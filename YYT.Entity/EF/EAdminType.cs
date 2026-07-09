namespace YYT.Entity
{
    /// <summary>
    /// 用户类型
    /// </summary>
    public enum EAdminType
    {
        /// <summary>
        /// 用户
        /// </summary>
        None = -2,
        /// <summary>
        /// 超级管理
        /// </summary>
        Zero = 0,
        /// <summary>
        /// 总代理
        /// </summary>
        One = 1,
        /// <summary>
        /// 副管理
        /// </summary>
        Nine = 9,
        /// <summary>
        /// 开发、运维
        /// </summary>
        Ten = 10,
        /// <summary>
        /// 一般代理
        /// </summary>
        General = -1
    }

    public class AdminTypeTranslater
    {
        public static string TitleTranlate(EAdminType eAdminType)
        {
            switch (eAdminType)
            {
                case EAdminType.None:
                    return "用户";
                case EAdminType.Zero:
                    return "超级管理";
                case EAdminType.One:
                    return "总代理";
                case EAdminType.Nine:
                    return "副管";
                case EAdminType.Ten:
                    return "开发、运维";
                case EAdminType.General:
                default:
                    return "代理";
            }
        }
    }
}
