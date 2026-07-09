using Newtonsoft.Json;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    /// <summary>
    /// 游戏更新表
    /// </summary>
    [Table("UpdateAddr")]
    public class M_UpdateAddr
    {
        /// <summary>
        /// ID编号
        /// </summary>
        [Key]
        [Required]
        [Display(Name = "类型ID", Description = "类型ID")]
        [Range(1, 3)]
        public int ID { get; set; }

        public int V0 { get; set; }
        public string G0 { get; set; }

        public int V1 { get; set; }
        public string G1 { get; set; }

        public int V2 { get; set; }
        public string G2 { get; set; }

        public int V3 { get; set; }
        public string G3 { get; set; }

        public int V4 { get; set; }
        public string G4 { get; set; }

        public int V5 { get; set; }
        public string G5 { get; set; }

        public int V6 { get; set; }
        public string G6 { get; set; }

        public int V7 { get; set; }
        public string G7 { get; set; }

        public int V8 { get; set; }
        public string G8 { get; set; }

        public int V9 { get; set; }
        public string G9 { get; set; }

        public int V10 { get; set; }
        public string G10 { get; set; }

        public int V11 { get; set; }
        public string G11 { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }

    public class M_UpdateInfo
    {
        public string GameTag { get; set; }
        public int? Ver { get; set; }
        public string PackageUrl { get; set; }
    }
}
