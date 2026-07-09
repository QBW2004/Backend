namespace YYT.Entity
{
    public class M_FishBetAccBody
    {
        public long Small_In { get; set; }
        public long Small_Out { get; set; }
        public double Small_Per { get { return Small_In > 0 ? ((double)Small_Out / (double)Small_In * 100.0) : 0; } }

        public long Medium_In { get; set; }
        public long Medium_Out { get; set; }
        public double Medium_Per { get { return Medium_In > 0 ? ((double)Medium_Out / (double)Medium_In * 100.0) : 0; } }

        public long Large_In { get; set; }
        public long Large_Out { get; set; }
        public double Large_Per { get { return Large_In > 0 ? ((double)Large_Out / (double)Large_In * 100.0) : 0; } }

        public long Total_In { get { return Small_In + Medium_In + Large_In; } }
        public long Total_Out { get { return Small_Out + Medium_Out + Large_Out; } }
        public double Total_Per { get { return Total_In > 0 ? ((double)Total_Out / (double)Total_In * 100.0) : 0; } }
    }
}
