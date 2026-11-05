// 专属桌台「从公共桌台复制一套 / 收回专属桌台」真实 MySQL 往返验收（2026-11-05）。
// 连接串必须指向本机临时实例上的 mth_line_tables_validation_* 库；表结构取自 Database/mth_clean.sql，跑完删库。
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Entity;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using MySql.Data.MySqlClient;
using YYT.BLL.EF;
using YYT.Entity;

class LineTablesValidation
{
    static int checks;
    static MySqlConnection db;

    static void Check(bool value, string name)
    {
        if (!value) throw new Exception("FAIL: " + name);
        checks++;
    }

    static void Sql(string q) { using (var cmd = new MySqlCommand(q, db)) cmd.ExecuteNonQuery(); }
    static long Scalar(string q) { using (var cmd = new MySqlCommand(q, db)) return Convert.ToInt64(cmd.ExecuteScalar()); }
    static string Str(string q) { using (var cmd = new MySqlCommand(q, db)) { object o = cmd.ExecuteScalar(); return o == null || o is DBNull ? null : o.ToString(); } }

    static string Owner(int g, int t) { return Str("SELECT LineAgent FROM roomtableowner WHERE GAME_ID=" + g + " AND TableIndex=" + t); }

    static void SeedPublic(int g, int paraType, int count)
    {
        for (int t = 0; t < count; t++)
        {
            int id = g * 1000 + t;
            Sql("INSERT INTO roomtableconfig(GAME_ID,RoomIndex,TableIndex,TableName,Enabled,BetMin,BetMax) VALUES(" + g + ",0," + t + ",'公共" + t + "',1," + (10 + t) + "," + (100 + t) + ")");
            Sql("INSERT INTO robot_seat(GAME_ID,GAME_TYPE,ROOM_ID,TABLE_ID,ROBOT_NO) VALUES(" + g + "," + paraType + ",0," + t + ",1)");
            switch (paraType)
            {
                case 0:
                    Sql("INSERT INTO roomtableconfig_bet(GAME_ID,RoomIndex,TableIndex) VALUES(" + g + ",0," + t + ")");
                    Sql("INSERT INTO parabet(ID,GAME_ID) VALUES(" + id + "," + g + ")");
                    Sql("INSERT INTO cardpayoutprofile(GAME_ID,TableId) VALUES(" + g + "," + t + ")");
                    Sql("INSERT INTO betgamecfg(GAME_ID,TableIndex,CfgJson) VALUES(" + g + "," + t + ",'{\"t\":" + t + "}')");
                    break;
                case 1:
                    Sql("INSERT INTO cardgamecfg(GAME_ID,TableIndex,CfgJson) VALUES(" + g + "," + t + ",'{\"t\":" + t + "}')");
                    Sql("INSERT INTO roomtableconfig_card(GAME_ID,RoomIndex,TableIndex) VALUES(" + g + ",0," + t + ")");
                    Sql("INSERT INTO paracard(ID,GAME_ID,DIF) VALUES(" + id + "," + g + ",'D" + t + "')");
                    Sql("INSERT INTO cardpayoutprofile(GAME_ID,TableId) VALUES(" + g + "," + t + ")");
                    break;
                case 2:
                    Sql("INSERT INTO parafish(ID,GAME_ID,TableIndex) VALUES(" + id + "," + g + "," + t + ")");
                    break;
                case 3:
                    Sql("INSERT INTO paralaba(ID,GAME_ID,TableIndex) VALUES(" + id + "," + g + "," + t + ")");
                    Sql("INSERT INTO gameconfiglaba(GameId,TableIndex,OptKey,OptValue) VALUES(" + g + "," + t + ",'Rtp','" + (90 + t) + "')");
                    Sql("INSERT INTO roomtableconfig_bet(GAME_ID,RoomIndex,TableIndex) VALUES(" + g + ",0," + t + ")");
                    Sql("INSERT INTO cardpayoutprofile(GAME_ID,TableId) VALUES(" + g + "," + t + ")");
                    break;
            }
        }
    }

