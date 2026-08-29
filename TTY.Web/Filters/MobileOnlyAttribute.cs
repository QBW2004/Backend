using System.Web.Mvc;
using YYT.Web.Controllers;

namespace YYT.Web.Filters
{
    /// <summary>
    /// 手机端页面专用：电脑浏览器访问手机端页面时弹回电脑端框架页 /Mgr/Index。
    /// 可用 ?view=pc / ?view=mobile 手动切换，选择记在 mth_view Cookie（30 天），
    /// 与登录页 / 框架页同一套偏好；Cookie 选了 mobile 时允许在电脑上看手机版。
    /// </summary>
    public class MobileOnlyAttribute : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            BaseController controller = filterContext.Controller as BaseController;
            if (controller == null)
                return;

            string view = (filterContext.HttpContext.Request.QueryString["view"] ?? string.Empty).Trim().ToLowerInvariant();
            if (view == "pc" || view == "mobile")
            {
                controller.SaveViewMode(view);
                if (view == "pc")
                    filterContext.Result = new RedirectResult("~/Mgr/Index");
                return;
            }

            // 应去电脑端：主动选了 pc；或电脑 UA 且未选 mobile。
            // （手机 UA 选了 pc 也弹回，与电脑 UA 选 mobile 时可留在手机端互为镜像）
            string mode = controller.GetViewMode();
            if (mode == "pc" || (!controller.IsMobileBrowser() && mode != "mobile"))
            {
                filterContext.Result = new RedirectResult("~/Mgr/Index");
            }
        }
    }
}
