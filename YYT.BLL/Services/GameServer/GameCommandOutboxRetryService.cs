using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Threading;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Remote;

namespace YYT.BLL.Services.GameServer
{
    public class GameCommandOutboxRetryService
    {
        private static int processing;
        private readonly B_GameCommandOutbox commandOutbox;
        private readonly IGameServerClient gameServerClient;

        public GameCommandOutboxRetryService() : this(new B_GameCommandOutbox(), new PipeGameServerClient())
        {
        }

        public GameCommandOutboxRetryService(B_GameCommandOutbox commandOutbox, IGameServerClient gameServerClient)
        {
            this.commandOutbox = commandOutbox;
            this.gameServerClient = gameServerClient;
        }

        public int ProcessDueCommands(int take = 20)
        {
            if (Interlocked.Exchange(ref processing, 1) == 1)
                return 0;

            try
            {
                List<M_GameCommandOutbox> commands = commandOutbox.ClaimRetryableCommands(take);
                int processed = 0;

                foreach (M_GameCommandOutbox command in commands)
                {
                    try
                    {
                        if (Retry(command))
                            processed++;
                    }
                    catch (Exception ex)
                    {
                        commandOutbox.MarkFailed(command.CommandId, null, ex.Message);
                        LogHelper.WriteLog(typeof(GameCommandOutboxRetryService), ex);
                    }
                }

                return processed;
            }
            finally
            {
                Volatile.Write(ref processing, 0);
            }
        }

        private bool Retry(M_GameCommandOutbox command)
        {
            if (command == null || string.IsNullOrWhiteSpace(command.CommandId))
                return false;

            commandOutbox.MarkRetrying(command.CommandId);

            string commandType = (command.CommandType ?? string.Empty).Trim().ToUpperInvariant();

            // 命名管道 RPC 的 sr.ReadLine() 在 Center 接受连接但不回复时会永久阻塞
            // (ReadTimeout 对 StreamReader 不可靠)。用带超时的 Task 包裹，超时则
            // MarkFailed 放弃本条，避免定时器线程被卡死导致后续命令全部堆积。
            // TC 命令的回复读取有历史兼容问题(Center 二进制管道消息边界)，
            // 用更短超时且失败后停止重试，避免反复重试拖慢整个 outbox 队列。
            bool isTableConfig = commandType == "TC";
            int rpcTimeoutMs = isTableConfig ? 5000 : 15000;
            bool result = false;
            Exception error = null;
            var task = System.Threading.Tasks.Task.Run(() =>
            {
                try
                {
                    switch (commandType)
                    {
                        case "KU":
                            result = RetryKick(command);
                            break;
                        case "UC":
                            result = RetryUserControl(command);
                            break;
                        case "LK":
                            result = RetryLock(command);
                            break;
                        case "UL":
                            result = RetryUnlock(command);
                            break;
                        case "RP":
                            result = RetryRoomRefresh(command);
                            break;
                        case "TC":
                            result = RetryTableConfig(command);
                            break;
                        default:
                            commandOutbox.MarkFailed(command.CommandId, null, "Unsupported game command type: " + command.CommandType);
                            result = false;
                            break;
                    }
                }
                catch (Exception ex)
                {
                    error = ex;
                }
            });
            if (!task.Wait(rpcTimeoutMs))
            {
                // 超时：底层 RPC 仍可能阻塞在该线程上，但本调用放弃。
                // TC 超时直接标记 Acked 停止重试(历史 bug，重试无意义且拖慢队列)；
                // 其它命令标记 Failed 待重试。
                if (isTableConfig)
                {
                    commandOutbox.MarkAcked(command.CommandId, "TC timeout - skipped (historical pipe issue)");
                    LogHelper.WriteLog(typeof(GameCommandOutboxRetryService), "TC timeout skipped for command " + command.CommandId);
                }
                else
                {
                    commandOutbox.MarkFailed(command.CommandId, null, "RPC timeout (" + rpcTimeoutMs + "ms) for " + commandType);
                    LogHelper.WriteLog(typeof(GameCommandOutboxRetryService), "RPC timeout for command " + command.CommandId + " type=" + commandType);
                }
                return false;
            }
            if (error != null)
            {
                // TC 异常也停止重试(管道未连接等)，避免拖慢队列。
                if (isTableConfig)
                {
                    commandOutbox.MarkAcked(command.CommandId, "TC error skipped: " + error.Message);
                    LogHelper.WriteLog(typeof(GameCommandOutboxRetryService), "TC error skipped for " + command.CommandId + ": " + error.Message);
                }
                else
                {
                    commandOutbox.MarkFailed(command.CommandId, null, error.Message);
                    LogHelper.WriteLog(typeof(GameCommandOutboxRetryService), error);
                }
                return false;
            }
            // TC 发送成功但 code=0(失败) 也停止重试，避免反复重试拖慢队列。
            if (isTableConfig && !result)
            {
                commandOutbox.MarkAcked(command.CommandId, "TC failed - skipped to avoid retry storm");
            }
            return result;
        }

