using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Remote;

namespace YYT.BLL.Services.GameServer
{
    public class PipeGameServerClient : IGameServerClient
    {
        private readonly B_GameCommandOutbox commandOutbox;

        // 管道熔断：游戏服不可达时每次指令都要等 Connect 超时（5-10 秒），
        // 冷却期内直接快速失败（冷却结束放行一次真实重试，成功即复位）。
        private static readonly object breakerLock = new object();
        private static DateTime breakerOpenUntilUtc = DateTime.MinValue;
        private const int BreakerCooldownSeconds = 30;

        private static bool IsBreakerOpen()
        {
            lock (breakerLock)
            {
                return DateTime.UtcNow < breakerOpenUntilUtc;
            }
        }

        private static void RecordTransportResult(bool failed)
        {
            lock (breakerLock)
            {
                breakerOpenUntilUtc = failed ? DateTime.UtcNow.AddSeconds(BreakerCooldownSeconds) : DateTime.MinValue;
            }
        }

        public PipeGameServerClient()
        {
            commandOutbox = new B_GameCommandOutbox();
        }

        /// <summary>
        /// 在线玩家查询(QA)的连接/读写超时（毫秒）。
        /// QA 是玩家列表页首屏与刷新按钮的关键路径，正常时管道往返只有几毫秒；
        /// 游戏服不可达时若沿用默认的 5s/10s 超时，请求线程会被占住十几秒，
        /// ASP.NET 线程池补线程太慢，整个站点（含静态文件）一起卡住
        /// （2026-09-17 线上 IIS 日志：游戏服停机窗口内 jquery.min.map 与接口同时卡 10 秒）。
        /// 因此这类"查不到就算了"的轮询指令必须快速失败，由熔断器兜住后续请求。
        /// </summary>
        private const int OnlineQueryConnectTimeoutMs = 1000;
        private const int OnlineQueryReadTimeoutMs = 3000;

        public string SendRaw(EScMsgType command, params object[] args)
        {
            return SendRawWithTimeouts(command, 0, 0, args);
        }

        /// <summary>指定管道超时的发送；connectTimeoutMs/readWriteTimeoutMs 传 0 表示用 SConnect 默认值。</summary>
        private string SendRawWithTimeouts(EScMsgType command, int connectTimeoutMs, int readWriteTimeoutMs, params object[] args)
        {
            if (IsBreakerOpen())
                return "数据发送失败！游戏服管道熔断冷却中";
            var srv = connectTimeoutMs > 0 || readWriteTimeoutMs > 0
                ? new SConnect(connectTimeoutMs, readWriteTimeoutMs)
                : new SConnect();
            string raw = srv.SendNotTranlation(command, args);
            RecordTransportResult(IsTransportFailure(raw));
            return raw;
        }

        public Msg SendTranslated(EScMsgType command, params object[] args)
        {
            if (IsBreakerOpen())
                return new Msg(0, "游戏服管道熔断冷却中");
            var srv = new SConnect();
            Msg msg = srv.SendReadString(command, args);
            return msg;
        }

        public GameCommandResult KickPlayer(string userAccount)
        {
            M_GameCommandOutbox command = commandOutbox.Create("KU", userAccount, new { UserAccount = userAccount });
            try
            {
                commandOutbox.MarkSent(command?.CommandId);
                string raw = SendRaw(EScMsgType.KU, userAccount);
                if (IsTransportFailure(raw))
                {
                    commandOutbox.MarkFailed(command?.CommandId, raw, raw);
                    GameCommandResult fail = GameCommandResult.Fail("KU", userAccount, raw, raw);
                    fail.CommandId = command?.CommandId;
                    return fail;
                }

                string t = (raw ?? "").Trim();
                if (t.StartsWith("KUOK", StringComparison.Ordinal))
                {
                    commandOutbox.MarkAcked(command?.CommandId, t);
                    GameCommandResult success = GameCommandResult.Success("KU", userAccount, "踢人指令已执行，玩家已被踢出。", t);
                    success.CommandId = command?.CommandId;
                    return success;
                }
                if (t.StartsWith("KUOFFLINE", StringComparison.Ordinal))
                {
                    commandOutbox.MarkAcked(command?.CommandId, t);
                    GameCommandResult success = GameCommandResult.Success("KU", userAccount, "玩家当前不在线，无需踢出。", t);
                    success.CommandId = command?.CommandId;
                    return success;
                }

                string error = "游戏服务未确认踢人：" + t;
                commandOutbox.MarkFailed(command?.CommandId, t, error);
                GameCommandResult fail = GameCommandResult.Fail("KU", userAccount, error, t);
                fail.CommandId = command?.CommandId;
                return fail;
            }
            catch (Exception ex)
            {
                commandOutbox.MarkFailed(command?.CommandId, null, ex.Message);
                LogHelper.WriteLog(typeof(PipeGameServerClient), ex);
                GameCommandResult fail = GameCommandResult.Fail("KU", userAccount, "踢人指令发送失败：" + ex.Message);
                fail.CommandId = command?.CommandId;
                return fail;
            }
        }

        public PlayerRuntimeState QueryPlayerRuntimeState(string userAccount)
        {
            var state = new PlayerRuntimeState
            {
                UserId = userAccount,
                QuerySucceeded = false,
                Message = "查询失败！"
            };

            try
            {
                string raw = SendRaw(EScMsgType.QU, userAccount);
                state.RawResponse = raw;
                if (IsTransportFailure(raw))
                {
                    state.Message = raw;
                    return state;
                }

                state.Data = JsonConvert.DeserializeObject<M_UserOnlineData>(raw);
                state.QuerySucceeded = state.Data != null;
                state.Message = state.QuerySucceeded ? "查询成功！" : "实时状态返回为空！";
            }
            catch (Exception ex)
            {
                state.Message = "查询失败：" + ex.Message;
                LogHelper.WriteLog(typeof(PipeGameServerClient), ex);
            }
            return state;
        }

