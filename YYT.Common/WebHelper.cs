using System;
using System.Collections.Specialized;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Mvc;

namespace YYT.Common
{
    /// <summary>
    /// Web 扩展帮助类
    /// </summary>
    public static class WebHelper
    {
        #region Session 缓存

        #region 保存Session缓存
        /// <summary>
        /// 保存Session缓存
        /// </summary>
        /// <param name="key">缓存Key</param>
        /// <param name="obj">缓存值</param>
        /// <param name="ts">超时时间</param>
        public static void SaveSsionCache(string key, object obj, TimeSpan ts)
        {
            //WHCache.Default.Save<SessionCache>(key, obj, ts.Minutes);
        }
        #endregion

        #region 获取验证码
        /// <summary>
        /// 获取验证码
        /// </summary>
        /// <returns></returns>
        public static string GetValideCode()
        {
            string vcode = String.Empty;
            vcode = GetSession(ConfigHelper.Get("ValideCodeKey"));
            vcode = DESEncrypt.Decrypt(vcode);

            return vcode;
        }
        /// <summary>
        /// 移除验证码
        /// </summary>
        public static void RemoveValideCode()
        {
            RemoveSession(ConfigHelper.Get("ValideCodeKey"));
        }
        #endregion

        #region 登录Session信息
        /// <summary>
        /// 获取登录信息
        /// </summary>
        /// <returns></returns>
        public static YYT.Entity.M_LoginUser GetLoginInfo()
        {
            string userStr = GetSession("LoginInfo");
            if (!String.IsNullOrWhiteSpace(userStr))
            {
                userStr = DESEncrypt.Decrypt(userStr);//解密
                return YYT.Entity.M_LoginUser.GetLoginModel(userStr);
            }

            return null;
        }
        /// <summary>
        /// 设置登录信息
        /// </summary>
        /// <param name="loginData">登录数据,(超时时间默认30分钟)</param>
        /// <param name="loginData">登录数据,(超时时间默认30分钟)</param>
        public static void SetLoginInfo(object loginData, int num = 30)
        {
            SaveSsionCache("LoginInfo", loginData, TimeSpan.FromMinutes(num));
        }

        /// <summary>
        /// 移除登录信息
        /// </summary>
        public static void RemoveLogin()
        {
            RemoveSession("LoginInfo");
        }
        #endregion

        #endregion

        #region Session操作
        /// <summary>
        /// 写Session
        /// </summary>
        /// <typeparam name="T">Session键值的类型</typeparam>
        /// <param name="key">Session的键名</param>
        /// <param name="value">Session的键值</param>
        public static void WriteSession<T>(string key, T value)
        {
            if (string.IsNullOrWhiteSpace(key))
                return;
            HttpContext.Current.Session.Timeout = 30;//30分钟
            HttpContext.Current.Session[key] = value;
        }

        /// <summary>
        /// 写Session
        /// </summary>
        /// <param name="key">Session的键名</param>
        /// <param name="value">Session的键值</param>
        public static void WriteSession(string key, string value)
        {
            WriteSession<string>(key, value);
        }

        /// <summary>
        /// 读取Session的值
        /// </summary>
        /// <param name="key">Session的键名</param>        
        public static string GetSession(string key)
        {
            if (string.IsNullOrWhiteSpace(key))
                return string.Empty;
            return HttpContext.Current.Session[key] != null ? HttpContext.Current.Session[key] as string : "";
        }
        /// <summary>
        /// 读取Session的值
        /// </summary>
        /// <typeparam name="T">输出类型</typeparam>
        /// <param name="key">Session的键名</param>
        /// <returns></returns>
        public static T GetSession<T>(string key)
        {
            object val = HttpContext.Current.Session[key];
            if (val != null)
                return val.ToType<T>();
            return default(T);
        }
        /// <summary>
        /// 删除指定Session
        /// </summary>
        /// <param name="key">Session的键名</param>
        public static void RemoveSession(string key)
        {
            if (string.IsNullOrWhiteSpace(key))
                return;
            HttpContext.Current.Session.Contents.Remove(key);
        }

        #endregion

