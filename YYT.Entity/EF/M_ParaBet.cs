using Newtonsoft.Json;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    /// <summary>
    /// 押分类参数表
    /// </summary>
    [Table("ParaBet")]
    public class M_ParaBet
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
        /// 系统难度
        /// </summary>
        [Display(Name = "系统难度", Description = "系统难度")]
        [RegularExpression("^\\d+$", ErrorMessage = "只能是数字")]
        [Range(0, 9, ErrorMessage = "值范围只能是0~9")]
        public int DIF { get; set; }
        /// <summary>
        /// 系统加难
        /// </summary>
        [Display(Name = "系统加难", Description = "系统加难")]
        [RegularExpression("^\\d+$", ErrorMessage = "只能是数字")]
        [Range(0, 9, ErrorMessage = "值范围只能是0~9")]
        public int HAR { get; set; }
        /// <summary>
        /// 系统起伏
        /// </summary>
        [Display(Name = "系统起伏", Description = "系统起伏")]
        [RegularExpression("^\\d+$", ErrorMessage = "只能是数字")]
        [Range(0, 2, ErrorMessage = "值范围只能是0~2")]
        public int SITE_TYPE { get; set; }
        /// <summary>
        /// 庄家难度
        /// </summary>
        [Display(Name = "庄家难度", Description = "庄家难度")]
        [RegularExpression("^\\d+$", ErrorMessage = "只能是数字")]
        [Range(0, 9, ErrorMessage = "值范围只能是0~9")]
        public int BANKER_DIF { get; set; }
        /// <summary>
        /// 庄家加难档位
        /// </summary>
        [Display(Name = "庄家加难档位", Description = "庄家加难档位")]
        [RegularExpression("^\\d+$", ErrorMessage = "只能是数字")]
        [Range(0, 9, ErrorMessage = "值范围只能是0~9")]
        public int BANKER_HAR { get; set; }
        /// <summary>
        /// 庄家场起伏
        /// </summary>
        [Display(Name = "庄家场起伏", Description = "庄家场起伏")]
        [RegularExpression("^\\d+$", ErrorMessage = "只能是数字")]
        [Range(0, 2, ErrorMessage = "值范围只能是0~2")]
        public int BANKER_SITE_TYPE { get; set; }
        /// <summary>
        /// 庄家抽水
        /// </summary>
        [Display(Name = "庄家抽水", Description = "庄家抽水")]
        [RegularExpression("^\\d+$", ErrorMessage = "只能是数字")]
        [Range(0, 99, ErrorMessage = "值范围只能是0~99")]
        public int BANKER_PER { get; set; }
        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}
