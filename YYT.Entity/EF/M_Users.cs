using Newtonsoft.Json;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    /// <summary>
    /// 用户（玩家）表
    /// </summary>
    [Table("Users")]
    public class M_Users
    {
        [Key]
        [Display(Name = "账号", Description = "账号")]
        [Required]
        [MinLength(6, ErrorMessage = "长度不能小于6个字符")]
        [MaxLength(50, ErrorMessage = "长度不能超过50个字符")]
        [RegularExpression("^[\u4e00-\u9fa5_a-zA-Z0-9]+$", ErrorMessage = "只能输入中文、英文字母、数字")]
        public string ID { get; set; }
        [Display(Name = "昵称", Description = "昵称")]
        [Required]
        [MinLength(1, ErrorMessage = "长度不能小于1个字符")]
        [MaxLength(50, ErrorMessage = "长度不能超过50个字符")]
        //[RegularExpression("^[\u4e00-\u9fa5_a-zA-Z0-9]+$", ErrorMessage = "只能输入中文、英文字母、数字")]
        public string NAME { get; set; }
        [Display(Name = "密码", Description = "密码")]
        [MinLength(6, ErrorMessage = "长度不能小于6个字符")]
        [MaxLength(50, ErrorMessage = "长度不能超过50个字符")]
        [RegularExpression("^[a-zA-Z0-9]+$", ErrorMessage = "只能输入英文字母、数字")]
        public string PWD { get; set; }
        public string AGENCY { get; set; }

        public int? PIC_INDEX { get; set; }
        public int? FROZEN { get; set; }
        public long? COINS { get; set; }
        public long? COINS_EXP { get; set; }
        public long? COINS_BUY { get; set; }
        public long? COINS_BACK { get; set; }
        public long? BMW_SCORE { get; set; }
        public long? DICE_SCORE { get; set; }
        public long? DT_SCORE { get; set; }
        public long? PHENIX_SCORE { get; set; }
        public long? JC_SCORE { get; set; }
        public long? MAGNATE_SCORE { get; set; }
        public long? FISH_COW_SCORE { get; set; }
        public long? FISH_CROCODILE_SCORE { get; set; }
        public long? CARD_ATT2_SCORE { get; set; }
        public long? CARD_FISH_SCORE { get; set; }
        public long? BET_ANIMAL_SCORE { get; set; }
        public long? FISH_BIRD_SCORE { get; set; }
        public long? BET_COW_SCORE { get; set; }
        public string TELEPHONE { get; set; }
        public bool INHALL { get; set; }

        public bool IsRegister { get; set; }
        public long? GAME_SCORE { get; set; }

        public string SAFE_PWD { get; set; }

        public long? SAFE_COINS { get; set; }
        public int? GRADE { get; set; }
        /// <summary>
        /// 玩家盈利
        /// </summary>
        [NotMapped]
        public long? Profit { get; set; }
        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }

    /// <summary>
    /// ID 类型
    /// </summary>
    public enum EIDType
    {
        /// <summary>
        /// 账号
        /// </summary>
        Account,
        /// <summary>
        /// 用户ID【平台唯一标识】
        /// </summary>
        UserID
    }
    public class RankUsersList
    {
        public string ID { get; set; }
        public string NAME { get; set; }
     
        public long? COINS { get; set; }
     
        public long? PIC_INDEX { get; set; }
      
    }
    public class M_Users_DTO
    {
        public int UserID { get; set; }
        public string ID { get; set; }
        public string NAME { get; set; }
        public string PWD { get; set; }
        public string AGENCY { get; set; }
        public int? PIC_INDEX { get; set; }
        public int? FROZEN { get; set; }
        public long? COINS { get; set; }
        public long? COINS_EXP { get; set; }
        public long? COINS_BUY { get; set; }
        public long? COINS_BACK { get; set; }
        public long? BMW_SCORE { get; set; }
        public long? DICE_SCORE { get; set; }
        public long? DT_SCORE { get; set; }
        public long? PHENIX_SCORE { get; set; }
        public long? JC_SCORE { get; set; }
        public long? MAGNATE_SCORE { get; set; }
        public long? FISH_COW_SCORE { get; set; }
        public long? FISH_CROCODILE_SCORE { get; set; }
        public long? CARD_ATT2_SCORE { get; set; }
        public long? CARD_FISH_SCORE { get; set; }
        public long? BET_ANIMAL_SCORE { get; set; }
        public long? FISH_BIRD_SCORE { get; set; }
        public long? BET_COW_SCORE { get; set; }
        public string TELEPHONE { get; set; }
        public bool INHALL { get; set; }
        public bool IsRegister { get; set; }
        public long? GAME_SCORE { get; set; }
        public string SAFE_PWD { get; set; }

        public long? SAFE_COINS { get; set; }

        public int? GRADE { get; set; }
        public string CurrentGameName { get; set; }
        public int? CurrentGameType { get; set; }
        public long? CurrentRoomId { get; set; }
        public long? CurrentTableId { get; set; }
        public long? CurrentSeatId { get; set; }
        public long? CurrentBetCoins { get; set; }
        public long? CurrentWinLose { get; set; }
        /// <summary>
        /// 玩家盈利
        /// </summary>
        [NotMapped]
        public long? Profit { get; set; }
        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }

    public class UserDailyAccounts
    {
        public int UserID { get; set; }
        public string ID { get; set; }
        public string NAME { get; set; }
        public string AGENCY { get; set; }
        public long? COIN { get; set; }

        public int PROCESSED { get; set; }
        /// <summary>
        /// 后台充值、后台赠送、前端充值;后台兑换、后台扣币、前端提现   
        /// </summary>
        public int RECHARGE_TYPE { get; set; }
        public DateTime GAMETIME { get; set; }
        /// <summary>
        /// 上
        /// </summary>
        public long? UPPER { get; set; }
        /// <summary>
        /// 下
        /// </summary>
        public long? BELOW { get; set; }
        /// <summary>
        /// 盈利
        /// </summary>
        public long? PROFIT { get; set; }
        /// <summary>
        /// 时间
        /// </summary>
        public string GAMETIME_STR { get; set; }



        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}
