using System.Collections.Generic;
using YYT.Common;
using YYT.Entity;

namespace YYT.Web.Models
{
    public class V_BetAcc : IVGameAcc
    {
        private byte[] Bytes;
        public V_BetAcc(byte[] bytes)
        {
            this.Bytes = bytes;
        }
        public object GetAcc()
        {
            st_BetAcc st_BetAcc = Bytes.BytesToStuct(typeof(st_BetAcc));

            M_BetAcc betAcc = new M_BetAcc();
            betAcc.Head = st_BetAcc.HeadBytes.SwapUInt16();

            List<M_FishBetAccBody> list = new List<M_FishBetAccBody>();
            st_FishBetAccBody st_FishBetAccBody;
            M_FishBetAccBody fishBetAccBody;

            for (int i = 0; i < 2; i++)
            {
                st_FishBetAccBody = st_BetAcc.Body[i];

                fishBetAccBody = new M_FishBetAccBody();
                fishBetAccBody.Small_In = st_FishBetAccBody.Small_In.SwapInt64();
                fishBetAccBody.Small_Out = st_FishBetAccBody.Small_Out.SwapInt64();
                fishBetAccBody.Medium_In = st_FishBetAccBody.Medium_In.SwapInt64();
                fishBetAccBody.Medium_Out = st_FishBetAccBody.Medium_Out.SwapInt64();
                fishBetAccBody.Large_In = st_FishBetAccBody.Large_In.SwapInt64();
                fishBetAccBody.Large_Out = st_FishBetAccBody.Large_Out.SwapInt64();

                list.Add(fishBetAccBody);
            }
            betAcc.Body = list;

            return betAcc;
        }
    }
}