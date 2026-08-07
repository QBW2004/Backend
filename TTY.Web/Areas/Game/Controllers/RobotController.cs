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
        /// 桌台名称列表：全游戏类型统一从 roomtableconfig 读取(玩家/机器人已锁定第一房间)，
        /// TableName 为空时保底"桌台"+TableIndex。
        /// </summary>
        /// <param name="form"></param>
        /// <returns></returns>
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetRobotTableList(FormCollection form)
        {
            List<object> tableList = new List<object>();
            try
            {
                int GameId = form.Q<int>("GameId");
                if (GameId > 0)
                {
                    using (var ef = new GameDbContext())
                    {
                        var rows = ef.Database.SqlQuery<BetTableSelRow>(
                            "SELECT TableIndex, TableName FROM roomtableconfig WHERE GAME_ID={0} AND RoomIndex=0 ORDER BY TableIndex", GameId).ToList();
                        int idx = 0;
                        foreach (BetTableSelRow r in rows)
                        {
                            tableList.Add(new
                            {
                                id = r.TableIndex,
                                text = string.IsNullOrWhiteSpace(r.TableName) ? ("桌台" + r.TableIndex) : r.TableName,
                                selected = idx == 0
                            });
                            idx++;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.RobotController), ex);
            }
            return Json(tableList);
        }

        // roomtableconfig 桌台选择行映射（机器人页桌台下拉用）
        public class BetTableSelRow
        {
            public int TableIndex { get; set; }
            public string TableName { get; set; }
        }

        /// <summary>
        /// 牌机/鱼机类房间参数(已废弃：机器人页桌台统一走 GetRobotTableList)
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
                string TableName = form.Q<string>("TABLE_NAME");
                int pageIndex = form.Q<int>("page", 1);
                int pageSize = form.Q<int>("rows", 10);
                M_Page mPage = new M_Page(pageIndex, pageSize);
                M_Robot entity = new M_Robot
                {
                    GAME_NAME = GameName,
                    TABLE_NAME = TableName,
                    // 房间/机台搜索已移除：显式 -1 跳过 BLL 的 ROOM_ID/TABLE_ID 过滤(int 默认 0 会误过滤成只显示第一张桌)
                    ROOM_ID = -1,
                    TABLE_ID = -1
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
                int TABLE_ID = form.Q<int>("TABLE_ID");
                int RobotNo = form.Q<int>("RobotNo");
                // 玩家/机器人已锁定只能进入第一房间：ROOM_ID 恒为 0(押注类一房N桌亦为0)
                int RoomId = 0;
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
                // 押注类单房间固定"默认场"；鱼机/牌机锁定第一房间"初级场"。
                string RoomName = GameType == 0 ? "默认场" : "初级场";
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