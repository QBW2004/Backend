using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace YYT.BLL.EF
{
    /// <summary>
    /// 游戏参数类型
    /// </summary>
    public enum EGameParaType
    {
        /// <summary>
        /// 下注押分类型
        /// </summary>
        Bet = 0,
        /// <summary>
        /// 牌机类型
        /// </summary>
        Card,
        /// <summary>
        /// 鱼机类型
        /// </summary>
        Fish,
        /// <summary>
        /// 拉霸类型
        /// </summary>
        Laba
    }
}
