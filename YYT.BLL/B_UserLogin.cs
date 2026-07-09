using System;
using System.Collections.Specialized;
using System.Data;
using System.Linq;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;

namespace YYT.BLL
{
    public class B_UserLogin : SupperBLL
    {
        //public B_UserLogin() : base(PubConstant.DbConnString) { }
        public B_UserLogin() { }

        #region 系统登录
        /// <summary>
        /// 系统登录
        /// </summary>
        /// <param name="accounts">帐号</param>
        /// <param name="password">密码</param>
        /// <param name="clientIP">客户端IP地址</param>
        /// <returns> 用户信息实体 </returns>
        public M_LoginUser Login(string accounts, string password, string clientIP)
        {
            M_LoginUser loginUser = null;
            using (var ef = new GameDbContext())
            {
                var rst = ef.Admins.Where(f => f.ID.Equals(accounts) && f.PWD.Equals(password) && f.RE_ENABLE == 1).FirstOrDefault();

                if (rst != null)
                {
                    // 日志
                    new B_AgencyOptLog().AddAgencyOptLog(ef, new M_AgencyOptLog
                    {
                        OptID = rst.ID,
                        ID = rst.ID,
                        SrcUserTitle = rst.Title,
                        DestUserTitle = rst.Title,
                        AGENCY = rst.AGENCY,
                        COINS = rst.COINS ?? 0,
                        REC_TIME = DateTime.Now,
                        OPT = 2,
                        WEEK = DateTime.Now.WeekOfYear(),
                        BEF_COINS = rst.COINS ?? 0,
                        AFT_COINS = rst.COINS ?? 0
                    });

                    loginUser = rst.ToLoginUser();
                    loginUser.LoginResult = 1;
                    loginUser.UserID = 999;
                    loginUser.Remark = rst.ID;
                    loginUser.LoginMsg = "登录成功！";
                    loginUser.IsFrozen = rst.IsFrozen;
                    loginUser.IsProbability = rst.IsProbability;
                    loginUser.IsKicking = rst.IsKicking;
                    loginUser.IsDelete = rst.IsDelete;
                    return loginUser;
                }
            }
            loginUser = new M_Admin().ToLoginUser();
            loginUser.UserPriv = loginUser.UserType = -1;
            loginUser.RE_ENABLE = 0;
            loginUser.Accounts = loginUser.UserName = accounts;
            
            return loginUser;
        }
        #endregion

        #region 修改密码
        /// <summary>
        /// 修改密码
        /// </summary>
        /// <param name="userType"></param>
        /// <param name="accounts"></param>
        /// <param name="oldPwd"></param>
        /// <param name="newPwd"></param>
        /// <param name="clientIP"></param>
        /// <returns></returns>
        public Msg ResetPwd(int userType, string accounts, string oldPwd, string newPwd, string clientIP)
        {
            Msg msg = new Msg(0, "重置密码");
            try
            {
                using (var ef = new GameDbContext())
                {
                    ef.Configuration.ValidateOnSaveEnabled = false;
                    var rst = ef.Admins.Where(c => c.ID.Equals(accounts) && c.PWD.Equals(oldPwd)).FirstOrDefault();
                    if (rst != null)
                    {
                        rst.PWD = newPwd;
                        int val = ef.SaveChanges();
                        if (val > 0)
                        {
                            msg.code = 1;
                            msg.content = "修改成功！";
                        }
                    }
                    else
                    {
                        msg.content = "旧密码不正确！";
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                Dispose();
            }
            return msg;
        }
        #endregion

        #region 获取登录日志
        /// <summary>
        /// 获取登录日志
        /// </summary>
        /// <param name="kv">查询参数</param>
        /// <returns></returns>
        public M_EasyuiGridData<M_Base_AdminLog> GetLoginLog(NameValueCollection kv)
        {
            return null;

            //try
            //{
            //    List<DbParameter> paraList = new List<DbParameter>();
            //    foreach (var key in kv)
            //        paraList.Add(db.CreateDbParam("@" + key.ToString(), kv[key.ToString()]));
            //    paraList.Add(db.CreateDbParam("@TotalCount", ParameterDirection.Output, null, 4, DbType.Int32));

            //    List<M_Base_AdminLog> list = db.QueryForList<M_Base_AdminLog>("PRC_Get_LoginLog_List", paraList, CommandType.StoredProcedure);

            //    //获取查询结果
            //    int totalCount = 0;
            //    foreach (DbParameter param in paraList)
            //    {
            //        if (param.ParameterName.EndsWith("TotalCount") && param.Value != DBNull.Value)
            //        {
            //            Int32.TryParse(param.Value.ToString(), out totalCount);
            //            break;
            //        }
            //    }

            //    M_EasyuiGridData<M_Base_AdminLog> jsonClass = new M_EasyuiGridData<M_Base_AdminLog>();
            //    jsonClass.total = totalCount;
            //    jsonClass.rows = list;

            //    return jsonClass;
            //}
            //catch (Exception ex)
            //{
            //    throw ex;
            //}
            //finally
            //{
            //    Dispose();
            //}
        }
        #endregion
    }
}
