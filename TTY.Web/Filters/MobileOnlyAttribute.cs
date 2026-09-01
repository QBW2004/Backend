using System.Web.Mvc;
using YYT.Web.Controllers;

namespace YYT.Web.Filters
{
    /// <summary>
    /// 手机端页面专用标记。
    /// 手机端/电脑版由入口 URL 决定，不能根据 UA 或 Cookie 重定向。
    /// </summary>
    public class MobileOnlyAttribute : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            // Intentionally no-op. The attribute remains on existing Mobile actions
            // so route metadata and authorization behavior do not change.
        }
    }
}
