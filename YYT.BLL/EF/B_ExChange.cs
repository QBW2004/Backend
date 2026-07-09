using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using YYT.Common;
using YYT.Entity;
using YYT.Remote;


namespace YYT.BLL.EF
{
    public class B_ExChange
    {


        public Msg AddExChange(GameDbContext ef, M_ExChange entity)
        {
            ef.exChanges.Add(entity);
            if (ef.SaveChanges() > 0)
                return new Msg(10000, "兑换申请成功！");
            return new Msg(10002, "兑换申请失败！");
        }

        public M_ExChange GetSingle(M_ExChange entity)
        {
            using (var ef = new GameDbContext())
            {
                return ef.exChanges.Find(entity.PLAYER_ID);
            }
        }

        public M_EasyuiGridData<M_ExChange> getExChange(M_Page mPage, M_ExChange entity, M_LoginUser loginUser)
        {
            M_EasyuiGridData<M_ExChange> list = new M_EasyuiGridData<M_ExChange>();
            using (var ef = new GameDbContext())
            {
                IEnumerable<M_ExChange> rst = ef.exChanges;
                if (!string.IsNullOrWhiteSpace(entity.PLAYER_ID))
                    rst = rst.Where(c => c.PLAYER_ID.Contains(entity.PLAYER_ID));
                if (!string.IsNullOrWhiteSpace(entity.AGENCY))
                    rst = rst.Where(c => c.AGENCY.Contains(entity.AGENCY));
                // 加权限查询
                if (loginUser.UserPriv != 0)
                {
                    rst = rst.Where(c => c.AGENCY.Equals(loginUser.Accounts));
                }
                // 分页
                if (rst != null)
                {
                    mPage.SetTotalCount(rst.Count());
                    var users = rst.AsEnumerable()
                        .OrderByDescending(c => c.CREATE_TIME)
                        .Skip(mPage.PageSize * (mPage.PageIndex - 1)).Take(mPage.PageSize)
                        .ToList();
                    list.rows = users;
                    list.total = mPage.TotalCount;
                }
            }
            return list;
        }
    }
}
