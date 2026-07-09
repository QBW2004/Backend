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
    [Table("TransferLog")]
    public class M_TransferLog
    {

        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long ID { get; set; }

        public string UserName { get; set; }
     
        public int? Status { get; set; }
      
        public string ClientTransferId { get; set; }
        public long? Money { get; set; }
        public DateTime CreateTime { get; set; }

        public string Remark { get; set; }

        public string PlatType { get; set; }

        public string Type { get; set; }

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
