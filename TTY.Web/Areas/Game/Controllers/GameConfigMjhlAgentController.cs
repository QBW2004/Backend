using System;
using System.Globalization;
using System.Linq;
using System.Web.Mvc;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Web.Models;

namespace YYT.Web.Areas.Game.Controllers
{
    public partial class GameConfigController
    {
        private string MjhlLine(GameDbContext ef, string requested)
        {
            var viewer = WebHelper.GetLoginInfo();
            if (viewer == null) throw new UnauthorizedAccessException("登录已过期。");
            string own = viewer.UserPriv == 0 ? "" : LineScopeRules.ResolveLineOfAgency(ef, viewer.Accounts);
            string line = string.IsNullOrWhiteSpace(requested) && viewer.UserPriv != 0 ? own : (requested ?? "").Trim();
            int viewerPriv = viewer.UserPriv.GetValueOrDefault(-1);
            if (string.IsNullOrEmpty(line) || line.Length > 64 || !MjhlAgentConfig.CanRead(viewerPriv, own, line))
                throw new UnauthorizedAccessException("请选择有权查看的代理线。");
            if (line == MjhlAgentConfig.DefaultLine) return MjhlAgentConfig.DefaultLine;
            string canonical = ef.Admins.Where(a => a.ID == line && a.PRIV == 1).Select(a => a.ID).FirstOrDefault();
            if (canonical == null) throw new ArgumentException("代理线不存在。");
            if (!LineScopeRules.IsGameAllowed(LineScopeRules.GetLinePlayableGames(ef, canonical), 54))
                throw new ArgumentException("该代理线尚未开放麻将胡了。");
            return canonical;
        }

        [AjaxOnly, HttpPost]
        public ActionResult GetMjhlAgentLines()
        {
            try
            {
                using (var ef = new GameDbContext())
                {
                    var viewer = WebHelper.GetLoginInfo();
                    string own = viewer.UserPriv == 0 ? "" : LineScopeRules.ResolveLineOfAgency(ef, viewer.Accounts);
                    var configured = ef.Database.SqlQuery<string>("SELECT LineAgent FROM mjhl_agent_config WHERE GameId=54").ToList();
                    var lines = new System.Collections.Generic.List<object>();
                    if (viewer.UserPriv == 0)
                        lines.Add(new { id = MjhlAgentConfig.DefaultLine, text = "默认（未单独配置的代理线使用）", count = 1 });
                    lines.AddRange((viewer.UserPriv == 0 ? LineScopeRules.GetLineAgents(ef) : new System.Collections.Generic.List<string> { own })
                        .Where(line => !string.IsNullOrEmpty(line) && LineScopeRules.IsGameAllowed(LineScopeRules.GetLinePlayableGames(ef, line), 54))
                        .Select(line => (object)new { id = line, text = line + (configured.Contains(line, StringComparer.OrdinalIgnoreCase) ? "（独立配置）" : "（使用默认配置）"), count = configured.Contains(line, StringComparer.OrdinalIgnoreCase) ? 1 : 0 }));
                    return Json(new { code = 1, datas = new { Ready = true, Lines = lines, Owned = 0, Recycled = 0, CanEdit = viewer.UserPriv.GetValueOrDefault(-1) == 0 } });
                }
            }
            catch (Exception ex) { LogHelper.WriteLog(typeof(GameConfigController), ex); return Json(new { code = 0, content = "代理线读取失败。" }); }
        }

        [AjaxOnly, HttpPost]
        public ActionResult GetMjhlAgentConfig(string lineAgent)
        {
            try
            {
                using (var ef = new GameDbContext())
                {
                    string line = MjhlLine(ef, lineAgent);
                    var row = MjhlAgentConfigStore.Read(ef, line);
                    var defaults = line == MjhlAgentConfig.DefaultLine ? row : MjhlAgentConfigStore.Read(ef, MjhlAgentConfig.DefaultLine);
                    var effective = row ?? defaults;
                    return Json(new { code = 1, lineAgent = line, configured = row != null, inherited = row == null && defaults != null,
                        revision = MjhlAgentConfigStore.Revision(ef, line, row).ToString(CultureInfo.InvariantCulture),
                        defaultAvailable = defaults != null, defaultRevision = defaults == null ? "0" : defaults.Revision.ToString(CultureInfo.InvariantCulture),
                        sourceLine = effective == null ? "" : effective.LineAgent, sourceRevision = effective == null ? "0" : effective.Revision.ToString(CultureInfo.InvariantCulture),
                        config = effective == null ? MjhlAgentConfig.Default() : MjhlAgentConfig.Parse(effective.ConfigJson), configHash = effective == null ? "" : effective.ConfigHash,
                        canEdit = WebHelper.GetLoginInfo().UserPriv.GetValueOrDefault(-1) == 0, updatedAt = effective == null ? "" : effective.UpdatedAt.ToString("yyyy-MM-dd HH:mm:ss") + " UTC",
                        simulationSummary = effective == null ? "" : (effective.SimulationSummary ?? "") });
                }
            }
            catch (Exception ex) { LogHelper.WriteLog(typeof(GameConfigController), ex); return Json(new { code = 0, content = ex is ArgumentException || ex is UnauthorizedAccessException ? ex.Message : "配置读取失败，请确认数据库补丁已执行。" }); }
        }

