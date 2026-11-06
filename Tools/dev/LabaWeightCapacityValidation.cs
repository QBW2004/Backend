using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Entity;
using System.IO;
using System.Linq;
using System.Reflection;
using MySql.Data.MySqlClient;
using YYT.BLL.EF;
using YYT.Web.Areas.Game.Controllers;
using YYT.Web.Models;

// Only the isolated local schema created by check-laba-weight-capacity.ps1 may be used.
internal static class LabaWeightCapacityValidation
{
    private static MySqlConnection db;
    private static int checks;
    private static void Check(bool value, string name)
    { if (!value) throw new Exception("FAIL: " + name); checks++; }
    private static void Sql(string query)
    { using (var command = new MySqlCommand(query, db)) command.ExecuteNonQuery(); }
    private static long Count(string query)
    { using (var command = new MySqlCommand(query, db)) return Convert.ToInt64(command.ExecuteScalar()); }
    private static void Call(string method, params object[] args)
    {
        try { typeof(GameConfigController).GetMethod(method, BindingFlags.NonPublic | BindingFlags.Static).Invoke(null, args); }
        catch (TargetInvocationException ex) { throw ex.InnerException; }
    }
    private static void Reject(Action action, string name)
    { try { action(); } catch (ArgumentException) { checks++; return; } throw new Exception("Expected rejection: " + name); }
    private static void InsertTable(GameDbContext ef, int game, int table)
    { ef.Database.ExecuteSqlCommand("INSERT INTO roomtableconfig (GAME_ID,RoomIndex,TableIndex,TableName) VALUES ({0},0,{1},'capacity-test')", game, table); }
    private static void Save(int game, int table, IList<LabaWeightMath.Profile> rows, bool create)
    {
        using (var ef = new GameDbContext()) using (var tx = ef.Database.BeginTransaction())
        {
            if (create) InsertTable(ef, game, table);
            Call("WriteLabaWeightProfiles", ef, game, table, rows);
            tx.Commit();
        }
    }
    public static int Main()
    {
        var cs = new MySqlConnectionStringBuilder(ConfigurationManager.ConnectionStrings["DbConnString"].ConnectionString);
        if (cs.Server != "127.0.0.1" || cs.Port != 33406 || !cs.Database.StartsWith("mth_laba_capacity_"))
            throw new InvalidOperationException("Isolated database required");
        string schema = cs.Database;
        cs.Database = "";
        Database.SetInitializer<GameDbContext>(null);
        using (db = new MySqlConnection(cs.ConnectionString))
        {
            db.Open();
            Sql("CREATE DATABASE `" + schema + "` CHARACTER SET utf8mb4");
            try
            {
                db.ChangeDatabase(schema);
                string root = ConfigurationManager.AppSettings["repoRoot"];
                string snapshot = SqlSnapshot.Read(root);
                Sql(SqlSnapshot.Table(snapshot, "roomtableconfig"));
                Sql(SqlSnapshot.Table(snapshot, "cardpayoutprofile"));
                Check(Count("SELECT @@lower_case_table_names") == 1, "case insensitive table names");
                var math = new LabaWeightMath(File.ReadAllText(Path.Combine(root, "TTY.Web/Config/laba-weight-catalog.json")));
                foreach (int game in new[] { 16, 40, 53 })
                {
                    bool converted;
                    var config = math.ActivateEditor(game, math.ToEditorScale(game, math.Defaults(game), out converted));
                    var rows = math.WriteProfiles(game, config);
                    foreach (int table in Enumerable.Range(0, 30).Concat(new[] { 255, 256, 999 }))
                    {
                        Call("CheckWeightScope", game, table);
                        Save(game, table, rows, true);
                        Check(Count("SELECT COUNT(*) FROM cardpayoutprofile WHERE GAME_ID=" + game + " AND TableId=" + table) == rows.Count, "complete weights: " + game + "/" + table);
                    }
                    Check(33L * rows.Count * 52 + 33 * 218 + 8192 > 60000, "exceeds old limit: " + game);
                    Save(game, 999, rows, false);
                    Check(Count("SELECT COUNT(*) FROM cardpayoutprofile WHERE GAME_ID=" + game) == 33L * rows.Count, "replacement is idempotent: " + game);
                    using (var ef = new GameDbContext())
                    {
                        var read = ef.Database.SqlQuery<LabaWeightMath.Profile>("SELECT HandType,ProbabilityBasis,PayoutMultiplier FROM cardpayoutprofile WHERE GAME_ID={0} AND TableId=999", game).ToList();
                        var restored = math.ReadProfiles(game, read);
                        Check(restored.main.SequenceEqual(config.main) && restored.extra.SequenceEqual(config.extra), "weight round trip: " + game);
                    }
                    Reject(() => Call("CheckWeightScope", game, -1), "negative table");
                    Reject(() => Call("CheckWeightScope", game, 1000), "table beyond maximum");
                }
                Reject(() => Call("CheckWeightScope", 54, 0), "unrelated game");
                Call("CheckWeightProfileCount", 65535L);
                Reject(() => Call("CheckWeightProfileCount", 65536L), "U16 overflow");
                Reject(() => Call("CheckWeightProfileCount", (long)int.MaxValue + 1), "count arithmetic overflow");
                Sql("DELETE FROM cardpayoutprofile WHERE GAME_ID=53");
                Sql("INSERT INTO cardpayoutprofile(GAME_ID,TableId,HandType,PayoutMultiplier,ProbabilityBasis,Enabled) VALUES(53,0,1,1,1,1)");
                for (int i = 0; i < 16; i++)
                    Sql("INSERT INTO cardpayoutprofile(GAME_ID,TableId,HandType,PayoutMultiplier,ProbabilityBasis,Enabled) SELECT GAME_ID,TableId,HandType,PayoutMultiplier,ProbabilityBasis,Enabled FROM cardpayoutprofile WHERE GAME_ID=53");
                Sql("DELETE FROM cardpayoutprofile WHERE GAME_ID=53 LIMIT 2");
                Check(Count("SELECT COUNT(*) FROM cardpayoutprofile WHERE GAME_ID=53") == 65534, "seed U16 boundary");
                var single = new List<LabaWeightMath.Profile> { new LabaWeightMath.Profile { HandType = 1000, PayoutMultiplier = 1, ProbabilityBasis = 1 } };
                Save(53, 998, single, true);
                Check(Count("SELECT COUNT(*) FROM cardpayoutprofile WHERE GAME_ID=53") == 65535, "exact U16 limit saves");
                single[0].ProbabilityBasis = 0;
                Save(53, 998, single, false);
                Check(Count("SELECT ProbabilityBasis FROM cardpayoutprofile WHERE GAME_ID=53 AND TableId=998") == 0, "replacement excludes existing rows at limit");
                Reject(() => Save(53, 997, single, true), "overflow rejects new table");
                Check(Count("SELECT COUNT(*) FROM roomtableconfig WHERE GAME_ID=53 AND TableIndex=997") == 0, "new table rolls back");
                Check(Count("SELECT COUNT(*) FROM cardpayoutprofile WHERE GAME_ID=53") == 65535, "existing profiles unchanged on failure");
                var two = new List<LabaWeightMath.Profile>(single) { new LabaWeightMath.Profile { HandType = 1100, ProbabilityBasis = 2 } };
                Reject(() => Save(53, 998, two, false), "overflow rejects replacement");
                Check(Count("SELECT COUNT(*) FROM cardpayoutprofile WHERE GAME_ID=53 AND TableId=998") == 1, "old weight survives rejected replacement");
                Console.WriteLine("PASS " + checks + " checks; three games, old limit, extended tables, round trips, U16 boundaries, transaction rollback");
                return 0;
            }
            finally { Sql("DROP DATABASE `" + schema + "`"); }
        }
    }
}
