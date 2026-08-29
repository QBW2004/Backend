using MySql.Data;
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Data.Common;
using System.Data.Entity.Validation;
using System.Drawing;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using YYT.Common;
using YYT.Entity;
using YYT.BLL.Services.GameServer;
using static System.Runtime.CompilerServices.RuntimeHelpers;
namespace YYT.BLL.EF
{
    public class B_Users
    {
        protected IGameServerClient GameServerClient { get; set; }

        public B_Users()
        {
            this.GameServerClient = new PipeGameServerClient();
        }

        public List<RankUsersList> GetRankingUserList()
        {
            using (var ef = new GameDbContext())
            {
                IQueryable<RankUsersList> RankList = null;
                var rst = from u in ef.Users
                          group u by new { ID = u.ID, NAME = u.NAME, COINS = u.COINS, PIC_INDEX = u.PIC_INDEX } into g
                          select new RankUsersList
                          {
                              ID = g.Key.ID,
                              NAME = g.Key.NAME,
                              COINS = g.Key.COINS,
                              PIC_INDEX = g.Key.PIC_INDEX
                          };
                RankList= rst.OrderByDescending(x => x.COINS).Take(100);
                //IQueryable<M_Users> Users = null;
                //var rst = ef.Users;
                //Users = rst.OrderByDescending(x => x.COINS).Take(15);
                // Users = Users.ToList().Take(15).Select(a => a.ID);
                return RankList.ToList();
            }
        }
        public bool Exists(M_Users entity)
        {
            using (var ef = new GameDbContext())
            {
                return ef.Users.Any(c => c.ID.Equals(entity.ID));
            }
        }

        public M_Users GetSingle(M_Users entity)
        {
            using (var ef = new GameDbContext())
            {
                return ef.Users.Find(entity.ID);
            }
        }

        public Msg GetBySafePwd(M_Users entity)
        {
            Msg msg = new Msg(1002, "登录失败！");
            using (var ef = new GameDbContext())
            {
                var usr = ef.Users.Where(c => c.ID.Equals(entity.ID)).FirstOrDefault();
                if (usr!=null)
                {
                    if (string.Equals(usr.SAFE_PWD, entity.SAFE_PWD))
                    {
                        SafeModel model = new SafeModel();
                        model.playerId = usr.ID;
                        model.safePwd = usr.SAFE_PWD;
                        model.coins = usr.COINS;
                        model.safeCoins = usr.SAFE_COINS;
                        msg.code = 10000;
                        msg.content = "登录成功！";
                        msg.datas = model;
                        return msg;
                    }
                    else
                    {
                        msg.content = "保险柜密码错误！";
                        return msg;

                    }
                }
                else
                {
                    msg.content = "未找到该账号！";
                    return msg;
                }
            }
        }

        public Msg updateSafePwd(M_Users entity,string safePwd)
        {
            Msg msg = new Msg(1002, "修改失败！");
            using (var ef = new GameDbContext())
            {
                var usr = ef.Users.Where(c => c.ID.Equals(entity.ID)).FirstOrDefault();
                if (usr != null)
                {
                    if (string.Equals(usr.SAFE_PWD, entity.SAFE_PWD))
                    {
                        usr.SAFE_PWD =safePwd;
                        ef.SaveChanges();
                        SafeModel model = new SafeModel();
                        model.playerId = usr.ID;
                        model.safePwd = usr.SAFE_PWD;
                        model.coins = usr.COINS;
                        model.safeCoins = usr.SAFE_COINS;
                        msg.code = 10000;
                        msg.content = "修改成功！";
                        msg.datas = model;
                    }
                    else
                    {
                        msg.content = "保险柜原始密码错误！";
                        return msg;
                    }
                }
                else
                {
                    msg.content = "未找到该账号！";
                    return msg;
                }
            }
            return msg;
        }

        public Msg updateUsersName(M_Users entity)
        {
            Msg msg = new Msg(1002, "Sửa đổi thất bại（修改失败）！");
            using (var ef = new GameDbContext())
            {
                var usr = ef.Users.Where(c => c.ID.Equals(entity.ID)).FirstOrDefault();
                if (usr != null)
                {
                    usr.NAME = entity.NAME;
                    ef.SaveChanges();
                    msg.code = 10000;
                    msg.content = "Sửa đổi thành công（修改成功）！";

                }
                else
                {
                    msg.content = "Không tìm thấy tài khoản（未找到该账号）！";
                    return msg;
                }
            }

          
            return msg;
        }

