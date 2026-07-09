using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Threading.Tasks;
using YYT.Common;
using YYT.Entity;

namespace YYT.BLL.EF
{
    public class B_CashierInfo
    {
        public Msg SaveCashierInfo(M_CashierInfo entity)
        {
            Msg msg = new Msg(0, "保存失败！");
            using (var ef = new GameDbContext())
            {
                using (var trans = ef.Database.BeginTransaction())
                {
                    try
                    {
                        var rst = string.IsNullOrWhiteSpace(entity.CID) ? null : ef.CashierInfos.Where(c => c.CID == entity.CID).SingleOrDefault();
                        if (rst != null)
                        {
                            var checkName = ef.CashierInfos.Where(c => !c.CID.Equals(entity.CID) && c.Account.Equals(entity.Account) && c.PayType == entity.PayType).SingleOrDefault();
                            if (checkName != null)
                            {
                                msg.content = "同类型支付下已配置此收款账号信息！";
                                return msg;
                            }
                            // 修改
                            rst.CreateTime = DateTime.Now;
                            rst.Name = entity.Name;
                            rst.PayType = entity.PayType;
                            rst.Account = entity.Account;
                            rst.UseQRCodeImg = entity.UseQRCodeImg;
                            rst.Enable = entity.Enable;
                            if (!string.IsNullOrWhiteSpace(entity.QRCodeImg))
                                rst.QRCodeImg = entity.QRCodeImg;
                        }
                        else
                        {
                            // 添加
                            entity.CID = Guid.NewGuid().ToString();
                            entity.CreateTime = DateTime.Now;
                            entity.QRCodeImg = string.IsNullOrWhiteSpace(entity.QRCodeImg) ? "" : entity.QRCodeImg;
                            ef.CashierInfos.Add(entity);
                        }

                        // 检查收款码，微信和支付宝种同时只能启用一张二维码
                        if(entity.UseQRCodeImg == 1)
                        {
                            var checkObjs = ef.CashierInfos.Where(c => !c.CID.Equals(entity.CID) && c.PayType == entity.PayType && c.UseQRCodeImg == 1);
                            if(checkObjs != null)
                            {
                                foreach (var item in checkObjs)
                                {
                                    item.UseQRCodeImg = 0;
                                }
                            }
                        }

                        int val = ef.SaveChanges();
                        if (val > 0)
                        {
                            msg.code = 1;
                            msg.content = "保存成功！";
                        }

                        trans.Commit();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        LogHelper.WriteLog(typeof(YYT.BLL.EF.B_CashierInfo), ex);
                    }
                }
            }
            return msg;
        }

        public List<M_CashierInfo> GetCashierInfos()
        {
            using (var ef = new GameDbContext())
            {
                return ef.CashierInfos.ToList();
            }
        }

        public async Task<List<M_Cashier>> GetCashierInfosAsync()
        {
            using (var ef = new GameDbContext())
            {
                var query = from c in ef.CashierInfos
                            where c.Enable == 1
                            select new M_Cashier { Account = c.Account, PayType = c.PayType, Name = c.Name };
                return await query.ToListAsync();
            }
        }

        public async Task<M_CashierInfo> GetQRCodeImg(int payType)
        {
            using (var ef = new GameDbContext())
            {
                return await ef.CashierInfos.Where(c => c.PayType == payType && c.Enable == 1 && c.UseQRCodeImg == 1).SingleOrDefaultAsync();
            }
        }


        public M_EasyuiGridData<M_CashierInfo> GetCashierInfos(M_LoginUser loginUser, M_Page mPage, M_CashierInfo entity)
        {
            M_EasyuiGridData<M_CashierInfo> list = new M_EasyuiGridData<M_CashierInfo>();
            using (var ef = new GameDbContext())
            {
                IQueryable<M_CashierInfo> rst = ef.CashierInfos;

                if (!string.IsNullOrWhiteSpace(entity.Name))
                    rst = rst.Where(c => c.Name.Contains(entity.Name));
                if (!string.IsNullOrWhiteSpace(entity.Account))
                    rst = rst.Where(c => c.Account.Equals(entity.Account));
                if (entity.PayType > 0)
                    rst = rst.Where(c => c.PayType == entity.PayType);

                //加权限查询
                if (loginUser.UserPriv != 0)
                {
                    //TODO: 根据登录权限获取相应的收款信息
                }

                // 分页
                if (rst != null)
                {
                    mPage.SetTotalCount(rst.Count());
                    var users = rst.AsEnumerable()
                        .OrderByDescending(c => c.CreateTime)
                        .Skip(mPage.PageSize * (mPage.PageIndex - 1)).Take(mPage.PageSize)
                        .ToList();
                    list.rows = users;
                    list.total = mPage.TotalCount;
                }
            }
            return list;
        }

        public Msg DelCashierInfo(M_CashierInfo entity)
        {
            Msg msg = new Msg(0, "删除失败！");
            using (var ef = new GameDbContext())
            {
                var rst = ef.CashierInfos.Where(c => c.CID.Equals(entity.CID)).SingleOrDefault();
                if (rst != null)
                {
                    entity.QRCodeImg = rst.QRCodeImg;

                    ef.CashierInfos.Remove(rst);
                    int val = ef.SaveChanges();
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "删除成功！";
                    }
                }
            }
            return msg;
        }
    }
}
