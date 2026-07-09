using System;
using System.Data;
using System.Data.SqlClient;

namespace YYT.BLL
{
    public class SqlBulkWriter
    {
        /// <summary>
        /// SqlBulkCopy批量插入数据
        /// </summary>
        /// <param name="connectionStr">链接字符串</param>
        /// <param name="dataTableName">表名</param>
        /// <param name="sourceDataTable">数据源</param>
        /// <param name="batchSize">一次事务插入的行数</param>
        public static void SqlBulkCopyByDataTable(string connectionStr, string dataTableName, DataTable sourceDataTable, int batchSize = 100000)
        {
            using (SqlConnection connection = new SqlConnection(connectionStr))
            {
                using (SqlBulkCopy sqlBulkCopy = new SqlBulkCopy(connectionStr, SqlBulkCopyOptions.UseInternalTransaction))
                {
                    try
                    {
                        sqlBulkCopy.DestinationTableName = dataTableName;
                        sqlBulkCopy.BatchSize = batchSize;

                        for (int i = 0; i < sourceDataTable.Columns.Count; i++)
                        {
                            sqlBulkCopy.ColumnMappings.Add(sourceDataTable.Columns[i].ColumnName, sourceDataTable.Columns[i].ColumnName);
                        }

                        sqlBulkCopy.WriteToServer(sourceDataTable);
                    }
                    catch (Exception ex)
                    {
                        throw ex;
                    }
                }
            }
        }
    }
}