        public Msg updateSafeCoins(M_Users entity, int type,long? coins)
        {
            Msg msg = new Msg(1002, "接口错误！");
            int rstVal = 0;
            if (coins <= 0)
            {
                msg.content = "请输入大于0的金额！";
                return msg;
            }

            using (var ef = new GameDbContext())
            {
                var usr = ef.Users.Where(c => c.ID.Equals(entity.ID)).FirstOrDefault();
                if (usr == null)
                {
                    msg.content = "未找到该账号！";
                    return msg;
                }

                if (!string.Equals(usr.SAFE_PWD, entity.SAFE_PWD))
                {
                    msg.content = "请重新登录，保险柜密码错误！";
                    return msg;
                }

                if (type == 0 && usr.SAFE_COINS < coins)
                {
                    msg.content = "Vui lòng nhập lại số tiền, số dư két không đủ（请重新输入金额，保险柜余额不够）！";
                    return msg;
                }
                if (type != 0 && usr.COINS < coins)
                {
                    msg.content = "Vui lòng nhập lại số tiền, số dư không đủ（请重新输入金额，余额不够）！";
                    return msg;
                }

                Msg lockMsg = LockUser(entity.ID);
                if (lockMsg == null || lockMsg.code != 1)
                    return lockMsg ?? new Msg(1002, "服务器锁定用户失败！");

                int typeInt = type == 0 ? 5 : 4;
                try
                {
                    if (type == 0)
                    {
                        usr.COINS = usr.COINS + coins;
                        usr.SAFE_COINS = usr.SAFE_COINS - coins;
                    }
                    else
                    {
                        usr.COINS = usr.COINS - coins;
                        usr.SAFE_COINS = usr.SAFE_COINS + coins;
                    }

                    new B_SafeCoinsLog().AddSafeCoinsLog(ef, new M_SafeCoinsLog()
                    {
                        User_Id = usr.ID,
                        type = type,
                        coins = coins,
                        Create_Time = DateTime.Now,
                        new_Coins = usr.COINS,
                        safe_Coins = usr.SAFE_COINS
                    });

                    rstVal = ef.SaveChanges();
                    msg.code = 10000;
                    msg.content = type == 0 ? "Rút tiền thành công（取出金额成功）！" : "Số tiền nạp thành công（存入金额成功）！";
                    msg.datas = new SafeModel
                    {
                        playerId = usr.ID,
                        safePwd = usr.SAFE_PWD,
                        coins = usr.COINS,
                        safeCoins = usr.SAFE_COINS
                    };
                }
                finally
                {
                    UnLockUser(rstVal > 0 ? UnLockOptType.Success : UnLockOptType.Error, typeInt, coins, usr.ID);
                }
            }
            return msg;
        }

        public Msg ExChangeCoin(string playerId, long? coin)
        {
            Msg msg = new Msg(1002, "接口错误！");
            int val = 0;
            if (coin <= 0)
            {
                msg.content = "请输入大于0的金额！";
                return msg;
            }

            using (var ef = new GameDbContext())
            {
                var rst = ef.Users.Where(c => c.ID.Equals(playerId)).SingleOrDefault();
                if (rst == null)
                {
                    msg.content = "未找到该账号！";
                    return msg;
                }

                if (rst.COINS < coin)
                {
                    msg.content = "余额不足！";
                    return msg;
                }

                Msg lockMsg = LockUser(playerId);
                if (lockMsg == null || lockMsg.code != 1)
                    return lockMsg ?? new Msg(1002, "服务器锁定用户失败！");

                try
                {
                    rst.COINS = rst.COINS - coin;//用户余额=余额-兑换金币
                    rst.COINS_BACK = rst.COINS_BACK + coin;//用户兑换金币数量=兑换+兑换金币
                    val = ef.SaveChanges();
                    msg.code = 10000;
                    msg.content = "兑换成功！";
                }
                catch (Exception ex)
                {
                    msg.content = ex.Message;
                    LogHelper.WriteLog(typeof(YYT.BLL.EF.B_Users), ex);
                }
                finally
                {
                    UnLockUser(val > 0 ? UnLockOptType.Success : UnLockOptType.Error, 1, coin, playerId);
                }
            }
            return msg;

        }

        public Msg ExChangeCoinEx(string playerId, long? coin)
        {
            Msg msg = new Msg(1002, "接口错误！");
            int val = 0;
            if (coin <= 0)
            {
                msg.content = "请输入大于0的金额！";
                return msg;
            }

            using (var ef = new GameDbContext())
            {
                var rst = ef.Users.Where(c => c.ID.Equals(playerId)).SingleOrDefault();
                if (rst == null)
                {
                    msg.content = "未找到该账号！";
                    return msg;
                }

                Msg lockMsg = LockUser(playerId);
                if (lockMsg == null || lockMsg.code != 1)
                    return lockMsg ?? new Msg(1002, "服务器锁定用户失败！");

                try
                {
                    rst.COINS = rst.COINS + coin;//用户余额=余额+兑换金币
                    rst.COINS_BACK = rst.COINS_BACK - coin;//用户兑换金币数量=兑换-兑换金币
                    val = ef.SaveChanges();
                    msg.code = 10000;
                    msg.content = "兑换回滚成功！";
                }
                catch (Exception ex)
                {
                    msg.content = ex.Message;
                    LogHelper.WriteLog(typeof(YYT.BLL.EF.B_Users), ex);
                }
                finally
                {
                    UnLockUser(val > 0 ? UnLockOptType.Success : UnLockOptType.Error, 6, coin, playerId);
                }
            }
            return msg;

        }

        /// <summary>
        /// 锁定用户
        /// </summary>
        /// <returns></returns>
        protected Msg LockUser(string ID)
        {
            try
            {
                // 发送锁定用户指令  指令内容：UL + 玩家账号
                return this.GameServerClient.LockPlayer(ID);

            }
            catch (Exception ex)
            {
                Msg msg = new Msg(1002, "服务器连接失败,"+ex.Message);
                return msg;
            }
        }
        /// <summary>
        /// 解锁用户
        /// </summary>
        /// <param name="val"></param>
        /// <returns></returns>
        private string UnLockUser(UnLockOptType optType,int type,long? coins,string ID)
        {
            int val = 0;// 失败
            if (optType == UnLockOptType.Success)
                val = 1;// 成功
            string srvCode = string.Empty;
            try
            {
                //0是加金币,不等于0是减金币
                // 发送解锁用户指令  指令内容：UL + 充值0/兑换1 +充值金币数+ 操作结果失败0/成功1 + 玩家账号
                srvCode = this.GameServerClient.UnlockPlayer(type, val, coins, ID);
            }
            catch (Exception ex)
            {
                srvCode = "服务器连接失败," + ex.Message;
            }
            return srvCode;
        }

