using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using YYT.BLL.Services.GameServer;

namespace YYT.BLL.EF
{
    /// <summary>播放前按同一中奖事件核对真人占用；不使用昵称或显示台号推断机台身份。</summary>
    public static class AnnouncementRules
    {
        public sealed class Record
        {
            public int GameId { get; set; }
            public int GameType { get; set; }
            public long RoomId { get; set; }
            public long TableId { get; set; }
            public int IsRobot { get; set; }
            public string LineAgent { get; set; }
            public string Text { get; set; }
            public int AgeSeconds { get; set; }
        }

        public sealed class Decision
        {
            public bool Play { get; set; }
            public string Content { get; set; }
        }

        public static Decision Check(Record record, TableDisplayMap tables, string line,
            IEnumerable<OnlinePlayerInfo> players)
        {
            var denied = new Decision { Content = "" };
            if (record == null || record.AgeSeconds < 0 || record.AgeSeconds > 300 || tables == null) return denied;
            int? index = tables.HistoryTableIndex(record.GameId, record.GameType, record.RoomId, record.TableId, record.LineAgent);
            if (!index.HasValue || !tables.IsVisible(record.GameId, index.Value, line)) return denied;
            if (record.IsRobot == 0) return new Decision { Play = true, Content = WireText(record.Text) };
            if (players == null) return denied;
            foreach (var player in players)
            {
                if (player.GameID != record.GameId) continue;
                // 缺少坐下标记是旧中心或不完整快照，不能把选桌默认台号或未知状态当作空桌。
                if (!player.IsSitDown.HasValue) return denied;
                if (player.IsSitDown.Value && player.TableId == index.Value) return denied;
            }
            string text = ReplaceMachine(record.Text, tables.OnlineLabel(record.GameId, index.Value));
            return text == null ? denied : new Decision { Play = true, Content = WireText(text) };
        }

        /// <summary>保留事件原始名字、奖项与分数，只修正文案中由服务端生成的台号段。</summary>
        public static string ReplaceMachine(string text, string label)
        {
            if (string.IsNullOrEmpty(text) || string.IsNullOrEmpty(label) || label == "--") return null;
            int end = text.LastIndexOf("】机台，打中【", StringComparison.Ordinal);
            if (end < 0) return null;
            int start = text.LastIndexOf("】【", end, StringComparison.Ordinal);
            return start < 0 ? null : text.Substring(0, start + "】【".Length) + label + text.Substring(end);
        }

        /// <summary>与 NoticeQueue 的 UTF-8 500 字节上限一致，兼容已经进入客户端的截断正文。</summary>
        public static string WireText(string text)
        {
            byte[] bytes = Encoding.UTF8.GetBytes(text ?? "");
            if (bytes.Length <= 500) return text ?? "";
            int length = 500;
            while (length > 0 && (bytes[length] & 0xc0) == 0x80) length--;
            return Encoding.UTF8.GetString(bytes, 0, length);
        }
    }
}
