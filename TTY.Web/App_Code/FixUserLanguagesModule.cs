using System;
using System.Web;

namespace YYT.Web.App_Code
{
    public class FixUserLanguagesModule : IHttpModule
    {
        public void Dispose() { }

        public void Init(HttpApplication context)
        {
            context.BeginRequest += (sender, e) =>
            {
                var request = HttpContext.Current?.Request;
                if (request != null && (request.UserLanguages == null || request.UserLanguages.Length == 0))
                {
                    // Set a default Accept-Language header to prevent NullReferenceException
                    // in LocalizationAttribute.OnActionExecuting
                    var type = typeof(HttpRequest);
                    var field = type.GetField("_userLanguages", 
                        System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
                    if (field != null)
                    {
                        field.SetValue(request, new string[] { "zh-CN" });
                    }
                }
            };
        }
    }
}
