using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace YYT.Common
{
    public static class StringHelper
    {
        public static string ToGB2312(this string str)
        {
            byte[] array = Encoding.GetEncoding("GB2312").GetBytes(str);
            using (MemoryStream stream = new MemoryStream(array))
            {
                using (StreamReader reader = new StreamReader(stream))
                {
                    return reader.ReadToEnd();
                }
            }
        }
    }
}
