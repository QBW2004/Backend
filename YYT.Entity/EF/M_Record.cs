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
        /// <summary>
        /// 只查资金变动记录（手机端「代理流水」用）：过滤掉登录/退出(OPT 2/3)与封禁审计(OPT 24-27)等无金额记录。
        /// 桌面「代理记录」需要展示这些记录，所以默认 false。
        /// </summary>
        public bool MONEY_ONLY { get; set; }

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

        /// <summary>
        /// 被操作账号（ID）是否玩家：手机端流水页据此显示“玩 账号”并跳玩家详情，
        /// 否则为“代 账号”并弹出代理详情。账号在 users / admin 两表间不重复，由服务端判定。
        /// </summary>
        [NotMapped]
        public bool DestIsPlayer { get; set; }

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

        /// <summary>
        /// 进入桌台前总余额（后台按同一用户/游戏/桌台的前一条进入记录配对补充，仅离开记录有效）
        /// </summary>
        [NotMapped]
        public long EnterCoins { get; set; }
        /// <summary>
        /// 离开桌台后总余额（仅离开记录有效）
        /// </summary>
        [NotMapped]
        public long LeaveCoins { get; set; }
        /// <summary>
        /// 本次盈亏 = 进入 - 离开（玩家亏钱为正，赢钱为负）
        /// </summary>
        [NotMapped]
        public long SessionProfit { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }

    /// <summary>高倍率中奖播报记录。</summary>
    [Table("gameprizerecord")]
    public class M_GamePrizeRecord
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long ID { get; set; }
        [Required, StringLength(64)]
        public string EventId { get; set; }
        [Required, StringLength(50)]
        public string UserID { get; set; }
        public int GameId { get; set; }
        public int GameType { get; set; }
        public long RoomId { get; set; }
        public long TableId { get; set; }
        public string CardType { get; set; }
        public decimal Multiplier { get; set; }
        public long Score { get; set; }
        public int IsManualControl { get; set; }
        public int IsBroadcast { get; set; }
        public DateTime RecTime { get; set; }

        [NotMapped]
        public string GameName { get; set; }

        /// <summary>
        /// 机台显示名（手机端中奖历史「机台号」列）：优先 roomtableconfig.TableName
        ///（运营在桌台配置里给机台起的名字，与拉霸客户端选桌大厅一致），无配置回退 "N号机"。
        /// </summary>
        [NotMapped]
        public string TableLabel { get; set; }
    }
}
