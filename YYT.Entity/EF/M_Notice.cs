using Newtonsoft.Json;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    /// <summary>
    /// 公告表
    /// </summary>
    [Table("Notice")]
    public class M_Notice
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
        /// 玩家公告（一般告知玩家客服微信等）
        /// </summary>
        [Required]
        [Display(Description = "公告内容", Name = "公告内容"), MaxLength(200, ErrorMessage = "长度不能超过50个字符!")]
        public string NOTICE { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}
