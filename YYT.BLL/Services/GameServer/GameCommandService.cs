using YYT.Entity;

namespace YYT.BLL.Services.GameServer
{
    public class GameCommandService
    {
        private readonly IGameServerClient gameServerClient;

        public GameCommandService() : this(new PipeGameServerClient())
        {
        }

        public GameCommandService(IGameServerClient gameServerClient)
        {
            this.gameServerClient = gameServerClient;
        }

        public Msg KickPlayer(string userAccount)
        {
            GameCommandResult result = gameServerClient.KickPlayer(userAccount);
            return new Msg(result.Code, result.Message)
            {
                datas = result
            };
        }

        public Msg SetUserControl(params object[] args)
        {
            return gameServerClient.SetUserControl(args);
        }
    }
}
