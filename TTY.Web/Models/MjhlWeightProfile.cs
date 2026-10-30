using System;
using System.Collections.Generic;
using System.Linq;
using Newtonsoft.Json;

namespace YYT.Web.Models
{
    /// <summary>
    /// 麻将胡了(54) 出货率（权重）配置：页面 JSON ↔ cardpayoutprofile 行。
    /// 存储口径与游戏服 MTH-Server/ServerCardMjhl/MjhlWeight.h 的 ProfileBuilder 一致，改一处必须同步另一处：
    ///   HandType 2000+mode*20+idx（mode 0 普通/1 免费；idx 0..8=符号1..9，9 百搭，10 至尊）：
    ///     PayoutMultiplier=轴1，ProbabilityBasis=轴2，StockLimit=轴3×10^7+轴4，StockRemain=轴5，Enabled=该牌启用；
    ///   HandType 2100：PayoutMultiplier=第2/4轴及普通第3轴金色概率(%×100)；其余列为旧版免费参数兼容位，现固定写 0/0/0/1，不再改变免费规则；
    ///   HandType 2101：PayoutMultiplier=版本 1，ProbabilityBasis=每轴总权重，StockLimit=目标RTP×10×10^5+目标至尊率×100，StockRemain=模拟局数×10^5+试算精度（仅页面用）。
    /// 杂牌权重不存：= 总权重 − 其它启用牌权重。
    /// </summary>
    public static class MjhlWeightProfile
    {
        public const int GameId = 54;
        public const int HandTypeFirst = 2000, HandTypeSettings = 2100, HandTypeMeta = 2101, HandTypeLast = 2199;
        public const int SymbolCount = 11, WildIndex = 9, ScatterIndex = 10;
        public const long Pack = 10000000L;
        public const int WeightMax = 1000000;
        /// <summary>每桌行数（普通/免费各 11 行 + 设置 + 版本）。</summary>
        public const int RowsPerTable = SymbolCount * 2 + 2;
        public static readonly string[] Names = { "二条", "二筒", "五条", "五筒", "八万", "白板", "红中", "发财", "三筒", "百搭牌", "至尊牌" };

        public sealed class Weights { public int[][] n; public int[][] f; }
        public sealed class Config
        {
            public int version;
            public int weightTotal;
            public bool[] enabled;
            public Weights weights;
            public decimal goldChance;
            // 保留旧 JSON/数据库格式；免费奖励固定按至尊数量计算，不能通过这些字段覆盖。
            public bool retrigger;
            public int retriggerAward;
            public int retriggerLimit;
            public int freeLimit;
            public decimal targetRtp;
            public decimal targetScatter;
            public int spinCount;
            public int calibrationSamples;
        }
        public sealed class Row
        {
            public int HandType { get; set; }
            public int PayoutMultiplier { get; set; }
            public int ProbabilityBasis { get; set; }
            public long StockLimit { get; set; }
            public long StockRemain { get; set; }
            public int Enabled { get; set; }
        }

        public static Config Parse(string json)
        {
            Config c;
            try { c = JsonConvert.DeserializeObject<Config>(json ?? ""); }
            catch (JsonException) { throw new ArgumentException("出货率配置格式不正确，请刷新页面后重试。"); }
            NormalizeRules(c);
            Validate(c);
            return c;
        }

        static void Range(List<string> errors, string label, decimal value, decimal min, decimal max, bool integer)
        {
            if (value < min || value > max || (integer && value != decimal.Truncate(value)))
                errors.Add(label + "：请填写" + min + "至" + max + "之间的" + (integer ? "整数" : "数值") + "。");
        }

        private static void NormalizeRules(Config c)
        {
            if (c == null) return;
            c.retrigger = true;
            c.retriggerAward = 0;
            c.retriggerLimit = 0;
            c.freeLimit = 0;
        }