        public class SafeModel
        {
            /// <summary>
            /// 玩家账号
            /// </summary>
            public string playerId { get; set; }

            /// <summary>
            /// 保险柜密码
            /// </summary>
            public string safePwd { get; set; }


            /// <summary>
            /// 金币数
            /// </summary>
            public long? coins { get; set; }

            /// <summary>
            /// 保险柜金币数
            /// </summary>
            public long? safeCoins { get; set; }

        }

        public M_EasyuiGridData<M_Users_DTO> GetUsersList(M_Page mPage, M_Users_DTO entity, M_LoginUser loginUser)
        {
            M_EasyuiGridData<M_Users_DTO> list = new M_EasyuiGridData<M_Users_DTO>();
            using (var ef = new GameDbContext())
            {
                // 敏感列仅在有查看权限时才参与查询（与 ApplySensitiveFieldPermissions 同口径，避免密码无谓出库出接口）
                bool canPwd = loginUser.UserPriv == 0 || loginUser.IsViewPwd == 1 || loginUser.IsViewSafePwd == 1;
                bool canSafePwd = loginUser.UserPriv == 0 || loginUser.IsViewSafePwd == 1;

                var rst = from c in ef.Users
                          join r in ef.UserRelations on c.ID equals r.ID
                          select new M_Users_DTO
                          {
                              ID = c.ID,
                              NAME = c.NAME,
                              PWD = canPwd ? c.PWD : null,
                              SAFE_PWD = canSafePwd ? c.SAFE_PWD : null,
                              AGENCY = c.AGENCY,
                              FROZEN = c.FROZEN,
                              COINS = c.COINS,
                              COINS_BUY = c.COINS_BUY,
                              COINS_BACK = c.COINS_BACK,
                              UserID = r.UserID,
                              TELEPHONE = c.TELEPHONE,
                              INHALL = c.INHALL,
                              GAME_SCORE = c.GAME_SCORE,
                              GRADE = c.GRADE,
                              SAFE_COINS = c.SAFE_COINS
                          };

                if (!string.IsNullOrWhiteSpace(entity.AGENCY))
                    rst = rst.Where(c => c.AGENCY.Equals(entity.AGENCY));
                if (!string.IsNullOrWhiteSpace(entity.NAME))
                    rst = rst.Where(c => c.NAME.Equals(entity.NAME));
                if (!string.IsNullOrWhiteSpace(entity.ID))
                    rst = rst.Where(c => c.ID.Equals(entity.ID));
                if (entity.UserID > 0)
                    rst = rst.Where(c => c.UserID == entity.UserID);

                // 加权限查询：一条 IN(...) 取代原先逐代理执行 SQL 的 N+1 循环
                if (loginUser.UserPriv != 0)
                {
                    List<string> agencies = new B_Admin().GetManagedAgencyAccounts(ef, loginUser);
                    if (agencies == null || agencies.Count < 1)
                        return list;
                    rst = rst.Where(c => agencies.Contains(c.AGENCY));
                }

                // 分页下推数据库
                mPage.SetTotalCount(rst.Count());
                List<M_Users_DTO> users = rst
                    .OrderByDescending(c => c.INHALL)
                    .ThenByDescending(c => c.UserID)
                    .Skip(mPage.PageSize * (mPage.PageIndex - 1)).Take(mPage.PageSize)
                    .ToList();

                FillCurrentPlayInfo(ef, users);
                FillTodayWinLoss(ef, users);
                ApplySensitiveFieldPermissions(users, loginUser);
                list.rows = users;
                list.total = mPage.TotalCount;
            }
            return list;
        }

        public List<M_Users_DTO> GetUserRowsByIds(List<string> userIds, M_LoginUser loginUser)
        {
            if (userIds == null || userIds.Count < 1 || loginUser == null)
                return new List<M_Users_DTO>();

            userIds = userIds
                .Where(c => !string.IsNullOrWhiteSpace(c))
                .Select(c => c.Trim())
                .Distinct()
                .Take(100)
                .ToList();

            if (userIds.Count < 1)
                return new List<M_Users_DTO>();

            using (var ef = new GameDbContext())
            {
                // 敏感列仅在有查看权限时才参与查询（与 ApplySensitiveFieldPermissions 同口径）
                bool canPwd = loginUser.UserPriv == 0 || loginUser.IsViewPwd == 1 || loginUser.IsViewSafePwd == 1;
                bool canSafePwd = loginUser.UserPriv == 0 || loginUser.IsViewSafePwd == 1;

                var rst = from c in ef.Users
                          join r in ef.UserRelations on c.ID equals r.ID
                          where userIds.Contains(c.ID)
                          select new M_Users_DTO
                          {
                              ID = c.ID,
                              NAME = c.NAME,
                              PWD = canPwd ? c.PWD : null,
                              SAFE_PWD = canSafePwd ? c.SAFE_PWD : null,
                              AGENCY = c.AGENCY,
                              FROZEN = c.FROZEN,
                              COINS = c.COINS,
                              COINS_BUY = c.COINS_BUY,
                              COINS_BACK = c.COINS_BACK,
                              UserID = r.UserID,
                              TELEPHONE = c.TELEPHONE,
                              INHALL = c.INHALL,
                              GAME_SCORE = c.GAME_SCORE,
                              GRADE = c.GRADE,
                              SAFE_COINS = c.SAFE_COINS
                          };

                if (loginUser.UserPriv != 0)
                {
                    List<string> agencies = new B_Admin().GetManagedAgencyAccounts(ef, loginUser);
                    rst = rst.Where(c => agencies.Contains(c.AGENCY));
                }

                List<M_Users_DTO> users = rst.ToList();
                foreach (M_Users_DTO user in users)
                    user.Profit = user.COINS_BUY - user.COINS_BACK;

                FillCurrentPlayInfo(ef, users);
                FillTodayWinLoss(ef, users);
                ApplySensitiveFieldPermissions(users, loginUser);
                return users;
            }
        }

