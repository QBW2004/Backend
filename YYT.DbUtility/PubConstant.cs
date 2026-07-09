using YYT.Common;

namespace YYT.BLL
{
    public class PubConstant
    {
        public static string DbConnString
        {
            get
            {
                return "Server=localhost;Port=3306;Database=winner;Uid=root;Pwd=123456;character set=utf8;SslMode=None";
            }
        }
        
        private static string GetConnectionString(string AppKey)
        {
            return ConfigHelper.Get(AppKey);
        }
    }
}
