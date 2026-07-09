//============================================【示例】=================================================
//     //使用示例 SQLite
//     string connectionString = @"Data Source=D:\VS2008\NetworkTime\CrawlApplication\CrawlApplication.db3";
//     string sql = "SELECT * FROM Weibo_Media order by Id desc limit 0,20000";
//     DbUtility db = new DbUtility(connectionString, DbProviderType.SQLite);
//     DataTable data = db.ExecuteDataTable(sql, null);
//     DbDataReader reader = db.ExecuteReader(sql, null);
//     reader.Close(); 

//     //使用示例 MySql
//     string connectionString = @"Server=localhost;Database=crawldb;Uid=root;Pwd=root;Port=3306;";
//     string sql = "SELECT * FROM Weibo_Media order by Id desc limit 0,20000";
//     DbUtility db = new DbUtility(connectionString, DbProviderType.MySql);
//     DataTable data = db.ExecuteDataTable(sql, null);
//     DbDataReader reader = db.ExecuteReader(sql, null);
//     reader.Close(); 
//     MySql注意事项：1.存储过程不能直接return值，需要调整为output输出参数或做为select结果集输出。
//                    2.存储过程参数不捡懒，需要把指定参数输入输出类型、大小、默认值、参数值类型。否则会抛出无法处理的类型。

//     //使用示例 Execl
//     string connectionString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + Server.MapPath("~/XLS/车型.xls") + ";Extended Properties=Excel 8.0;";
//     string sql = "SELECT * FROM [Sheet1$]";
//     DbUtility db = new DbUtility(connectionString, DbProviderType.OleDb);
//     DataTable data = db.ExecuteDataTable(sql, null);
//============================================【示例】=================================================

using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using YYT.Entity;

namespace YYT.BLL
{
    public sealed class DbHelper
    {
        #region 属性
        /// <summary>
        /// 数据库连接字符串
        /// </summary>
        public string ConnectionString { get; set; }
        /// <summary>
        /// 数据库链接
        /// </summary>
        private DbConnection con { get; set; }
        /// <summary>
        /// 数据类型工厂
        /// </summary>
        private DbProviderFactory providerFactory;
        /// <summary>
        /// DbCommand
        /// </summary>
        private DbCommand cmd;
        #endregion

        #region 构造函数
        /// <summary> 
        /// 构造函数
        /// </summary> 
        /// <param name="connectionString">数据库连接字符串</param> 
        /// <param name="providerType">数据库类型枚举，参见<paramref name="providerType"/></param> 
        public DbHelper(string connectionString, EDbProviderType providerType)
        {
            if (String.IsNullOrWhiteSpace(connectionString))
            {
                throw new ArgumentException("Can't load DbConnection for given value of connectionString");
            }
            ConnectionString = connectionString;
            providerFactory = ProviderFactory.GetDbProviderFactory(providerType);
            if (providerFactory == null)
            {
                throw new ArgumentException("Can't load DbProviderFactory for given value of providerType");
            }
        }
        #endregion

        #region ExecuteNonQuery
        /// <summary>    
        /// 执行SQL返回操作影响行数
        /// </summary>    
        /// <param name="sql">要执行的SQL语句</param>    
        /// <param name="parameters">SQL的参数</param> 
        /// <returns>返回受影响的行数</returns>   
        public int ExecuteNonQuery(string sql, IList<DbParameter> parameters)
        {
            return ExecuteNonQuery(sql, parameters, CommandType.Text);
        }
        /// <summary>    
        /// 执行SQL返回操作影响行数
        /// </summary>    
        /// <param name="sql">要执行的SQL语句或存储过程</param>    
        /// <param name="parameters">SQL或储存过程的参数</param> 
        /// <param name="commandType">SQL或储存过程</param> 
        /// <returns>返回受影响的行数</returns> 
        public int ExecuteNonQuery(string sql, IList<DbParameter> parameters, CommandType commandType)
        {
            using (DbCommand command = CreateDbCommand(sql, parameters, commandType))
            {
                command.Connection.Open();
                int affectedRows = command.ExecuteNonQuery();
                this.Close();
                return affectedRows;
            }
        }
        #endregion

