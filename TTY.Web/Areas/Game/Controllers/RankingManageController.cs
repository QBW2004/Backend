using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Web.Controllers;
using YYT.Web.Models;

namespace YYT.Web.Areas.Game.Controllers
{
    /// <summary>
    /// 系统设置 / 排行榜管理（2026-11-06，仅超管）：勾选游戏后清空大厅排行榜显示（gamerankhistory）。
    /// 客户端 api/RankingList/History 实时读表，清理后下次打开排行榜即不再显示；中奖明细不删除。
    /// 可按代理线清理：全部代理线 / 公共桌台 / 某条直属代理线。只列客户端可见游戏；残留记录由定时任务 RankHistoryCleanup.CleanupResidualDaily 每日自动清理。
    /// 规则见 YYT.BLL.EF.RankHistoryCleanup。
    /// </summary>
    [MemberAuthorize]
    [SuperAdminAuthorize]
    public class RankingManageController : BaseController
    {
        public ActionResult Index()
        {
            return View();
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult GetGames(string line)
        {
            try
            {
                using (var ef = new GameDbContext())
                {
                    List<string> lineAgents = LineScopeRules.GetLineAgents(ef);
                    string error;
                    string scope = RankHistoryCleanup.ParseLine(line, lineAgents, out error);
                    if (error != null) return Json(new { code = 0, content = error, lines = lineAgents });
                    var rows = RankHistoryCleanup.ListGames(ef, scope).Select(r => new
                    {
                        r.GameId,
                        r.Name,
                        TypeName = r.GameType == 1 ? "牌机" : "拉霸",
                        r.VisibleCount,
                        r.Source,
                        LastTime = r.LastTime.HasValue ? r.LastTime.Value.ToString("yyyy-MM-dd HH:mm:ss") : ""
                    }).ToList();
                    // lineMode：all 全部代理线 / public 公共桌台 / line 具体代理线（页面据此显示“排行来源”列）
                    string lineMode = scope == null ? "all" : scope.Length == 0 ? "public" : "line";
                    return Json(new { code = 1, rows, lines = lineAgents, lineMode });
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(RankingManageController), ex);
                return Json(new { code = 0, content = "查询失败：" + ex.Message });
            }
        }

        [AjaxOnly]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Clear(string gameIds, string line)
        {
            try
            {
                List<int> ids = RankHistoryCleanup.ParseGameIds(gameIds);
                if (ids == null) return Json(new Msg(0, "请勾选要清理的游戏！"));
                string operatorName = WebHelper.GetLoginInfo().UserName;
                List<RankHistoryCleanup.GameRow> cleared;
                int deleted;
                string scope;
                using (var ef = new GameDbContext())
                {
                    string error;
                    scope = RankHistoryCleanup.ParseLine(line, LineScopeRules.GetLineAgents(ef), out error);
                    if (error != null) return Json(new Msg(0, error));
                    deleted = RankHistoryCleanup.Clear(ef, ids, scope, out cleared);
                }
                if (cleared.Count == 0) return Json(new Msg(0, "所选游戏不在该范围的排行榜中，请刷新后重试！"));
                string scopeText = scope == null ? "全部代理线" : scope.Length == 0 ? "公共桌台" : "代理线 " + scope;
                LogHelper.WriteLog(typeof(RankingManageController), "[RankClear] operator=" + operatorName
                    + " line=" + (scope == null ? RankHistoryCleanup.AllLines : scope.Length == 0 ? RankHistoryCleanup.PublicLine : scope)
                    + " games=" + string.Join(",", cleared.Select(g => g.GameId + ":" + g.Source)) + " deleted=" + deleted);
                return Json(new Msg(1, "已清理" + scopeText + " " + cleared.Count + " 款游戏的排行榜记录，共 " + deleted + " 条；客户端重新打开排行榜即生效。"));
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(RankingManageController), ex);
                return Json(new Msg(0, "清理失败：" + ex.Message));
            }
        }
    }
}
