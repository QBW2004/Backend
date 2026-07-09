using Newtonsoft.Json;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    [Table("UserLockRecord")]
    public class M_UserLockRecord
    {
        [Key]
        public int RecIndex { get; set; }
        /// <summary>
        /// 充值、兑换后台的操作结果
        /// </summary>
        public int OptResult { get; set; }
        public int RechargeType { get; set; }
        public string ID { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}
