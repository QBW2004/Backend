using YYT.Entity;
using YYT.Common;
using System;
using System.Web;
using System.Web.Mvc;

namespace YYT.Web
{

    /// <summary>
    /// 站点授权属性
    /// </summary>
    public class MemberAuthorizeAttribute : AuthorizeAttribute
    {
        public override void OnAuthorization(AuthorizationContext filterContext)
        {
            HttpContextBase context = filterContext.HttpContext;
            M_LoginUser loginUser = WebHelper.GetLoginInfo();
            if (loginUser == null || !(loginUser.UserID > 0))
            {
                if (context.Request.HttpMethod.Equals("POST", StringComparison.CurrentCultureIgnoreCase))
                {
                    CustomResponse(context, TipMsg.MSG_LOGIN_TIMEOUT);
                    filterContext.Result = new JsonResult();//加入JsonResult就告诉ASP.NET MVC在本拦截器执行结束后，不必再为当前请求执行Controller中Action的代码
                }
                else
                {
                    // Mobile 区域固定跳手机登录；Mgr 默认入口也固定跳手机登录。
                    // 显式 /Mgr/Index?view=pc 保持电脑版登录入口。
                    string area = filterContext.RouteData != null && filterContext.RouteData.DataTokens["area"] != null
                        ? filterContext.RouteData.DataTokens["area"].ToString()
                        : string.Empty;
                    string controller = filterContext.RouteData.Values["controller"] == null
                        ? string.Empty
                        : filterContext.RouteData.Values["controller"].ToString();
                    bool explicitPc = string.Equals(filterContext.HttpContext.Request.QueryString["view"], "pc", StringComparison.OrdinalIgnoreCase);
                    string loginUrl = area.Equals("Mobile", StringComparison.OrdinalIgnoreCase)
                        || (controller.Equals("Mgr", StringComparison.OrdinalIgnoreCase) && !explicitPc)
                        ? "~/Login/Mobile"
                        : "~/Login/Index";
                    context.Response.Redirect(loginUrl);
                    filterContext.Result = new EmptyResult();//加入EmptyResult就告诉ASP.NET MVC在本拦截器执行结束后，不必再为当前请求执行Controller中Action的代码
                }
                return;
            }
        }
        private void CustomResponse(HttpContextBase context, string msg)
        {
            context.Response.Clear();
            context.Response.StatusCode = 200;
            context.Response.StatusDescription = "登录超时";
            context.Response.ContentType = "application/json";
            context.Response.Headers.Add("Access-Control-Allow-Origin", "*");
            context.Response.Headers.Add("Pragma.", "no-cache");
            context.Response.Write(msg);
            context.Response.End();
        }
    }


    /// <summary>
    /// 管理员授权属性  
    /// </summary>
    public class MgrAuthorizeAttribute : AuthorizeAttribute
    {
        public override void OnAuthorization(AuthorizationContext filterContext)
        {
            HttpContextBase context = filterContext.HttpContext;
            M_LoginUser loginUser = WebHelper.GetLoginInfo();
            if (loginUser == null || !(loginUser.UserID > 0))
            {
                if (context.Request.HttpMethod.Equals("POST", StringComparison.CurrentCultureIgnoreCase))
                {
                    CustomResponse(context, TipMsg.MSG_LOGIN_TIMEOUT);
                    filterContext.Result = new JsonResult();//加入EmptyResult就告诉ASP.NET MVC在本拦截器执行结束后，不必再为当前请求执行Controller中Action的代码
                }
                else
                {
                    context.Response.Redirect("~/Login/Index");
                    filterContext.Result = new EmptyResult();//加入EmptyResult就告诉ASP.NET MVC在本拦截器执行结束后，不必再为当前请求执行Controller中Action的代码
                }
                return;
            }
            else 
            {
                if (String.IsNullOrWhiteSpace(loginUser.Roles) || !ValidRole(loginUser.Roles))
                {
                    if (!context.Request.HttpMethod.Equals("POST", StringComparison.CurrentCultureIgnoreCase))
                    {
                        context.Response.Redirect("~/Common/NoAuthorize");
                        filterContext.Result = new EmptyResult();//加入EmptyResult就告诉ASP.NET MVC在本拦截器执行结束后，不必再为当前请求执行Controller中Action的代码
                    }
                    else
                    {
                        CustomResponse(context, TipMsg.MSG_INVALID_AUTHORIZE);
                        filterContext.Result = new JsonResult();//加入EmptyResult就告诉ASP.NET MVC在本拦截器执行结束后，不必再为当前请求执行Controller中Action的代码
                    }
                    return;
                }
            }
        }

        private bool ValidRole(string roles)
        {
            string[] rolesArr = roles.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            foreach (var item in rolesArr)
            {
                int roleId = 0;
                int.TryParse(item, out roleId);
                if (roleId == 1)
                    return true;
            }
            return false;
        }

        private void CustomResponse(HttpContextBase context, string msg)
        {
            context.Response.Clear();
            context.Response.StatusCode = 200;
            context.Response.StatusDescription = "登录超时";
            context.Response.ContentType = "application/json";
            context.Response.Headers.Add("Access-Control-Allow-Origin", "*");
            context.Response.Headers.Add("Pragma.", "no-cache");
            context.Response.Write(msg);
            context.Response.End();
        }
    }

}
