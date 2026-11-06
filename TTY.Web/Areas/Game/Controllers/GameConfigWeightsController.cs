using System;
using System.Collections.Generic;
using System.IO;
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
    public partial class GameConfigController
    {
        private LabaWeightMath WeightMath()
        { return new LabaWeightMath(System.IO.File.ReadAllText(Server.MapPath("~/Config/laba-weight-catalog.json"))); }
        private static void CheckWeightScope(int game, int table)
        { if ((game!=16 && game!=40 && game!=53) || table<0 || table>=LineTables.MaxTablesFor(3)) throw new ArgumentException("请选择三款拉霸的有效机台（0至"+(LineTables.MaxTablesFor(3)-1)+"）。"); }

        private static void CheckWeightProfileCount(long count)
        {
            // 中心与三款拉霸已支持 8MiB 分片；1000 桌及 U16 条权重的载荷小于该上限。
            // 分片不改变配置条数的 U16 编码，仍须在事务写入前拒绝溢出。
            if (count > ushort.MaxValue)
                throw new ArgumentException("该游戏的配置条目总数超过中心服协议上限（65535 条），请先清理不用的桌台配置。");
        }

        [AjaxOnly, HttpPost]
        public ActionResult GetLabaWeights(int gameId, int tableIndex, bool newTable=false)
        {
            try
            {
                CheckWeightScope(gameId,tableIndex); var math=WeightMath(); var config=math.Defaults(gameId);
                bool stale=false;
                if (!newTable) using (var ef=new GameDbContext())
                {
                    var rows=ef.Database.SqlQuery<LabaWeightMath.Profile>("SELECT HandType,ProbabilityBasis,PayoutMultiplier FROM cardpayoutprofile WHERE GAME_ID={0} AND TableId={1} AND HandType BETWEEN 1000 AND 1279 AND Enabled=1",gameId,tableIndex).ToList();
                    // 规则/目录更新后旧权重的指纹或奖型数量不再匹配，游戏服也不会应用；回退默认值供重新设置保存
                    try { config=math.ReadProfiles(gameId,rows); }
                    catch (ArgumentException) { config=math.Defaults(gameId); stale=true; }
                }
                // 后台按“每 10000 次”（水浒传每 100000 次）编辑：旧配置/默认值先按比例换算显示，保存后才生效
                bool converted;
                config=math.ToEditorScale(gameId,config,out converted);
                bool activationPending=!config.enabled || (gameId==40 && config.extra[0]!=1);
                config=math.ActivateEditor(gameId,config);
                LabaWeightMath.Result previewResult=null;
                string validationError=null;
                try { math.ValidateEditor(gameId,config); previewResult=math.Calculate(gameId,config,1); }
                catch (ArgumentException ex) { validationError=ex.Message; }
                var game=math.Find(gameId);
                return Json(new { code=1, config, stale, converted, activationPending, validationError, scale=LabaWeightMath.ScaleOf(gameId), hash=math.Data.hash, game=game.name,
                    items=game.items.Select((i,index)=>new { i.code,i.name, mean=i.boards.Length>0 ? i.boards.Average(b=>b.pay) : 0, multiplier=gameId==40 ? game.rat[index] : 0 }),
                    result=previewResult });
            }
            catch (Exception ex) { return Json(new { code=0,content=ex.Message }); }
        }

        [AjaxOnly, HttpPost, ValidateAntiForgeryToken]
        public ActionResult PreviewLabaWeights(int gameId, int tableIndex, string weightsJson, int bet=1)
        {
            try { CheckWeightScope(gameId,tableIndex); var math=WeightMath(); return Json(new { code=1,result=math.Calculate(gameId,math.ActivateEditor(gameId,math.Parse(gameId,weightsJson)),bet) }); }
            catch (Exception ex) { return Json(new { code=0,content=ex.Message }); }
        }

        /// <summary>权重作为完整独立配置事务保存，预览不落库；失败不写入半套参数。</summary>
        [AjaxOnly, HttpPost, ValidateAntiForgeryToken, SuperAdminAuthorize]
        public ActionResult SaveLabaWeights(int gameId, int tableIndex, string weightsJson, int bet=1)
        {
            try
            {
                CheckWeightScope(gameId,tableIndex); var math=WeightMath(); var c=math.ActivateEditor(gameId,math.Parse(gameId,weightsJson));
                var result=math.Calculate(gameId,c,bet);
                var rows=math.WriteProfiles(gameId,c);
                using (var ef=new GameDbContext()) using (var tx=ef.Database.BeginTransaction())
                {
                    WriteLabaWeightProfiles(ef,gameId,tableIndex,rows);
                    tx.Commit();
                }
                LogHelper.WriteLog(typeof(GameConfigController),"[LabaWeights] operator="+WebHelper.GetLoginInfo().UserName+" game="+gameId+" table="+tableIndex+" catalog="+math.Data.hash+" config="+JsonConvert.SerializeObject(c));
                Msg hot=null;
                try { hot=new SConnect().SendPcCommand((ushort)gameId); } catch (Exception ex) { LogHelper.WriteLog(typeof(GameConfigController),ex); }
                return Json(new { code=1,content=hot!=null && hot.code==1 ? "权重已保存；热更指令已发送，游戏服接收后下一局使用新配置。" : "权重已保存；热更指令尚未成功，当前游戏服可能仍使用旧配置，请重试热更。",result,hotReload=hot!=null && hot.code==1 });
            }
            catch (Exception ex) { LogHelper.WriteLog(typeof(GameConfigController),ex); return Json(new { code=0,content=ex.Message }); }
        }

        private static void WriteLabaWeightProfiles(GameDbContext ef, int gameId, int tableIndex, IList<LabaWeightMath.Profile> rows)
        {
            if (ef.Database.SqlQuery<int>("SELECT COUNT(*) FROM roomtableconfig WHERE GAME_ID={0} AND RoomIndex=0 AND TableIndex={1}",gameId,tableIndex).Single()==0)
                throw new ArgumentException("请先保存基础桌台，再保存开奖权重。");
            int others=ef.Database.SqlQuery<int>("SELECT COUNT(*) FROM cardpayoutprofile WHERE GAME_ID={0} AND NOT (TableId={1} AND HandType BETWEEN 1000 AND 1279)",gameId,tableIndex).Single();
            CheckWeightProfileCount((long)others+rows.Count);
            ef.Database.ExecuteSqlCommand("DELETE FROM cardpayoutprofile WHERE GAME_ID={0} AND TableId={1} AND HandType BETWEEN 1000 AND 1279",gameId,tableIndex);
            foreach (var row in rows)
                ef.Database.ExecuteSqlCommand("INSERT INTO cardpayoutprofile (GAME_ID,TableId,HandType,PayoutMultiplier,ProbabilityBasis,StockLimit,StockRemain,Enabled) VALUES ({0},{1},{2},{3},{4},-1,-1,1)",gameId,tableIndex,row.HandType,row.PayoutMultiplier,row.ProbabilityBasis);
        }
    }
}