        #region 手机端扩展查询（离线玩家 / 封禁玩家 / 会员盈亏 / 今日总输赢）
        /// <summary>
        /// 手机端通用玩家分页查询：可只看离线 / 只看封禁，支持按今日输赢、总盈亏排序。
        /// 过滤/排序/分页/今日输赢全部下推 SQL（配合 users(AGENCY,INHALL)、userrelations(ID)、
        /// user_daily_winloss(UserID,DAY) 索引），禁止把权限范围内全量玩家拉进内存再排序分页。
        /// </summary>
        /// <param name="sort">空/last-time 默认序；win-most 今日赢最多；loss-most 今日输最多；profit-desc 总盈亏降序；profit-asc 总盈亏升序</param>
        private M_EasyuiGridData<M_Users_DTO> QueryUsersPaged(M_Page mPage, M_Users_DTO entity, M_LoginUser loginUser, bool onlyOffline, bool onlyFrozen, string sort)
        {
            M_EasyuiGridData<M_Users_DTO> list = new M_EasyuiGridData<M_Users_DTO>();
            using (var ef = new GameDbContext())
            {
                List<string> agencies = null;
                if (loginUser.UserPriv != 0)
                {
                    agencies = new B_Admin().GetManagedAgencyAccounts(ef, loginUser);
                    if (agencies == null || agencies.Count < 1)
                        return list;
                }

                int pageIndex = mPage != null && mPage.PageIndex > 0 ? mPage.PageIndex : 1;
                int pageSize = mPage != null && mPage.PageSize > 0 ? mPage.PageSize : 10;
                if (pageSize > 1000)
                    pageSize = 1000;

                List<object> args = new List<object>();
                StringBuilder where = new StringBuilder();
                if (onlyOffline)
                    where.Append(" AND NOT (c.INHALL = 1)");
                if (onlyFrozen)
                    where.Append(" AND c.FROZEN = 1");
                if (!string.IsNullOrWhiteSpace(entity.AGENCY))
                {
                    where.Append(" AND c.AGENCY = {").Append(args.Count).Append("}");
                    args.Add(entity.AGENCY);
                }
                if (!string.IsNullOrWhiteSpace(entity.NAME))
                {
                    where.Append(" AND c.NAME = {").Append(args.Count).Append("}");
                    args.Add(entity.NAME);
                }
                if (!string.IsNullOrWhiteSpace(entity.ID))
                {
                    where.Append(" AND c.ID = {").Append(args.Count).Append("}");
                    args.Add(entity.ID);
                }
                if (entity.UserID > 0)
                {
                    where.Append(" AND r.UserID = {").Append(args.Count).Append("}");
                    args.Add(entity.UserID);
                }
                if (agencies != null)
                {
                    where.Append(" AND c.AGENCY IN (");
                    for (int i = 0; i < agencies.Count; i++)
                    {
                        if (i > 0)
                            where.Append(",");
                        where.Append("{").Append(args.Count).Append("}");
                        args.Add(agencies[i]);
                    }
                    where.Append(")");
                }
                string whereSql = where.ToString();
                object[] baseArgs = args.ToArray();

                // 排序口径与原内存排序一致，UserID 作稳定次序
                string orderClause;
                switch (sort)
                {
                    case "win-most":
                        orderClause = " ORDER BY IFNULL(w.WINLOSS,0) DESC, r.UserID DESC";
                        break;
                    case "loss-most":
                        orderClause = " ORDER BY IFNULL(w.WINLOSS,0) ASC, r.UserID DESC";
                        break;
                    case "profit-desc":
                        orderClause = " ORDER BY (IFNULL(c.COINS_BUY,0) - IFNULL(c.COINS_BACK,0)) DESC, r.UserID DESC";
                        break;
                    case "profit-asc":
                        orderClause = " ORDER BY (IFNULL(c.COINS_BUY,0) - IFNULL(c.COINS_BACK,0)) ASC, r.UserID DESC";
                        break;
                    default:
                        // 默认按最后登录时间倒序（无记录的排最后）
                        orderClause = " ORDER BY l.LastLoginTime DESC, r.UserID DESC";
                        break;
                }

                int total = ef.Database.SqlQuery<int>(
                    "SELECT COUNT(1) FROM users c INNER JOIN userrelations r ON r.ID = c.ID" + whereSql,
                    baseArgs).FirstOrDefault();
                mPage.SetTotalCount(total);

                // 今日输赢一并 LEFT JOIN 取出（user_daily_winloss 主键 (UserID, DAY)，一次命中）；
                // 最后登录时间取 UserOptLog 最新操作时间（UserID 存玩家账号）
                args.Add(DateTime.Today);
                string pageSql = "SELECT c.ID, c.NAME, c.AGENCY, c.FROZEN, c.COINS, c.COINS_BUY, c.COINS_BACK," +
                    " r.UserID, c.INHALL, c.GAME_SCORE, c.GRADE, c.SAFE_COINS," +
                    " IFNULL(w.WINLOSS,0) AS TodayWinLoss, l.LastLoginTime" +
                    " FROM users c INNER JOIN userrelations r ON r.ID = c.ID" +
                    " LEFT JOIN user_daily_winloss w ON w.UserID = c.ID AND w.DAY = {" + (args.Count - 1) + "}" +
                    " LEFT JOIN (SELECT UserID, MAX(REC_TIME) AS LastLoginTime FROM `UserOptLog` GROUP BY UserID) l ON l.UserID = c.ID" +
                    whereSql + orderClause +
                    " LIMIT " + (pageSize * (pageIndex - 1)) + ", " + pageSize;
                List<M_Users_DTO> users = ef.Database.SqlQuery<M_Users_DTO>(pageSql, args.ToArray()).ToList();

                foreach (M_Users_DTO item in users)
                    item.Profit = item.COINS_BUY - item.COINS_BACK;
                ApplySensitiveFieldPermissions(users, loginUser);

                list.rows = users;
                list.total = mPage.TotalCount;
            }
            return list;
        }

