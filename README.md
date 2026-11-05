# MTH 运营后台

ASP.NET MVC5 / .NET Framework 4.8 / EF6 / MySQL 5.7。网站目录为 `TTY.Web`，程序集为 `YYT.Web`；通过命名管道与中心服、Robot 通信。

改功能前先读 [AGENTS.md](AGENTS.md) 和 [文档导航](Docs/README.md)，按 [三端功能影响图](../MTH-Server/docs/architecture/feature-impact-map.md) 列出受影响链路。新增子游戏从 [三端接入清单](../MTH-Server/docs/architecture/new-game-checklist.md) 开始，再完成 [后台接入清单](Docs/architecture/backend-new-game.md)。

- [当前后台功能与源码入口](Docs/architecture/backend-features.md)：页面、权限、参数、资金、控制、记录、机器人及客户端接口。
- [开发、验证与交付](Docs/architecture/backend-development.md)：本地环境、最短验证和部署依赖。
- [游戏接入矩阵](../MTH-Server/docs/architecture/game-integration-matrix.md)：确认每款游戏的能力与例外。
- [变更影响记录模板](../MTH-Server/docs/architecture/change-impact-template.md)：记录本次涉及/不涉及的模块及证据。

当前状态以源码和有产物清单的专题发布记录交叉核对；文档日期、提交、独立包、后台上线与 APK 发布不是同一件事。
