# deploy-template/ — MTH 服务端部署产物（随 skill 分发，不入 git）

配合 `.devin/skills/mth-server-deploy/SKILL.md` 使用——那是完整的部署手册。

| 文件 | 说明 | 来源 |
|---|---|---|
| `MTH-Server-Binaries_20261018.zip` (~161MB) | 游戏服二进制全集：28 个 `Server*` 目录的 `x64\Release\`（exe + Poco*.dll×14 + libmysql.dll + 状态文件 + 中心服 pdb）+ `servers.ini` + `mth_pipe.ps1` + `pipe_cmd.ps1` | 2026-10-18 自线上 `8.218.67.82` `C:\Server` 打包（当时在线运行版本） |
| `TTY.Web_1.0.62.zip` (~31MB) | 运营后台站点编译产物（WebVer 1.0.62） | 线上当前运行版（`Tools/deploy/pack.ps1` 产物） |
| `_raw_mth_full_20261018.sql` (~421KB) | ⚠️ 线上 mth 全量 dump（含真实玩家/代理/流水，**勿分发**，仅存档备灾） | 2026-10-18 22:39 mysqldump --routines --triggers |

数据库分发给外部的模板是 `.devin/skills/mth-server-deploy/assets/mth_template.sql`（清档版）。

## 快速上手（3 条命令，细节看 SKILL.md）

```powershell
# 在目标 Windows Server 上，管理员 PowerShell：
scripts\env-check.ps1                                    # 装 .NET4.8/IIS/MySQL5.7
scripts\import-db.ps1 -SqlFile assets\mth_template.sql   # 灌库（atmadmin/123456）
Expand-Archive MTH-Server-Binaries_*.zip C:\Server; scripts\install-autostart.ps1 -StartAllOnBoot
scripts\deploy-web.ps1 -SourcePath TTY.Web_1.0.62.zip -Port 8081 -Yes
scripts\open-ports.ps1; scripts\verify-deploy.ps1        # 防火墙 + 体检
```

## 重新生成产物（以后出新版本时）

```bash
# 后台站点 zip：本仓库根
Tools\dev\build.bat && powershell -File Tools\deploy\pack.ps1 -Version <x.y.z>

# 数据库模板：线上跑（勿在含真实数据的库上直接跑模板文件——它会整库覆盖）
#   参考 Tools/one-off/_pack_stage1.ps1：dump 全库 → 灌 scratch 库 → 跑 Docs/sql/上线清档 → 导出
# 游戏服 zip：参考 Tools/one-off/_pack_stage2.ps1（线上 C:\Server 打包）
```
