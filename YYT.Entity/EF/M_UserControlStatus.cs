using Newtonsoft.Json;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    /// <summary>
    /// 玩家控制有限状态机表（鱼机和玩家控制）
    /// </summary>
    [Table("usercontrolstatus")]
    public class M_UserControlStatus
    {
        /// <summary>
        /// 唯一自增主键
        /// </summary>
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int ID { get; set; }
        /// <summary>
        /// 被控玩家账号ID（"*" 表示进入该鱼机的所有玩家）
        /// </summary>
        public string UserID { get; set; }
        /// <summary>
        /// 游戏类型枚举（1鱼机/2注机/3牌机/4押注类）
        /// </summary>
        public int GameType { get; set; }
        /// <summary>
        /// 针对的具体游戏（0 表示全部鱼机）
        /// </summary>
        public int GameId { get; set; }
        /// <summary>
        /// 1=Kill(点杀), 2=Release(放水), 3=Limit(金币上限)
        /// </summary>
        public int ControlMode { get; set; }
        /// <summary>
        /// 目标吸/放金币总数
        /// </summary>
        public long TargetCoins { get; set; }
        /// <summary>
        /// 已吃/已消耗金币数
        /// </summary>
        public long ConsumedCoins { get; set; }
        /// <summary>
        /// 已放/已赠予金币数
        /// </summary>
        public long GrantedCoins { get; set; }
        /// <summary>
        /// 金币上限阈值
        /// </summary>
        public long LimitCoins { get; set; }
        /// <summary>
        /// 点杀/放水时的单局胜率/抽水控制系数(如60代表6/4开)
        /// </summary>
        public int KillRatio { get; set; }
        /// <summary>
        /// 0=Active(执行中), 1=Expired(过期/手动关闭), 2=Completed(达成)
        /// </summary>
        public int Status { get; set; }
        /// <summary>
        /// 建立此控制的操作人账号
        /// </summary>
        public string CreatedBy { get; set; }
        /// <summary>
        /// 控制起始时间
        /// </summary>
        public DateTime CreatedTime { get; set; }
        /// <summary>
        /// 预设的失效时间
        /// </summary>
        public DateTime? ExpiredTime { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }

    /// <summary>
    /// 控制模式枚举
    /// </summary>
    public enum EControlMode
    {
        /// <summary>
        /// 点杀（慢慢吃分）
        /// </summary>
        Kill = 1,
        /// <summary>
        /// 放水（慢慢出分）
        /// </summary>
        Release = 2,
        /// <summary>
        /// 金币上限（超出部分逐步消耗）
        /// </summary>
        Limit = 3
    }

    /// <summary>
    /// 控制状态枚举
    /// </summary>
    public enum EControlStatus
    {
        /// <summary>
        /// 执行中
        /// </summary>
        Active = 0,
        /// <summary>
        /// 过期/手动关闭
        /// </summary>
        Expired = 1,
        /// <summary>
        /// 达成
        /// </summary>
        Completed = 2
    }

    /// <summary>
    /// 控制记录列表 DTO
    /// </summary>
    public class M_UserControlStatus_DTO
    {
        public int ID { get; set; }
        public string UserID { get; set; }
        public int GameType { get; set; }
        public int GameId { get; set; }
        public string GameName { get; set; }
        public int ControlMode { get; set; }
        public long TargetCoins { get; set; }
        public long ConsumedCoins { get; set; }
        public long GrantedCoins { get; set; }
        public long LimitCoins { get; set; }
        public int Status { get; set; }
        public string CreatedBy { get; set; }
        /// <summary>
        /// 设置时间（已格式化）
        /// </summary>
        public string CreatedTime { get; set; }
        /// <summary>
        /// 所属代理（精确到用户时填充）
        /// </summary>
        public string AGENCY { get; set; }
    }
}
