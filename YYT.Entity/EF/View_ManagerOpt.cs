using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    [Table("V_ManagerOptWithUsers")]
    public class View_ManagerOpt
    {
        [Key]
        public string UserID { get; set; }
        public string NAME { get; set; }
        public int Opt { get; set; }
        public int OptValue { get; set; }
        public string Type { get; set; }
        public string TIME { get; set; }
        public string AGENCY { get; set; }
    }
    public class View_ManagerOpt_DTO
    {
        public string UserID { get; set; }
        public string NAME { get; set; }
        public int Opt { get; set; }
        public int OptValue { get; set; }
        public string Type { get; set; }
        public string TIME { get; set; }
        public string AGENCY { get; set; }
    }
}
