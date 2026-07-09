using System.Collections.Generic;
using YYT.Entity;
using YYT.Remote;

namespace YYT.BLL.Services.GameServer
{
    public interface IGameServerClient
    {
        string SendRaw(EScMsgType command, params object[] args);
        Msg SendTranslated(EScMsgType command, params object[] args);
        GameCommandResult KickPlayer(string userAccount);
        PlayerRuntimeState QueryPlayerRuntimeState(string userAccount);
        List<OnlinePlayerInfo> QueryAllOnlinePlayers();
        Msg SetUserControl(params object[] args);
        Msg LockPlayer(string userAccount);
        string UnlockPlayer(int rechargeType, int result, long? coins, string userAccount);
    }
}
