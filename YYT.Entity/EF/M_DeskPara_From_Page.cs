namespace YYT.Entity
{
    public class M_BetDeskPara
    {
        /// <summary>
        /// 游戏ID
        /// </summary>
        public int GAME_ID { get; set; }
        /// <summary>
        /// 游戏类型
        /// </summary>
        public int GAME_TYPE { get; set; }


        /// <summary>
        /// 选择的房间
        /// </summary>
        public int RoomSel { get; set; }
        /// <summary>
        /// 选择的机台
        /// </summary>
        public int DeskSel { get; set; }
        /// <summary>
        /// 系统难度
        /// </summary>
        public int DIF { get; set; }
        /// <summary>
        /// 系统加难
        /// </summary>
        public int HAR { get; set; }
        /// <summary>
        /// 系统起伏
        /// </summary>
        public int SITE_TYPE { get; set; }
        /// <summary>
        /// 庄家难度
        /// </summary>
        public int BANKER_DIF { get; set; }
        /// <summary>
        /// 庄家加难
        /// </summary>
        public int BANKER_HAR { get; set; }
        /// <summary>
        /// 庄家起伏
        /// </summary>
        public int BANKER_SITE_TYPE { get; set; }
        /// <summary>
        /// 庄家抽水
        /// </summary>
        public int BANKER_PER { get; set; }

    }

    public class M_CardDeskPara
    {
        /// <summary>
        /// 游戏ID
        /// </summary>
        public int GAME_ID { get; set; }
        /// <summary>
        /// 游戏类型
        /// </summary>
        public int GAME_TYPE { get; set; }


        /// <summary>
        /// 选择的房间
        /// </summary>
        public int RoomSel { get; set; }
        /// <summary>
        /// 选择的机台
        /// </summary>
        public int DeskSel { get; set; }
        /// <summary>
        /// 炒场类型
        /// </summary>
        public int HYPE_TYPE { get; set; }
        /// <summary>
        /// 牌机难度
        /// </summary>
        public string DIF { get; set; }
    }

    public class M_FishDeskPara
    {
        /// <summary>
        /// 游戏ID
        /// </summary>
        public int GAME_ID { get; set; }
        /// <summary>
        /// 游戏类型
        /// </summary>
        public int GAME_TYPE { get; set; }


        /// <summary>
        /// 选择的房间
        /// </summary>
        public int RoomSel { get; set; }
        /// <summary>
        /// 选择的机台
        /// </summary>
        public int DeskSel { get; set; }
        /// <summary>
        /// 鱼机难度
        /// </summary>
        public int DIF { get; set; }
        /// <summary>
        /// 场地类型
        /// </summary>
        public int SITE_TYPE { get; set; }
    }
}
