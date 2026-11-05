using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Threading;
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
        /// 配置 RabbitRaceLedgerPath 时，直接读取游戏服权威台账，避免清库或记录漏报后虚增剩余名额。
        /// 未配置台账路径的环境沿用中奖记录统计；已配置但读取失败必须报错，不能退回不完整记录。
        /// </summary>
        public static int CountUsed(GameDbContext ef, RabbitRaceActivity activity, DateTime utcNow)
        {
            string ledgerPath = ConfigurationManager.AppSettings["RabbitRaceLedgerPath"];
            if (!string.IsNullOrWhiteSpace(ledgerPath)) return ReadLedgerUsed(ledgerPath, activity, utcNow);

            DateTime startBj = activity.QuotaDayStart(RabbitRaceActivity.BeijingNow(utcNow));
            DateTime startLocal = DateTime.SpecifyKind(startBj - RabbitRaceActivity.BeijingOffset, DateTimeKind.Utc).ToLocalTime();
            DateTime endLocal = startLocal.AddDays(1);
            return ef.Database.SqlQuery<int>(
                "SELECT COUNT(*) FROM gameprizerecord WHERE GameId={0} AND CardType={1} AND RecTime>={2} AND RecTime<{3}",
                RabbitRaceActivity.GameId, RabbitRaceActivity.PrizeName, startLocal, endLocal).FirstOrDefault();
        }

        /// <summary>游戏服文件格式为“北京活动日编号 已用次数”；旧日台账在新一轮首次中奖前仍可存在。</summary>
        private static int ReadLedgerUsed(string path, RabbitRaceActivity activity, DateTime utcNow)
        {
            const string message = "全民赛跑名额台账暂不可读，请稍后重试或检查台账路径和读取权限。";
            if (!Path.IsPathRooted(path)) throw new InvalidOperationException(message);
            long expectedDay = (long)(activity.ActivityDayStart(RabbitRaceActivity.BeijingNow(utcNow)).Date
                - new DateTime(1970, 1, 1)).TotalDays;
            Exception lastError = null;
            for (int attempt = 0; attempt < 3; attempt++)
            {
                try
                {
                    using (var file = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite | FileShare.Delete))
                    using (var reader = new StreamReader(file))
                    {
                        if (file.Length < 1 || file.Length > 128) throw new InvalidDataException("Invalid activity ledger size.");
                        string[] parts = reader.ReadToEnd().Split((char[])null, StringSplitOptions.RemoveEmptyEntries);
                        long day;
                        int used;
                        if (parts.Length != 2
                            || !long.TryParse(parts[0], NumberStyles.None, CultureInfo.InvariantCulture, out day)
                            || !int.TryParse(parts[1], NumberStyles.None, CultureInfo.InvariantCulture, out used))
                            throw new InvalidDataException("Invalid activity ledger counters.");
                        return day == expectedDay ? used : 0;
                    }
                }
                catch (IOException ex) { lastError = ex; }
                catch (InvalidDataException ex) { lastError = ex; }
                catch (UnauthorizedAccessException ex) { throw new InvalidOperationException(message, ex); }
                // 游戏服以删除旧文件、重命名临时文件替换台账，容忍该短暂间隙。
                if (attempt < 2) Thread.Sleep(10);
            }
            throw new InvalidOperationException(message, lastError);
        }
    }
}
