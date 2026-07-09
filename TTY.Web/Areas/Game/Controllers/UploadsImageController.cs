using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;

namespace YYT.Web.Areas.Game.Controllers
{
    public class UploadsImageController : Controller
    {
        // GET: Game/UploadsImage
        public ActionResult Index()
        {
            return View();
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult List(FormCollection form)
        {
            M_EasyuiGridData<M_UploadsImage> list = new M_EasyuiGridData<M_UploadsImage>();
            try
            {
                // string UserName = form.Q<string>("UserName");
                int pageIndex = form.Q<int>("page", 1);
                int pageSize = form.Q<int>("rows", 10);

                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(list);

                M_Page mPage = new M_Page(pageIndex, pageSize);
               

                list = new B_UploadsImage().GetUploadsImage(loginUser, mPage);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(list);
        }

        #region 上传附件

        [HttpPost]
        public ActionResult SavePicture(string uploaderName, string fileTypeId)
        {

            //var tmpArr = picString.Split(',');
            //byte[] bytes = Convert.FromBase64String(tmpArr[1]);
            //MemoryStream ms = new MemoryStream(bytes);
            //ms.Write(bytes, 0, bytes.Length);
            //var img = Image.FromStream(ms, true);

            //var path = ConfigHelper.Get("UploadPath") ;

            //string fileName = DateTime.Now.ToString("yyyyMMddHHmmss_ffff", System.Globalization.DateTimeFormatInfo.InvariantInfo) + ".png";
            //var bitImage = GetThumbnailImage(img, 400, 300);
            //bitImage.Save(path + @"\" +fileName);
            //bool isOk = true;
            //string msg = path + @"\" + fileName;

            //int count1 = new B_UploadsImage().UpdateUploadsImage(fileName, Convert.ToInt32(fileTypeId));
            //return Json(new { suc = isOk, msg = msg });
            bool isOk = true;
            string msg = "";
            try
            {
                //HttpPostedFileBase file = Request.Files[uploaderName];

                //var files = Request.Files.GetMultiple(uploaderName);

                //string fname = file.FileName;
                //int index = fname.LastIndexOf(".");
                //int len = fname.Length - index - 1;
                //string fileName = fname.Substring(0, index).ToLower();
                //string fileType = fname.Substring(index, len + 1).ToLower();
                ////fname = Guid.NewGuid() +fname+ fileType;
                ////文件名
                //fname = "(" + fileName + ")" + string.Format("{0:yyyyMMddHHmmssffff}", DateTime.Now) + fileType;
                ////绝对路径
                ////string filePath = FileHandler.GetSettingPath("分包商附件上传目录") + @"\" + fname;
                //string filePath = Server.MapPath("~/Upload/" + fname);//保存文件的路径
                //file.SaveAs(filePath);

                int count1 = new B_UploadsImage().UpdateUploadsImage("", Convert.ToInt32(fileTypeId));
            }
            catch(Exception ex)
            {
                isOk = false;
                msg = ex.Message;
            }
            return Json(new { suc = isOk, msg = msg });


        }

        #endregion
        //图片压缩
        public static Image GetThumbnailImage(Image srcImage, int width, int height)
        {
            Image bitmap = new Bitmap(width, height);
            Graphics g = Graphics.FromImage(bitmap);

            //设置高质量插值法 
            g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.High;
            g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.HighSpeed;

            //在指定位置并且按指定大小绘制原图片的指定部分 
            g.DrawImage(srcImage, new Rectangle(0, 0, width, width),
                new Rectangle(0, 0, srcImage.Width, srcImage.Height),
                GraphicsUnit.Pixel);

            return bitmap;
        }
    }

   
}