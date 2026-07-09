using Newtonsoft.Json;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    [Table("LoginMissRecord")]
    public class M_LoginMissRecord
    {
        /// <summary>
        /// 标识ID
        /// </summary>
        [Key]
        public int LMID { get; set; }
        /// <summary>
        /// 登录人账号
        /// </summary>
        public string ID { get; set; }
        /// <summary>
        /// 登录失败次数
        /// </summary>
        public int MissCount { get; set; }
        /// <summary>
        /// 登录结果
        /// <para>0 失败</para>
        /// <para>1 成功</para>
        /// </summary>
        public int LoginResult { get; set; }
        /// <summary>
        /// 登录人IP地址
        /// </summary>
        public string IPAddr { get; set; }
        /// <summary>
        /// 登录时间
        /// </summary>
        public DateTime LoginTime { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}