        #region ExecuteNonQueryAsync
        /// <summary>    
        /// 执行SQL返回操作影响行数
        /// </summary>    
        /// <param name="sql">要执行的SQL语句</param>    
        /// <param name="parameters">SQL的参数</param> 
        /// <returns>返回受影响的行数</returns>   
        public async System.Threading.Tasks.Task<int> ExecuteNonQueryAsync(string sql, IList<DbParameter> parameters)
        {
            return await ExecuteNonQueryAsync(sql, parameters, CommandType.Text);
        }
        /// <summary>    
        /// 执行SQL返回操作影响行数
        /// </summary>    
        /// <param name="sql">要执行的SQL语句或存储过程</param>    
        /// <param name="parameters">SQL或储存过程的参数</param> 
        /// <param name="commandType">SQL或储存过程</param> 
        /// <returns>返回受影响的行数</returns> 
        public async System.Threading.Tasks.Task<int> ExecuteNonQueryAsync(string sql, IList<DbParameter> parameters, CommandType commandType)
        {
            using (DbCommand command = CreateDbCommand(sql, parameters, commandType))
            {
                await command.Connection.OpenAsync();
                return await command.ExecuteNonQueryAsync();
            }
        }
        #endregion

        #region Query DbDataReader
        /// <summary>    
        /// 执行查询
        /// </summary>    
        /// <param name="sql">要执行的SQL语句</param>    
        /// <param name="parameters">SQL的参数</param> 
        /// <returns></returns>  
        public DbDataReader ExecuteReader(string sql, IList<DbParameter> parameters)
        {
            return ExecuteReader(sql, parameters, CommandType.Text);
        }

        /// <summary>    
        /// 执行查询
        /// </summary>    
        /// <param name="sql">要执行的SQL语句或存储过程</param>    
        /// <param name="parameters">SQL或储存过程的参数</param> 
        /// <param name="commandType">SQL或储存过程</param> 
        /// <returns></returns>  
        public DbDataReader ExecuteReader(string sql, IList<DbParameter> parameters, CommandType commandType)
        {
            DbCommand command = CreateDbCommand(sql, parameters, commandType);
            command.Connection.Open();
            return command.ExecuteReader(CommandBehavior.CloseConnection);
        }
        #endregion

        #region Query DbDataReaderAsync
        /// <summary>    
        /// 执行查询
        /// </summary>    
        /// <param name="sql">要执行的SQL语句</param>    
        /// <param name="parameters">SQL的参数</param> 
        /// <returns></returns>  
        public async System.Threading.Tasks.Task<DbDataReader> ExecuteReaderAsync(string sql, IList<DbParameter> parameters)
        {
            return await ExecuteReaderAsync(sql, parameters, CommandType.Text);
        }

        /// <summary>    
        /// 执行查询
        /// </summary>    
        /// <param name="sql">要执行的SQL语句或存储过程</param>    
        /// <param name="parameters">SQL或储存过程的参数</param> 
        /// <param name="commandType">SQL或储存过程</param> 
        /// <returns></returns>  
        public async System.Threading.Tasks.Task<DbDataReader> ExecuteReaderAsync(string sql, IList<DbParameter> parameters, CommandType commandType)
        {
            DbCommand command = CreateDbCommand(sql, parameters, commandType);
            await command.Connection.OpenAsync();
            return await command.ExecuteReaderAsync(CommandBehavior.CloseConnection);
        }
        #endregion

