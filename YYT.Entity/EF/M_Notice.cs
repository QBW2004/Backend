using Newtonsoft.Json;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    /// <summary>
    /// 公告表
    /// <para>全表只允许存在一条记录（后台「全屏公告」页 = 唯一公告的编辑器，
    /// 客户端 Notice 面板也只展示这一条），唯一性由 B_Notice.SaveSingleNotice 保证。</para>
    /// </summary>
    [Table("Notice")]
    public class M_Notice
    {
        /// <summary>
        /// ID
        /// </summary>
        public int ID { get; set; }

        /// <summary>
        /// 标题
        /// <para>客户端旧版本用它作为公告按钮的文案，现单条展示下仅作标识，
        /// 同时是中心服 <c>GetNotice</c> 里 map&lt;标题,内容&gt; 的 key（留空会以默认标题保存）。</para>
        /// </summary>
        public string TITLE { get; set; }

        /// <summary>
        /// 玩家公告（一般告知玩家客服微信等）
        /// <para>列宽 varchar(255)，后台校验 200 字符。</para>
        /// </summary>
        [Required]
        [Display(Description = "公告内容", Name = "公告内容"), MaxLength(200, ErrorMessage = "长度不能超过200个字符!")]
        public string NOTICE { get; set; }

        /// <summary>
        /// 公告字号
        /// <para>对应客户端 Notice 面板 Scroll View/Label 的 mFontSize，设计基准 41。</para>
        /// <para>中心服只下发 TITLE/NOTICE 两个字符串，所以非默认字号由后台以
        /// <c>[SIZE=nn]</c> 前缀写进 NOTICE 尾部内容下发，客户端解析后套用到 Label 上；
        /// 等于默认字号时不写前缀（老客户端也就看不到任何标记）。</para>
        /// </summary>
        [Display(Description = "字号", Name = "字号")]
        [Range(NoticeFontSize.Min, NoticeFontSize.Max, ErrorMessage = "字号必须在 12-120 之间!")]
        public int FONTSIZE { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }
    }

    /// <summary>
    /// 公告字号常量：客户端 Notice 面板 Label 的设计字号为 41，
    /// 后台页面 / 控制器 / 客户端标记解析三处共用同一套边界。
    /// </summary>
    public static class NoticeFontSize
    {
        /// <summary>客户端 Label 的设计字号（不写 [SIZE=] 标记的默认值）</summary>
        public const int Default = 41;

        /// <summary>允许的最小字号</summary>
        public const int Min = 12;

        /// <summary>允许的最大字号（再大 255 字符的内容会溢出可视区太多）</summary>
        public const int Max = 120;

        /// <summary>
        /// 把后台填的字号收敛到合法区间，非法值（0/负数/超上限）一律回退默认字号。
        /// </summary>
        public static int Normalize(int fontSize)
        {
            if (fontSize < Min || fontSize > Max) return Default;
            return fontSize;
        }
    }
}
