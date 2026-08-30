using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web.Mvc;
using YYT.BLL;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Web.Filters;
using static YYT.Web.Filters.LocalizationAttribute;

namespace YYT.Web.Controllers
{
    [Localization]
    public class LoginController : BaseController
    {
        #region 登录后的首页面
        /// <summary>
        /// 登录后的首页面
        /// </summary>
        /// <returns></returns>
        [MemberAuthorize]
        public ActionResult HomePage()
        {
            //获取上次登录情况
            return View();
        }
        #endregion

        #region 系统登录
        /// <summary>
        /// 系统登录。
        /// 手机浏览器访问时自动跳转手机登录页；可用 ?view=pc / ?view=mobile 手动切换，
        /// 选择会记在 Cookie 里（30 天），之后不再自动跳转（与 Mgr/Index 同一套偏好）。
        /// </summary>
        /// <returns></returns>
        public ActionResult Index()
        {
            string view = (Request.QueryString["view"] ?? string.Empty).Trim().ToLowerInvariant();
            if (view == "pc" || view == "mobile")
            {
                SaveViewMode(view);
                if (view == "mobile")
                    return RedirectToAction("Mobile");
            }
            else if (IsMobileBrowser() && GetViewMode() != "pc")
            {
                return RedirectToAction("Mobile");
            }

            ViewBag.String1 = Resources.Language.String1;
            return View();
        }

        [WithoutLocalization]//这个函数不走Localization过滤器
        public ActionResult ChangeLanguage(String NewLang, String ReturnUrl)
        {
            if (!ReturnUrl.EndsWith("/"))
            {
                ReturnUrl += "/";
            }
            //use NewLang replace old lang,include input judgment
            if (!string.IsNullOrEmpty(ReturnUrl) && ReturnUrl.Length > 3 && ReturnUrl.StartsWith("/") && ReturnUrl.IndexOf("/", 1) > 0 && new string[] { "zh-CN", "en-US", "vi-VN" }.Contains(ReturnUrl.Substring(1, ReturnUrl.IndexOf("/", 1) - 1)))
            {
                ReturnUrl = $"/{NewLang}{ReturnUrl.Substring(ReturnUrl.IndexOf("/", 1))}";
            }
            else
            {
                ReturnUrl = $"/{NewLang}{ReturnUrl}";
            }
            return Redirect(ReturnUrl);//redirect to new url
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Index(FormCollection form)
        {
            string uname = form.Q<string>("uname", "").Trim();
            string upwd = form.Q<string>("upwd", "").Trim();

            M_LoginUser loginUser;
            bool banned;
            string errorMsg = TryLogin(uname, upwd, out loginUser, out banned);
            if (!string.IsNullOrEmpty(errorMsg))
            {
                TempData["msg"] = errorMsg;
                return View();
            }

            return RedirectToAction("Index", "Mgr");
        }

        #region 手机端登录
        /// <summary>
        /// 手机端登录页（与桌面端 /Login/Index 共用校验逻辑）。
        /// 电脑浏览器访问时弹回桌面登录页；?view=pc / ?view=mobile 可手动切换，
        /// 偏好记在 mth_view Cookie（与 /Login/Index、/Mgr/Index 同一套）。
        /// </summary>
        public ActionResult Mobile()
        {
            string view = (Request.QueryString["view"] ?? string.Empty).Trim().ToLowerInvariant();
            if (view == "pc" || view == "mobile")
            {
                SaveViewMode(view);
                if (view == "pc")
                    return Redirect(DesktopLoginUrl());
            }
            else if (GetViewMode() == "pc" || (!IsMobileBrowser() && GetViewMode() != "mobile"))
            {
                // 应去桌面端：主动选了 pc；或电脑 UA 且未选 mobile
                return Redirect(DesktopLoginUrl());
            }

            return View();
        }

        /// <summary>
        /// 桌面登录页地址。显式带上语言段，
        /// 避免 RedirectToAction 因 controller/action 是路由默认值而被省略成 /zh-CN。
        /// </summary>
        private string DesktopLoginUrl()
        {
            string lang = Convert.ToString(RouteData.Values["lang"] ?? string.Empty);
            return string.IsNullOrEmpty(lang) ? "~/Login/Index" : $"/{lang}/Login/Index";
        }

        /// <summary>
        /// 手机端登录（ajax），成功后由前端跳转 /Mobile/Home/Index
        /// </summary>
        [HttpPost]
        [ValidateAntiForgeryToken]
        [WithoutLocalization]
        public ActionResult Mobile(FormCollection form)
        {
            string uname = form.Q<string>("uname", "").Trim();
            string upwd = form.Q<string>("upwd", "").Trim();

            M_LoginUser loginUser;
            bool banned;
            string errorMsg;
            try
            {
                errorMsg = TryLogin(uname, upwd, out loginUser, out banned);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(LoginController), ex.Message + "手机端登录失败！");
                errorMsg = "登录失败。";
                banned = false;
            }

            if (!string.IsNullOrEmpty(errorMsg))
                return Json(new { code = 0, msg = errorMsg, banned = banned });

            return Json(new { code = 1, msg = "ok" });
        }
        #endregion

