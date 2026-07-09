using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    /// <summary>
    /// 玩家账号标识信息表
    /// </summary>
    [Table("UserRelations")]
    public class M_UserRelations
    {
        /// <summary>
        /// 玩家唯一标识
        /// </summary>
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int UserID { get; set; }
        /// <summary>
        /// 玩家ID
        /// </summary>
        public string ID { get; set; }
    }
}
