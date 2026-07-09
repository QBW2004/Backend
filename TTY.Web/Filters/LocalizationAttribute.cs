using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.Mvc;

namespace YYT.Web.Filters
{
    public class LocalizationAttribute : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {

            bool isSkipLocalization = filterContext.ActionDescriptor.IsDefined(typeof(WithoutLocalizationAttribute), inherit: true) || filterContext.ActionDescriptor.ControllerDescriptor.IsDefined(typeof(WithoutLocalizationAttribute), inherit: true);

            if (!isSkipLocalization)
            {
                if (filterContext.RouteData.Values["lang"] != null && !string.IsNullOrWhiteSpace(filterContext.RouteData.Values["lang"].ToString()))
                {
                    ///从路由数据(url)里设置语言
                    var lang = filterContext.RouteData.Values["lang"].ToString();
                    Thread.CurrentThread.CurrentUICulture = CultureInfo.CreateSpecificCulture(lang);
                }
                else
                {
                    ///从cookie里读取语言设置
                    var cookie = filterContext.HttpContext.Request.Cookies["Localization.CurrentUICulture"];
                    var langHeader = string.Empty;
                    if (cookie != null && cookie.Value != "")
                    {
                        ///根据cookie设置语言
                        langHeader = cookie.Value;
                        Thread.CurrentThread.CurrentUICulture = CultureInfo.CreateSpecificCulture(langHeader);
                    }
                    else
                    {
                        ///如果读取cookie失败则设置默认语言
                        if (filterContext.HttpContext.Request.UserLanguages != null && filterContext.HttpContext.Request.UserLanguages.Length > 0)
                            langHeader = filterContext.HttpContext.Request.UserLanguages[0];
                        else
                            langHeader = "zh-CN";
                        Thread.CurrentThread.CurrentUICulture = CultureInfo.CreateSpecificCulture(langHeader);
                    }
                    ///把语言值设置到路由值里
                    filterContext.RouteData.Values["lang"] = langHeader;
                    //如果url中不包含语言设置则重定向到包含语言值设置的url里
                    string ReturnUrl = $"/{filterContext.RouteData.Values["lang"]}/{filterContext.RouteData.Values["controller"]}/{filterContext.RouteData.Values["action"]}";
                    filterContext.Result = new RedirectResult(ReturnUrl);
                }

                /// 把设置保存进cookie
                HttpCookie _cookie = new HttpCookie("Localization.CurrentUICulture", Thread.CurrentThread.CurrentUICulture.Name);
                _cookie.Expires = DateTime.Now.AddYears(1);
                filterContext.HttpContext.Response.SetCookie(_cookie);

                base.OnActionExecuting(filterContext);
            }

        }
        public class WithoutLocalizationAttribute : Attribute
        {
        }


    }
}