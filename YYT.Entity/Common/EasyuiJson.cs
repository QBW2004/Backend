using System.Collections.Generic;
using System.Runtime.Serialization;

namespace YYT.Entity
{
    [DataContract]
    public class M_EasyuiGridData<T> where T : new()
    {
        public M_EasyuiGridData()
        {
            rows = new List<T>();
        }

        [DataMember(Name = "total")]
        public int total { get; set; }

        [DataMember(Name = "rows")]
        public List<T> rows { get; set; }

        [DataMember(Name = "footer")]
        public List<T> footer { get; set; }
    }

    [DataContract]
    public class M_EasyuiGridData_II<T, K>
        where T : new()
        where K : new()
    {
        public M_EasyuiGridData_II()
        {
            rows = new List<T>();
            footer = new List<K>();
        }

        [DataMember(Name = "total")]
        public int total { get; set; }

        [DataMember(Name = "rows")]
        public List<T> rows { get; set; }
        [DataMember(Name = "footer")]
        public List<K> footer { get; set; }
    }



    [DataContract]
    public class M_EasyuiComboData
    {
        [DataMember(Name="val")]
        public int val { get; set; }
        [DataMember(Name="text")]
        public string text { get; set; }
    }
}
