using Game.Utils;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Security.Policy;
using System.Text;
using System.Threading.Tasks;
using System.Web.Services.Description;
using YYT.Common;

namespace YYT.Web.Models
{
  
    /// <summary>
    /// 发送接口类
    /// </summary>
    public class RestClientUtil
    {

        //sign_key
        public string secretKey = ConfigHelper.Get("secretKey");
        //SN
        public string SN = ConfigHelper.Get("SN");
        //walletType
        public string walletType = ConfigHelper.Get("walletType");

        public string api_token = ConfigHelper.Get("api_token");
        #region Get请求
        public string Get(string uri)
        {
            //先根据用户请求的uri构造请求地址
            string serviceUrl = string.Format("{0}", uri);
            //创建Web访问对  象
            HttpWebRequest myRequest = (HttpWebRequest)WebRequest.Create(serviceUrl);
            //通过Web访问对象获取响应内容
            HttpWebResponse myResponse = (HttpWebResponse)myRequest.GetResponse();
            //通过响应内容流创建StreamReader对象，因为StreamReader更高级更快
            StreamReader reader = new StreamReader(myResponse.GetResponseStream(), Encoding.UTF8);
            //string returnXml = HttpUtility.UrlDecode(reader.ReadToEnd());//如果有编码问题就用这个方法
            string returnXml = reader.ReadToEnd();//利用StreamReader就可以从响应内容从头读到尾
            reader.Close();
            myResponse.Close();
            return returnXml;
        }
        #endregion


        #region Post请求
        /// <summary>
        /// Post Api请求
        /// </summary>
        /// <param name="data"></param>
        /// <param name="uri"></param>
        /// <returns></returns>
        public string Post(string data, string uri)
        {
            string retString = "";
            try
            {
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(uri);
                request.Method = "POST";
                request.Accept = "application/json";
                request.ContentType = "application/json";
                request.Headers.Add("Authorization", "Bearer " + api_token);
                string strContent = data; //参数data的格式
                using (StreamWriter dataStream = new StreamWriter(request.GetRequestStream()))
                {
                    dataStream.Write(strContent);
                    dataStream.Close();
                }
                HttpWebResponse response = (HttpWebResponse)request.GetResponse();
                string encoding = response.ContentEncoding;
                if (encoding == null || encoding.Length < 1)
                {
                    encoding = "UTF-8"; //默认编码  
                }
                StreamReader reader = new StreamReader(response.GetResponseStream(), Encoding.GetEncoding(encoding));
                retString = reader.ReadToEnd();
            }
            catch (Exception ex)
            {
                retString = ex.Message;
            }
            return retString;

        }
        #endregion

        public string HttpPost(string data, string uri)
        {
            try
            {
                //获取提交的字节
                byte[] bs = Encoding.UTF8.GetBytes(data);
                //设置提交的相关参数
                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(uri);
                req.Method = "POST";
                req.ContentType = "application/x-www-form-urlencoded";
                req.ContentLength = bs.Length;
                //提交请求数据
                Stream reqStream = req.GetRequestStream();
                reqStream.Write(bs, 0, bs.Length);
                reqStream.Close();
                //接收返回的页面，必须的，不能省略
                WebResponse wr = req.GetResponse();
                System.IO.Stream respStream = wr.GetResponseStream();
                System.IO.StreamReader reader = new System.IO.StreamReader(respStream, System.Text.Encoding.GetEncoding("utf-8"));
                string t = reader.ReadToEnd();
                System.Web.HttpContext.Current.Response.Write(t);
                wr.Close();
                return t;
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }


        #region PostJson请求
        /// <summary>
        /// http PostJson请求
        /// </summary>
        /// <param name="parameterData">参数</param>
        /// <param name="serviceUrl">访问地址</param>
        /// <param name="ContentType">默认 application/json , application/x-www-form-urlencoded,multipart/form-data,raw,binary </param>
        /// <param name="Accept">默认application/json</param>
        /// <returns></returns>
        public string PostJson(string data,string url)
        {
            string retString = "";
            try
            {
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);

                request.Method = "POST";
                request.ContentType = "application/json";

                //随机字符串 16-32 位小写字母 + 数字
                string random = GetChar(32);
                //加密后字符串  32 位小写 md5(random+sn+secretKey)
                string sign = Utility.MD5(random + SN + secretKey).ToLower();
                request.Headers.Add("random", random);
                request.Headers.Add("sign", sign);
                request.Headers.Add("sn", SN);
                string strContent = data; //参数data的格式就是上一句被注释的语句
                using (StreamWriter dataStream = new StreamWriter(request.GetRequestStream()))
                {
                    dataStream.Write(strContent);
                    dataStream.Close();
                }
                HttpWebResponse response = (HttpWebResponse)request.GetResponse();
                string encoding = response.ContentEncoding;
                if (encoding == null || encoding.Length < 1)
                {
                    encoding = "UTF-8"; //默认编码  
                }
                StreamReader reader = new StreamReader(response.GetResponseStream(), Encoding.GetEncoding(encoding));
                retString = reader.ReadToEnd();
            }catch(Exception ex)
            {
                retString = ex.Message;
            }
           
            //解析josn
            
            //sessionId = jo["sessionId"].ToString();
            //return sessionid;
            return retString;
        }
        #endregion



    
        /// <summary>
        /// 生成随机字符串
        /// </summary>
        /// <param name="length">字符串长度</param>
        /// <returns></returns>
        public string GetChar(int length)
        {
            char[] chars = {
                                '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
                                'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j',
                                'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
                                'u', 'v', 'w', 'x', 'y', 'z'
                               };
            string result = "";
            Random rnd = new Random(Guid.NewGuid().GetHashCode());
            for (int i = 0; i < length; i++)
            {
                result += chars[rnd.Next(chars.Length)];
            }
            return result;
        }

      

        public String getParamSrc(Dictionary<string, string> paramsMap)
        {
            var vDic = (from objDic in paramsMap orderby objDic.Key ascending select objDic);
            StringBuilder str = new StringBuilder();
            foreach (KeyValuePair<string, string> kv in vDic)
            {
                string pkey = kv.Key;
                string pvalue = kv.Value;
                str.Append(pkey + "=" + pvalue + "&");
            }
            String result = str.ToString().Substring(0, str.ToString().Length - 1);
            return result;
        }
    }
}
