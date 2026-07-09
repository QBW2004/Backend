using Newtonsoft.Json;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    /// <summary>
    /// 活动表
    /// </summary>
    [Table("Activity")]
    public class M_Activity
    {
        /// <summary>
        /// ID
        /// </summary>
        public int ID { get; set; }

        /// <summary>
        /// 标题
        /// </summary>
        public string TITLE { get; set; }
        /// <summary>
        /// 活动内容
        /// </summary>
        [Required]
        [Display(Description = "活动内容", Name = "活动内容"), MaxLength(200, ErrorMessage = "长度不能超过50个字符!")]
        public string Activity { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}
