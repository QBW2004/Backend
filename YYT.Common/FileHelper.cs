using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Web;

namespace YYT.Common
{
    public static class FileHelper
    {
        public static string SaveFile(HttpPostedFileBase file, string savePath)
        {
            var newFileName = string.Empty;
            try
            {
                using (var md5 = MD5.Create())
                {
                    using (var stream = file.InputStream)
                    {
                        var hash = md5.ComputeHash(stream);
                        newFileName = BitConverter.ToString(hash).Replace("-", "").ToLowerInvariant() + Path.GetExtension(file.FileName);
                        file.SaveAs(Path.Combine(savePath, newFileName));
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Common.FileHelper), ex);
            }
            return newFileName;
        }

        public static string GetMD5Hash(Stream stream)
        {
            MD5 md5 = null;
            MemoryStream stream1 = new MemoryStream();
            try
            {
                md5 = MD5.Create();

                stream.CopyTo(stream1);
                stream1.Seek(0, SeekOrigin.Begin);

                byte[] data = md5.ComputeHash(stream1);
                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < data.Length; i++)
                {
                    sb.Append(data[i].ToString("x2"));
                }
                return sb.ToString();
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Common.FileHelper), ex);
            }
            finally
            {
                try
                {
                    if (stream1 != null)
                    {
                        stream1.Close();
                        stream1.Dispose();
                    }
                }
                catch { }

                try
                {
                    if (md5 != null)
                    {
                        md5.Clear();
                        md5.Dispose();
                    }
                }
                catch { }
            }
            return "";
        }

        public static bool FileEquals(this HttpPostedFileBase upFile, string filePath, string newfileHash = "")
        {
            MD5 md5 = null;

            MemoryStream stream1 = new MemoryStream();
            Stream stream2 = null;

            try
            {
                if (upFile == null || string.IsNullOrWhiteSpace(filePath) || !System.IO.File.Exists(filePath))
                    throw new ArgumentNullException("对比文件为空！");

                md5 = MD5.Create();

                upFile.InputStream.CopyTo(stream1);
                stream1.Seek(0, SeekOrigin.Begin);// 这个必须要！！！ 坑！！！读取stream时读到了stream的结尾，再次读取时要重头开始读。

                stream2 = File.OpenRead(filePath);

                var hash_1 = BitConverter.ToString(md5.ComputeHash(stream1)).Replace("-", "").ToLower();
                var hash_2 = BitConverter.ToString(md5.ComputeHash(stream2)).Replace("-", "").ToLower();

                newfileHash = hash_2;

                return hash_1.Equals(hash_2);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Common.FileHelper), ex);
            }
            finally
            {
                try
                {
                    if (stream1 != null)
                    {
                        stream1.Close();
                        stream1.Dispose();
                    }
                }
                catch { }

                try
                {
                    if (stream2 != null)
                    {
                        stream2.Close();
                        stream2.Dispose();
                    }
                }
                catch { }

                try
                {
                    if (md5 != null)
                    {
                        md5.Clear();
                        md5.Dispose();
                    }
                }
                catch { }
            }
            return false;
        }

    }

    public class FileWatcher
    {
        public static void WatcherStrat(string path, string filter)
        {
            FileSystemWatcher watcher = new FileSystemWatcher();
            watcher.Path = path;
            watcher.Filter = filter;
            watcher.Changed += new FileSystemEventHandler(OnProcess);
            watcher.Created += new FileSystemEventHandler(OnProcess);
            watcher.Deleted += new FileSystemEventHandler(OnProcess);
            watcher.Renamed += new RenamedEventHandler(OnRenamed);
            watcher.EnableRaisingEvents = true;
            watcher.NotifyFilter = NotifyFilters.Attributes | NotifyFilters.CreationTime | NotifyFilters.DirectoryName | NotifyFilters.FileName | NotifyFilters.LastAccess
                                   | NotifyFilters.LastWrite | NotifyFilters.Security | NotifyFilters.Size;
            watcher.IncludeSubdirectories = true;
        }
        private static void OnProcess(object source, FileSystemEventArgs e)
        {
            if (e.ChangeType == WatcherChangeTypes.Created)
            {
                OnCreated(source, e);
            }
            else if (e.ChangeType == WatcherChangeTypes.Changed)
            {
                OnChanged(source, e);
            }
            else if (e.ChangeType == WatcherChangeTypes.Deleted)
            {
                OnDeleted(source, e);
            }
        }

        private static void OnCreated(object source, FileSystemEventArgs e)
        {
            //LogHelper.WriteLog(typeof(FileWatcher), string.Format("文件新建事件处理逻辑 {0}  {1}  {2}", e.ChangeType, e.FullPath, e.Name));
        }
        private static void OnChanged(object source, FileSystemEventArgs e)
        {
            //LogHelper.WriteLog(typeof(FileWatcher), string.Format("文件改变事件处理逻辑{0}  {1}  {2}", e.ChangeType, e.FullPath, e.Name));
        }
        private static void OnDeleted(object source, FileSystemEventArgs e)
        {
            //LogHelper.WriteLog(typeof(FileWatcher), string.Format("文件删除事件处理逻辑{0}  {1}   {2}", e.ChangeType, e.FullPath, e.Name));
        }
        private static void OnRenamed(object source, RenamedEventArgs e)
        {
            //LogHelper.WriteLog(typeof(FileWatcher), string.Format("文件重命名事件处理逻辑{0}  {1}  {2}", e.ChangeType, e.FullPath, e.Name));
        }
    }
}
