using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO.Pipes;
using System.Threading;
using YYT.BLL.Services.GameServer;
using YYT.Remote;

// 一次性验证程序：证明"游戏服管道挂着不回话"时，在线玩家查询(QA)会在短超时内失败并返回 null，
// 而不是像以前那样把请求线程占住 10 秒（默认读超时）。
//   server 模式：扮演"占着管道不回话"的游戏服（接受连接后既不读也不回）
//   client 模式：连调两次 PipeGameServerClient.QueryAllOnlinePlayers()，打印结果与耗时
//                （第 1 次真实超时，第 2 次走熔断快速失败）
//   old    模式：用默认超时的 SConnect 直发 QA，对照旧行为（10 秒才回来）
class Program
{
    static int Main(string[] args)
    {
        try
        {
            string mode = args.Length > 0 ? args[0] : "client";
            if (mode == "server")
                return RunFakeServer();
            if (mode == "caps")
                return RunCaps();
            if (mode == "manual")
                return RunManual();
            if (mode == "raw")
                return RunRaw();
            if (mode == "unblock")
                return RunUnblock();
            if (mode == "probe")
            {
                int c = args.Length > 1 ? int.Parse(args[1]) : 1000;
                int r = args.Length > 2 ? int.Parse(args[2]) : 3000;
                return RunProbe(c, r);
            }
            return RunClient();
        }
        catch (Exception ex)
        {
            // 不用 ex.ToString()：某些异常在中文环境下格式化会二次抛错
            Console.WriteLine("EXCEPTION type = " + ex.GetType().FullName);
            Console.WriteLine("EXCEPTION msg  = " + ex.Message);
            if (ex.InnerException != null)
                Console.WriteLine("INNER     type = " + ex.InnerException.GetType().FullName +
                                  ", msg = " + ex.InnerException.Message);
            Console.Out.Flush();
            return 2;
        }
    }

