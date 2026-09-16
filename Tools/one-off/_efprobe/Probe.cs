using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using YYT.BLL.EF;
using YYT.Entity;

public class Probe
{
    public static void Main(string[] args)
    {
        Console.OutputEncoding = Encoding.UTF8;
        string id = args.Length > 0 ? args[0] : "a1314";
        bool withPlay = args.Length < 2 || args[1] != "0";

        M_LoginUser loginUser = new M_LoginUser
        {
            UserID = 1,
            Accounts = "atmadmin",
            UserPriv = 0,
            ManageScope = 1,
            IsViewPwd = 0,
            IsViewSafePwd = 0
        };

        try
        {
            List<M_Users_DTO> rows = new B_Users().GetUserRowsByIds(new List<string> { id }, loginUser, withPlay);
            Console.WriteLine("OK rows=" + rows.Count);
            foreach (M_Users_DTO r in rows)
            {
                Console.WriteLine(string.Format("  {0} INHALL={1} game={2} room={3} table={4} bet={5} profit={6} today={7}",
                    r.ID, r.INHALL, r.CurrentGameName, r.CurrentRoomId, r.CurrentTableId, r.CurrentBetCoins, r.Profit, r.TodayWinLoss));
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine("FAILED: " + ex.GetType().FullName);
            Console.WriteLine(ex.Message);
            Exception inner = ex.InnerException;
            int depth = 0;
            while (inner != null && depth++ < 5)
            {
                Console.WriteLine("  INNER: " + inner.GetType().FullName + " :: " + inner.Message);
                inner = inner.InnerException;
            }
            Console.WriteLine("--- STACK ---");
            Console.WriteLine(ex.StackTrace);
        }
    }
}
