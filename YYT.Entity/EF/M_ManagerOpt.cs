using Newtonsoft.Json;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    [Table("ManagerOpt")]
    public class M_ManagerOpt
    {
        [Key]
        public string UserID { get; set; }
        public string NAME { get; set; }
        public int Opt { get; set; }
        public int OptValue { get; set; }
        public string Type { get; set; }
        public string TIME { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}
