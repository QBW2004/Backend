using System;
using System.Collections.Generic;
using System.Linq;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace YYT.Web.Models
{
    /// <summary>理论值来自与游戏服相同的有限盘面集合，额外玩法按实际有限状态流程求期望。</summary>
    public sealed class LabaWeightMath
    {
        public sealed class Board { public int pay; public int entries; public int[] cells; }
        public sealed class Item { public int code; public string name; public int weight; public Board[] boards; }
        public sealed class Game { public int game; public string name; public int[] rat; public int[] area; public Item[] items; }
        public sealed class Catalog { public int version; public string hash; public Game[] games; }
        public sealed class Config { public bool enabled; public int[] main; public int[] extra; }
        public sealed class Profile
        {
            public int HandType { get; set; }
            public int PayoutMultiplier { get; set; }
            public int ProbabilityBasis { get; set; }
        }
        public sealed class Result
        {
            public double baseRtp, extraRtp, totalRtp, hitRate;
            public double[] areaRtp;
            public string basis;
        }
        /// <summary>
        /// 后台编辑口径：明星97、水果机每项最高 10000；水浒传全屏大奖赔率极高（全屏水浒传 45000 倍单线注），
        /// 10000 的精度放不下，改按“每 100000 次”。有未中奖项的游戏：未中奖＝口径－中奖奖型合计。额外玩法权重一律最高 10000。
        /// </summary>
        public const int Scale = 10000;
        public const int ShzScale = 100000;
        public static int ScaleOf(int game) { return game==53 ? ShzScale : Scale; }
        /// <summary>
        /// 水果机两个幸运灯各自一套奖池：右侧(灯10/面板位9)用 extra[1..11] 特殊奖 + extra[12] 吃灯；
        /// 左侧(灯22/面板位21)用 extra[28..38] + extra[39]。左侧 12 项全为 0 表示沿用右侧那套，
        /// 旧配置（只有 1..12 有值）行为不变；游戏服 LabaWeightEngine::FruitType 同一口径。
        /// </summary>
        public const int FruitPoolBStart = 28;
        public const int FruitPoolCount = 12;
        public static int[] FruitPool(Config c, int lamp)
        {
            bool useB = lamp==21 && Enumerable.Range(FruitPoolBStart,FruitPoolCount).Any(i=>c.extra[i]>0);
            var pool = new int[FruitPoolCount];
            Array.Copy(c.extra, useB ? FruitPoolBStart : 1, pool, 0, FruitPoolCount);
            return pool;
        }
        public readonly Catalog Data;
        public LabaWeightMath(string json) { Data = JsonConvert.DeserializeObject<Catalog>(json); }
        public Game Find(int game) { return Data.games.Single(g => g.game == game); }
        public Config Defaults(int game)
        {
            var c = new Config { enabled = false, main = Find(game).items.Select(i => i.weight).ToArray(), extra = new int[80] };
            c.extra[12] = 1; c.extra[21] = c.extra[22] = c.extra[23] = 1;
            for (int i = 40; i < 64; i++) c.extra[i] = 1;
            c.extra[64] = 512;
            for (int i = 0; i < 8; i++) c.extra[70+i] = Convert.ToInt32(Data.hash.Substring(i*4,4),16);
            return c;
        }
        public Config Parse(int game, string json)
        {
            JObject value = JObject.Parse(json ?? "{}");
            if (value["enabled"] == null || value["enabled"].Type != JTokenType.Boolean) throw new ArgumentException("请选择是否启用权重开奖。");
            var c = new Config { enabled = (bool)value["enabled"], main = ReadArray(value["main"], Find(game).items.Length), extra = ReadArray(value["extra"],80) };
            Validate(game,c); ValidateEditor(game,c); return c;
        }
        /// <summary>编辑页统一启用权重；仅在提交保存后生效，读取不改写存量配置。</summary>
        public Config ActivateEditor(int game, Config source)
        {
            var c = new Config { enabled = true, main = (int[])source.main.Clone(), extra = (int[])source.extra.Clone() };
            if (game == 40) c.extra[0] = 1;
            return c;
        }
        /// <summary>第 0 项是“未中奖”的游戏（明星97、水浒传）；水果机 24 灯每局必中一灯，没有未中奖项。</summary>
        public bool HasNoWin(int game)
        {
            var items=Find(game).items;
            return game!=40 && items.Length>0 && items[0].code==0;
        }
        /// <summary>后台提交（试算/保存）的额外校验：每项不超过口径；有未中奖项的游戏必须满足 未中奖＝口径－中奖奖型合计。</summary>
        public void ValidateEditor(int game, Config c)
        {
            int scale=ScaleOf(game);
            if (c.main.Any(v=>v>scale)) throw new ArgumentException("每项权重最高"+scale+"。");
            for (int i=1;i<c.extra.Length;i++)
            {
                if (i==64 || (i>=70 && i<78)) continue;
                if (c.extra[i]>Scale) throw new ArgumentException("额外玩法权重最高10000。");
            }
            if (!HasNoWin(game)) return;
            long wins=c.main.Skip(1).Sum(v=>(long)v);
            if (wins>scale) throw new ArgumentException("中奖奖型权重合计不能超过"+scale+"（当前"+wins+"）。");
            if (c.main[0]!=scale-wins) throw new ArgumentException("未中奖权重必须等于"+scale+"减中奖奖型权重合计（应为"+(scale-wins)+"）。");
        }
        /// <summary>
        /// 旧配置/默认值换算成后台编辑口径（只用于显示，保存后才生效）：明星97 合计不是 10000、水浒传合计不是 100000、
        /// 或水果机有单灯超过 10000 时，按比例换算到该口径（最大余数法取整）。不足 1 次的奖型会变成 0。
        /// </summary>
        public Config ToEditorScale(int game, Config c, out bool converted)
        {
            converted=false;
            int scale=ScaleOf(game);
            var r=new Config { enabled=c.enabled, main=(int[])c.main.Clone(), extra=(int[])c.extra.Clone() };
            long sum=r.main.Sum(v=>(long)v);
            bool need=HasNoWin(game) ? sum!=scale : r.main.Any(v=>v>scale);
            if (!need || sum<=0) return r;
            double[] exact=r.main.Select(v=>(double)v*scale/sum).ToArray();
            int[] floor=exact.Select(x=>(int)Math.Floor(x)).ToArray();
            int rest=scale-floor.Sum();
            foreach (int i in Enumerable.Range(0,floor.Length).OrderByDescending(k=>exact[k]-floor[k]).ThenBy(k=>k).Take(Math.Max(0,rest))) floor[i]++;
            if (HasNoWin(game)) floor[0]=scale-floor.Skip(1).Sum();
            r.main=floor; converted=true;
            return r;
        }
        /// <summary>读取数据库下发快照，缺失的0权重不能补值，否则会与游戏服完整性校验不一致。</summary>
        public Config ReadProfiles(int game, IEnumerable<Profile> profiles)
        {
            var rows=profiles.ToList(); var c=Defaults(game);
            if (rows.Count==0) return c;
            if (rows.GroupBy(r=>r.HandType).Any(g=>g.Count()!=1)) throw new ArgumentException("权重配置包含重复项目，请检查保存数据。");
            var mode=rows.SingleOrDefault(r=>r.HandType==1000);
            if (mode==null || mode.PayoutMultiplier!=1 || (mode.ProbabilityBasis!=0 && mode.ProbabilityBasis!=1)) throw new ArgumentException("权重配置缺少有效的格式版本与启用标记。");
            c.enabled=mode.ProbabilityBasis==1;
            int mainCount=rows.Count(r=>r.HandType>=1100 && r.HandType<1100+c.main.Length);
            if ((c.enabled || mainCount>0) && mainCount!=c.main.Length) throw new ArgumentException("开奖权重配置不完整，0权重项目也必须保存；游戏服不会应用此配置。");
            if (c.enabled && rows.Count(r=>r.HandType>=1270 && r.HandType<=1277)!=8) throw new ArgumentException("权重配置缺少规则目录指纹，游戏服不会应用此配置。");
            foreach (var row in rows)
            {
                if (row.ProbabilityBasis<0 || row.ProbabilityBasis>1000000) throw new ArgumentException("权重超出有效范围。");
                if (row.HandType==1000) continue;
                if (row.HandType>=1100 && row.HandType<1100+c.main.Length) c.main[row.HandType-1100]=row.ProbabilityBasis;
                else if (row.HandType>=1200 && row.HandType<1280) c.extra[row.HandType-1200]=row.ProbabilityBasis;
                else throw new ArgumentException("权重配置含有当前规则不支持的项目。");
            }
            Validate(game,c); return c;
        }
        /// <summary>编码完整主奖型和必要的额外参数，保存与回读复用同一份协议约定。</summary>
        public List<Profile> WriteProfiles(int game, Config c)
        {
            Validate(game,c); var defaults=Defaults(game);
            var rows=new List<Profile> { new Profile { HandType=1000,PayoutMultiplier=1,ProbabilityBasis=c.enabled ? 1 : 0 } };
            for (int i=0;i<c.main.Length;i++) rows.Add(new Profile { HandType=1100+i,ProbabilityBasis=c.main[i] });
            for (int i=0;i<80;i++) if (c.extra[i]!=defaults.extra[i] || i>=70 && i<78)
                rows.Add(new Profile { HandType=1200+i,ProbabilityBasis=c.extra[i] });
            return rows;
        }
        private static int[] ReadArray(JToken token, int count)
        {
            var values = token as JArray;
            if (values == null || values.Count != count) throw new ArgumentException("权重配置不完整，请刷新后重试。");
            var result = new int[count];
            for (int i=0;i<count;i++)
            {
                if (values[i].Type != JTokenType.Integer || (long)values[i] < 0 || (long)values[i] > 1000000) throw new ArgumentException("权重必须为0至1000000的整数，0表示不抽取。");
                result[i] = (int)values[i];
            }
            return result;
        }
        public void Validate(int game, Config c)
        {
            if (c.main.Length != Find(game).items.Length || c.extra.Length != 80 || c.main.Any(v => v<0 || v>1000000) || c.extra.Any(v => v<0 || v>1000000)) throw new ArgumentException("非法权重。");
            for (int i=0;i<8;i++) if (c.extra[70+i] != Convert.ToInt32(Data.hash.Substring(i*4,4),16)) throw new ArgumentException("计算目录已更新，请刷新页面。");
            if (c.main.Sum(v=>(long)v) <= 0) throw new ArgumentException("至少一项开奖权重必须大于0。");
            if (c.extra[0]>1 || c.extra[20]>10000 || c.extra[24]+c.extra[25]>10000 || c.extra[26]>10000 || c.extra[27]>10000) throw new ArgumentException("额外玩法概率范围为0至10000，半额与全额概率之和不得超过10000。");
            if (c.extra[64]<27 || c.extra[64]>512) throw new ArgumentException("小玛丽回合上限范围为27至512。");
            if (c.extra[0] == 1 && game==16 && c.extra[20]>0 && c.extra.Skip(21).Take(3).Sum()==0) throw new ArgumentException("明星倍触发时至少设置一个倍数权重。");
            if (game==53 && c.extra.Skip(40).Take(24).Sum()==0) throw new ArgumentException("小玛丽外圈至少设置一个权重。");
            if (game==40)
            {
                double award=c.extra.Skip(1).Take(12).Sum(v=>(double)v);
                if (c.extra[0]==1 && award==0) throw new ArgumentException("右侧幸运灯（灯10）至少配置一种特殊奖或吃灯权重；左侧留空时沿用右侧。");
            }
        }
        public Result Calculate(int game, Config c, int bet)
        {
            Validate(game,c);
            if (bet<1 || bet>1000000) throw new ArgumentException("试算单局下注范围为1至1000000。");
            if (game==40) return Fruit(c);
            Game g=Find(game); double sum=c.main.Sum(v=>(double)v), mean=0, hit=0, mary=0;
            double cost=game==16 ? 8 : 9;
            double[] maryValues=new double[28];
            if (game==53) maryValues=Mary(c);
            for (int i=0;i<g.items.Length;i++)
            {
                Board[] boards=g.items[i].boards; double p=c.main[i]/sum/boards.Length;
                foreach (Board b in boards)
                {
                    mean+=p*b.pay/cost;
                    if (b.pay>0) hit+=p;
                    mary+=p*maryValues[b.entries]/cost;
                }
            }
            double extra=game==53 ? mary : 0;
            return new Result { baseRtp=mean*100, extraRtp=extra*100, totalRtp=(mean+extra)*100, hitRate=hit*100,
                basis=game==16 ? "八线齐押，单局消耗=单线注×8；全盘奖只赔全盘倍数不叠加线奖；无明星倍/BONUS/系统奖。" : "九线齐押，单局消耗=单线注×9；双边对奖，全盘奖按总押注且不叠加线奖；小玛丽恒开启，含内圈三同/四同及回合上限强制退出。" };
        }
        private static double[] Mary(Config c)
        {
            int[] outer={-1,5,7,1,8,6,-1,3,5,7,8,2,-1,4,6,8,5,1,-1,7,3,8,6,2};
            int[] ratio={0,200,100,70,50,20,10,5,2};
            double sum=0, exit=0, reward=0;
            for (int i=0;i<24;i++) { double w=c.extra[40+i]; sum+=w; if (outer[i]<0) exit+=w; else reward+=w*(ratio[outer[i]]*.5+780.0/512.0); }
            var next=new double[28]; var current=new double[28];
            for (int t=c.extra[64]-1;t>=0;t--)
            {
                for (int e=1;e<=27;e++) current[e]=t>=c.extra[64]-e ? 0 : reward/sum+(1-exit/sum)*next[e]+exit/sum*next[e-1];
                Array.Copy(current,next,28);
            }
            return next;
        }
        private Result Fruit(Config c)
        {
            Game g=Find(40); double sum=c.main.Sum(v=>(double)v);
            int[] poolA=FruitPool(c,9), poolB=FruitPool(c,21);
            double awardA=poolA.Sum(v=>(double)v), awardB=poolB.Sum(v=>(double)v);
            double p9=c.main[9]/sum, p21=c.main[21]/sum;
            var main=new double[8]; var extra=new double[8]; var areas=new double[8];
            for (int i=0;i<24;i++) if (g.area[i]>=0) main[g.area[i]]+=c.main[i]/sum*g.rat[i];
            for (int type=0;type<11;type++)
            {
                double chanceA=c.extra[0]==1 ? (awardA>0 ? poolA[type]/awardA : 0) : (type==6 ? 0.5 : 0);
                double chanceB=c.extra[0]==1 ? (awardB>0 ? poolB[type]/awardB : 0) : (type==6 ? 0.5 : 0);
                if (chanceA<=0 && chanceB<=0) continue;
                double[] value=FruitAward(g,type);
                for (int a=0;a<8;a++) extra[a]+=(p9*chanceA+p21*chanceB)*value[a];
            }
            for (int a=0;a<8;a++) areas[a]=(main[a]+extra[a])*100;
            double baseMean=main.Average()*100, total=areas.Average();
            return new Result { baseRtp=baseMean, extraRtp=total-baseMean,totalRtp=total,areaRtp=areas,
                basis="八区等额下注为总RTP；单押或不等额下注按各区RTP加权。两个幸运灯各有奖池（灯10 右侧用 extra[1..12]，灯22 左侧用 extra[28..39]，左侧全 0 时沿用右侧），按“送1-5个灯或者吃灯”（额外玩法开启时按特殊奖/吃灯权重）计入，无免费局；不包括人为控牌、比倍和余额容量拒绝。" };
        }
        private static double[] FruitAward(Game g, int type)
        {
            int[][] fixedSets={new[]{1,2,7},new[]{8,16,21},new[]{5,11,17,23},new[]{3,6,9,12,15,18,20,24},new[]{1,2,4,5,7,8,11,13,14,16,17,19,21,23},Enumerable.Range(1,24).Where(v=>v!=10 && v!=22).ToArray()};
            var result=new double[8]; Action<IEnumerable<int>,double> add=(targets,p)=> { foreach (int lamp in targets) if (g.area[lamp-1]>=0) result[g.area[lamp-1]]+=p*g.rat[lamp-1]; };
            if (type<=4) add(fixedSets[type],1);
            else if (type==5)
                for (int row=0;row<4;row++) add(Enumerable.Range(0,7).Select(i=>(row*6+i)%24+1).Where(v=>v!=10 && v!=22),.25);
            else if (type==7)
                for (int count=3;count<=8;count++) for (int start=1;start<=24;start++)
                    add(Enumerable.Range(0,24).Select(i=>(start-1+i)%24+1).Where(v=>v!=10 && v!=22).Take(count),1.0/144);
            else add(fixedSets[5],(type==6 ? 3.0 : type-1)/22.0);
            return result;
        }
    }
}