        /// <summary>手机端：离线玩家分页（支持排序）</summary>
        public M_EasyuiGridData<M_Users_DTO> GetOfflineUsersList(M_Page mPage, M_Users_DTO entity, M_LoginUser loginUser, string sort)
        {
            return QueryUsersPaged(mPage, entity, loginUser, true, false, sort);
        }

        /// <summary>手机端：封禁中的玩家分页</summary>
        public M_EasyuiGridData<M_Users_DTO> GetFrozenUsersList(M_Page mPage, M_Users_DTO entity, M_LoginUser loginUser)
        {
            return QueryUsersPaged(mPage, entity, loginUser, false, true, null);
        }

        /// <summary>手机端：会员盈亏分页（今日输赢 + 总盈亏，支持排序）</summary>
        public M_EasyuiGridData<M_Users_DTO> GetMemberWinLossList(M_Page mPage, M_Users_DTO entity, M_LoginUser loginUser, string sort)
        {
            return QueryUsersPaged(mPage, entity, loginUser, false, false, sort ?? "win-most");
        }

        /// <summary>
        /// 手机端：今日玩家总输赢合计（权限范围内）
        /// </summary>
        public long GetTodayTotalWinLoss(M_LoginUser loginUser)
        {
            using (var ef = new GameDbContext())
            {
                if (loginUser != null && loginUser.UserPriv == 0)
                {
                    return ef.Database.SqlQuery<long>("SELECT CAST(IFNULL(SUM(WINLOSS),0) AS SIGNED) FROM user_daily_winloss WHERE DAY = CURDATE()").FirstOrDefault();
                }

                if (loginUser == null)
                    return 0;

                List<string> agencies = new B_Admin().GetManagedAgencyAccounts(ef, loginUser);
                if (agencies.Count < 1)
                    return 0;

                long total = 0;
                for (int i = 0; i < agencies.Count; i += 300)
                {
                    List<string> chunk = agencies.Skip(i).Take(300).ToList();
                    string placeholders = string.Join(",", chunk.Select((c, j) => "{" + j + "}"));
                    string sql = "SELECT CAST(IFNULL(SUM(w.WINLOSS),0) AS SIGNED) FROM user_daily_winloss w " +
                                 "INNER JOIN UserRelations r ON r.UserID = w.UserID " +
                                 "INNER JOIN Users u ON u.ID = r.ID " +
                                 "WHERE w.DAY = CURDATE() AND u.AGENCY IN (" + placeholders + ")";
                    total += ef.Database.SqlQuery<long>(sql, chunk.Cast<object>().ToArray()).FirstOrDefault();
                }
                return total;
            }
        }
        #endregion

        public List<M_Admin> GetTree(List<M_Admin> list1, List<M_Admin> list2, string id)
        {
            var self = list1.Where(t => t.AGENCY == id);
            if (self != null)
            {
                foreach (M_Admin admin in self)
                {
                    list2.Add(admin);
                    var child = list1.Where(t => t.AGENCY == admin.ID);
                    if(child!=null)
                    {
                        foreach (M_Admin vpdl in child)
                        {
                            list2.Add(vpdl);
                            GetTree(list1, list2, vpdl.ID);
                        }
                    }
                   
                }
            }
           
            return list2;
        }
        public M_EasyuiGridData<M_Users_DTO> GetOnlinePlayersList(M_Page mPage, M_Users_DTO entity, M_LoginUser loginUser)
        {
            M_EasyuiGridData<M_Users_DTO> list = new M_EasyuiGridData<M_Users_DTO>();
            using (var ef = new GameDbContext())
            {
                var rst = from c in ef.Users
                          join r in ef.UserRelations on c.ID equals r.ID
                          select new M_Users_DTO
                          {
                              ID = c.ID,
                              NAME = c.NAME,
                              PWD = c.PWD,
                              SAFE_PWD = c.SAFE_PWD,
                              AGENCY = c.AGENCY,
                              FROZEN = c.FROZEN,
                              COINS = c.COINS,
                              COINS_BUY = c.COINS_BUY,
                              COINS_BACK = c.COINS_BACK,
                              UserID = r.UserID,
                              TELEPHONE = c.TELEPHONE,
                              INHALL = c.INHALL,
                              GAME_SCORE = c.GAME_SCORE
                              //BuyBack=c.COINS_BUY- c.COINS_BACK
                          };
                rst = rst.Where(c => c.INHALL==true);
                if (!string.IsNullOrWhiteSpace(entity.AGENCY))
                    rst = rst.Where(c => c.AGENCY.Equals(entity.AGENCY));
                if (!string.IsNullOrWhiteSpace(entity.NAME))
                    rst = rst.Where(c => c.NAME.Equals(entity.NAME));
                if (!string.IsNullOrWhiteSpace(entity.ID))
                    rst = rst.Where(c => c.ID.Equals(entity.ID));
                if (entity.UserID > 0)
                    rst = rst.Where(c => c.UserID == entity.UserID);

                // 加权限查询
                if (loginUser.UserPriv != 0)
                {
                    List<string> agencies = new B_Admin().GetManagedAgencyAccounts(ef, loginUser);
                    rst = rst.Where(c => agencies.Contains(c.AGENCY));
                }

                // 分页
                if (rst != null)
                {
                    mPage.SetTotalCount(rst.Count());
                    var users = rst.AsEnumerable()
                        .OrderBy(c => c.UserID)
                        .Skip(mPage.PageSize * (mPage.PageIndex - 1)).Take(mPage.PageSize)
                        .ToList();
                    FillCurrentPlayInfo(ef, users);
                    ApplySensitiveFieldPermissions(users, loginUser);
                    list.rows = users;
                    list.total = mPage.TotalCount;
                }
            }
            return list;
        }

