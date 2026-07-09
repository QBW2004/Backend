using System.Collections.Generic;
using YYT.Common;
using YYT.Entity;

namespace YYT.Web.Models
{
    public class V_FishAcc : IVGameAcc
    {
        private byte[] Bytes;
        public V_FishAcc(byte[] bytes)
        {
            this.Bytes = bytes;
        }
        public object GetAcc()
        {
            st_FishAcc st_FishAcc = this.Bytes.BytesToStuct(typeof(st_FishAcc));

            M_FishAcc fishAcc = new M_FishAcc();
            fishAcc.Head = st_FishAcc.HeadBytes.SwapUInt16();

            List<M_FishBetAccBody> list = new List<M_FishBetAccBody>();
            st_FishBetAccBody st_FishBetAccBody = st_FishAcc.Body[0];

            M_FishBetAccBody fishBetAccBody = new M_FishBetAccBody();
            fishBetAccBody.Small_In = st_FishBetAccBody.Small_In.SwapInt64();
            fishBetAccBody.Small_Out = st_FishBetAccBody.Small_Out.SwapInt64();
            fishBetAccBody.Medium_In = st_FishBetAccBody.Medium_In.SwapInt64();
            fishBetAccBody.Medium_Out = st_FishBetAccBody.Medium_Out.SwapInt64();
            fishBetAccBody.Large_In = st_FishBetAccBody.Large_In.SwapInt64();
            fishBetAccBody.Large_Out = st_FishBetAccBody.Large_Out.SwapInt64();

            list.Add(fishBetAccBody);

            fishAcc.Body = list;

            return fishAcc;
        }
    }
}