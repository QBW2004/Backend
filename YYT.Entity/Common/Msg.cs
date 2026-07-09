using System.ComponentModel;
using System.Runtime.Serialization;

namespace YYT.Entity
{
    [DataContract]
    public class Msg
    {
        public Msg() : this(10001, "操作失败") { }
        /// <summary>
        /// 系统消息
        /// </summary>
        /// <param name="_code">消息代码</param>
        /// <param name="_content">消息内容</param>
        public Msg(int _code, string _content)
        {
            this.code = _code;
            this.content = _content;
        }

        /// <summary>
        /// 操作结果代码 
        /// <para>0 表示操作失败</para>
        /// <para>1 表示操作成功</para>
        /// </summary>
        [DefaultValue(0)]
        [DataMember(Name = "code")]
        public int code { get; set; }

        /// <summary>
        /// 结果消息
        /// </summary>
        [DataMember(Name = "content")]
        public string content { get; set; }

        /// <summary>
        /// 附加信息
        /// </summary>
        [DataMember(Name = "datas")]
        public dynamic datas { get; set; }
        /// <summary>
        /// 序列化成JSON字符串
        /// </summary>
        /// <returns></returns>
        public string ToJsonString()
        {
            return Newtonsoft.Json.JsonConvert.SerializeObject(this);
        }
    }
}