        private void FillCurrentPlayInfo(GameDbContext ef, List<M_Users_DTO> users)
        {
            if (users == null || users.Count < 1)
                return;

            List<string> onlineUserIds = users.Where(c => c.INHALL).Select(c => c.ID).Distinct().ToList();
            if (onlineUserIds.Count < 1)
                return;

            Dictionary<int, string> gameNames = ef.Games.ToDictionary(c => c.GameId, c => c.Name);

            // 每个在线玩家只取最新一条操作日志：先按 UserID 取 MAX(LID)（走 useroptlog(UserID,LID) 索引），
            // 再按 LID 回表取需要的列。禁止整表 OrderBy(LID desc) 后内存 GroupBy。
            List<long> latestIds = ef.UserOptLogs
                .Where(c => onlineUserIds.Contains(c.UserID))
                .GroupBy(c => c.UserID)
                .Select(g => g.Max(x => x.LID))
                .ToList();
            if (latestIds.Count < 1)
                return;

            Dictionary<string, M_UserOptLog> latestLogs = ef.UserOptLogs
                .Where(c => latestIds.Contains(c.LID))
                .Select(c => new M_UserOptLog
                {
                    LID = c.LID,
                    UserID = c.UserID,
                    GAME_TYPE = c.GAME_TYPE,
                    ROOM = c.ROOM,
                    TABLE_ID = c.TABLE_ID,
                    SEAT_ID = c.SEAT_ID,
                    OPT_COINS = c.OPT_COINS,
                    SCORE = c.SCORE
                })
                .ToList()
                .GroupBy(c => c.UserID)
                .ToDictionary(g => g.Key, g => g.First());

            foreach (M_Users_DTO user in users)
            {
                if (!user.INHALL)
                    continue;

                M_UserOptLog log;
                if (!latestLogs.TryGetValue(user.ID, out log) || log == null)
                    continue;

                user.CurrentGameType = log.GAME_TYPE;
                user.CurrentRoomId = log.ROOM;
                user.CurrentTableId = log.TABLE_ID;
                user.CurrentSeatId = log.SEAT_ID;
                user.CurrentBetCoins = log.OPT_COINS;
                user.CurrentWinLose = log.SCORE;

                string gameName;
                if (gameNames.TryGetValue(log.GAME_TYPE, out gameName))
                    user.CurrentGameName = gameName;
            }
        }

        private void FillTodayWinLoss(GameDbContext ef, List<M_Users_DTO> users)
        {
            if (users == null || users.Count < 1)
                return;

            List<string> userIds = users.Select(c => c.ID).Where(c => !string.IsNullOrWhiteSpace(c)).Distinct().ToList();
            if (userIds.Count < 1)
                return;

            string placeholders = string.Join(",", userIds.Select((c, i) => "{" + i + "}"));
            string sql = "SELECT UserID, WINLOSS FROM user_daily_winloss WHERE DAY = CURDATE() AND UserID IN (" + placeholders + ")";
            Dictionary<string, long> winLossMap = ef.Database.SqlQuery<M_UserDailyWinLoss>(sql, userIds.Cast<object>().ToArray())
                .ToList()
                .GroupBy(c => c.UserID)
                .ToDictionary(g => g.Key, g => g.First().WINLOSS);

            foreach (M_Users_DTO user in users)
            {
                user.TodayWinLoss = winLossMap.TryGetValue(user.ID, out long winLoss) ? winLoss : (long?)0;
            }
        }

        private void ApplySensitiveFieldPermissions(List<M_Users_DTO> users, M_LoginUser loginUser)
        {
            if (users == null || loginUser == null || loginUser.UserPriv == 0)
                return;

            foreach (M_Users_DTO user in users)
            {
                if (loginUser.IsViewPwd != 1 && loginUser.IsViewSafePwd != 1)
                    user.PWD = null;
                if (loginUser.IsViewSafePwd != 1)
                    user.SAFE_PWD = null;
            }
        }

