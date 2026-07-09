namespace YYT.Entity
{
    /// <summary>
    /// 数据库类型枚举
    /// </summary>
    public enum EDbProviderType : byte
    {
        SqlServer = 0,
        MySql,
        SQLite,
        Oracle,
        ODBC,
        OleDb,
        Firebird,
        PostgreSql,
        DB2,
        Informix,
        SqlServerCe
    }
}