        /// <summary>
        /// 查询全部在线玩家。游戏服不可达/超时返回 <c>null</c>，与"查得到但一个人都不在线"（空列表）
        /// 区分开——否则端上只能显示"暂无在线玩家"，运营会误以为玩家都下线了。
        /// </summary>
        public List<OnlinePlayerInfo> QueryAllOnlinePlayers()
        {
            try
            {
                string raw = SendRawWithTimeouts(EScMsgType.QA, OnlineQueryConnectTimeoutMs, OnlineQueryReadTimeoutMs);
                if (IsTransportFailure(raw))
                {
                    LogHelper.WriteLog(typeof(PipeGameServerClient), "QA transport failure: " + raw);
                    return null;
                }

                var list = JsonConvert.DeserializeObject<List<OnlinePlayerInfo>>(raw);
                return list ?? new List<OnlinePlayerInfo>();
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(PipeGameServerClient), ex);
                return null;
            }
        }

        public Msg SetUserControl(params object[] args)
        {
            M_GameCommandOutbox command = commandOutbox.Create("UC", GetLastArgAsTarget(args), new { Args = args });
            try
            {
                commandOutbox.MarkSent(command?.CommandId);
                Msg msg = SendTranslated(EScMsgType.UC, args);
                if (msg != null && msg.code == 1)
                    commandOutbox.MarkAcked(command?.CommandId, msg.datas == null ? msg.content : msg.datas.ToString());
                else
                    commandOutbox.MarkFailed(command?.CommandId, msg == null ? null : msg.datas == null ? null : msg.datas.ToString(), msg == null ? "游戏服务返回为空" : msg.content);
                return msg;
            }
            catch (Exception ex)
            {
                commandOutbox.MarkFailed(command?.CommandId, null, ex.Message);
                throw;
            }
        }

        public Msg QueueUserControl(params object[] args)
        {
            M_GameCommandOutbox command = commandOutbox.Create("UC", GetLastArgAsTarget(args), new { Args = args });
            if (command == null)
                return new Msg(0, "指令排队失败！");

            return new Msg(1, "已受理，处理中！")
            {
                datas = new { CommandId = command.CommandId }
            };
        }

        public Msg QueueLockPlayer(string userAccount)
        {
            M_GameCommandOutbox command = commandOutbox.Create("LK", userAccount, new { UserAccount = userAccount });
            if (command == null)
                return new Msg(0, "指令排队失败！");

            return new Msg(1, "已受理，处理中！")
            {
                datas = new { CommandId = command.CommandId }
            };
        }

        public Msg LockPlayer(string userAccount)
        {
            M_GameCommandOutbox command = commandOutbox.Create("LK", userAccount, new { UserAccount = userAccount });
            try
            {
                commandOutbox.MarkSent(command?.CommandId);
                Msg msg = SendTranslated(EScMsgType.LK, userAccount);
                if (msg != null && msg.code == 1)
                    commandOutbox.MarkAcked(command?.CommandId, msg.datas == null ? msg.content : msg.datas.ToString());
                else
                    commandOutbox.MarkFailed(command?.CommandId, msg == null ? null : msg.datas == null ? null : msg.datas.ToString(), msg == null ? "游戏服务返回为空" : msg.content);
                return msg;
            }
            catch (Exception ex)
            {
                commandOutbox.MarkFailed(command?.CommandId, null, ex.Message);
                throw;
            }
        }

        public string UnlockPlayer(int rechargeType, int result, long? coins, string userAccount)
        {
            M_GameCommandOutbox command = commandOutbox.Create("UL", userAccount, new { RechargeType = rechargeType, Result = result, Coins = coins, UserAccount = userAccount });
            try
            {
                commandOutbox.MarkSent(command?.CommandId);
                string raw = SendRaw(EScMsgType.UL, rechargeType, result, coins, "/", userAccount);
                if (IsTransportFailure(raw))
                    commandOutbox.MarkFailed(command?.CommandId, raw, raw);
                else
                    commandOutbox.MarkAcked(command?.CommandId, raw);
                return raw;
            }
            catch (Exception ex)
            {
                commandOutbox.MarkFailed(command?.CommandId, null, ex.Message);
                throw;
            }
        }

        public Msg QueueUnlockPlayer(int rechargeType, int result, long? coins, string userAccount)
        {
            M_GameCommandOutbox command = commandOutbox.Create("UL", userAccount, new
            {
                RechargeType = rechargeType,
                Result = result,
                Coins = coins,
                UserAccount = userAccount
            });
            if (command == null)
                return new Msg(0, "指令排队失败！");

            return new Msg(1, "已受理，处理中！")
            {
                datas = new { CommandId = command.CommandId }
            };
        }

        private static bool IsTransportFailure(string raw)
        {
            return string.IsNullOrWhiteSpace(raw) || raw.StartsWith("\u6570\u636e\u53d1\u9001\u5931\u8d25\uff01", StringComparison.Ordinal);
        }

        private static string GetLastArgAsTarget(object[] args)
        {
            if (args == null || args.Length < 1 || args[args.Length - 1] == null)
                return null;
            return args[args.Length - 1].ToString();
        }
    }
}
