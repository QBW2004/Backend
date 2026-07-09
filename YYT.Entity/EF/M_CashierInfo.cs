using Newtonsoft.Json;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Web;

namespace YYT.Entity
{
    /// <summary>
    /// 收款人信息
    /// </summary>
    [Table("CashierInfo")]
    public class M_CashierInfo
    {
        /// <summary>
        /// 标识ID
        /// </summary>
        [Key]
        [Display(Name = "标识ID", Description = "标识ID"), MaxLength(38, ErrorMessage = "长度不能超过40个字符")]
        public string CID { get; set; }
        /// <summary>
        /// 收款人姓名
        /// </summary>
        [Required]
        [Display(Name = "收款人姓名", Description = "收款人姓名"), MaxLength(20, ErrorMessage = "长度不能超过20个字符")]
        public string Name { get; set; }
        /// <summary>
        /// 收款人账号
        /// </summary>
        [Required]
        [Display(Name = "收款人账号", Description = "收款人账号"), MaxLength(20, ErrorMessage = "长度不能超过20个字符")]
        public string Account { get; set; }
        /// <summary>
        /// 收款信息所属代理
        /// </summary>
       // [Required]
        //[Display(Name = "所属代理", Description = "所属代理"), MaxLength(50, ErrorMessage = "长度不能超过20个字符")]
        public string Agency { get; set; }
        /// <summary>
        /// 支付类型
        /// <para>1 微信</para>
        /// <para>2 支付宝</para>
        /// </summary>
        [Required]
        [Display(Name = "支付类型", Description = "支付类型")]
        [Range(1, 2, ErrorMessage = "超出范围（1-2）")]
        public int PayType { get; set; }
        /// <summary>
        /// 收款码图片名称
        /// </summary>
        public string QRCodeImg { get; set; }
        /// <summary>
        /// 是否使用收款码
        /// <para>0 不使用</para>
        /// <para>1 使用</para>
        /// </summary>
        [Required]
        [Display(Name = "是否使用收款码", Description = "是否使用收款码")]
        [Range(0, 1, ErrorMessage = "超出范围（0-1）")]
        public int UseQRCodeImg { get; set; }
        /// <summary>
        /// 是否启用
        /// <para>0 不使用</para>
        /// <para>1 使用</para>
        /// </summary>
        [Required]
        [Display(Name = "是否启用此收款信息", Description = "是否启用此收款信息")]
        [Range(0, 1, ErrorMessage = "超出范围（0-1）")]
        public int Enable { get; set; }
        /// <summary>
        /// 更新时间
        /// </summary>
        public DateTime CreateTime { get; set; }
        /// <summary>
        /// 上传的文件
        /// </summary>
        [NotMapped]
        public HttpPostedFileBase Upfile { get; set; }

        [NotMapped]
        public string OldFile { get; set; }
        /// <summary>
        /// 更新时间
        /// </summary>
        [NotMapped]
        public string CreateTimeStr { get { return this.CreateTime.ToString("yyyy-MM-dd HH:mm:ss"); } set { CreateTimeStr = value; } }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
    public class M_Cashier
    {
        /// <summary>
        /// 收款人姓名
        /// </summary>
        public string Name { get; set; }
        /// <summary>
        /// 收款人账号
        /// </summary>
        public string Account { get; set; }
        /// <summary>
        /// 支付类型
        /// <para>1 微信</para>
        /// <para>2 支付宝</para>
        /// </summary>
        public int PayType { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}
