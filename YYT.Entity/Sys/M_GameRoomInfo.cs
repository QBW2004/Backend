using System.Runtime.Serialization;

namespace YYT.Entity
{
    /// <summary>
    ///  房间信息实体类
    /// </summary>
    [DataContract]
    public class M_GameRoomInfo
    {
        public M_GameRoomInfo() { }

        /// <summary>
        ///  标识ID
        /// </summary>
        [DataMember(Name = "id")]
        public int id { get; set; }
        /// <summary>
        ///  类型标识
        /// </summary>
        [DataMember(Name = "ServerID")]
        public int ServerID { get; set; }
        /// <summary>
        ///  房间名称
        /// </summary>
        [DataMember(Name = "ServerName")]
        public string ServerName { get; set; }
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
        ///  状态标识 0表示关闭 1表示开启 
        /// </summary>
        [DataMember(Name = "RoomStatus")]
        public int RoomStatus { get; set; }
    }
}
