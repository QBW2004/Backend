using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using YYT.Common;
using YYT.Entity;
using YYT.Remote;

namespace YYT.BLL.EF
{
    public class B_ReChargeRecords
    {
        /// <summary>
        /// 清理充值记录：超级管理员清理全部，子代理清理自己的记录
        /// </summary>
        public int ClearRecords(M_LoginUser loginUser)
        {
            if (loginUser == null)
                return -1;

            using (var ef = new GameDbContext())
            {
                if (loginUser.UserPriv == 0)
                    ef.Database.ExecuteSqlCommand("TRUNCATE TABLE `ReChargeRecords`");
                else
                    ef.Database.ExecuteSqlCommand("DELETE FROM `ReChargeRecords` WHERE `Agency` = @p0", loginUser.Accounts);
                return 1;
            }
        }

        public M_EasyuiGridData<M_ReChargeRecords> GetReChargeRecords(M_LoginUser loginUser, M_Page mPage, M_ReChargeRecordsDao entity)
        {
            M_EasyuiGridData<M_ReChargeRecords> list = new M_EasyuiGridData<M_ReChargeRecords>();
            using (var ef = new GameDbContext())
            {
                IEnumerable<M_ReChargeRecords> rst = ef.ReChargeRecords;
                //var rst = from c in ef.ReChargeRecords
                //          select new M_ReChargeRecordsDao
                //          {
                //              OrderNo=c.OrderNo,
                //              RechargeType=c.RechargeType,
                //              Coin=c.Coin,
                //              GameID=c.GameID,
                //              Agency=c.Agency,
                //              PayNo=c.PayNo,
                //              Processed=c.Processed,
                //              CreateTime = c.CreateTime,
                //          };

                if (!string.IsNullOrWhiteSpace(entity.GameID))
                    rst = rst.Where(c => c.GameID.Equals(entity.GameID));

                if (!string.IsNullOrWhiteSpace(entity.PayNo))
                    rst = rst.Where(c => c.PayNo.Equals(entity.PayNo));

                if (!string.IsNullOrWhiteSpace(entity.OrderNo))
                    rst = rst.Where(c => c.OrderNo.Equals(entity.OrderNo));

                if (entity.Processed > -1 && entity.Processed < 3)
                    rst = rst.Where(c => c.Processed == entity.Processed);

                if (!string.IsNullOrWhiteSpace(entity.StartTime))
                    rst = rst.Where(c => c.CreateTime>Convert.ToDateTime(entity.StartTime));

                if (!string.IsNullOrWhiteSpace(entity.EndTime))
                    rst = rst.Where(c => c.CreateTime < Convert.ToDateTime(entity.EndTime));

                if (!string.IsNullOrWhiteSpace(entity.Agency))
                    rst = rst.Where(c => c.Agency.Equals(entity.Agency));
                // 加权限查询
                if (loginUser.UserPriv != 0)
                {
                    rst = rst.Where(c => c.Agency.Equals(loginUser.Accounts));
                }
              
                List<M_ReChargeRecords> ListFooter = new List<M_ReChargeRecords>();
                long? tatolReCharge = 0;
                long? tatolExCharge = 0;
                long? tatolGive = 0;
                long? tatolDelCoins = 0;
                List<M_ReChargeRecords> ListRecords = new List<M_ReChargeRecords>();
                ListRecords = rst.ToList();
                foreach (var item in ListRecords)
                {
                    if (item.RechargeType == 20 )
                    {
                        tatolReCharge += item.Coin;
                    }
                    if(item.RechargeType == 30)
                    {
                        if (item.Processed == 1)
                        {
                            tatolReCharge += item.Coin;
                        }
                    }
                    if (item.RechargeType == 21)
                    {
                        tatolExCharge += item.Coin;
                    }
                    if (item.RechargeType == 22)
                    {
                        tatolGive += item.Coin;
                    }
                    if (item.RechargeType == 23)
                    {
                        tatolDelCoins += item.Coin;
                    }
                    if (item.RechargeType == 31)
                    {
                        if (item.Processed == 3)
                        {
                            tatolDelCoins += item.Coin;
                        }
                        if (item.Processed == 1)
                        {
                            tatolExCharge += item.Coin;
                        }
                    }
                }
                M_ReChargeRecords footer = new M_ReChargeRecords();
                footer.GameID = "后台总充值：" + tatolReCharge;
                footer.Agency = "后台总兑换：" + tatolExCharge;
                footer.Operator = "后台总赠送：" + tatolGive;
                footer.OrderNo = "后台总扣币：" + tatolDelCoins;
                footer.Processed = 4;
                ListFooter.Add(footer);
                // 分页
                if (ListRecords != null)
                {
                    mPage.SetTotalCount(ListRecords.Count());
                    var users = ListRecords.AsEnumerable()
                        .OrderByDescending(c => c.CreateTime)
                        .Skip(mPage.PageSize * (mPage.PageIndex - 1)).Take(mPage.PageSize)
                        .ToList();
                    list.footer = ListFooter;
                    list.rows = users;
                    list.total = mPage.TotalCount;
                }
            }
            return list;
        }

