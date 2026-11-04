using System;
using System.Linq;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using YYT.BLL.EF;
using YYT.Entity;

namespace YYT.Web.Models
{
    /// <summary>大白兔玩法规则按桌台保存，与本桌参数同事务下发。</summary>
    public static class RabbitConfig
    {
        public const string SharedKey = "rabbit_rules"; // 仅作为旧桌缺失独立配置时的只读兼容值。

        public static string NormalizeTable(string json, int maxBet)
        {
            var config = Parse(json, maxBet);
            config["race"]["enabled"] = false;
            return config.ToString(Formatting.None);
        }

        public static string ReadTable(GameDbContext ef, int tableIndex, out string source, bool forUpdate = false)
        {
            if (tableIndex < -1 || tableIndex > 255) throw new ArgumentException("机台无效");
            if (tableIndex >= 0)
            {
                string json = ef.Database.SqlQuery<string>(
                    "SELECT CfgJson FROM cardgamecfg WHERE GAME_ID=55 AND TableIndex={0}" + (forUpdate ? " FOR UPDATE" : ""), tableIndex).FirstOrDefault();
                if (json != null) { source = "table"; return json; }
                var legacy = ActivityConfigs.TableExists(ef) ? ActivityConfigs.Load(ef, SharedKey) : null;
                if (legacy != null) { source = "legacy"; return legacy.CfgJson; }
            }
            source = "default";
            return DefaultJson;
        }

        // 调用方负责事务；只校验和更新当前桌台，不写入旧共用规则或其他桌台。
        public static void SaveTable(GameDbContext ef, int tableIndex, string json, int maxBet, bool isNew = false)
        {
            if (tableIndex < 0 || tableIndex > 255) throw new ArgumentException("机台无效");
            string source;
            json = NormalizeTable(json ?? (isNew ? DefaultJson : ReadTable(ef, tableIndex, out source, true)), maxBet);
            ef.Database.ExecuteSqlCommand(
                "INSERT INTO cardgamecfg(GAME_ID,TableIndex,CfgJson) VALUES(55,{0},{1}) ON DUPLICATE KEY UPDATE CfgJson=VALUES(CfgJson)",
                tableIndex, json);
        }

