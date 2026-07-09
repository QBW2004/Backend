using System;

namespace YYT.Entity
{
    public class TipMsg
    {
        /// <summary>
        /// 登录超时，请重新登录
        /// </summary>
        public static readonly string MSG_LOGIN_TIMEOUT = String.Format("{0}{1}{2}", "{\"code\":", (int)EServerData.Login_Time_Out, ",\"msg\":\"登录超时，请重新登录！\",\"total\":0,\"rows\":[]}");

        /// <summary>
        /// 未获取到任何数据
        /// </summary>
        public static readonly string MSG_NO_DATA = "未获取到任何数据！";
        /// <summary>
        /// 未获取到任何数据
        /// </summary>
        public static readonly string MSG_GRID_NO_DATA = String.Format("{0}{1}{2}{3}{4}", "{\"code\":", (int)EServerData.General_Error, ",\"msg\":\"", MSG_NO_DATA, "\",\"total\":0,\"rows\":[]}");

        /// <summary>
        /// 未经授权访问
        /// <![CDATA[{"code":-3,"msg":"未经授权访问。"}]]>
        /// </summary>
        public static readonly string MSG_INVALID_AUTHORIZE = String.Format("{0}{1}{2}", "{\"code\":", (int)EServerData.Authorize_Invalid, ",\"msg\":\"未经授权访问！\"}");
        /// <summary>
        /// 授权失败
        /// <![CDATA[{"code":0,"msg":"授权失败。"}]]>
        /// </summary>
        public static readonly string MSG_ERR_AUTHORIZE = String.Format("{0}{1}{2}", "{\"code\":", (int)EServerData.General_Error, "\"msg\":\"授权失败！\"}");

        /// <summary>
        /// 空表格数据
        /// </summary>
        public static readonly string EMPTY_GRID_DATA = "{\"total\":0,\"rows\":[]}";

        /// <summary>
        /// 登录失败
        /// </summary>
        public static readonly string MSG_NOT_LOGINPASS = "登录失败！";
        /// <summary>
        /// 登录成功
        /// </summary>
        public static readonly string MSG_OK_LOGINPASS = "登录成功！";
        /// <summary>
        /// 登录错误
        /// </summary>
        public static readonly string MSG_ERR_LOGINPASS = "登录错误！";

        /// <summary>
        /// 操作失败
        /// </summary>
        public static readonly string MSG_ERR_OPERATE = "操作失败！";
        /// <summary>
        /// 操作成功
        /// </summary>
        public static readonly string MSG_OK_OPERATE = "操作成功！";

        /// <summary>
        /// 参数错误
        /// </summary>
        public static readonly string MSG_ERR_PARAMETER = "参数错误！";
        /// <summary>
        /// 参数不规范
        /// </summary>
        public static readonly string MSG_INVALID_PARAMETER = "参数不规范！";

    }
}
