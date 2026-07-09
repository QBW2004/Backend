using System;

namespace YYT.Entity
{
    [Flags]
    public enum EServerData
    {
        /// <summary>
        /// 服务器错误
        /// </summary>
        Server_Error = -3,
        /// <summary>
        /// 未授权
        /// </summary>
        Authorize_Invalid = -2,
        /// <summary>
        /// 登录超时
        /// </summary>
        Login_Time_Out = -1,
        /// <summary>
        /// 一般性错误
        /// </summary>
        General_Error = 0,
        /// <summary>
        /// 操作成功
        /// </summary>
        Success = 1,
        /// <summary>
        /// 重复
        /// </summary>
        Repeat = 2,
    }
}
