using System;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Web.Http;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;

namespace YYT.Web.Controllers.Api
{
    public class CashierPicController : ApiController
    {
        /// <summary>
        /// 收款人二维码图
        /// </summary>
        /// <param name="id">图类型   1表示微信   2表示支付宝</param>
        /// <returns></returns>
        //GET: api/CashierPic/{id}
        public async Task<HttpResponseMessage> Get(int id)
        {
            try
            {
                M_CashierInfo rst = await new B_CashierInfo().GetQRCodeImg(id);
                if (rst != null)
                {
                    string dir = System.Web.Hosting.HostingEnvironment.MapPath("~/Upload/");
                    string fileName = rst.QRCodeImg;
                    string path = System.IO.Path.Combine(dir, fileName);

                    if (System.IO.File.Exists(path))
                    {
                        HttpResponseMessage result = new HttpResponseMessage(HttpStatusCode.OK);
                        var stream = new FileStream(path, FileMode.Open, FileAccess.Read);
                        result.Content = new StreamContent(stream);
                        result.Content.Headers.ContentType = new MediaTypeHeaderValue("application/octet-stream");
                        return result;
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Controllers.Api.CashierPicController), ex);
            }
            return new HttpResponseMessage(HttpStatusCode.NoContent);
        }
    }
}
