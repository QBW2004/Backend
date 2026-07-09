using System.Runtime.Serialization;

namespace YYT.Entity
{
    /// <summary>
    ///  用户日志信息实体类
    /// </summary>
    [DataContract]
    public class M_Base_AdminLog
    {
        public M_Base_AdminLog() { }
        /// <summary>
        ///  RowIndex
        /// </summary>
        [DataMember(Name = "RowIndex")]
        public int RowIndex { get; set; }
        /// <summary>
        ///  用户ID
        /// </summary>
        [DataMember(Name = "LogID")]
        public long LogID { get; set; }
        /// <summary>
        ///  帐号
        /// </summary>
        [DataMember(Name = "Accounts")]
        public string Accounts { get; set; }
        /// <summary>
        ///  登录时间
        /// </summary>
        [DataMember(Name = "WriteTime")]
        public string WriteTime { get; set; }
        /// <summary>
        ///  客户端IP地址
        /// </summary>
        [DataMember(Name = "ClientIP")]
        public string ClientIP { get; set; }
        /// <summary>
        ///  备注信息
        /// </summary>
        [DataMember(Name = "MsgContent")]
        public string MsgContent { get; set; }
    }
}