        /// <summary>
        /// 手机端：充退记录分页（支持操作人/类型筛选，返回筛选范围内的总充值/总退分，并补充玩家名称与类型名称）
        /// TypeFlag：0 全部；1 充值类（后台充值/赠送/前端充值）；2 退分类（后台兑换/扣币/前端提现）
        /// </summary>
        public M_EasyuiGridData<M_ReChargeRecords> GetReChargeRecordsForPhone(M_LoginUser loginUser, M_Page mPage, M_ReChargeRecordsDao entity, out long sumRecharge, out long sumWithdraw)
        {
            sumRecharge = 0;
            sumWithdraw = 0;
            M_EasyuiGridData<M_ReChargeRecords> list = new M_EasyuiGridData<M_ReChargeRecords>();
            using (var ef = new GameDbContext())
            {
                var rst = ef.ReChargeRecords.AsQueryable();

                if (!string.IsNullOrWhiteSpace(entity.GameID))
                    rst = rst.Where(c => c.GameID.Equals(entity.GameID));
                if (!string.IsNullOrWhiteSpace(entity.PayNo))
                    rst = rst.Where(c => c.PayNo.Equals(entity.PayNo));
                if (!string.IsNullOrWhiteSpace(entity.OrderNo))
                    rst = rst.Where(c => c.OrderNo.Equals(entity.OrderNo));
                if (entity.Processed > -1 && entity.Processed < 3)
                    rst = rst.Where(c => c.Processed == entity.Processed);
                if (!string.IsNullOrWhiteSpace(entity.StartTime))
                    rst = rst.Where(c => c.CreateTime > Convert.ToDateTime(entity.StartTime));
                if (!string.IsNullOrWhiteSpace(entity.EndTime))
                    rst = rst.Where(c => c.CreateTime < Convert.ToDateTime(entity.EndTime));
                if (!string.IsNullOrWhiteSpace(entity.Agency))
                    rst = rst.Where(c => c.Agency.Equals(entity.Agency));
                if (!string.IsNullOrWhiteSpace(entity.Operator))
                    rst = rst.Where(c => c.Operator != null && c.Operator.Equals(entity.Operator));

                // 加权限查询
                if (loginUser.UserPriv != 0)
                {
                    rst = rst.Where(c => c.Agency.Equals(loginUser.Accounts));
                }

                // 类型筛选
                if (entity.TypeFlag == 1)
                {
                    rst = rst.Where(c => c.RechargeType == 20 || c.RechargeType == 22 || (c.RechargeType == 30 && c.Processed == 1));
                }
                else if (entity.TypeFlag == 2)
                {
                    rst = rst.Where(c => c.RechargeType == 21 || c.RechargeType == 23 || (c.RechargeType == 31 && c.Processed == 1));
                }
                else if (entity.TypeFlag == 3)
                {
                    rst = rst.Where(c => c.RechargeType == 22);
                }

                // 筛选范围内合计与总数，数据库端聚合（口径与原内存累加一致）
                sumRecharge = rst.Where(c => c.RechargeType == 20 || (c.RechargeType == 30 && c.Processed == 1) || c.RechargeType == 22)
                    .Sum(c => (long?)c.Coin) ?? 0;
                sumWithdraw = rst.Where(c => c.RechargeType == 21 || c.RechargeType == 23 || (c.RechargeType == 31 && c.Processed == 1))
                    .Sum(c => (long?)c.Coin) ?? 0;
                mPage.SetTotalCount(rst.Count());

                // 分页在数据库内完成
                List<M_ReChargeRecords> rows = rst
                    .OrderByDescending(c => c.CreateTime)
                    .Skip(mPage.PageSize * (mPage.PageIndex - 1)).Take(mPage.PageSize)
                    .ToList();

                // 玩家名称补充（只为当页行查）
                List<string> gameIds = rows.Select(c => c.GameID).Where(c => !string.IsNullOrWhiteSpace(c)).Distinct().ToList();
                Dictionary<string, string> nameMap = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
                if (gameIds.Count > 0)
                {
                    nameMap = ef.Users.Where(c => gameIds.Contains(c.ID)).ToDictionary(c => c.ID, c => c.NAME, StringComparer.OrdinalIgnoreCase);
                }
                foreach (M_ReChargeRecords item in rows)
                {
                    string name;
                    item.UserName = nameMap.TryGetValue(item.GameID, out name) ? name : string.Empty;
                    item.TypeName = TypeName(item.RechargeType);
                }

                list.rows = rows;
                list.total = mPage.TotalCount;
            }
            return list;
        }

