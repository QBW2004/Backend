using System;
using System.Collections.Generic;
using System.Linq;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace YYT.BLL.EF
{
    /// <summary>
    /// 全民赛跑活动（2026-11-03，后台「系统设置/活动配置」）：大白兔(55)全服一份配置。
    /// 每日北京时间固定时段开放；换牌开出勾选牌型（小四梅及以上）时额外送「押分 × 倍数」活动奖金，
    /// 每触发一次扣一次当日总名额，名额用完当天停止派送。活动奖金在换牌时直接入分（客户端先滚活动奖金），
    /// 牌型得分仍需玩家点击得分。与按桌「全兔赛跑」相互独立，同一手两者都中时只发本活动。
    /// 存 activityconfig.CfgJson，经中心服 0x5621 原样下发游戏服 RabbitActivity.h，字段名两端一致。
    /// </summary>
    public class RabbitRaceActivity
    {
        public const string Key = "rabbit_race";
        public const int GameId = 55;
        /// <summary>中奖记录 gameprizerecord.CardType，游戏服 ReportPrizeRecord 同名；按它统计当日已派次数。</summary>
        public const string PrizeName = "全民赛跑";
        public const int FirstType = 7, LastType = 12;
        /// <summary>可勾选牌型：与游戏服 te_CardsType、客户端 RabbitRules.Chinese 同序号。</summary>
        public static readonly Dictionary<int, string> TypeNames = new Dictionary<int, string>
        {
            { 7, "小四梅" }, { 8, "大四梅" }, { 9, "同花顺" }, { 10, "五梅" }, { 11, "同花大顺" }, { 12, "五兔王" }
        };
        public static readonly TimeSpan BeijingOffset = TimeSpan.FromHours(8);

        public bool Enabled { get; set; }
        /// <summary>北京时间当天第几分钟（0~1439）；开始大于结束表示跨零点，凌晨段属于前一天的活动。</summary>
        public int StartMinute { get; set; }
        public int EndMinute { get; set; }
        public int DailyQuota { get; set; }
        public int Multiplier { get; set; }
        public List<int> Types { get; set; }

        public static RabbitRaceActivity Default()
        {
            return new RabbitRaceActivity { Enabled = false, StartMinute = 10 * 60, EndMinute = 22 * 60, DailyQuota = 50, Multiplier = 10, Types = new List<int> { 7, 8, 9, 10, 11, 12 } };
        }

        /// <summary>返回 null 表示通过；关闭状态也要求字段合法，避免下次开启时带着坏值。</summary>
        public string Validate()
        {
            if (StartMinute < 0 || StartMinute > 1439 || EndMinute < 0 || EndMinute > 1439) return "开始/结束时间无效！";
            if (StartMinute == EndMinute) return "开始时间与结束时间不能相同！";
            if (DailyQuota < 1 || DailyQuota > 1000000) return "每日奖励总名额须为 1～1000000！";
            if (Multiplier < 1 || Multiplier > 100000) return "押分倍数须为 1～100000！";
            if (Types == null || Types.Count == 0) return "请至少勾选一个触发牌型！";
            if (Types.Any(t => t < FirstType || t > LastType)) return "触发牌型只能是四梅及以上！";
            return null;
        }

        public string ToJson()
        {
            var types = (Types ?? new List<int>()).Distinct().OrderBy(t => t).ToList();
            var root = new JObject
            {
                ["schemaVersion"] = 1,
                ["enabled"] = Enabled,
                ["startMinute"] = StartMinute,
                ["endMinute"] = EndMinute,
                ["dailyQuota"] = DailyQuota,
                ["multiplier"] = Multiplier,
                ["types"] = new JArray(types)
            };
            return root.ToString(Formatting.None);
        }

        public static RabbitRaceActivity Parse(string json)
        {
            if (string.IsNullOrWhiteSpace(json)) return null;
            JObject root = JObject.Parse(json);
            return new RabbitRaceActivity
            {
                Enabled = root.Value<bool?>("enabled") ?? false,
                StartMinute = root.Value<int?>("startMinute") ?? 0,
                EndMinute = root.Value<int?>("endMinute") ?? 0,
                DailyQuota = root.Value<int?>("dailyQuota") ?? 0,
                Multiplier = root.Value<int?>("multiplier") ?? 1,
                Types = root["types"] is JArray arr ? arr.Select(t => t.Value<int>()).ToList() : new List<int>()
            };
        }

        /// <summary>"HH:mm" ↔ 分钟。</summary>
        public static string FormatMinute(int minute) { return (minute / 60).ToString("00") + ":" + (minute % 60).ToString("00"); }
        public static int ParseMinute(string text)
        {
            TimeSpan t;
            if (string.IsNullOrWhiteSpace(text) || !TimeSpan.TryParseExact(text.Trim(), "hh\\:mm", null, out t) || t.TotalMinutes >= 1440) return -1;
            return (int)t.TotalMinutes;
        }

        public string TypeText()
        {
            var types = (Types ?? new List<int>()).Distinct().OrderBy(t => t).ToList();
            if (types.Count == LastType - FirstType + 1) return "四梅及以上";
            return string.Join("、", types.Where(TypeNames.ContainsKey).Select(t => TypeNames[t]));
        }

        public static DateTime BeijingNow(DateTime utcNow) { return utcNow + BeijingOffset; }

        public bool IsOpen(DateTime beijingNow)
        {
            if (!Enabled) return false;
            int minute = beijingNow.Hour * 60 + beijingNow.Minute;
            return StartMinute < EndMinute ? minute >= StartMinute && minute < EndMinute : minute >= StartMinute || minute < EndMinute;
        }

        /// <summary>最近一次到达的活动开放起点（北京时间）；下一次开始前仍属于上一轮，与游戏服 ActivityDay 同口径。</summary>
        public DateTime ActivityDayStart(DateTime beijingNow)
        {
            DateTime day = beijingNow.Date;
            int minute = beijingNow.Hour * 60 + beijingNow.Minute;
            if (minute < StartMinute) day = day.AddDays(-1);
            return day.AddMinutes(StartMinute);
        }

        /// <summary>最近已开始的一轮所用名额的记录起点；下一轮开始前保留上一轮计数。
        /// 统计完整活动日，避免修改开始时间后漏掉当天较早已扣的名额。</summary>
        public DateTime QuotaDayStart(DateTime beijingNow)
        {
            DateTime day = ActivityDayStart(beijingNow).Date;
            return StartMinute > EndMinute ? day.AddMinutes(EndMinute) : day;
        }
    }

    /// <summary>activityconfig 表读写与当日派发统计。</summary>
    public static class ActivityConfigs
    {
        public class Row
        {
            public string ActivityKey { get; set; }
            public int Enabled { get; set; }
            public string CfgJson { get; set; }
            public string Operator { get; set; }
            public DateTime? UpdateTime { get; set; }
        }

        public static bool TableExists(GameDbContext ef)
        {
            return ef.Database.SqlQuery<int>(
                "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='activityconfig'")
                .FirstOrDefault() > 0;
        }

        public static Row Load(GameDbContext ef, string key)
        {
            return ef.Database.SqlQuery<Row>(
                "SELECT ActivityKey, Enabled, CfgJson, Operator, UpdateTime FROM activityconfig WHERE ActivityKey={0} LIMIT 1", key)
                .FirstOrDefault();
        }

        public static void Save(GameDbContext ef, string key, int gameId, bool enabled, string json, string operatorName)
        {
            ef.Database.ExecuteSqlCommand(
                "INSERT INTO activityconfig(ActivityKey,GameId,Enabled,CfgJson,Operator,UpdateTime) VALUES({0},{1},{2},{3},{4},NOW()) " +
                "ON DUPLICATE KEY UPDATE GameId=VALUES(GameId),Enabled=VALUES(Enabled),CfgJson=VALUES(CfgJson),Operator=VALUES(Operator),UpdateTime=NOW()",
                key, gameId, enabled ? 1 : 0, json, operatorName ?? string.Empty);
        }

        public static RabbitRaceActivity LoadRabbitRace(GameDbContext ef)
        {
            if (!TableExists(ef)) return null;
            Row row = Load(ef, RabbitRaceActivity.Key);
            return row == null ? null : RabbitRaceActivity.Parse(row.CfgJson);
        }

        /// <summary>
        /// 当前活动日已派发次数：按游戏服上报的「全民赛跑」中奖记录计数（gameprizerecord 7 天滚动，当日足够）。
        /// RecTime 为服务器本地时间，统计区间由北京时间换算；游戏服名额台账才是派发权威，此处仅供公示与后台查看。
        /// </summary>
        public static int CountUsed(GameDbContext ef, RabbitRaceActivity activity, DateTime utcNow)
        {
            DateTime startBj = activity.QuotaDayStart(RabbitRaceActivity.BeijingNow(utcNow));
            DateTime startLocal = DateTime.SpecifyKind(startBj - RabbitRaceActivity.BeijingOffset, DateTimeKind.Utc).ToLocalTime();
            DateTime endLocal = startLocal.AddDays(1);
            return ef.Database.SqlQuery<int>(
                "SELECT COUNT(*) FROM gameprizerecord WHERE GameId={0} AND CardType={1} AND RecTime>={2} AND RecTime<{3}",
                RabbitRaceActivity.GameId, RabbitRaceActivity.PrizeName, startLocal, endLocal).FirstOrDefault();
        }
    }
}
