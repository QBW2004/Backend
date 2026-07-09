using System.Runtime.Serialization;

namespace YYT.Entity
{
    [DataContract]
    public class M_WeekRangeData
    {
        /// <summary>
        /// 周索引
        /// </summary>
        [DataMember(Name = "WeekIndex")]
        public int WeekIndex { get; set; }

        /// <summary>
        /// 显示的文本
        /// </summary>
        [DataMember(Name = "WeekText")]
        public string WeekText { get; set; }

        /// <summary>
        /// 周范围值
        /// </summary>
        [DataMember(Name = "WeekVal")]
        public string WeekVal { get; set; }

        /// <summary>
        /// 开始日期
        /// </summary>
        [DataMember(Name = "StartDate")]
        public string StartDate { get; set; }

        /// <summary>
        /// 结束日期
        /// </summary>
        [DataMember(Name = "EndDate")]
        public string EndDate { get; set; }

        /// <summary>
        /// 当前所在周
        /// </summary>
        [DataMember(Name = "NowWeek")]
        public int NowWeek { get; set; }
    }
}
