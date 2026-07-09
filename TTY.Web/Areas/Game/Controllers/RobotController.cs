using Google.Protobuf.WellKnownTypes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Remote;

namespace YYT.Web.Areas.Game.Controllers
{
    public class RobotController : Controller
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
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RobotController), ex);
            }
            return Json(list);
        }

        /// <summary>
        /// 押分类房间参数
        /// </summary>
        /// <param name="form"></param>
        /// <returns></returns>
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetParabetRoom(FormCollection form)
        {
            M_ParaBetRoom user = new M_ParaBetRoom();
            try
            {
                int GameId = form.Q<int>("GameId");
                int RoomId = form.Q<int>("RoomId");

                M_Games entity = new M_Games();
                entity.Enable = 1;
                string num = "";
                if (GameId > 0)
                    num = GameId.ToString();
                if (RoomId > -1)
                    num = GameId.ToString() + RoomId.ToString().PadLeft(3, '0');

                user = new B_BetGamePara().GetSingle(new M_ParaBetRoom { ID = Convert.ToInt32(num) });

            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RobotController), ex);
            }
            return Json(user);
        }

        /// <summary>
        /// 牌机/鱼机类房间参数
        /// </summary>
        /// <param name="form"></param>
        /// <returns></returns>
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetParaRoom(FormCollection form)
        {
            M_ParaRoom user = new M_ParaRoom();
            try
            {
                int GameId = form.Q<int>("GameId");
                int RoomId = form.Q<int>("RoomId");
                string num = "";
                if (GameId > -1)
                    num = GameId.ToString();
                if (RoomId > -1)
                    num = GameId.ToString() + RoomId.ToString().PadLeft(3, '0');
                user = new B_CardGamePara().GetSingle(new M_ParaRoom { ID = Convert.ToInt32(num) });
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RobotController), ex);
            }
            return Json(user);
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetRobot(FormCollection form)
        {
            M_EasyuiGridData<M_Robot> list = new M_EasyuiGridData<M_Robot>();
            try
            {
                string GameName = form.Q<string>("GameName");
                int RoomId = form.Q<int>("RoomId", -1);
                int TABLE_ID = form.Q<int>("TABLE_ID", -1);
                int pageIndex = form.Q<int>("page", 1);
                int pageSize = form.Q<int>("rows", 10);
                M_Page mPage = new M_Page(pageIndex, pageSize);
                M_Robot entity = new M_Robot
                {
                    GAME_NAME = GameName,
                    ROOM_ID = RoomId,
                    TABLE_ID = TABLE_ID
                };
                list = new B_Robot().getRobots(mPage, entity);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RobotController), ex);
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
                int GameType = form.Q<int>("GameType");
                int GameId = form.Q<int>("GameId");
                int RoomId = form.Q<int>("RoomSel");
                int TABLE_ID = form.Q<int>("TABLE_ID");
                int RobotNo = form.Q<int>("RobotNo");
                if (GameType == -1)
                {
                    msg.content = "请选择游戏类型！";
                    return Json(msg);
                }
                if (GameId == -1)
                {
                    msg.content = "请选择游戏！";
                    return Json(msg);
                }
                string GameName = "";
                string RoomName = "";
                if (RoomId == 0)
                {
                    RoomName = "初级场";
                }
                else if (RoomId == 1)
                {
                    RoomName = "中级场";
                }
                else if (RoomId == 2)
                {
                    RoomName = "高级场";
                }
                else if (RoomId == 3)
                {
                    RoomName = "VIP场";
                }
                M_Games game = new B_Games().GetSingle(new M_Games { GameId = GameId });
                if (game != null)
                {
                    GameName = game.Name;
                }
                M_Robot entity = new M_Robot
                {
                    GAME_TYPE = GameType,
                    GAME_ID = GameId,
                    ROOM_ID = RoomId,
                    GAME_NAME = GameName,
                    ROOM_NAME = RoomName,
                    TABLE_ID = TABLE_ID,
                    ROBOT_NO = RobotNo,
                };
                msg = new B_Robot().AddRobot(entity);
            }
            catch (Exception ex)
            {
                msg.content = "机器人添加失败。";
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RobotController), ex);
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
                    M_Robot mRobot = new M_Robot { ID = Convert.ToInt32(id) };
                    int val = new B_Robot().DelRobot(mRobot);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "删除成功！";
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RobotController), ex);
            }
            return Json(msg);
        }

    }


}