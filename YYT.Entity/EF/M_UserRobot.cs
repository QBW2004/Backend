using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    /// <summary>
    /// 机器人设置
    /// </summary>
    [Table("userrobot")]
    public class M_UserRobot
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long ID { get; set; }
        /// <summary>
        /// 机器人账户
        /// </summary>
        public string UserName { get; set; }
        /// <summary>
        /// 机器人妮称
        /// </summary>
        public string UserNick { get; set; }
        /// <summary>
        ///  密码
        /// </summary>
        public string PassW { get; set; }
        /// <summary>
        /// 头像编号
        /// </summary>
        public int Ico { get; set; }
        /// <summary>
        /// 等级
        /// </summary>
        public int Lev { get; set; }
        /// <summary>
        /// 性别
        /// </summary>
        public int Sex { get; set; }
        /// <summary>
        /// 金币
        /// </summary>
        public int Gold { get; set; }
        /// <summary>
        /// 2是1否是机器人
        /// </summary>
        public int IsRobot { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }

   
}
