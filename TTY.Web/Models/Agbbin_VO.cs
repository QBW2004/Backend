using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using YYT.Common;

namespace YYT.Web.Models
{
   
    public class Agbbin_VO
    {
     
        /// <summary>
        /// 注册
        /// </summary>
        public class Register
        {
            /// <summary>
            /// 会员名称，不需要前缀 （用户名为5-11的字母加数字）
            /// </summary>
            public string username { get; set; }
            /// <summary>
            /// 加密签名
            /// </summary>
            public string sign_key { get; set; }
            /// <summary>
            /// 平台类型（参见附录平台类型）
            /// </summary>
            public string plat_type { get; set; }
            /// <summary>
            /// md5(sign_key+api_account+plat_type+username)
            /// </summary>
            public string code { get; set; }

        }
        /// <summary>
        /// 登录获取游戏链接地址
        /// </summary>
        public class Logo
        {
            /// <summary>
            /// 会员名称，不需要前缀 （用户名为5-11的字母加数字）
            /// </summary>
            public string username { get; set; }
            /// <summary>
            /// 加密签名
            /// </summary>
            public string sign_key { get; set; }
            /// <summary>
            /// 平台类型（参见附录平台类型）
            /// </summary>
            public string plat_type { get; set; }
            /// <summary>
            /// 是否手机登录 【1是】【0不是】
            /// </summary>
            public string is_mobile_url { get; set; }
            /// <summary>
            /// 游戏代码 
            /// </summary>
            public string game_type { get; set; }
            /// <summary>
            /// 可选 游戏代码 （参见附录游戏代码）
            /// </summary>
            public string gameCode { get; set; }
            /// <summary>
            /// 该参数目前只针对EG彩票生效，其他游戏平台为空即可，为1时进入（EG）官方彩票(传统彩票)，为空时进入（EG）信用彩票
            /// </summary>
            public string lott_type { get; set; }
            /// <summary>
            /// 默认简体中文，
            /// </summary>
            public string lang { get; set; }
            /// <summary>
            /// 查看支持试玩的平台1进入试玩 为空进入真实游戏
            /// </summary>
            public string demo { get; set; }
            /// <summary>
            /// md5(sign_key+api_account+plat_type+username)
            /// </summary>
            public string code { get; set; }
            /// <summary>
            /// 1为转账钱包 2为免转钱包
            /// </summary>
            public string wallet_type { get; set; }

        }
        /// <summary>
        /// 更新免转钱包额度
        /// </summary>
        public class Trans
        {
            /// <summary>
            /// 会员名称，不需要前缀 （用户名为5-11的字母加数字）
            /// </summary>
            public string username { get; set; }
            /// <summary>
            /// 转账金额(负数表示从钱包扣除，正数转入钱包)，不支持小数
            /// </summary>
            public int money { get; set; }
            /// <summary>
            ///转换额度订单号，不能超过64位，商户平台传过来要保证唯一性
            /// </summary>
            public string client_transfer_id { get; set; }
            /// <summary>
            /// 加密签名
            /// </summary>
            public string sign_key { get; set; }
            /// <summary>
            /// md5(sign_key+api_account+username+money+client_transfer_id)
            /// </summary>
            public string code { get; set; }

        }

        public class TransAll
        {
            /// <summary>
            /// 会员名称，不需要前缀 （用户名为5-11的字母加数字）
            /// </summary>
            public string username { get; set; }
            /// <summary>
            /// 加密签名
            /// </summary>
            public string sign_key { get; set; }
            /// <summary>
            /// md5(sign_key+api_account+username+money+client_transfer_id)
            /// </summary>
            public string code { get; set; }
        }



        /// <summary>
        /// 返回参数
        /// </summary>
        public class RetMsg
        {
            /// <summary>
            /// 注册是否成功. 01:成功; 其他失败;
            /// </summary>
            public string statusCode { get; set; }
            /// <summary>
            /// code对应的信息
            /// </summary>
            public string message { get; set; }
            /// <summary>
            /// 注册成功 返回注册成功的用户名
            /// </summary>
            public string data { get; set; }
        }

        /// <summary>
        /// 返回参数
        /// </summary>
        public class ReturnMessage
        {
            /// <summary>
            /// 注册是否成功. 01:成功; 其他失败;
            /// </summary>
            public int code { get; set; }
            /// <summary>
            /// code对应的信息
            /// </summary>
            public string msg { get; set; }
            /// <summary>
            /// 注册成功 返回注册成功的用户名
            /// </summary>
            public string data { get; set; }
        }


        public class Credit
        {
            public string sign_key { get; set; }
            public string code { get; set; }
        }

      

    }
}