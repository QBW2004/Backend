using System;
using System.IO;
using System.Net;
using System.Runtime.InteropServices;
using System.Text;

namespace YYT.Common
{
    /// <summary>
    /// 网络帮助类
    /// </summary>
    public class NetHelper
    {

        #region Http请求
        /// <summary>
        /// 通过POST请求数据
        /// </summary>
        /// <param name="url"></param>
        /// <returns></returns>
        public static string HttpPost(string url)
        {
            WebRequest hr = HttpWebRequest.Create(url);
            hr.ContentType = "application/x-www-form-urlencoded";
            hr.Method = "POST";

            WebResponse response = hr.GetResponse();
            StreamReader reader = new StreamReader(response.GetResponseStream(), Encoding.GetEncoding("utf-8"));
            string result = reader.ReadToEnd();

            reader.Close();
            response.Close();

            return result;
        }
        public static string HttpPost(string url, string postData)
        {
            try
            {
                //创建post请求
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
                request.Method = "POST";
                request.ContentType = "application/x-www-form-urlencoded";
                request.Timeout = 60 * 1000;//一分钟超时
                byte[] data = Encoding.UTF8.GetBytes(postData);
                request.ContentLength = data.Length;

                //发送post的请求
                Stream writer = request.GetRequestStream();
                writer.Write(data, 0, data.Length);
                writer.Close();

                //接受返回来的数据
                HttpWebResponse response = (HttpWebResponse)request.GetResponse();
                Stream stream = response.GetResponseStream();
                StreamReader reader = new StreamReader(stream, Encoding.UTF8);
                string value = reader.ReadToEnd();

                reader.Close();
                stream.Close();
                response.Close();

                return value;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// 通过GET请求数据
        /// </summary>
        /// <param name="url"></param>
        /// <returns></returns>
        public static string HttpGet(string url)
        {
            try
            {
                WebRequest request = HttpWebRequest.Create(url);
                request.Method = "GET";

                WebResponse response = request.GetResponse();
                StreamReader reader = new StreamReader(response.GetResponseStream(), Encoding.GetEncoding("UTF-8"));
                var result = reader.ReadToEnd();

                reader.Close();
                response.Close();

                return result;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        #endregion


        #region Struct
        /// <summary>
        /// byte数组转结构体
        /// </summary>
        /// <param name="bytes">byte数组</param>
        /// <param name="type">结构体类型</param>
        /// <returns>转换后的结构体</returns>
        public static object BytesToStruct(byte[] bytes, Type type)
        {
            //得到结构体的大小
            int size = Marshal.SizeOf(type);
            //byte数组长度小于结构体的大小
            if (size > bytes.Length)
                //返回空
                return null;
            //分配结构体大小的内存空间
            IntPtr structPtr = Marshal.AllocHGlobal(size);
            //将byte数组拷到分配好的内存空间
            Marshal.Copy(bytes, 0, structPtr, size);
            //将内存空间转换为目标结构体
            object obj = Marshal.PtrToStructure(structPtr, type);
            //释放内存空间
            Marshal.FreeHGlobal(structPtr);
            //返回结构体
            return obj;
        }
        #endregion
    }

    /// <summary>
    /// 字节序转换
    /// </summary>
    public static class Endian
    {
        public static short SwapInt16(this byte[] bytes)
        {
            return SwapInt16(BitConverter.ToInt16(bytes, 0));
        }
        public static ushort SwapUInt16(this byte[] bytes)
        {
            return SwapUInt16(BitConverter.ToUInt16(bytes, 0));
        }
        public static int SwapInt32(this byte[] bytes)
        {
            return System.Net.IPAddress.NetworkToHostOrder(BitConverter.ToInt32(bytes, 0));
        }
        public static uint SwapUInt32(this byte[] bytes)
        {
            return SwapUInt32(BitConverter.ToUInt32(bytes, 0));
        }
        public static long SwapInt64(this byte[] bytes)
        {
            return System.Net.IPAddress.NetworkToHostOrder(BitConverter.ToInt64(bytes, 0));
        }

        public static short SwapInt16(this short n)
        {
            return (short)(((n & 0xff) << 8) | ((n >> 8) & 0xff));
        }
        public static ushort SwapUInt16(this ushort n)
        {
            return (ushort)(((n & 0xff) << 8) | ((n >> 8) & 0xff));
        }

        public static int SwapInt32(this int n)
        {
            return (int)(((SwapInt16((short)n) & 0xffff) << 0x10) | (SwapInt16((short)(n >> 0x10)) & 0xffff));
        }

        public static uint SwapUInt32(this uint n)
        {
            return (uint)(((SwapUInt16((ushort)n) & 0xffff) << 0x10) | (SwapUInt16((ushort)(n >> 0x10)) & 0xffff));
        }

        public static long SwapInt64(this long n)
        {
            return (long)(((SwapInt32((int)n) & 0xffffffffL) << 0x20) | (SwapInt32((int)(n >> 0x20)) & 0xffffffffL));
        }

        public static ulong SwapUInt64(this ulong n)
        {
            return (ulong)(((SwapUInt32((uint)n) & 0xffffffffL) << 0x20) | (SwapUInt32((uint)(n >> 0x20)) & 0xffffffffL));
        }
    }


    /// <summary>
    /// 结构体的转换
    /// </summary>
    public static class ConvertToStruct
    {
        /// <summary>
        /// 结构体转byte数组
        /// </summary>
        /// <param name="structObj">要转换的结构体</param>
        /// <returns>转换后的byte数组</returns>
        public static byte[] StructToBytes(this object structObj)
        {
            //得到结构体的大小
            int size = Marshal.SizeOf(structObj);
            //创建byte数组
            byte[] bytes = new byte[size];
            //分配结构体大小的内存空间
            IntPtr structPtr = Marshal.AllocHGlobal(size);
            //将结构体拷到分配好的内存空间
            Marshal.StructureToPtr(structObj, structPtr, false);
            //从内存空间拷到byte数组
            Marshal.Copy(structPtr, bytes, 0, size);
            //释放内存空间
            Marshal.FreeHGlobal(structPtr);
            //返回byte数组
            return bytes;
        }
        /// <summary>
        /// byte数组转结构体
        /// </summary>
        /// <param name="bytes">byte数组</param>
        /// <param name="type">结构体类型</param>
        /// <returns>转换后的结构体</returns>
        public static dynamic BytesToStuct(this byte[] bytes, Type type)
        {
            //得到结构体的大小
            int size = Marshal.SizeOf(type);
            //byte数组长度小于结构体的大小
            if (size > bytes.Length)
            {
                //返回空
                return null;
            }
            //分配结构体大小的内存空间
            IntPtr structPtr = Marshal.AllocHGlobal(size);
            //将byte数组拷到分配好的内存空间
            Marshal.Copy(bytes, 0, structPtr, size);
            //将内存空间转换为目标结构体
            object obj = Marshal.PtrToStructure(structPtr, type);
            //释放内存空间
            Marshal.FreeHGlobal(structPtr);
            //返回结构体
            return Convert.ChangeType(obj, type);
        }
        /// <summary>
        /// 获取除结构体，剩余字节数组
        /// </summary>
        /// <param name="_bytes"></param>
        /// <param name="_type"></param>
        /// <returns></returns>
        public static byte[] GetDataCell(this byte[] _bytes, Type _type)
        {
            byte[] Rebyte = new byte[_bytes.Length - Marshal.SizeOf(_type)];
            Buffer.BlockCopy(_bytes, Marshal.SizeOf(_type), Rebyte, 0, Rebyte.Length);
            return Rebyte;
        }
    }
}
