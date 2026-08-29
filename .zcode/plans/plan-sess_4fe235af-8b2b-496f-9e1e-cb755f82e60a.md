# 手机端后台 1:1 复刻参考站点（mmttqq.sbs:1099）实施方案

## 目标
将 `TTY.Web/Areas/Mobile` 手机端后台整体替换为参考站点的样式与交互（1:1），并接入项目现有登录/权限/`/Game/*` 数据接口。参考底稿用 `Phone/_reference/` 里已保存的逐页 DOM 快照（真实站点抓取），逐页对照截图验收。

## 页面清单（12 页）

| # | 参考页面 | 本项目落地 | 数据来源 |
|---|---|---|---|
| 1 | houtai.html 登录页 | 新增 `/Mobile/Login`（新 LoginController + Login.cshtml，DOM/CSS 按线上页复刻，实施时 curl 抓取原页源码） | 复用 LoginController 登录逻辑（抽出公共校验方法），成功后跳 `/Mobile/Home/Index` |
| 2 | wanjialist 玩家列表 | 重写 `Index.cshtml` | 现有 `GetOnlineUsers/GetUsers/KickPlayer/FrozenUser/ChgPwd/QueryPlayerCoins` + 新增"今日总输赢"接口 |
| 3 | kaidaili 添加代理 | 重写 `AddAgent.cshtml` | 现有 `CanAddAgency/AddAgencyInfo` |
| 4 | wodedaili 我的代理 | 重写 `Agents.cshtml` | 现有 `GetAgencies/SetRecharge/DeleteAdmin/ChgPwd` 等 |
| 5 | chongzhi 玩家充退 | 重写 `Recharge.cshtml` | 现有 `QueryCoins/SaveCoin` |
| 6 | chongzhilist 充退记录 | 重写 `Records.cshtml` | 改接 `GetReChargeRecords`（按参考站语义为充退流水） |
| 7 | yichangzhanghu 异常账号 | 新增 `Abnormal.cshtml` | 新接口：查 `LoginMissRecord`（连续登录失败锁定的账号，玩家/代理分类计数、锁定原因=失败次数+IP+时间）+ 解封（重置计数） |
| 8 | fenghao 玩家封号 | 新增 `BanPlayer.cshtml` | 封禁/解禁用现有 `FrozenUser`；新增封禁列表查询（`Users.FROZEN!=0`） |
| 9 | dailifenghao 代理封号 | 新增 `BanAgent.cshtml` | 封禁用现有 `SetRecharge(RE_ENABLE=0)`；新增封禁代理列表查询 |
| 10 | daililahei 代理拉黑 | 新增 `Blacklist.cshtml` | 新接口：拉黑=代理 `RE_ENABLE=0` + 按范围（直属/非直属/所有）级联冻结其玩家（用现有 `GetAgencyLineAccounts` 等层级工具），记录影响玩家/代理数与操作日志 |
| 11 | songjiang 送奖管理 | 新增 `Songjiang.cshtml` | 基于现有 `SaveGive`（赠送，流水类型22）+ 风控（玩家在线 `INHALL`、送奖金额≤今日输赢）；记录用 `GetReChargeRecords(22)` |
| 12 | huiyuanyingkui 会员盈亏 | 新增 `Huiyuan.cshtml`（无参考 DOM，用 `Phone/_preview/04_会员盈亏详情.png` 原型稿） | 新接口：按玩家聚合 今日输赢(`user_daily_winloss`) + 总盈亏(`COINS_BUY-COINS_BACK`)，分页+筛选 |

菜单 = 参考站 8 项 + 新增 3 项（代理拉黑/送奖管理/会员盈亏，"我的会员"死链接活为会员盈亏），保留 管理员卡片/邀请码/修改密码/退出登录，按现有权限位（IsSuper/CanCreateAgent/CanUpDown/CanFrozen…）显隐。

## 已知偏差（参考站依赖其游戏服，本项目无对应子系统）
- **送奖管理**：牌型赔率、奖池、实时押注读取依赖参考站游戏服，本项目游戏服不支持。页面 UI 1:1 复刻，后端按"带风控的赠送"简化落地；奖池/牌型字段保留展示但仅作备注，不参与金额计算。
- **代理拉黑**："吃分金额"（扣钱）语义不实现（涉及资金扣减，且无数据来源），拉黑=封禁+级联冻结，列表展示影响玩家/代理数、操作人、时间。
- **封号提示/封禁时间**：数据库无现成字段，不做表结构变更；列表展示账号+操作（代理拉黑的封号提示存入现有操作日志）。

## 技术方案
- **共享资产**：新增 `Content/css/phone.css`（从参考页提取的共享设计系统：#007aff 蓝头部、卡片、表格、弹窗、toast、按钮）；`js-base64` 落地到本地 `Scripts/lib/`（去掉 jsDelivr CDN 依赖）。新 JS 走 `Scripts/app/phone/phone.core.js` + 每页一个 `phone.<page>.js`，复用现有 mobile.core.js 的成熟机制（防伪 token 自动附加、`code==-1` 登录超时跳转、toast/loading/modal）。
- **布局**：重写 `_MobileLayout.cshtml` 为参考站外壳（蓝头部+汉堡抽屉+返回按钮），保留 `window.MConfig` 服务端权限注入与防伪表单。
- **视图/控制器**：重写 HomeController 5 个 action，新增 7 个 action（权限校验沿用 ViewBag perms 模式）；新增 `Mobile/LoginController`（不带 MemberAuthorize）；`MemberAuthorizeAttribute` 改为区域感知：Mobile 区域未登录 GET 跳 `/Mobile/Login`，AJAX POST 仍返回超时 JSON；`phone.core.js` 超时跳转同步改 `/Mobile/Login`。桌面端 `/Login`、`/Mgr` 完全不动。
- **新后端接口**（Game 区域，沿用 `[AjaxOnly][HttpPost][MemberAuthorize]` + `Msg`/`{total,rows}` 形状）：`UserInfo/GetTodayWinLoss`、`UserInfo/GetFrozenUsers`、`AgencyInfo/GetBannedAgencies`、新增 `Game/AbnormalController`（列表+解封）、`AgencyInfo/BlacklistAgent`（含级联）、会员盈亏查询接口。全部只用现有表，不改表结构。
- **csproj**：老式项目文件，所有新增 .cshtml/.js/.css/.cs 需手工登记进 `YYT.Web.csproj`。

## 实施步骤
1. curl 抓取 houtai.html 登录页源码，连同 `_reference` 各页 DOM 作为底稿。
2. 后端先行：抽取登录公共逻辑 + 新增各 JSON 接口 + MemberAuthorize 区域感知，编译通过。
3. 前端资产：phone.css / phone.core.js / base64 本地化 / 布局重写。
4. 按页面逐个迁移：先 5 个已有页（重写），再 7 个新页；每页接真实接口。
5. csproj 登记，整体编译，本地跑起来用浏览器逐页打开，与 `_reference` 截图对照修正（视觉验收）。

## 验证
- 项目编译零错误；浏览器实际登录→逐页走通（玩家列表/增删改查/封禁等真实数据操作只做只读验证，写操作验证到接口调用成功即止）；每页与参考截图并排比对布局、配色、文案。
