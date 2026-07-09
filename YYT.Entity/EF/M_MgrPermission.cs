using Newtonsoft.Json;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    [Table("MgrPermission")]
    public class M_MgrPermission
    {
        public string PID { get; set; }
        public string ID { get; set; }
        public int PermissionID { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}
