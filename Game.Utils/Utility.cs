using System;
using System.Security.Cryptography;
using System.Text;

namespace Game.Utils
{
    /// <summary>
    /// 通用工具类
    /// </summary>
    public static class Utility
    {
        /// <summary>
        /// 计算字符串的 MD5 哈希值
        /// </summary>
        public static string MD5(string input)
        {
            if (input == null) input = "";
            using (var md5 = System.Security.Cryptography.MD5.Create())
            {
                byte[] bytes = md5.ComputeHash(Encoding.UTF8.GetBytes(input));
                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < bytes.Length; i++)
                {
                    sb.Append(bytes[i].ToString("x2"));
                }
                return sb.ToString();
            }
        }
    }
}
