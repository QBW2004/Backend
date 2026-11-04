using System;
using System.Collections.Concurrent;
using System.Linq;
using System.Reflection;
using System.Web.Mvc;
using System.Web.Routing;
using System.Web.SessionState;

namespace YYT.Web
{
    /// <summary>
    /// 标记“只读会话”的接口：只读 Session（登录信息），从不写 Session。
    /// 2026-11-04 背景：ASP.NET 默认对同一登录会话的请求加排他锁，同一账号的并发请求被逐个放行，
    /// 而排队方每 500ms 才重试一次拿锁。手机端玩家列表/操作管理等页面每隔几秒并发轮询多个接口，
    /// 本该 10ms 的请求实测被排到 0.5~1.5s，游戏服慢时更久，进而超时、弹“网络异常”。
    /// 标了此特性的接口改用只读会话（不加排他锁、可并发；会话过期时间照常顺延）。
    /// 只能标在确定不写 Session 的接口上，写入会在只读会话里静默丢失。
    /// </summary>
    [AttributeUsage(AttributeTargets.Method, AllowMultiple = false)]
    public sealed class ReadOnlySessionAttribute : Attribute
    {
    }

    /// <summary>
    /// 按“控制器 + Action”决定会话行为。MVC 自带的 [SessionState] 只能整控制器设置，
    /// 而 UserInfoController 等同时含写 Session 的接口（注册令牌），所以按 Action 粒度判断：
    /// 同名 Action 的所有重载都标了 [ReadOnlySession] 才用只读会话，其余一律沿用默认（可写、加锁）。
    /// </summary>
    public class ReadOnlySessionControllerFactory : DefaultControllerFactory
    {
        private static readonly ConcurrentDictionary<string, bool> Cache = new ConcurrentDictionary<string, bool>(StringComparer.OrdinalIgnoreCase);

        protected override SessionStateBehavior GetControllerSessionBehavior(RequestContext requestContext, Type controllerType)
        {
            if (controllerType != null && requestContext != null && requestContext.RouteData != null)
            {
                string action = requestContext.RouteData.Values["action"] as string;
                if (!string.IsNullOrEmpty(action) && IsReadOnly(controllerType, action))
                    return SessionStateBehavior.ReadOnly;
            }
            return base.GetControllerSessionBehavior(requestContext, controllerType);
        }

        private static bool IsReadOnly(Type controllerType, string action)
        {
            return Cache.GetOrAdd(controllerType.FullName + "." + action, key =>
            {
                var methods = controllerType.GetMethods(BindingFlags.Instance | BindingFlags.Public)
                    .Where(m => string.Equals(m.Name, action, StringComparison.OrdinalIgnoreCase))
                    .ToList();
                return methods.Count > 0 && methods.All(m => m.IsDefined(typeof(ReadOnlySessionAttribute), true));
            });
        }
    }
}
