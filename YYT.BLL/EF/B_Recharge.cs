using System;
using System.Collections.Generic;
using System.Data.Entity.Infrastructure;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using YYT.Common;
using YYT.Entity;
using YYT.BLL.Services.GameServer;

namespace YYT.BLL.EF
{

    public class B_ReChargeBase
    {
        /// <summary>
        /// 充值人实体
        /// </summary>
        protected M_Admin SrcUser { get; set; }
        /// <summary>
        /// 被充目标实体
        /// </summary>
        protected dynamic DestUser { get; set; }
        /// <summary>
        /// 充值数据实体
        /// </summary>
        protected M_Recharge ReChargeDataEntity { get; set; }
        /// <summary>
        /// 操作类型
        /// <para>0：充值</para>
        /// <para>1：兑换</para>
        /// <para>2：赠送</para>
        /// </summary>
        protected int OptType { get; set; }
        /// <summary>
        /// 操作类型文本
        /// </summary>
        protected string OptStr { get; set; }
        /// <summary>
        /// 结果消息
        /// </summary>
        protected Msg _msg { get; set; }
        /// <summary>
        /// 充值/兑换前金币
        /// </summary>
        protected long BeforCoins { get; set; }
        /// <summary>
        /// 充值/兑换后金币
        /// </summary>
        protected long AfterCoins { get; set; }
        /// <summary>
        /// 日志信息
        /// </summary>
        protected StringBuilder DebugLog { get; set; }
        /// <summary>
        /// 调试开关
        /// </summary>
        protected bool Debug { get; private set; }
        public bool IsRMB { get; set; }
        public int ExchangeRate { get; set; }
        protected IGameServerClient GameServerClient { get; set; }



        private B_ReChargeBase() { }
        /// <summary>
        /// 充值基类
        /// </summary>
        /// <param name="rechargeUser">充值人</param>
        /// <param name="rechargeTarget">待充值人</param>
        public B_ReChargeBase(M_Admin rechargeUser, M_Recharge rechargeTarget)
        {
            this.SrcUser = rechargeUser;
            this.ReChargeDataEntity = rechargeTarget;
            this.OptType = this.ReChargeDataEntity.RechargeType;
            _msg = new Msg(0, "操作失败！");
            this.DebugLog = new StringBuilder();
            this.Debug = (ConfigHelper.GetInt("logSwitch") == 1);
            this.IsRMB = ConfigHelper.Get("IsRMB").Equals("1");
            this.ExchangeRate = ConfigHelper.GetInt("ExchangeRate");
            this.GameServerClient = new PipeGameServerClient();
        }



