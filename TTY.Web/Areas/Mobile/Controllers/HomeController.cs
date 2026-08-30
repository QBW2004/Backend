using System;
using System.Web;
using System.Web.Mvc;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Web.Controllers;
using YYT.Web.Filters;

namespace YYT.Web.Areas.Mobile.Controllers
{
    /// <summary>
    /// 手机端后台页面。
    /// 只负责渲染外壳与权限判定，数据全部由前端 ajax 复用 /Game/* 现有接口。
    /// </summary>
    [MemberAuthorize]
    [MobileOnly]
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

        /// <summary>玩家列表（在线 / 离线）</summary>
        public ActionResult Index()
        {
            M_LoginUser user = WebHelper.GetLoginInfo();

            ViewBag.MPage = "index";
            ViewBag.MTitle = "玩家列表";
            ViewBag.MShowMenu = true;
            ViewBag.MShowRefresh = true;
            ViewBag.MShowSearch = true;
            ViewBag.MHeaderTall = true;
            ViewBag.MSubtitleHtml = "<div>今日玩家总输赢（金币）</div><div class=\"total-win-loss\" id=\"totalWinLoss\">0</div>";
            ViewBag.CanUpDown = CanUpDown(user);
            ViewBag.CanFrozen = IsSuper(user) || (user != null && user.IsFrozen == 1);
            ViewBag.CanKick = IsSuper(user) || (user != null && user.IsKicking == 1);
            ViewBag.CanModifyPwd = IsSuper(user) || (user != null && user.IsModifyPwd == 1);
            // 控制管理入口：吃分(IsKill)/放水(IsProbability)/控牌(IsRelease) 任一权限即可
            ViewBag.CanControl = IsSuper(user)
                || (user != null && (user.IsKill == 1 || user.IsProbability == 1 || user.IsRelease == 1));

            return View();
        }

        /// <summary>我的代理</summary>
        public ActionResult Agents()
        {
            M_LoginUser user = WebHelper.GetLoginInfo();

            ViewBag.MPage = "agents";
            ViewBag.MTitle = "我的代理";
            ViewBag.MSubtitle = "查看所有代理信息";
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
            ViewBag.MTitle = "充值管理";
            ViewBag.MShowRefresh = false;
            ViewBag.OwnCoins = GetOwnCoins(user);
            ViewBag.MSubtitleHtml = "当前金币余额: <span class=\"diamond-count\" id=\"currentDiamond\">" + ViewBag.OwnCoins + "</span>";
            ViewBag.IsSuper = IsSuper(user);

            // 可操作对象范围，与桌面端 RechargeController.GetTreeDataByPermission 保持一致：
            //   -2 玩家、2 一般代理、1 总代
            int priv = user != null && user.UserPriv.HasValue ? user.UserPriv.Value : -1;
            bool canAgent = priv == 0 || priv == 9 || priv == 1 || (priv > 1 && priv < 3);
            bool canTopAgent = priv == 0 || priv == 9;
            ViewBag.CanTargetAgent = canAgent;
            ViewBag.CanTargetTopAgent = canTopAgent;

            // 支持从玩家列表 / 代理列表跳转过来时预填（默认与参考站一致：下级代理）
            ViewBag.PresetAccount = Request.QueryString["id"] ?? string.Empty;
            ViewBag.PresetPayType = Request.QueryString["pay"] == "1" ? "1" : "0";
            ViewBag.PresetRole = Request.QueryString["role"] == "player" ? "player" : "agent";

            return View();
        }

        /// <summary>充退记录</summary>
        public ActionResult Records()
        {
            ViewBag.MPage = "records";
            ViewBag.MTitle = "充退记录";
            ViewBag.MSubtitle = "查看玩家充值和退分历史";
            ViewBag.MShowRefresh = true;
            ViewBag.Today = DateTime.Now.ToString("yyyy-MM-dd");

            return View();
        }

        #region 手机端扩展页面
        /// <summary>冻结明细（查看冻结中的账号并解冻）</summary>
        public ActionResult Abnormal()
        {
            M_LoginUser user = WebHelper.GetLoginInfo();
            if (!IsSuper(user))
                return RedirectToAction("Index");

            ViewBag.MPage = "abnormal";
            ViewBag.MTitle = "冻结明细";
            ViewBag.MSubtitle = "查看冻结账号并解冻";
            ViewBag.MShowRefresh = true;

            return View();
        }

