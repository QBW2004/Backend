using System;
using System.Configuration;

namespace YYT.Common
{
    public class ConfigHelper
    {
        /// <summary>
        /// 获取AppSetting中配置
        /// </summary>
        /// <param name="key">键</param>
        /// <returns></returns>
        public static string Get(string key)
        {
            if (string.IsNullOrWhiteSpace(key))
            {
                return String.Empty;
            }
            return ConfigurationManager.AppSettings[key];
        }
        /// <summary>
        /// 获取AppSetting中配置
        /// </summary>
        /// <param name="key">键</param>
        /// <returns></returns>
        public static int GetInt(string key)
        {
            string val = Get(key);
            int num = 0;
            int.TryParse(val, out num);
            return num;
        }
        /// <summary>
        /// 读取缓存配置
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="key"></param>
        /// <returns></returns>
        public static T GetByCache<T>(string key, dynamic defaultVal)
        {
            dynamic val = CacheHelper.Get<T>(key, defaultVal);

            if (val == defaultVal)
            {
                val = ConvertTo<T>(Get(key));

                if (val == null || string.IsNullOrWhiteSpace(val.ToString()))
                    val = defaultVal;

                CacheHelper.Add(key, val);
            }

            return val;
        }

        static dynamic ConvertTo<T>(dynamic val)
        {
            if (val == null || string.IsNullOrWhiteSpace(val.ToString()))
                return null;
            try
            {
                if (typeof(T) == typeof(string))
                {
                    return (T)Convert.ChangeType(val, typeof(T));
                }
                else if (!string.IsNullOrWhiteSpace(val.ToString()))
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
    }
}
