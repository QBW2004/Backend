using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using Newtonsoft.Json;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Remote;
using YYT.Web.Controllers;
using YYT.Web.Models;

namespace YYT.Web.Areas.Game.Controllers
{
    /// <summary>
    /// 系统设置 / 活动配置（2026-11-03，仅超管）：目前只有大白兔「全民赛跑」一项。
    /// 保存写 activityconfig 后发 PC(55)，中心服重推大白兔扩展参数（含 0x5621 活动帧），下一手生效；
    /// 关闭后游戏服停发、客户端公示接口返回不展示。规则与口径见 YYT.BLL.EF.RabbitRaceActivity。
    /// </summary>
    [MemberAuthorize]
    [SuperAdminAuthorize]
    public class ActivityConfigController : BaseController
    {
        public ActionResult Index()
        {
            return View();
        }

        // 拒绝缓存的全桌规则编辑器，避免覆盖已经分开的桌台参数。
        [AjaxOnly, HttpPost]
        public ActionResult GetRabbitConfig()
        {
            return Json(new Msg(0, "玩法规则已改为按桌台配置，请在大白兔桌台配置中选择具体桌台。"));
        }

        [AjaxOnly, HttpPost, ValidateAntiForgeryToken]
        public ActionResult SaveRabbitConfig(string configJson)
        {
            return Json(new Msg(0, "已停止全桌规则保存，请在大白兔桌台配置中使用底部保存按钮。"));
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult GetRabbitRace()
        {
            try
            {
                using (var ef = new GameDbContext())
                {
                    if (!ActivityConfigs.TableExists(ef))
                        return Json(new { code = 0, ready = false, content = "数据库缺少 activityconfig 表，请先执行 SQL 补丁「全民赛跑活动配置-20261103.sql」！" });
                    ActivityConfigs.Row row = ActivityConfigs.Load(ef, RabbitRaceActivity.Key);
                    RabbitRaceActivity cfg = (row == null ? null : RabbitRaceActivity.Parse(row.CfgJson)) ?? RabbitRaceActivity.Default();
                    int used = ActivityConfigs.CountUsed(ef, cfg, DateTime.UtcNow);
                    return Json(new
                    {
                        code = 1,
                        ready = true,
                        saved = row != null,
                        enabled = cfg.Enabled,
                        startTime = RabbitRaceActivity.FormatMinute(cfg.StartMinute),
                        endTime = RabbitRaceActivity.FormatMinute(cfg.EndMinute),
                        dailyQuota = cfg.DailyQuota,
                        multiplier = cfg.Multiplier,
                        types = cfg.Types,
                        typeOptions = RabbitRaceActivity.TypeNames.Select(p => new { value = p.Key, name = p.Value }).ToList(),
                        open = cfg.IsOpen(RabbitRaceActivity.BeijingNow(DateTime.UtcNow)),
                        usedToday = used,
                        remainingToday = Math.Max(0, cfg.DailyQuota - used),
                        beijingNow = RabbitRaceActivity.BeijingNow(DateTime.UtcNow).ToString("yyyy-MM-dd HH:mm"),
                        operatorName = row == null ? "" : row.Operator,
                        updateTime = row == null || !row.UpdateTime.HasValue ? "" : row.UpdateTime.Value.ToString("yyyy-MM-dd HH:mm:ss")
                    });
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(ActivityConfigController), ex);
                return Json(new { code = 0, ready = false, content = "查询失败：" + ex.Message });
            }
        }

        [AjaxOnly]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult SaveRabbitRace(FormCollection form)
        {
            try
            {
                var types = new List<int>();
                foreach (string part in (form.Q<string>("Types") ?? string.Empty).Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
                {
                    int type;
                    if (!int.TryParse(part.Trim(), out type)) return Json(new Msg(0, "触发牌型无效！"));
                    types.Add(type);
                }
                var cfg = new RabbitRaceActivity
                {
                    Enabled = form.Q<int>("Enabled", 0) == 1,
                    StartMinute = RabbitRaceActivity.ParseMinute(form.Q<string>("StartTime")),
                    EndMinute = RabbitRaceActivity.ParseMinute(form.Q<string>("EndTime")),
                    DailyQuota = form.Q<int>("DailyQuota", 0),
                    Multiplier = form.Q<int>("Multiplier", 0),
                    Types = types.Distinct().OrderBy(t => t).ToList()
                };
                string error = cfg.Validate();
                if (error != null) return Json(new Msg(0, error));
                string json = cfg.ToJson();
                string operatorName = WebHelper.GetLoginInfo().UserName;
                using (var ef = new GameDbContext())
                {
                    if (!ActivityConfigs.TableExists(ef))
                        return Json(new Msg(0, "数据库缺少 activityconfig 表，请先执行 SQL 补丁「全民赛跑活动配置-20261103.sql」！"));
                    ActivityConfigs.Save(ef, RabbitRaceActivity.Key, RabbitRaceActivity.GameId, cfg.Enabled, json, operatorName);
                }
                LogHelper.WriteLog(typeof(ActivityConfigController), "[RabbitRace] operator=" + operatorName + " config=" + json);
                Msg hot = null;
                try { hot = new SConnect().SendPcCommand((ushort)RabbitRaceActivity.GameId); }
                catch (Exception ex) { LogHelper.WriteLog(typeof(ActivityConfigController), ex); }
                bool sent = hot != null && hot.code == 1;
                return Json(new Msg(1, sent ? "活动已保存，已通知游戏服，下一手牌生效。" : "活动已保存；通知游戏服未成功，请稍后再次保存重发。"));
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(ActivityConfigController), ex);
                return Json(new Msg(0, "保存失败：" + ex.Message));
            }
        }
    }
}
