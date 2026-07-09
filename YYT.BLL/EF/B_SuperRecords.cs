using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using YYT.Common;
using YYT.Entity;

namespace YYT.BLL.EF
{
    public abstract class B_SuperRecords
    {
        public EDbProviderType DBType { get; set; }

        public B_SuperRecords(EDbProviderType dBType)
        {
            this.DBType = dBType;
        }


        public abstract dynamic Get_PlayerRecords(M_LoginUser loginUser, M_Page mPage, dynamic queryEntity);

        public abstract dynamic Get_AgencyRecords(M_LoginUser loginUser, M_Page mPage, dynamic queryEntity);
    }
}
