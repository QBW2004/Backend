using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace YYT.Web
{
    public class ValidateFileAttribute : ValidationAttribute
    {
        /// <summary>
        /// 允许空
        /// </summary>
        public bool Nullable { get; set; }

        public override bool IsValid(object value)
        {
            try
            {
                int maxLength = 1024 * 1024 * 4;
                string[] allowExt = new string[] { ".jpg", "jpeg", ".gif", ".png" };

                var file = value as HttpPostedFileBase;

                if (file == null)
                {
                    if (this.Nullable == true)
                        return true;
                    else
                        return false;
                }
                else
                if (!allowExt.Contains(System.IO.Path.GetExtension(file.FileName)))
                {
                    ErrorMessage = "只请允许上传的图片类型有: " + string.Join(",", allowExt);
                    return false;
                }
                else if (file.ContentLength > maxLength)
                {
                    ErrorMessage = "上传图片过大，不能超过4兆（4MB）。";
                    return false;
                }
                else
                    return true;
            }
            catch
            {
                return false;
            }
        }
    }
}