using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    /// <summary>
    /// 保险柜存入取出记录
    /// </summary>
    [Table("safe_coins_log")]
    public class M_SafeCoinsLog
    {

        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long ID { get; set; }

        public string User_Id { get; set; }
     
        public int? type { get; set; }
      
        public long? coins { get; set; }
        public DateTime Create_Time { get; set; }

        public long? new_Coins { get; set; }

        public long? safe_Coins { get; set; }


        /// <summary>
        /// 时间
        /// </summary>
        [NotMapped]
        public string CreateTimeStr { get { return this.Create_Time.ToString("yyyy-MM-dd HH:mm:ss"); } set { CreateTimeStr = value; } }
        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }

   
}
