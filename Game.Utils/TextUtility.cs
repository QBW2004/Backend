using System;
using System.Text;

namespace Game.Utils
{
    /// <summary>
    /// 文本工具类
    /// </summary>
    public static class TextUtility
    {
        private static readonly Random _random = new Random();

        /// <summary>
        /// 获取长时间字符串 (yyyyMMddHHmmssffffff)
        /// </summary>
        public static string GetDateTimeLongString()
        {
            return DateTime.Now.ToString("yyyyMMddHHmmssffffff");
        }

        /// <summary>
        /// 创建随机字符串
        /// </summary>
        /// <param name="length">长度</param>
        /// <param name="useDigits">是否包含数字</param>
        /// <param name="useUpper">是否包含大写字母</param>
        /// <param name="useLower">是否包含小写字母</param>
        /// <param name="useSpecial">是否包含特殊字符</param>
        /// <param name="specialChars">自定义特殊字符</param>
        public static string CreateRandom(int length, int useDigits, int useUpper, int useLower, int useSpecial, string specialChars)
        {
            const string digits = "0123456789";
            const string upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
            const string lower = "abcdefghijklmnopqrstuvwxyz";

            StringBuilder pool = new StringBuilder();
            if (useDigits != 0) pool.Append(digits);
            if (useUpper != 0) pool.Append(upper);
            if (useLower != 0) pool.Append(lower);
            if (useSpecial != 0 && !string.IsNullOrEmpty(specialChars)) pool.Append(specialChars);

            // 默认至少包含数字
            if (pool.Length == 0) pool.Append(digits);

            StringBuilder result = new StringBuilder(length);
            for (int i = 0; i < length; i++)
            {
                result.Append(pool[_random.Next(pool.Length)]);
            }
            return result.ToString();
        }
    }
}
