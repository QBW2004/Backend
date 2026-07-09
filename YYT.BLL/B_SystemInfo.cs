using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Data;
using System.Data.Common;
using System.Text;
using YYT.Entity;

namespace YYT.BLL
{
    public class B_SystemInfo : SupperBLL
    {
        public B_SystemInfo() : base(PubConstant.DbConnString) { }

        #region 获取菜单列表
        /// <summary>
        /// 获取菜单列表
        /// </summary>
        /// <param name="userID">用户ID</param>
        /// <returns></returns>
        public List<M_BaseModule> GetMenus(int userID)
        {
            try
            {
                List<DbParameter> paraList = new List<DbParameter>
                {
                    db.CreateDbParam("@UserID",userID)
                };

                return db.QueryForList<M_BaseModule>("PRC_Get_Menus", paraList, CommandType.StoredProcedure);
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                Dispose();
            }
        }
        #endregion

        #region 获取角色菜单列表
        /// <summary>
        /// 获取角色菜单列表
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="roleId"></param>
        /// <param name="menuTitle"></param>
        /// <returns></returns>
        public List<T> GetRoleMenus<T>(int? roleId = null, string menuTitle = null) where T : new()
        {
            try
            {
                List<DbParameter> paraList = new List<DbParameter>
                {
                    db.CreateDbParam("@RoleID",roleId),
                    db.CreateDbParam("@MenuTitle",menuTitle)
                };
                return db.QueryForList<T>("PRC_Get_RoleMenus", paraList, CommandType.StoredProcedure);
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                Dispose();
            }
        }
        #endregion

        #region 角色相关
        /// <summary>
        /// 设置角色菜单
        /// </summary>
        /// <param name="roleID">角色ID</param>
        /// <param name="id">菜单ID</param>
        /// <param name="isSet">0取消  1配置</param>
        /// <returns></returns>
        public Msg SetRoleMenus(int roleID, int id, int isSet)
        {
            try
            {
                List<DbParameter> paraList = new List<DbParameter>
                {
                    db.CreateDbParam("@RoleID",roleID),
                    db.CreateDbParam("@ModuleID",id),
                    db.CreateDbParam("@IsSet",isSet)
                };
                return RunProcGetMsg("PRC_Set_RoleMenus", paraList);
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                Dispose();
            }
        }

        /// <summary>
        /// 添加角色
        /// </summary>
        /// <param name="roleName"></param>
        /// <returns></returns>
        public Msg AddRole(string roleName)
        {
            try
            {
                List<DbParameter> paraList = new List<DbParameter>()
                {
                    db.CreateDbParam("@RoleName",roleName,DbType.String)
                };
                return RunProcGetMsg("PRC_Add_Role", paraList);
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                Dispose();
            }
        }

        /// <summary>
        /// 获取角色列表
        /// </summary>
        /// <returns></returns>
        public List<M_Roles> GetRoles(NameValueCollection kv)
        {
            try
            {
                List<DbParameter> paraList = new List<DbParameter>();

                StringBuilder sql = new StringBuilder();
                sql.AppendLine("SELECT * ")
                    .AppendLine("FROM `Base_AdminRole` ")
                    .AppendLine("WHERE 1=1 ");

                if (kv.Count > 0)
                {
                    foreach (var key in kv)
                    {
                        if (!string.IsNullOrWhiteSpace(kv[key.ToString()]))
                        {
                            paraList.Add(db.CreateDbParam("@" + key.ToString(), "%" + kv[key.ToString()] + "%"));
                            sql.AppendLine(" AND " + key.ToString() + " LIKE @" + key.ToString());
                        }
                    }
                }
                sql.Append(";");

                return db.QueryForList<M_Roles>(sql.ToString(), paraList);
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                Dispose();
            }
        }

        /// <summary>
        /// 获取角色列表
        /// </summary>
        /// <returns></returns>
        public M_EasyuiGridData<M_Roles> GetGridRoles(NameValueCollection kv)
        {
            List<M_Roles> list = GetRoles(kv);
            M_EasyuiGridData<M_Roles> jsonClass = new M_EasyuiGridData<M_Roles>();
            jsonClass.total = list.Count;
            jsonClass.rows = list;
            return jsonClass;
        }

        /// <summary>
        /// 统计角色中用户数
        /// </summary>
        /// <param name="roleID"></param>
        /// <returns></returns>
        public int GetRoleUserCount(int roleID)
        {
            int usrCount = 0;
            try
            {
                List<DbParameter> paraList = new List<DbParameter>()
                {
                    db.CreateDbParam("@RoleID", roleID, DbType.Int32)
                };

                usrCount = db.ExecuteScalar<int>("SELECT COUNT(`UserID`) AS Cnt FROM `Base_AdminRoleRelation` WHERE `RoleID` = @RoleID;", paraList, CommandType.Text);
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                Dispose();
            }
            return usrCount;
        }

        /// <summary>
        /// 删除角色
        /// </summary>
        /// <param name="roleID"></param>
        /// <returns></returns>
        public Msg DelRole(int roleID)
        {
            try
            {
                int usrCount = GetRoleUserCount(roleID);
                if (usrCount > 0)
                    return new Msg(0, "该角色中有用户存在，不能删除。");

                List<DbParameter> paraList = new List<DbParameter>()
                {
                    db.CreateDbParam("@RoleID", roleID, DbType.Int32)
                };
                int val = db.ExecuteNonQuery("DELETE FROM `Base_AdminRole` WHERE `RoleID` = @RoleID;DELETE FROM `Base_AdminRolePermission` WHERE `RoleID` = @RoleID;DELETE from `Base_AdminRoleRelation` WHERE `RoleID` = @RoleID;", paraList);

                if (val > 0)
                    return new Msg(1, "删除成功");

                return new Msg(0, "删除失败");
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                Dispose();
            }
        }

