using System;

namespace YYT.Entity
{
    [AttributeUsage(AttributeTargets.Property, AllowMultiple = true)]
    public sealed class CheckAttribute : Attribute
    {
        /// <summary>
        /// 字段类型
        /// </summary>
        public Type FieldType { get; set; }

        /// <summary>
        /// 描述
        /// </summary>
        public string Comment { get; set; }

        /// <summary>
        /// 是否是必须
        /// </summary>
        public bool Required { get; set; }

        /// <summary>
        /// 默认值
        /// </summary>
        public object DefaultVal { get; set; }

        /// <summary>
        /// 最小值
        /// </summary>
        public object MinVal { get; set; }

        /// <summary>
        /// 最大值
        /// </summary>
        public object MaxVal { get; set; }

        public CheckAttribute() { }
    }

}
