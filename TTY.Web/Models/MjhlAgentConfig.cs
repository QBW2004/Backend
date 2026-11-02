using System;
using System.Globalization;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace YYT.Web.Models
{
    /// <summary>顶层代理线独立配置。金额是显示钻，保存时精确校验到十分之一原分；不改玩家控制协议。</summary>
    public sealed class MjhlAgentConfig
    {
        public int gameId;
        public decimal targetRtp;
        public decimal goldChance;
        public bool scatterEnabled;
        public bool freeRetrigger;
        public MjhlWeightProfile.Weights weights;
        public BetConfig bets;
        public const long MaxRawUnits = 42949672950L;

        public sealed class BetConfig
        {
            public decimal min;
            public decimal max;
            public decimal[] chips;
            public decimal entry;
            public int scorePerCoin;
        }

        public static MjhlAgentConfig Default()
        {
            return new MjhlAgentConfig
            {
                gameId = 54, targetRtp = 96, goldChance = 8, scatterEnabled = true, freeRetrigger = true,
                weights = new MjhlWeightProfile.Weights
                {
                    n = new[] { new[]{1561,1469,1469,1469,1561}, new[]{1560,1469,1469,1469,1560}, new[]{656,618,618,618,656}, new[]{656,617,617,617,656}, new[]{496,467,467,467,496}, new[]{209,196,196,196,209}, new[]{146,137,137,137,146}, new[]{110,104,104,104,110}, new[]{824,776,776,776,824}, new[]{0,20,20,20,0}, new[]{0,568,568,568,0} },
                    f = new[] { new[]{546,514,514,514,546}, new[]{546,514,514,514,546}, new[]{230,216,216,216,230}, new[]{230,216,216,216,230}, new[]{174,164,164,164,174}, new[]{73,69,69,69,73}, new[]{51,48,48,48,51}, new[]{38,36,36,36,38}, new[]{288,271,271,271,288}, new[]{0,20,20,20,0}, new[]{0,568,568,568,0} }
                },
                bets = new BetConfig { min = .4m, max = 20m, chips = new[]{.4m,.8m,1.2m,2m,4m,8m,20m}, entry = .4m, scorePerCoin = 100 }
            };
        }

        private static void ExactKeys(JObject obj, string names)
        {
            string[] keys = names.Split(',');
            if (obj == null || keys.Any(k => obj[k] == null) || obj.Properties().Any(p => !keys.Contains(p.Name)))
                throw new ArgumentException("配置项不完整或包含旧字段，请刷新页面后重试。");
        }

        /// <summary>JSON.NET 转成 int 时会四舍五入，先按原始十进制数校验，避免后台保存的权重与输入不一致。</summary>
        private static void RequireIntegral(JToken token)
        {
            if (token == null || (token.Type != JTokenType.Integer && token.Type != JTokenType.Float))
                throw new ArgumentException("游戏编号、每钻原分和牌型权重必须为整数。");
            decimal value = token.Value<decimal>();
            if (value != decimal.Truncate(value))
                throw new ArgumentException("游戏编号、每钻原分和牌型权重必须为整数。");
        }

        public static MjhlAgentConfig Parse(string json)
        {
            if (string.IsNullOrWhiteSpace(json) || Encoding.UTF8.GetByteCount(json) > 32768)
                throw new ArgumentException("配置为空或超过 32KB。");
            try
            {
                JObject root = JsonConvert.DeserializeObject<JObject>(json, new JsonSerializerSettings { FloatParseHandling = FloatParseHandling.Decimal, DateParseHandling = DateParseHandling.None, MaxDepth = 16 });
                ExactKeys(root, "gameId,targetRtp,goldChance,scatterEnabled,freeRetrigger,weights,bets");
                ExactKeys(root["weights"] as JObject, "n,f");
                ExactKeys(root["bets"] as JObject, "min,max,chips,entry,scorePerCoin");
                foreach (string key in new[]{"scatterEnabled","freeRetrigger"})
                    if (root[key].Type != JTokenType.Boolean) throw new ArgumentException("开关必须为布尔值。");
                foreach (JToken token in root.Descendants().Where(t => t is JValue && t.Path != "scatterEnabled" && t.Path != "freeRetrigger"))
                    if (token.Type != JTokenType.Integer && token.Type != JTokenType.Float)
                        throw new ArgumentException("数值配置不能包含空值、布尔值或字符串。");
                RequireIntegral(root["gameId"]);
                RequireIntegral(root["bets"]["scorePerCoin"]);
                foreach (JToken token in ((JObject)root["weights"]).Descendants().Where(t => t is JValue))
                    RequireIntegral(token);
                var config = root.ToObject<MjhlAgentConfig>();
                config.Validate();
                return config;
            }
            catch (JsonException) { throw new ArgumentException("配置 JSON 格式不正确。"); }
            catch (OverflowException) { throw new ArgumentException("配置数值超出范围。"); }
        }

        public void Validate()
        {
            if (gameId != 54) throw new ArgumentException("此配置仅支持麻将胡了。");
            if (targetRtp < 0 || targetRtp > 1000) throw new ArgumentException("目标 RTP 范围为 0～1000%。");
            if (goldChance < 0 || goldChance > 100 || goldChance * 100 != decimal.Truncate(goldChance * 100))
                throw new ArgumentException("金色牌概率为 0～100%，最多两位小数。");
            if (weights == null) throw new ArgumentException("缺少牌型权重。");
            foreach (int[][] matrix in new[]{weights.n, weights.f})
            {
                if (matrix == null || matrix.Length != 11 || matrix.Any(row => row == null || row.Length != 5))
                    throw new ArgumentException("普通和免费权重均需 11 种牌 × 5 轴。");
                for (int col = 0; col < 5; col++)
                {
                    if (matrix.Any(row => row[col] < 0 || row[col] > 10000) || matrix.Sum(row => (long)row[col]) > 10000)
                        throw new ArgumentException("每轴权重为非负整数，合计不能超过 10000。");
                    if ((col == 0 || col == 4) && matrix[9][col] != 0) throw new ArgumentException("百搭只允许在第 2～4 轴自然出现。");
                }
            }
            if (bets == null || bets.scorePerCoin < 1 || bets.scorePerCoin > 100000) throw new ArgumentException("每钻原分须为 1～100000 的整数。");
            if (bets.min < .4m || bets.max < bets.min) throw new ArgumentException("最低筹码至少 0.4 钻，最高不能低于最低。");
            RawUnits(bets.min, bets.scorePerCoin); RawUnits(bets.max, bets.scorePerCoin); RawUnits(bets.entry, bets.scorePerCoin);
            if (bets.chips == null || bets.chips.Length < 1 || bets.chips.Length > 200) throw new ArgumentException("筹码列表须有 1～200 档。");
            decimal previous = -1;
            foreach (decimal chip in bets.chips)
            {
                if (chip < bets.min || chip > bets.max || chip <= previous) throw new ArgumentException("筹码须在最低/最高范围内，去重并从小到大排列。");
                RawUnits(chip, bets.scorePerCoin); previous = chip;
            }
            if (!bets.chips.Contains(bets.entry)) throw new ArgumentException("进场默认筹码必须属于筹码列表。");
        }

        public static long RawUnits(decimal coins, int scorePerCoin)
        {
            if (coins < 0 || decimal.Round(coins, 5) != coins) throw new ArgumentException("钻金额最多保留五位小数。");
            decimal raw = coins * scorePerCoin * 10m;
            if (raw != decimal.Truncate(raw) || raw < 1 || raw > MaxRawUnits) throw new ArgumentException("筹码换算后须为 0.1 原分的整数倍，且不能超过钱包范围。");
            return (long)raw;
        }

        public string ToJson() { return JsonConvert.SerializeObject(this, Formatting.None); }
        public string ConfigHash()
        {
            using (var sha = SHA256.Create()) return BitConverter.ToString(sha.ComputeHash(Encoding.UTF8.GetBytes(ToJson()))).Replace("-", "").ToLowerInvariant();
        }

        public static bool CanRead(int privilege, string ownLine, string requestedLine)
        {
            return privilege == 0 || (!string.IsNullOrEmpty(ownLine) && string.Equals(ownLine, requestedLine, StringComparison.OrdinalIgnoreCase));
        }
    }
}