        #region ExecuteScalar
        /// <summary>    
        /// 执行查询
        /// </summary>    
        /// <param name="sql">要执行的SQL语句</param>    
        /// <param name="parameters">SQL的参数</param>    
        /// <returns>结果的第一行第一列</returns>    
        public Object ExecuteScalar(string sql, IList<DbParameter> parameters)
        {
            return ExecuteScalar(sql, parameters, CommandType.Text);
        }
        /// <summary>
        /// 执行查询
        /// </summary>
        /// <typeparam name="T">返回类型</typeparam>
        /// <param name="sql">要执行的SQL语句或存储过程</param>
        /// <param name="parameters">SQL或储存过程的参数</param>
        /// <param name="commandType">SQL或储存过程</param>
        /// <returns>结果的第一行第一列</returns>
        public T ExecuteScalar<T>(string sql, IList<DbParameter> parameters, CommandType commandType)
        {
            object obj = ExecuteScalar(sql, parameters, commandType);
            if (obj != null)
                return (T)Convert.ChangeType(obj, typeof(T));
            return default(T);
        }
        /// <summary>    
        /// 执行查询
        /// </summary>    
        /// <param name="sql">要执行的SQL语句或存储过程</param>    
        /// <param name="parameters">SQL或储存过程的参数</param>    
        /// <param name="commandType">SQL或储存过程</param> 
        /// <returns>结果的第一行第一列</returns>    
        public Object ExecuteScalar(string sql, IList<DbParameter> parameters, CommandType commandType)
        {
            bool hasReturnVal = false;
            foreach (DbParameter para in parameters)
            {
                if (para.ParameterName.EndsWith("ReturnValue"))
                    hasReturnVal = true;
            }
            //用于接收存储过程Return值
            if (hasReturnVal == false)
                parameters.Add(CreateDbParam("@ReturnValue", ParameterDirection.ReturnValue, null, 4));

            using (DbCommand command = CreateDbCommand(sql, parameters, commandType))
            {
                command.Connection.Open();
                object result = command.ExecuteScalar();
                this.Close();
                return result;
            }
        }
        #endregion

        #region ExecuteScalarAsync
        /// <summary>    
        /// 执行查询
        /// </summary>    
        /// <param name="sql">要执行的SQL语句</param>    
        /// <param name="parameters">SQL的参数</param>    
        /// <returns>结果的第一行第一列</returns>    
        public async System.Threading.Tasks.Task<Object> ExecuteScalarAsync(string sql, IList<DbParameter> parameters)
        {
            return await ExecuteScalarAsync(sql, parameters, CommandType.Text);
        }
        /// <summary>
        /// 执行查询
        /// </summary>
        /// <typeparam name="T">返回类型</typeparam>
        /// <param name="sql">要执行的SQL语句或存储过程</param>
        /// <param name="parameters">SQL或储存过程的参数</param>
        /// <param name="commandType">SQL或储存过程</param>
        /// <returns>结果的第一行第一列</returns>
        public async System.Threading.Tasks.Task<T> ExecuteScalarAsync<T>(string sql, IList<DbParameter> parameters, CommandType commandType)
        {
            object obj = await ExecuteScalarAsync(sql, parameters, commandType);
            if (obj != null)
                return (T)Convert.ChangeType(obj, typeof(T));
            return default(T);
        }
        /// <summary>    
        /// 执行查询
        /// </summary>    
        /// <param name="sql">要执行的SQL语句或存储过程</param>    
        /// <param name="parameters">SQL或储存过程的参数</param>    
        /// <param name="commandType">SQL或储存过程</param> 
        /// <returns>结果的第一行第一列</returns>    
        public async System.Threading.Tasks.Task<Object> ExecuteScalarAsync(string sql, IList<DbParameter> parameters, CommandType commandType)
        {
            bool hasReturnVal = false;
            foreach (DbParameter para in parameters)
            {
                if (para.ParameterName.EndsWith("ReturnValue"))
                    hasReturnVal = true;
            }
            //用于接收存储过程Return值
            if (hasReturnVal == false)
                parameters.Add(CreateDbParam("@ReturnValue", ParameterDirection.ReturnValue, null, 4));

            using (DbCommand command = CreateDbCommand(sql, parameters, commandType))
            {
                await command.Connection.OpenAsync();
                return await command.ExecuteScalarAsync();
            }
        }
        #endregion

