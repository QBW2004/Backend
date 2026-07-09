using Newtonsoft.Json;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    public class M_AgencyRecord
    {
        /// <summary>
        /// 代理账号
        /// </summary>
        public string ID { get; set; }
        public string TIME { get; set; }
        public long? RE_EX { get; set; }
        public long? COINS { get; set; }
        public long? BEF_COINS { get; set; }
        public long? AFT_COINS { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }

    public class M_PlayerRecord
    {
        /// <summary>
        /// 玩家账号
        /// </summary>
        public string ID { get; set; }
        /// <summary>
        /// 操作类型
        /// </summary>
        public int? OPT { get; set; }
        public int? OPT_COINS { get; set; }
        public int? COINS { get; set; }
        public int? SCORE { get; set; }
        public int? ROOM { get; set; }
        public int? TABLE_ID { get; set; }
        public int? SEAT_ID { get; set; }
        public int? GAME_TYPE { get; set; }
        public string GAME_NAME { get; set; }
        public string REC_TIME { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }

    public class M_S_Record
    {
        public string ID { get; set; }
        public int OPT { get; set; }
        public string AGENCY { get; set; }
        public DateTime S_TIME { get; set; }
        public DateTime E_TIME { get; set; }
        public int WEEK { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }


    /// <summary>
    /// 代理日志
    /// </summary>
    [Table("AgencyOptLog")]
    public class M_AgencyOptLog
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long LID { get; set; }
        /// <summary>
        /// 操作人账号
        /// </summary>
        public string OptID { get; set; }
        /// <summary>
        /// 操作人账号类型
        /// </summary>
        public string SrcUserTitle { get; set; }
        /// <summary>
        /// 被操作账号
        /// </summary>
        public string ID { get; set; }
        /// <summary>
        /// 被操作人账号类型
        /// </summary>
        public string DestUserTitle { get; set; }
        /// <summary>
        /// 代理账号
        /// </summary>
        [NotMapped]
        public string AGENCY { get; set; }
        /// <summary>
        /// 日志时间
        /// </summary>
        public DateTime REC_TIME { get; set; }
        [NotMapped]
        public string REC_TIME_Str { get { return REC_TIME.ToString("yyyy-MM-dd HH:mm:ss"); } }
        /// <summary>
        /// 操作类型  如：0 充值  1兑换  2登录  3退出
        /// </summary>
        public int? OPT { get; set; }
        /// <summary>
        /// 操作金币量
        /// </summary>
        public long? COINS { get; set; }
        /// <summary>
        /// 操作前金币量
        /// </summary>
        public long? BEF_COINS { get; set; }
        /// <summary>
        /// 操作后金币量
        /// </summary>
        public long? AFT_COINS { get; set; }
        /// <summary>
        /// 周数
        /// </summary>
        public int WEEK { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }

    /// <summary>
    /// 用户日志
    /// </summary>
    [Table("UserOptLog")]
    public class M_UserOptLog
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long LID { get; set; }
        public string UserID { get; set; }
        /// <summary>
        /// 父级
        /// </summary>
        [NotMapped]
        public string AGENCY { get; set; }
        public int OPT { get; set; }
        public long OPT_COINS { get; set; }
        public long COINS { get; set; }
        public long SCORE { get; set; }
        public long ROOM { get; set; }
        public long TABLE_ID { get; set; }
        public long SEAT_ID { get; set; }
        public int GAME_TYPE { get; set; }
        [NotMapped]
        public string GameName { get; set; }
        public DateTime REC_TIME { get; set; }
        [NotMapped]
        public string REC_TIME_Str { get { return REC_TIME.ToString("yyyy-MM-dd HH:mm:ss"); } }
        public int REC_WEEK { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}