        /// <summary>
        /// 获取充值对象实体
        /// </summary>
        /// <returns></returns>
        protected virtual M_Admin GetReChargeUser()
        {
            M_Admin entity = null;
            using (var ef = new GameDbContext())
            {
                // 充值人
                entity = ef.Admins.Where(c => c.ID.Equals(this.SrcUser.ID)).SingleOrDefault();

            }
            return entity;
        }
        /// <summary>
        /// 获取被充值对象实体
        /// </summary>
        /// <returns></returns>
        protected virtual dynamic GetReChargeDest()
        {
            using (var ef = new GameDbContext())
            {
                if (this.ReChargeDataEntity.AdminType == EAdminType.None)
                {
                    // 玩家信息查询
                    IQueryable<M_Users> rst = null;
                    // 默认 0通过账号方式充值 1通过ID方式充值
                    if (EIDType.UserID == this.ReChargeDataEntity.IDType)
                    {
                        // 用户平台唯一标识查找用户信息
                        int userId = Convert.ToInt32(this.ReChargeDataEntity.ID);
                        rst = (from c in ef.Users
                               join r in ef.UserRelations on c.ID equals r.ID
                               where r.UserID == userId
                               select c);
                    }
                    else
                    {
                        // 用用户账号来查找用户信息
                        rst = ef.Users.Where(c => c.ID.Equals(this.ReChargeDataEntity.ID));
                    }

                    // 检查归属代理
                    if (this.SrcUser.PRIV != 0)
                    {
                        List<string> agencies = new B_Admin().GetManagedAgencyAccounts(ef, this.SrcUser.ToLoginUser());
                        return rst.Where(c => agencies.Contains(c.AGENCY)).FirstOrDefault();
                    }
                    else
                    {
                        return rst.SingleOrDefault();
                    }

                   
                }
                else
                {
                    // 代理信息查询
                    if (this.SrcUser.PRIV == 0)
                    {
                        return ef.Admins.Where(c => c.ID.Equals(this.ReChargeDataEntity.ID)).SingleOrDefault();
                    }
                    else
                    {
                        List<string> agencies = new B_Admin().GetManagedAgencyAccounts(ef, this.SrcUser.ToLoginUser());
                        return ef.Admins.Where(c => c.ID.Equals(this.ReChargeDataEntity.ID) && agencies.Contains(c.ID)).SingleOrDefault();
                    }
                }
            }
        }
        public List<M_Admin> GetTree(List<M_Admin> list1, List<M_Admin> list2, string id)
        {
            var self = list1.Where(t => t.AGENCY == id);
            if (self != null)
            {
                foreach (M_Admin admin in self)
                {
                    list2.Add(admin);
                    var child = list1.Where(t => t.AGENCY == admin.ID);
                    if (child != null)
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
      
        /// <summary>
        /// 验证充值和被充值对象 
        /// </summary>
        /// <returns></returns>
        protected bool IsValidated()
        {
            if (this.ReChargeDataEntity.Coin <= 0)
            {
                _msg.code = 0;
                _msg.content = "操作金额必须大于0。";
                return false;
            }

            if (this.ReChargeDataEntity.RechargeType == 0)
            {
                // 充值
                this.OptStr = "充值";
            }
            else if (this.ReChargeDataEntity.RechargeType == 2)
            {
                // 充值
                this.OptStr = "赠送";
            }
            else
            {
                // 兑换
                this.OptStr = "兑换";
            }
            // 充值对象
            this.SrcUser = this.GetReChargeUser();
            if (this.SrcUser == null)
            {
                _msg.code = 0;
                _msg.content = "充值人信息错误。";
                return false;
            }
            else
            {
                if (this.SrcUser.RE_ENABLE != 1)
                {
                    _msg.code = 0;
                    _msg.content = "本帐号充值功能已被锁定。";
                    return false;
                }
            }

            // 被充值对象
            this.DestUser = this.GetReChargeDest();
            if (this.DestUser == null)
            {
                _msg.code = 0;
                _msg.content = $"{this.ReChargeDataEntity.Title}不存在 或者 该用户不在你的权限范围内！";
                return false;
            }
            else
            {
                this.DestUser.COINS = this.DestUser.COINS ?? 0;
                this.DestUser.COINS_BUY = this.DestUser.COINS_BUY ?? 0;
                this.DestUser.COINS_BACK = this.DestUser.COINS_BACK ?? 0;

                // 非管理检查余额
                if (this.SrcUser.PRIV != 0)
                {
                    if (this.OptType == 0 && this.SrcUser.COINS < this.ReChargeDataEntity.Coin)
                    {
                        _msg.code = 0;
                        _msg.content = $"账户余额不足，不能为{this.DestUser.ID}{this.OptStr}。";
                        return false;
                    }
                }

                // 兑换余额检查
                if ((this.OptType == 1 || this.OptType == 3) && this.DestUser.COINS < this.ReChargeDataEntity.Coin)
                {
                    _msg.code = 0;
                    _msg.content = $"“{this.DestUser.ID}”账户余额不足，不能{this.OptStr}。";
                    return false;
                }

                this.AfterCoins = this.DestUser.COINS;// 充值前币数
                this.BeforCoins = this.DestUser.COINS;// 充值后币数

                _msg.code = 1;
                _msg.content = "OK";
            }
            return true;
        }



        /// <summary>
        /// 充值
        /// </summary>
        /// <param name="ef"></param>
        protected virtual void ReCharge(GameDbContext ef)
        {
            // 充值
            this.AfterCoins += (this.ReChargeDataEntity.Coin ?? 0);

            // 充值账号
            if (this.SrcUser.PRIV != 0)
                this.SrcUser.COINS -= this.ReChargeDataEntity.Coin;
            this.SrcUser.RECHARGE += this.ReChargeDataEntity.Coin;// 充值币数
            ef.Admins.Attach(this.SrcUser);
            if (this.SrcUser.PRIV != 0)
                ef.Entry<M_Admin>(this.SrcUser).Property(c => c.COINS).IsModified = true;
            ef.Entry<M_Admin>(this.SrcUser).Property(c => c.RECHARGE).IsModified = true;

            // 被充账号
            this.DestUser.COINS = this.AfterCoins;                  // 当前币【注意：这里不累加了，上面(见该函数内第一行)已经加过了！！！！】
            this.DestUser.COINS_BUY += this.ReChargeDataEntity.Coin;// 购币
            if (this.ReChargeDataEntity.AdminType != EAdminType.None)
            {
                // 给代理充
                ef.Admins.Attach(this.DestUser);
                DbEntityEntry<M_Admin> destUserEntry = ef.Entry<M_Admin>(this.DestUser);
                destUserEntry.Property(c => c.COINS).IsModified = true;
                destUserEntry.Property(c => c.COINS_BUY).IsModified = true;
            }
            else
            {
                // 给用户充
                ef.Users.Attach(this.DestUser);
                DbEntityEntry<M_Users> destUserEntry = ef.Entry<M_Users>(this.DestUser);
                destUserEntry.Property(c => c.COINS).IsModified = true;
                destUserEntry.Property(c => c.COINS_BUY).IsModified = true;
            }
        }

        public virtual void ReCharePay(GameDbContext ef)
        {
            this.AfterCoins += (this.ReChargeDataEntity.Coin ?? 0);
            // 充值账号
            if (this.SrcUser.PRIV != 0)
                this.SrcUser.COINS -= this.ReChargeDataEntity.Coin;
            this.SrcUser.RECHARGE += this.ReChargeDataEntity.Coin;// 充值币数
            ef.Admins.Attach(this.SrcUser);
            if (this.SrcUser.PRIV != 0)
                ef.Entry<M_Admin>(this.SrcUser).Property(c => c.COINS).IsModified = true;
            ef.Entry<M_Admin>(this.SrcUser).Property(c => c.RECHARGE).IsModified = true;

            // 被充账号
            this.DestUser.COINS = this.AfterCoins;                  // 当前币【注意：这里不累加了，上面(见该函数内第一行)已经加过了！！！！】
            this.DestUser.COINS_BUY += this.ReChargeDataEntity.Coin;// 购币
                                                                    // 给用户充
            ef.Users.Attach(this.DestUser);
            DbEntityEntry<M_Users> destUserEntry = ef.Entry<M_Users>(this.DestUser);
            destUserEntry.Property(c => c.COINS).IsModified = true;
            destUserEntry.Property(c => c.COINS_BUY).IsModified = true;
        }
        /// <summary>
        /// 兑换
        /// </summary>
        /// <param name="ef"></param>
        protected virtual void ExChange(GameDbContext ef)
        {
            // 兑换
            this.AfterCoins -= (this.ReChargeDataEntity.Coin ?? 0);
            if (this.AfterCoins < 0)
                throw new Exception("Err，余额不足！");

            // 充值账号
            if (this.SrcUser.PRIV != 0)
                this.SrcUser.COINS += this.ReChargeDataEntity.Coin;
            this.SrcUser.EXCHANGE += this.ReChargeDataEntity.Coin;// 充值人兑换币数
            ef.Admins.Attach(this.SrcUser);
            if (this.SrcUser.PRIV != 0)
                ef.Entry<M_Admin>(this.SrcUser).Property(c => c.COINS).IsModified = true;
            ef.Entry<M_Admin>(this.SrcUser).Property(c => c.EXCHANGE).IsModified = true;

            // 被充账号
            this.DestUser.COINS = this.AfterCoins;
            this.DestUser.COINS_BACK += this.ReChargeDataEntity.Coin;// 总币
            if (this.ReChargeDataEntity.AdminType != EAdminType.None)
            {
                // 给代理、副管兑换
                ef.Admins.Attach(this.DestUser);
                DbEntityEntry<M_Admin> destUserEntry = ef.Entry<M_Admin>(this.DestUser);
                destUserEntry.Property(c => c.COINS).IsModified = true;
                destUserEntry.Property(c => c.COINS_BACK).IsModified = true;
            }
            else
            {
                // 给用户兑换
                ef.Users.Attach(this.DestUser);
                DbEntityEntry<M_Users> destUserEntry = ef.Entry<M_Users>(this.DestUser);
                destUserEntry.Property(c => c.COINS).IsModified = true;
                destUserEntry.Property(c => c.COINS_BACK).IsModified = true;
            }
        }



        /// <summary>
        /// 设置结果消息
        /// </summary>
        /// <param name="rstVal"></param>
        protected virtual void SetResultMsg(int rstVal)
        {
            _msg.code = (rstVal > 0 ? 1 : 0);
            if (_msg.code > 0)
            {
                //  消息示例：
                //      {充值}成功！已向{用户}{充值}{100}个金币。{充值}前{10}，{充值}后：{110}。
                //      {兑换}成功！已向{代理}{兑换}{50}个金币。{兑换}前{100}，{兑换}后：{150}。

                StringBuilder sb = new StringBuilder();
                sb.Append($"{this.OptStr}成功！已向");
                sb.Append(this.ReChargeDataEntity.Title);
                sb.Append(this.DestUser.ID);
                sb.Append(this.OptStr);
                sb.AppendFormat("{0:F}", ResolverCoin(this.ReChargeDataEntity.Coin));
                sb.Append(" 。");
                sb.Append(this.OptStr);
                sb.Append("前：");
                sb.AppendFormat("{0:F}", ResolverCoin(this.BeforCoins));
                sb.Append("，");
                sb.Append(this.OptStr);
                sb.Append("后：");
                sb.AppendFormat("{0:F}", ResolverCoin(this.AfterCoins));
                sb.Append("。");

                _msg.content = sb.ToString();
            }
            else
            {
                _msg.content = $"{this.OptStr}失败！";
            }
        }
        protected dynamic ResolverCoin(long? coins)
        {
            if (this.IsRMB == true && coins.HasValue)
            {
                return coins.Value / this.ExchangeRate;
            }
            return coins;
        }


        /// <summary>
        /// 给代理充值
        /// </summary>
        /// <returns></returns>
        public virtual Msg AgencyReCharge()
        {
            if (!(this.IsValidated()))
                return this._msg;

            int rstVal = 0;

            using (var ef = new GameDbContext())
            {
                ef.Configuration.ValidateOnSaveEnabled = false;
                using (var trans = ef.Database.BeginTransaction())
                {
                    try
                    {
                        if (this.ReChargeDataEntity.RechargeType == 0)
                            this.ReCharge(ef);// 充值
                        else
                            this.ExChange(ef);// 兑换

                        B_Records_MySQL.CleanupExpiredRecords(ef);

                        // 添加代理日志
                        AddAgentOptLog(ef);

                        // 向充值记录中添加数据
                        AddReChargeRecords(ef);

                        // 保存
                        rstVal = ef.SaveChanges();

                        // 提交事务
                        trans.Commit();

                        // 获取结果消息
                        this.SetResultMsg(rstVal);
                    }
                    catch (Exception ex)
                    {
                        // 回滚事务
                        trans.Rollback();
                        LogHelper.WriteLog(typeof(YYT.BLL.EF.B_ReChargeBase), ex);
                    }
                }
            }

            return this._msg;
        }
        /// <summary>
        /// 给用户充值、兑换
        /// </summary>
        /// <returns></returns>
        public virtual Msg PlayerReCharge()
        {
            int rstVal = 0;

            Msg tmpMsg;
            string srvCode = "";

            bool chekRst = this.IsValidated();
            if(chekRst == false)
                return this._msg;

            // 发送锁定用户指令
            tmpMsg = LockUser();
            AppendDebugLog($"\n Lock User >> SrvCode:[{tmpMsg?.datas}] ");
            if (tmpMsg.code == 1 && chekRst == true)
            {
                using (var ef = new GameDbContext())
                {
                    ef.Configuration.ValidateOnSaveEnabled = false;
                    using (var trans = ef.Database.BeginTransaction())
                    {
                        try
                        {
                            if (this.ReChargeDataEntity.RechargeType == 0)
                            {
                                // 充值
                                this.OptStr = "充值";
                                this.ReCharge(ef);
                            }else if (this.ReChargeDataEntity.RechargeType == 2)
                            {
                                // 充值
                                this.OptStr = "赠送";
                                this.ReCharge(ef);
                            }
                            else if (this.ReChargeDataEntity.RechargeType == 3)
                            {
                                // 充值
                                this.OptStr = "扣币";
                                this.ExChange(ef);
                            }
                            else
                            {
                                // 兑换
                                this.OptStr = "兑换";
                                this.ExChange(ef);
                            }
                            B_Records_MySQL.CleanupExpiredRecords(ef);
                            // 添加代理日志
                            AddAgentOptLog(ef);

                            // 向充值记录中添加数据
                            AddReChargeRecords(ef);

                            // 保存
                            rstVal = ef.SaveChanges();

                            // 提交事务
                            trans.Commit();

                            // 解锁用户
                            if (rstVal > 0)
                                srvCode = UnLockUser(UnLockOptType.Success);
                            else
                                srvCode = UnLockUser(UnLockOptType.Error);


                            AppendDebugLog($" Request >>（ID:{this.SrcUser.ID}）{this.OptStr} => （ID:{this.DestUser.ID},Coins:{this.ReChargeDataEntity.Coin}） ");
                            AppendDebugLog($" Commit >> BeforCoins:{this.BeforCoins},AfterCoins:{this.AfterCoins}");

                            // 获取结果消息
                            this.SetResultMsg(rstVal);
                        }
                        catch (Exception ex)
                        {
                            // 回滚事务
                            trans.Rollback();

                            // 解锁用户
                            srvCode = UnLockUser(UnLockOptType.Error);

                            AppendDebugLog($" Exception，Rollback >> \r\n {ex.Message} ");
                        }
                    }
                }
            }
            else
            {
                this._msg.code = 0;
                if (tmpMsg.code == 0)
                {
                    this._msg.content = this.OptStr + "失败！" + tmpMsg.content;
                }

                // 解锁用户
                srvCode = UnLockUser(UnLockOptType.Error);
            }

            if (!"ULOK".Equals(srvCode))
                AppendDebugLog(" Unlock command was persisted to game command outbox for retry. ");
            AppendDebugLog($" End! ");

            // 打印日志
            PrintDebugLog();

            return this._msg;
        }

        /// <summary>
        /// 管理人员点击确认处理，给用户充值
        /// </summary>
        /// <returns></returns>
        public virtual Msg PlayerReCharge1()
        {
            int rstVal = 0;

            Msg tmpMsg;
            string srvCode = "";

            bool chekRst = this.IsValidated();
            if (chekRst == false)
                return this._msg;

            // 发送锁定用户指令
            tmpMsg = LockUser();
            AppendDebugLog($"\n Lock User >> SrvCode:[{tmpMsg?.datas}] ");
            if (tmpMsg.code == 1 && chekRst == true)
            {
                using (var ef = new GameDbContext())
                {
                    ef.Configuration.ValidateOnSaveEnabled = false;
                    using (var trans = ef.Database.BeginTransaction())
                    {
                        try
                        {
                            if (this.ReChargeDataEntity.RechargeType == 0)
                            {
                                // 充值
                                this.OptStr = "充值";
                                this.ReCharge(ef);
                            }
                            else if (this.ReChargeDataEntity.RechargeType == 2)
                            {
                                // 充值
                                this.OptStr = "赠送";
                                this.ReCharge(ef);
                            }
                            else
                            {
                                // 兑换
                                this.OptStr = "兑换";
                                this.ExChange(ef);
                            }

                            B_Records_MySQL.CleanupExpiredRecords(ef);

                            // 添加代理日志
                            AddAgentOptLog(ef);
                            // 向充值记录中添加数据
                            //AddReChargeRecords(ef);

                            // 保存
                            rstVal = ef.SaveChanges();

                            // 提交事务
                            trans.Commit();

                            // 解锁用户
                            if (rstVal > 0)
                                srvCode = UnLockUser(UnLockOptType.Success);
                            else
                                srvCode = UnLockUser(UnLockOptType.Error);

                            AppendDebugLog($" Request >>（ID:{this.SrcUser.ID}）{this.OptStr} => （ID:{this.DestUser.ID},Coins:{this.ReChargeDataEntity.Coin}） ");
                            AppendDebugLog($" Commit >> BeforCoins:{this.BeforCoins},AfterCoins:{this.AfterCoins}");

                            // 获取结果消息
                            this.SetResultMsg(rstVal);
                        }
                        catch (Exception ex)
                        {
                            // 回滚事务
                            trans.Rollback();

                            // 解锁用户
                            srvCode = UnLockUser(UnLockOptType.Error);

                            AppendDebugLog($" Exception，Rollback >> \r\n {ex.Message} ");
                        }
                    }
                }
            }
            else
            {
                this._msg.code = 0;
                if (tmpMsg.code == 0)
                {
                    this._msg.content = this.OptStr + "失败！" + tmpMsg.content;
                }

                // 解锁用户
                srvCode = UnLockUser(UnLockOptType.Error);
            }

            if (!"ULOK".Equals(srvCode))
                AppendDebugLog(" Unlock command was persisted to game command outbox for retry. ");
            AppendDebugLog($" End! ");

            // 打印日志
            PrintDebugLog();

            return this._msg;
        }


        /// <summary>
        /// 锁定用户
        /// </summary>
        /// <returns></returns>
        protected Msg LockUser()
        {
            try
            {
                // 发送锁定用户指令  指令内容：LK + 玩家账号
                this.GameServerClient.LockPlayer(this.DestUser.ID);
                // 无论服务器返回任何结果，均允许充值（用户在线中也可充值）
                return new Msg(1, "OK");
            }
            catch (Exception ex)
            {
                AppendDebugLog($" LockUser Exception >> {ex.Message} ");
                // 连接异常视为服务器离线，允许继续充值
                return new Msg(1, "游戏服务器连接异常，直接充值。");
            }
        }
        /// <summary>
        /// 解锁用户
        /// </summary>
        /// <param name="val"></param>
        /// <returns></returns>
        private string UnLockUser(UnLockOptType optType)
        {
            int val = 0;// 失败
            if (optType == UnLockOptType.Success)
                val = 1;// 成功
            string srvCode = string.Empty;
            int type = this.ReChargeDataEntity.RechargeType;
            //if (type == 2)//赠送
            //{
            //    type = 0;
            //}
            //if (type == 3)//扣币
            //{
            //    type = 1;
            //}
            try
            {
                // 发送解锁用户指令  指令内容：UL + 充值0/兑换1+操作结果失败0/成功1  +充值金币数+"/"+ 玩家账号
                srvCode = this.GameServerClient.UnlockPlayer(type, val, this.ReChargeDataEntity.Coin, this.DestUser.ID);
                AppendDebugLog($" UnLock User >> SrvCode:[{srvCode}] ");
            }
            catch (Exception ex)
            {
                AppendDebugLog($" UnLock User >> {ex.Message} ");
            }
            return srvCode;
        }

        public virtual Msg QueryTargetCoins()
        {
            Msg msg = new Msg(0, "查询失败！");
            this.SrcUser = this.GetReChargeUser();
            if (this.SrcUser == null)
            {
                msg.content = "充值人信息错误。";
                return msg;
            }

            this.DestUser = this.GetReChargeDest();
            if (this.DestUser == null)
            {
                msg.content = $"{this.ReChargeDataEntity.Title}不存在 或者 该用户不在你的权限范围内！";
                return msg;
            }

            long coins = this.DestUser.COINS ?? 0;
            msg.code = 1;
            msg.content = "查询成功！";
            msg.datas = new
            {
                id = (string)this.DestUser.ID,
                title = this.ReChargeDataEntity.Title,
                coins = coins,
                displayCoins = ResolverCoin(coins)
            };
            return msg;
        }




        /// <summary>
        /// 充值记录
        /// </summary>
        private void AddReChargeRecords(GameDbContext ef)
        {
            M_ReChargeRecords entity = new M_ReChargeRecords
            {
                Coin = this.ReChargeDataEntity.Coin,
                BEF_COINS = this.BeforCoins,
                AFT_COINS = this.AfterCoins,
                CreateTime = DateTime.Now,
                GameID = this.ReChargeDataEntity.ID,
                Agency = this.DestUser.AGENCY,
                OrderNo = Guid.NewGuid().ToString().Replace("-", ""),
                PayNo = string.Empty,
                Processed = 1,
                RechargeType = (this.ReChargeDataEntity.RechargeType + 20)
            };
            var rst = ef.ReChargeRecords.Where(c => c.OrderNo.Equals(entity.OrderNo));
            if (rst == null || rst.Count() == 0)
            {
                entity.Coin = entity.Coin;
                ef.ReChargeRecords.Add(entity);
            }
        }

        /// <summary>
        /// 代理日志
        /// </summary>
        /// <param name="ef"></param>
        protected void AddAgentOptLog(GameDbContext ef)
        {
            // 日志
            M_AgencyOptLog entity = new M_AgencyOptLog
            {
                OptID = this.SrcUser.ID,
                SrcUserTitle = this.SrcUser.Title,
                ID = this.DestUser.ID,
                DestUserTitle = this.ReChargeDataEntity.Title,
                AGENCY = this.DestUser.AGENCY,
                COINS = this.ReChargeDataEntity.Coin,
                REC_TIME = DateTime.Now,
               // OPT = this.ReChargeDataEntity.RechargeType,
                OPT = (this.ReChargeDataEntity.RechargeType + 20),
                WEEK = DateTime.Now.WeekOfYear(),
                BEF_COINS = this.BeforCoins,
                AFT_COINS = this.AfterCoins
            };

            ef.AgencyOptLogs.Add(entity);


        }

        /// <summary>
        /// 调试日志
        /// </summary>
        /// <param name="str"></param>
        protected void AppendDebugLog(string str)
        {
            this.DebugLog.AppendLine(str);
        }
        /// <summary>
        /// 输出调试日志
        /// </summary>
        protected void PrintDebugLog()
        {
            if (this.Debug == true)
                LogHelper.WriteLog(typeof(YYT.BLL.EF.B_ReChargeBase), this.DebugLog.ToString());
        }
    }

    public enum UnLockOptType
    {
        Error,
        Success
    }
}
