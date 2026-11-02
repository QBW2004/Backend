using System;
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
        [AjaxOnly, HttpPost, SuperAdminAuthorize]
        public ActionResult GetRabbitConfig(int tableIndex)
        {
            try
            {
                if(tableIndex<0 || tableIndex>255) throw new ArgumentException("请选择已保存的大白兔机台");
                using(var ef=new GameDbContext())
                {
                    string json=ef.Database.SqlQuery<string>("SELECT CfgJson FROM cardgamecfg WHERE GAME_ID=55 AND TableIndex={0}",tableIndex).FirstOrDefault();
                    return Json(new{code=1,config=JsonConvert.DeserializeObject(json??RabbitConfig.DefaultJson)});
                }
            }
            catch(Exception ex){return Json(new{code=0,content=ex.Message});}
        }

        /// <summary>仅超管修改独立规则；事务锁住旧活动编号，保存失败不下发部分参数。</summary>
        [AjaxOnly, HttpPost, SuperAdminAuthorize, ValidateAntiForgeryToken]
        public ActionResult SaveRabbitConfig(int tableIndex,string configJson)
        {
            try
            {
                if(tableIndex<0 || tableIndex>255) throw new ArgumentException("机台无效");
                string normalized;
                using(var ef=new GameDbContext())
                using(var tx=ef.Database.BeginTransaction())
                {
                    int maxBet=ef.Database.SqlQuery<int>("SELECT BetMax FROM roomtableconfig WHERE GAME_ID=55 AND TableIndex={0} FOR UPDATE",tableIndex).Single();
                    var config=RabbitConfig.Parse(configJson,maxBet);
                    string old=ef.Database.SqlQuery<string>("SELECT CfgJson FROM cardgamecfg WHERE GAME_ID=55 AND TableIndex={0} FOR UPDATE",tableIndex).FirstOrDefault();
                    if(old!=null && config.SelectToken("race.id").ToObject<long>()<Newtonsoft.Json.Linq.JObject.Parse(old).SelectToken("race.id").ToObject<long>())
                        throw new ArgumentException("活动编号不能减小；延长原活动保持编号，新活动使用更大的编号");
                    normalized=config.ToString(Formatting.None);
                    ef.Database.ExecuteSqlCommand("INSERT INTO cardgamecfg(GAME_ID,TableIndex,CfgJson) VALUES(55,{0},{1}) ON DUPLICATE KEY UPDATE CfgJson=VALUES(CfgJson)",tableIndex,normalized);
                    tx.Commit();
                }
                LogHelper.WriteLog(typeof(GameConfigController),"[RabbitConfig] operator="+WebHelper.GetLoginInfo().UserName+" table="+tableIndex+" config="+normalized);
                Msg hot=SendMjhlHotReload(55);
                bool sent=hot!=null && hot.code==1;
                return Json(new{code=1,hotReload=sent,content=sent?"规则已保存，热更指令已发送，下一局使用。":"规则已保存；热更未成功，请稍后再次保存重发。"});
            }
            catch(Exception ex){LogHelper.WriteLog(typeof(GameConfigController),ex);return Json(new{code=0,content=ex.Message});}
        }
    }
}

