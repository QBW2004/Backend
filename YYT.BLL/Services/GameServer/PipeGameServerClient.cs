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

        public PipeGameServerClient()
        {
            commandOutbox = new B_GameCommandOutbox();
        }

        public string SendRaw(EScMsgType command, params object[] args)
        {
            var srv = new SConnect();
            return srv.SendNotTranlation(command, args);
        }

        public Msg SendTranslated(EScMsgType command, params object[] args)
        {
            var srv = new SConnect();
            return srv.SendReadString(command, args);
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

                commandOutbox.MarkAcked(command?.CommandId, raw);
                GameCommandResult success = GameCommandResult.Success("KU", userAccount, "踢人指令已由游戏服务响应。", raw);
                success.CommandId = command?.CommandId;
                return success;
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

        public List<OnlinePlayerInfo> QueryAllOnlinePlayers()
        {
            List<OnlinePlayerInfo> result = new List<OnlinePlayerInfo>();
            try
            {
                string raw = SendRaw(EScMsgType.QA);
                if (IsTransportFailure(raw))
                {
                    LogHelper.WriteLog(typeof(PipeGameServerClient), "QA transport failure: " + raw);
                    return result;
                }

                var list = JsonConvert.DeserializeObject<List<OnlinePlayerInfo>>(raw);
                if (list != null)
                    result = list;
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(PipeGameServerClient), ex);
            }
            return result;
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