        /// <summary>与 mjhl.engine.js validate、MjhlWeight::Finalize 同口径；不合法抛 ArgumentException（多条原因换行拼接）。</summary>
        public static void Validate(Config c)
        {
            var errors = new List<string>();
            if (c == null || c.version != 1) throw new ArgumentException("出货率配置版本不正确，请刷新页面后重试。");
            Range(errors, "每轴总权重", c.weightTotal, 100, WeightMax, true);
            Range(errors, "目标总RTP（%）", c.targetRtp, 1, 150, false);
            Range(errors, "模拟完整付费回合数", c.spinCount, 100, 1000000, true);
            Range(errors, "自动分配试算精度", c.calibrationSamples, 1000, 20000, true);
            Range(errors, "金色牌出现概率（%）", c.goldChance, 0, 100, false);
            Range(errors, "目标至尊触发率（%）", c.targetScatter, 0, 100, false);
            if (c.goldChance * 100 != decimal.Truncate(c.goldChance * 100)) errors.Add("金色牌出现概率最多保留两位小数。");
            if (c.enabled == null || c.enabled.Length != SymbolCount) errors.Add("启用标志不完整。");
            else if (!c.enabled.Take(9).Any(x => x)) errors.Add("请至少启用一种普通赔付牌。");
            if (c.weights == null) errors.Add("权重表不完整。");
            else
            {
                foreach (var mode in new[] { new { name = "普通", rows = c.weights.n }, new { name = "免费", rows = c.weights.f } })
                {
                    if (mode.rows == null || mode.rows.Length != SymbolCount || mode.rows.Any(r => r == null || r.Length != 5)) { errors.Add("权重表不完整。"); continue; }
                    for (int col = 0; col < 5; col++)
                    {
                        long used = 0;
                        for (int s = 0; s < SymbolCount; s++)
                        {
                            int w = mode.rows[s][col];
                            if (w < 0 || w > WeightMax) { errors.Add(Names[s] + "权重必须为0至1000000的整数。"); continue; }
                            if ((col == 0 || col == 4) && w != 0 && s == WildIndex) errors.Add(Names[s] + "只能出现在第2–4轴。");
                            if (c.enabled != null && c.enabled.Length == SymbolCount && c.enabled[s]) used += w;
                        }
                        if (used > c.weightTotal) errors.Add(mode.name + "轴" + (col + 1) + "：其它牌权重" + used + "超过总量" + c.weightTotal + "，请降低其它权重。");
                    }
                }
            }
            if (errors.Count > 0) throw new ArgumentException(string.Join("\n", errors.Distinct()));
        }

        public static List<Row> WriteRows(Config c)
        {
            NormalizeRules(c);
            Validate(c);
            var rows = new List<Row>();
            for (int m = 0; m < 2; m++)
            {
                int[][] src = m == 0 ? c.weights.n : c.weights.f;
                for (int s = 0; s < SymbolCount; s++)
                {
                    int[] w = src[s];
                    rows.Add(new Row
                    {
                        HandType = HandTypeFirst + m * 20 + s,
                        PayoutMultiplier = w[0],
                        ProbabilityBasis = w[1],
                        StockLimit = w[2] * Pack + w[3],
                        StockRemain = w[4],
                        Enabled = c.enabled[s] ? 1 : 0
                    });
                }
            }
            rows.Add(new Row
            {
                HandType = HandTypeSettings,
                PayoutMultiplier = (int)(c.goldChance * 100),
                ProbabilityBasis = c.freeLimit,
                StockLimit = c.retriggerAward,
                StockRemain = c.retriggerLimit,
                Enabled = c.retrigger ? 1 : 0
            });
            rows.Add(new Row
            {
                HandType = HandTypeMeta,
                PayoutMultiplier = 1,
                ProbabilityBasis = c.weightTotal,
                StockLimit = (long)decimal.Round(c.targetRtp * 10) * 100000L + (long)decimal.Round(c.targetScatter * 100),
                StockRemain = c.spinCount * 100000L + c.calibrationSamples,
                Enabled = 1
            });
            return rows;
        }

