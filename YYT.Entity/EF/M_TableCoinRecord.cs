using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    /// <summary>
    /// 桌子输赢记录
    /// </summary>
    [Table("TableCoinRecord")]
    public class M_TableCoinRecord
    {
        [Key]
        public int RecIndex { get; set; }
        /// <summary>
        /// 游戏ID
        /// </summary>
        public int GameID { get; set; }
        /// <summary>
        /// 游戏名称
        /// </summary>
        [NotMapped]
        public string GameName { get; set; }
        /// <summary>
        /// 房间ID
        /// </summary>
        public int RoomID { get; set; }
        /// <summary>
        /// 桌子ID
        /// </summary>
        public int TableID { get; set; }
        /// <summary>
        /// 金币
        /// </summary>
        public long Coins { get; set; }
        /// <summary>
        /// 记录时间
        /// </summary>
        public DateTime CreateTime { get; set; }
        [NotMapped]
        public string CreateTimeStr { get { return this.CreateTime.ToString("yyyy-MM-dd HH:mm:ss"); } }
    }

    public class M_TableCoinRecord_DTO
    {
        public int RecIndex { get; set; }
        /// <summary>
        /// 游戏ID
        /// </summary>
        public int GameID { get; set; }
        /// <summary>
        /// 游戏名称
        /// </summary>
        [NotMapped]
        public string GameName { get; set; }
        /// <summary>
        /// 房间ID
        /// </summary>
        public int RoomID { get; set; }
        /// <summary>
        /// 桌子ID
        /// </summary>
        public int TableID { get; set; }
        /// <summary>
        /// 金币
        /// </summary>
        public long Coins { get; set; }
        /// <summary>
        /// 记录时间
        /// </summary>
        public DateTime CreateTime { get; set; }
        [NotMapped]
        public string CreateTimeStr { get { return this.CreateTime.ToString("yyyy-MM-dd HH:mm:ss"); } }
    }
}
