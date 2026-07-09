using System;
using System.Collections;
using System.Web;

namespace YYT.Common
{
    /// <summary>
    /// 缓存帮助类
    /// </summary>
    public class CacheHelper
    {
        private static System.Web.Caching.Cache cache = HttpRuntime.Cache;
        /// <summary>
        /// 获取缓存
        /// </summary>
        /// <typeparam name="T">值类型</typeparam>
        /// <param name="cacheKey">缓存Key</param>
        /// <returns></returns>
        public static T Get<T>(string cacheKey)
        {
            return Get<T>(cacheKey, default(T));
        }
        public static bool Exists(string cacheKey)
        {
            return !(cache[cacheKey] == null);
        }
        /// <summary>
        /// 获取缓存
        /// </summary>
        /// <typeparam name="T">值类型</typeparam>
        /// <param name="cacheKey">缓存Key</param>
        /// <param name="defaultVal">默认值</param>
        /// <returns></returns>
        public static T Get<T>(string cacheKey, dynamic defaultVal)
        {
            if (cache[cacheKey] != null)
                return (T)cache[cacheKey];

            return defaultVal;
        }
        /// <summary>
        /// 添加缓存
        /// </summary>
        /// <typeparam name="T">值类型</typeparam>
        /// <param name="cacheKey">缓存Key</param>
        /// <param name="value">值</param>
        public static void Add<T>(string cacheKey, T value)
        {
            cache.Insert(cacheKey, value, null, DateTime.Now.AddMinutes(30), System.Web.Caching.Cache.NoSlidingExpiration);
        }
        /// <summary>
        /// 添加缓存
        /// </summary>
        /// <typeparam name="T">值类型</typeparam>
        /// <param name="cacheKey">缓存Key</param>
        /// <param name="value">值</param>
        /// <param name="expireTime">过期时间</param>
        public static void Add<T>(string cacheKey, T value, DateTime expires)
        {
            cache.Insert(cacheKey, value, null, expires, System.Web.Caching.Cache.NoSlidingExpiration);
        }
        /// <summary>
        /// 移除指定缓存
        /// </summary>
        /// <param name="cacheKey">缓存Key</param>
        public static void RemoveCache(string cacheKey)
        {
            cache.Remove(cacheKey);
        }
        /// <summary>
        /// 移除所有缓存
        /// </summary>
        public static void RemoveCache()
        {
            IDictionaryEnumerator CacheEnum = cache.GetEnumerator();
            while (CacheEnum.MoveNext())
            {
                cache.Remove(CacheEnum.Key.ToString());
            }
        }
    }
}
