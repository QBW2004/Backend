using System.Collections.Generic;
using System.Data.Common;
using YYT.Entity;

namespace YYT.BLL
{
    /// <summary>
    /// DbProviderFactory工厂类
    /// </summary>
    public class ProviderFactory
    {
        private static Dictionary<EDbProviderType, string> providerInvariantNames = new Dictionary<EDbProviderType, string>();
        private static Dictionary<EDbProviderType, DbProviderFactory> providerFactoies = new Dictionary<EDbProviderType, DbProviderFactory>(20);
        static ProviderFactory()
        {
            //加载已知的数据库访问类的程序集
            providerInvariantNames.Add(EDbProviderType.SqlServer, "System.Data.SqlClient");
            providerInvariantNames.Add(EDbProviderType.OleDb, "System.Data.OleDb");
            providerInvariantNames.Add(EDbProviderType.ODBC, "System.Data.ODBC");
            providerInvariantNames.Add(EDbProviderType.Oracle, "Oracle.DataAccess.Client");
            providerInvariantNames.Add(EDbProviderType.MySql, "MySql.Data.MySqlClient");
            providerInvariantNames.Add(EDbProviderType.SQLite, "System.Data.SQLite");
            providerInvariantNames.Add(EDbProviderType.Firebird, "FirebirdSql.Data.Firebird");
            providerInvariantNames.Add(EDbProviderType.PostgreSql, "Npgsql");
            providerInvariantNames.Add(EDbProviderType.DB2, "IBM.Data.DB2.iSeries");
            providerInvariantNames.Add(EDbProviderType.Informix, "IBM.Data.Informix");
            providerInvariantNames.Add(EDbProviderType.SqlServerCe, "System.Data.SqlServerCe");
        }
        /// <summary>
        /// 获取指定数据库类型对应的程序集名称
        /// </summary>
        /// <param name="providerType">数据库类型枚举</param>
        /// <returns></returns>
        public static string GetProviderInvariantName(EDbProviderType providerType)
        {
            return providerInvariantNames[providerType];
        }
        /// <summary>
        /// 获取指定类型的数据库对应的DbProviderFactory
        /// </summary>
        /// <param name="providerType">数据库类型枚举</param>
        /// <returns></returns>
        public static DbProviderFactory GetDbProviderFactory(EDbProviderType providerType)
        {
            //如果还没有加载，则加载该DbProviderFactory
            if (!providerFactoies.ContainsKey(providerType) || providerFactoies[providerType] != null)
            {
                providerFactoies.Add(providerType, ImportDbProviderFactory(providerType));
            }
            return providerFactoies[providerType];
        }
        /// <summary>
        /// 加载指定数据库类型的DbProviderFactory
        /// </summary>
        /// <param name="providerType">数据库类型枚举</param>
        /// <returns></returns>
        private static DbProviderFactory ImportDbProviderFactory(EDbProviderType providerType)
        {
            string providerName = providerInvariantNames[providerType];
            DbProviderFactory factory = null;
            try
            {
                //从全局程序集中查找
                factory = DbProviderFactories.GetFactory(providerName);
            }
            catch //(System.Exception e)
            {
                factory = null;
                //throw e;
            }
            return factory;
        }
    }
}
