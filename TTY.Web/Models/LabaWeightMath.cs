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
            Validate(game,c); return c;
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
            if (c.extra[0] == 1 && game==53 && c.extra.Skip(40).Take(24).Sum()==0) throw new ArgumentException("小玛丽外圈至少设置一个权重。");
            if (game==40)
            {
                double sum=c.main.Sum(v=>(double)v), award=c.extra.Skip(1).Take(12).Sum(v=>(double)v);
                if (c.extra[0]==1 && award==0) throw new ArgumentException("幸运灯至少配置一种特殊奖或免费局权重。");
                double free=c.extra[0]==1 ? c.extra[12]/award : 1;
                if ((2*c.main[9]+4.5*c.main[21])*free>=sum) throw new ArgumentException("免费局期望派生次数必须小于1，否则无法结束且RTP无穷大。");
            }
        }
        public Result Calculate(int game, Config c, int bet)
        {
            Validate(game,c);
            if (bet<1 || bet>1000000) throw new ArgumentException("试算单局下注范围为1至1000000。");
            if (game==40) return Fruit(c);
            double cost=game==16 ? 8 : 9;
            Game g=Find(game); double sum=c.main.Sum(v=>(double)v), mean=0, half=0, hit=0, mary=0;
            double[] maryValues=new double[28];
            if (game==53 && c.extra[0]==1) maryValues=Mary(c);
            for (int i=0;i<g.items.Length;i++)
            {
                Board[] boards=g.items[i].boards; double p=c.main[i]/sum/boards.Length;
                foreach (Board b in boards)
                {
                    mean+=p*b.pay; half+=p*Math.Floor((double)b.pay*bet/2)/bet;
                    if (b.pay>0) hit+=p;
                    mary+=p*maryValues[b.entries];
                }
            }
            double extra=0;
            if (c.extra[0]==1 && game==16)
            {
                double trigger=hit*c.extra[20]/10000.0, sw=c.extra.Skip(21).Take(3).Sum();
                double multiplier=sw>0 ? (2.0*c.extra[21]+3.0*c.extra[22]+4.0*c.extra[23])/sw : 1;
                extra=mean*(5*trigger/(1+5*trigger))*(multiplier-1)+half*c.extra[24]/10000.0+mean*c.extra[25]/10000.0+c.extra[26]/10000.0*c.extra[27];
            }
            else if (game==53) extra=mary;
            return new Result { baseRtp=mean*100/cost, extraRtp=extra*100/cost, totalRtp=(mean+extra)*100/cost, hitRate=hit*100,
                basis=game==16 ? "八线齐押，单局扣注=单线注×8；计入叠加线奖、明星倍五个后续付费局的稳态期望、BONUS整数取半和系统奖。" : "九线齐押，单局扣注=单线注×9；全屏奖与线奖叠加，小玛丽含内圈三同/四同及回合上限强制退出。" };
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
            Game g=Find(40); double sum=c.main.Sum(v=>(double)v), lucky=(c.main[9]+c.main[21])/sum;
            double award=c.extra.Skip(1).Take(12).Sum(v=>(double)v), free=c.extra[0]==1 ? c.extra[12]/award : 1;
            double growth=(2*c.main[9]+4.5*c.main[21])/sum*free;
            var main=new double[8]; var extra=new double[8]; var areas=new double[8];
            for (int i=0;i<24;i++) if (g.area[i]>=0) main[g.area[i]]+=c.main[i]/sum*g.rat[i];
            if (c.extra[0]==1)
                for (int type=0;type<11;type++)
                {
                    double[] value=FruitAward(g,type);
                    for (int a=0;a<8;a++) extra[a]+=lucky*c.extra[1+type]/award*value[a];
                }
            for (int a=0;a<8;a++) areas[a]=(main[a]+extra[a])/(1-growth)*100;
            double baseMean=main.Average()*100, total=areas.Average();
            return new Result { baseRtp=baseMean, extraRtp=total-baseMean,totalRtp=total,areaRtp=areas,
                basis="八区等额下注为总RTP；单押或不等额下注按各区RTP加权。免费局递归派生、幸运灯特殊奖均计入；不包括人为控牌、比倍和余额容量拒绝。" };
        }
        private static double[] FruitAward(Game g, int type)
        {
            int[][] fixedSets={new[]{1,2,7},new[]{8,16,21},new[]{5,11,17,23},new[]{3,6,9,12,15,18,20,24},Enumerable.Range(1,24).Where(v=>v!=10 && v!=22).ToArray()};
            var result=new double[8]; Action<IEnumerable<int>,double> add=(targets,p)=> { foreach (int lamp in targets) if (g.area[lamp-1]>=0) result[g.area[lamp-1]]+=p*g.rat[lamp-1]; };
            if (type<=4) add(fixedSets[type],1);
            else if (type==5)
                for (int row=0;row<4;row++) add(Enumerable.Range(0,7).Select(i=>(row*6+i)%24+1).Where(v=>v!=10 && v!=22),.25);
            else if (type==7)
                for (int count=3;count<=8;count++) for (int start=1;start<=24;start++)
                    add(Enumerable.Range(0,24).Select(i=>(start-1+i)%24+1).Where(v=>v!=10 && v!=22).Take(count),1.0/144);
            else add(fixedSets[4],(type==6 ? 3.0 : type-1)/22.0);
            return result;
        }
    }
}
