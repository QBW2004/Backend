using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace YYT.Remote
{
    public enum EScMsgType
    {
        /// <summary>
        /// 锁定玩家金币充值、兑换
        /// </summary>
        LK,
        /// <summary>
        /// 解锁玩家金币充值、兑换
        /// </summary>
        UL,
        /// <summary>
        /// 设定机台参数
        /// </summary>
        PA,
        /// <summary>
        /// 重启服务器
        /// </summary>
        RB,
        /// <summary>
        /// 关闭服务器
        /// </summary>
        SD,
        /// <summary>
        /// 游戏库存
        /// </summary>
        GA,
        /// <summary>
        /// 用户控制
        /// </summary>
        UC,
        /// <summary>
        /// 公告
        /// </summary>
        RN,
        /// <summary>
        /// 鱼机房间参数刷新
        /// </summary>
        PR,
        /// <summary>
        /// 查询用户信息
        /// </summary>
        QU,
        /// <summary>
        /// 查询所有在线用户
        /// </summary>
        QA,
        /// <summary>
        /// 踢除用户
        /// </summary>
        KU,
        /// <summary>
        /// 清空桌子库存
        /// </summary>
        CA,
        /// <summary>
        /// 房间设定
        /// </summary>
        RP,
        /// <summary>
        /// 切换模式
        /// </summary>
        GM,
        /// 回退积分
        /// </summary>
        RC,
        /// <summary>
        /// 刷新分数ALL
        /// </summary>
        RL,
        /// <summary>
        /// 桌台配置(桌名)热更新：后台→center 写 roomtableconfig 表并全量重推给子游戏服。
        /// 二进制报文(非文本模板)，由 SConnect.SendTcCommand 直接组包发送。
        /// </summary>
        TC

    }
}
