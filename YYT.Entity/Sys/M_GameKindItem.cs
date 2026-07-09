using System.Runtime.Serialization;

namespace YYT.Entity
{
    /// <summary>
    ///  游戏信息实体类
    /// </summary>
    [DataContract]
    public class M_GameKindItem
    {
        public M_GameKindItem() { }

        /// <summary>
        ///  标识ID
        /// </summary>
        [DataMember(Name = "id")]
        public int id { get; set; }
        /// <summary>
        ///  类型标识
        /// </summary>
        [DataMember(Name = "KindID")]
        public int KindID { get; set; }
        /// <summary>
        ///  游戏标识
        /// </summary>
        [DataMember(Name = "GameID")]
        public int GameID { get; set; }
        /// <summary>
        ///  游戏名称
        /// </summary>
        [DataMember(Name = "KindName")]
        public string KindName { get; set; }
        /// <summary>
        ///  状态标识 0表示关闭 1表示开启 
        /// </summary>
        [DataMember(Name = "GameStatus")]
        public int GameStatus { get; set; }
    }
}
