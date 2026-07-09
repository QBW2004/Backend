using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Web.Security;

namespace YYT.Common
{

    /// <summary>
    /// DES加密/解密类。
    /// </summary>
    public class DESEncrypt
    {
        private static byte[] Keys = { 0x19, 0x15, 0x52, 0x09, 0xEC, 0xBE, 0xCD, 0x66 }; //默认加密钥向量
        private static string DefaultKey = "!y@Y0`_T";
        public DESEncrypt() { }

        #region 获取32位MD5
        /// <summary>
        /// 获取32位MD5
        /// </summary>
        /// <param name="str"></param>
        /// <returns></returns>
        public static string Md5(string str)
        {
            MD5 md5 = MD5.Create();
            // 将字符串转换成字节数组
            byte[] byteOld = Encoding.UTF8.GetBytes(str);
            // 调用加密方法
            byte[] byteNew = md5.ComputeHash(byteOld);
            // 将加密结果转换为字符串
            StringBuilder sb = new StringBuilder();
            foreach (byte b in byteNew)
            {
                // 将字节转换成16进制表示的字符串，
                sb.Append(b.ToString("x2"));
            }
            // 返回加密的字符串
            return sb.ToString();
        }
        #endregion

        #region  生成公钥和私钥
        /// <summary>
        /// 获取公钥和私钥
        /// </summary>
        /// <param name="publicKeys"></param>
        /// <param name="privateKeys"></param>
        public static void GetRSAKeys(out string publicKeys, out string privateKeys)
        {
            RSACryptoServiceProvider rsaProvider = new RSACryptoServiceProvider();
            //生成公钥
            privateKeys = rsaProvider.ToXmlString(true);

            //导出公钥
            RSAParameters rPara = rsaProvider.ExportParameters(false);

            //RSA加密指数 & RSA加密系数
            publicKeys = String.Format("{0}&{1}", BytesToHexString(rPara.Exponent), BytesToHexString(rPara.Modulus));
        }

        /// <summary>
        /// 解密字符串
        /// </summary>
        /// <param name="encrypted_pwd">密码</param>
        /// <param name="privateKyes">私钥</param>
        /// <returns></returns>
        public static string RSADecrypt(string encrypted_pwd, string privateKyes)
        {
            CspParameters RSAParams = new CspParameters();
            RSAParams.Flags = CspProviderFlags.UseMachineKeyStore;
            System.Security.Cryptography.RSACryptoServiceProvider rsaProvider = new RSACryptoServiceProvider(1024, RSAParams);
            //RSACryptoServiceProvider rsaProvider = new RSACryptoServiceProvider();
            //加入私钥
            rsaProvider.FromXmlString(privateKyes);
            //解密字符串
            byte[] result = rsaProvider.Decrypt(HexStringToBytes(encrypted_pwd), false);

            System.Text.ASCIIEncoding enc = new ASCIIEncoding();
            return enc.GetString(result);
        }

        private static string BytesToHexString(byte[] input)
        {
            StringBuilder hexString = new StringBuilder(64);

            for (int i = 0; i < input.Length; i++)
            {
                hexString.Append(String.Format("{0:X2}", input[i]));
            }
            return hexString.ToString();
        }

        public static byte[] HexStringToBytes(string hex)
        {
            if (hex.Length == 0)
            {
                return new byte[] { 0 };
            }

            if (hex.Length % 2 == 1)
            {
                hex = "0" + hex;
            }

            byte[] result = new byte[hex.Length / 2];

            for (int i = 0; i < hex.Length / 2; i++)
            {
                result[i] = byte.Parse(hex.Substring(2 * i, 2), System.Globalization.NumberStyles.AllowHexSpecifier);
            }

            return result;
        }

        #endregion

        #region ========加密========

        /// <summary>
        /// 加密
        /// </summary>
        /// <param name="Text"></param>
        /// <returns></returns>
        public static string Encrypt(string Text)
        {
            return EnCrypString(Text, DefaultKey);
        }

        /// <summary>
        /// 加密字符串
        /// </summary>
        /// <param name="CrpString">待加密字符串</param>
        /// <param name="CrpKey">加密的密钥</param>
        /// <returns></returns>
        public static string EnCrypString(string CrpString, string CrpKey)
        {
            try
            {
                //将需要加密的字符串
                byte[] _byteCrpS = System.Text.ASCIIEncoding.Default.GetBytes(CrpString);

                byte[] _byteCrpKey = Encoding.UTF8.GetBytes(CrpKey.Trim().Substring(0, 8));
                byte[] _byteKeys = Keys;

                MemoryStream ms = new MemoryStream();
                //加密实例
                DESCryptoServiceProvider des = new DESCryptoServiceProvider();
                ICryptoTransform ICryptoTF = des.CreateEncryptor(_byteCrpKey, _byteKeys);
                CryptoStream sStream = new CryptoStream(ms, ICryptoTF, CryptoStreamMode.Write);
                sStream.Write(_byteCrpS, 0, _byteCrpS.Length);
                sStream.FlushFinalBlock();

                return Convert.ToBase64String(ms.ToArray());
            }
            catch (Exception Ex)
            {
                return Ex.Message;
            }

        }

        #endregion

        #region ========解密========


        /// <summary>
        /// 解密
        /// </summary>
        /// <param name="Text"></param>
        /// <returns></returns>
        public static string Decrypt(string Text)
        {
            return DeCrypString(Text, DefaultKey);
        }

        /// <summary>
        /// 解密字符串
        /// </summary>
        /// <param name="_DCrypString">解密字符串</param>
        /// <param name="CrypKey">解密密钥</param>
        /// <returns></returns>
        public static string DeCrypString(string _DCrypString, string CrypKey)
        {
            try
            {
                byte[] _byteCrpKey = System.Text.ASCIIEncoding.ASCII.GetBytes(CrypKey.Trim().Substring(0, 8));
                byte[] _byteKey = Keys;
                byte[] _byteCrypString = Convert.FromBase64String(_DCrypString);

                DESCryptoServiceProvider DES = new DESCryptoServiceProvider();
                MemoryStream ms = new MemoryStream();

                ICryptoTransform Cf = DES.CreateDecryptor(_byteCrpKey, _byteKey);
                CryptoStream cStream = new CryptoStream(ms, Cf, CryptoStreamMode.Write);
                cStream.Write(_byteCrypString, 0, _byteCrypString.Length);
                cStream.FlushFinalBlock();

                return Encoding.Default.GetString(ms.ToArray());
            }
            catch (Exception Ex)
            {
                return Ex.Message;
            }
        }

        #endregion
    }
}