        #region Cookie操作
        /// <summary>
        /// 写cookie值
        /// </summary>
        /// <param name="strName">名称</param>
        /// <param name="strValue">值</param>
        public static void WriteCookie(string strName, string strValue)
        {
            HttpCookie cookie = HttpContext.Current.Request.Cookies[strName];
            if (cookie == null)
            {
                cookie = new HttpCookie(strName);
            }
            cookie.Value = strValue;
            HttpContext.Current.Response.AppendCookie(cookie);
        }
        /// <summary>
        /// 写cookie值
        /// </summary>
        /// <param name="strName">名称</param>
        /// <param name="strValue">值</param>
        /// <param name="strValue">过期时间(分钟)</param>
        public static void WriteCookie(string strName, string strValue, int expires)
        {
            HttpCookie cookie = HttpContext.Current.Request.Cookies[strName];
            if (cookie == null)
            {
                cookie = new HttpCookie(strName);
            }
            cookie.Value = strValue;
            cookie.Expires = DateTime.Now.AddMinutes(expires);
            HttpContext.Current.Response.AppendCookie(cookie);
        }
        /// <summary>
        /// 读cookie值
        /// </summary>
        /// <param name="strName">名称</param>
        /// <returns>cookie值</returns>
        public static string GetCookie(string strName)
        {
            if (HttpContext.Current.Request.Cookies != null && HttpContext.Current.Request.Cookies[strName] != null)
            {
                return HttpContext.Current.Request.Cookies[strName].Value.ToString();
            }
            return "";
        }
        /// <summary>
        /// 删除Cookie对象
        /// </summary>
        /// <param name="CookiesName">Cookie对象名称</param>
        public static void RemoveCookie(string CookiesName)
        {
            HttpCookie objCookie = new HttpCookie(CookiesName.Trim());
            objCookie.Expires = DateTime.Now.AddYears(-5);
            HttpContext.Current.Response.Cookies.Add(objCookie);
        }
        #endregion

        #region Request.Params Get 扩展
        /// <summary>
        /// 转换Form中Param为XML数据
        /// </summary>
        /// <param name="form">form表单</param>
        /// <returns> XML 数据</returns>
        public static string GetXmlData(this NameValueCollection form)
        {
            if (form == null || form.AllKeys.Length == 0)
            {
                return String.Empty;
            }

            StringBuilder xml = new StringBuilder("<?xml version=\"1.0\" encoding=\"utf-8\"?>");
            xml.AppendLine("<Root>");
            xml.AppendLine("<Row ");
            foreach (string key in form.AllKeys)
            {
                xml.AppendFormat(" {0}=\"{1}\" ", key, form[key]);
            }
            xml.AppendLine(" />");
            xml.AppendLine("</Root>");

            return xml.ToString();
        }

        /// <summary>
        /// 转换Form中Param为XML数据
        /// </summary>
        /// <param name="form">form表单</param>
        /// <returns> XML 数据</returns>
        public static string GetJsonString(this NameValueCollection form)
        {
            if (form == null || form.AllKeys.Length == 0)
            {
                return String.Empty;
            }

            string val = String.Empty;
            string _char = String.Empty;
            StringBuilder xml = new StringBuilder();
            xml.AppendLine("{");
            for (int i = 0; i < form.AllKeys.Length; i++)
            {
                val = form[form.AllKeys[i]];
                _char = (i < form.AllKeys.Length - 1 ? "," : "");
                if (val.IsNumber())
                    xml.AppendLine(String.Format(" {0}:{1}{2} ", form.AllKeys[i], form[form.AllKeys[i]], _char));
                else
                    xml.AppendLine(String.Format(" {0}:\"{1}\"{2} ", form.AllKeys[i], form[form.AllKeys[i]], _char));
            }
            xml.AppendLine("}");

            return xml.ToString();
        }
        /// <summary>
        /// 获取客户端请求参数值【直接从Request.Params中取出参数值】
        /// </summary>
        /// <typeparam name="T">获取的类型</typeparam>
        /// <param name="form">客户端请求表单</param>
        /// <param name="key">Paras中的Key</param>
        /// <returns></returns>
        public static T Q<T>(this NameValueCollection form, string key)
        {
            return Q<T>(form, key, "");
        }
        /// <summary>
        /// 获取客户端请求参数值【直接从Request.Params中取出参数值】
        /// </summary>
        /// <typeparam name="T">获取的类型</typeparam>
        /// <param name="form">客户端请求表单</param>
        /// <param name="key">Paras中的Key</param>
        /// <param name="defauleVal">默认值</param>
        /// <returns></returns>
        public static T Q<T>(this NameValueCollection form, string key, object defauleVal)
        {
            object val = string.IsNullOrEmpty(form[key]) ? defauleVal : form[key];
            return val.ToType<T>();
        }
        private static T ToType<T>(this object val)
        {
            try
            {
                if (typeof(T) == typeof(string))
                {
                    return (T)Convert.ChangeType(val, typeof(T));
                }
                else if (!string.IsNullOrEmpty(val.ToString()))
                {
                    return (T)Convert.ChangeType(val, typeof(T));
                }
                return typeof(T) == typeof(string) ? (T)Convert.ChangeType("", typeof(T)) : default(T);
            }
            catch
            {
                return typeof(T) == typeof(string) ? (T)Convert.ChangeType("", typeof(T)) : default(T);
            }
        }
        #endregion

