using Newtonsoft.Json;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    /// <summary>
    /// 游戏房间参数设定表
    /// </summary>
    [Table("ParaRoom")]
    public class M_ParaRoom
    {
        /// <summary>
        /// 游戏房间编号
        /// </summary>
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int ID { get; set; }
        /// <summary>
        /// 游戏编号
        /// </summary>
        public int GAME_ID { get; set; }
        /// <summary>
        /// 机台数
        /// </summary>
        public int NUM { get; set; }
        /// <summary>
        /// 最小押分
        /// </summary>
        public int BET_MIN { get; set; }
        /// <summary>
        /// 最大押分
        /// </summary>
        public int BET_MAX { get; set; }
        /// <summary>
        /// 兑换单位
        /// </summary>
        public int EX_COIN { get; set; }
        /// <summary>
        /// 兑换币值
        /// </summary>
        public int COIN_SC { get; set; }
        /// <summary>
        /// 入场金币
        /// </summary>
        public int COIN_NEED { get; set; }
        /// <summary>
        /// 加炮幅度（支持小数0.1-0.9）
        /// </summary>
        public decimal scoreSwitch { get; set; }
        /// <summary>
        /// 最小押分值限制
        /// </summary>
        public int BetMinValLimit { get; set; }
        /// <summary>
        /// 最大押分值限制
        /// </summary>
        public int BetMaxValLimit { get; set; }
        /// <summary>
        /// 兑换金币数
        /// </summary>
        public int Game_Mo { get; set; }

        public string TableName { get; set; }

        public int MaxSeats { get; set; } = 6;

        public int IdleFireTimeoutSec { get; set; }

        public bool IdleFireKickEnabled { get; set; }

        public bool Enabled { get; set; } = true;

        public int MinBetUnits { get; set; }

        public int MaxBetUnits { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}
