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
    [Table("AccountLog")]
    public class M_AccountLog
    {
     
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long ID { get; set; }
 
        public string UserName { get; set; }
     
        public DateTime CreateTime { get; set; }
        public string PlayGame { get; set; }

        public string IP { get; set; }
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
