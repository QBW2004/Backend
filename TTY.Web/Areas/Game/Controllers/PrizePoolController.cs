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
        [ReadOnlySession] // 只读会话：不排会话锁（2026-11-04）
        public ActionResult Wallet() { return Execute(user => new B_PrizePool().GetWallet(user)); }

        [AjaxOnly, HttpPost, JsonAntiForgery]
        public ActionResult Transfer(FormCollection form)
        {
            long amount;
            if (!long.TryParse(form["Amount"], out amount) || amount <= 0) return Json(new Msg(0, "充值/提取金额必须为正整数钻！"));
            return Execute(user => new B_PrizePool().Transfer(user, amount, form["RequestId"], form["Withdraw"] == "1"));
        }

        [AjaxOnly, HttpPost]
        [ReadOnlySession] // 只读会话：不排会话锁（2026-11-04）
        public ActionResult Records(FormCollection form)
        {
            // 手机端送奖明细带时分（yyyy-MM-dd HH:mm，按分钟精确）；只传日期时仍按整天
            DateTime start, end;
            if (!B_Records_MySQL.TryParseQueryRange(form["StartTime"], form["EndTime"], out start, out end))
                return Json(new Msg(0, "请选择有效的时间范围！"));
            var page = new M_Page(Math.Max(1, Math.Min(1000000, form.Q<int>("page", 1))), Math.Max(1, Math.Min(100, form.Q<int>("rows", 20))));
            return Execute(user => new B_PrizePool().GetControlRecords(user, page, (form["ID"] ?? "").Trim(), start, end, form.Q<int>("CardAction", 0)));
        }

        [AjaxOnly, HttpPost, JsonAntiForgery]
        public ActionResult RemoveRecord(FormCollection form)
        {
            int controlId, mode;
            string id = (form["ID"] ?? "").Trim();
            if (!int.TryParse(form["ControlId"], out controlId) || controlId <= 0 ||
                !int.TryParse(form["Mode"], out mode) || mode < 4 || mode > 6 || id.Length == 0)
                return Json(new Msg(0, "无效的送奖记录！"));
            return Execute(user => new B_UserControl().CloseTotalControl(user, id, mode, true, controlId));
        }

        [AjaxOnly, HttpPost]
        [ReadOnlySession] // 只读会话：不排会话锁（2026-11-04）
        public ActionResult CardQuote(FormCollection form)
        {
            return Execute(user =>
            {
                string id = (form["ID"] ?? "").Trim();
                var rows = new B_Users().GetUserRowsByIds(new System.Collections.Generic.List<string> { id }, user, false);
                if (!rows.Any()) return new Msg(0, "无权操作该玩家！");
                if (user.UserPriv != 0 && user.IsRelease != 1) return new Msg(0, "没有控牌权限！");
                var quote = B_PrizePool.QuoteCard(id, form.Q<int>("CardAction"), form.Q<int>("CardValue"), 1);
                var wallet = new B_PrizePool().GetWallet(user);
                if (wallet.code != 1) return wallet;
                return new Msg(1, "查询成功") { datas = new { Quote = quote, Wallet = wallet.datas } };
            });
        }

        [AjaxOnly, HttpPost]
        [ReadOnlySession] // 只读会话：不排会话锁（2026-11-04）
        public ActionResult Player(FormCollection form)
        {
            return Execute(user =>
            {
                string id = (form["ID"] ?? "").Trim();
                var rows = new B_Users().GetUserRowsByIds(new System.Collections.Generic.List<string> { id }, user);
                var row = rows.FirstOrDefault();
                if (row == null) return new Msg(0, "未查询到该玩家，请确认账号是否正确");
                decimal? bet = null;
                int? gameId = null;
                if (row.INHALL)
                {
                    var online = new PipeGameServerClient().QueryAllOnlinePlayers();
                    var live = online == null ? null : online.FirstOrDefault(p => p.ID == row.ID);
                    if (live != null && live.Status == 0 && live.CurBetUnitsPerCoin > 0)
                        bet = live.CurBetDiamonds ?? (decimal)live.CurBet / live.CurBetUnitsPerCoin.Value;
                    // 当前所在游戏：手机送奖页据此默认选中“送奖+对应游戏类型”（大厅/房间内为 0）
                    if (live != null && live.Status == 0) gameId = live.GameID;
                }
                return new Msg(1, "查询成功") { datas = new { Player = row, CurrentBetDiamonds = bet, CurrentGameId = gameId } };
            });
        }

        [AjaxOnly, HttpPost]
        [ReadOnlySession] // 只读会话：不排会话锁（2026-11-04）
        public ActionResult Ledger(FormCollection form)
        {
            // 手机端奖池明细带时分（按分钟精确）；只传日期时仍按整天
            DateTime start, end;
            if (!B_Records_MySQL.TryParseQueryRange(form["StartTime"], form["EndTime"], out start, out end))
                return Json(new Msg(0, "请选择有效的时间范围！"));
            var page = new M_Page(Math.Max(1, Math.Min(1000000, form.Q<int>("page", 1))), Math.Max(1, Math.Min(100, form.Q<int>("rows", 20))));
            return Execute(user => new B_PrizePool().GetLedger(user, form["AgentID"], form["Kind"], (form["PlayerID"] ?? "").Trim(), page, start, end));
        }
    }
}
