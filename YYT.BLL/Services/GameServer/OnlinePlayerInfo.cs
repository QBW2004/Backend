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

        /// <summary>账号冻结状态：0 正常，1 冻结。</summary>
        [JsonProperty("FROZEN")]
        public int FROZEN { get; set; }

        [JsonProperty("UserID")]
        public int UserID { get; set; }

        [JsonProperty("GameID")]
        public int GameID { get; set; }

        [JsonProperty("RoomId")]
        public int RoomId { get; set; }

        [JsonProperty("TableId")]
        public int TableId { get; set; }

        /// <summary>中心实时坐下标记；缺失必须保留 null，播报校验不能推断为空桌。</summary>
        [JsonProperty("IsSitDown")]
        public bool? IsSitDown { get; set; }

        /// <summary>按该桌归属及选桌顺序生成的展示台号；TableId 仍保留协议原值。</summary>
        public string TableDisplay { get; set; }

        [JsonProperty("SeatId")]
        public int SeatId { get; set; }

        [JsonProperty("Coins")]
        public long Coins { get; set; }

        [JsonProperty("Score")]
        public long Score { get; set; }

        /// <summary>
        /// 机台内钻（子游戏上报的原始 mCoins，未做钻分折算；玩家坐下兑分后通常为 0）。
        /// 旧版中心服不下发时为 null，展示侧回退 Coins 口径。
        /// </summary>
        [JsonProperty("GameCoins")]
        public long? GameCoins { get; set; }

        /// <summary>
        /// 机台内分数（子游戏上报的原始 mGameScore，与游戏客户端显示的"分"同口径；
        /// 0.1 分炮鱼机为 0.1 分内部单位，展示需 ÷10）。旧版中心服不下发时为 null。
        /// </summary>
        [JsonProperty("GameScore")]
        public long? GameScore { get; set; }

        [JsonProperty("CurGameScore")]
        public long CurGameScore { get; set; }

        [JsonProperty("CurBetDiamonds")]
        public decimal? CurBetDiamonds { get; set; }

        [JsonProperty("CurBetUnitsPerCoin")]
        public uint? CurBetUnitsPerCoin { get; set; }

        [JsonProperty("CurBet")]
        public long CurBet { get; set; }

        [JsonProperty("TotalWinLoss")]
        public long TotalWinLoss { get; set; }

        /// <summary>
        /// 总盈亏 = 用户注册以来每天「今日盈亏」之和（后台补充，SUM user_daily_winloss 全量，与用户管理页总盈亏同口径）
        /// </summary>
        [JsonProperty("Profit")]
        public decimal Profit { get; set; }

        /// <summary>
        /// 今日盈亏（后台补充，取 user_daily_winloss 当日数据，与用户管理页今日盈亏同口径）
        /// </summary>
        [JsonProperty("TodayWinLoss")]
        public decimal TodayWinLoss { get; set; }

        /// <summary>
        /// 状态: 0=游戏中, 1=大厅, 2=其他
        /// </summary>
        [JsonProperty("Status")]
        public int Status { get; set; }
    }
}
