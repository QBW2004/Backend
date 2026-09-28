using System;
using System.Linq;
using System.Text.RegularExpressions;
using YYT.Common;
using YYT.Entity;

namespace YYT.BLL.EF
{
    /// <summary>
    /// 公告（notice 表）业务层。
    ///
    /// <para><b>唯一性</b>：全表只允许一条记录。后台「全屏公告」页进入即编辑这一条，
    /// 客户端 Notice 面板也只展示这一条；中心服 MessageNotice 会把表里**所有行**都下发，
    /// 所以历史多出来的行必须由本层清掉（<see cref="SaveSingleNotice"/> 保存时收敛，
    /// SQL 补丁里也做了一次存量清理），否则客户端又会收到多条公告。</para>
    ///
    /// <para><b>字号下发契约</b>：中心服只把 TITLE / NOTICE 两个字符串原样下发
    /// （ServerCenterNew::MessageNotice + Database::GetNotice），报文里没有字号字段，
    /// 所以非默认字号由本层以 <c>[SIZE=nn]</c> 前缀写进 NOTICE 一起下发：
    /// 客户端 LibAlg 解析该前缀后套用到 Notice 面板 Scroll View/Label 的 fontSize，
    /// 并把它从正文里剥掉。字号等于默认值（41，与客户端 Label 设计值一致）时不写前缀，
    /// 于是「没改过字号的公告」对老客户端也是零影响。</para>
    /// </summary>
    public class B_Notice
    {
        /// <summary>标题留空时的兜底值（中心服以标题为 map key，也用于旧客户端按钮文案）</summary>
        public const string DefaultTitle = "公告";

        /// <summary>字号标记：<c>[SIZE=nn]</c>，只认前缀，与客户端解析保持同一格式（大小写不敏感）</summary>
        private static readonly Regex SizeTagRegex =
            new Regex(@"^\s*\[SIZE=(\d{1,3})\]\s*", RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);

        /// <summary>
        /// 取唯一公告（表里存在多条时取最新一条）。库中无数据时返回 null。
        /// <para>返回对象的 NOTICE 是**裸文本**（已剥掉字号标记），字号单独放在 FONTSIZE 里，
        /// 直接给后台编辑页显示用。</para>
        /// </summary>
        public M_Notice GetSingleNotice()
        {
            using (var ef = new GameDbContext())
            {
                M_Notice row = ef.Notices.OrderByDescending(c => c.ID).FirstOrDefault();
                if (row == null) return null;

                // 正文里带标记时以标记为准：那才是客户端真正会渲染的字号，
                // 编辑页/预览按它走才不会与客户端看到的不一致。
                int tagged;
                string plain = SplitSizeTag(row.NOTICE, out tagged);
                int fontSize = tagged > 0 ? NoticeFontSize.Normalize(tagged) : NoticeFontSize.Normalize(row.FONTSIZE);

                return new M_Notice
                {
                    ID = row.ID,
                    TITLE = string.IsNullOrWhiteSpace(row.TITLE) ? DefaultTitle : row.TITLE,
                    NOTICE = plain,
                    FONTSIZE = fontSize
                };
            }
        }

        /// <summary>
        /// 保存唯一公告：已有记录则更新，没有则新增；同时删除历史多出来的行。
        /// <para>内容为空白时直接失败（不写库）；标题留空按 <see cref="DefaultTitle"/> 存。</para>
        /// </summary>
        public Msg SaveSingleNotice(M_Notice entity)
        {
            Msg msg = new Msg(0, "公告保存失败！");
            if (entity == null || string.IsNullOrWhiteSpace(entity.NOTICE))
            {
                msg.content = "公告内容不能为空！";
                return msg;
            }

            string title = string.IsNullOrWhiteSpace(entity.TITLE) ? DefaultTitle : entity.TITLE.Trim();
            int fontSize = NoticeFontSize.Normalize(entity.FONTSIZE);
            // 正文里的字面 \n 统一存成真实换行：客户端本来就会做 content.Replace("\\n","\n")，
            // 存真实换行后客户端/后台预览/数据库看到的是同一份内容（历史数据里的 \n 一并收敛）。
            string plain = (entity.NOTICE ?? string.Empty).Replace("\\n", "\n");
            // 真正进库（并下发给客户端）的正文：默认字号不加任何标记
            string stored = ComposeSizeTag(plain, fontSize);

            using (var ef = new GameDbContext())
            {
                using (var trans = ef.Database.BeginTransaction())
                {
                    try
                    {
                        var rows = ef.Notices.OrderByDescending(c => c.ID).ToList();
                        if (rows.Count == 0)
                        {
                            M_Notice added = new M_Notice
                            {
                                TITLE = title,
                                NOTICE = stored,
                                FONTSIZE = fontSize
                            };
                            ef.Notices.Add(added);
                        }
                        else
                        {
                            // 保留最新一条的 ID（客户端/中心服都不依赖 ID，但保持稳定利于排查）
                            M_Notice target = rows[0];
                            target.TITLE = title;
                            target.NOTICE = stored;
                            target.FONTSIZE = fontSize;
                            for (int i = 1; i < rows.Count; i++)
                                ef.Notices.Remove(rows[i]);
                        }

                        ef.SaveChanges();
                        trans.Commit();
                        msg.code = 1;
                        msg.content = "公告保存成功！";
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        LogHelper.WriteLog(typeof(YYT.BLL.EF.B_Notice), ex);
                    }
                }
            }
            return msg;
        }

        /// <summary>
        /// 组下发给客户端的正文：按需加 <c>[SIZE=nn]</c> 前缀。
        /// <para>入参无论是否已带标记都会先剥掉，避免重复叠加。</para>
        /// </summary>
        public static string ComposeSizeTag(string notice, int fontSize)
        {
            string text = RemoveSizeTag(notice);
            if (fontSize == NoticeFontSize.Default) return text;
            return "[SIZE=" + NoticeFontSize.Normalize(fontSize) + "]" + text;
        }

        /// <summary>
        /// 剥掉正文开头的 <c>[SIZE=nn]</c> 标记，返回裸文本；<paramref name="size"/> 输出解析到的字号
        /// （没有标记时为 0）。
        /// </summary>
        public static string SplitSizeTag(string notice, out int size)
        {
            size = 0;
            if (string.IsNullOrEmpty(notice)) return notice;

            Match m = SizeTagRegex.Match(notice);
            if (!m.Success) return notice;

            int parsed;
            if (!int.TryParse(m.Groups[1].Value, out parsed)) return notice;

            size = parsed;
            return notice.Substring(m.Length);
        }

        /// <summary>只剥标记、不关心字号的简便写法</summary>
        public static string RemoveSizeTag(string notice)
        {
            int size;
            return SplitSizeTag(notice, out size);
        }
    }
}