        #region Query As T
        /// <summary> 
        /// 查询多个实体集合 
        /// </summary> 
        /// <typeparam name="T">返回的实体集合类型</typeparam> 
        /// <param name="sql">要执行的SQL语句</param>    
        /// <param name="parameters">SQL的参数</param> 
        /// <returns></returns> 
        public List<T> QueryForList<T>(string sql, IList<DbParameter> parameters) where T : new()
        {
            return QueryForList<T>(sql, parameters, CommandType.Text);
        }
        /// <summary> 
        /// 查询单个实体 
        /// </summary> 
        /// <typeparam name="T">返回的实体集合类型</typeparam> 
        /// <param name="sql">要执行的SQL语句</param>    
        /// <param name="parameters">SQL的参数</param> 
        /// <returns></returns> 
        public T QueryForObject<T>(string sql, IList<DbParameter> parameters) where T : new()
        {
            return QueryForObject<T>(sql, parameters, CommandType.Text);
        }
        /// <summary> 
        /// 查询单个实体 
        /// </summary> 
        /// <typeparam name="T">返回的实体集合类型</typeparam> 
        /// <param name="sql">要执行的SQL语句或存储过程</param>    
        /// <param name="parameters">SQL或储存过程的参数</param>    
        /// <param name="commandType">SQL或储存过程</param> 
        /// <returns></returns> 
        public T QueryForObject<T>(string sql, IList<DbParameter> parameters, CommandType commandType) where T : new()
        {
            var qy = QueryForList<T>(sql, parameters, commandType);
            return ((qy != null && qy.Count > 0) ? qy[0] : default(T));
        }
        /// <summary> 
        ///  查询多个实体集合 
        /// </summary> 
        /// <typeparam name="T">返回的实体集合类型</typeparam> 
        /// <param name="sql">要执行的SQL语句或存储过程</param>    
        /// <param name="parameters">SQL或储存过程的参数</param>    
        /// <param name="commandType">SQL或储存过程</param> 
        /// <returns></returns> 
        public List<T> QueryForList<T>(string sql, IList<DbParameter> parameters, CommandType commandType) where T : new()
        {
            DataTable dt = ExecuteDataTable(sql, parameters, commandType);
            if (dt != null)
                return EntityReader.GetEntities<T>(dt);
            else
                return new List<T>();
        }
        #endregion

        #region Query Table
        /// <summary>    
        /// 执行一个查询语句
        /// </summary>    
        /// <param name="sql">要执行的SQL语句</param>    
        /// <param name="parameters">SQL的参数</param> 
        /// <returns></returns> 
        public DataTable ExecuteDataTable(string sql, IList<DbParameter> parameters)
        {
            return ExecuteDataTable(sql, parameters, CommandType.Text);
        }
        /// <summary>    
        /// 执行一个查询语句
        /// </summary>    
        /// <param name="sql">要执行的SQL语句或存储过程</param>    
        /// <param name="parameters">SQL或储存过程的参数</param> 
        /// <param name="commandType">SQL或储存过程</param> 
        /// <returns></returns> 
        public DataTable ExecuteDataTable(string sql, IList<DbParameter> parameters, CommandType commandType)
        {
            DataSet ds = ExecuteDataSet(sql, parameters, commandType);
            return ds != null && ds.Tables.Count > 0 ? ds.Tables[0] : null;
        }
        /// <summary>    
        /// 执行一个查询语句
        /// </summary>    
        /// <param name="sql">要执行的SQL语句</param>    
        /// <param name="parameters">SQL的参数</param> 
        /// <returns></returns> 
        public DataSet ExecuteDataSet(string sql, IList<DbParameter> parameters)
        {
            return ExecuteDataSet(sql, parameters, CommandType.Text);
        }
        /// <summary>
        /// 执行一个查询语句
        /// </summary>    
        /// <param name="sql">要执行的SQL语句或存储过程</param>    
        /// <param name="parameters">SQL或储存过程的参数</param> 
        /// <param name="commandType">SQL或储存过程</param> 
        /// <returns></returns>
        public DataSet ExecuteDataSet(string sql, IList<DbParameter> parameters, CommandType commandType)
        {
            using (DbCommand command = CreateDbCommand(sql, parameters, commandType))
            {
                using (DbDataAdapter adapter = providerFactory.CreateDataAdapter())
                {
                    adapter.SelectCommand = command;
                    DataSet ds = new DataSet();
                    adapter.Fill(ds);
                    return ds;
                }
            }
        }
        #endregion

