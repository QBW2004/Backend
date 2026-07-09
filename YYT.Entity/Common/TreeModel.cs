using System.Collections.Generic;
using System.Runtime.Serialization;

namespace YYT.Entity
{
    [DataContract]
    public class M_AgentTreeModel
    {
        [DataMember(Name = "id")]
        public string id { get; set; }

        [DataMember(Name = "AgentName")]
        public string AgentName { get; set; }

        [DataMember(Name = "parentId")]
        public string parentId { get; set; }

        [DataMember(Name = "state")]
        public string state { get; set; }

        [DataMember(Name = "UserID")]
        public int UserID { get; set; }

        [DataMember(Name = "CDKey")]
        public string CDKey { get; set; }

        [DataMember(Name = "Remark")]
        public string Remark { get; set; }

        [DataMember(Name = "IsDel")]
        public int IsDel { get; set; }

    }

    [DataContract]
    public class M_MenuTreeModel
    {
        [DataMember(Name = "ModuleID")]
        public int ModuleID { get; set; }

        [DataMember(Name = "ParentID")]
        public int ParentID { get; set; }

        [DataMember(Name = "Title")]
        public string Title { get; set; }

        [DataMember(Name = "Link")]
        public string Link { get; set; }

        [DataMember(Name = "Remark")]
        public string Remark { get; set; }
    }

    public class M_TreeModel
    {
        public int id { get; set; }
        public string text { get; set; }
        public string iconCls { get; set; }
        public string @checked { get; set; }
        public string state { get; set; }
        public object attributes { get; set; }
        public List<M_TreeModel> children { get; set; }
    }


}