        private bool RetryKick(M_GameCommandOutbox command)
        {
            string userAccount = ReadString(command.Payload, "UserAccount") ?? command.TargetUserId;
            string raw = gameServerClient.SendRaw(EScMsgType.KU, userAccount);
            return MarkRawResult(command.CommandId, raw);
        }

        private bool RetryUserControl(M_GameCommandOutbox command)
        {
            object[] args = ReadArgs(command.Payload);
            Msg msg = gameServerClient.SendTranslated(EScMsgType.UC, args);
            if (msg != null && msg.code == 1)
            {
                commandOutbox.MarkAcked(command.CommandId, msg.datas == null ? msg.content : msg.datas.ToString());
                return true;
            }

            commandOutbox.MarkFailed(
                command.CommandId,
                msg == null || msg.datas == null ? null : msg.datas.ToString(),
                msg == null ? "Game server returned empty response." : msg.content);
            return false;
        }

        private bool RetryLock(M_GameCommandOutbox command)
        {
            string userAccount = ReadString(command.Payload, "UserAccount") ?? command.TargetUserId;
            Msg msg = gameServerClient.SendTranslated(EScMsgType.LK, userAccount);
            if (msg != null && msg.code == 1)
            {
                commandOutbox.MarkAcked(command.CommandId, msg.datas == null ? msg.content : msg.datas.ToString());
                return true;
            }

            commandOutbox.MarkFailed(
                command.CommandId,
                msg == null || msg.datas == null ? null : msg.datas.ToString(),
                msg == null ? "Game server returned empty response." : msg.content);
            return false;
        }

        private bool RetryUnlock(M_GameCommandOutbox command)
        {
            int rechargeType = ReadInt(command.Payload, "RechargeType");
            int result = ReadInt(command.Payload, "Result");
            long? coins = ReadNullableLong(command.Payload, "Coins");
            string userAccount = ReadString(command.Payload, "UserAccount") ?? command.TargetUserId;
            string raw = gameServerClient.SendRaw(EScMsgType.UL, rechargeType, result, coins, "/", userAccount);
            return MarkRawResult(command.CommandId, raw);
        }

        // RP(房间参数重载)：Center 收到后按 paragame.ROOM_MAX 全量重读房间/桌台配置，
        // 是桌台热更新的关键命令。Payload 仅含 GameId。
        private bool RetryRoomRefresh(M_GameCommandOutbox command)
        {
            int gameId = ReadInt(command.Payload, "GameId");
            if (gameId <= 0)
            {
                commandOutbox.MarkFailed(command.CommandId, null, "RP payload missing GameId");
                return false;
            }
            Msg msg = gameServerClient.SendTranslated(EScMsgType.RP, gameId);
            if (msg != null && msg.code == 1)
            {
                commandOutbox.MarkAcked(command.CommandId, msg.content);
                return true;
            }
            commandOutbox.MarkFailed(
                command.CommandId,
                null,
                msg == null ? "Game server returned empty response for RP." : msg.content);
            return false;
        }

        // TC(桌台配置热更新)：二进制命令，不走文本模板，需直接 SConnect.SendTcCommand
        // 重组包发送。Payload 含全部 TC 参数(含可选 TcBetExt/TcTableExt 扩展字段)。
        private bool RetryTableConfig(M_GameCommandOutbox command)
        {
            int gameId = ReadInt(command.Payload, "GameId");
            int tableIndex = ReadInt(command.Payload, "TableIndex");
            if (gameId <= 0)
            {
                commandOutbox.MarkFailed(command.CommandId, null, "TC payload missing GameId");
                return false;
            }
            string tableName = ReadString(command.Payload, "TableName") ?? string.Empty;
            bool enabled = ReadBool(command.Payload, "Enabled");
            uint idleSec = ReadUInt(command.Payload, "IdleFireTimeoutSec");
            byte idleKick = ReadBool(command.Payload, "IdleFireKickEnabled") ? (byte)1 : (byte)0;
            ushort maxSeats = ReadUShort(command.Payload, "MaxSeats");

            SConnect.TcTableExt tableExt = ReadTableExt(command.Payload);
            SConnect.TcBetExt betExt = ReadBetExt(command.Payload);

            var srv = new SConnect();
            Msg msg = srv.SendTcCommand(
                (ushort)gameId, 0, (ushort)tableIndex, tableName,
                enabled ? (byte)1 : (byte)0, idleSec, idleKick, maxSeats, betExt, tableExt);
            if (msg != null && msg.code == 1)
            {
                commandOutbox.MarkAcked(command.CommandId, msg.content);
                return true;
            }
            commandOutbox.MarkFailed(
                command.CommandId,
                null,
                msg == null ? "Game server returned empty response for TC." : msg.content);
            return false;
        }

