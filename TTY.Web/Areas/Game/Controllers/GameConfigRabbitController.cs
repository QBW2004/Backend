using System.Web.Mvc;
using YYT.Entity;
using System;
using System.Web.Script.Serialization;
using YYT.BLL.EF;
using YYT.Web.Models;

namespace YYT.Web.Areas.Game.Controllers
{
    public partial class GameConfigController
    {
        [AjaxOnly, HttpPost, SuperAdminAuthorize]
        public ActionResult GetRabbitPayoutRules(int tableIndex)
        {
            return GetRabbitConfig(tableIndex);
        }

        [AjaxOnly, HttpPost, SuperAdminAuthorize]
        public ActionResult GetRabbitConfig(int tableIndex)
        {
            try
            {
                if (tableIndex < -1 || tableIndex > 255) throw new ArgumentException("机台无效");
                using (var ef = new GameDbContext())
                {
                    string source;
                    string json = RabbitConfig.ReadTable(ef, tableIndex, out source);
                    // MVC JsonResult uses JavaScriptSerializer; JToken would lose its field names.
                    return Json(new { code = 1, tableIndex, saved = source == "table", source, shared = false, config = new JavaScriptSerializer().DeserializeObject(json) });
                }
            }
            catch (Exception ex) { return Json(new Msg(0, "规则载入失败：" + ex.Message)); }
        }

        [AjaxOnly, HttpPost, SuperAdminAuthorize, ValidateAntiForgeryToken]
        public ActionResult SaveRabbitConfig(int tableIndex, string configJson)
        {
            return Json(new Msg(0, "请在大白兔桌台配置中使用底部保存按钮，同时保存本桌参数与玩法规则。"));
        }
    }
}