        public List<UserDailyAccounts> GetDailyAccounts(M_Page mPage, M_Users_DTO entity, M_LoginUser loginUser)
        {
            List<UserDailyAccounts> list = new List<UserDailyAccounts>();
            DateTime sevenDaysAgo = DateTime.Now.AddDays(-7);
            using (var ef = new GameDbContext())
            {
                var rst = from c in ef.Users
                          join r in ef.ReChargeRecords on c.ID equals r.GameID
                          select new UserDailyAccounts
                          {
                              ID = c.ID,
                              NAME = c.NAME,
                              AGENCY = c.AGENCY,
                              GAMETIME = r.CreateTime,
                              PROCESSED = r.Processed,
                              RECHARGE_TYPE = r.RechargeType,
                              COIN = r.Coin,
                          };
                rst = rst.Where(c => c.PROCESSED == 1 && c.GAMETIME>= sevenDaysAgo);//只获取已经处理 和7天前的数据
                if (!string.IsNullOrWhiteSpace(entity.AGENCY))
                    rst = rst.Where(c => c.AGENCY.Equals(entity.AGENCY));
                if (!string.IsNullOrWhiteSpace(entity.NAME))
                    rst = rst.Where(c => c.NAME.Equals(entity.NAME));
                if (!string.IsNullOrWhiteSpace(entity.ID))
                    rst = rst.Where(c => c.ID.Equals(entity.ID));
    
                // 加权限查询
                if (loginUser.UserPriv != 0)
                {
                    // 查询权限范围内的代理
                    rst = rst.Where(c => c.AGENCY.Equals(loginUser.Accounts));
                }
                list = rst.ToList();
            }
            return list;
        }
        public int ResetCoin(string gameid, long? coin)
        {
            int val = 0;
            using (var ef = new GameDbContext())
            {
                try
                {
                 
                    var rst = ef.Users.Where(c => c.ID.Equals(gameid)).SingleOrDefault();
                    if (rst != null)
                    {
                        rst.COINS  += (coin ?? 0);
                        rst.COINS_BUY += coin;// 购币
                        val = ef.SaveChanges();
                    }
                }
                catch (Exception ex)
                {
                    LogHelper.WriteLog(typeof(YYT.BLL.EF.B_Users), ex);
                }
            }
            return val;
           
        }

        public int ChangeCoin(string gameid, long? coin)
        {
            int val = 0;
            using (var ef = new GameDbContext())
            {
                try
                {

                    var rst = ef.Users.Where(c => c.ID.Equals(gameid)).SingleOrDefault();
                    if (rst != null)
                    {
                        rst.COINS -= (coin ?? 0);
                        rst.COINS_BUY += coin;// 购币
                        val = ef.SaveChanges();
                    }
                }
                catch (Exception ex)
                {
                    LogHelper.WriteLog(typeof(YYT.BLL.EF.B_Users), ex);
                }
            }
            return val;

        }
        public int DelUser(M_Users entity)
        {
            int val = 0;
            using (var ef = new GameDbContext())
            {
                using (var trans = ef.Database.BeginTransaction())
                {
                    try
                    {
                        ef.Users.Attach(entity);
                        ef.Users.Remove(entity);

                        var rst = ef.UserRelations.Where(c => c.ID.Equals(entity.ID)).SingleOrDefault();
                        if (rst != null)
                            ef.UserRelations.Remove(rst);

                        val = ef.SaveChanges();

                        trans.Commit();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        LogHelper.WriteLog(typeof(YYT.BLL.EF.B_Users), ex);
                    }
                }
            }
            return val;
        }

