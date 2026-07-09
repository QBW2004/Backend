using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Remote;
using YYT.Web.Controllers;
using YYT.Web.Models;

namespace YYT.Web.Areas.Game.Controllers
{
    [MemberAuthorize]
    public class GameRecordController : BaseController
    {
        // GET: Game/GameRecord
        public ActionResult Index()
        {
            return View();
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult GetGamesTreeData()
        {
            List<object> list = new List<object>();
            try
            {
                using (var ef = new GameDbContext())
                {
                    var games = ef.Games
                        .Where(c => c.Enable == 1 && (c.GameType == 0 || c.GameType == 1 || c.GameType == 2 || c.GameType == 3))
                        .OrderBy(c => c.GameType)
                        .ThenBy(c => c.GameId)
                        .ToList();

                    // 按游戏类型分组：0押注 1牌机 2鱼机 3拉霸
                    var typeNames = new Dictionary<int, string>
                    {
                        { 0, "押注类" },
                        { 1, "牌机类" },
                        { 2, "鱼机类" },
                        { 3, "拉霸类" }
                    };

                    foreach (var kv in typeNames)
                    {
                        int gameType = kv.Key;
                        var typeGames = games.Where(g => g.GameType == gameType).ToList();
                        if (typeGames.Count > 0)
                        {
                            var children = new List<object>();
                            foreach (var g in typeGames)
                            {
                                children.Add(new
                                {
                                    id = g.GameId,
                                    text = g.Name,
                                    attributes = new { GameType = g.GameType }
                                });
                            }
                            list.Add(new
                            {
                                id = "type_" + gameType,
                                text = kv.Value,
                                state = "open",
                                children = children
                            });
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(GameRecordController), ex);
            }
            return Json(list);
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult GetGameRecord(FormCollection form)
        {
            Msg msg = new Msg(0, "获取数据失败！");
            try
            {
                int gameType = form.Q<int>("GAME_TYPE", -1);
                int gameId = form.Q<int>("GAME_ID", -1);
                int deskIndex = form.Q<int>("DESK_ID", -1);
                if (gameType > -1 && gameId > -1 && deskIndex > -1)
                {
                    if (gameType == 3)
                    {
                        msg.code = 1;
                        msg.content = "参数获取成功！";
                        msg.datas = new B_GameAccLaba().GetAccLabas(new M_GameAccLaba { GameId = gameId });
                    }
                    else
                    {
                        var srv = new SConnect();
                        byte[] bytes = srv.SendReadBytes(EScMsgType.GA, gameId.ToString().PadLeft(2, '0'), deskIndex.ToString().PadLeft(3, '0'));

                        if (bytes != null && bytes.Length > 0)
                        {
                            object obj = GetAcc(gameType, bytes);
                            if (obj != null)
                            {
                                msg.code = 1;
                                msg.content = "参数获取成功！";
                                msg.datas = obj;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.GameRecordController), ex);
            }
            return Json(msg);
        }
        public static byte[] StringToByteArray(string hex)
        {
            int NumberChars = hex.Length;
            byte[] bytes = new byte[NumberChars / 2];
            for (int i = 0; i < NumberChars; i += 2)
                bytes[i / 2] = Convert.ToByte(hex.Substring(i, 2), 16);
            return bytes;
        }
        private object GetAcc(int gameType, byte[] bytes)
        {
            switch (gameType)
            {
                case 0:// 押注类
                    return new GameAccContext(new BetAcc(bytes)).GetGameAcc();
                case 1:// 牌机类
                    return new GameAccContext(new CardAcc(bytes)).GetGameAcc();
                case 2:// 鱼机类
                    return new GameAccContext(new FishAcc(bytes)).GetGameAcc();
            }
            return null;
        }

        // GET: Game/TableRecords
        public ActionResult TableRecords()
        {
            M_LoginUser loginUser = WebHelper.GetLoginInfo();
            if (loginUser == null || loginUser.UserPriv != 0)
                return RedirectToAction("NoAuthorize", "Common", new { area = "" });
            return View();
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult ClearTableRecords()
        {
            M_LoginUser loginUser = WebHelper.GetLoginInfo();
            if (loginUser == null || loginUser.UserPriv != 0)
                return Json(new { code = 0, msg = "无权限" });
            try
            {
                int result = new B_GameRecords().ClearTableCoinRecords(loginUser);
                if (result > 0)
                    return Json(new { code = 1, msg = "清理成功" });
                return Json(new { code = 0, msg = "清理失败" });
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(GameRecordController), ex);
                return Json(new { code = 0, msg = "操作异常" });
            }
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult GetTableRecords(FormCollection form)
        {
            M_EasyuiGridData<M_TableCoinRecord_DTO> list = new M_EasyuiGridData<M_TableCoinRecord_DTO>();
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null || loginUser.UserPriv != 0)
                    return Json(list);

                int gameId = form.Q<int>("GameID", -1);
                int roomId = form.Q<int>("RoomID", -1);
                int tableId = form.Q<int>("TableID", -1);
                int pageIndex = form.Q<int>("page", 1);
                int pageSize = form.Q<int>("rows", 10);

                M_Page mPage = new M_Page(pageIndex, pageSize);
                M_TableCoinRecord entity = new M_TableCoinRecord { GameID = gameId, RoomID = roomId, TableID = tableId };
                list = new B_GameRecords().GetTableCoinRecord(mPage, entity);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.GameRecordController), ex);
            }
            return Json(list);
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult ClearTableACC(FormCollection form)
        {
            Msg msg = new Msg(0, "操作失败！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null || loginUser.UserPriv != 0)
                {
                    msg.content = "无权限";
                    return Json(msg);
                }

                int gameId = form.Q<int>("GameID", -1);
                int roomId = form.Q<int>("RoomID", -1);
                int tableId = form.Q<int>("TableID", -1);

                if (gameId > -1 && roomId > -1 && tableId > -1)
                {
                    var srv = new SConnect();
                    string rst = srv.SendNotTranlation(
                        EScMsgType.CA,
                        gameId.ToString().PadLeft(3, '0'),
                        roomId.ToString().PadLeft(3, '0'),
                        (tableId - 1).ToString().PadLeft(3, '0'));

                    msg.code = 1;
                    msg.content = "操作成功，请耐心等待服务器处理！";
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.GameRecordController), ex);
            }
            return Json(msg);
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult GetGamesTreeData(FormCollection form)
        {
            List<M_TreeModel> list = new List<M_TreeModel>();
            try
            {
                int gameId = form.Q<int>("id", -1);

                M_Games entity = new M_Games();
                entity.Enable = 1;

                if (gameId > -1)
                    entity.GameId = gameId;

                list = new B_Games().GetGamesTreeData(entity);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.GameRecordController), ex);
            }
            return Json(list);
        }

        [AjaxOnly]
        [HttpPost]
        public ActionResult GetGameRoomDeskPara(FormCollection form)
        {
            List<M_GameRoomDeskPara> list = new List<M_GameRoomDeskPara>();
            try
            {
                int gameType = form.Q<int>("GAME_TYPE", -1);
                int gameId = form.Q<int>("GAME_ID", -1);

                IGamePara gamePara = null;
                if (gameType == 0)
                    gamePara = new B_BetGamePara();
                else if (gameType == 1)
                    gamePara = new B_CardGamePara();
                else if (gameType == 2)
                    gamePara = new B_FishGamePara();

                if (gamePara != null && gameId > -1)
                    list = gamePara.GetGameRoomDeskPara(gameId);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.GameRecordController), ex);
            }
            return Json(list);
        }
    }
}
