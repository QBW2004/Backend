using YYT.Entity;

namespace YYT.BLL.EF
{
    public interface IRecords
    {
        dynamic Get_PlayerRecords(M_Page mPage, M_LoginUser loginUser,dynamic queryEntity);
        dynamic Get_AgencyRecords(M_Page mPage, M_LoginUser loginUser,dynamic queryEntity);
    }
}
