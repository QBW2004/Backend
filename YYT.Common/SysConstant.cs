namespace YYT.Common
{
    public sealed class SysConstant
    {

        #region Redis Constant
        /// <summary>
        /// redis key 前缀
        /// </summary>
        public const string REDIS_PREFIX_KEY = "ppt_";
        /// <summary>
        /// redis 广告商用户缓存KEY
        /// </summary>
        public const string REDIS_ADVERT_USR_RELATION_KEY = "advert_user_relation";
        /// <summary>
        /// redis 广告商广告类型KEY
        /// </summary>
        public const string REDIS_ADVERT_AD_TYPE_KEY = "advert_ad_type";
        /// <summary>
        /// redis 广告商缓存KEY
        /// </summary>
        public const string REDIS_ADVERT_KEY = "adverts";
        /// <summary>
        /// redis 广告图
        /// </summary>
        public const string REDIS_ADVERT_PIC_0_KEY = "advert_pic_0";
        /// <summary>
        /// redis 分享图
        /// </summary>
        public const string REDIS_ADVERT_PIC_1_KEY = "advert_pic_1";
        #endregion

    }
}
