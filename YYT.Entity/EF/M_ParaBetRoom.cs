using Newtonsoft.Json;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    /// <summary>
    /// 押分类房间参数设定表
    /// </summary>
    [Table("ParaBetRoom")]
    public class M_ParaBetRoom
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
        /// 押分时间（倒计时）
        /// </summary>
        public int BET_TIME { get; set; }
        
        /// <summary>
        /// 房间桌台数目
        /// </summary>
        public int NUM { get; set; }
        
        /// <summary>
        /// 押分限红
        /// </summary>
        public int BET_MAX { get; set; }
        
        /// <summary>
        /// 起押值
        /// </summary>
        public int BET_MIN { get; set; }
        
        /// <summary>
        /// 庄闲限红
        /// </summary>
        public int BET_MAX_VICE { get; set; }
        
        /// <summary>
        /// 庄闲起押值
        /// </summary>
        public int BET_MIN_VICE { get; set; }
        
        /// <summary>
        /// 和限红
        /// </summary>
        public int BET_MAX_DRAW { get; set; }
        
        /// <summary>
        /// 和起押值
        /// </summary>
        public int BET_MIN_DRAW { get; set; }
        
        /// <summary>
        /// 一次取几币
        /// </summary>
        public int EX_COIN { get; set; }
        
        /// <summary>
        /// 一个币兑换几分
        /// </summary>
        public int COIN_SC { get; set; }
        
        /// <summary>
        /// 需要多少币才能进入该房间
        /// </summary>
        public int COIN_NEED { get; set; }
        
        /// <summary>
        /// 需要多少分数才能做庄
        /// </summary>
        public int BANKER_SC_NEED { get; set; }
        
        /// <summary>
        /// 单门限红
        /// </summary>
        public int SC_LIMIT_SING { get; set; }
        
        /// <summary>
        /// 全局限红
        /// </summary>
        public int SC_LIMIT_ALL { get; set; }
        
        /// <summary>
        /// 兑换金币数
        /// </summary>
        public int Game_Mo { get; set; }

        /// <summary>
        /// 投注档位配置（逗号分隔）
        /// 第0位：默认投注金额（不点快捷按钮时的投注金币）
        /// 第1-N位：快捷投注按钮
        /// 例如："1,5,10,15,20" 表示默认1，快捷按钮为5,10,15,20
        /// </summary>
        [StringLength(200)]
        public string BetScores { get; set; }

        /// <summary>
        /// 默认档位索引（固定为0，表示使用第0位作为默认投注金额）
        /// </summary>
        public int? DefaultBetIndex { get; set; }

        public string TableName { get; set; }

        public int MaxSeats { get; set; } = 6;

        public int IdleFireTimeoutSec { get; set; }

        public bool IdleFireKickEnabled { get; set; }

        public bool Enabled { get; set; } = true;

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}