        #region 正则判断
        /// <summary>
        /// 判断是否是数字
        /// </summary>
        /// <param name="val"></param>
        /// <returns></returns>
        public static bool IsNumber(this object val)
        {
            if (val == null)
                return false;

            if (String.IsNullOrEmpty(val.ToString()))
                return false;

            Regex reg = new Regex(@"(^0$)|(^\d+$)|(^-?\d*\.?\d*[0-9]+\d*$)|(^-?[0-9]+\d*\.\d*$)");

            if (reg.IsMatch(val.ToString()))
                return true;
            else
                return false;
        }
        /// <summary>
        /// 判断是否是整数类型
        /// </summary>
        /// <param name="val"></param>
        /// <returns></returns>
        public static bool IsInteger(this object val)
        {
            if (val == null)
                return false;

            if (String.IsNullOrEmpty(val.ToString()))
                return false;

            Regex reg = new Regex(@"^\d+$");

            if (reg.IsMatch(val.ToString()))
                return true;
            else
                return false;
        }
        #endregion

        #region ULR参数取值
        /// <summary>
        /// 获取Url中参数值
        /// <para>
        /// <![CDATA[
        /// 字符串：?key=123&code=456
        /// 获取该字符串中key的值123 或是 code的值 456
        /// ]]>
        /// </para>
        /// </summary>
        /// <param name="inputStr">待查询的字符串</param>
        /// <param name="paraName">参数名称</param>
        /// <returns></returns>
        public static string GetPara(string inputStr, string paraName)
        {
            if (!String.IsNullOrEmpty(inputStr))
                inputStr = "?" + inputStr;
            else
                return "";

            Regex reg = new Regex("[&|?]" + paraName + "=([^&$]*)", RegexOptions.Compiled | RegexOptions.IgnoreCase);
            Match m = reg.Match(inputStr);
            return m.Success && m.Groups.Count > 0 ? m.Groups[1].Value : "";

        }

        /// <summary>
        /// 获取字符串某个参数值 
        /// <para>
        /// <![CDATA[
        /// 字符串：callback ({"client_id":"123"})
        /// 获取该字符串中client_id的值 123
        /// ]]>
        /// </para>
        /// </summary>
        /// <param name="inputStr">待查询的字符串</param>
        /// <param name="paraName">参数名称</param>
        /// <param name="isNumber">是否是数值</param>
        /// <returns></returns>
        public static string GetPara2(string inputStr, string paraName, bool isNumber)
        {
            //("client_id"\:")([^"]*)(")
            if (isNumber)
            {
                Regex reg = new Regex("(\"" + paraName + "\"\\:)(\\d+)");
                Match m = reg.Match(inputStr);
                return m.Success && m.Groups.Count > 0 ? m.Groups[2].Value : "";
            }
            else
            {
                Regex reg = new Regex("(\"" + paraName + "\"\\:\")([^\"',]*)(\")");
                Match m = reg.Match(inputStr);
                return m.Success && m.Groups.Count > 1 ? m.Groups[2].Value : "";
            }
        }
        #endregion