        public int FrozenUser(M_Users entity)
        {
            using (var ef = new GameDbContext())
            {
                var usr = ef.Users.Where(c => c.ID.Equals(entity.ID)).FirstOrDefault();
                if (usr != null)
                {
                    if (usr.FROZEN.Equals(entity.FROZEN))
                        return 1;
                    usr.FROZEN = entity.FROZEN;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public int ResetSafePwd(M_Users entity)
        {
            using (var ef = new GameDbContext())
            {
                var usr = ef.Users.Where(c => c.ID.Equals(entity.ID)).FirstOrDefault();
                if (usr != null)
                {
                 
                    usr.SAFE_PWD = "123456";
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public int IsRegisterUser(M_Users entity)
        {
            using (var ef = new GameDbContext())
            {
                var usr = ef.Users.Where(c => c.ID.Equals(entity.ID)).FirstOrDefault();
                if (usr != null)
                {
                    usr.IsRegister = true;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public int UpdateCoin(string gameid, long? coin)
        {
            int val = 0;
            using (var ef = new GameDbContext())
            {
                try
                {

                    var rst = ef.Users.Where(c => c.ID.Equals(gameid)).SingleOrDefault();
                    if (rst != null)
                    {
                        rst.COINS +=coin;
                        val = ef.SaveChanges();
                    }
                }
                catch (Exception ex)
                {
                    LogHelper.WriteLog(typeof(YYT.BLL.EF.B_Users), ex);
                }
            }
            return val;

        }
        public int ChgPwd(M_Users entity)
        {
            using (var ef = new GameDbContext())
            {
                ef.Configuration.ValidateOnSaveEnabled = false;
                var usr = ef.Users.Where(c => c.ID.Equals(entity.ID)).FirstOrDefault();
                if (usr != null)
                {
                    if (string.Equals(usr.PWD, entity.PWD))
                        return 1;
                    usr.PWD = entity.PWD;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public int ChgSafePwd(M_Users entity)
        {
            using (var ef = new GameDbContext())
            {
                ef.Configuration.ValidateOnSaveEnabled = false;
                var usr = ef.Users.Where(c => c.ID.Equals(entity.ID)).FirstOrDefault();
                if (usr != null)
                {
                    if (string.Equals(usr.SAFE_PWD, entity.SAFE_PWD))
                        return 1;
                    usr.SAFE_PWD = entity.SAFE_PWD;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public int ChgGrade(M_Users entity)
        {
            using (var ef = new GameDbContext())
            {
                var usr = ef.Users.Where(c => c.ID.Equals(entity.ID)).FirstOrDefault();
                if (usr != null)
                {
                    if (usr.GRADE.Equals(entity.GRADE))
                        return 1;
                    usr.GRADE = entity.GRADE;
                    return ef.SaveChanges();
                }
            }
            return 0;
        }

        public Msg Regist(M_Users entity)
        {
            Msg msg = new Msg(0, "注册失败！");
            using (var ef = new GameDbContext())
            {
                var usr = ef.Users.Where(c => c.ID.Equals(entity.ID));
                if (usr.Count() > 0)
                {
                    msg.content = "账号重复！";
                    return msg;
                }

                var agency = ef.Admins.Where(c => c.ID.Equals(entity.AGENCY));
                if (agency.Count() < 1)
                {
                    msg.content = "未找到代理！";
                    return msg;
                }

                using (var trans = ef.Database.BeginTransaction())
                {
                    try
                    {
                        entity.PIC_INDEX = 0;
                        entity.FROZEN = 0;
                        entity.COINS = 0;
                        entity.COINS_EXP = 0;
                        entity.COINS_BUY = 0;
                        entity.COINS_BACK = 0;
                        entity.BMW_SCORE = 0;
                        entity.DICE_SCORE = 0;
                        entity.DT_SCORE = 0;
                        entity.PHENIX_SCORE = 0;
                        entity.JC_SCORE = 0;
                        entity.MAGNATE_SCORE = 0;
                        entity.FISH_COW_SCORE = 0;
                        entity.FISH_CROCODILE_SCORE = 0;
                        entity.CARD_ATT2_SCORE = 0;
                        entity.CARD_FISH_SCORE = 0;
                        entity.BET_ANIMAL_SCORE = 0;
                        entity.FISH_BIRD_SCORE = 0;
                        entity.BET_COW_SCORE = 0;
                        entity.GAME_SCORE = 0;
                        entity.SAFE_PWD = "123456";
                        entity.SAFE_COINS = 0;
                        entity.GRADE = 1;
                        ef.Users.Add(entity);

                        var identityRst = ef.UserRelations.Where(c => c.ID.Equals(entity.ID)).SingleOrDefault();
                        if (identityRst == null)
                        {
                            ef.UserRelations.Add(new M_UserRelations { ID = entity.ID });
                        }
                        ef.Configuration.ValidateOnSaveEnabled = false;
                        if (ef.SaveChanges() > 0)
                        {
                            ef.Configuration.ValidateOnSaveEnabled = true;
                            msg.code = 1;
                            msg.content = "注册成功！";
                        }

                        trans.Commit();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        LogHelper.WriteLog(typeof(YYT.BLL.EF.B_Users), ex);
                    }
                }
                return msg;
            }
        }

        public Msg Add(M_Users entity)
        {
            Msg msg = new Msg(0, "注册失败！");
            using (var ef = new GameDbContext())
            {
                var usr = ef.Users.Where(c => c.ID.Equals(entity.ID));
                if (usr.Count() > 0)
                {
                    msg.content = "账号重复！";
                    return msg;
                }

                var agency = ef.Admins.Where(c => c.ID.Equals(entity.AGENCY));
                if (agency.Count() < 1)
                {
                    msg.content = "未找到代理！";
                    return msg;
                }

                using (var trans = ef.Database.BeginTransaction())
                {
                    try
                    {
                        entity.PIC_INDEX = 0;
                        entity.FROZEN = 0;
                        entity.COINS = 0;
                        entity.COINS_EXP = 0;
                        entity.COINS_BUY = 0;
                        entity.COINS_BACK = 0;
                        entity.BMW_SCORE = 0;
                        entity.DICE_SCORE = 0;
                        entity.DT_SCORE = 0;
                        entity.PHENIX_SCORE = 0;
                        entity.JC_SCORE = 0;
                        entity.MAGNATE_SCORE = 0;
                        entity.FISH_COW_SCORE = 0;
                        entity.FISH_CROCODILE_SCORE = 0;
                        entity.CARD_ATT2_SCORE = 0;
                        entity.CARD_FISH_SCORE = 0;
                        entity.BET_ANIMAL_SCORE = 0;
                        entity.FISH_BIRD_SCORE = 0;
                        entity.BET_COW_SCORE = 0;
                        entity.GAME_SCORE = 0;
                        entity.SAFE_PWD = "123456";
                        entity.SAFE_COINS = 0;
                        entity.GRADE = 1;
                        ef.Users.Add(entity);
                        ef.Configuration.ValidateOnSaveEnabled = false;

                        if (ef.SaveChanges() > 0)
                        {

                            var identityRst = ef.UserRelations.Where(c => c.ID.Equals(entity.ID)).SingleOrDefault();
                            if (identityRst == null)
                            {
                                ef.UserRelations.Add(new M_UserRelations { ID = entity.ID });
                                if (ef.SaveChanges() > 0)
                                {
                                    msg.code = 1;
                                    msg.content = "注册成功！";
                                }
                            }
                        }

                        trans.Commit();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        LogHelper.WriteLog(typeof(YYT.BLL.EF.B_Users), ex);
                    }
                }
                return msg;
            }
        }

        public int SelectUserINHALL(string parm,string selIdType)
        {
            int val = 0;
            using (var ef = new GameDbContext())
            {
                try
                {
                    if (selIdType == "0")
                    {
                        var rst = ef.Users.Where(c => c.NAME.Equals(parm)).SingleOrDefault();
                        if (rst != null)
                        {
                            val = Convert.ToInt32(rst.INHALL);
                        }
                        
                    }
                    else
                    {
                        var rst = ef.Users.Where(c => c.ID.Equals(parm)).SingleOrDefault();
                        if (rst != null)
                        {
                            val = Convert.ToInt32(rst.INHALL);
                        }
                    }
                 
                }
                catch (Exception ex)
                {
                    LogHelper.WriteLog(typeof(YYT.BLL.EF.B_Users), ex);
                }
            }
            return val;

        }
    }
}
