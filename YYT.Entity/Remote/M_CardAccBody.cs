using System.Linq;

namespace YYT.Entity
{
    public class M_CardAccBody
    {
        public int PlayRound { get; set; }
        public int WinRound { get { return CardTypeDatas.Skip(1).Sum(); } }
        public double Prize_Per { get { return PlayRound > 0 ? ((double)WinRound / (double)PlayRound * 100.0) : 0; } }

        public long Pok_In { get; set; }
        public long Pok_Out { get; set; }
        public double Pok_Per { get { return Pok_In > 0 ? ((double)Pok_Out / (double)Pok_In * 100.0) : 0; } }

        public int[] CardTypeDatas { get; set; }

        public long Dou_In { get; set; }
        public long Dou_Out { get; set; }
        public double Dou_Per { get { return Dou_In > 0 ? ((double)Dou_Out / (double)Dou_In * 100.0) : 0; } }
    }
}
