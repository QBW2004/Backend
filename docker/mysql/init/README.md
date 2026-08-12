# docker/mysql/init
# ============================================================
# MySQL 容器首次启动时的初始化 SQL(按文件名顺序自动导入)。
#
# 文件来源(全部从仓库现有文件复制生成, 勿直接编辑本目录):
#   00_mth.sql                     <- 根目录 mth.sql
#        (Navicat 从 MySQL 5.7.44 导出的基础表结构, 51 张表 + 存储过程)
#   10_动态桌台字段扩展.sql         <- Docs/sql/动态桌台字段扩展.sql
#   20_fix_scoreswitch_decimal.sql <- Docs/sql/fix_scoreswitch_decimal.sql
#        (注意: 副本已将表名改为小写 pararoom —— 原脚本的 ParaRoom 在
#         Linux 容器(MySQL 表名区分大小写)中会报 Table doesn't exist)
#   30_房间桌台配置表坐席扩列.sql    <- Docs/sql/房间桌台配置表坐席扩列.sql
#
# 注: 三个补丁对应 Tools/reset-db.ps1 中的 patche 列表,
#     保证 Docker 初始化与本机手工重置流程一致。
#
# 重新生成:
#   仅在这些文件被删除时需重新复制:
#     copy mth.sql docker\mysql\init\00_mth.sql
#     copy Docs\sql\动态桌台字段扩展.sql  docker\mysql\init\10_动态桌台字段扩展.sql
#     copy Docs\sql\fix_scoreswitch_decimal.sql docker\mysql\init\20_fix_scoreswitch_decimal.sql
#     copy Docs\sql\房间桌台配置表坐席扩列.sql  docker\mysql\init\30_房间桌台配置表坐席扩列.sql
#
# 注意: 初始化只会在数据卷首次创建时执行。
#   要重新导入(清空数据)使用: Tools\docker-db.bat reinit
#   或: docker-compose down -v && docker-compose up -d
