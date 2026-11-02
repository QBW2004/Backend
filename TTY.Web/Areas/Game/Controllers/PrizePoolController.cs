using System;
using System.Linq;
using System.Web.Mvc;
using YYT.BLL.EF;
using YYT.BLL.Services.GameServer;
using YYT.Common;
using YYT.Entity;
using YYT.Web.Controllers;
using YYT.Web.Filters;

namespace YYT.Web.Areas.Game.Controllers
{
    [MemberAuthorize]
    public class PrizePoolController : BaseController
    {
        private ActionResult Execute(Func<M_LoginUser, object> action)
        {
            try
            {
                var user = WebHelper.GetLoginInfo();
                return Json(user == null ? new Msg(0, "登录信息失效，请重新登录！") : action(user));
            }
            catch (InvalidOperationException ex) { return Json(new Msg(0, ex.Message)); }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(PrizePoolController), ex);
                return Json(new Msg(0, "奖池操作失败，请确认已初始化奖池功能后重试！"));
            }
        }

        [AjaxOnly, HttpPost]
        public ActionResult Wallet() { return Execute(user => new B_PrizePool().GetWallet(user)); }

        [AjaxOnly, HttpPost, JsonAntiForgery]
        public ActionResult Transfer(FormCollection form)
        {
            long amount;
            if (!long.TryParse(form["Amount"], out amount) || amount <= 0) return Json(new Msg(0, "充值/提取金额必须为正整数钻！"));
            return Execute(user => new B_PrizePool().Transfer(user, amount, form["RequestId"], form["Withdraw"] == "1"));
        }

        [AjaxOnly, HttpPost]
        public ActionResult Records(FormCollection form)
        {
            DateTime start, end;
            if (!DateTime.TryParse(form["StartTime"], out start) || !DateTime.TryParse(form["EndTime"], out end) || start.Date > end.Date || end.Date == DateTime.MaxValue.Date)
                return Json(new Msg(0, "请选择有效的日期范围！"));
            var page = new M_Page(Math.Max(1, Math.Min(1000000, form.Q<int>("page", 1))), Math.Max(1, Math.Min(100, form.Q<int>("rows", 20))));
            return Execute(user => new B_PrizePool().GetControlRecords(user, page, (form["ID"] ?? "").Trim(), start.Date, end.Date.AddDays(1)));
        }

        [AjaxOnly, HttpPost]
        public ActionResult Player(FormCollection form)
        {
            return Execute(user =>
            {
                string id = (form["ID"] ?? "").Trim();
                var rows = new B_Users().GetUserRowsByIds(new System.Collections.Generic.List<string> { id }, user);
                var row = rows.FirstOrDefault();
                if (row == null) return new Msg(0, "未查询到该玩家，请确认账号是否正确");
                decimal? bet = null;
                if (row.INHALL)
                {
                    var online = new PipeGameServerClient().QueryAllOnlinePlayers();
                    var live = online == null ? null : online.FirstOrDefault(p => p.ID == row.ID);
                    if (live != null && live.Status == 0 && live.CurBetUnitsPerCoin > 0)
                        bet = live.CurBetDiamonds ?? (decimal)live.CurBet / live.CurBetUnitsPerCoin.Value;
                }
                return new Msg(1, "查询成功") { datas = new { Player = row, CurrentBetDiamonds = bet } };
            });
        }

        [AjaxOnly, HttpPost]
        public ActionResult Ledger(FormCollection form)
        {
            DateTime start, end;
            if (!DateTime.TryParse(form["StartTime"], out start) || !DateTime.TryParse(form["EndTime"], out end) || start.Date > end.Date || end.Date == DateTime.MaxValue.Date)
                return Json(new Msg(0, "请选择有效的日期范围！"));
            var page = new M_Page(Math.Max(1, Math.Min(1000000, form.Q<int>("page", 1))), Math.Max(1, Math.Min(100, form.Q<int>("rows", 20))));
            return Execute(user => new B_PrizePool().GetLedger(user, form["AgentID"], form["Kind"], (form["PlayerID"] ?? "").Trim(), page, start.Date, end.Date.AddDays(1)));
        }
    }
}
