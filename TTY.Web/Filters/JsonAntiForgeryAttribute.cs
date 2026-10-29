using System.Web.Helpers;
using System.Web.Mvc;

namespace YYT.Web.Filters
{
    /// <summary>
    /// 与 [ValidateAntiForgeryToken] 相同的防伪令牌校验，但校验失败时返回 JSON
    /// 而不是 HTML 错误页——供 fetch/ajax 登录这类只认 JSON 响应的接口使用。
    /// 此前手机端登录在令牌过期/Cookie 被清理时会拿到 500 HTML，前端 res.json()
    /// 解析失败统一显示"服务器响应错误"，把令牌问题误报成服务器故障。
    /// 响应带 refresh=true，客户端可重新拉取页面换新令牌后重试一次。
    /// </summary>
    public class JsonAntiForgeryAttribute : FilterAttribute, IAuthorizationFilter
    {
        public void OnAuthorization(AuthorizationContext filterContext)
        {
            try
            {
                AntiForgery.Validate();
            }
            catch (HttpAntiForgeryException)
            {
                filterContext.Result = new JsonResult
                {
                    Data = new { code = 0, msg = "登录校验已过期，请刷新页面后重试！", refresh = true }
                };
            }
        }
    }
}
