using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Http;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;

namespace YYT.Web.Controllers.Api
{
    /// <summary>
    /// 客户端大厅「全民赛跑」入口与公示：GET api/RabbitRaceActivity?account=玩家账号。
    /// 只在「活动已开启 + 大白兔(55)已启用 + 该玩家所在代理线开放了大白兔」时 show=true，
    /// 否则客户端隐藏活动图标（关闭活动、代理线未开放大白兔都不展示）。不带账号一律不展示。
    /// 剩余名额按当日「全民赛跑」中奖记录统计（见 ActivityConfigs.CountUsed），派发权威在游戏服。
    /// </summary>
    public class RabbitRaceActivityController : ApiController
    {
        public class ActivityModel
        {
            public bool show { get; set; }
            public bool open { get; set; }
            public string startTime { get; set; }
            public string endTime { get; set; }
            public int multiplier { get; set; }
            public int dailyQuota { get; set; }
            public int remaining { get; set; }
            public string typeText { get; set; }
            public List<int> types { get; set; }
        }

        [HttpGet]
        public Msg Get(string account = null)
        {
            Msg msg = new Msg(10000, "查询成功！") { datas = new ActivityModel { show = false } };
            try
            {
                if (string.IsNullOrWhiteSpace(account)) return msg;
                string playerId = account.Trim();
                using (var ef = new GameDbContext())
                {
                    RabbitRaceActivity cfg = ActivityConfigs.LoadRabbitRace(ef);
                    if (cfg == null || !cfg.Enabled || cfg.Validate() != null) return msg;
                    bool gameOn = ef.Database.SqlQuery<int>("SELECT COUNT(*) FROM games WHERE GameId={0} AND Enable=1", RabbitRaceActivity.GameId).FirstOrDefault() > 0;
                    if (!gameOn) return msg;
                    if (!ef.Users.AsNoTracking().Any(u => u.ID == playerId)) return msg;
                    List<int> playable = LineScopeRules.GetPlayableGamesOfPlayer(ef, playerId);
                    if (playable != null && !playable.Contains(RabbitRaceActivity.GameId)) return msg;
                    int used = ActivityConfigs.CountUsed(ef, cfg, DateTime.UtcNow);
                    msg.datas = new ActivityModel
                    {
                        show = true,
                        open = cfg.IsOpen(RabbitRaceActivity.BeijingNow(DateTime.UtcNow)),
                        startTime = RabbitRaceActivity.FormatMinute(cfg.StartMinute),
                        endTime = RabbitRaceActivity.FormatMinute(cfg.EndMinute),
                        multiplier = cfg.Multiplier,
                        dailyQuota = cfg.DailyQuota,
                        remaining = Math.Max(0, cfg.DailyQuota - used),
                        typeText = cfg.TypeText(),
                        types = cfg.Types.Distinct().OrderBy(t => t).ToList()
                    };
                }
            }
            catch (Exception ex)
            {
                // 查询异常按不展示处理，不能让大厅因活动接口失败而报错。
                LogHelper.WriteLog(typeof(RabbitRaceActivityController), ex);
                msg.datas = new ActivityModel { show = false };
            }
            return msg;
        }
    }
}