        private static string TypeName(int rechargeType)
        {
            switch (rechargeType)
            {
                case 20: return "后台充值";
                case 21: return "后台兑换";
                case 22: return "赠送";
                case 23: return "扣币";
                case 30: return "前端充值";
                case 31: return "前端提现";
                default: return "类型" + rechargeType;
            }
        }

        public List<M_ReChargeRecords> GetReChargeRecords(M_ReChargeRecords entity)
        {
            M_EasyuiGridData<M_ReChargeRecords> list = new M_EasyuiGridData<M_ReChargeRecords>();
            using (var ef = new GameDbContext())
            {
                var rst = ef.ReChargeRecords.ToList();
                if (!string.IsNullOrWhiteSpace(entity.GameID))
                    rst = rst.Where(c => c.GameID.Equals(entity.GameID)).ToList();
                list.rows = rst;
                list.total = rst.Count;
            }
            return list.rows;
        }

        public Msg AddReChargeRecords(GameDbContext ef, M_ReChargeRecords entity)
        {
            Msg msg = new Msg(10002, "提交訂單失败！");
            var rst = ef.ReChargeRecords.Where(c => c.OrderNo.Equals(entity.OrderNo));
            if (rst != null && rst.Count() > 0)
            {
                msg.code = 10000;
                msg.content = "提交訂單成功！";
            }
            else
            {
                entity.Coin = entity.Coin ?? 0;
                ef.ReChargeRecords.Add(entity);
                int val = ef.SaveChanges();
                if (val > 0)
                {
                    msg.code = 10000;
                    msg.content = "提交訂單成功！";
                }
            }
            return msg;
        }

     
        public async Task<Msg> AddReChargeRecords(M_ReChargeRecords entity)
        {
            Msg msg = new Msg(0, "提交訂單失败！");
            using (var ef = new GameDbContext())
            {
                var rst = ef.ReChargeRecords.Where(c => c.OrderNo.Equals(entity.OrderNo));

                if (rst != null && rst.Count() > 0)
                {
                    msg.code = 0;
                    msg.content = "提交訂單失败！";
                }
                else
                {
                    entity.Coin = entity.Coin ?? 0;

                    ef.ReChargeRecords.Add(entity);
                    int val = await ef.SaveChangesAsync();
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "提交訂單成功！";
                    }
                }
            }
            return msg;
        }
        public int UpdateReChargeRecords(M_ReChargeRecords entity)
        {
            using (var ef = new GameDbContext())
            {
                var records = ef.ReChargeRecords.Where(c => c.OrderNo.Equals(entity.OrderNo)).First();
                if (records != null)
                {
                    M_Admin srcUsr = new B_Admin().GetSingle(new M_Admin { ID = records.Agency });
                    int RechargeType = 0;
                    if (records.RechargeType == 31)
                    {
                        RechargeType = 1;
                    }
                    M_Recharge dstUsr = new M_Recharge { AdminType = EAdminType.None, Coin = records.Coin, ID = records.GameID, IDType = EIDType.Account, RechargeType = RechargeType };
                    B_ReChargeBase reChargeBase = new B_ReChargeBase(srcUsr, dstUsr);
                    Msg msg = reChargeBase.PlayerReCharge1();
                    if (msg.code == 1)
                    {
                        records.Processed = 1;
                        var val1 = ef.SaveChanges();
                    }
                }
            }
            return 0;
        }
        public int UpdateChangeCoin(M_ReChargeRecords entity)
        {
            using (var ef = new GameDbContext())
            {
                var usr = ef.ReChargeRecords.Where(c => c.OrderNo.Equals(entity.OrderNo)).First();
                if (usr != null)
                {

                    usr.Processed = entity.Processed;
                    /// <summary>
                    /// 是否是真金版
                    /// </summary>
                    bool isRMB = ConfigHelper.Get("IsRMB").Equals("1");
                    /// <summary>
                    /// 真金版兑换率
                    /// </summary>
                    int exchangeRate = 0;
                    int coin = Convert.ToInt32(entity.Coin);
                    if (isRMB == true)
                    {
                        exchangeRate = Convert.ToInt32(ConfigHelper.Get("ExchangeRate"));
                        if (exchangeRate > 0)
                            coin *= exchangeRate;
                    }
                    string gameid = usr.GameID;
                    int count1 = new B_Users().ChangeCoin(gameid, coin);
                    return ef.SaveChanges();
                }
            }
            return 0;
        }


