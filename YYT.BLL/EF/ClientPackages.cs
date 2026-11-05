using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using YYT.Entity;

namespace YYT.BLL.EF
{
    /// <summary>
    /// 客户端包（换皮包）管理（2026-10-30）：多套不同 UI 的 APK/IPA 共用同一套服务端，靠大厅登录包第二个字段的口令（AppKey）区分。
    /// 中心服每次大厅登录都按 AppKey 查 clientpackage：查不到或已停用回 -5（请升级游戏版本）并断开，所以启停对新登录立即生效、在线的不踢。
    /// 包只决定外观和能否显示专属桌台（RealTableIndex=1 的包按真实桌号显示），权限一律看代理线、不看包。
    /// 1 号「默认包」的口令 CDhP53fFb822 写死在 2026-10-30 之前发布的全部线上包里，不能修改，停用它等于让所有老包无法登录。
    /// </summary>
    public static class ClientPackages
    {
        public const int DefaultPackageId = 1;
        public const string LegacyAppKey = "CDhP53fFb822";

        public class PackageRow
        {
            public int ID { get; set; }
            public string Name { get; set; }
            public string AppKey { get; set; }
            public int Enabled { get; set; }
            public int RealTableIndex { get; set; }
            public string Remark { get; set; }
            public DateTime? CreateTime { get; set; }
            public DateTime? UpdateTime { get; set; }
        }

        /// <summary>
        /// 校验包名与口令：口令 6~32 位字母或数字（大厅登录包按 Poco 字符串发送，中心服逐字比对，区分大小写）；返回 null 表示通过。
        /// </summary>
        public static string Validate(string name, string appKey)
        {
            if (string.IsNullOrWhiteSpace(name) || name.Trim().Length > 50)
                return "包名称不能为空，且不超过 50 个字！";
            if (string.IsNullOrEmpty(appKey) || !Regex.IsMatch(appKey, "^[A-Za-z0-9]{6,32}$"))
                return "包口令必须是 6~32 位字母或数字！";
            return null;
        }

        /// <summary>clientpackage 表是否存在（SQL 补丁未执行时页面给出提示）。</summary>
        public static bool TableExists(GameDbContext ef)
        {
            return ef.Database.SqlQuery<int>(
                "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='clientpackage'")
                .FirstOrDefault() > 0;
        }

        public static List<PackageRow> List(GameDbContext ef)
        {
            return ef.Database.SqlQuery<PackageRow>(
                "SELECT ID, Name, AppKey, Enabled, RealTableIndex, IFNULL(Remark,'') AS Remark, CreateTime, UpdateTime FROM clientpackage ORDER BY ID")
                .ToList();
        }

        /// <summary>新增（id&lt;=0）或修改客户端包；口令全局唯一，1 号默认包的口令不能改。</summary>
        public static Msg Save(int id, string name, string appKey, int enabled, int realTableIndex, string remark)
        {
            Msg msg = new Msg(0, "保存失败！");
            name = (name ?? string.Empty).Trim();
            appKey = (appKey ?? string.Empty).Trim();
            remark = (remark ?? string.Empty).Trim();
            if (remark.Length > 200) remark = remark.Substring(0, 200);
            string error = Validate(name, appKey);
            if (error != null)
            {
                msg.content = error;
                return msg;
            }
            using (var ef = new GameDbContext())
            {
                if (!TableExists(ef))
                {
                    msg.content = "数据库缺少 clientpackage 表，请参照 Database/README.md 核对所需增量升级；运营库不可直接重导初始化库。";
                    return msg;
                }
                int dup = ef.Database.SqlQuery<int>("SELECT COUNT(*) FROM clientpackage WHERE AppKey={0} AND ID<>{1}", appKey, id).FirstOrDefault();
                if (dup > 0)
                {
                    msg.content = "包口令已被其他包使用！";
                    return msg;
                }
                int en = enabled == 0 ? 0 : 1;
                int real = realTableIndex == 0 ? 0 : 1;
                if (id <= 0)
                {
                    ef.Database.ExecuteSqlCommand(
                        "INSERT INTO clientpackage (Name, AppKey, Enabled, RealTableIndex, Remark) VALUES ({0}, {1}, {2}, {3}, {4})",
                        name, appKey, en, real, remark);
                    msg.code = 1;
                    msg.content = "新增成功！新包的玩家登录即时生效";
                    return msg;
                }
                PackageRow old = ef.Database.SqlQuery<PackageRow>(
                    "SELECT ID, Name, AppKey, Enabled, RealTableIndex, IFNULL(Remark,'') AS Remark, CreateTime, UpdateTime FROM clientpackage WHERE ID={0}", id)
                    .FirstOrDefault();
                if (old == null)
                {
                    msg.content = "客户端包不存在！";
                    return msg;
                }
                if (id == DefaultPackageId && !string.Equals(old.AppKey, appKey, StringComparison.Ordinal))
                {
                    msg.content = "默认包的口令写死在已发布的线上包里，不能修改！";
                    return msg;
                }
                ef.Database.ExecuteSqlCommand(
                    "UPDATE clientpackage SET Name={0}, AppKey={1}, Enabled={2}, RealTableIndex={3}, Remark={4} WHERE ID={5}",
                    name, appKey, en, real, remark, id);
                msg.code = 1;
                msg.content = "保存成功！对之后的新登录生效，在线玩家不受影响";
            }
            return msg;
        }

        /// <summary>启用/停用：停用后该包无法登录大厅（新登录即时生效，在线玩家下次登录时生效）。</summary>
        public static Msg SetEnabled(int id, int enabled)
        {
            Msg msg = new Msg(0, "设置失败！");
            using (var ef = new GameDbContext())
            {
                if (!TableExists(ef))
                {
                    msg.content = "数据库缺少 clientpackage 表，请先执行 SQL 补丁！";
                    return msg;
                }
                int n = ef.Database.ExecuteSqlCommand("UPDATE clientpackage SET Enabled={0} WHERE ID={1}", enabled == 0 ? 0 : 1, id);
                if (n > 0)
                {
                    msg.code = 1;
                    msg.content = enabled == 0 ? "已停用，该包的新登录将被拒绝" : "已启用";
                }
                else
                {
                    msg.content = "客户端包不存在！";
                }
            }
            return msg;
        }
    }
}
