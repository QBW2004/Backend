using System;
using System.Threading.Tasks;

namespace YYT.Common
{
    public class LogHelper
    {
        /// <summary>
        /// 输出日志到Log4Net
        /// </summary>
        /// <param name="t"></param>
        /// <param name="ex"></param>
        #region static void WriteLog(Type t, Exception ex)
        public static void WriteLog(Type t, Exception ex)
        {
            Task.Factory.StartNew(() =>
            {
                log4net.ILog log = log4net.LogManager.GetLogger(t);
                log.Error("Error", ex);
            });
        }
        #endregion

        /// <summary>
        /// 输出日志到Log4Net
        /// </summary>
        /// <param name="t"></param>
        /// <param name="msg"></param>
        #region static void WriteLog(Type t, string msg)
        public static void WriteLog(Type t, string msg)
        {
            Task.Factory.StartNew(() =>
            {
                try
                {
                    log4net.ILog log = log4net.LogManager.GetLogger(t);
                    log.Info(msg);
                }
                catch
                {
                }
            });
        }
        #endregion

    }
}