        #region 登录校验（桌面端 / 手机端共用）
        /// <summary>
        /// 统一登录校验：失败锁定、非法字符、数据库校验，成功时返回登录会话模型。
        /// </summary>
        /// <param name="uname">账号</param>
        /// <param name="upwd">密码</param>
        /// <param name="loginUser">成功时返回登录会话模型</param>
        /// <param name="banned">账号存在但被禁用时为 true，errorMsg 即禁用提示（封号提示），登录页需弹窗展示</param>
        /// <returns>错误消息；成功返回空字符串</returns>
        private string TryLogin(string uname, string upwd, out M_LoginUser loginUser, out bool banned)
        {
            loginUser = null;
            banned = false;
            string clientIP = WebHelper.GetClientIP();

            if (string.IsNullOrWhiteSpace(uname))
                return "请输入帐号！";
            if (string.IsNullOrWhiteSpace(upwd))
                return "请输入密码！";

            // 超管与代理一律走数据库校验（admin 表 + RE_ENABLE）。
            // 2026-08-29 移除了"账号等于 Web.config admin 键即免密登录超管"的分支——
            // 那是一个免密码后门，且站点对公网开放。
            var missBll = new B_LoginMissRecord();
            M_LoginMissRecord missEntity = missBll.GetRecord(new M_LoginMissRecord { ID = uname });
            if (missEntity == null)
            {
                missEntity = new M_LoginMissRecord { ID = uname, IPAddr = clientIP, LoginResult = 0, MissCount = 0, LoginTime = DateTime.Now };
            }
            else
            {
                if (missEntity.MissCount > 4 && (DateTime.Now - missEntity.LoginTime).TotalMinutes > 0)
                {
                    return "登录错误次数太多，请5分钟后再登录！";
                }
            }

            string regStr = "'|(select)|(drop)|(table)|(master)|(dbo\\.)|\\[|\\]|\\{|\\}";
            if (Regex.IsMatch(uname, regStr) || Regex.IsMatch(upwd, regStr))
            {
                missEntity.LoginResult = 0;
                missBll.UpadteRecord(missEntity);
                return "非法字符输入！";
            }

            //查询数据库 ,判断用户名密码是否正确
            M_LoginUser model = new B_UserLogin().Login(uname, /*DESEncrypt.Md5(upwd)*/upwd, clientIP);
            if (model != null)
            {
                if (model.LoginResult == 1)
                {
                    WebHelper.WriteSession("LoginInfo", DESEncrypt.Encrypt(model.ToString()));

                    missEntity.LoginResult = 1;
                    missBll.UpadteRecord(missEntity);

                    loginUser = model;
                    return string.Empty;
                }
                else
                {
                    LogHelper.WriteLog(typeof(LoginController), model.LoginMsg + "登录失败！");
                    missEntity.LoginResult = 0;
                    missBll.UpadteRecord(missEntity);

                    // 账号存在但被禁用：直接弹出禁用时的封号提示
                    if (model.RE_ENABLE == 0 && !string.IsNullOrWhiteSpace(model.LoginMsg))
                    {
                        banned = true;
                        return model.LoginMsg;
                    }
                    return model.LoginMsg + "登录失败！";
                }
            }
            else
            {
                missEntity.LoginResult = 0;
                missBll.UpadteRecord(missEntity);
                return "登录失败！";
            }
        }
        #endregion
        #endregion

