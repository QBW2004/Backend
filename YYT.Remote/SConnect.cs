using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Pipes;
using System.Linq;
using System.Security.Principal;
using System.Text;
using System.Web;
using System.Xml;
using YYT.Common;
using YYT.Entity;

namespace YYT.Remote
{
    public class SConnect
    {
        private readonly string MSG_DEF_KEY = "SRV_MSG";
        private readonly string SRV_DATA = "SRV_DATA";
        private readonly string CACHE_KEY = "SRV_XML_KEY";

        public NamedPipeClientStream PipeClient { get; private set; }
        private XmlDocument xmlDoc { get; set; }

        public string ServerName { get; set; }
        public string PipeName { get; set; }

        public SConnect()
        {
            this.Init();
        }

        private void Init()
        {
            // 初始化管道
            this.InitPipe();
            // 初始化XML参数
            this.InitXmlDoc();
        }
        void InitPipe()
        {
            // 初始化管道
            this.ServerName = ConfigHelper.Get("serverName");
            this.PipeName = ConfigHelper.Get("pipeName");

            this.PipeClient = new NamedPipeClientStream(this.ServerName, this.PipeName, PipeDirection.InOut, PipeOptions.Asynchronous, TokenImpersonationLevel.None);

            if (this.PipeClient.CanTimeout)
            {
                this.PipeClient.ReadTimeout = 10000;
                this.PipeClient.WriteTimeout = 10000;
            }
            // 初始化连接
            this.Connect();
        }
        private void InitXmlDoc()
        {
            XmlDocument xml = CacheHelper.Get<XmlDocument>(CACHE_KEY);
            if (xml == null)
            {
                xml = new XmlDocument();
                if (HttpContext.Current != null)
                    xml.Load(HttpContext.Current.Server.MapPath("~/Config/MsgDefine.config"));
                else
                    xml.Load(AppDomain.CurrentDomain.BaseDirectory + "/Config/MsgDefine.config");

                CacheHelper.Add<XmlDocument>(CACHE_KEY, xml);
            }
            this.xmlDoc = xml;
        }
        public Msg GetSrvMsg(string key)
        {
            if (string.IsNullOrWhiteSpace(key))
                return new Msg { code = 0, datas = key, content = "服务没有任何消息！" };

            XmlNode node = null;
            try
            {
                node = this.xmlDoc.GetXmlNodeByXpath($"/root/rows[@key=\"{MSG_DEF_KEY}\"]/row[@key=\"{key}\"]");
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Remote.SConnect), "\n服务器内容：" + key + "\n服务器消息格式不正确！\n" + ex.Message);
            }
            if (node == null)
                return null;

            int val = 0;
            if (node.GetAttributeVal("value") != null && int.TryParse(node.GetAttributeVal("value"), out val))
            {
                return new Msg { code = val, datas = key, content = $"{node.GetAttributeVal("text")}({key})" };
            }

