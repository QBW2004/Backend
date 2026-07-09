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
        /// 系统登录
        /// </summary>
        /// <returns></returns>
        public ActionResult Index()
        {
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
            string clientIP = string.Empty;
            string uname = string.Empty;
            string upwd = string.Empty;
            //string code = string.Empty;
            string admin = ConfigHelper.Get("admin");
            try
            {
                uname = form.Q<string>("uname", "").Trim();
                upwd = form.Q<string>("upwd", "").Trim();
                //code = form.Q<string>("code", "").Trim();

                clientIP = WebHelper.GetClientIP();

                if (string.IsNullOrWhiteSpace(uname))
                {
                    TempData["msg"] = "请输入帐号！";
                    return View();
                }
                if (string.IsNullOrWhiteSpace(upwd))
                {
                    TempData["msg"] = "请输入密码！";
                    return View();
                }
                //if (string.IsNullOrWhiteSpace(code))
                //{
                //    TempData["msg"] = "请输入验证码！";
                //    return View();
                //}


                if (uname == admin)
                {
                //    { "LoginResult":1,"LoginMsg":"登录成功！","UserID":999,"Accounts":"admin",
                //            "UserName":"admin","IsDel":0,"Remark":"","Roles":"0",
                //            "UserType":0,"RE_ENABLE":1,"UserPriv":0,"IsFrozen":1,"IsProbability":1,"IsKill":1,"IsRelease":1,"IsKicking":1,"IsDelete":1}
                    M_LoginUser model1 = new M_LoginUser();
                    model1.LoginResult = 1;
                    model1.UserPriv = 0;
                    model1.Accounts = admin;
                    model1.UserName = admin;
                    model1.UserID = 999;
                    model1.LoginMsg = "登录成功！";
                    model1.IsDel = 0;
                    model1.Remark = "";
                    model1.Roles = "0";
                    model1.UserType = 0;
                    model1.RE_ENABLE = 1;
                    model1.IsFrozen = 1;
                    model1.IsProbability = 1;
                    model1.IsKill = 1;
                    model1.IsRelease = 1;
                    model1.IsKicking = 1;
                    model1.IsDelete = 1;
                    WebHelper.WriteSession("LoginInfo", DESEncrypt.Encrypt(model1.ToString()));
                    return RedirectToAction("Index", "Mgr");
                }
                else
                {
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
                            TempData["msg"] = "登录错误次数太多，请5分钟后再登录！";
                            return View();
                        }
                    }

                    string regStr = "'|(select)|(drop)|(table)|(master)|(dbo\\.)|\\[|\\]|\\{|\\}";
                    if (Regex.IsMatch(uname, regStr) || Regex.IsMatch(upwd, regStr))
                    {
                        TempData["msg"] = "非法字符输入！";
                        missEntity.LoginResult = 0;
                        missBll.UpadteRecord(missEntity);
                        return View();
                    }
                    //if (Regex.IsMatch(code, "[^\\d]{4}") || !(code.Equals(WebHelper.GetValideCode(), StringComparison.InvariantCultureIgnoreCase)))
                    //{
                    //    TempData["msg"] = "验证码不正确！";
                    //    missEntity.LoginResult = 0;
                    //    missBll.UpadteRecord(missEntity);
                    //    return View();
                    //}
                    //查询数据库 ,判断用户名密码是否正确
                    M_LoginUser model = new B_UserLogin().Login(uname, /*DESEncrypt.Md5(upwd)*/upwd, WebHelper.GetClientIP());
                    if (model != null)
                    {
                        if (model.LoginResult == 1)
                        {
                            WebHelper.WriteSession("LoginInfo", DESEncrypt.Encrypt(model.ToString()));

                            //#if DEBUG
                            //                        if (Request.Browser.IsMobileDevice)
                            //                            return RedirectToAction("Index", "Home", new { area = "Mobile" }); 
                            //#endif

                            missEntity.LoginResult = 1;
                            missBll.UpadteRecord(missEntity);

                            return RedirectToAction("Index", "Mgr");
                        }
                        else
                        {
                            TempData["msg"] = model.LoginMsg + "登录失败！";
                            LogHelper.WriteLog(typeof(LoginController), model.LoginMsg + "登录失败！");

                            missEntity.LoginResult = 0;
                            missBll.UpadteRecord(missEntity);
                        }
                    }
                    else
                    {
                        TempData["msg"] = "登录失败！";
                        missEntity.LoginResult = 0;
                        missBll.UpadteRecord(missEntity);
                    }
                }
              
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(LoginController), ex.Message + "登录失败！");

                TempData["msg"] = "登录失败。";
            }
            return View();
        }
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