        private static SConnect.TcTableExt ReadTableExt(string payload)
        {
            JToken token = ParsePayload(payload)["TableExt"];
            if (token == null || token.Type == JTokenType.Null)
                return null;
            return new SConnect.TcTableExt
            {
                BetMin = token.Value<uint>("BetMin"),
                BetMax = token.Value<uint>("BetMax"),
                OneCoinScore = token.Value<uint>("OneCoinScore"),
                CoinsNeed = token.Value<uint>("CoinsNeed")
            };
        }

        private static SConnect.TcBetExt ReadBetExt(string payload)
        {
            JToken token = ParsePayload(payload)["BetExt"];
            if (token == null || token.Type == JTokenType.Null)
                return null;
            return new SConnect.TcBetExt
            {
                BetTime = token.Value<byte>("BetTime"),
                BetMin = token.Value<uint>("BetMin"),
                BetMax = token.Value<uint>("BetMax"),
                BankerScoreNeed = token.Value<uint>("BankerScoreNeed"),
                ItemSingleScoreLimit = token.Value<uint>("ItemSingleScoreLimit"),
                ItemAllScoreLimit = token.Value<uint>("ItemAllScoreLimit"),
                CoinsNeed = token.Value<uint>("CoinsNeed"),
                OneCoinScore = token.Value<uint>("OneCoinScore"),
                BetScores = token.Value<string>("BetScores") ?? string.Empty,
                DefaultBetIndex = token.Value<byte>("DefaultBetIndex"),
                IncludeViceDraw = token.Value<bool>("IncludeViceDraw"),
                BetMinVice = token.Value<uint>("BetMinVice"),
                BetMaxVice = token.Value<uint>("BetMaxVice"),
                BetMinDraw = token.Value<uint>("BetMinDraw"),
                BetMaxDraw = token.Value<uint>("BetMaxDraw")
            };
        }

        private bool MarkRawResult(string commandId, string raw)
        {
            if (IsTransportFailure(raw))
            {
                commandOutbox.MarkFailed(commandId, raw, raw);
                return false;
            }

            commandOutbox.MarkAcked(commandId, raw);
            return true;
        }

        private static bool IsTransportFailure(string raw)
        {
            return string.IsNullOrWhiteSpace(raw) || raw.StartsWith("\u6570\u636e\u53d1\u9001\u5931\u8d25\uff01", StringComparison.Ordinal);
        }

        private static JObject ParsePayload(string payload)
        {
            if (string.IsNullOrWhiteSpace(payload))
                return new JObject();
            return JObject.Parse(payload);
        }

        private static string ReadString(string payload, string name)
        {
            JToken token = ParsePayload(payload)[name];
            return token == null || token.Type == JTokenType.Null ? null : token.ToString();
        }

        private static int ReadInt(string payload, string name)
        {
            JToken token = ParsePayload(payload)[name];
            return token == null || token.Type == JTokenType.Null ? 0 : token.Value<int>();
        }

        private static bool ReadBool(string payload, string name)
        {
            JToken token = ParsePayload(payload)[name];
            if (token == null || token.Type == JTokenType.Null)
                return false;
            if (token.Type == JTokenType.Boolean)
                return token.Value<bool>();
            return token.Value<int>() != 0;
        }

        private static uint ReadUInt(string payload, string name)
        {
            JToken token = ParsePayload(payload)[name];
            return token == null || token.Type == JTokenType.Null ? 0u : token.Value<uint>();
        }

        private static ushort ReadUShort(string payload, string name)
        {
            JToken token = ParsePayload(payload)[name];
            return token == null || token.Type == JTokenType.Null ? (ushort)0 : token.Value<ushort>();
        }

        private static long? ReadNullableLong(string payload, string name)
        {
            JToken token = ParsePayload(payload)[name];
            return token == null || token.Type == JTokenType.Null ? (long?)null : token.Value<long>();
        }

        private static object[] ReadArgs(string payload)
        {
            JArray args = ParsePayload(payload)["Args"] as JArray;
            if (args == null)
                return new object[0];

            object[] values = new object[args.Count];
            for (int i = 0; i < args.Count; i++)
                values[i] = args[i] == null || args[i].Type == JTokenType.Null ? null : args[i].ToObject<object>();
            return values;
        }
    }
}
