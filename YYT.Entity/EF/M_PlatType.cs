using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    /// <summary>
    /// 视讯平台信息
    /// </summary>
    [Table("PlatType")]
    public class M_PlatType
    {
        /// <summary>
        /// 游戏标识ID
        /// </summary>
        [Key]
        public int ID { get; set; }
        /// <summary>
        /// 游戏名称
        /// </summary>
        public string Name { get; set; }
        /// <summary>
        /// 是否启用
        /// <para>0 禁用</para>
        /// <para>1 启用</para>
        /// </summary>
        public bool Enable { get; set; }
      
        public string Type { get; set; }

        public DateTime CreateTime { get; set; }
        /// <summary>
        /// 时间
        /// </summary>
        [NotMapped]
        public string CreateTimeStr { get { return this.CreateTime.ToString("yyyy-MM-dd HH:mm:ss"); } set { CreateTimeStr = value; } }
        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }

   
}