            return new Msg { code = 0, datas = key, content = "服务器消息翻译配置未读取到！" };
        }

        private string SetParamsPosOperate(string dataStr, int length)
        {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < length; i++)
            {
                sb.AppendFormat("{0}{1}{2}", "{", i, "}");
            }
            return string.Format(dataStr, sb);
        }
        private string BuildCommand(EScMsgType eScMsgType, object[] para)
        {
            string rowKey = Enum.GetName(typeof(EScMsgType), eScMsgType);
            string dataStr = this.xmlDoc.GetXmlAttributeVal($"/root/rows[@key=\"{SRV_DATA}\"]/row[@key=\"{rowKey}\"]", "value");
            string cmd = string.Empty;
            if (para != null)
            {
                string tmpCmd = SetParamsPosOperate(dataStr, para.Length);
                cmd = string.Format(tmpCmd, para);
            }
            else
            {
                cmd = dataStr;
            }

            return cmd;
        }
        public string SendNotTranlation(EScMsgType eScMsgType, params object[] para)
        {
            StreamWriter sw = null;
            StreamReader sr = null;
            string srv_code = string.Empty;

            try
            {
                // 消息组装
                string cmd = BuildCommand(eScMsgType, para);
                if (string.IsNullOrWhiteSpace(cmd))
                    return srv_code;

                if (this.PipeClient.IsConnected == false)
                    this.InitPipe();

                // 发送数据
                sw = new StreamWriter(this.PipeClient);
                sw.AutoFlush = true;
                List<char> charList = cmd.ToList<char>();
                charList.Add('\0');
                sw.WriteLine(charList.ToArray<char>());
                LogHelper.WriteLog(typeof(YYT.Remote.SConnect), $"指令内容：\n{cmd}");
                // 解锁用户不用读
                sr = new StreamReader(this.PipeClient);
                srv_code = sr.ReadLine();
            }
            catch (Exception ex)
            {
                srv_code = "数据发送失败！" + ex.Message;
            }
            finally
            {
                try
                {
                    if (sw != null)
                    {
                        sw.Close();
                        sw.Dispose();
                    }
                }
                catch { }
                try
                {
                    if (sr != null)
                    {
                        sr.Close();
                        sr.Dispose();
                    }
                }
                catch { }

                // 服务器消息下发后已经关闭了管道，所以客户端也直接关闭并释放
                this.Close();
            }
            return srv_code;
        }
        public Msg SendReadString(EScMsgType eScMsgType, params object[] para)
        {
            Msg msg = new Msg(0, "服务器内部错误，消息发送失败！");
            StreamWriter sw = null;
            StreamReader sr = null;
            string srv_code = string.Empty;

            try
            {
                // 消息组装
                string cmd = BuildCommand(eScMsgType, para);
                if (string.IsNullOrWhiteSpace(cmd))
                    return msg;
                if (this.PipeClient.IsConnected == false)
                    this.InitPipe();
                // 发送数据
                sw = new StreamWriter(this.PipeClient);
                sw.AutoFlush = true;
                List<char> charList = cmd.ToList<char>();
                charList.Add('\0');
                sw.WriteLine(charList.ToArray<char>());
                // 解锁用户不用读
                if (eScMsgType != EScMsgType.UL)
                {
                    sr = new StreamReader(this.PipeClient);
                    srv_code = sr.ReadLine();
                }
                // 消息翻译
                var tmpMsg = this.GetSrvMsg(srv_code);
                LogHelper.WriteLog(typeof(YYT.Remote.SConnect), $"指令内容：\n{cmd},服务器返回信息：{tmpMsg.content}");
                if (tmpMsg.code != 1)
                {
                    tmpMsg.code = 0;
                    LogHelper.WriteLog(typeof(YYT.Remote.SConnect), $"指令内容：\n{cmd}");
                }
                msg = tmpMsg;
            }
            catch (Exception ex)
            {
                msg.content = "数据发送失败！" + ex.Message;
            }
            finally
            {
                try
                {
                    if (sw != null)
                    {
                        sw.Close();
                        sw.Dispose();
                    }
                }
                catch { }
                try
                {
                    if (sr != null)
                    {
                        sr.Close();
                        sr.Dispose();
                    }
                }
                catch { }

                // 服务器消息下发后已经关闭了管道，所以客户端也直接关闭并释放
                this.Close();
            }
            return msg;
        }
        public byte[] SendReadBytes(EScMsgType eScMsgType, params object[] para)
        {
            StreamWriter sw = null;
            BinaryReader br = null;
            string srv_code = string.Empty;
            byte[] buf = null;

            try
            {
                // 消息组装
                string cmd = BuildCommand(eScMsgType, para);
                if (string.IsNullOrWhiteSpace(cmd))
                    return null;

                if (this.PipeClient.IsConnected == false)
                    this.InitPipe();

                // 发送数据
                sw = new StreamWriter(this.PipeClient);
                sw.AutoFlush = true;
                List<char> charList = cmd.ToList<char>();
                charList.Add('\0');
                sw.WriteLine(charList.ToArray<char>());
                // 读取返回数据
                br = new BinaryReader(this.PipeClient);
                buf = new byte[512];
                br.Read(buf, 0, 512);
            }
            catch(Exception ex)
            {
                throw ex;
            }
            finally
            {
                try
                {
                    if (sw != null)
                    {
                        sw.Close();
                        sw.Dispose();
                    }
                }
                catch { }
                try
                {
                    if (br != null)
                    {
                        br.Close();
                        br.Dispose();
                    }
                }
                catch { }

                // 服务器消息下发后已经关闭了管道，所以客户端也直接关闭并释放
                this.Close();
            }
            return buf;
        }

        public bool Connect(int timeOut = 5000)
        {
            try
            {
                if (!this.PipeClient.IsConnected)
                    this.PipeClient.Connect(timeOut);
                return true;
            }
            catch { }
            return false;
        }

        /// <summary>
        /// TC 命令的押分桌台扩展字段（仅押分类游戏），字段顺序与 center 的
        /// ts_BetRoomTableConfig 解析一致：U8 betTime + U32×7(betMin/betMax/bankerScoreNeed/
        /// itemSingle/itemAll/coinsNeed/oneCoinScore) + Poco 字符串 betScores + U8 defaultBetIndex
        /// + 可选 U32×4(betMinVice/betMaxVice/betMinDraw/betMaxDraw，仅 layoutTag==1 的游戏，如幸运六狮)。
        /// </summary>
        public class TcBetExt
        {
            public byte BetTime;
            public uint BetMin;
            public uint BetMax;
            public uint BankerScoreNeed;
            public uint ItemSingleScoreLimit;
            public uint ItemAllScoreLimit;
            public uint CoinsNeed;
            public uint OneCoinScore;
            public string BetScores;
            public byte DefaultBetIndex;
            public bool IncludeViceDraw;
            public uint BetMinVice;
            public uint BetMaxVice;
            public uint BetMinDraw;
            public uint BetMaxDraw;
        }

        /// <summary>
        /// TC 命令的桌台参数扩展字段（牌机/鱼机），紧跟 maxSeats 之后：
        /// U32×4(betMin/betMax/oneCoinScore/coinsNeed)，字段顺序与 center 的解析一致。
        /// </summary>
        public class TcTableExt
        {
            public uint BetMin;
            public uint BetMax;
            public uint OneCoinScore;
            public uint CoinsNeed;
        }

        /// <summary>
        /// 发送 TC(桌台配置热更新) 二进制命令，并读取 center 的文本回复(TCOK/TCER)。
        /// 报文布局见《后台桌名热更新对接说明-TC命令》§3.2：
        ///   "TC" + U16 BE gameID + U16 BE roomIndex + U16 BE tableIndex
        ///   + Poco 7-bit varint 长度前缀 + UTF-8 桌名
        ///   + U8 enabled + U32 BE idleFireTimeoutSec + U8 idleFireKickEnabled + U16 BE maxSeats
        ///   + 可选桌台参数扩展(TcTableExt，牌机/鱼机，U32×4 betMin/betMax/oneCoinScore/coinsNeed)
        ///   + 可选押分扩展(TcBetExt，仅押分类游戏，center 据此写 roomtableconfig_bet)
        /// 与现有 RP/PA(文本命令)不同，TC 为纯二进制报文，不经过 MsgDefine.config 模板。
        /// </summary>
        public Msg SendTcCommand(ushort gameID, ushort roomIndex, ushort tableIndex,
                                 string tableName, byte enabled,
                                 uint idleFireTimeoutSec, byte idleFireKickEnabled,
                                 ushort maxSeats, TcBetExt betExt = null, TcTableExt tableExt = null)
        {
            Msg msg = new Msg(0, "服务器内部错误，消息发送失败！");
            StreamReader sr = null;
            try
            {
                // 桌名约束：UTF-8 字节 ≤ 51（C++ 结构体 char[52]，留 1 字节 \0）。
                byte[] nameBytes = Encoding.UTF8.GetBytes(tableName ?? string.Empty);
                if (nameBytes.Length > 51)
                {
                    // 按 UTF-8 字节截断时避免落在多字节字符中间：逐字节回退到 ≤51 且非续位字节。
                    int cut = 51;
                    while (cut > 0 && (nameBytes[cut] & 0xC0) == 0x80) cut--;
                    Array.Resize(ref nameBytes, cut);
                }

                if (this.PipeClient.IsConnected == false)
                    this.InitPipe();

                // 直接写底层流，按大端序逐字段组包。
                using (var bw = new BinaryWriter(this.PipeClient, Encoding.UTF8, leaveOpen: true))
                {
                    // 命令头 "TC"
                    bw.Write((byte)'T');
                    bw.Write((byte)'C');
                    // U16 BE ×3
                    bw.Write(HostToNetworkU16(gameID));
                    bw.Write(HostToNetworkU16(roomIndex));
                    bw.Write(HostToNetworkU16(tableIndex));
                    // Poco 7-bit varint 长度前缀 + UTF-8 桌名
                    Write7BitVarint(bw, (uint)nameBytes.Length);
                    bw.Write(nameBytes);
                    // U8 / U32 BE / U8 / U16 BE
                    bw.Write(enabled);
                    bw.Write(HostToNetworkU32(idleFireTimeoutSec));
                    bw.Write(idleFireKickEnabled);
                    bw.Write(HostToNetworkU16(maxSeats));
                    if (tableExt != null)
                    {
                        bw.Write(HostToNetworkU32(tableExt.BetMin));
                        bw.Write(HostToNetworkU32(tableExt.BetMax));
                        bw.Write(HostToNetworkU32(tableExt.OneCoinScore));
                        bw.Write(HostToNetworkU32(tableExt.CoinsNeed));
                    }
                    if (betExt != null)
                    {
                        bw.Write(betExt.BetTime);
                        bw.Write(HostToNetworkU32(betExt.BetMin));
                        bw.Write(HostToNetworkU32(betExt.BetMax));
                        bw.Write(HostToNetworkU32(betExt.BankerScoreNeed));
                        bw.Write(HostToNetworkU32(betExt.ItemSingleScoreLimit));
                        bw.Write(HostToNetworkU32(betExt.ItemAllScoreLimit));
                        bw.Write(HostToNetworkU32(betExt.CoinsNeed));
                        bw.Write(HostToNetworkU32(betExt.OneCoinScore));
                        byte[] scoreBytes = Encoding.UTF8.GetBytes(betExt.BetScores ?? string.Empty);
                        Write7BitVarint(bw, (uint)scoreBytes.Length);
                        bw.Write(scoreBytes);
                        bw.Write(betExt.DefaultBetIndex);
                        if (betExt.IncludeViceDraw)
                        {
                            bw.Write(HostToNetworkU32(betExt.BetMinVice));
                            bw.Write(HostToNetworkU32(betExt.BetMaxVice));
                            bw.Write(HostToNetworkU32(betExt.BetMinDraw));
                            bw.Write(HostToNetworkU32(betExt.BetMaxDraw));
                        }
                    }
                    bw.Flush();
                }

                // 读取 center 文本回复(TCOK\n / TCER\n)，与 RP/PA 风格一致。
                sr = new StreamReader(this.PipeClient);
                string srv_code = sr.ReadLine();
                var tmpMsg = this.GetSrvMsg(srv_code);
                // GetSrvMsg 对未知 key 返回 null，兜底为失败，避免下游 NPE。
                if (tmpMsg == null)
                {
                    tmpMsg = new Msg { code = 0, datas = srv_code, content = "服务器返回未识别：" + (srv_code ?? "(空)") };
                }
                LogHelper.WriteLog(typeof(YYT.Remote.SConnect),
                    $"TC指令：gameID={gameID},room={roomIndex},table={tableIndex},name={tableName},服务器返回：{tmpMsg.content}");
                if (tmpMsg.code != 1)
                {
                    tmpMsg.code = 0;
                    LogHelper.WriteLog(typeof(YYT.Remote.SConnect),
                        $"TC指令失败：gameID={gameID},room={roomIndex},table={tableIndex},返回={srv_code}");
                }
                msg = tmpMsg;
            }
            catch (Exception ex)
            {
                msg.content = "TC数据发送失败！" + ex.Message;
                LogHelper.WriteLog(typeof(YYT.Remote.SConnect), ex);
            }
            finally
            {
                try { if (sr != null) { sr.Close(); sr.Dispose(); } } catch { }
                // 服务器消息下发后已经关闭了管道，所以客户端也直接关闭并释放
                this.Close();
            }
            return msg;
        }

        /// <summary>U16 转大端字节（Windows 为小端，须手动转网络字节序）。</summary>
        private static byte[] HostToNetworkU16(ushort v)
        {
            return new byte[] { (byte)(v >> 8), (byte)(v & 0xFF) };
        }

        /// <summary>U32 转大端字节。</summary>
        private static byte[] HostToNetworkU32(uint v)
        {
            return new byte[] { (byte)(v >> 24), (byte)(v >> 16), (byte)(v >> 8), (byte)(v & 0xFF) };
        }

        /// <summary>Poco 7-bit 变长长度前缀：每字节低7位为数据，最高位为延续标志。</summary>
        private static void Write7BitVarint(BinaryWriter bw, uint value)
        {
            while (value >= 0x80)
            {
                bw.Write((byte)(value | 0x80));
                value >>= 7;
            }
            bw.Write((byte)value);
        }

        public void Close()
        {
            try
            {
                if (this.PipeClient != null)
                {
                    this.PipeClient.Close();
                    this.PipeClient.Dispose();
                }
            }
            catch { }
        }
    }
}
