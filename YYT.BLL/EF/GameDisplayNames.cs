using YYT.Entity;

namespace YYT.BLL.EF
{
    /// <summary>后台展示名称；数据库和客户端接口仍使用原游戏标识。</summary>
    public static class GameDisplayNames
    {
        public static string GetName(int gameId, string storedName)
        {
            if (gameId == 55) return "大白兔";
            return gameId == 37 ? "点石成金" : storedName;
        }

        public static M_Games ToDisplayGame(M_Games game)
        {
            // 返回副本，避免展示转换污染 EF 实体或客户端使用的原始名称。
            return new M_Games
            {
                GameId = game.GameId,
                Name = GetName(game.GameId, game.Name),
                Enable = game.Enable,
                Num = game.Num,
                GameType = game.GameType
            };
        }
    }
}
