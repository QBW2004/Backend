using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using Newtonsoft.Json;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Remote;
using YYT.Web.Models;

namespace YYT.Web.Areas.Game.Controllers
{
    /// <summary>麻将胡了(54) 按桌「出货率」（权重）配置：独立保存/删除，保存后发 PC 热更，游戏服下一局使用。</summary>
    public partial class GameConfigController
    {
        private const string MjhlWeightScope = "HandType BETWEEN 2000 AND 2199";

        private static void CheckMjhlScope(int gameId, int tableIndex)
        {
            if (gameId != MjhlWeightProfile.GameId || tableIndex < 0 || tableIndex > 255)
                throw new ArgumentException("请选择麻将胡了的有效桌台（0至255）。");
        }

        private static Msg SendMjhlHotReload(int gameId)
        {
            try { return new SConnect().SendPcCommand((ushort)gameId); }
            catch (Exception ex) { LogHelper.WriteLog(typeof(GameConfigController), ex); return null; }
        }

        [AjaxOnly, HttpPost]
        public ActionResult GetMjhlWeights(int gameId, int tableIndex)
        {
            try
            {
                CheckMjhlScope(gameId, tableIndex);
                using (var ef = new GameDbContext())
                {
                    var rows = ef.Database.SqlQuery<MjhlWeightProfile.Row>(
                        "SELECT HandType,PayoutMultiplier,ProbabilityBasis,StockLimit,StockRemain,Enabled FROM cardpayoutprofile WHERE GAME_ID={0} AND TableId={1} AND " + MjhlWeightScope,
                        gameId, tableIndex).ToList();
                    var config = MjhlWeightProfile.ReadRows(rows);
                    return Json(new { code = 1, configured = config != null, config });
                }
            }
            catch (Exception ex) { return Json(new { code = 0, content = ex.Message }); }
        }

        /// <summary>整套配置在一个事务里替换；simulated 为页面最近一次模拟摘要，仅写日志备查。</summary>
        [AjaxOnly, HttpPost, ValidateAntiForgeryToken, SuperAdminAuthorize]
        public ActionResult SaveMjhlWeights(int gameId, int tableIndex, string configJson, string simulated)
        {
            try
            {
                CheckMjhlScope(gameId, tableIndex);
                var config = MjhlWeightProfile.Parse(configJson);
                var rows = MjhlWeightProfile.WriteRows(config);
                using (var ef = new GameDbContext())
                using (var tx = ef.Database.BeginTransaction())
                {
                    if (ef.Database.SqlQuery<int>("SELECT COUNT(*) FROM roomtableconfig WHERE GAME_ID={0} AND RoomIndex=0 AND TableIndex={1}", gameId, tableIndex).Single() == 0)
                        throw new ArgumentException("请先保存基础桌台，再保存出货率。");
                    int others = ef.Database.SqlQuery<int>("SELECT COUNT(*) FROM cardpayoutprofile WHERE GAME_ID={0} AND NOT (TableId={1} AND " + MjhlWeightScope + ")", gameId, tableIndex).Single();
                    int tables = ef.Database.SqlQuery<int>("SELECT COUNT(*) FROM roomtableconfig WHERE GAME_ID={0}", gameId).Single();
                    // 中心服把本游戏全部桌台参数 + cardpayoutprofile 放进一帧下发（上限 65531 字节，每行 52 字节）
                    if ((others + rows.Count) * 52L + tables * 218L + 8192 > 60000)
                        throw new ArgumentException("麻将胡了的配置总量接近中心服单帧上限（约 35 桌出货率），请先删除不用的桌台或其出货率配置。");
                    ef.Database.ExecuteSqlCommand("DELETE FROM cardpayoutprofile WHERE GAME_ID={0} AND TableId={1} AND " + MjhlWeightScope, gameId, tableIndex);
                    foreach (var r in rows)
                        ef.Database.ExecuteSqlCommand(
                            "INSERT INTO cardpayoutprofile (GAME_ID,TableId,HandType,PayoutMultiplier,ProbabilityBasis,StockLimit,StockRemain,Enabled) VALUES ({0},{1},{2},{3},{4},{5},{6},{7})",
                            gameId, tableIndex, r.HandType, r.PayoutMultiplier, r.ProbabilityBasis, r.StockLimit, r.StockRemain, r.Enabled);
                    tx.Commit();
                }
                LogHelper.WriteLog(typeof(GameConfigController), "[MjhlWeights] save operator=" + WebHelper.GetLoginInfo().UserName + " table=" + tableIndex
                    + " simulated=" + (simulated ?? "") + " config=" + JsonConvert.SerializeObject(config));
                Msg hot = SendMjhlHotReload(gameId);
                bool ok = hot != null && hot.code == 1;
                return Json(new
                {
                    code = 1,
                    hotReload = ok,
                    content = ok ? "出货率已保存；热更指令已发送，游戏服下一局使用新配置。" : "出货率已保存；热更指令尚未成功，游戏服可能仍在使用旧配置，请稍后重新保存一次以重发热更。"
                });
            }
            catch (Exception ex) { LogHelper.WriteLog(typeof(GameConfigController), ex); return Json(new { code = 0, content = ex.Message }); }
        }

        /// <summary>删除本桌出货率配置：游戏服收到热更后本桌恢复原分档算法。</summary>
        [AjaxOnly, HttpPost, ValidateAntiForgeryToken, SuperAdminAuthorize]
        public ActionResult DeleteMjhlWeights(int gameId, int tableIndex)
        {
            try
            {
                CheckMjhlScope(gameId, tableIndex);
                int removed;
                using (var ef = new GameDbContext())
                    removed = ef.Database.ExecuteSqlCommand("DELETE FROM cardpayoutprofile WHERE GAME_ID={0} AND TableId={1} AND " + MjhlWeightScope, gameId, tableIndex);
                LogHelper.WriteLog(typeof(GameConfigController), "[MjhlWeights] delete operator=" + WebHelper.GetLoginInfo().UserName + " table=" + tableIndex + " rows=" + removed);
                Msg hot = SendMjhlHotReload(gameId);
                bool ok = hot != null && hot.code == 1;
                return Json(new
                {
                    code = 1,
                    hotReload = ok,
                    content = (removed > 0 ? "已删除本桌出货率配置" : "本桌原本就没有出货率配置")
                        + (ok ? "；热更指令已发送，本桌下一局恢复原分档算法。" : "；热更指令尚未成功，请稍后重试。")
                });
            }
            catch (Exception ex) { LogHelper.WriteLog(typeof(GameConfigController), ex); return Json(new { code = 0, content = ex.Message }); }
        }
    }
}
