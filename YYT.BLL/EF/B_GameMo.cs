using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using YYT.Common;
using YYT.Entity;
using YYT.Remote;


namespace YYT.BLL.EF
{
    public class B_GameMo
    {

        public M_EasyuiGridData<M_GameMo> GetGameMo(M_LoginUser loginUser, M_Page mPage, M_GameMo entity)
        {
            M_EasyuiGridData<M_GameMo> list = new M_EasyuiGridData<M_GameMo>();
            using (var ef = new GameDbContext())
            {
                IEnumerable<M_GameMo> rst = ef.GameMos;
                //if (!string.IsNullOrWhiteSpace(entity.UserName))
                //    rst = rst.Where(c => c.UserName.Equals(entity.UserName));
                // 加权限查询
                //if (loginUser.UserPriv != 0)
                //{
                //    rst = rst.Where(c => c.Agency.Equals(loginUser.Accounts));
                //}

                // 分页
                if (rst != null)
                {
                    mPage.SetTotalCount(rst.Count());
                    var users = rst.AsEnumerable()
                        .Skip(mPage.PageSize * (mPage.PageIndex - 1)).Take(mPage.PageSize)
                        .ToList();
                    list.rows = users;
                    list.total = mPage.TotalCount;
                }
            }
            return list;
        }

        public int UpdateGameMoType(M_GameMo entity)
        {
            using (var ef = new GameDbContext())
            {
                var usr = ef.GameMos.Where(c => c.ID.Equals(entity.ID)).FirstOrDefault();
                if (usr != null)
                {
                    if (usr.GameMoType.Equals(entity.GameMoType))
                        return 1;
                    usr.GameMoType = entity.GameMoType;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }
    }
}
