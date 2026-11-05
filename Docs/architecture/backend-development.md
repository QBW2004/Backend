# 后台开发、验证与交付

先按 [功能影响面](backend-features.md) 选需要验证的链路；生产边界与资金口径见 [AGENTS](../../AGENTS.md)。本页合并旧通用性能/部署草案，只保留适用于当前 MVC5/IIS 仓库的做法。

## 本地环境与构建

- 解决方案 `MTH_Mgr_MySQL.sln`；`Tools/dev/build.bat noclean` 做最短增量 Release，完整构建去掉 `noclean`。脚本会补 .NET4.8 引用程序集/Web targets，不能把本机缺工作负载误判为代码失败。
- `Tools/dev/start.ps1` 启 IIS Express；运行前核对数据库及管道指向隔离环境。MySQL5.7需 `lower_case_table_names=1`，环境详见 [Docker数据库](../docker-mysql.md) 与 [工具索引](../../Tools/README.md)。
- `Tools/db/reset-db.ps1`、docker reinit、`env-check.ps1` 默认安装等不是只读命令。只读检查使用对应参数；不为验证页面自动重建真实库。
- 老式csproj新增文件必须登记；Razor视图保留UTF-8 BOM，应用池64位v4.0 Integrated。Web.config、程序实际引用和发布包不能用一份工作区文件推断。

## 按影响选择验证

| 改动 | 优先入口 | 补充验证 |
|---|---|---|
| 纯文档 | 链接、源码路径/方法、删除引用、diff检查 | 无需启动应用或业务回归 |
| 权限/控制规则 | UnitTestProj `AgencyRulesTest/LineScopeRulesTest/TotalControlRulesTest` | 实际Controller请求：本人/下级/跨线/无权限/令牌失败 |
| 页面/共享JS | `node --check` + 对应 `tests/*.browser.cjs`/`Tools/dev/check-*-ui.*` | 两端真实交互；中文编码、长内容、空值、恢复默认、迟到请求 |
| 桌台/活动/资金 | `Tools/dev/check-line-tables.ps1`、`check-rabbit-remaining.ps1`、`check-prize-pool.ps1`、`check-player-winloss.ps1` | 真实BLL/临时MySQL、事务失败、并发/重放、实际HTTP序列化、服务端报文 |
| RTP/权重 | `tests/rabbit-rtp.test.js`、`phenix-rtp.test.js`、`mjhl-rtp-*.test.*`、UnitTestProj相关数学测试 | 同随机输入逐步对拍、完整免费链、非默认权重、实际浏览器正式复核后可保存 |
| 视图或发布包 | 隔离完整站点 `aspnet_compiler` | DLL真实依赖与新方法、静态资源齐全；登录页200不能替代业务视图编译 |
| 只改页面样式 | 快速浏览器或2–3分钟明确人工步骤 | 不为无关布局跑联网下注/全部游戏 |

不要固定抄“多少条测试永远失败”。旧 `UnitTestProj/App.config` 的MySQL provider/失效连接问题按当次输出识别；只读副本中如需排除无引用且缺FengBo的遗留partial，记录准确文件，不能改生产页面隐藏新错误。

## 玩家列表与手机交互的现行验收

旧方案声称“离线无控制”“所有控制多行展示”“已提升60–75%”，均不能作为当前验收结论。源码当前有在线/离线控制、列表同包controls、按权限每人一条和缓存失效机制，历史百分比只是预期目标。

1. 选与问题相符的隔离数据规模，记录首次可见、接口响应、完整可操作时间；至少冷启动与重复进入各一次，报告设备、网络与数量。不能用首页HTTP200代替功能/性能通过。
2. 在线与离线各测试搜索、排序、分页、连续刷新、旧响应晚到；无控制/控牌与吃放共存/耗尽后切回，确认BLL展示口径和权限没有因缓存改变。
3. 控制数据优先随列表同包；兼容补查必须批量，不能每个卡片单独请求。旧响应不得追加到已切换账号/列表，刷新/设置控制后缓存失效按当前实现验证。
4. QA失败应明确失败并保留上次列表/人数；成功空列表才显示无人。`SConnect.ReadLineWithTimeout` 的超时与熔断不能替换成无限阻塞读取。
5. 滚动到页面中下部打开弹窗，确定/取消可点；叠加提示解除全部滚动锁后恢复原位置。`pagehide` abort、隐藏页暂停与不弹幽灵网络错误须保留。
6. HTML动态值转义；视图readonly/disabled不是授权，Controller仍校验。没有测到的设备/线上状态明确列为未验证。

## 发布与回滚证据

1. 先确认用户授权的组件/SQL/维护范围，读取实际线上基线；其它任务改动通过隔离工作树/站点排除。此文不是发布或数据修正授权。
2. 用 `Tools/deploy/pack.ps1 -Version <版本> -SourcePath <隔离完整站点>` 打包，检查Web/BLL/Entity/Remote的实际依赖；静态页改动也需检查共享脚本版本与缓存。
3. SQL只执行本次明确需要的迁移，按现有表/列/索引/触发器/存储过程检测缺项；先备份包含 routines/triggers 的数据库。不得照旧性能指南每次机械重跑迁移或全表改历史资金。
4. 服务端协议/回执/分片变更按共享依赖成套发布与回滚；后台保存成功不证明旧子游戏能接收。保护运行期 `App_Data/Logs/Upload`，别用全仓覆盖线上隔离基线。
5. 部署脚本按实际参数执行，核对最终服务器副本、进程位数、SSH生命周期与维护窗口；不用旧Linux占位命令、强推Git或`iisreset`模板代替既有Windows发布流程。
6. 交付记录写版本/提交/文件清单、哈希、SQL、备份、实际测试/耗时、部署和未验事项。源码提交、隔离包、后台上线、服务端上线、客户端APK分别记，不推断同步完成。

历史故障依据：[BLL漏发](../机器人账户批量删除缺失依赖修复-20261101.md)、[配置JSON序列化](../大白兔规则读取与JSON回包修复-20261104.md)、[后台1.0.106隔离发布](../后台1.0.106与服务端发布-20261105.md)。最新发布列表见 [文档导航](../README.md)，不要把这里的示例当当前运行版本。
