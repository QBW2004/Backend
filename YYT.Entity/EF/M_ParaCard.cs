using Newtonsoft.Json;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    /// <summary>
    /// 牌机类参数设定表
    /// </summary>
    [Table("ParaCard")]
    public class M_ParaCard
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
        /// 牌机难度
        /// </summary>
        [Display(Name = "牌机难度", Description = "牌机难度")]
        [RegularExpression("\\d{16}", ErrorMessage = "长度必须为16位数字！")]
        public string DIF { get; set; }
        /// <summary>
        /// 炒场类型
        /// </summary>
        public int HYPE_TYPE { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}
