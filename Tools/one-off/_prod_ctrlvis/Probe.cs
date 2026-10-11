// 一次性线上验证（2026-10-07）：玩家控制状态可见口径
//   预期：所属代理本人 / 特级代理(限本线) / 总台 可见；同线或线外的其他代理不可见。
// 只读验证——只调用读方法（GetTotalControlStatus / GetActiveTotalControls /
// GetControls / GetTotalControlRecords / B_ManagerOpt.GetUsersListWithPermission），
// 不写库、不发管道指令、不碰运行中的站点。
//
// 用法：
//   1) 服务器上准备目录 C:\Temp\ctrlvis\，拷入 C:\Backend\bin\*.* 后，再用新构建的
//      YYT.BLL.dll 覆盖同名文件（即被测代码），放入本程序的 CtrlVisProbe.exe 与
//      CtrlVisProbe.exe.config（connectionStrings.DbConnString 用线上连接串）。
//   2) 运行 CtrlVisProbe.exe，逐行打印 VIEWER 判定与 EXPECT/ACTUAL，全 PASS 则退出码 0。
using System;
using System.Collections.Generic;
using System.Linq;
using YYT.BLL.EF;
using YYT.Entity;

public static class CtrlVisProbe
{
    // args: 可选的额外查看者账号，格式 "role:account"，如 CtrlVisProbe.exe sibling:zz_p2 mid:zz_mid
    public static int Main(string[] args)
    {
        try { Console.OutputEncoding = System.Text.Encoding.UTF8; } catch { }
        try
        {
            using (var ef = new GameDbContext())
            {
                // 被测玩家：取最近一条执行中总控（GameType=9, Status=Active）；没有则退到鱼机控制(GameType=1)
                var ctrl = ef.UserControlStatuses
                    .Where(c => c.GameType == B_UserControl.GAMETYPE_TOTAL && c.Status == (int)EControlStatus.Active)
                    .OrderByDescending(c => c.ID).FirstOrDefault();
                int probeGameType = B_UserControl.GAMETYPE_TOTAL;
                if (ctrl == null)
                {
                    ctrl = ef.UserControlStatuses
                        .Where(c => c.GameType == B_UserControl.GAMETYPE_FISH && c.Status == (int)EControlStatus.Active)
                        .OrderByDescending(c => c.ID).FirstOrDefault();
                    probeGameType = B_UserControl.GAMETYPE_FISH;
                }
                if (ctrl == null) { Console.WriteLine("NO_ACTIVE_CONTROL_ROW"); return 2; }

                string pid = ctrl.UserID;
                var player = ef.Users.FirstOrDefault(u => u.ID == pid);
                if (player == null) { Console.WriteLine("PLAYER_MISSING " + pid); return 2; }
                string ownerAgency = player.AGENCY;
                Console.WriteLine("PLAYER=" + pid + " AGENCY=" + ownerAgency
                    + " CTRL(gameType=" + ctrl.GameType + " mode=" + ctrl.ControlMode
                    + " createdBy=" + ctrl.CreatedBy + ")");
                if (string.IsNullOrWhiteSpace(ownerAgency)) { Console.WriteLine("NO_AGENCY"); return 2; }

                var owner = ef.Admins.FirstOrDefault(a => a.ID == ownerAgency);
                if (owner == null) { Console.WriteLine("OWNER_NOT_ADMIN " + ownerAgency); return 2; }

                var bAdmin = new B_Admin();

                // 特级祖先：沿 admin.AGENCY 上溯到 PRIV<=1 的节点
                M_Admin cursor = owner; int guard = 0;
                while (cursor != null && (cursor.PRIV ?? -1) > AgencyRules.TopAgentPriv && guard++ < 50)
                    cursor = ef.Admins.FirstOrDefault(a => a.ID == cursor.AGENCY);
                M_Admin topAgent = (cursor != null && (cursor.PRIV ?? -1) == AgencyRules.TopAgentPriv) ? cursor : null;

                // owner 整条线（从线上顶点起算）；顶点可能不是特级（直达总台时顶点即总台）
                M_Admin root = owner; guard = 0;
                while (root != null && !string.IsNullOrWhiteSpace(root.AGENCY)
                    && ef.Admins.Any(a => a.ID == root.AGENCY) && guard++ < 50)
                    root = ef.Admins.FirstOrDefault(a => a.ID == root.AGENCY);
                List<string> line = root != null
                    ? bAdmin.GetAgencyLineAccounts(ef, root.ID)
                    : new List<string> { owner.ID };

                // 同线非所属代理：线内除 owner 外任一 PRIV>=2
                var sameLine = ef.Admins.Where(a => line.Contains(a.ID) && a.ID != owner.ID && a.PRIV > 1)
                    .OrderBy(a => a.ID).FirstOrDefault();
                // 线外代理：PRIV>=2 且不在 owner 线内
                var outside = ef.Admins.Where(a => a.PRIV > 1 && a.ID != owner.ID).ToList()
                    .FirstOrDefault(a => !line.Contains(a.ID));
                // 总台
                var sup = ef.Admins.Where(a => a.PRIV == 0).OrderBy(a => a.ID).FirstOrDefault();

                var viewers = new List<KeyValuePair<string, M_Admin>>
                {
                    new KeyValuePair<string, M_Admin>("owner", owner),
                    new KeyValuePair<string, M_Admin>("same-line", sameLine),
                    new KeyValuePair<string, M_Admin>("top", topAgent != null && topAgent.ID != owner.ID ? topAgent : null),
                    new KeyValuePair<string, M_Admin>("outside", outside),
                    new KeyValuePair<string, M_Admin>("super", sup),
                };
                // 命令行显式指定的查看者（如临时建的 sibling/mid 测试代理）
                foreach (var arg in args ?? new string[0])
                {
                    var parts = (arg ?? "").Split(':');
                    if (parts.Length != 2 || string.IsNullOrWhiteSpace(parts[1])) continue;
                    string accId = parts[1].Trim();
                    var acc = ef.Admins.FirstOrDefault(a => a.ID == accId);
                    viewers.Add(new KeyValuePair<string, M_Admin>(parts[0], acc));
                }

                var bUc = new B_UserControl();
                var bOpt = new B_ManagerOpt();
                int fails = 0;
                foreach (var kv in viewers)
                {
                    if (kv.Value == null) { Console.WriteLine("SKIP " + kv.Key + " (no such account)"); continue; }
                    var v = kv.Value;
                    var lu = v.ToLoginUser();

                    bool inLine = bAdmin.IsInAgencyLine(ef, v.ID, ownerAgency);
                    bool canManage = bAdmin.CanManagePlayer(ef, lu, ownerAgency);
                    // 新口径：按设置人判定——总台/特级看全部，普通代理仅看 CreatedBy==自己
                    bool expectSee = AgencyRules.CanViewPlayerControl(lu.UserPriv, lu.Accounts, ctrl.CreatedBy);

                    var st = bUc.GetTotalControlStatus(lu, pid);
                    int stCount = (st.datas as List<M_UserControlStatus_DTO>) == null ? -1
                        : ((List<M_UserControlStatus_DTO>)st.datas).Count;

                    var batch = bUc.GetActiveTotalControls(lu, new List<string> { pid });
                    int btCount = (batch.datas as List<M_UserControlStatus_DTO>) == null ? -1
                        : ((List<M_UserControlStatus_DTO>)batch.datas).Count;

                    var recs = bUc.GetControls(new M_Page(1, 500), pid, -1, lu);
                    int rcCount = recs.rows == null ? -1
                        : recs.rows.Count(r => r.UserID == pid); // 机台范围行不算玩家记录

                    int trCount;
                    var tr = bUc.GetTotalControlRecords(new M_Page(1, 500), lu, null, null, out trCount);
                    int trHas = tr.rows == null ? -1 : tr.rows.Count(r => r.UserID == pid);

                    var optList = bOpt.GetUsersListWithPermission(new M_Page(1, 500), new M_Users { ID = pid }, lu);
                    int moCount = optList.rows == null ? -1 : optList.rows.Count;

                    // 判定：期望可见 -> 至少一个出口能拿到该玩家记录；期望不可见 -> 全出口都拿不到
                    int seen = (stCount > 0 ? 1 : 0) + (btCount > 0 ? 1 : 0) + (rcCount > 0 ? 1 : 0) + (trHas > 0 ? 1 : 0);
                    bool pass = expectSee ? (stCount > 0 && btCount > 0 && trHas > 0)
                                          : (stCount == 0 && btCount == 0 && rcCount == 0 && trHas == 0 && moCount == 0);
                    if (!pass) fails++;
                    Console.WriteLine(string.Format(
                        "{0} viewer={1} priv={2} inLine={3} canManage={4} | status={5} batch={6} fishRec={7} totalRec={8} optLog={9} | expect={10} => {11}",
                        kv.Key, v.ID, v.PRIV, inLine, canManage,
                        stCount, btCount, rcCount, trHas, moCount,
                        expectSee ? "SEE" : "HIDE", pass ? "PASS" : "FAIL"));
                }
                Console.WriteLine(fails == 0 ? "ALL_PASS" : ("FAILS=" + fails));
                return fails == 0 ? 0 : 1;
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine("ERR " + ex);
            return 3;
        }
    }
}
