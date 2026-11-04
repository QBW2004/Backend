using System.Web;
using System.Web.Optimization;

namespace YYT.Web
{
    public class BundleConfig
    {
        // 有关捆绑的详细信息，请访问 https://go.microsoft.com/fwlink/?LinkId=301862
        public static void RegisterBundles(BundleCollection bundles)
        {
            // 2026-11-04：Web.config 关闭调试编译（debug=false）后，System.Web.Optimization 默认会把下列包合并压缩，
            // 合并后 CSS 的虚拟路径变成 ~/res/...，easyui/font-awesome 里的相对图片、字体地址会失效。
            // 这里显式关闭合并压缩，页面输出与调试模式时完全一致（逐个文件引用）。
            BundleTable.EnableOptimizations = false;
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
