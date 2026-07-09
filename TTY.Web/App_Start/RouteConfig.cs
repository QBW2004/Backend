using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace YYT.Web
{
    public class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");


            routes.MapRoute(
            name: "Localization", // 路由名称
            url: "{lang}/{controller}/{action}/{id}", // 带有参数的 URL\
            constraints: new { lang = "zh-CN|en-US|vi-VN" }, //限制可输入的语言项
            defaults: new { controller = "Login", action = "Index", id = UrlParameter.Optional }//参数默认值
          );

            routes.MapRoute(
                name: "Default",
                url: "{controller}/{action}/{id}",
                defaults: new { controller = "Login", action = "Index", id = UrlParameter.Optional }
            );

            //routes.MapRoute(
            //    name: "Default",
            //    url: "{controller}/{action}/{id}",
            //    defaults: new { controller = "Login", action = "Index", id = UrlParameter.Optional }
            //);
        }
    }
}
