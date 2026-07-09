using System;
using System.Data;

namespace YYT.Entity
{
    [AttributeUsage(AttributeTargets.Property, AllowMultiple = true)]
    public class DatabaseMapAttribute : Attribute
    {
        /// <summary>
        /// 对应数据字段名称
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// 字段类型
        /// </summary>
        public DbType dbType { get; set; }

        /// <summary>
        /// 字段长度
        /// </summary>
        public int Length { get; set; }

        public DatabaseMapAttribute() { }


    }
}
