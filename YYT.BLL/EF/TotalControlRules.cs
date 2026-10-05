using System.Collections.Generic;
using System.Linq;
using YYT.Entity;

namespace YYT.BLL.EF
{
    /// <summary>
    /// 总控（总点杀4/总放水5/总控牌6）的互斥与展示口径。
    /// 吃分和放水互斥（同一时间只有一个生效）；控牌与吃分/放水共存——
    /// 运营会一边吃分一边控牌，两类控制的进度与冷却互不相干。
    /// </summary>
    public static class TotalControlRules
    {
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
