using System;
using System.Data.Entity;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;
using System.Threading;
using YYT.BLL.EF;
using YYT.BLL.Services.GameServer;
using YYT.Common;

namespace YYT.Web
{
    public class MvcApplication : System.Web.HttpApplication
    {
        public static System.Timers.Timer tasksTimer = new System.Timers.Timer();
        private static int timerTaskRunning;

        protected void Application_Start()
        {
           
            AreaRegistration.RegisterAllAreas();
            ViewEngines.Engines.Clear();
            ViewEngines.Engines.Add(new CustomRazorViewEngine());
            GlobalConfiguration.Configure(WebApiConfig.Register);
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);
            Database.SetInitializer<GameDbContext>(null);
            //配置log4net
            log4net.Config.XmlConfigurator.Configure(new System.IO.FileInfo(Server.MapPath("~/Config/log4net.config")));

            // 定时任务
            int interval = ConfigHelper.GetInt("Timer") * 1000;
            if (interval > 0)
            {
                tasksTimer.Elapsed += TasksTimer_Elapsed;
                tasksTimer.Interval = interval;
                tasksTimer.Enabled = true;
                tasksTimer.AutoReset = true;
            }
        }

        private void TasksTimer_Elapsed(object sender, System.Timers.ElapsedEventArgs e)
        {
            try
            {
                if (Interlocked.Exchange(ref timerTaskRunning, 1) == 1)
                    return;

                // 定时任务
                System.Threading.Tasks.Task.Run(() => {
                    try
                    {
                        new B_UserLockRecord().TimerTaskRun();
                        new GameCommandOutboxRetryService().ProcessDueCommands();
                        new B_LoginMissRecord().ResetLoginMissRecord();
                        B_Records_MySQL.CleanupExpiredRecordsThrottled();
                    }
                    finally
                    {
                        Volatile.Write(ref timerTaskRunning, 0);
                    }
                });
            }
            catch
            {
                Volatile.Write(ref timerTaskRunning, 0);
            }
        }
        
        public override void Init()
        {
            // 在Api中使用Session；/Game、/Mobile 数据接口改为只读会话——
            // 同一管理员并发发起的 AJAX 不再被会话锁串行化（会话只用于读登录态）。
            // 这两个区域里写 Session 的只有 Game/UserInfo/Register（注册令牌），必须保持可写。
            this.PostAuthenticateRequest += (sender, e) =>
            {
                HttpContext ctx = HttpContext.Current;
                if (ctx == null)
                    return;
                string path = ctx.Request.AppRelativeCurrentExecutionFilePath ?? string.Empty;
                bool readOnly = (path.StartsWith("~/Game/", StringComparison.OrdinalIgnoreCase)
                              || path.StartsWith("~/Mobile/", StringComparison.OrdinalIgnoreCase))
                    && !path.StartsWith("~/Game/UserInfo/Register", StringComparison.OrdinalIgnoreCase);
                ctx.SetSessionStateBehavior(readOnly
                    ? System.Web.SessionState.SessionStateBehavior.ReadOnly
                    : System.Web.SessionState.SessionStateBehavior.Required);
            };
            base.Init();
        }
    }
}
