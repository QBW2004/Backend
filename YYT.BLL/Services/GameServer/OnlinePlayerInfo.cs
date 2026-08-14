using Newtonsoft.Json;

namespace YYT.BLL.Services.GameServer
{
    /// <summary>
    /// 在线玩家实时信息（由游戏服务端 QA 命令返回）
    /// </summary>
    public class OnlinePlayerInfo
    {
        [JsonProperty("ID")]
        public string ID { get; set; }

        [JsonProperty("NAME")]
        public string NAME { get; set; }

        [JsonProperty("AGENCY")]
        public string AGENCY { get; set; }

        [JsonProperty("UserID")]
        public int UserID { get; set; }

        [JsonProperty("GameID")]
        public int GameID { get; set; }

        [JsonProperty("RoomId")]
        public int RoomId { get; set; }

        [JsonProperty("TableId")]
        public int TableId { get; set; }

        [JsonProperty("SeatId")]
        public int SeatId { get; set; }

        [JsonProperty("Coins")]
        public long Coins { get; set; }

        [JsonProperty("Score")]
        public long Score { get; set; }

        [JsonProperty("CurGameScore")]
        public long CurGameScore { get; set; }

        [JsonProperty("CurBet")]
        public long CurBet { get; set; }

        [JsonProperty("TotalWinLoss")]
        public long TotalWinLoss { get; set; }

        /// <summary>
        /// 总盈亏 = 用户注册以来每天「今日盈亏」之和（后台补充，SUM user_daily_winloss 全量，与用户管理页总盈亏同口径）
        /// </summary>
        [JsonProperty("Profit")]
        public long Profit { get; set; }

        /// <summary>
        /// 今日盈亏（后台补充，取 user_daily_winloss 当日数据，与用户管理页今日盈亏同口径）
        /// </summary>
        [JsonProperty("TodayWinLoss")]
        public long TodayWinLoss { get; set; }

        /// <summary>
        /// 状态: 0=游戏中, 1=大厅, 2=其他
        /// </summary>
        [JsonProperty("Status")]
        public int Status { get; set; }
    }
}
