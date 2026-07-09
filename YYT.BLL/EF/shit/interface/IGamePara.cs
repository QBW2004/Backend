using System.Collections.Generic;
using YYT.Entity;

namespace YYT.BLL.EF
{
    public interface IGamePara
    {
        Dictionary<string, dynamic> GetGameParams(int gameId);

        Msg SaveRoomPara<T>(T t);

        Msg SaveDeskPara<T>(T t);

        List<M_GameRoomDeskPara> GetGameRoomDeskPara(int gameId);
    }
}
