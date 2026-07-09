using System.Collections.Generic;
using YYT.Entity;
using YYT.BLL.EF;

namespace YYT.BLL.Services.GameServer
{
    public class PlayerStateService
    {
        private readonly IGameServerClient gameServerClient;

        public PlayerStateService() : this(new PipeGameServerClient())
        {
        }

        public PlayerStateService(IGameServerClient gameServerClient)
        {
            this.gameServerClient = gameServerClient;
        }

        public Msg QueryRuntimeState(string userAccount)
        {
            PlayerRuntimeState state = gameServerClient.QueryPlayerRuntimeState(userAccount);
            FillAccountCoins(state);
            return new Msg(state.QuerySucceeded ? 1 : 0, state.Message)
            {
                datas = state
            };
        }

        public List<OnlinePlayerInfo> QueryAllOnlinePlayers()
        {
            return gameServerClient.QueryAllOnlinePlayers();
        }

        private void FillAccountCoins(PlayerRuntimeState state)
        {
            if (state == null || string.IsNullOrWhiteSpace(state.UserId))
                return;

            using (var ef = new GameDbContext())
            {
                M_Users user = ef.Users.Find(state.UserId);
                if (user != null)
                    state.AccountCoins = user.COINS;
            }
        }
    }
}
