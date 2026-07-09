using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using YYT.Common;
using YYT.Entity;

namespace YYT.BLL.EF
{
    public enum GameCommandOutboxStatus
    {
        Created = 0,
        Sent = 1,
        Acked = 2,
        Failed = 3,
        Processing = 4
    }

    public class B_GameCommandOutbox
    {
        private static readonly object ensureTableLock = new object();
        private static bool tableEnsured;
        private const int MaxRetryCount = 5;
        private static readonly TimeSpan SentCommandTimeout = TimeSpan.FromMinutes(2);

        public M_GameCommandOutbox Create(string commandType, string targetUserId, object payload)
        {
            try
            {
                EnsureTable();
                var entity = new M_GameCommandOutbox
                {
                    CommandId = Guid.NewGuid().ToString("N"),
                    CommandType = commandType,
                    TargetUserId = targetUserId,
                    Payload = payload == null ? null : JsonConvert.SerializeObject(payload),
                    Status = (int)GameCommandOutboxStatus.Created,
                    RetryCount = 0,
                    CreatedAt = DateTime.Now
                };

                using (var ef = new GameDbContext())
                {
                    ef.GameCommandOutboxes.Add(entity);
                    ef.SaveChanges();
                }
                return entity;
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(B_GameCommandOutbox), "Create game command outbox failed: " + ex.Message);
                return null;
            }
        }

        public void MarkSent(string commandId)
        {
            Update(commandId, GameCommandOutboxStatus.Sent, null, null, false);
        }

        public void MarkAcked(string commandId, string rawResponse)
        {
            Update(commandId, GameCommandOutboxStatus.Acked, rawResponse, null, false);
        }

        public void MarkFailed(string commandId, string rawResponse, string errorMessage)
        {
            Update(commandId, GameCommandOutboxStatus.Failed, rawResponse, errorMessage, true);
        }

        public List<M_GameCommandOutbox> ClaimRetryableCommands(int take)
        {
            try
            {
                EnsureTable();
                DateTime now = DateTime.Now;
                DateTime staleCommandBefore = now.Subtract(SentCommandTimeout);
                using (var ef = new GameDbContext())
                {
                    List<string> candidateIds = ef.GameCommandOutboxes
                        .Where(c =>
                            c.Status != (int)GameCommandOutboxStatus.Acked &&
                            c.RetryCount < MaxRetryCount &&
                            (c.Status != (int)GameCommandOutboxStatus.Sent || !c.SentAt.HasValue || c.SentAt <= staleCommandBefore) &&
                            (c.Status != (int)GameCommandOutboxStatus.Processing || !c.UpdatedAt.HasValue || c.UpdatedAt <= staleCommandBefore) &&
                            (!c.NextRetryAt.HasValue || c.NextRetryAt <= now))
                        .OrderBy(c => c.CreatedAt)
                        .Take(take)
                        .Select(c => c.CommandId)
                        .ToList();

                    var claimed = new List<M_GameCommandOutbox>();
                    foreach (string commandId in candidateIds)
                    {
                        int rows = ef.Database.ExecuteSqlCommand(@"
UPDATE `gamecommandoutbox`
SET `Status` = @p0,
    `UpdatedAt` = @p1
WHERE `CommandId` = @p2
  AND `Status` <> @p3
  AND `RetryCount` < @p4
  AND (`NextRetryAt` IS NULL OR `NextRetryAt` <= @p1)
  AND (`Status` <> @p5 OR `SentAt` IS NULL OR `SentAt` <= @p6)
  AND (`Status` <> @p7 OR `UpdatedAt` IS NULL OR `UpdatedAt` <= @p6)",
                            (int)GameCommandOutboxStatus.Processing,
                            now,
                            commandId,
                            (int)GameCommandOutboxStatus.Acked,
                            MaxRetryCount,
                            (int)GameCommandOutboxStatus.Sent,
                            staleCommandBefore,
                            (int)GameCommandOutboxStatus.Processing);

                        if (rows != 1)
                            continue;

                        M_GameCommandOutbox command = ef.GameCommandOutboxes.Find(commandId);
                        if (command != null)
                            claimed.Add(command);
                    }

                    return claimed;
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(B_GameCommandOutbox), "Claim retryable game command outbox failed: " + ex.Message);
                return new List<M_GameCommandOutbox>();
            }
        }

        public void MarkRetrying(string commandId)
        {
            Update(commandId, GameCommandOutboxStatus.Sent, null, null, false);
        }

