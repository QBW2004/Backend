using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using YYT.BLL.EF;
using YYT.Entity;

namespace YYT.Web.Controllers.Api
{
    [RoutePrefix("api/QRCodeList")]
    public class QRCodeListController : ApiController
    {
        /// <summary>
        /// 游戏类型
        /// </summary>
        /// <returns></returns>
        // GET: api/Games
        public IEnumerable<UploadsImageList> Get()
        {
            List<UploadsImageList> list = new List<UploadsImageList>();
            try
            {
                list = new B_UploadsImage().GetQRCodeList();
            }
            catch (Exception ex)
            {
            }
            return list;
        }
    }
}
