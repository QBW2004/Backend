using System;

namespace YYT.BLL
{
    /// <summary>
    /// 自定义属性，用于指示如何从DataTable或者DbDataReader中读取类的属性值
    /// </summary>
    public class ColumnNameAttribute : Attribute
    {
        /// <summary>
        /// 类属性对应的列名
        /// </summary>
        public string ColumnName { get; set; }
        /// <summary>
        /// 指示在从DataTable或者DbDataReader中读取类的属性时是否可以忽略这个属性
        /// </summary>
        public bool Ignorable { get; set; }
        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="columnName">类属性对应的列名</param>
        public ColumnNameAttribute(string columnName)
        {
            ColumnName = columnName;
            Ignorable = false;
        }
        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="ignorable">指示在从DataTable或者DbDataReader中读取类的属性时是否可以忽略这个属性</param>
        public ColumnNameAttribute(bool ignorable)
        {
            Ignorable = ignorable;
        }
        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="columnName">类属性对应的列名</param>
        /// <param name="ignorable">指示在从DataTable或者DbDataReader中读取类的属性时是否可以忽略这个属性</param>
        public ColumnNameAttribute(string columnName, bool ignorable)
        {
            ColumnName = columnName;
            Ignorable = ignorable;
        }
    }
}
