# 历史初始化目录

2026-11-05 起，Docker 不再挂载本目录，也不再维护 `00_mth.sql` 和历史补丁副本。

当前唯一来源是仓库 [Database/mth_clean.sql](../../../Database/mth_clean.sql)，由 `docker-compose.yml` 直接只读挂载。全量恢复文件为 [Database/mth_full.sql](../../../Database/mth_full.sql)；说明与清理边界见 [Database/README.md](../../../Database/README.md)。

历史迁移仍在 `Docs/sql/` 留存作证据，不叠加到当前完整快照。已有 Docker 数据卷不会因替换 SQL 自动升级；重建卷会删除数据，操作边界见 [Docker说明](../../../Docs/docker-mysql.md)。
