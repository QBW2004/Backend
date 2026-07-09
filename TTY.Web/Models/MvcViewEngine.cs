using System.Linq;
using System.Web.Mvc;

namespace YYT.Web
{
    public class CustomRazorViewEngine : RazorViewEngine
    {
        public CustomRazorViewEngine()
        {
            var newLocationFormat = new[]
                                    {
                                        "~/Views/{1}/Shared/{0}.cshtml",
                                        "~/Views/{1}/{0}.cshtml", 
                                        "~/Views/Shared/{0}.cshtml", 
                                        "~/Views/Shared/Layout/{0}.cshtml", 
                                        "~/Views/Shared/PartialPage/{0}.cshtml",
                                        "~/Areas/Game/Views/Shared/{0}.cshtml",
                                        "~/Areas/Mobile/Views/Shared/{0}.cshtml"
                                        //"~/Areas/{1}/Views/Shared/{0}.cshtml"
                                    };
            base.PartialViewLocationFormats = base.PartialViewLocationFormats.Union(newLocationFormat).ToArray();
        }
    }
}