        /// <summary>冻结账号（冻结或解冻玩家账号）</summary>
        public ActionResult BanPlayer()
        {
            M_LoginUser user = WebHelper.GetLoginInfo();
            if (!(IsSuper(user) || (user != null && user.IsFrozen == 1)))
                return RedirectToAction("Index");

            ViewBag.MPage = "banplayer";
            ViewBag.MTitle = "冻结账号";
            ViewBag.MSubtitle = "冻结或解冻玩家账号";
            ViewBag.MShowRefresh = true;

            return View();
        }

        /// <summary>禁用代理（禁用代理登录，可填写封号提示，该代理登录时弹出）</summary>
        public ActionResult BanAgent()
        {
            M_LoginUser user = WebHelper.GetLoginInfo();
            if (!IsSuper(user))
                return RedirectToAction("Index");

            ViewBag.MPage = "banagent";
            ViewBag.MTitle = "禁用代理";
            ViewBag.MSubtitle = "禁用代理账号登录";
            ViewBag.MShowRefresh = true;

            return View();
        }

        /// <summary>
        /// 控制管理（吃分 / 送分 / 控牌），复用电脑端总控接口：
        /// /Game/UserInfo/ApplyTotalControl、GetTotalControlStatus、CloseTotalControl、GetControlRecords。
        /// Mode=4 吃分需 IsKill，Mode=5 送分需 IsProbability，Mode=6 控牌需 IsRelease（与电脑端一致）。
        /// </summary>
        public ActionResult Control()
        {
            M_LoginUser user = WebHelper.GetLoginInfo();
            bool canKill = IsSuper(user) || (user != null && user.IsKill == 1);
            bool canRelease = IsSuper(user) || (user != null && user.IsProbability == 1);
            bool canCard = IsSuper(user) || (user != null && user.IsRelease == 1);
            if (!(canKill || canRelease || canCard))
                return RedirectToAction("Index");

            ViewBag.MPage = "control";
            ViewBag.MTitle = "控制管理";
            ViewBag.MSubtitle = "设置吃分、送分、控牌";
            ViewBag.MShowRefresh = false;
            ViewBag.CanKill = canKill;
            ViewBag.CanRelease = canRelease;
            ViewBag.CanCard = canCard;
            ViewBag.PresetAccount = Request.QueryString["id"] ?? string.Empty;

            return View();
        }

        /// <summary>会员盈亏（会员盈亏详情，头部副标题显示 代理名- 会员总数N）</summary>
        public ActionResult Huiyuan()
        {
            ViewBag.MPage = "huiyuan";
            ViewBag.MTitle = "会员盈亏详情";
            ViewBag.MShowRefresh = true;
            ViewBag.Today = DateTime.Now.ToString("yyyy-MM-dd");

            // 从"我的代理-我的会员-查看"跳转过来（?agency=）时副标题带代理名
            string agency = (Request.QueryString["agency"] ?? string.Empty).Trim();
            ViewBag.MSubtitleHtml =
                (agency.Length > 0 ? HttpUtility.HtmlEncode(agency) + "- " : "") +
                "会员总数<span id=\"memberTotal\">--</span>";

            return View();
        }

        /// <summary>
        /// 玩家详细信息（独立页面，替代原玩家弹窗里的详情浮层）。
        /// 数据由 /Game/UserInfo/GetUserDetail 提供；?id= 指定玩家账号。
        /// </summary>
        public ActionResult PlayerDetail()
        {
            M_LoginUser user = WebHelper.GetLoginInfo();

            ViewBag.MPage = "playerdetail";
            ViewBag.MTitle = "玩家详细信息";
            ViewBag.MShowRefresh = true;
            ViewBag.CanModifyPwd = IsSuper(user) || (user != null && user.IsModifyPwd == 1);
            ViewBag.CanControl = IsSuper(user)
                || (user != null && (user.IsKill == 1 || user.IsProbability == 1 || user.IsRelease == 1));
            ViewBag.PlayerAccount = Request.QueryString["id"] ?? string.Empty;

            return View();
        }
        #endregion
    }
}
