using YYT.Entity;

namespace YYT.BLL.EF
{
    internal class AgencyFactory
    {
        public IAgencyQuery agencyQuery { get; private set; }

        public AgencyFactory(EAdminType eAdminType)
        {
            switch (eAdminType)
            {
                case EAdminType.Zero:// 超级管理
                    agencyQuery = new TypeZeroAdmin();
                    break;
                case EAdminType.Nine:// 副管理
                    agencyQuery = new TypeNineAdmin();
                    break;
                case EAdminType.Ten:// 运维、开发
                    agencyQuery = new TypeTenAdmin();
                    break;
                case EAdminType.One: // 总代理
                case EAdminType.General:// 一般代理
                default:
                    agencyQuery = new TypeGeneralAdmin();
                    break;
            }
        }
    }
}
