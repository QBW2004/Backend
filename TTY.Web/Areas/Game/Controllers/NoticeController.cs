using System;
using System.Web.Mvc;
using YYT.BLL.EF;
using YYT.Common;
using YYT.Entity;
using YYT.Web;
using YYT.Web.Controllers;

namespace YYT.Web.Areas.Game.Controllers
{
    /// <summary>
    /// 全屏公告 —— 唯一公告的编辑页。
    ///
    /// <para>客户端已改成只展示一条公告（大厅 Notice 面板「Scroll View」里的一个 Label），
    /// 后台这边同步从「列表 + 新增/修改/删除」收敛成「进入即编辑」：没有添加按钮、
    /// 没有删除、没有列表，保存就是对那唯一一条的全量覆盖（<see cref="B_Notice.SaveSingleNotice"/>）。</para>
    ///
    /// <para>字号：客户端 Label 有字号概念，中心服却没下发字号字段，所以非默认字号
    /// 由后台以 <c>[SIZE=nn]</c> 前缀写进正文（详见 <see cref="B_Notice"/> 注释）。</para>
    /// </summary>
    [MemberAuthorize]
    public class NoticeController : BaseController
    {
        // GET: Game/Notice
        public ActionResult Index()
        {
            return View();
        }

        /// <summary>
        /// 读取唯一公告（页面进入时调用）。
        /// <para>库里没有记录时返回默认值（空内容 + 默认字号），页面照常可编辑保存。</para>
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetNotice(FormCollection form)
        {
            try
            {
                M_Notice entity = new B_Notice().GetSingleNotice();
                if (entity == null)
                {
                    entity = new M_Notice
                    {
                        ID = 0,
                        TITLE = B_Notice.DefaultTitle,
                        NOTICE = string.Empty,
                        FONTSIZE = NoticeFontSize.Default
                    };
                }

                return Json(new
                {
                    code = 1,
                    msg = string.Empty,
                    data = new
                    {
                        ID = entity.ID,
                        TITLE = entity.TITLE,
                        // 裸文本（字号标记已由 BLL 剥掉），编辑器里不应该看到 [SIZE=nn]
                        NOTICE = entity.NOTICE,
                        FONTSIZE = entity.FONTSIZE
                    }
                });
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.NoticeController), ex);
                return Json(new { code = 0, msg = "公告读取失败，请稍后重试！" });
            }
        }

        /// <summary>
        /// 保存唯一公告：有记录则更新、没有则新增，并删除历史多出来的行（客户端只允许一条公告）。
        /// </summary>
        [AjaxOnly]
        [HttpPost]
        public ActionResult SaveNotice(FormCollection form)
        {
            Msg msg = new Msg(0, "公告保存失败！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(msg);
                if (loginUser.RE_ENABLE != 1)
                {
                    msg.content = "您不具备此权限";
                    return Json(msg);
                }

                // 这里不走 TryUpdateModel：字号为空/非法时模型绑定会把 ModelState 弄脏，
                // 而"字号留空"在业务上等价于"用默认字号"，不是错误。
                int fontSize = form.Q<int>("FONTSIZE");
                if (fontSize == 0) fontSize = NoticeFontSize.Default;
                if (fontSize < NoticeFontSize.Min || fontSize > NoticeFontSize.Max)
                {
                    msg.content = string.Format("字号必须在 {0}-{1} 之间！", NoticeFontSize.Min, NoticeFontSize.Max);
                    return Json(msg);
                }

                string title = form.Q<string>("TITLE");
                string notice = form.Q<string>("NOTICE");

                if (string.IsNullOrWhiteSpace(notice))
                {
                    msg.content = "请填写公告内容！";
                    return Json(msg);
                }
                // 与实体上的 MaxLength(200) 保持一致；NOTICE 列是 varchar(255)，
                // 另加 [SIZE=nn] 前缀后仍然安全，但不要放宽这里的限制。
                if (notice.Length > 200)
                {
                    msg.content = "公告内容长度不能超过200个字符！";
                    return Json(msg);
                }

                M_Notice entity = new M_Notice
                {
                    TITLE = string.IsNullOrWhiteSpace(title) ? B_Notice.DefaultTitle : title,
                    NOTICE = notice,
                    FONTSIZE = fontSize
                };

                msg = new B_Notice().SaveSingleNotice(entity);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.NoticeController), ex);
            }
            return Json(msg);
        }
    }
}
