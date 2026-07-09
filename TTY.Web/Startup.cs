using Microsoft.Owin;
using Microsoft.Owin.Cors;
using Owin;

[assembly: OwinStartup(typeof(YYT.Web.Startup))]

namespace YYT.Web
{
    public class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            // 有关如何配置应用程序的详细信息，请访问 https://go.microsoft.com/fwlink/?LinkID=316888

            //WebApi允许跨域调用
            app.UseCors(CorsOptions.AllowAll);

            app.MapSignalR();
        }
    }
}