    // 直接观察 SConnect 的超时是否生效：构造后先读私有超时字段，再发 QA 计时
    static int RunProbe(int connectMs, int readMs)
    {
        Stopwatch sw = Stopwatch.StartNew();
        SConnect srv = new SConnect(connectMs, readMs);
        System.Reflection.FieldInfo fc = typeof(SConnect).GetField("connectTimeoutMs", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        System.Reflection.FieldInfo fr = typeof(SConnect).GetField("readTimeoutMs", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        Console.WriteLine("probe: ctor(" + connectMs + "," + readMs + ") took " + sw.ElapsedMilliseconds +
                          " ms; fields connectTimeoutMs=" + (fc == null ? "?" : fc.GetValue(srv).ToString()) +
                          " readTimeoutMs=" + (fr == null ? "?" : fr.GetValue(srv).ToString()) +
                          "; CanTimeout=" + srv.PipeClient.CanTimeout);
        string raw = srv.SendNotTranlation(EScMsgType.QA);
        sw.Stop();
        Console.WriteLine("probe: elapsed = " + sw.ElapsedMilliseconds + " ms, reply = " + (raw == null ? "(null)" : raw));
        return 0;
    }

    // 逐项探测：与 SConnect 完全相同的构造参数下，哪些超时 API 可用
    static int RunCaps()
    {
        System.IO.Pipes.NamedPipeClientStream pipe = new System.IO.Pipes.NamedPipeClientStream(
            ".", "mynamedpipe", PipeDirection.InOut, PipeOptions.Asynchronous, System.Security.Principal.TokenImpersonationLevel.None);
        Console.WriteLine("pipe created, IsConnected=" + pipe.IsConnected);
        try { Console.WriteLine("CanTimeout = " + pipe.CanTimeout); }
        catch (Exception e) { Console.WriteLine("CanTimeout THREW " + e.GetType().Name + ": " + e.Message); }
        try { pipe.ReadTimeout = 3000; Console.WriteLine("set ReadTimeout(3000) OK"); }
        catch (Exception e) { Console.WriteLine("set ReadTimeout THREW " + e.GetType().Name + ": " + e.Message); }
        try { Console.WriteLine("get ReadTimeout = " + pipe.ReadTimeout); }
        catch (Exception e) { Console.WriteLine("get ReadTimeout THREW " + e.GetType().Name + ": " + e.Message); }
        try { pipe.WriteTimeout = 3000; Console.WriteLine("set WriteTimeout(3000) OK"); }
        catch (Exception e) { Console.WriteLine("set WriteTimeout THREW " + e.GetType().Name + ": " + e.Message); }
        try { Console.WriteLine("get WriteTimeout = " + pipe.WriteTimeout); }
        catch (Exception e) { Console.WriteLine("get WriteTimeout THREW " + e.GetType().Name + ": " + e.Message); }
        pipe.Dispose();
        return 0;
    }

    // 只用原始字节 Write + 异步读，看是不是 StreamWriter 层的问题
    static int RunRaw()
    {
        Stopwatch sw = Stopwatch.StartNew();
        SConnect srv = new SConnect(1000, 3000);
        Console.WriteLine("t=" + sw.ElapsedMilliseconds + " connected");
        byte[] payload = System.Text.Encoding.UTF8.GetBytes("QA\0");
        srv.PipeClient.Write(payload, 0, payload.Length);
        Console.WriteLine("t=" + sw.ElapsedMilliseconds + " raw write done");
        byte[] buf = new byte[65536];
        System.Threading.Tasks.Task<int> task = srv.PipeClient.ReadAsync(buf, 0, buf.Length);
        Console.WriteLine("t=" + sw.ElapsedMilliseconds + " ReadAsync started");
        bool done = task.Wait(3000);
        Console.WriteLine("t=" + sw.ElapsedMilliseconds + " Wait(3000) returned " + done +
                          (done ? ", bytes=" + task.Result : ""));
        srv.Close();
        Console.WriteLine("t=" + sw.ElapsedMilliseconds + " closed");
        Console.Out.Flush();
        return 0;
    }

    // 验证"阻塞中的收发能否被 Close() 解开"：超时后要能靠关闭管道把线程放掉
    static int RunUnblock()
    {
        Stopwatch sw = Stopwatch.StartNew();
        SConnect srv = new SConnect(1000, 3000);
        Console.WriteLine("t=" + sw.ElapsedMilliseconds + " connected");
        bool finished = false;
        System.Threading.Tasks.Task worker = System.Threading.Tasks.Task.Run(delegate()
        {
            try
            {
                System.IO.StreamWriter w = new System.IO.StreamWriter(srv.PipeClient);
                w.AutoFlush = true;
                System.Collections.Generic.List<char> cs = new System.Collections.Generic.List<char>("QA".ToCharArray());
                cs.Add('\0');
                w.WriteLine(cs.ToArray());
                Console.WriteLine("t=" + sw.ElapsedMilliseconds + " worker: write returned");
            }
            catch (Exception e) { Console.WriteLine("t=" + sw.ElapsedMilliseconds + " worker THREW " + e.GetType().Name + ": " + e.Message); }
            finished = true;
        });
        System.Threading.Thread.Sleep(2000);
        Console.WriteLine("t=" + sw.ElapsedMilliseconds + " main: worker finished=" + finished + ", closing pipe now");
        srv.Close();
        bool exited = worker.Wait(5000);
        Console.WriteLine("t=" + sw.ElapsedMilliseconds + " main: after close, worker finished=" + finished + " (task.Wait=" + exited + ")");
        Console.Out.Flush();
        return 0;
    }

    // 手工复刻 SendNotTranlation 的每一步并打时间戳，定位到底哪一步会挂住
    static int RunManual()
    {
        Stopwatch sw = Stopwatch.StartNew();
        SConnect srv = new SConnect(1000, 3000);
        Console.WriteLine("t=" + sw.ElapsedMilliseconds + " connected");
        System.IO.StreamWriter w = new System.IO.StreamWriter(srv.PipeClient);
        w.AutoFlush = true;
        Console.WriteLine("t=" + sw.ElapsedMilliseconds + " writer created");
        System.Collections.Generic.List<char> cs = new System.Collections.Generic.List<char>("QA".ToCharArray());
        cs.Add('\0');
        w.WriteLine(cs.ToArray());
        Console.WriteLine("t=" + sw.ElapsedMilliseconds + " written");
        System.IO.StreamReader r = new System.IO.StreamReader(srv.PipeClient);
        System.Threading.Tasks.Task<string> task = r.ReadLineAsync();
        Console.WriteLine("t=" + sw.ElapsedMilliseconds + " ReadLineAsync started");
        bool done = task.Wait(3000);
        Console.WriteLine("t=" + sw.ElapsedMilliseconds + " Wait(3000) returned " + done);
        srv.Close();
        Console.WriteLine("t=" + sw.ElapsedMilliseconds + " pipe closed");
        try { w.Close(); Console.WriteLine("t=" + sw.ElapsedMilliseconds + " writer closed"); }
        catch (Exception e) { Console.WriteLine("writer.Close THREW " + e.GetType().Name); }
        try { r.Close(); Console.WriteLine("t=" + sw.ElapsedMilliseconds + " reader closed"); }
        catch (Exception e) { Console.WriteLine("reader.Close THREW " + e.GetType().Name); }
        Console.Out.Flush();
        return 0;
    }

    static int RunFakeServer()
    {
        Console.WriteLine("fake pipe server: listening on \\\\.\\pipe\\mynamedpipe (never replies)");
        while (true)
        {
            NamedPipeServerStream pipe = new NamedPipeServerStream(
                "mynamedpipe", PipeDirection.InOut, 16, PipeTransmissionMode.Message, PipeOptions.None, 4096, 4096);
            pipe.WaitForConnection();
            // ⚠️ 必须留着强引用：只赋给局部变量的话 GC 会回收管道对象、连接被中断，
            // 测出来的是"管道已中断"而不是"读超时"。
            held.Add(pipe);
            Console.WriteLine("fake pipe server: client connected at " + DateTime.Now.ToString("HH:mm:ss.fff") +
                              " (held=" + held.Count + ")");
        }
    }

    static readonly List<NamedPipeServerStream> held = new List<NamedPipeServerStream>();

    static int RunClient()
    {
        for (int i = 1; i <= 2; i++)
        {
            Console.WriteLine("client: call #" + i + " QueryAllOnlinePlayers() ...");
            Stopwatch sw = Stopwatch.StartNew();
            List<OnlinePlayerInfo> list = new PipeGameServerClient().QueryAllOnlinePlayers();
            sw.Stop();
            Console.WriteLine("client: call #" + i + " result = " + (list == null ? "null (失败态)" : "list (" + list.Count + " items)"));
            Console.WriteLine("client: call #" + i + " elapsed = " + sw.ElapsedMilliseconds + " ms");
        }
        return 0;
    }

    static int RunOldDefaultTimeout()
    {
        Console.WriteLine("old: SConnect() 默认超时直发 QA ...");
        Stopwatch sw = Stopwatch.StartNew();
        string raw = new SConnect().SendNotTranlation(EScMsgType.QA);
        sw.Stop();
        Console.WriteLine("old: elapsed = " + sw.ElapsedMilliseconds + " ms, reply = " + (raw == null ? "(null)" : raw));
        return 0;
    }
}