        #region 获取客户端IP地址
        /// <summary>
        /// 获取客户端IP地址
        /// </summary>
        /// <returns></returns>
        public static string GetClientIP()
        {
            string result = String.Empty;

            result = HttpContext.Current.Request.ServerVariables["HTTP_X_FORWARDED_FOR"];
            if (String.IsNullOrEmpty(result))
            {
                result = HttpContext.Current.Request.ServerVariables["REMOTE_ADDR"];
            }
            if (String.IsNullOrEmpty(result))
            {
                result = HttpContext.Current.Request.UserHostAddress;
            }
            if (String.IsNullOrEmpty(result))
            {
                return "127.0.0.1";
            }
            return result;
        }
        #endregion

        #region 随机字符
        /// <summary>
        /// 生成自定义长度随机字符
        /// </summary>
        /// <param name="len">长度</param>
        /// <returns></returns>
        public static string RandomStr(int len, bool onlyNum = false)
        {
            string randomChars = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIKJLMNOPQRSTUVWXYZ";
            if (onlyNum == true)
            {
                randomChars = "0123456789";
            }
            string str = string.Empty;
            int randomNum;

            for (int i = 0; i < len; i++)
            {
                Random random = new Random(GetRandomSeed());
                randomNum = random.Next(randomChars.Length);
                str += randomChars[randomNum];
            }
            return str;
        }
        /// <summary>
        /// 随机种子随机
        /// </summary>
        /// <returns></returns>
        static int GetRandomSeed()
        {
            byte[] bytes = new byte[4];
            System.Security.Cryptography.RNGCryptoServiceProvider rng = new System.Security.Cryptography.RNGCryptoServiceProvider();
            //使用加密服务提供程序 (CSP) 提供的实现来实现加密随机数生成器 (RNG)。无法继承此类。 
            rng.GetBytes(bytes); //用经过加密的强随机值序列填充字节数组。 
            return BitConverter.ToInt32(bytes, 0);
        }
        #endregion

        #region 分隔字符串
        /// <summary>
        /// 分隔字符串
        /// </summary>
        /// <param name="str"></param>
        /// <param name="splitChar"></param>
        /// <returns></returns>
        public static string[] SplitStr(this string str, char splitChar)
        {
            if (str == null || str.Trim().Equals(string.Empty))
                return null;
            return str.Split(new char[] { splitChar }, StringSplitOptions.RemoveEmptyEntries);
        }
        #endregion

        #region string array to Xml
        /// <summary>
        /// string array to Xml
        /// </summary>
        /// <param name="sb"></param>
        /// <returns></returns>
        public static string ToXml(this string[] items, params string[] fieldMapping)
        {
            if (items.Length < 1)
                return string.Empty;

            StringBuilder xml = new StringBuilder();
            xml.AppendLine("<root>");
            xml.Append(items.ToXmlRows(fieldMapping));
            xml.AppendLine("</root>");

            return xml.ToString();
        }

        public static string ToXmlRows(this string[] items, params string[] fieldMapping)
        {
            if (items.Length < 1)
                return string.Empty;

            StringBuilder xml = new StringBuilder();
            foreach (var item in items)
            {
                string[] datas = item.SplitStr('_');
                xml.Append("<row");
                for (int i = 0; i < fieldMapping.Length; i++)
                {
                    xml.AppendFormat(" {0}=\"{1}\"", fieldMapping[i], datas[i]);
                }
                xml.AppendFormat(" />{0}", Environment.NewLine);
            }

            return xml.ToString();
        }
        #endregion

        #region 从Modelstate中获取错误消息
        /// <summary>
        /// 从Modelstate中获取错误消息
        /// </summary>
        /// <param name="modelState"></param>
        /// <returns></returns>
        public static string GetErrMsg(this System.Collections.Generic.ICollection<ModelState> modelState)
        {
            return string.Join(";", modelState.SelectMany(x => x.Errors).Select(x => x.ErrorMessage));
        }
        #endregion

    }

    public static class HtmlExExtensions
    {
        public static MvcHtmlString ToRoutMap(this HtmlHelper htmlHelper, params string[] arr)
        {
            StringBuilder html = new StringBuilder();
            for (int i = 0; i < arr.Length; i++)
            {
                if (i == arr.Length - 1)
                    html.Append(arr[i]);
                else
                    html.AppendFormat("{0} {1} ", arr[i], ConstStr.FONT_SIGN_GT);
            }

            return new MvcHtmlString(html.ToString());
        }
    }
}
