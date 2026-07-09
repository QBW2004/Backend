using System;
using System.Data.Common;
using System.Text;
using System.Threading.Tasks;
using YYT.Entity;

namespace YYT.BLL
{
    /// <summary>
    /// 游戏配置
    /// </summary>
    public class B_Config : SupperBLL
    {
        public B_Config() : base(PubConstant.DbConnString) { }

        public int GetConfig()
        {
            try
            {
                //string sql = "select * from t_gameparam;";
                string sql = @"INSERT INTO T_GameParam(ParamType,ParamText,ParamName,ParamValue,ValType,Remark)" +
                    "VALUES(1, '" + Guid.NewGuid().ToString().Replace("-", "").Substring(20) 
                    + "', 'T1', '79', 'Float', '" + Guid.NewGuid().ToString().Replace("-", "") + "');";
                Task<int> tsk = db.ExecuteNonQueryAsync(sql, null);
                return tsk.Result;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                this.Dispose();
            }
        }

        public int UpdateShowCount()
        {
            try
            {
                string sql = @"UPDATE `T_GameParam`
                                SET ParamText = 'ABCDEFG' " +
                               "WHERE id = 1;";
                Task<int> tsk = db.ExecuteNonQueryAsync(sql, null);
                return tsk.Result;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                this.Dispose();
            }
        }

        public async Task<string> Test()
        {
            var providerFactory = ProviderFactory.GetDbProviderFactory(EDbProviderType.MySql);
            DbConnection connection = providerFactory.CreateConnection();
            try
            {
                connection.ConnectionString = PubConstant.DbConnString;
                await connection.OpenAsync();

                DbCommand cmdSelect = connection.CreateCommand();
                cmdSelect.CommandText = "SELECT * FROM Admin;";

                DbDataReader reader = await cmdSelect.ExecuteReaderAsync();

                StringBuilder sb = new StringBuilder();
                while (await reader.ReadAsync())
                {
                    sb.AppendFormat("{0} {1} {2} {3} {4}", reader[0], reader[1], reader[2], reader[3], reader[4]);
                }
                return sb.ToString();
            }
            finally
            {
                connection.Close();
            }
        }
    }
}
