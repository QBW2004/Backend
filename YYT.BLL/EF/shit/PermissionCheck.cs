namespace YYT.BLL.EF
{
    public class PermissionCheck
    {
        /// <summary>
        /// 检查登录人员是否具有某一类代理的查询权限
        /// </summary>
        /// <param name="loginPriv"></param>
        /// <param name="targetPriv"></param>
        /// <returns></returns>
        public static bool GetAgencyByType(int loginPriv, int targetPriv)
        {
            if (loginPriv == 0)
                return true;

            else if (loginPriv == 1)
                if (targetPriv > 1 && targetPriv < 9)
                    return true;
                else
                    return false;

            else if (loginPriv >= 2 && loginPriv < 9)
                if (targetPriv > 2 && targetPriv < 9)
                    return true;
                else
                    return false;

            else if (loginPriv == 9)
                if (targetPriv > 0 && targetPriv < 9)
                    return true;
                else
                    return false;

            else
                return false;
        }
    }
}
