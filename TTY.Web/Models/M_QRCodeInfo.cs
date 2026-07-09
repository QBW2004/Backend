using System.ComponentModel.DataAnnotations;
using System.Web;

namespace YYT.Web
{
    public class M_QRCodeUpload
    {
        /// <summary>
        /// 收款人账号
        /// </summary>
        public string Account { get; set; }
        /// <summary>
        /// 收款人
        /// </summary>
        public string Name { get; set; }
        /// <summary>
        /// 支付类型
        /// <para>1 微信</para>
        /// <para>2 支付宝</para>
        /// </summary>
        public int PayType { get; set; }
        /// <summary>
        /// 旧文件
        /// </summary>
        public string OldFile { get; set; }
        /// <summary>
        /// 收款二维码
        /// </summary>
        [Display(Name = "收款二维码", Description = "收款二维码")]
        [ValidateFile(Nullable = true, ErrorMessage = "请上传收款二维码图片")]
        public HttpPostedFileBase QRCodeImg { get; set; }
    }
}
