using YYT.Common;
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Security.Cryptography;
using System.Web.Mvc;

namespace YYT.Web.Controllers
{
    /// <summary>
    /// 验证码控制器
    /// </summary>
    public class ValidatorController : Controller
    {
        public FileResult ValidateImage()
        {

            string randomcode = WebHelper.RandomStr(4, true);
            //验证码存入Session中
            WebHelper.WriteSession(ConfigHelper.Get("ValideCodeKey"), DESEncrypt.Encrypt(randomcode));

            return File(this.CreateImage(80, 32, randomcode), "image/png");
        }

        private static Bitmap charbmp = new Bitmap(40, 40);
        private static Matrix m = new Matrix();
        private static byte[] randb = new byte[4];
        private static Color[] randColor = {
                                               Color.Black,
                                               Color.BurlyWood,
                                               Color.DarkBlue,
                                               Color.DeepSkyBlue,
                                               Color.DeepPink,
                                               Color.Indigo,
                                               Color.Magenta,
                                               Color.MediumBlue,
                                               Color.MediumSlateBlue,
                                               Color.Navy,
                                               Color.OliveDrab,
                                               Color.Orchid,
                                               Color.Sienna,
                                               Color.SlateGray,
                                               Color.SteelBlue,
                                               Color.Tomato
                                           };
        private static RNGCryptoServiceProvider rand = new RNGCryptoServiceProvider();
        private static Font[] fonts = {
                            new Font(new FontFamily("Times New Roman"), 16 + Next(3), FontStyle.Regular),
                            new Font(new FontFamily("Georgia"), 16 + Next(3), FontStyle.Regular),
                            new Font(new FontFamily("Arial"), 16 + Next(3), FontStyle.Regular),
                            new Font(new FontFamily("Comic Sans MS"), 16 + Next(3), FontStyle.Regular),
                            new Font(new FontFamily("Verdana"), 16 + Next(3), FontStyle.Regular)
                        };

        /// <summary>
        /// 获得下一个随机数
        /// </summary>
        /// <param name="max">最大值</param>
        /// <returns></returns>
        private static int Next(int max)
        {
            rand.GetBytes(randb);
            int value = BitConverter.ToInt32(randb, 0);
            value = value % (max + 1);
            if (value < 0)
                value = -value;
            return value;
        }

        /// <summary>
        /// 获得下一个随机数
        /// </summary>
        /// <param name="min">最小值</param>
        /// <param name="max">最大值</param>
        /// <returns></returns>
        private static int Next(int min, int max)
        {
            int value = Next(max - min) + min;
            return value;
        }

        /// <summary>
        /// 创建随机码图片
        /// </summary>
        ///  <param  name="width">宽</param>
        ///  <param  name="height">高</param>
        ///  <param  name="randomcode">随机码</param>
        /// <returns></returns>
        private byte[] CreateImage(int width, int height, string randomcode)
        {
            Bitmap bitmap = new Bitmap(width, height, PixelFormat.Format32bppArgb);

            Graphics g = Graphics.FromImage(bitmap);
            g.SmoothingMode = SmoothingMode.HighSpeed;
            g.Clear(Color.White);
            
            //随机笔刷
            SolidBrush drawBrush = new SolidBrush(randColor[Next(randColor.Length - 1)]);
            for (int i = 0; i < Next(8, 20); i++)
            {
                //int fixedNumber = 60;
                Pen linePen = new Pen(randColor[Next(randColor.Length - 1)], Next(1, 3));
                g.DrawArc(linePen, Next(20) - 10, Next(20) - 10, Next(width) + 20, Next(height) + 20, Next(-100, 100), Next(-200, 200));
            }

            Graphics charg = Graphics.FromImage(charbmp);

            float charx = -18;
            for (int i = 0; i < randomcode.Length; i++)
            {
                m.Reset();
                m.RotateAt(Next(45) - 25, new PointF(10,10));

                charg.Clear(Color.Transparent);
                charg.Transform = m;
                //定义前景色为黑色
                drawBrush.Color = randColor[Next(randColor.Length - 1)];

                //验证码画入图片
                charx = charx + 18 + Next(5, 12);
                PointF drawPoint = new PointF(charx, 2.0F);
                charg.DrawString(randomcode[i].ToString(), fonts[Next(fonts.Length - 1)], drawBrush, new PointF(0, 0));

                charg.ResetTransform();
                
                g.DrawImage(charbmp, new Point(i*20,Next(4)));
            }
            drawBrush.Dispose();
            g.Dispose();
            //生成图片
            MemoryStream ms = new MemoryStream();
            bitmap.Save(ms, ImageFormat.Png);

            bitmap.Dispose();

            return ms.ToArray();
        }
    }
}