        /// <summary>无行返回 null（该桌未配置，游戏服走原分档算法）；行不完整/重复/越界抛 ArgumentException。</summary>
        public static Config ReadRows(IEnumerable<Row> source)
        {
            var rows = source.Where(r => r.HandType >= HandTypeFirst && r.HandType <= HandTypeLast).ToList();
            if (rows.Count == 0) return null;
            if (rows.GroupBy(r => r.HandType).Any(g => g.Count() > 1)) throw new ArgumentException("本桌出货率配置存在重复行，请重新保存。");
            var map = rows.ToDictionary(r => r.HandType);
            Func<int, Row> get = ht =>
            {
                Row r;
                if (!map.TryGetValue(ht, out r)) throw new ArgumentException("本桌出货率配置不完整（缺少 " + ht + "），请重新保存。");
                return r;
            };
            Row meta = get(HandTypeMeta), settings = get(HandTypeSettings);
            if (meta.PayoutMultiplier != 1) throw new ArgumentException("本桌出货率配置版本不受支持，请重新保存。");
            var c = new Config
            {
                version = 1,
                weightTotal = meta.ProbabilityBasis,
                enabled = new bool[SymbolCount],
                weights = new Weights { n = new int[SymbolCount][], f = new int[SymbolCount][] },
                goldChance = settings.PayoutMultiplier / 100m,
                // 旧行只保留金色概率；旧重触发开关和次数上限不再影响玩法。
                freeLimit = 0,
                retriggerAward = 0,
                retriggerLimit = 0,
                retrigger = true,
                targetRtp = (meta.StockLimit / 100000L) / 10m,
                targetScatter = (meta.StockLimit % 100000L) / 100m,
                spinCount = (int)(meta.StockRemain / 100000L),
                calibrationSamples = (int)(meta.StockRemain % 100000L)
            };
            for (int m = 0; m < 2; m++)
                for (int s = 0; s < SymbolCount; s++)
                {
                    Row r = get(HandTypeFirst + m * 20 + s);
                    if (r.StockLimit < 0 || r.StockRemain < 0) throw new ArgumentException("本桌出货率配置权重越界，请重新保存。");
                    int[] w = { r.PayoutMultiplier, r.ProbabilityBasis, (int)(r.StockLimit / Pack), (int)(r.StockLimit % Pack), (int)r.StockRemain };
                    if (m == 0) { c.weights.n[s] = w; c.enabled[s] = r.Enabled != 0; }
                    else
                    {
                        c.weights.f[s] = w;
                        if ((r.Enabled != 0) != c.enabled[s]) throw new ArgumentException("本桌出货率配置启用标志不一致，请重新保存。");
                    }
                }
            // 页面专用字段越界时回到默认值，不影响开奖配置的读取
            if (c.targetRtp < 1 || c.targetRtp > 150) c.targetRtp = 90;
            if (c.targetScatter < 0 || c.targetScatter > 100) c.targetScatter = 5;
            if (c.spinCount < 100 || c.spinCount > 1000000) c.spinCount = 10000;
            if (c.calibrationSamples < 1000 || c.calibrationSamples > 20000) c.calibrationSamples = 5000;
            Validate(c);
            return c;
        }

        /// <summary>
        /// 押注档位规则（与 MjhlWeight::BuildBetLadder 一致）：最小/最大押注与每次加减分值至少0.1分、最多一位小数，最大≥最小、档位不超过200个。
        /// 合法返回 null，否则返回提示文字。
        /// </summary>
        public static string CheckBetLadder(decimal betMin, decimal betMax, decimal step)
        {
            if (betMin < 0.1m || betMax < betMin || step < 0.1m)
                return "麻将胡了的最小押注和每次增加的分值至少 0.1 分，且最大押注不能小于最小押注！";
            if (betMax > int.MaxValue / 10m || step > 6553.5m)
                return "麻将胡了的押注参数超出可保存范围！";
            if (betMin * 10 != decimal.Truncate(betMin * 10) || betMax * 10 != decimal.Truncate(betMax * 10) || step * 10 != decimal.Truncate(step * 10))
                return "麻将胡了的最小/最大押注和每次增加的分值最多保留一位小数！";
            decimal minUnits = betMin * 10, maxUnits = betMax * 10, stepUnits = step * 10;
            decimal count = decimal.Floor((maxUnits - minUnits) / stepUnits) + 1 + ((maxUnits - minUnits) % stepUnits != 0 ? 1 : 0);
            if (count > 200) return "麻将胡了押注档位不能超过 200 个，请加大每次增加的分值或缩小押注范围！";
            return null;
        }
    }
}
