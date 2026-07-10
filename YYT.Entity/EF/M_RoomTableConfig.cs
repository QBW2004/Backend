using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    [Table("roomtableconfig")]
    public class M_RoomTableConfig
    {
        [Key]
        public int ID { get; set; }
        public int GAME_ID { get; set; }
        public int RoomIndex { get; set; }
        public int TableIndex { get; set; }
        public string TableName { get; set; }
        public int MaxSeats { get; set; }
        public int Enabled { get; set; }
        public int OneCoinScore { get; set; }
        public int BetMin { get; set; }
        public int BetMax { get; set; }
        public int CoinsNeed { get; set; }
        public int IdleFireTimeoutSec { get; set; }
        public int IdleFireKickEnabled { get; set; }
    }
}