        #region 检查登录
        /// <summary>
        /// 检查登录
        /// </summary>
        /// <returns></returns>
        public ActionResult CheckLogin()
        {
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser != null && loginUser.UserID > 0 && loginUser.IsDel == 0)
                    return Json(new { code = (int)EServerData.Success, msg = "ok" });
                else
                    return Content(TipMsg.MSG_LOGIN_TIMEOUT);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(LoginController), ex);
            }
            return Content(TipMsg.MSG_ERR_OPERATE);
        }
        #endregion

        #region 退出登录
        /// <summary>
        /// 退出登录
        /// </summary>
        /// <returns></returns>
        public ActionResult LoginOut()
        {
            try
            {
                AddAgencyLog();

                WebHelper.RemoveLogin();
                Session.Abandon();
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Controllers.LoginController), ex);
            }

            return View("Index");
        }

        private static void AddAgencyLog()
        {
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser != null)
                {
                    var rst = new B_Admin().GetSingle(new M_Admin { ID = loginUser.Accounts });
                    if (rst != null)
                    {
                        // 日志
                        new B_AgencyOptLog().AddAgencyOptLog(new M_AgencyOptLog
                        {
                            ID = rst.ID,
                            OptID = rst.ID,
                            SrcUserTitle = rst.Title,
                            DestUserTitle = rst.Title,
                            AGENCY = rst.AGENCY,
                            COINS = rst.COINS,
                            REC_TIME = DateTime.Now,
                            OPT = 3,
                            WEEK = DateTime.Now.WeekOfYear(),
                            BEF_COINS = rst.COINS,
                            AFT_COINS = rst.COINS
                        });
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Controllers.LoginController), ex);
            }
        }
        #endregion

        #region 重置密码
        /// <summary>
        /// 重置密码
        /// </summary>
        /// <returns></returns>
        [MemberAuthorize]
        public ActionResult ResetPwd()
        {
            return View();
        }
        /// <summary>
        /// 重置密码
        /// </summary>
        /// <returns></returns>
        [MemberAuthorize]
        [HttpPost]
        [ValidateAntiForgeryToken]
        [WithoutLocalization]
        public ActionResult ResetPwd(FormCollection form)
        {
            try
            {
                M_LoginUser model = WebHelper.GetLoginInfo();
                if (model != null)
                {
                    string oldPwd = form.Q<string>("OldPwd", "").Trim();
                    string newPwd = form.Q<string>("NewPwd", "").Trim();
                    string rePwd = form.Q<string>("RePwd", "").Trim();

                    if (String.IsNullOrWhiteSpace(oldPwd))
                        return Json(new { code = 0, msg = "请输入原始密码！" });
                    if (String.IsNullOrWhiteSpace(newPwd))
                        return Json(new { code = 0, msg = "请输入新密码！" });
                    if (String.IsNullOrWhiteSpace(rePwd))
                        return Json(new { code = 0, msg = "请输入确认密码！" });
                    if (!newPwd.Equals(rePwd))
                        return Json(new { code = 0, msg = "请输入新密码与确认密码不一致！" });

                    //查询数据库 ,判断用户名密码是否正确
                    Msg msg = new B_UserLogin().ResetPwd(model.UserType, model.Accounts, oldPwd/*DESEncrypt.Md5(oldPwd)*/, newPwd/*DESEncrypt.Md5(newPwd)*/, WebHelper.GetClientIP());

                    return Json(new { code = msg.code, msg = msg.content });
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(LoginController), ex);
            }

            return Json(new { code = 0, msg = "修改失败！" });
        }
        #endregion

        #region 登录日志
        /// <summary>
        /// 登录日志
        /// </summary>
        /// <returns></returns>
        [MemberAuthorize]
        public ActionResult LoginLog()
        {
            return View();
        }
        [MemberAuthorize]
        [HttpPost]
        public JsonResult LoginLog(FormCollection form)
        {
            M_EasyuiGridData<M_Base_AdminLog> jsonData = null;
            try
            {
                int pageIndex = form.Q<int>("page", 1);
                int pageSize = form.Q<int>("rows", 10);
                string sTime = form.Q<string>("sTime", DateTime.Now.ToString("yyyy-MM-dd"));
                string eTime = form.Q<string>("eTime", DateTime.Now.ToString("yyyy-MM-dd 23:59:59"));

                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser != null && loginUser.UserID > 0)
                {
                    NameValueCollection kv = new NameValueCollection();
                    kv.Add("PageSize", pageSize.ToString());
                    kv.Add("PageIndex", pageIndex.ToString());
                    kv.Add("sTime", sTime);
                    kv.Add("eTime", (eTime.IndexOf(':') > -1 ? eTime : eTime + " 23:59:59"));
                    kv.Add("Accounts", loginUser.Accounts);

                    //jsonData = new B_UserLogin().GetLoginLog(kv);
                }

            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(LoginController), ex);
            }

            jsonData = (jsonData == null ? new M_EasyuiGridData<M_Base_AdminLog>() : jsonData);

            return Json(jsonData);
        }
        #endregion
    }
}