    /// <summary>每张按桌表在目标桌号上恰有 1 行（拉霸 gameconfiglaba 按 OptKey 也是 1 行）。</summary>
    static void CheckPerTableRows(int g, int paraType, int dst, string label)
    {
        foreach (LineTables.CloneSpec s in LineTables.PerTableSpecs(paraType))
        {
            string where = s.IndexCol != null && Scalar("SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='" + s.Table + "' AND COLUMN_NAME='" + s.IndexCol + "'") > 0
                ? "`" + s.IndexCol + "`=" + dst : "`" + s.IdCol + "`=" + (g * 1000 + dst);
            long n = Scalar("SELECT COUNT(*) FROM `" + s.Table + "` WHERE `" + s.GameCol + "`=" + g + " AND " + where);
            Check(n == 1, label + " " + s.Table + " table " + dst + " has exactly 1 row (got " + n + ")");
            if (s.IndexCol != null && s.IdCol != null)
                Check(Scalar("SELECT COUNT(*) FROM `" + s.Table + "` WHERE `" + s.IdCol + "`=" + (g * 1000 + dst) + " AND `" + s.IndexCol + "`=" + dst) == 1, label + " " + s.Table + " ID encoded for " + dst);
        }
    }

    static void Main()
    {
        var timer = System.Diagnostics.Stopwatch.StartNew();
        try
        {
            var cs = new MySqlConnectionStringBuilder(ConfigurationManager.ConnectionStrings["DbConnString"].ConnectionString);
            if ((cs.Server != "localhost" && cs.Server != "127.0.0.1") || !cs.Database.StartsWith("mth_line_tables_validation_"))
                throw new Exception("Requires an isolated local validation database");
            string schema = cs.Database;
            string repo = ConfigurationManager.AppSettings["repoRoot"];
            string dump = SqlSnapshot.Read(repo);
            cs.Database = "";
            using (db = new MySqlConnection(cs.ConnectionString))
            {
                db.Open();
                Sql("CREATE DATABASE `" + schema + "` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
                try
                {
                    Sql("USE `" + schema + "`");
                    Sql("SET SESSION sql_mode=''");
                    foreach (string t in new[] { "admin", "roomtableconfig", "robot_seat", "roomtableconfig_bet", "parabet", "cardpayoutprofile", "betgamecfg", "roomtableconfig_card", "paracard", "parafish", "paralaba", "gameconfiglaba", "pararoom" })
                        Sql(SqlSnapshot.Table(dump, t));
                    Sql(SqlSnapshot.Table(dump, "cardgamecfg"));
                    Sql(SqlSnapshot.Table(dump, "roomtableowner"));
                    Database.SetInitializer<GameDbContext>(null);

                    // admin 实体列可能多于旧 dump：按 EF 报错补齐，最多补 30 列
                    for (int i = 0; i < 30; i++)
                    {
                        try { using (var ef = new GameDbContext()) ef.Admins.Any(); break; }
                        catch (Exception ex)
                        {
                            Match m = Regex.Match(ex.ToString(), "Unknown column '(?:Extent1\\.)?([A-Za-z0-9_]+)'");
                            if (!m.Success) throw;
                            Sql("ALTER TABLE admin ADD COLUMN `" + m.Groups[1].Value + "` VARCHAR(64) NULL");
                        }
                    }
                    Sql("INSERT INTO admin(ID,PRIV) VALUES('lineA',1),('lineB',1),('lineC',1),('sub1',2)");

                    // ===== 牌机（paraType 1）完整往返 =====
                    int g = 5;
                    SeedPublic(g, 1, 3);
                    Msg r = LineTables.CopyPublicToLine(g, 1, "lineA");
                    Check(r.code == 1 && Convert.ToInt32(r.datas) == 3, "card copy lineA ok: " + r.content);
                    for (int k = 0; k < 3; k++)
                    {
                        int dst = 3 + k;
                        Check(Owner(g, dst) == "lineA", "lineA owns " + dst);
                        { string nm = Str("SELECT TableName FROM roomtableconfig WHERE GAME_ID=5 AND TableIndex=" + dst); Check(nm == (k + 1) + "号机", "renamed " + dst + " got [" + nm + "] hex " + Str("SELECT HEX(TableName) FROM roomtableconfig WHERE GAME_ID=5 AND TableIndex=" + dst)); }
                        Check(Scalar("SELECT BetMax FROM roomtableconfig WHERE GAME_ID=5 AND TableIndex=" + dst) == 100 + k, "BetMax copied " + dst);
                        Check(Str("SELECT DIF FROM paracard WHERE ID=" + (5000 + dst)) == "D" + k, "paracard copied by ID " + dst);
                        Check(Str("SELECT CfgJson FROM cardgamecfg WHERE GAME_ID=5 AND TableIndex=" + dst) == "{\"t\":" + k + "}", "cardgamecfg copied " + dst);
                        CheckPerTableRows(g, 1, dst, "card copy");
                    }
                    for (int t = 0; t < 3; t++) Check(Owner(g, t) == null, "public " + t + " stays public");
                    Check(Str("SELECT TableName FROM roomtableconfig WHERE GAME_ID=5 AND TableIndex=0") == "公共0", "public name untouched");

                    Check(LineTables.CopyPublicToLine(g, 1, "lineA").code == 0, "duplicate copy rejected");
                    Check(LineTables.CopyPublicToLine(g, 1, "LINEA").code == 0, "duplicate copy rejected case-insensitive");
                    Check(LineTables.CopyPublicToLine(g, 1, "sub1").code == 0, "non-line agent rejected");
                    Check(LineTables.CopyPublicToLine(g, 1, "nobody").code == 0, "unknown agent rejected");
                    Check(LineTables.CopyPublicToLine(g, 1, "#").code == 0, "recycled marker rejected");
                    Check(LineTables.CopyPublicToLine(g, 1, "").code == 0, "empty line rejected");
                    Check(Scalar("SELECT COUNT(*) FROM roomtableconfig WHERE GAME_ID=5") == 6, "rejections wrote nothing");

                    Check(LineTables.CopyPublicToLine(g, 1, "LINEB").code == 1, "copy lineB (requested in other case)");
                    Check(Scalar("SELECT COUNT(*) FROM roomtableowner WHERE GAME_ID=5 AND BINARY LineAgent='lineB'") == 3, "owner stored with admin.ID exact spelling");
                    Check(Owner(g, 6) == "lineB" && Owner(g, 8) == "lineB", "lineB appended 6..8 (only public tables copied, not lineA's)");
                    Check(Scalar("SELECT BetMax FROM roomtableconfig WHERE GAME_ID=5 AND TableIndex=6") == 100, "lineB copied from public 0");

                    // lineA 改过的专属参数，收回后再分给 lineC 时必须被公共参数覆盖，不留旧行
                    Sql("UPDATE roomtableconfig SET BetMax=9999 WHERE GAME_ID=5 AND TableIndex=3");
                    long robotsBefore = Scalar("SELECT COUNT(*) FROM robot_seat WHERE GAME_ID=5");
                    r = LineTables.RecallLine(g, "lineA");
                    Check(r.code == 1 && Convert.ToInt32(r.datas) == 3, "recall lineA ok: " + r.content);
                    for (int t = 3; t < 6; t++) Check(Owner(g, t) == "#", "table " + t + " recycled");
                    Check(Scalar("SELECT COUNT(*) FROM robot_seat WHERE GAME_ID=5 AND TABLE_ID BETWEEN 3 AND 5") == 0, "recalled tables robots removed");
                    Check(Scalar("SELECT COUNT(*) FROM robot_seat WHERE GAME_ID=5") == robotsBefore - 3, "other robots untouched");
                    Check(Scalar("SELECT COUNT(*) FROM roomtableconfig WHERE GAME_ID=5") == 9, "recall keeps table rows");
                    Check(LineTables.RecallLine(g, "lineA").code == 0, "second recall rejected");
                    Check(LineTables.RecallLine(g, "").code == 0, "recall empty line rejected");
                    Check(LineTables.RecallLine(g, "#").code == 0, "recall # rejected");
                    Check(Owner(g, 6) == "lineB", "lineB untouched by lineA recall");

                    using (var ef = new GameDbContext())
                    {
                        var owners = LineTables.GetOwners(ef, g);
                        Check(!LineScopeRules.TableBelongsTo(owners, 3, "") && !LineScopeRules.TableBelongsTo(owners, 3, "lineA"), "recycled invisible to public and lineA");
                        Check(LineScopeRules.TableBelongsTo(owners, 0, ""), "public visible after recall");
                    }

                    r = LineTables.CopyPublicToLine(g, 1, "lineC");
                    Check(r.code == 1, "copy lineC reuses recycled: " + r.content);
                    for (int t = 3; t < 6; t++) { Check(Owner(g, t) == "lineC", "lineC reuses " + t); CheckPerTableRows(g, 1, t, "reuse"); }
                    Check(Scalar("SELECT BetMax FROM roomtableconfig WHERE GAME_ID=5 AND TableIndex=3") == 100, "reused table overwritten with public values");
                    Check(Scalar("SELECT COUNT(*) FROM roomtableconfig WHERE GAME_ID=5") == 9, "reuse did not grow table count");
                    Check(Scalar("SELECT COUNT(*) FROM robot_seat WHERE GAME_ID=5 AND TABLE_ID BETWEEN 3 AND 5") == 3, "reused tables get public robot settings");

                    // lineA 再次复制：此时公共只有 0..2，没有已收回桌号，接到 9..11
                    Check(LineTables.CopyPublicToLine(g, 1, "lineA").code == 1, "lineA copy again after recall");
                    Check(Owner(g, 9) == "lineA" && Owner(g, 11) == "lineA", "lineA appended to 9..11");

                    // 事务回滚：第二张桌复制中途失败，全部不落库
                    Sql("CREATE TRIGGER trg_fail BEFORE INSERT ON paracard FOR EACH ROW BEGIN IF NEW.ID = 5013 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='forced'; END IF; END");
                    Sql("INSERT INTO admin(ID,PRIV) VALUES('lineD',1)");
                    long cfgBefore = Scalar("SELECT COUNT(*) FROM roomtableconfig WHERE GAME_ID=5");
                    r = LineTables.CopyPublicToLine(g, 1, "lineD");
                    Check(r.code == 0 && r.content.Contains("forced"), "mid-copy failure reported: " + r.content);
                    Check(Scalar("SELECT COUNT(*) FROM roomtableconfig WHERE GAME_ID=5") == cfgBefore, "rollback: no roomtableconfig rows");
                    Check(Scalar("SELECT COUNT(*) FROM roomtableowner WHERE LineAgent='lineD'") == 0, "rollback: no owner rows");
                    Check(Scalar("SELECT COUNT(*) FROM paracard WHERE ID=5012") == 0, "rollback: first table paracard undone");
                    Sql("DROP TRIGGER trg_fail");
                    Check(LineTables.CopyPublicToLine(g, 1, "lineD").code == 1, "copy works after failure cleared");

                    // 删除公共桌台 1：归属整体左移，与按桌表压实一致
                    using (var ef = new GameDbContext()) LineTables.OnTableDeleted(ef, g, 1);
                    Check(Owner(g, 2) == "lineC" && Owner(g, 5) == "lineB" && Owner(g, 13) == "lineD" && Owner(g, 14) == null, "owners shifted left after delete");

                    // 上限按类型：押注/鱼机 256，牌机/拉霸 1000；放不下时拒绝且不写
                    int g2 = 7;
                    SeedPublic(g2, 0, 3);
                    Sql("INSERT INTO roomtableconfig(GAME_ID,RoomIndex,TableIndex,TableName,Enabled) VALUES(7,0,254,'x',1)");
                    Sql("INSERT INTO roomtableowner(GAME_ID,RoomIndex,TableIndex,LineAgent) VALUES(7,0,254,'lineB')");
                    Check(LineTables.CopyPublicToLine(g2, 0, "lineA").code == 0, "bet over 256 rejected");
                    Check(Scalar("SELECT COUNT(*) FROM roomtableowner WHERE GAME_ID=7") == 1, "bet over-limit wrote nothing");
                    int g4 = 11;
                    SeedPublic(g4, 1, 3);
                    Sql("INSERT INTO roomtableconfig(GAME_ID,RoomIndex,TableIndex,TableName,Enabled) VALUES(11,0,254,'x',1)");
                    Sql("INSERT INTO roomtableowner(GAME_ID,RoomIndex,TableIndex,LineAgent) VALUES(11,0,254,'lineB')");
                    Check(LineTables.CopyPublicToLine(g4, 1, "lineA").code == 1 && Owner(g4, 255) == "lineA" && Owner(g4, 257) == "lineA", "card copy past 256 allowed");
                    CheckPerTableRows(g4, 1, 257, "card past 256");
                    Sql("INSERT INTO roomtableconfig(GAME_ID,RoomIndex,TableIndex,TableName,Enabled) VALUES(11,0,997,'x',1)");
                    Sql("INSERT INTO roomtableowner(GAME_ID,RoomIndex,TableIndex,LineAgent) VALUES(11,0,997,'lineB')");
                    Check(LineTables.CopyPublicToLine(g4, 1, "lineC").code == 0 && Scalar("SELECT COUNT(*) FROM roomtableowner WHERE GAME_ID=11 AND LineAgent='lineC'") == 0, "card over 1000 rejected, nothing written");

                    // ===== 专属视图新建桌台：预登记归属 / 撤销 =====
                    int g3 = 9;
                    SeedPublic(g3, 1, 2);
                    Check(LineTables.ReserveNewLineTable(g3, 1, "lineA").code == 0, "reserve refused before line has exclusive tables");
                    Check(LineTables.CopyPublicToLine(g3, 1, "lineA").code == 1, "g3 copy lineA");
                    Msg rv = LineTables.ReserveNewLineTable(g3, 1, "LINEA");
                    Check(rv.code == 1 && Convert.ToInt32(rv.datas) == 4, "reserve next index after max: " + rv.content);
                    Check(Owner(g3, 4) == "lineA", "reserved owner stored with existing spelling");
                    using (var ef = new GameDbContext())
                        Check(LineScopeRules.TableBelongsTo(LineTables.GetOwners(ef, g3), 4, "lineA") && !LineScopeRules.TableBelongsTo(LineTables.GetOwners(ef, g3), 4, ""), "reserved table never public");
                    LineTables.ReleaseUnusedReservation(g3, 4);
                    Check(Owner(g3, 4) == null, "unused reservation released");
                    rv = LineTables.ReserveNewLineTable(g3, 1, "lineA");
                    Check(Convert.ToInt32(rv.datas) == 4, "reserve again same index");
                    Sql("INSERT INTO roomtableconfig(GAME_ID,RoomIndex,TableIndex,TableName,Enabled) VALUES(9,0,4,'新桌',1)"); // 模拟保存成功
                    LineTables.ReleaseUnusedReservation(g3, 4);
                    Check(Owner(g3, 4) == "lineA", "saved table keeps owner");
                    rv = LineTables.ReserveNewLineTable(g3, 1, "lineA");
                    Check(Convert.ToInt32(rv.datas) == 5, "second add goes to 5");
                    LineTables.ReleaseUnusedReservation(g3, 5);
                    Check(LineTables.RecallLine(g3, "lineA").code == 1 && Owner(g3, 4) == "#", "recall covers added table");
                    Check(LineTables.ReserveNewLineTable(g3, 1, "lineA").code == 0, "reserve refused after recall");
                    Check(LineTables.ReserveNewLineTable(g3, 1, "sub1").code == 0, "reserve refused for non-line");
                    Check(LineTables.ReserveNewLineTable(g3, 1, "#").code == 0 && LineTables.ReserveNewLineTable(g3, 1, "").code == 0, "reserve refused for #/empty");
                    Check(LineTables.ReserveNewLineTable(54, 3, "lineA").code == 0, "reserve refused for mjhl");
                    Sql("INSERT INTO roomtableconfig(GAME_ID,RoomIndex,TableIndex,TableName,Enabled) VALUES(9,0,255,'x',1)");
                    Sql("INSERT INTO roomtableowner(GAME_ID,RoomIndex,TableIndex,LineAgent) VALUES(9,0,255,'lineB')");
                    Check(LineTables.ReserveNewLineTable(g3, 0, "lineB").code == 0 && Owner(g3, 256) == null, "bet reserve refused at 256");
                    rv = LineTables.ReserveNewLineTable(g3, 1, "lineB");
                    Check(rv.code == 1 && Convert.ToInt32(rv.datas) == 256, "card reserve allowed past 256");
                    LineTables.ReleaseUnusedReservation(g3, 256);
                    Sql("INSERT INTO roomtableconfig(GAME_ID,RoomIndex,TableIndex,TableName,Enabled) VALUES(9,0,999,'x',1)");
                    Sql("INSERT INTO roomtableowner(GAME_ID,RoomIndex,TableIndex,LineAgent) VALUES(9,0,999,'lineB')");
                    Check(LineTables.ReserveNewLineTable(g3, 1, "lineB").code == 0 && Owner(g3, 1000) == null, "card reserve refused at 1000");

                    // ===== 押注 / 鱼机 / 拉霸 各一轮复制+收回+复用 =====
                    foreach (int[] p in new[] { new[] { 0, 30 }, new[] { 2, 3 }, new[] { 3, 40 } })
                    {
                        int type = p[0], gid = p[1];
                        SeedPublic(gid, type, 2);
                        Check(LineTables.CopyPublicToLine(gid, type, "lineA").code == 1, "type " + type + " copy");
                        CheckPerTableRows(gid, type, 2, "type " + type);
                        CheckPerTableRows(gid, type, 3, "type " + type);
                        Check(LineTables.RecallLine(gid, "lineA").code == 1, "type " + type + " recall");
                        Check(LineTables.CopyPublicToLine(gid, type, "lineB").code == 1, "type " + type + " reuse copy");
                        CheckPerTableRows(gid, type, 2, "type " + type + " reuse");
                        CheckPerTableRows(gid, type, 3, "type " + type + " reuse");
                        Check(Owner(gid, 2) == "lineB" && Owner(gid, 3) == "lineB", "type " + type + " reuse owners");
                    }
                    Check(Str("SELECT OptValue FROM gameconfiglaba WHERE GameId=40 AND TableIndex=3") == "91", "laba RTP copied");
                }
                finally { Sql("DROP DATABASE IF EXISTS `" + schema + "`"); }
            }
            Console.WriteLine("PASS " + checks + " database checks in " + timer.Elapsed.TotalSeconds.ToString("F2") + "s");
        }
        catch (Exception ex) { Console.WriteLine(ex); Environment.ExitCode = 1; }
    }
}
