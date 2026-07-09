using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    [Table("gameacclaba")]
    public class M_GameAccLaba
    {
        [Key]
        public int GameId { get; set; }
        public int Stock { get; set; }
        public int MiniJackpot { get; set; }
        public int MidJackpot { get; set; }
        public int LargeJackpot { get; set; }
    }

    
}
