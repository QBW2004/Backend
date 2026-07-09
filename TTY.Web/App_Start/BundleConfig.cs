using System.Web;
using System.Web.Optimization;

namespace YYT.Web
{
    public class BundleConfig
    {
        // 有关捆绑的详细信息，请访问 https://go.microsoft.com/fwlink/?LinkId=301862
        public static void RegisterBundles(BundleCollection bundles)
        {
            /*****************************************************************************************************************************************/
            bundles.Add(new ScriptBundle("~/res/jquery-js").Include(
                "~/Scripts/jquery-{version}.js",
                "~/Scripts/easyloader.js",
                "~/Scripts/app/common.js"
                ));
            /**
             * 框架内页面公共资源
             * */
            bundles.Add(new StyleBundle("~/res/main-common-css").Include(
                "~/Content/css/bootstrap.min.css",
                "~/Content/css/font-awesome.css",
                "~/Content/css/animate.css"
                ));
            bundles.Add(new ScriptBundle("~/res/main-common-js").Include(
                "~/Scripts/jquery-{version}.js",
                "~/Scripts/bootstrap.js"
                ));
            /*****************************************************************************************************************************************/
            /**
             * jquery easyui 公共资源
             * */
            bundles.Add(new StyleBundle("~/res/easyui-css").Include(
                //"~/Content/easyui/themes/material-teal/easyui.css",
                "~/Content/easyui/themes/bootstrap/easyui.css",
                "~/Content/easyui/themes/color.css",
                "~/Content/easyui/themes/icon.css"
                ));
            bundles.Add(new ScriptBundle("~/res/easyui-js").Include(
                "~/Scripts/jquery-{version}.js",
                "~/Scripts/easyui/src/easyloader.js"
                ));

            /*****************************************************************************************************************************************/
            /*
             * 登录资源
             * */
            //bundles.Add(new StyleBundle("~/res/login-css").Include(
            //    "~/Content/css/bootstrap.min.css",
            //    "~/Content/css/login.css"
            //    ));
            bundles.Add(new StyleBundle("~/res/login-css").Include(
                "~/Content/css/bootstrap.min.css",
                "~/Content/css/font-awesome.css",
                "~/Content/css/login.css"
                ));
            bundles.Add(new ScriptBundle("~/res/login-js").Include(
                "~/Scripts/jquery-{version}.js",
                "~/Scripts/bootstrap.js",
                "~/Scripts/app/login.js"
                ));
            /*****************************************************************************************************************************************/
            /**
             * 框架资源
             * */
            bundles.Add(new StyleBundle("~/res/frame-css").Include(
                "~/Content/css/bootstrap.min.css",
                "~/Content/css/font-awesome.css",
                "~/Content/css/animate.css",
                "~/Content/css/style.css"
                ));
            bundles.Add(new ScriptBundle("~/res/frame-plugins-js").Include(
                "~/Scripts/plugins/metisMenu/jquery.metisMenu.js",
                "~/Scripts/plugins/slimscroll/jquery.slimscroll.js",
                "~/Scripts/plugins/pace/pace.js"
                ));
            bundles.Add(new ScriptBundle("~/res/frame-usr-js").Include(
                "~/Scripts/app/frame.js"
                ));
        }
    }
}