        public Msg ConfirmReChargeOrder(M_LoginUser loginUser, string orderNo)
        {
            Msg msg = new Msg(0, "订单处理失败！");
            using (var ef = new GameDbContext())
            {
                // 订单信息
                var rst = ef.ReChargeRecords.Where(c => c.OrderNo.Equals(orderNo)).SingleOrDefault();
                if (rst == null)
                {
                    msg.content = "获取订单信息失败！";
                    return msg;
                }
                if (rst.Processed > 0)
                {
                    msg.content = "订单已处理过，请不要重复确认！";
                    return msg;
                }

                // 订单中金币数量为0，没有必要和服务器通知，直接修改订单处理状态
                if (rst.Coin == 0)
                {
                    rst.Processed = 1;
                    rst.Operator = loginUser.Accounts;
                    var val = ef.SaveChanges();

                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "订单处理成功！";
                    }
                    return msg;
                }
                // 玩家信息
                var usr = ef.Users.Where(c => c.ID.Equals(rst.GameID)).SingleOrDefault();
                if (usr == null)
                {
                    int userId = Convert.ToInt32(rst.GameID);
                    usr = (from c in ef.Users
                           join r in ef.UserRelations on c.ID equals r.ID
                           where r.UserID == userId
                           select c).SingleOrDefault();
                }
                if (usr == null)
                {
                    msg.content = "获取用户信息失败！";
                    return msg;
                }
              
                M_Admin srcUsr = loginUser.ToAdminType();
                int RechargeType = 0;
                if (rst.RechargeType == 31)
                {
                    RechargeType = 1;
                }
                M_Recharge dstUsr = new M_Recharge { AdminType = EAdminType.None, Coin = rst.Coin, ID = rst.GameID, IDType = EIDType.Account, RechargeType = RechargeType };
                B_ReChargeBase reChargeBase = new B_ReChargeBase(srcUsr, dstUsr);
                msg = reChargeBase.PlayerReCharge1();
                if (msg.code == 1)
                {
                    rst.Processed = 1;
                    rst.Operator = loginUser.Accounts;
                    var val1 = ef.SaveChanges();
                }
                //msg.content = "暂未开放！";
            }
            return msg;
        }


        public Msg OrderRefuseDelCoins(M_LoginUser loginUser, string orderNo)
        {
            Msg msg = new Msg(0, "订单处理失败！");
            using (var ef = new GameDbContext())
            {
                // 订单信息
                var rst = ef.ReChargeRecords.Where(c => c.OrderNo.Equals(orderNo)).SingleOrDefault();
                if (rst == null)
                {
                    msg.content = "获取订单信息失败！";
                    return msg;
                }
                if (rst.Processed > 0)
                {
                    msg.content = "订单已处理过，请不要重复确认！";
                    return msg;
                }
                var usr = ef.Users.Where(c => c.ID.Equals(rst.GameID)).SingleOrDefault();
                if (usr == null)
                {
                    msg.content = "获取用户信息失败！";
                    return msg;
                }

                using (var trans = ef.Database.BeginTransaction())
                {
                    try
                    {
                        rst.Processed = 3;// 标识已处理
                        int val = ef.SaveChanges();
                        if (val > 0)
                        {
                            msg.code = 1;
                            msg.content = $"设置成功！";
                        }
                        trans.Commit();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();

                        LogHelper.WriteLog(typeof(YYT.BLL.EF.B_ReChargeRecords), ex);
                    }
                }
            }
            return msg;
        }

        public Msg OrderProcessOrder(string orderNo)
        {
            Msg msg = new Msg(0, "设置失败！");
            using (var ef = new GameDbContext())
            {
                var rst = ef.ReChargeRecords.Where(c => c.OrderNo.Equals(orderNo)).SingleOrDefault();
                if (rst == null)
                {
                    msg.content = "获取订单信息失败！";
                    return msg;
                }
                if (rst.Processed > 0)
                {
                    msg.content = "订单已处理过，请不要重复确认！";
                    return msg;
                }

                var usr = ef.Users.Where(c => c.ID.Equals(rst.GameID)).SingleOrDefault();
                if (usr == null)
                {
                    msg.content = "获取用户信息失败！";
                    return msg;
                }

                using (var trans = ef.Database.BeginTransaction())
                {
                    try
                    {
                        rst.Processed = 1;// 标识已处理
                        int val = ef.SaveChanges();
                        if (val > 0)
                        {
                            msg.code = 1;
                            msg.content = $"设置成功！";
                        }
                        trans.Commit();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();

                        LogHelper.WriteLog(typeof(YYT.BLL.EF.B_ReChargeRecords), ex);
                    }
                }
            }
            return msg;
        }

        public Msg OrderOrderRefuse(string orderNo)
        {
            Msg msg = new Msg(0, "设置失败！");
            using (var ef = new GameDbContext())
            {
                var rst = ef.ReChargeRecords.Where(c => c.OrderNo.Equals(orderNo)).SingleOrDefault();
                if (rst == null)
                {
                    msg.content = "获取订单信息失败！";
                    return msg;
                }
                if (rst.Processed > 0)
                {
                    msg.content = "订单已处理过，请不要重复确认！";
                    return msg;
                }

                var usr = ef.Users.Where(c => c.ID.Equals(rst.GameID)).SingleOrDefault();
                if (usr == null)
                {
                    msg.content = "获取用户信息失败！";
                    return msg;
                }

                using (var trans = ef.Database.BeginTransaction())
                {
                    try
                    {
                        rst.Processed = 2;// 标识已处理
                        int val = ef.SaveChanges();
                        if (val > 0)
                        {
                            msg.code = 1;
                            msg.content = $"设置成功！";
                        }
                        trans.Commit();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();

                        LogHelper.WriteLog(typeof(YYT.BLL.EF.B_ReChargeRecords), ex);
                    }
                }
            }
            return msg;
        }

        public Msg OrderOrderRefuseEx(string orderNo)
        {
            Msg msg = new Msg(0, "设置失败！");
            using (var ef = new GameDbContext())
            {
                var rst = ef.ReChargeRecords.Where(c => c.OrderNo.Equals(orderNo)).SingleOrDefault();
                if (rst == null)
                {
                    msg.content = "获取订单信息失败！";
                    return msg;
                }

                var usr = ef.Users.Where(c => c.ID.Equals(rst.GameID)).SingleOrDefault();
                if (usr == null)
                {
                    msg.content = "获取用户信息失败！";
                    return msg;
                }
                msg = new B_Users().ExChangeCoinEx(rst.GameID, rst.Coin);//修改用户金币
                int val1 = new B_Admin().ExChangeCoinEx(rst.Agency, rst.Coin);//修改代理金币
                using (var trans = ef.Database.BeginTransaction())
                {
                    try
                    {
                        rst.Processed = 2;// 标识已处理
                        int val = ef.SaveChanges();
                        if (val > 0)
                        {
                            msg.code = 1;
                            msg.content = $"设置成功！";
                        }
                        trans.Commit();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();

                        LogHelper.WriteLog(typeof(YYT.BLL.EF.B_ReChargeRecords), ex);
                    }
                }
            }
            return msg;
        }
    }
}
