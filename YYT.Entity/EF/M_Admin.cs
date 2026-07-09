using Newtonsoft.Json;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace YYT.Entity
{
    /// <summary>
    /// 管理员、代理表
    /// </summary>
    [Table("Admin")]
    public class M_Admin
    {
        /// <summary>
        /// ID、账号
        /// </summary>
        [Key]
        [Required]
        [Display(Name = "账号ID", Description = "账号ID"), MinLength(3, ErrorMessage = "长度不足3个字符")]
        public string ID { get; set; }

        /// <summary>
        /// 密码
        /// </summary>
        [Required]
        [Display(Name = "密码", Description = "密码"), MinLength(6, ErrorMessage = "长度不足6个字符")]
        public string PWD { get; set; }

        /// <summary>
        /// 确认密码（仅用于前端验证，不映射到数据库）
        /// </summary>
        [NotMapped]
        [Compare("PWD", ErrorMessage = "两次输入的密码不一致")]
        public string RE_PWD { get; set; }

        /// <summary>
        /// 代理层级标志（仅用于前端，不映射到数据库）
        /// 0=直属代理 1=总代理
        /// </summary>
        [NotMapped]
        public int? FLAG { get; set; }

        /// <summary>
        /// 代理层级
        /// </summary>
        public int? PRIV { get; set; }

        /// <summary>
        /// 代理名（邀请码）
        /// </summary>
        public string AGENCY { get; set; }

        /// <summary>
        /// 拥有金币数
        /// </summary>
        public long? COINS { get; set; }

        /// <summary>
        /// 总充值数
        /// </summary>
        public long? RECHARGE { get; set; }

        /// <summary>
        /// 总兑换数
        /// </summary>
        public long? EXCHANGE { get; set; }

        /// <summary>
        /// 购币数
        /// </summary>
        public long? COINS_BUY { get; set; }

        /// <summary>
        /// 总兑币数
        /// </summary>
        public long? COINS_BACK { get; set; }

        /// <summary>
        /// 启用充值
        /// </summary>
        public long? RE_ENABLE { get; set; }

        /// <summary>
        /// 限制最大代理数（暂不用）
        /// </summary>
        public long? AGENCY_LIMIT { get; set; }

        /// <summary>
        /// 是否有冻结权限
        /// </summary>
        public long? IsFrozen { get; set; }

        /// <summary>
        /// 鱼机控制权限
        /// </summary>
        public long? IsProbability { get; set; }

        /// <summary>
        /// 注机控制权限 0无 1有
        /// </summary>
        public long? IsKill { get; set; }
        
        /// <summary>
        /// 牌机控制权限 0无 1有
        /// </summary>
        public long? IsRelease { get; set; }

        /// <summary>
        /// 是否有踢人权限
        /// </summary>
        public long? IsKicking { get; set; }

        /// <summary>
        /// 是否有删除权限
        /// </summary>
        public long? IsDelete { get; set; }

        /// <summary>
        /// 是否有上下分权限 0无 1有
        /// </summary>
        public long? IsUpDown { get; set; }

        /// <summary>
        /// 踢人范围 1=仅直属 2=全部下级
        /// </summary>
        public long? KickScope { get; set; }

        /// <summary>
        /// 是否有赠送权限 0无 1有
        /// </summary>
        public long? IsGift { get; set; }

        /// <summary>
        /// 是否允许开代理 0不允许 1允许
        /// </summary>
        public long? IsCreateAgent { get; set; }

        /// <summary>
        /// 是否可查看密码 0不可 1可以
        /// </summary>
        public long? IsViewPwd { get; set; }

        /// <summary>
        /// 是否可修改密码 0不可 1可以
        /// </summary>
        public long? IsModifyPwd { get; set; }

        /// <summary>
        /// 是否可重置保险密码 0不可 1可以
        /// </summary>
        public long? IsResetSafePwd { get; set; }

        /// <summary>
        /// 是否可查看保险柜密码 0不可 1可以
        /// </summary>
        public long? IsViewSafePwd { get; set; }

        /// <summary>
        /// 是否可修改保险柜密码 0不可 1可以
        /// </summary>
        public long? IsModifySafePwd { get; set; }

        /// <summary>
        /// 管理范围 1=仅直属 2=全部下级
        /// </summary>
        public long? ManageScope { get; set; }

        /// <summary>
        /// 邀请码 4-8位纯数字
        /// </summary>
        [StringLength(8)]
        public string InviteCode { get; set; }

        /// <summary>
        /// 佣金比例 百分比 0.01%-100%
        /// </summary>
        public decimal? CommissionRate { get; set; }

        /// <summary>
        /// 创建时间
        /// </summary>
        public DateTime? CreateTime { get; set; }

        /// <summary>
        /// 更新时间
        /// </summary>
        public DateTime? UpdateTime { get; set; }


        public string CustomerServiceUrl { get; set; }
        /// <summary>
        /// 职务
        /// </summary>
        public string Title
        {
            get
            {
                return AdminTypeTranslater.TitleTranlate(this.PRIV_Translate());
            }
        }

        /// <summary>
        /// 代理盈利
        /// </summary>
        [NotMapped]
        public long? Profit { get; set; }

        /// <summary>
        /// 代理总余额
        /// </summary>
        [NotMapped]
        public long? PlayerBalance { get; set; }
        
        /// <summary>
        /// 玩家总余额
        /// </summary>
        [NotMapped]
        public long? UserBalance { get; set; }

        /// <summary>
        /// 前端代理树分组序号，用于同组行背景色。
        /// </summary>
        [NotMapped]
        public int AgencyGroupIndex { get; set; }

        /// <summary>
        /// 前端代理树深度，用于序号列折叠子级。
        /// </summary>
        [NotMapped]
        public int AgencyTreeDepth { get; set; }

        /// <summary>
        /// 前端标记该代理是否还有下级代理。
        /// </summary>
        [NotMapped]
        public bool HasChildAgency { get; set; }

        /// <summary>
        /// 前端标记是否可继续创建下级代理。
        /// </summary>
        [NotMapped]
        public bool CanCreateChildAgent { get; set; }

        public EAdminType PRIV_Translate()
        {
            switch (this.PRIV)
            {
                case 0:
                    return EAdminType.Zero;
                case 1:
                    return EAdminType.One;
                case 9:
                    return EAdminType.Nine;
                default:
                    return EAdminType.General;
            }
        }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(this);
        }

        public M_LoginUser ToLoginUser()
        {
            return new M_LoginUser
            {
                Accounts = this.ID,
                IsDel = 0,
                LoginResult = 0,
                LoginMsg = "用户名或密码错误！",
                Remark = string.Empty,
                Roles = this.PRIV.HasValue ? this.PRIV.Value.ToString() : "",
                UserID = -1,
                UserName = this.ID,
                UserType = this.PRIV.HasValue ? this.PRIV.Value : 0,
                UserPriv = this.PRIV,
                RE_ENABLE = this.RE_ENABLE,
                IsFrozen = this.IsFrozen,
                IsProbability = this.IsProbability,
                IsKill = this.IsKill,
                IsRelease = this.IsRelease, 
                IsKicking = this.IsKicking,
                IsDelete = this.IsDelete,
                IsUpDown = this.IsUpDown,
                KickScope = this.KickScope,
                IsGift = this.IsGift,
                IsCreateAgent = this.IsCreateAgent,
                IsViewPwd = this.IsViewPwd,
                IsModifyPwd = this.IsModifyPwd,
                IsResetSafePwd = this.IsResetSafePwd,
                IsViewSafePwd = this.IsViewSafePwd,
                IsModifySafePwd = this.IsModifySafePwd,
                ManageScope = this.ManageScope,
                InviteCode = this.InviteCode,
                CommissionRate = this.CommissionRate
            };
        }
    }

    public class M_Agency
    {
        public EAdminType AdminType { get; set; }
        public string ID { get; set; }
        public int Priv { get; set; }
        public string Agency { get; set; }
    }
}
