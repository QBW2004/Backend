using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    [Table("gameconfiglaba")]
    public class M_GameConfigLaba
    {
        [Key, Column(Order = 1)]
        public int GameId { get; set; }

        [Key, Column(Order = 2)]
        public int TableIndex { get; set; }

        [Key, Column(Order = 3)]
        public string OptKey { get; set; }

        public int OptValue { get; set; }

        public string @Type { get; set; }

        public DateTime TIME { get; set; }
        public string TIME_Str { get { return TIME != null ? TIME.ToString("yyyy-MM-dd HH:mm:ss") : string.Empty; } }
    }
}
