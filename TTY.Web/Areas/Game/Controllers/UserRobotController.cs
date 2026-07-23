using Google.Protobuf.WellKnownTypes;
using Microsoft.Ajax.Utilities;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Services.Description;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Remote;
using YYT.Web.Controllers;

namespace YYT.Web.Areas.Game.Controllers
{
    [MemberAuthorize]
    public class UserRobotController : BaseController
    {
        // GET: Game/Robot
        public ActionResult Index()
        {
            return View();
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult GetGamesTreeData(FormCollection form)
        {
            List<M_TreeModel> list = new List<M_TreeModel>();
            try
            {
                int GameType = form.Q<int>("GameType");

                M_Games entity = new M_Games();
                entity.Enable = 1;

                if (GameType > -1)
                    entity.GameType = GameType;

                list = new B_Games().GetGamesTreeData(entity);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserRobotController), ex);
            }
            return Json(list);
        }

        // GetParabetRoom / GetParaRoom 已删除：全 Backend 无调用方，为冗余死代码。
        // 押注类房间参数查询统一走 RobotController.GetParabetRoom(一房N桌模型)。

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetRobot(FormCollection form)
        {
            M_EasyuiGridData<M_UserRobot> list = new M_EasyuiGridData<M_UserRobot>();
            try
            {
                string UserName = form.Q<string>("UserName");
                string UserNick = form.Q<string>("UserNick");

                int pageIndex = form.Q<int>("page", 1);
                int pageSize = form.Q<int>("rows", 10);
                M_Page mPage = new M_Page(pageIndex, pageSize);
                M_UserRobot entity = new M_UserRobot
                {
                    UserName = UserName,
                    UserNick= UserNick
                 
                };
                list = new B_UserRobot().getRobots(mPage, entity);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserRobotController), ex);
            }
            return Json(list);
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult SaveRobot(FormCollection form)
        {
            Msg msg = new Msg(0, "机器人添加失败！");
            try
            {
                string UserName = form.Q<string>("UserName");
                string UserNick = form.Q<string>("UserNick");
                int Ico = form.Q<int>("Ico");
                int Lev = form.Q<int>("Lev");
                int Sex = form.Q<int>("Sex");
                int Gold = form.Q<int>("Gold");

                if (string.IsNullOrWhiteSpace(UserName))
                {
                    msg.content = "机器人账户不能为空！";
                    return Json(msg);
                }
                if (string.IsNullOrWhiteSpace(UserNick))
                {
                    msg.content = "机器人昵称不能为空！";
                    return Json(msg);
                }
                if (Lev<=0)
                {
                    msg.content = "最小等级为1！";
                    return Json(msg);
                }
                if (Gold <= 0)
                {
                    msg.content = "金币不能小于等于0！";
                    return Json(msg);
                }
                M_UserRobot entity = new M_UserRobot
                {
                    PassW= "123456654321",
                    UserName = UserName,
                    UserNick = UserNick,
                    Ico = Ico,
                    Lev = Lev,
                    Sex = Sex,
                    Gold = Gold
                };
                msg = new B_UserRobot().AddRobot(entity);
            }
            catch (Exception ex)
            {
                msg.content = "机器人添加失败。";
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserRobotController), ex);
            }
            return Json(msg);
        }


        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult SaveBatchRobot(FormCollection form)
        {
            Msg msg = new Msg(0, "机器人添加失败！");
            try
            {
                int Ico = form.Q<int>("Ico");
                int Lev = form.Q<int>("Lev");
                int Sex = form.Q<int>("Sex");
                int Gold = form.Q<int>("Gold");
                int Num = form.Q<int>("Num");
                if (Lev <= 0)
                {
                    msg.content = "最小等级为1！";
                    return Json(msg);
                }
                if (Gold <= 0)
                {
                    msg.content = "金币不能小于等于0！";
                    return Json(msg);
                }
                if (Num <= 0)
                {
                    msg.content = "批量添加机器人数量不能为0！";
                    return Json(msg);
                }
                for (int i = 0; i < Num; i++)
                {
                    int number = GetRomNum();
                    string UserName = "VIP" + number;
                    bool isTrue = new B_UserRobot().Exists(new M_UserRobot { UserName = UserName });
                    if(isTrue ==true)
                    {
                        Num= Num + 1;
                        continue;
                    }
                    M_UserRobot entity = new M_UserRobot
                    {
                        PassW = "123456654321",
                        UserName = UserName,
                        UserNick = UserName,
                        Ico = Ico,
                        Lev = Lev,
                        Sex = Sex,
                        Gold = Gold
                    };
                    msg = new B_UserRobot().AddRobot(entity);
                }
            }
            catch (Exception ex)
            {
                msg.content = "机器人添加失败。";
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserRobotController), ex);
            }
            return Json(msg);
        }
        public int GetRomNum()
        {
            Random random = new Random();
            int randomNumber = random.Next(1, 10) * 100000 + random.Next(0, 100000);
            return randomNumber;
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult UpdateRobot(FormCollection form)
        {
            Msg msg = new Msg(0, "机器人修改失败！");
            try
            {
                long ID = form.Q<long>("ID1");
                string UserName = form.Q<string>("UserName1");
                //string UserNick = form.Q<string>("UserNick1");
                int Ico = form.Q<int>("Ico1");
                int Lev = form.Q<int>("Lev1");
                int Sex = form.Q<int>("Sex1");
                int Gold = form.Q<int>("Gold1");

                if (string.IsNullOrWhiteSpace(UserName))
                {
                    msg.content = "机器人账户不能为空！";
                    return Json(msg);
                }
                //if (string.IsNullOrWhiteSpace(UserNick))
                //{
                //    msg.content = "机器人昵称不能为空！";
                //    return Json(msg);
                //}
                if (Lev <= 0)
                {
                    msg.content = "最小等级为1！";
                    return Json(msg);
                }
                if (Gold <= 0)
                {
                    msg.content = "金币不能小于等于0！";
                    return Json(msg);
                }
                M_UserRobot entity = new M_UserRobot
                {
                    ID = ID,
                    UserName = UserName,
                    //UserNick = UserNick,
                    Ico = Ico,
                    Lev = Lev,
                    Sex = Sex,
                    Gold = Gold
                };
                msg = new B_UserRobot().UpdateRobot(entity);
            }
            catch (Exception ex)
            {
                msg.content = "机器人修改失败。";
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserRobotController), ex);
            }
            return Json(msg);
        }


        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult UpdateBatchRobot(FormCollection form)
        {
            Msg msg = new Msg(0, "机器人修改失败！");
            try
            {
                string ID = form.Q<string>("ID7");
                string UserNick = form.Q<string>("UserNick");
                int Gold = form.Q<int>("Gold");
                if (string.IsNullOrWhiteSpace(UserNick))
                {
                    msg.content = "机器人昵称不能为空！";
                    return Json(msg);
                }
                if (Gold <= 0)
                {
                    msg.content = "金币不能小于等于0！";
                    return Json(msg);
                }
                if (ID.Contains(","))
                {
                    string[] strArray=ID.Split(',');
                    foreach (string str in strArray) {
                        M_UserRobot entity = new M_UserRobot
                        {
                            ID = Convert.ToInt64(str),
                            UserNick= UserNick,
                            Gold = Gold
                        };
                        msg = new B_UserRobot().UpdateBatchRobot(entity);
                    }
                }
                else
                {
                    M_UserRobot entity = new M_UserRobot
                    {
                        ID = Convert.ToInt64(ID),
                        UserNick = UserNick,
                        Gold = Gold
                    };
                    msg = new B_UserRobot().UpdateBatchRobot(entity);
                }
            
            }
            catch (Exception ex)
            {
                msg.content = "机器人修改失败。";
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserRobotController), ex);
            }
            return Json(msg);
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult DelRobot(FormCollection form)
        {
            Msg msg = new Msg(0, "删除失败！");
            try
            {
                string id = form.Q<string>("ID");
                if (!string.IsNullOrWhiteSpace(id))
                {
                    M_UserRobot mRobot = new M_UserRobot { ID = Convert.ToInt32(id) };
                    int val = new B_UserRobot().DelRobot(mRobot);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "删除成功！";
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserRobotController), ex);
            }
            return Json(msg);
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult batchDelete(FormCollection form)
        {
            Msg msg = new Msg(0, "删除失败！");
            try
            {
                string ids = form.Q<string>("ids");
                if (!string.IsNullOrWhiteSpace(ids))
                {
                    String[] idArr = ids.Split(',');
                    Boolean f = false;
                    for (int i = 0; i < idArr.Length; i++) {
                        M_UserRobot mRobot = new M_UserRobot { ID = Convert.ToInt32(idArr[i]) };
                        int val = new B_UserRobot().DelRobot(mRobot);
                    }
                }
             
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserRobotController), ex);
            }
            return Json(msg);
        }

    }


}