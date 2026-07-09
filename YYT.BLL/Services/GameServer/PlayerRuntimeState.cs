using YYT.Entity;

namespace YYT.BLL.Services.GameServer
{
    public class PlayerRuntimeState
    {
        public string UserId { get; set; }
        public bool QuerySucceeded { get; set; }
        public string RawResponse { get; set; }
        public string Message { get; set; }
        public long? AccountCoins { get; set; }
        public M_UserOnlineData Data { get; set; }

        public string RuntimeStatusText
        {
            get
            {
                switch (RuntimeStatus)
                {
                    case 0:
                        return "NeverLoggedIn";
                    case 1:
                        return "InGame";
                    case 2:
                        return "InHall";
                    case 3:
                        return "LoggedOut";
                    default:
                        return "Unknown";
                }
            }
        }

        public int? GameId
        {
            get { return Data == null ? null : Data.GameID; }
        }

        public long? RuntimeCoins
        {
            get { return Data == null ? null : Data.Coin; }
        }

        public long? GameScore
        {
            get { return Data == null ? null : Data.Score; }
        }

        public int RuntimeStatus
        {
            get { return Data == null ? -1 : Data.Ret; }
        }
    }
}
