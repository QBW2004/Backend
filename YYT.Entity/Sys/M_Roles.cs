using System.Collections.Generic;
using System.Runtime.Serialization;

namespace YYT.Entity
{
    /// <summary>
    /// 角色类 【easyui tree用数据类】
    /// </summary>
    [DataContract]
    public class M_Roles_TreeDataModel
    {
        public M_Roles_TreeDataModel() { }

        /// <summary>
        /// RoleId
        /// </summary>
        [DataMember(Name = "id")]
        public int id { get; set; }

        /// <summary>
        /// RoleName 
        /// </summary>
        [DataMember(Name = "text")]
        public string text { get; set; }

        /// <summary>
        /// 子节点
        /// </summary>
        [DataMember(Name = "children")]
        public List<M_Roles_TreeDataModel> children { get; set; }

        /// <summary>
        /// 图标
        /// </summary>
        [DataMember(Name = "iconCls")]
        public string iconCls { get; set; }


    }

    /// <summary>
    /// 角色类
    /// </summary>
    [DataContract]
    public class M_Roles
    {
        [DataMember(Name = "RoleID")]
        public int RoleID { get; set; }

        [DataMember(Name = "RoleName")]
        public string RoleName { get; set; }
    }
}
