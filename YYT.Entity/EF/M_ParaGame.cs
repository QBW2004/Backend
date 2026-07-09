using Newtonsoft.Json;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    /// <summary>
    /// 
    /// </summary>
    [Table("ParaGame")]
    public class M_ParaGame
    {
        public int ID { get; set; }
        public int ROOM_MAX { get; set; }
        public int PLY_MAX { get; set; }
        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}