        #region 释放资源
        /// <summary>
        /// 关闭数据库连接
        /// </summary>
        public void Close()
        {
            //确认连接存在
            if (con != null)
            {
                con.Close();
            }
        }

        /// <summary>
        /// 释放资源
        /// </summary>
        public void Dispose()
        {
            // 确认连接是否已经关闭
            if (cmd != null && con != null)
            {
                Close();//关闭连接

                //释放资源
                con.Dispose();
                cmd.Dispose();
            }
        }

        #endregion

        #region 创建DbParameter对象
        /// <summary>
        /// 创建一个DbParameter对象
        /// </summary>
        /// <param name="name">参数名称</param>
        /// <param name="value">参数对应值</param>
        /// <returns></returns>
        public DbParameter CreateDbParam(string name, object value)
        {
            return CreateDbParam(name, ParameterDirection.Input, value, 0);
        }
        /// <summary>
        /// 创建一个DbParameter对象
        /// </summary>
        /// <param name="name">参数名称</param>
        /// <param name="value">参数对应值</param>
        /// <param name="dbtype">数据类型</param>
        /// <returns></returns>
        public DbParameter CreateDbParam(string name, object value, DbType dbtype)
        {
            return CreateDbParam(name, ParameterDirection.Input, value, 0, dbtype);
        }
        /// <summary>
        /// 创建一个DbParameter对象
        /// </summary>
        /// <param name="name">参数名称</param>
        /// <param name="parameterDirection">参数输入输出类型</param>
        /// <param name="value">参数对应值</param>
        /// <param name="size">参数大小</param>
        /// <returns></returns>
        public DbParameter CreateDbParam(string name, ParameterDirection parameterDirection, object value, int size)
        {
            DbParameter parameter = providerFactory.CreateParameter();
            parameter.ParameterName = name;
            parameter.Value = value;
            if (size > 0)
            {
                parameter.Size = size;
            }
            parameter.Direction = parameterDirection;
            return parameter;
        }
        /// <summary>
        /// 创建一个DbParameter对象
        /// </summary>
        /// <param name="name">参数名称</param>
        /// <param name="parameterDirection">参数输入输出类型</param>
        /// <param name="value">参数对应值</param>
        /// <param name="size">参数大小</param>
        /// <param name="dbtype">数据类型</param>
        /// <returns></returns>
        public DbParameter CreateDbParam(string name, ParameterDirection parameterDirection, object value, int size, DbType dbtype)
        {
            DbParameter parameter = providerFactory.CreateParameter();
            parameter.ParameterName = name;
            parameter.Value = value;
            parameter.DbType = dbtype;
            if (size > 0)
            {
                parameter.Size = size;
            }
            parameter.Direction = parameterDirection;
            return parameter;
        }
        #endregion

        #region 创建DbCommand对象
        /// <summary> 
        /// 创建一个DbCommand对象
        /// </summary> 
        /// <param name="sql">要执行的SQL语句或存储过程</param>    
        /// <param name="parameters">SQL或储存过程的参数</param> 
        /// <param name="commandType">SQL或储存过程</param> 
        /// <returns></returns> 
        private DbCommand CreateDbCommand(string sql, IList<DbParameter> parameters, CommandType commandType)
        {
            this.con = providerFactory.CreateConnection();
            this.con.ConnectionString = this.ConnectionString;
            cmd = providerFactory.CreateCommand();
            cmd.CommandText = sql;
            cmd.CommandType = commandType;
            cmd.Connection = this.con;

            if (!(parameters == null || parameters.Count == 0))
            {
                foreach (DbParameter parameter in parameters)
                {

                    cmd.Parameters.Add(parameter);
                }
            }
            return cmd;
        }
        #endregion

    }

}