        /// <summary>
        /// 设置角色用户
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="roleId">角色ID</param>
        /// <param name="isSet">0取消  1设置</param>
        /// <returns></returns>
        public Msg SetUserRole(long userId, int roleId, int isSet)
        {
            try
            {
                List<DbParameter> paraList = new List<DbParameter>()
                {
                    db.CreateDbParam("@UserID", userId, DbType.Int64),
                    db.CreateDbParam("@RoleID", roleId, DbType.Int32),
                    db.CreateDbParam("@IsSet", isSet, DbType.Int32)
                };
                return RunProcGetMsg("PRC_Set_UserRole", paraList);
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                Dispose();
            }
        }
        #endregion

        #region 获取登录信息
        /// <summary>
        /// 获取登录信息
        /// </summary>
        /// <param name="Accounts">帐号</param>
        /// <returns></returns>
        public DataTable GetHomePageInfo(string Accounts)
        {
            try
            {
                return RunProcGetTable("PRC_Get_HomePageInfo", new List<DbParameter> { db.CreateDbParam("@Accounts", Accounts) });
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                Dispose();
            }
        }
        #endregion

        #region 后台用户相关

        /// <summary>
        /// 获取用户列表
        /// </summary>
        /// <param name="kv"></param>
        /// <returns></returns>
        public M_EasyuiGridData<M_MgrUsers> GetMgrUsersList(NameValueCollection kv)
        {
            try
            {
                List<DbParameter> paraList = new List<DbParameter>()
                {
                    db.CreateDbParam("@UserName",kv["usrNameOrAccounts"]),
                    db.CreateDbParam("@Accounts",kv["usrNameOrAccounts"]),
                    db.CreateDbParam("@RoleID",kv["RoleID"])
                };
                List<M_MgrUsers> list = db.QueryForList<M_MgrUsers>("PRC_Get_Users", paraList, CommandType.StoredProcedure);

                M_EasyuiGridData<M_MgrUsers> jsonClass = new M_EasyuiGridData<M_MgrUsers>();
                jsonClass.total = list.Count;
                jsonClass.rows = list;

                return jsonClass;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                Dispose();
            }
        }

        /// <summary>
        /// 删除用户
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns></returns>
        public Msg DelMgrUser(long userId)
        {
            try
            {
                List<DbParameter> paraList = new List<DbParameter>()
                {
                    db.CreateDbParam("@UserID", userId, DbType.Int64)
                };

                StringBuilder sql = new StringBuilder();
                sql.AppendLine("DELETE FROM `Base_AdminUser` WHERE `UserID` = @UserID;")
                    .AppendLine("DELETE FROM `Base_AdminRoleRelation` WHERE `UserID` = @UserID;");

                int val = db.ExecuteNonQuery(sql.ToString(), paraList, CommandType.Text);

                if (val > 0)
                    return new Msg(1, "删除成功");

                return new Msg(0, "删除失败");
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                Dispose();
            }
        }

        /// <summary>
        /// 添加或编辑用户
        /// </summary>
        /// <param name="userID">用户ID</param>
        /// <param name="roleId">角色ID</param>
        /// <param name="uname">用户名字</param>
        /// <param name="upwd">密码</param>
        /// <param name="isDel">0正常  1标识删除</param>
        /// <param name="remark">备注</param>
        /// <returns></returns>
        public Msg EditMgrUser(long userID, int roleId, string uname, string upwd, int isDel, string remark)
        {
            try
            {
                List<DbParameter> paraList = new List<DbParameter>()
                {
                    db.CreateDbParam("@UserID", userID, DbType.Int32),
                    db.CreateDbParam("@RoleID", roleId, DbType.Int32),
                    db.CreateDbParam("@UserName", uname, DbType.String),
                    db.CreateDbParam("@LoginPassword", upwd, DbType.AnsiString),
                    db.CreateDbParam("@IsDel", isDel, DbType.Int32),
                    db.CreateDbParam("@Remark", remark, DbType.String)
                };

                return RunProcGetMsg("PRC_Edit_Users", paraList);
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                Dispose();
            }
        }

        /// <summary>
        /// 添加后台管理用户
        /// </summary>
        /// <param name="roleID">角色</param>
        /// <param name="uname">用户名</param>
        /// <param name="accouns">账号</param>
        /// <param name="upwd">密码</param>
        /// <param name="remark">备注</param>
        /// <returns></returns>
        public Msg AddMgrUser(int roleID, string uname, string accouns, string upwd, string remark)
        {
            try
            {
                List<DbParameter> paraList = new List<DbParameter>()
                {
                    db.CreateDbParam("@RoleID", roleID, DbType.Int32),
                    db.CreateDbParam("@UserName", uname, DbType.String),
                    db.CreateDbParam("@Accounts", accouns, DbType.AnsiString),
                    db.CreateDbParam("@LoginPassword", upwd, DbType.AnsiString),
                    db.CreateDbParam("@Remark", remark, DbType.String)
                };

                return RunProcGetMsg("PRC_Add_User", paraList);
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                Dispose();
            }
        }

        #endregion
    }
}
