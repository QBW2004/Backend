using System;
using System.Linq;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace YYT.Web.Models
{
    /// <summary>火凤凰独立规则：仅正宗大四梅启用开关与倍数权重档；完整校验后才替换，无效配置不下发。</summary>
    public static class PhenixConfig
    {
        public const string DefaultJson = @"{""schemaVersion"":1,""specialRules"":{""authentic"":{""enabled"":true,""multipliers"":{""values"":[1,2,3],""weights"":[60,30,10]}}}}";
        private static long Number(JObject root, string path, long min, long max)
        {
            JToken token = root.SelectToken(path);
            if (token == null || token.Type != JTokenType.Integer) throw new ArgumentException(path + " 必须是整数");
            long value = token.Value<long>();
            if (value < min || value > max) throw new ArgumentException(path + " 超出范围 " + min + "～" + max);
            return value;
        }
        private static void Flag(JObject root, string path)
        {
            JToken token = root.SelectToken(path);
            if (token == null || token.Type != JTokenType.Boolean) throw new ArgumentException(path + " 必须是开关");
        }
        private static void Weighted(JObject root, string path, int maximum)
        {
            var values = root.SelectToken(path + ".values") as JArray;
            var weights = root.SelectToken(path + ".weights") as JArray;
            if (values == null || weights == null || values.Count == 0 || values.Count > maximum || values.Count != weights.Count)
                throw new ArgumentException(path + " 数值和权重数量不匹配");
            long sum = 0;
            for (int i = 0; i < values.Count; i++)
            {
                Number(root, path + ".values[" + i + "]", 1, maximum);
                sum += Number(root, path + ".weights[" + i + "]", 0, int.MaxValue);
            }
            if (values.Select(v => v.Value<int>()).Distinct().Count() != values.Count || sum < 1 || sum > int.MaxValue)
                throw new ArgumentException(path + " 数值重复或权重总量无效");
        }
        public static JObject Parse(string json, int maxBet)
        {
            if (string.IsNullOrWhiteSpace(json) || System.Text.Encoding.UTF8.GetByteCount(json) > 16384) throw new ArgumentException("规则为空或过长");
            var root = JObject.Parse(json);
            Number(root, "schemaVersion", 1, 1);
            if (maxBet < 1) throw new ArgumentException("请先保存有效的最高押分");
            const string a = "specialRules.authentic";
            Flag(root, a + ".enabled");
            Weighted(root, a + ".multipliers", 14);
            int vmax = ((JArray)root.SelectToken(a + ".multipliers.values")).Max(v => v.Value<int>());
            long highest = Math.Max(1000L, 80L * vmax);
            if (highest * maxBet > int.MaxValue) throw new ArgumentException("最高押分与倍率超出分数容量");
            return root;
        }
    }
}