        public const string DefaultJson = @"{""schemaVersion"":3,""smallFourMultiplier"":50,""specialRules"":{""authentic"":{""enabled"":true,""baseMultiplier"":80,""revealTimeoutSeconds"":20,""multipliers"":{""values"":[1,2,3,4,5,6,7,8,9,10,11,12,13,14],""weights"":[60,30,10,0,0,0,0,0,0,0,0,0,0,0]}},""five"":{""enabled"":true,""baseMultiplier"":250,""successMultiplier"":2,""missMultiplier"":1,""revealTimeoutSeconds"":20,""successChance"":{""numerator"":1,""denominator"":3},""forcedSuccessChance"":{""numerator"":1,""denominator"":4}},""streak"":{""enabled"":true,""burnRounds"":20,""poolContributionBasisPoints"":200,""initialPool"":0,""awardCounts"":{""values"":[2,3,4,5,6,7,8,9,10,11,12,13],""weights"":[8,32,22,22,20,20,12,12,7,7,3,3]},""startChance"":{""numerator"":1,""denominator"":100},""continueChance"":{""numerator"":1,""denominator"":18},""expiredChance"":{""numerator"":1,""denominator"":20},""secondJokerChance"":{""numerator"":1,""denominator"":10},""jokerFirstChance"":{""numerator"":9,""denominator"":10},""guaranteeLastRound"":true,""blockHigherPrizes"":true},""settlement"":{""passEnabled"":true,""explodeEnabled"":true}},""passTarget"":30000,""passBonus"":3000,""explodeTarget"":100000,""explodeBonus"":10000,""keepMax"":3,""keepMinHands"":10,""race"":{""enabled"":false,""id"":0,""start"":0,""end"":0,""total"":0,""multiplier"":1}}";
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
        private static void Chance(JObject root, string path)
        {
            long denominator = Number(root,path + ".denominator",1,int.MaxValue);
            Number(root,path + ".numerator",0,denominator);
        }
        private static void Weighted(JObject root, string path, int maximum)
        {
            var values = root.SelectToken(path + ".values") as JArray;
            var weights = root.SelectToken(path + ".weights") as JArray;
            if (values == null || weights == null || values.Count == 0 || values.Count > maximum || values.Count != weights.Count)
                throw new ArgumentException(path + " 数值和权重数量不匹配");
            long sum = 0;
            for(int i=0;i<values.Count;i++)
            {
                Number(root,path + ".values[" + i + "]",1,maximum);
                sum += Number(root,path + ".weights[" + i + "]",0,int.MaxValue);
            }
            if(values.Select(v=>v.Value<int>()).Distinct().Count()!=values.Count || sum<1 || sum>int.MaxValue)
                throw new ArgumentException(path + " 数值重复或权重总量无效");
        }
        public static JObject Parse(string json, int maxBet)
        {
            if(string.IsNullOrWhiteSpace(json) || System.Text.Encoding.UTF8.GetByteCount(json)>16384) throw new ArgumentException("规则为空或过长");
            var root = JObject.Parse(json);
            Number(root,"schemaVersion",3,3);
            if(maxBet<1) throw new ArgumentException("请先保存有效的最高押分");
            long small=Number(root,"smallFourMultiplier",1,int.MaxValue);
            const string a="specialRules.authentic", f="specialRules.five", s="specialRules.streak";
            Flag(root,a+".enabled");Flag(root,f+".enabled");Flag(root,s+".enabled");
            long authentic=Number(root,a+".baseMultiplier",1,int.MaxValue), five=Number(root,f+".baseMultiplier",1,int.MaxValue);
            long reveal=Number(root,a+".revealTimeoutSeconds",1,120);
            Number(root,f+".revealTimeoutSeconds",reveal,reveal);
            long miss=Number(root,f+".missMultiplier",1,255), success=Number(root,f+".successMultiplier",miss,255);
            Weighted(root,a+".multipliers",14);Weighted(root,s+".awardCounts",255);
            Chance(root,f+".successChance");Chance(root,f+".forcedSuccessChance");
            foreach(string key in new[]{"startChance","continueChance","expiredChance","secondJokerChance","jokerFirstChance"}) Chance(root,s+"."+key);
            Number(root,s+".burnRounds",1,255);Number(root,s+".poolContributionBasisPoints",0,10000);Number(root,s+".initialPool",0,9007199254740991L);
            Flag(root,s+".guaranteeLastRound");Flag(root,s+".blockHigherPrizes");
            Flag(root,"specialRules.settlement.passEnabled");Flag(root,"specialRules.settlement.explodeEnabled");
            Number(root,"passTarget",1,int.MaxValue);Number(root,"explodeTarget",1,int.MaxValue);
            long bonuses=Number(root,"passBonus",0,int.MaxValue)+Number(root,"explodeBonus",0,int.MaxValue);
            if(bonuses>int.MaxValue) throw new ArgumentException("彩金合计超出分数容量");
            Number(root,"keepMax",1,255);Number(root,"keepMinHands",0,1000000);
            Flag(root,"race.enabled");long id=Number(root,"race.id",0,9007199254740991L), start=Number(root,"race.start",0,4102444800L), end=Number(root,"race.end",0,4102444800L);
            long total=Number(root,"race.total",0,9007199254740991L), multiplier=Number(root,"race.multiplier",1,int.MaxValue);
            if(root.SelectToken("race.enabled").Value<bool>() && (id==0 || end<=start || total==0)) throw new ArgumentException("赛跑开启时必须填写活动编号、起止时间及额度");
            long highest=Math.Max(1000,Math.Max(small,Math.Max(authentic*14,five*success)));
            if(highest*maxBet>int.MaxValue || multiplier*maxBet>int.MaxValue) throw new ArgumentException("最高押分与奖励倍率超出分数容量");
            return root;
        }
    }
}
