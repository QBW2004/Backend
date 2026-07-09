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
            switch (commandType)
            {
                case "KU":
                    return RetryKick(command);
                case "UC":
                    return RetryUserControl(command);
                case "LK":
                    return RetryLock(command);
                case "UL":
                    return RetryUnlock(command);
                default:
                    commandOutbox.MarkFailed(command.CommandId, null, "Unsupported game command type: " + command.CommandType);
                    return false;
            }
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
