using System;
using System.Runtime.Serialization;

namespace YYT.Entity
{
    /// <summary>
    /// 代理/推广登录信息
    /// </summary>
    [DataContract]
    public class M_LoginUser
    {
        public M_LoginUser() { }

        /// <summary>
        /// 登录结果
        /// <para>1成功</para>
        /// <para>0失败</para>
        /// </summary>
        [DataMember(Name = "LoginResult")]
        public int LoginResult { get; set; }
        /// <summary>
        /// 登录结果消息
        /// </summary>
        [DataMember(Name = "LoginMsg")]
        public string LoginMsg { get; set; }
        /// <summary>
        ///  标识ID
        /// </summary>
        [DataMember(Name = "UserID")]
        public int UserID { get; set; }
        /// <summary>
        ///  帐号
        /// </summary>
        [DataMember(Name = "Accounts")]
        public string Accounts { get; set; }
        /// <summary>
        /// 名字
        /// </summary>
        [DataMember(Name = "UserName")]
        public string UserName { get; set; }
        /// <summary>
        ///  状态
        ///  <para>0正常</para>
        ///  <para>1标识删除</para>
        /// </summary>
        [DataMember(Name = "IsDel")]
        public int IsDel { get; set; }
        /// <summary>
        ///  备注信息
        /// </summary>
        [DataMember(Name = "Remark")]
        public string Remark { get; set; }
        /// <summary>
        ///  角色 （用逗号分隔的角色ID）
        /// </summary>
        [DataMember(Name = "Roles")]
        public string Roles { get; set; }
        /// <summary>
        ///  用户类型
        ///  <para>1表示站点管理</para>
        /// </summary>
        [DataMember(Name = "UserType")]
        public int UserType { get; set; }
        /// <summary>
        /// 是否启用
        /// </summary>
        [DataMember(Name = "RE_ENABLE")]
        public long? RE_ENABLE { get; set; }

        [DataMember(Name = "IsUpDown")]
        public long? IsUpDown { get; set; }

        [DataMember(Name = "KickScope")]
        public long? KickScope { get; set; }

        [DataMember(Name = "IsGift")]
        public long? IsGift { get; set; }

        [DataMember(Name = "IsCreateAgent")]
        public long? IsCreateAgent { get; set; }

        [DataMember(Name = "IsViewPwd")]
        public long? IsViewPwd { get; set; }

        [DataMember(Name = "IsModifyPwd")]
        public long? IsModifyPwd { get; set; }

        [DataMember(Name = "IsResetSafePwd")]
        public long? IsResetSafePwd { get; set; }

        [DataMember(Name = "ManageScope")]
        public long? ManageScope { get; set; }

        [DataMember(Name = "InviteCode")]
        public string InviteCode { get; set; }

        [DataMember(Name = "CommissionRate")]
        public decimal? CommissionRate { get; set; }

        [DataMember(Name = "IsKill")]
        public long? IsKill { get; set; }

        [DataMember(Name = "IsRelease")]
        public long? IsRelease { get; set; }

        [DataMember(Name = "IsViewSafePwd")]
        public long? IsViewSafePwd { get; set; }

        [DataMember(Name = "IsModifySafePwd")]
        public long? IsModifySafePwd { get; set; }


        // ======================================================================
        /// <summary>
        /// 代理层级（第几级代理）
        /// </summary>
        [DataMember(Name = "UserPriv")]
        public int? UserPriv { get; set; }

        [DataMember(Name = "IsFrozen")]
        public long? IsFrozen { get; set; }
        [DataMember(Name = "IsProbability")]
        public long? IsProbability { get; set; }
        [DataMember(Name = "IsKicking")]
        public long? IsKicking { get; set; }
        [DataMember(Name = "IsDelete")]
        public long? IsDelete { get; set; }
        public M_Admin ToAdminType()
        {
            return new M_Admin
            {
                ID = this.Accounts,
                PRIV = this.UserPriv,
                AGENCY = this.Accounts,
                IsFrozen = this.IsFrozen,
                IsProbability = this.IsProbability,
                IsKill = this.IsKill,              // 新增
                IsRelease = this.IsRelease,        // 新增
                IsKicking = this.IsKicking,
                IsDelete = this.IsDelete,
                IsUpDown = this.IsUpDown,
                KickScope = this.KickScope,
                IsGift = this.IsGift,
                IsCreateAgent = this.IsCreateAgent,
                IsViewPwd = this.IsViewPwd,
                IsModifyPwd = this.IsModifyPwd,
                IsResetSafePwd = this.IsResetSafePwd,
                IsViewSafePwd = this.IsViewSafePwd,        // 新增
                IsModifySafePwd = this.IsModifySafePwd,    // 新增
                ManageScope = this.ManageScope,
                InviteCode = this.InviteCode,
                CommissionRate = this.CommissionRate
            };
        }

        /// <summary>
        /// 序列化JSON字符串
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            return Newtonsoft.Json.JsonConvert.SerializeObject(this);
        }

        public static M_LoginUser GetLoginModel(string json)
        {
            if (String.IsNullOrWhiteSpace(json))
                return null;
            return Newtonsoft.Json.JsonConvert.DeserializeObject<M_LoginUser>(json);
        }
    }

    /// <summary>
    /// 后台管理用户类
    /// </summary>
    [DataContract]
    public class M_MgrUsers
    {
        public M_MgrUsers() { }

        [DataMember(Name = "RowIndex")]
        public int RowIndex { get; set; }
        /// <summary>
        ///  标识ID
        /// </summary>
        [DataMember(Name = "UserID")]
        public int UserID { get; set; }
        /// <summary>
        ///  帐号
        /// </summary>
        [DataMember(Name = "Accounts")]
        public string Accounts { get; set; }
        /// <summary>
        /// 名字
        /// </summary>
        [DataMember(Name = "UserName")]
        public string UserName { get; set; }
        /// <summary>
        ///  状态
        ///  <para>0正常</para>
        ///  <para>1标识删除</para>
        /// </summary>
        [DataMember(Name = "IsDel")]
        public int IsDel { get; set; }
        /// <summary>
        ///  备注信息
        /// </summary>
        [DataMember(Name = "Remark")]
        public string Remark { get; set; }
        /// <summary>
        ///  角色 （用逗号分隔的角色ID）
        /// </summary>
        [DataMember(Name = "Roles")]
        public string Roles { get; set; }
        /// <summary>
        ///  角色 （用逗号分隔的角色ID）
        /// </summary>
        [DataMember(Name = "RoleName")]
        public string RoleName { get; set; }
    }
}
