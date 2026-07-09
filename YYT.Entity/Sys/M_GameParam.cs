using System.Runtime.Serialization;

namespace YYT.Entity
{
    /// <summary>
    /// 配置参数类
    /// </summary>
    [DataContract]
    public class M_GameParam
    {
        public M_GameParam() { }

        /// <summary>
        ///  序号
        /// </summary>
        [DataMember(Name = "id")]
        public int id { get; set; }

        /// <summary>
        ///  参数类型
        /// </summary>
        [DataMember(Name = "ParamType")]
        public int ParamType { get; set; }

        /// <summary>
        ///  界面显示标签
        /// </summary>
        [DataMember(Name = "ParamText")]
        public string ParamText { get; set; }

        /// <summary>
        ///  参数名称
        /// </summary>
        [DataMember(Name = "ParamName")]
        public string ParamName { get; set; }

        /// <summary>
        ///  参数值
        /// </summary>
        [DataMember(Name = "ParamValue")]
        public string ParamValue { get; set; }

        /// <summary>
        ///  值类型
        /// </summary>
        [DataMember(Name = "ValType")]
        public string ValType { get; set; }

        /// <summary>
        ///  参数备注信息
        /// </summary>
        [DataMember(Name = "Remark")]
        public string Remark { get; set; }

    }
}
