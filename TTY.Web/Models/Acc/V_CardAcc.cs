using System.Collections.Generic;
using System.Linq;
using YYT.Common;
using YYT.Entity;

namespace YYT.Web.Models
{
    public class V_CardAcc : IVGameAcc
    {
        private byte[] Bytes;
        public V_CardAcc(byte[] bytes)
        {
            this.Bytes = bytes;
        }
        public object GetAcc()
        {
            st_CardAcc st_CardAcc = Bytes.BytesToStuct(typeof(st_CardAcc));

            M_CardAcc cardAcc = new M_CardAcc();
            cardAcc.Head = st_CardAcc.HeadBytes.SwapUInt16();

            List<M_CardAccBody> list = new List<M_CardAccBody>();
            for (int i = 0; i < 2; i++)
            {
                st_CardAccBody st_CardAccBody = st_CardAcc.Body[i];

                M_CardAccBody cardAccBody = new M_CardAccBody();
                cardAccBody.PlayRound = st_CardAccBody.PlayRound.SwapInt32();
                cardAccBody.Pok_In = st_CardAccBody.Pok_In.SwapInt64();
                cardAccBody.Pok_Out = st_CardAccBody.Pok_Out.SwapInt64();
                cardAccBody.CardTypeDatas = st_CardAccBody.CardTypeDatas.Select(f => f.CardTypeData.SwapInt32()).ToArray();
                cardAccBody.Dou_In = st_CardAccBody.Dou_In.SwapInt64();
                cardAccBody.Dou_Out = st_CardAccBody.Dou_Out.SwapInt64();

                list.Add(cardAccBody);
            }
            cardAcc.Body = list;

            return cardAcc;
        }
    }
}