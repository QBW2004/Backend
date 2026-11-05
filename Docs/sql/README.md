# 历史 SQL 已归档

2026-11-05：本目录旧迁移、修复及测试种子已核对 SHA-256 后移至仓库外，原文位置、用途及未采用方案见 [归档索引](../../Database/legacy-sql-archive.md)。历史专题链接保留为证据，不是待执行清单。

当前数据库只使用 [full / clean 两个入口](../../Database/README.md)。新环境导入 clean；已有运营库须比较缺项并准备有备份的增量升级，不能直接重导初始化库。

仍使用的 [桌台归属只读检查](../../Tools/db/check-line-ownership.sql) 已移到工具目录。