        [AjaxOnly, HttpPost, ValidateAntiForgeryToken, SuperAdminAuthorize]
        public ActionResult CopyMjhlDefaultConfig(string lineAgent, string expectedRevision, string expectedDefaultRevision)
        {
            return ChangeMjhlAgentInheritance(lineAgent, expectedRevision, expectedDefaultRevision, true);
        }

        [AjaxOnly, HttpPost, ValidateAntiForgeryToken, SuperAdminAuthorize]
        public ActionResult RecallMjhlAgentConfig(string lineAgent, string expectedRevision, string expectedDefaultRevision)
        {
            return ChangeMjhlAgentInheritance(lineAgent, expectedRevision, expectedDefaultRevision, false);
        }

        private ActionResult ChangeMjhlAgentInheritance(string lineAgent, string expectedRevision, string expectedDefaultRevision, bool copy)
        {
            try
            {
                long expected, expectedDefault;
                if (!long.TryParse(expectedRevision, NumberStyles.None, CultureInfo.InvariantCulture, out expected) ||
                    !long.TryParse(expectedDefaultRevision, NumberStyles.None, CultureInfo.InvariantCulture, out expectedDefault))
                    throw new ArgumentException("配置版本不正确，请重新载入。");
                MjhlAgentConfigStore.Row row;
                using (var ef = new GameDbContext())
                {
                    string line = MjhlLine(ef, lineAgent);
                    row = MjhlAgentConfigStore.ChangeInheritance(ef, line, expected, expectedDefault, copy, WebHelper.GetLoginInfo().Accounts);
                }
                var hot = SendMjhlHotReload(54);
                bool sent = hot != null && hot.code == 1;
                string action = copy ? "已复制默认配置，该代理线现使用独立配置" : "已收回独立配置，该代理线现跟随默认配置";
                LogHelper.WriteLog(typeof(GameConfigController), "[MjhlAgentConfig] action=" + (copy ? "copy-default" : "recall") + " line=" + row.LineAgent + " revision=" + row.Revision + " defaultRevision=" + expectedDefault + " operator=" + row.UpdatedBy + " hotReload=" + sent);
                return Json(new { code = 1, revision = row.Revision.ToString(CultureInfo.InvariantCulture), hotReload = sent,
                    content = action + (sent ? "，更新指令已发送。" : "；更新指令未成功，游戏服可能仍使用旧版本。") });
            }
            catch (Exception ex) { LogHelper.WriteLog(typeof(GameConfigController), ex); return Json(new { code = 0, content = ex is ArgumentException || ex is UnauthorizedAccessException ? ex.Message : "配置操作失败，请重新载入或查看后台日志。" }); }
        }

        [AjaxOnly, HttpPost, ValidateAntiForgeryToken, SuperAdminAuthorize]
        public ActionResult SaveMjhlAgentConfig(string lineAgent, string expectedRevision, string configJson, string simulated)
        {
            try
            {
                long expected;
                if (!long.TryParse(expectedRevision, NumberStyles.None, CultureInfo.InvariantCulture, out expected)) throw new ArgumentException("配置版本不正确，请重新载入。");
                var config = MjhlAgentConfig.Parse(configJson);
                MjhlAgentConfigStore.Row row;
                using (var ef = new GameDbContext())
                {
                    string line = MjhlLine(ef, lineAgent);
                    row = MjhlAgentConfigStore.Save(ef, line, expected, config, WebHelper.GetLoginInfo().Accounts, "正常权重试算，不含赠送/吃分控制；" + (simulated ?? ""));
                }
                var hot = SendMjhlHotReload(54);
                bool sent = hot != null && hot.code == 1;
                LogHelper.WriteLog(typeof(GameConfigController), "[MjhlAgentConfig] line=" + row.LineAgent + " revision=" + row.Revision + " hash=" + row.ConfigHash + " operator=" + row.UpdatedBy + " hotReload=" + sent);
                return Json(new { code = 1, revision = row.Revision.ToString(CultureInfo.InvariantCulture), configHash = row.ConfigHash, hotReload = sent,
                    content = sent ? "代理线配置已保存，更新指令已发送。" : "代理线配置已保存；更新指令未成功，游戏服可能仍使用旧版本。" });
            }
            catch (Exception ex) { LogHelper.WriteLog(typeof(GameConfigController), ex); return Json(new { code = 0, content = ex is ArgumentException || ex is UnauthorizedAccessException ? ex.Message : "保存失败，请查看后台日志。" }); }
        }
    }
}
