using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using YYT.Entity;

namespace YYT.BLL
{
    public class SupperBLL : IDisposable
    {
        protected DbHelper db;

        public SupperBLL() { }

        public SupperBLL(string conString) 
        {
            //db = new DbHelper(conString, EDbProviderType.SQLite);
        }

        protected void CreateDbHelper(string conString)
        {
            //db = new DbHelper(conString, EDbProviderType.SQLite);
        }

        /// <summary>
        /// 执行存储过程
        /// </summary>
        /// <param name="procName">存储过程名称</param>
        /// <param name="paraList">存储过程参数</param>
        /// <returns> Msg </returns>
        protected virtual Msg RunProcGetMsg(string procName, List<DbParameter> paraList)
        {
            bool hasReturnMsgPara = false;
            bool hasReturnValPara = false;
            paraList = (paraList == null ? new List<DbParameter>() : paraList);
            foreach (DbParameter para in paraList)
            {
                if (para.ParameterName.EndsWith("ReturnValue"))
                    hasReturnValPara = true;
                if (para.ParameterName.EndsWith("ReturnMsg"))
                    hasReturnMsgPara = true;
            }
            if (hasReturnValPara == false)
                paraList.Add(db.CreateDbParam("@ReturnValue", ParameterDirection.Output, null, 4));
            if (hasReturnMsgPara == false)
                paraList.Add(db.CreateDbParam("@ReturnMsg", ParameterDirection.Output, null, 50));

            db.ExecuteScalar(procName, paraList, CommandType.StoredProcedure);

            return this.GetProcMsg(paraList);
        }

        /// <summary>
        /// 执行存储过程
        /// </summary>
        /// <param name="procName">存储过程名称</param>
        /// <param name="paraList">存储过程参数</param>
        /// <returns> DataTable </returns>
        protected virtual DataTable RunProcGetTable(string procName, List<DbParameter> paraList)
        {
            return db.ExecuteDataTable(procName, paraList, CommandType.StoredProcedure);
        }

        /// <summary>
        /// 执行存储过程
        /// </summary>
        /// <param name="procName">存储过程名称</param>
        /// <param name="paraList">存储过程参数</param>
        /// <returns> DataSet </returns>
        protected virtual DataSet RunProcGetDataSet(string procName, List<DbParameter> paraList)
        {
            return db.ExecuteDataSet(procName, paraList, CommandType.StoredProcedure);
        }

        /// <summary>
        /// 获取存储过程消息
        /// </summary>
        /// <param name="paraList">参数列表</param>
        /// <returns></returns>
        protected virtual Msg GetProcMsg(List<DbParameter> paraList)
        {
            Msg msg = new Msg();
            // 获取返回值
            foreach (DbParameter para in paraList)
            {
                if (para.ParameterName.EndsWith("ReturnValue") && para.Value != DBNull.Value)
                    msg.code = Convert.ToInt32(para.Value);
                if (para.ParameterName.EndsWith("ReturnMsg") && para.Value != DBNull.Value)
                    msg.content = para.Value.ToString();
            }
            return msg;
        }

        public void Dispose()
        {
            if (db != null)
            {
                db.Close();
                db.Dispose();
            }
        }
    }
}
