using System.ComponentModel;
using System.Runtime.Serialization;

namespace YYT.Entity
{
    /// <summary>
    /// 菜单类
    /// </summary>
    [DataContract]
    public class M_BaseModule
    {
        public M_BaseModule() { }


        /// <summary>
        /// 菜单ID
        /// </summary>
        [DataMember(Name = "ModuleID")]
        public int ModuleID { get; set; }
        /// <summary>
        /// 父级菜单ID
        /// </summary>
        [DataMember(Name = "ParentID")]
        public int ParentID { get; set; }
        /// <summary>
        /// 菜单标题
        /// </summary>
        [DataMember(Name = "Title")]
        public string Title { get; set; }
        /// <summary>
        /// 菜单链接
        /// </summary>
        [DataMember(Name = "Link")]
        public string Link { get; set; }
        /// <summary>
        /// 排序编号
        /// </summary>
        [DataMember(Name = "OrderNo")]
        public int OrderNo { get; set; }
        /// <summary>
        /// 启用状态
        /// <para>0启用</para>
        /// <para>1禁用</para>
        /// </summary>
        [DefaultValue(true)]
        [DataMember(Name = "Nullity")]
        public bool Nullity { get; set; }
        /// <summary>
        /// 是否是菜单
        /// <para>0是</para>
        /// <para>1不是</para>
        /// </summary>
        [DefaultValue(true)]
        [DataMember(Name = "IsMenu")]
        public bool IsMenu { get; set; }
    }

    /// <summary>
    /// 角色菜单类
    /// </summary>
    [DataContract]
    public class M_RoleMenus
    {
        public M_RoleMenus() { }

        /// <summary>
        /// RowIndex
        /// </summary>
        [DataMember(Name = "RowIndex")]
        public int RowIndex{ get; set; }
        /// <summary>
        /// 所属角色
        /// </summary>
        [DataMember(Name = "Roles")]
        public string Roles { get; set; }
        /// <summary>
        /// 菜单ID
        /// </summary>
        [DataMember(Name = "ModuleID")]
        public int ModuleID { get; set; }
        /// <summary>
        /// 父级菜单ID
        /// </summary>
        [DataMember(Name = "ParentID")]
        public int ParentID { get; set; }
        /// <summary>
        /// 菜单标题
        /// </summary>
        [DataMember(Name = "Title")]
        public string Title { get; set; }
        /// <summary>
        /// 菜单链接
        /// </summary>
        [DataMember(Name = "Link")]
        public string Link { get; set; }
        /// <summary>
        /// 排序编号
        /// </summary>
        [DataMember(Name = "OrderNo")]
        public int OrderNo { get; set; }
        /// <summary>
        /// 启用状态
        /// <para>0启用</para>
        /// <para>1禁用</para>
        /// </summary>
        [DefaultValue(true)]
        [DataMember(Name = "Nullity")]
        public bool Nullity { get; set; }
        /// <summary>
        /// 是否是菜单
        /// <para>0是</para>
        /// <para>1不是</para>
        /// </summary>
        [DefaultValue(true)]
        [DataMember(Name = "IsMenu")]
        public bool IsMenu { get; set; }
        /// <summary>
        /// 备注信息
        /// </summary>
        [DefaultValue(true)]
        [DataMember(Name = "Remark")]
        public string Remark { get; set; }
    }
}
