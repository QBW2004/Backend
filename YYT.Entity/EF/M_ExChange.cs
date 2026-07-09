using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    /// <summary>
    /// 兑换记录表
    /// </summary>
    [Table("ex_change")]
    public class M_ExChange
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long ID { get; set; }
        /// <summary>
        /// 玩家id
        /// </summary>
        public string PLAYER_ID { get; set; }
        /// <summary>
        /// 兑换金币数量
        /// </summary>
        public long? COINS { get; set; }

        /// <summary>
        /// 状态，默认0未处理，1已处理，2已拒绝
        /// </summary>
        public long? STATUS { get; set; }
        /// <summary>
        /// 手机号码
        /// </summary>
        public string PHONE_NUMBER { get; set; }
        /// <summary>
        /// 游戏密码
        /// </summary>
        public string PWD { get; set; }
        /// <summary>
        /// 所属代理
        /// </summary>
        public string AGENCY { get; set; }
        /// <summary>
        ///创建时间
        /// </summary>
        public DateTime CREATE_TIME { get; set; }
        /// <summary>
        /// 时间
        /// </summary>
        [NotMapped]
        public string CreateTimeStr { get { return this.CREATE_TIME.ToString("yyyy-MM-dd HH:mm:ss"); } set { CreateTimeStr = value; } }

      
        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }

   
}
