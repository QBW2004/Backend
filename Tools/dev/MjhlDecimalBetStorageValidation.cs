// 在独立空库执行真实BLL保存；配置专用不存在的管道，只验数据库提交，不等待热更回复。
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Threading;
using System.Configuration;
using YYT.BLL.EF;
using YYT.Entity;

class MjhlDecimalBetStorageValidation
{
    static int checks;
    static void Check(bool ok, string name) { if (!ok) throw new Exception(name); checks++; Console.WriteLine("PASS " + name); }
    static M_ParaLaba Para(int min, int max, int step)
    {
        return new M_ParaLaba { ID = 54000, GAME_ID = 54, TableIndex = 0,
            BetMin = min, BetMax = max, ScoreSwitchX10 = step, CoinSc = 100, ExCoin = 1, GameMo = 1 };
    }
    static YYT.Entity.Msg Save(M_ParaLaba p)
    {
        var rows = new List<M_GameConfigLaba> {
            new M_GameConfigLaba { GameId=54, TableIndex=0, OptKey="betMinX10", OptValue=p.BetMin, TIME=DateTime.Now, Type="Room" },
            new M_GameConfigLaba { GameId=54, TableIndex=0, OptKey="betMaxX10", OptValue=p.BetMax, TIME=DateTime.Now, Type="Room" },
            new M_GameConfigLaba { GameId=54, TableIndex=0, OptKey="scoreSwitchX10", OptValue=p.ScoreSwitchX10, TIME=DateTime.Now, Type="Room" }
        };
        return new B_LabaGamePara().SaveTableFull(54000, 54, rows, p, "decimal fixture", 1, "", 0);
    }
    static void WaitForCommittedMinimum(int units)
    {
        for (int i = 0; i < 100; i++)
        {
            using (var db = new GameDbContext())
                if (db.Database.SqlQuery<int>("SELECT BetMin FROM paralaba WHERE GAME_ID=54 AND TableIndex=0").FirstOrDefault() == units) return;
            Thread.Sleep(20);
        }
        throw new Exception("BLL did not commit precise minimum");
    }
    static int Main()
    {
        try
        {
            var pipeName = ConfigurationManager.AppSettings["pipeName"];
            Check(pipeName.StartsWith("mth_mjhl_decimal_fixture_"), "dedicated fixture pipe");
            using (var db = new GameDbContext())
            {
                Check(db.Database.Connection.Database.StartsWith("mth_mjhl_decimal_fixture_"), "dedicated empty fixture database");
                db.Database.ExecuteSqlCommand("INSERT INTO roomtableconfig(GAME_ID,RoomIndex,TableIndex,TableName,Enabled) VALUES(54,0,0,'fixture',1)");
                db.Database.ExecuteSqlCommand("INSERT INTO cardpayoutprofile(GAME_ID,TableId,HandType,PayoutMultiplier,ProbabilityBasis,StockLimit,StockRemain,Enabled) VALUES(54,0,2100,800,0,0,0,1)");
            }
            // SaveTableFull先提交事务，再尝试热更；本测试仅等待已提交数据，专用无服务管道不能触及真实中心服。
            var firstSave = Task.Run(() => Save(Para(4, 200, 1)));
            WaitForCommittedMinimum(4);
            Check(!firstSave.IsFaulted, "actual BLL commits minimum 0.4 / maximum 20 / step 0.1");
            using (var db = new GameDbContext())
            {
                var p = db.Database.SqlQuery<M_ParaLaba>("SELECT * FROM paralaba WHERE GAME_ID=54 AND TableIndex=0").Single();
                Check(p.BetMin / 10m == 0.4m && p.BetMax / 10m == 20 && p.ScoreSwitchX10 / 10m == 0.1m, "stored table data reads back exact decimal values");
                var packed = db.Database.SqlQuery<long>("SELECT CAST(PayoutMultiplier*1000000+ProbabilityBasis*100+StockLimit AS SIGNED) FROM cardpayoutprofile WHERE GAME_ID=54 AND TableId=0 AND HandType=2200").Single();
                Check(packed == 4020001, "precise forwarding row contains 4 / 200 / 1");
                Check(db.Database.SqlQuery<int>("SELECT COUNT(*) FROM cardpayoutprofile WHERE GAME_ID=54 AND HandType=2100").Single() == 1, "bet save preserves payout settings");
            }
            var secondSave = Task.Run(() => Save(Para(7, 200, 2)));
            WaitForCommittedMinimum(7);
            Check(!secondSave.IsFaulted, "second save updates exact tenths");
            Check(Save(Para(4, 300, 1)).code == 0, "over-200 ladder rejected by BLL transaction");
            using (var db = new GameDbContext())
            {
                Check(db.Database.SqlQuery<int>("SELECT COUNT(*) FROM cardpayoutprofile WHERE GAME_ID=54 AND TableId=0 AND HandType=2200").Single() == 1, "repeated save does not duplicate precise row");
                Check(db.Database.SqlQuery<int>("SELECT PayoutMultiplier FROM cardpayoutprofile WHERE GAME_ID=54 AND TableId=0 AND HandType=2200").Single() == 7, "invalid save rolls precise row back to previous value");
                Check(db.Database.SqlQuery<int>("SELECT BetMin FROM paralaba WHERE GAME_ID=54 AND TableIndex=0").Single() == 7, "invalid save also rolls structured settings back");
            }
            Console.WriteLine("Checks=" + checks); return 0;
        }
        catch (Exception e) { Console.Error.WriteLine(e); return 1; }
    }
}
