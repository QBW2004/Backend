using System.Runtime.Serialization;

namespace YYT.Entity
{
    /// <summary>
    /// 奖池
    /// </summary>
    [DataContract]
    public class M_GameStorage
    {
        /// <summary>
        /// RowIndex
        /// </summary>
        [DataMember(Name = "RowIndex")]
        public int RowIndex { get; set; }

        /// <summary>
        /// 标识ID
        /// </summary>
        [DataMember(Name = "id")]
        public int id { get; set; }

        /// <summary>
        /// 游戏房间ID
        /// </summary>
        [DataMember(Name = "ServerID")]
        public int ServerID { get; set; }

        /// <summary>
        /// 奖池
        /// </summary>
        [DataMember(Name = "Storage")]
        public long Storage { get; set; }

        /// <summary>
        /// 增长率
        /// </summary>
        [DataMember(Name = "GrowthRate")]
        public float GrowthRate { get; set; }

        /// <summary>
        /// 数据时间
        /// </summary>
        [DataMember(Name = "WriteTime")]
        public string WriteTime { get; set; }

    }
}
