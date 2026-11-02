using System.Collections.Generic;
using System.Linq;
using YYT.Entity;

namespace YYT.BLL.EF
{
    /// <summary>
    /// 总控（总点杀4/总放水5/总控牌6）的互斥与展示口径。
    /// 吃分和放水互斥（同一时间只有一个生效）；控牌与吃分/放水共存——
    /// 控牌独立按次数执行，其实际净收益同时计入执行中的吃分/放水进度。
    /// </summary>
    public static class TotalControlRules
    {
        // 总控能力按当前开放游戏的实际子服协议收口：
        // 54(麻将胡了)总吃分走独立的 mCtrlType=27 低奖结果通道；
        // 总放水在鱼机/押注应用强度，在牌机/拉霸/麻将保留目标并累计实际净收益（含控牌）。
        public static bool IsModeSupportedForGame(int mode, int gameId)
        {
            if (mode == (int)EControlMode.TotalKill || mode == (int)EControlMode.TotalRelease)
            {
                return gameId == 2 || gameId == 3 || gameId == 5 || gameId == 10 || gameId == 13
                    || gameId == 15 || gameId == 16 || gameId == 25 || gameId == 37 || gameId == 40
                    || gameId == 44 || gameId == 53 || gameId == 54 || gameId == 55;
            }
            return mode == (int)EControlMode.TotalCard;
        }

        public static string UnsupportedModeMessage(int mode, int gameId)
        {
            if (mode == (int)EControlMode.TotalRelease)
                return "当前游戏暂不支持总放水！";
            return "当前游戏暂不支持该总控模式！";
        }

        /// <summary>
        /// 中心服以 UCER 表示当前游戏能力拒绝。SConnect 会把负协议值归一为
        /// code=0，因此必须读取 datas 中保留的原始协议键；UCNL 仍是离线待生效。
        /// </summary>
        public static bool IsServerCapabilityRejected(Msg message)
        {
            return message != null && message.datas != null
                && string.Equals(message.datas.ToString(), "UCER", System.StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>
        /// 新设置 mode 时需要置为过期的旧模式：吃分/放水互斥（后下的覆盖先下的，两个方向相同）；
        /// 控牌只替换旧控牌，与吃分/放水共存，不得把对方的执行中记录一并过期。
        /// </summary>
        public static int[] ModesReplacedBy(int mode)
        {
            if (mode == (int)EControlMode.TotalKill || mode == (int)EControlMode.TotalRelease)
                return new[] { (int)EControlMode.TotalKill, (int)EControlMode.TotalRelease };
            return new[] { mode };
        }

        /// <summary>
        /// 展示口径：每个玩家只留一条——控牌没完成时只显示控牌（控牌中的吃分/放水仍在后台跑，
        /// 但页面只展示玩家当前最需要关注的那条）；控牌结束后再显示还没完成的吃分/放水。
        /// 没有控牌时留吃分/放水里 ID 最大的那条（历史数据里可能两条同时执行中）。
        /// </summary>
        public static List<M_UserControlStatus_DTO> PickDisplayControls(IEnumerable<M_UserControlStatus_DTO> rows)
        {
            return (rows ?? Enumerable.Empty<M_UserControlStatus_DTO>())
                .Where(r => r != null)
                .GroupBy(r => r.UserID)
                .Select(g => g.OrderByDescending(r => r.ControlMode == (int)EControlMode.TotalCard ? 1 : 0)
                              .ThenByDescending(r => r.ID).First())
                .ToList();
        }
    }
}
