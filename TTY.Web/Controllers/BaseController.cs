using YYT.Entity;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Web.Mvc;

namespace YYT.Web.Controllers
{
    /// <summary>
    /// 控制器基类 
    /// </summary>
    public abstract class BaseController : Controller
    {
        #region 公用函数
        /// <summary>
        /// 返回JSON数据
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        protected virtual new JsonResult Json(object obj)
        {
            return this.Json(obj, Encoding.UTF8);
        }

        /// <summary>
        /// 返回前端表格用数据
        /// </summary>
        /// <param name="dataRows"></param>
        /// <param name="totalCount"></param>
        /// <returns></returns>
        protected virtual JsonResult GridJson(object dataRows, int totalCount)
        {
            return this.Json(new { total = totalCount, rows = dataRows }, Encoding.UTF8);
        }

        /// <summary>
        /// 返回JSON数据
        /// </summary>
        /// <param name="obj"></param>
        /// <param name="encoding"></param>
        /// <returns></returns>
        protected virtual JsonResult Json(object obj, Encoding encoding)
        {
            if (obj == null)
                if (Request.Params.AllKeys.Contains<string>("page") || Request.Params.AllKeys.Contains<string>("rows"))
                    return Json(new { code = (int)EServerData.Success, msg = TipMsg.MSG_NO_DATA, total = 0, rows = new List<int>() }, "application/json", encoding, JsonRequestBehavior.AllowGet);
                else
                    return Json(new { code = (int)EServerData.Success, msg = TipMsg.MSG_NO_DATA }, "application/json", encoding, JsonRequestBehavior.AllowGet);

            if (encoding == null)
                encoding = Encoding.UTF8;

            return Json(obj, "application/json", encoding, JsonRequestBehavior.AllowGet);
        }

        /// <summary>
        /// 下载Excel文件
        /// </summary>
        /// <param name="stream">文件流</param>
        /// <param name="fileName">文件名（可选参数）</param>
        /// <returns></returns>
        protected virtual FileResult Excel(Stream stream, string fileName = "")
        {
            string fname = (String.IsNullOrWhiteSpace(fileName) ? DateTime.Now.ToString("yyyyMMddhhmmssfff") : fileName) + ".xls";

            if (stream != null)
                return File(stream, "application/x-xls", fname);
            else
                return File(new Byte[0], "application/x-xls", fname);
        }
        #endregion
    }
}
