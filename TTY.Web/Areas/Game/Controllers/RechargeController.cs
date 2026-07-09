using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web.Mvc;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Web.Controllers;

namespace YYT.Web.Areas.Game.Controllers
{
    [MemberAuthorize]
    // GET: Game/Recharge
    public class RechargeController : BaseController
    {
        public ActionResult Index()
        {
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                ViewBag.TreeData = JsonConvert.SerializeObject(GetTreeDataByPermission(loginUser));
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RechargeController), ex);
            }
            return View();
        }
        private List<M_TreeModel> GetTreeDataByPermission(M_LoginUser loginUser)
        {
            List<M_TreeModel> list = new List<M_TreeModel>()
            {
                new M_TreeModel{ id = -2, text = "用户充值", attributes = new { payType = 0 } },
                new M_TreeModel{ id = -2, text = "用户兑换", attributes = new { payType = 1 } },

                new M_TreeModel{ id = 2, text = "代理充值", attributes = new { payType = 0 } },
                new M_TreeModel{ id = 2, text = "代理兑换", attributes = new { payType = 1 } },

                new M_TreeModel{ id = 1, text = "总代充值", attributes = new { payType = 0 } },
                new M_TreeModel{ id = 1, text = "总代兑换", attributes = new { payType = 1 } },

                //new M_TreeModel{ id = 9, text = "副管充值", attributes = new { payType = 0 } },
                //new M_TreeModel{ id = 9, text = "副管兑换", attributes = new { payType = 1 } }
            };

            if (loginUser.UserPriv == 0)//超级管理
                return list;

            else if (loginUser.UserPriv == 1)//总代理
                return list.Where(c => c.id == 2 || c.id == -2).ToList();

            else if (loginUser.UserPriv > 0 && loginUser.UserPriv < 9)//普通代理
                if (loginUser.UserPriv < 3)
                    return list.Where(c => c.id == -2 || c.id == 2).ToList();
                else
                    return list.Where(c => c.id == -2).ToList();

            else if (loginUser.UserPriv == 9)//副管理
                return list.Where(c => c.id < 9).ToList();

            else // 开发、运维及其它
                return new List<M_TreeModel>();
        }


        [AjaxOnly]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult SaveCoin(FormCollection form)
        {
            Msg msg = new Msg(0, "操作失败！");
            try
            {
                int coin = form.Q<int>("coin");// 充值币数量
                string id = form.Q<string>("id");// 充值的对象ID
                int idType = form.Q<int>("idType", 0);// 默认为 0通过用户账号充值  1通过平台用户唯一标识充值
                EIDType eIDType = (EIDType)idType;
                int rechargeType = form.Q<int>("payType", -1);// 0：充值  1：兑换
                int targetType = form.Q<int>("targetType", 0);// 充值的对象类型  -1：用户  2：一般代理  1：总代  9：副管理

                if (rechargeType == 0)
                    msg.content = "充值" + msg.content;
                else
                    msg.content = "兑换" + msg.content;

                if (string.IsNullOrWhiteSpace(id))
                {
                    msg.content += "请选择充值对象！";
                    goto err;
                }
                if (coin <= 0)
                {
                    msg.content += "请填充值数量！";
                    goto err;
                }
                if (rechargeType == -1)
                {
                    msg.content += "无法操作类型！";
                    goto err;
                }
                if (targetType == 0)
                {
                    msg.content += "无法充值对象的类型！";
                    goto err;
                }
                if (eIDType == EIDType.UserID && !System.Text.RegularExpressions.Regex.IsMatch(id,"^\\d+$"))
                {
                    msg.content += "请输入正确的用户ID！";
                    goto err;
                }

                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser != null)
                {
                    if (loginUser.UserPriv > 0 && loginUser.IsUpDown != 1)
                    {
                        msg.content = "没有上下分权限！";
                        goto err;
                    }
                    //if (loginUser.UserPriv != 0)
                    //{
                   //     int val = new B_Users().SelectUserINHALL(id, idType.ToString());
                    //    if (val == 1)
                    //    {
                    //        msg.content = "该用户在线.不可以充值";
                    //        goto err;
                    //    }
                    //}
                    
                    /// <summary>
                    /// 是否是真金版
                    /// </summary>
                    bool isRMB = ConfigHelper.Get("IsRMB").Equals("1");
                    /// <summary>
                    /// 真金版兑换率
                    /// </summary>
                    int exchangeRate = 0;
                    if (isRMB == true)
                    {
                        exchangeRate = Convert.ToInt32(ConfigHelper.Get("ExchangeRate"));
                        if (exchangeRate > 0)
                            coin *= exchangeRate;
                    }

                    M_Admin rechargeUser = loginUser.ToAdminType();
                    EAdminType eAdminType = (EAdminType)targetType;
                    M_Recharge rechargeTarget = new M_Recharge { ID = id, Coin = coin, RechargeType = rechargeType, AdminType = eAdminType, IDType = eIDType };
                    B_ReChargeBase bll = new B_ReChargeBase(rechargeUser, rechargeTarget);
                    if (eAdminType == EAdminType.None)
                        msg = bll.PlayerReCharge();
                    else
                        msg = bll.AgencyReCharge();
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RechargeController), ex);
            }
        err:
            return Json(msg);
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult GetUserOptions(FormCollection form)
        {
            var list = new List<object>();
            try
            {
                string keyword = form.Q<string>("keyword");
                if (string.IsNullOrWhiteSpace(keyword))
                    return Json(list);

                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(list);

                using (var ef = new GameDbContext())
                {
                    var query = ef.Users.Where(c => c.ID.Contains(keyword));
                    if (loginUser.UserPriv != 0)
                    {
                        List<string> agencies = new B_Admin().GetManagedAgencyAccounts(ef, loginUser);
                        if (agencies == null || agencies.Count < 1)
                            return Json(list);

                        query = query.Where(c => agencies.Contains(c.AGENCY));
                    }

                    var users = query
                        .OrderBy(c => c.ID)
                        .Take(20)
                        .Select(c => new { c.ID })
                        .ToList();

                    list = users
                        .Select(c => new { c.ID })
                        .Cast<object>()
                        .ToList();
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RechargeController), ex);
            }
            return Json(list);
        }

        [AjaxOnly]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult QueryCoins(FormCollection form)
        {
            Msg msg = new Msg(0, "查询失败！");
            try
            {
                string id = form.Q<string>("id");
                int idType = form.Q<int>("idType", 0);
                int targetType = form.Q<int>("targetType", 0);
                if (string.IsNullOrWhiteSpace(id))
                {
                    msg.content = "请选择查询对象！";
                    return Json(msg);
                }

                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(msg);
                if (loginUser.UserPriv > 0 && loginUser.IsUpDown != 1)
                {
                    msg.content = "没有上下分权限！";
                    return Json(msg);
                }

                M_Admin rechargeUser = loginUser.ToAdminType();
                M_Recharge rechargeTarget = new M_Recharge
                {
                    ID = id,
                    Coin = 0,
                    RechargeType = 0,
                    AdminType = (EAdminType)targetType,
                    IDType = (EIDType)idType
                };
                if (rechargeTarget.AdminType == EAdminType.None && rechargeTarget.IDType == EIDType.UserID && !System.Text.RegularExpressions.Regex.IsMatch(id, "^\\d+$"))
                {
                    msg.content = "请输入正确的用户ID！";
                    return Json(msg);
                }
                msg = new B_ReChargeBase(rechargeUser, rechargeTarget).QueryTargetCoins();
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RechargeController), ex);
            }
            return Json(msg);
        }


        public ActionResult Records()
        {
            return View();
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult ClearRecords()
        {
            M_LoginUser loginUser = WebHelper.GetLoginInfo();
            if (loginUser == null)
                return Json(new { code = 0, msg = "无权限" });
            try
            {
                int result = new B_ReChargeRecords().ClearRecords(loginUser);
                if (result > 0)
                    return Json(new { code = 1, msg = "清理成功" });
                return Json(new { code = 0, msg = "清理失败" });
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RechargeController), ex);
                return Json(new { code = 0, msg = "操作异常" });
            }
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult GetReChargeRecords(FormCollection form)
        {
            M_EasyuiGridData<M_ReChargeRecords> list = new M_EasyuiGridData<M_ReChargeRecords>();
            M_EasyuiGridData<M_ReChargeRecordsDao> listDao = new M_EasyuiGridData<M_ReChargeRecordsDao>();
            try
            {
                string id = form.Q<string>("ID");
                string orderNo = form.Q<string>("OrderNo");
                string payNo = form.Q<string>("PayNo");
                int processed = form.Q<int>("Processed");
                string srch_StartTime = form.Q<string>("srch_StartTime");
                string srch_EndTime = form.Q<string>("srch_EndTime");
                string Agency= form.Q<string>("Agency");
                int pageIndex = form.Q<int>("page", 1);
                int pageSize = form.Q<int>("rows", 10);

                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(list);

                M_Page mPage = new M_Page(pageIndex, pageSize);
                M_ReChargeRecordsDao entity = new M_ReChargeRecordsDao
                {
                    GameID = id,
                    OrderNo = orderNo,
                    PayNo = payNo,
                    Processed = processed,
                    StartTime= srch_StartTime,
                    EndTime= srch_EndTime,
                    Agency= Agency
                };

                list = new B_ReChargeRecords().GetReChargeRecords(loginUser, mPage, entity);
              
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RechargeController), ex);
            }

            return Json(list);
        }
        [AjaxOnly]
        [HttpPost]
        public ActionResult ConfirmReCharge(FormCollection form)
        {
            Msg msg = new Msg(0, "处理失败！");
            try
            {
                string orderNo = form.Q<string>("OrderNo");// 订单编号 
                if (string.IsNullOrWhiteSpace(orderNo)) 
                {
                    msg.content += "获取订单编号失败！";
                    goto err;
                }
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser != null)
                {
                    msg = new B_ReChargeRecords().ConfirmReChargeOrder(loginUser, orderNo);
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RechargeController), ex);
            }
        err:
            return Json(msg);
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult OrderRefuseDelCoins(FormCollection form)
        {
            Msg msg = new Msg(0, "处理失败！");
            try
            {
                string orderNo = form.Q<string>("OrderNo");// 订单编号 
                if (string.IsNullOrWhiteSpace(orderNo))
                {
                    msg.content += "获取订单编号失败！";
                    goto err;
                }
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser != null)
                {
                    msg = new B_ReChargeRecords().OrderRefuseDelCoins(loginUser, orderNo);
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RechargeController), ex);
            }
        err:
            return Json(msg);
        }
        [AjaxOnly]
        [HttpPost]
        public ActionResult OrderProcess(FormCollection form)
        {
            Msg msg = new Msg(0, "确认失败！");
            try
            {
                string orderNo = form.Q<string>("OrderNo");// 订单编号 
                if (string.IsNullOrWhiteSpace(orderNo))
                {
                    msg.content += "获取订单编号失败！";
                    goto err;
                }
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser != null)
                {
                    msg = new B_ReChargeRecords().OrderProcessOrder(orderNo);
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RechargeController), ex);
            }
        err:
            return Json(msg);
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult OrderRefuse(FormCollection form)
        {
            Msg msg = new Msg(0, "拒绝处理失败！");
            try
            {
                string orderNo = form.Q<string>("OrderNo");// 订单编号 
                if (string.IsNullOrWhiteSpace(orderNo))
                {
                    msg.content += "获取订单编号失败！";
                    goto err; 
                }
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser != null)
                {
                    msg = new B_ReChargeRecords().OrderOrderRefuse(orderNo);
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RechargeController), ex);
            }
        err:
            return Json(msg);
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult OrderRefuseEx(FormCollection form)
        {
            Msg msg = new Msg(0, "拒绝处理失败！");
            try
            {
                string orderNo = form.Q<string>("OrderNo");// 订单编号 
                if (string.IsNullOrWhiteSpace(orderNo))
                {
                    msg.content += "获取订单编号失败！";
                    goto err;
                }
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser != null)
                {
                    msg = new B_ReChargeRecords().OrderOrderRefuseEx(orderNo);
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RechargeController), ex);
            }
        err:
            return Json(msg);
        }

        public ActionResult CashierInfo()
        {
            return View();
        }
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetCashierInfos(FormCollection form)
        {
            M_EasyuiGridData<M_CashierInfo> list = new M_EasyuiGridData<M_CashierInfo>();
            try
            {
                string name = form.Q<string>("Name");
                string account = form.Q<string>("Account");
                int payType = form.Q<int>("PayType", 0);

                int pageIndex = form.Q<int>("page", 1);
                int pageSize = form.Q<int>("rows", 10);

                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(list);

                M_Page mPage = new M_Page(pageIndex, pageSize);
                M_CashierInfo entity = new M_CashierInfo { Account = account, Name = name, PayType = payType };

                list = new B_CashierInfo().GetCashierInfos(loginUser, mPage, entity);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RechargeController), ex);
            }
            return Json(list);
        }
        [AjaxOnly]
        [HttpPost]
        public ActionResult SaveCashierInfo(M_CashierInfo entity)
        {
            Msg msg = new Msg(0, "保存失败！");
            try
            {
                if (ModelState.IsValid)
                {
                    M_LoginUser loginUser = WebHelper.GetLoginInfo();
                    if (loginUser == null)
                        return Json(msg);
                    entity.Agency = loginUser.Accounts;// 收款信息所属代理

                    msg = new B_CashierInfo().SaveCashierInfo(entity);
                }
                else
                {
                    msg.content = ModelState.Values.GetErrMsg();
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RechargeController), ex);
            }
            return Json(msg);
        }



        [AjaxOnly]
        [HttpPost]
        public ActionResult DelCashierInfo(FormCollection form)
        {
            Msg msg = new Msg(0, "删除失败！");
            try
            {
                string cid = form.Q<string>("CID");// 订单编号 
                if (string.IsNullOrWhiteSpace(cid))
                {
                    msg.content += "获取收款人信息失败！";
                    return Json(msg);
                }

                M_CashierInfo entity = new M_CashierInfo { CID = cid };
                msg = new B_CashierInfo().DelCashierInfo(entity);
                // 清除文件
                if (msg.code == 1)
                {
                    string dir = Server.MapPath("~/Upload/");
                    string path = System.IO.Path.Combine(dir, entity.QRCodeImg);
                    if (System.IO.File.Exists(path))
                        System.IO.File.Delete(path);
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RechargeController), ex);
            }
            return Json(msg);
        }

        [AjaxOnly]
        //[HttpPost]
        public ActionResult SelectUserINHALL(string parm,string selIdType)
        {
            Msg msg = new Msg(0, "该用户不在线，不可以充值");
            try
            {
                int val = new B_Users().SelectUserINHALL(parm, selIdType);
                if (val == 1)
                {
                    msg.code = val;
                    msg.content = "该用户在线.可以充值";
                }
               
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RechargeController), ex);
            }
            return Json(msg);
        }
    }
}
