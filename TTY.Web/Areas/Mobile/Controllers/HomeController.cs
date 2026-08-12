using System;
using System.Web.Mvc;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Web.Controllers;

namespace YYT.Web.Areas.Mobile.Controllers
{
    /// <summary>
    /// 手机端后台页面。
    /// 只负责渲染外壳与权限判定，数据全部由前端 ajax 复用 /Game/* 现有接口。
    /// </summary>
    [MemberAuthorize]
    public class HomeController : BaseController
    {
        #region 权限判定

        private static bool IsSuper(M_LoginUser user)
        {
            return user != null && user.UserPriv == 0;
        }

        private static bool CanUpDown(M_LoginUser user)
        {
            return IsSuper(user) || (user != null && user.IsUpDown == 1);
        }

        private static bool CanCreateAgent(M_LoginUser user)
        {
            return IsSuper(user) || (user != null && user.IsCreateAgent == 1);
        }

        /// <summary>
        /// 当前登录账号的金币余额（超管账号在 Admin 表可能不存在，返回 0）
        /// </summary>
        private long GetOwnCoins(M_LoginUser user)
        {
            if (user == null || string.IsNullOrWhiteSpace(user.Accounts))
                return 0;
            try
            {
                M_Admin admin = new B_Admin().GetSingle(new M_Admin { ID = user.Accounts });
                return admin != null && admin.COINS.HasValue ? admin.COINS.Value : 0;
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(HomeController), ex);
                return 0;
            }
        }

        #endregion

        /// <summary>玩家列表（在线 / 全部）</summary>
        public ActionResult Index()
        {
            M_LoginUser user = WebHelper.GetLoginInfo();

            ViewBag.MPage = "index";
            ViewBag.MTitle = "玩家列表";
            ViewBag.MShowMenu = true;
            ViewBag.MShowRefresh = true;
            ViewBag.MShowSearch = true;
            ViewBag.CanUpDown = CanUpDown(user);
            ViewBag.CanFrozen = IsSuper(user) || (user != null && user.IsFrozen == 1);
            ViewBag.CanKick = IsSuper(user) || (user != null && user.IsKicking == 1);
            ViewBag.CanModifyPwd = IsSuper(user) || (user != null && user.IsModifyPwd == 1);

            return View();
        }

        /// <summary>我的代理</summary>
        public ActionResult Agents()
        {
            M_LoginUser user = WebHelper.GetLoginInfo();

            ViewBag.MPage = "agents";
            ViewBag.MTitle = "我的代理";
            ViewBag.MSubtitle = "查看与管理下级代理";
            ViewBag.MShowRefresh = true;
            ViewBag.MShowSearch = true;
            ViewBag.CanUpDown = CanUpDown(user);
            ViewBag.CanCreateAgent = CanCreateAgent(user);
            ViewBag.IsSuper = IsSuper(user);
            ViewBag.OwnAccount = user != null ? user.Accounts : string.Empty;

            return View();
        }

        /// <summary>添加代理</summary>
        public ActionResult AddAgent()
        {
            M_LoginUser user = WebHelper.GetLoginInfo();
            if (!CanCreateAgent(user))
                return RedirectToAction("Index");

            ViewBag.MPage = "addagent";
            ViewBag.MTitle = "添加代理";
            ViewBag.MSubtitle = "创建新的下级代理账号";
            ViewBag.MShowRefresh = false;
            ViewBag.IsSuper = IsSuper(user);

            return View();
        }

        /// <summary>玩家充退（充值 / 兑换）</summary>
        public ActionResult Recharge()
        {
            M_LoginUser user = WebHelper.GetLoginInfo();
            if (!CanUpDown(user))
                return RedirectToAction("Index");

            ViewBag.MPage = "recharge";
            ViewBag.MTitle = "玩家充退";
            ViewBag.MShowRefresh = false;
            ViewBag.OwnCoins = GetOwnCoins(user);
            ViewBag.IsSuper = IsSuper(user);

            // 可操作对象范围，与桌面端 RechargeController.GetTreeDataByPermission 保持一致：
            //   -2 玩家、2 一般代理、1 总代
            int priv = user != null && user.UserPriv.HasValue ? user.UserPriv.Value : -1;
            bool canAgent = priv == 0 || priv == 9 || priv == 1 || (priv > 1 && priv < 3);
            bool canTopAgent = priv == 0 || priv == 9;
            ViewBag.CanTargetAgent = canAgent;
            ViewBag.CanTargetTopAgent = canTopAgent;

            // 支持从玩家列表 / 代理列表跳转过来时预填
            ViewBag.PresetAccount = Request.QueryString["id"] ?? string.Empty;
            ViewBag.PresetPayType = Request.QueryString["pay"] == "1" ? "1" : "0";
            ViewBag.PresetRole = Request.QueryString["role"] == "agent" ? "agent" : "player";

            return View();
        }

        /// <summary>充退记录</summary>
        public ActionResult Records()
        {
            ViewBag.MPage = "records";
            ViewBag.MTitle = "充退记录";
            ViewBag.MSubtitle = "查看充值与兑换流水";
            ViewBag.MShowRefresh = true;
            ViewBag.Today = DateTime.Now.ToString("yyyy-MM-dd");

            return View();
        }
    }
}