        private void Update(string commandId, GameCommandOutboxStatus status, string rawResponse, string errorMessage, bool increaseRetryCount)
        {
            if (string.IsNullOrWhiteSpace(commandId))
                return;

            try
            {
                EnsureTable();
                using (var ef = new GameDbContext())
                {
                    var entity = ef.GameCommandOutboxes.Find(commandId);
                    if (entity == null)
                        return;

                    entity.Status = (int)status;
                    entity.RawResponse = rawResponse;
                    entity.ErrorMessage = errorMessage;
                    entity.UpdatedAt = DateTime.Now;
                    if (status == GameCommandOutboxStatus.Sent)
                    {
                        entity.SentAt = DateTime.Now;
                        entity.LastTriedAt = DateTime.Now;
                    }
                    if (increaseRetryCount)
                    {
                        entity.RetryCount += 1;
                        entity.LastTriedAt = DateTime.Now;
                        entity.NextRetryAt = CalculateNextRetryAt(entity.RetryCount);
                    }
                    if (status == GameCommandOutboxStatus.Acked)
                    {
                        entity.NextRetryAt = null;
                    }

                    ef.SaveChanges();
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(B_GameCommandOutbox), "Update game command outbox failed: " + ex.Message);
            }
        }

        private static DateTime CalculateNextRetryAt(int retryCount)
        {
            int seconds = retryCount <= 1 ? 10 : Math.Min(300, retryCount * retryCount * 10);
            return DateTime.Now.AddSeconds(seconds);
        }

        private void EnsureTable()
        {
            if (tableEnsured)
                return;

            lock (ensureTableLock)
            {
                if (tableEnsured)
                    return;

                using (var ef = new GameDbContext())
                {
                    ef.Database.ExecuteSqlCommand(@"
CREATE TABLE IF NOT EXISTS `gamecommandoutbox` (
  `CommandId` varchar(32) NOT NULL,
  `CommandType` varchar(32) NOT NULL,
  `TargetUserId` varchar(64) NULL DEFAULT NULL,
  `Payload` text NULL,
  `Status` int(11) NOT NULL DEFAULT 0,
  `RawResponse` text NULL,
  `ErrorMessage` varchar(1024) NULL DEFAULT NULL,
  `RetryCount` int(11) NOT NULL DEFAULT 0,
  `CreatedAt` datetime NOT NULL,
  `SentAt` datetime NULL DEFAULT NULL,
  `LastTriedAt` datetime NULL DEFAULT NULL,
  `NextRetryAt` datetime NULL DEFAULT NULL,
  `UpdatedAt` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`CommandId`) USING BTREE,
  INDEX `IX_GameCommandOutbox_Status` (`Status`) USING BTREE,
  INDEX `IX_GameCommandOutbox_TargetUserId` (`TargetUserId`) USING BTREE,
  INDEX `IX_GameCommandOutbox_NextRetryAt` (`NextRetryAt`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '游戏服务命令Outbox' ROW_FORMAT = Dynamic;");
                    EnsureColumn(ef, "RetryCount", "ALTER TABLE `gamecommandoutbox` ADD COLUMN `RetryCount` int(11) NOT NULL DEFAULT 0 AFTER `ErrorMessage`");
                    EnsureColumn(ef, "LastTriedAt", "ALTER TABLE `gamecommandoutbox` ADD COLUMN `LastTriedAt` datetime NULL DEFAULT NULL AFTER `SentAt`");
                    EnsureColumn(ef, "NextRetryAt", "ALTER TABLE `gamecommandoutbox` ADD COLUMN `NextRetryAt` datetime NULL DEFAULT NULL AFTER `LastTriedAt`");
                    EnsureIndex(ef, "IX_GameCommandOutbox_NextRetryAt", "ALTER TABLE `gamecommandoutbox` ADD INDEX `IX_GameCommandOutbox_NextRetryAt`(`NextRetryAt`) USING BTREE");
                }
                tableEnsured = true;
            }
        }

        private static void EnsureColumn(GameDbContext ef, string columnName, string alterSql)
        {
            int count = ef.Database.SqlQuery<int>(@"
SELECT COUNT(1)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND LOWER(TABLE_NAME) = 'gamecommandoutbox'
  AND COLUMN_NAME = @p0", columnName).FirstOrDefault();

            if (count == 0)
                ef.Database.ExecuteSqlCommand(alterSql);
        }

        private static void EnsureIndex(GameDbContext ef, string indexName, string alterSql)
        {
            int count = ef.Database.SqlQuery<int>(@"
SELECT COUNT(1)
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND LOWER(TABLE_NAME) = 'gamecommandoutbox'
  AND INDEX_NAME = @p0", indexName).FirstOrDefault();

            if (count == 0)
                ef.Database.ExecuteSqlCommand(alterSql);
        }
    }
}
