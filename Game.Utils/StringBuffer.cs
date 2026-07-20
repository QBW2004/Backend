using System;
using System.Text;

namespace Game.Utils
{
    /// <summary>
    /// 字符串拼接工具类，支持 += 运算符
    /// </summary>
    public class StringBuffer
    {
        private readonly StringBuilder _sb = new StringBuilder();

        public StringBuffer()
        {
        }

        public StringBuffer(string value)
        {
            _sb.Append(value);
        }

        public int Length
        {
            get { return _sb.Length; }
        }

        public static StringBuffer operator +(StringBuffer buffer, string value)
        {
            buffer._sb.Append(value);
            return buffer;
        }

        public static StringBuffer operator +(StringBuffer buffer, int value)
        {
            buffer._sb.Append(value);
            return buffer;
        }

        public static StringBuffer operator +(StringBuffer buffer, long value)
        {
            buffer._sb.Append(value);
            return buffer;
        }

        public override string ToString()
        {
            return _sb.ToString();
        }
    }
}
