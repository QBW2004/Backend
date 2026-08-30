# -*- coding: utf-8 -*-
"""
手机端后台测试数据生成器（Add-Phone-Support 分支联调用）。

用法：
    python Tools/one-off/_seed_phone_testdata.py    # 生成 Docs/sql/手机端测试数据.sql
    docker exec -i mth-mysql mysql -uroot -p123456 --default-character-set=utf8mb4 mth < Docs/sql/手机端测试数据.sql

设计约束（与线上行为对齐，避免种子数据被站点定时任务"吃掉"）：
  - rechargerecords / agencyoptlog / useroptlog 受 7 天滚动清理（B_Records_MySQL），
    因此这三张表的时间一律落在最近 7 天内（用 NOW() - INTERVAL 相对时间，重跑仍是"最近"）。
  - loginmissrecord 的 LoginResult=0 记录会被定时任务在 5 分钟后清零 MissCount（自动解封，
    属于该页面的真实业务行为），种子时间设为 NOW() 附近，页面在站点启动后约 5 分钟内可见。
  - 所有种子账号使用固定号段（代理 96xxx、玩家 950000xx、流水单号 TS 前缀），
    脚本先按号段 DELETE 再 INSERT，可重复执行；绝不触碰 userlockrecord 旧数据。
  - 不给 userlockrecord 里的历史账号（yyyy22/z9889 等）造充退流水，避免触发的迁移定时任务
    向不存在的中心服发管道指令。
"""
import io
import os
import random

random.seed(20260830)

OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
                   "Docs", "sql", "手机端测试数据.sql")

# ---------------------------------------------------------------------------
# 代理层级（ID, PRIV, 上级, 邀请码, 是否禁用）
#   PRIV: 1=总代 2=一般代理 3=下级代理（与 AgencyRules 层级一致）
# ---------------------------------------------------------------------------
AGENTS = [
    # id     priv parent      invite enable
    ("96001", 1,   "atmadmin", "7001", 1),
    ("96002", 1,   "atmadmin", "7002", 1),
    ("96003", 1,   "atmadmin", "7003", 1),
    ("96101", 2,   "96001",    "7101", 1),
    ("96102", 2,   "96001",    "7102", 1),
    ("96103", 2,   "96001",    "7103", 1),
    ("96111", 2,   "1688",     "7111", 1),
    ("96201", 2,   "96002",    "7201", 1),
    ("96202", 2,   "96002",    "7202", 1),
    ("96301", 3,   "96101",    "7301", 1),
    ("96302", 3,   "96102",    "7302", 1),
    ("96311", 3,   "96201",    "7311", 1),
    ("96321", 3,   "8888",     "7321", 1),
    ("96501", 2,   "96003",    "7501", 0),   # 禁用中（BanAgent 页可见）
    ("96502", 2,   "96003",    "7502", 1),   # 有禁用→恢复历史记录
]
AGENT_IDS = [a[0] for a in AGENTS]

# 代理台账：COINS 余额 / RECHARGE 累计充值 / EXCHANGE 累计兑换 / COINS_BUY / COINS_BACK / 天数
AGENT_LEDGER = {
    "96001": (45000000, 128000000, 96000000, 120000000, 92000000, 300),
    "96002": (18000000,  66000000, 51000000,  60000000, 48000000, 210),
    "96003": ( 6600000,  22000000, 19500000,  21000000, 18400000, 120),
    "96101": ( 8800000,  33000000, 26500000,  30000000, 24800000, 180),
    "96102": ( 3200000,  15000000, 12800000,  14000000, 12100000, 150),
    "96103": ( 1150000,   6800000,  6100000,   6300000,  5800000,  90),
    "96111": ( 2400000,  12000000,  9900000,  11000000,  9200000, 160),
    "96201": (  980000,   5200000,  4700000,   4800000,  4400000,  75),
    "96202": (  420000,   2600000,  2450000,   2400000,  2280000,  60),
    "96301": (  640000,   3100000,  2980000,   2900000,  2760000,  45),
    "96302": (  260000,   1400000,  1320000,   1300000,  1240000,  30),
    "96311": (   88000,    520000,   505000,    480000,   462000,  25),
    "96321": (  150000,    900000,   860000,    820000,   790000,  20),
    "96501": ( 1200000,   8000000,  7600000,   7500000,  7150000,  55),
    "96502": (  350000,   1900000,  1830000,   1800000,  1720000,  50),
}

# 各代理权限位差异（让"我的代理"页权限标签有区分度）
AGENT_PERMS = {
    # IsUpDown IsFrozen IsKicking IsCreateAgent IsProbability IsKill IsRelease IsViewPwd IsModifyPwd
    "96001": (1, 1, 1, 1, 1, 0, 1, 1, 1),
    "96002": (1, 1, 0, 1, 0, 0, 0, 1, 1),
    "96003": (1, 1, 1, 1, 0, 1, 0, 1, 0),
    "96101": (1, 1, 1, 1, 1, 0, 0, 1, 1),
    "96102": (1, 1, 0, 1, 0, 0, 1, 1, 0),
    "96103": (1, 0, 1, 0, 0, 0, 0, 0, 0),
    "96111": (1, 1, 1, 1, 0, 1, 0, 1, 1),
    "96201": (1, 1, 1, 1, 0, 0, 0, 1, 1),
    "96202": (1, 0, 0, 0, 0, 0, 0, 0, 0),
    "96301": (1, 1, 1, 0, 0, 0, 0, 1, 0),
    "96302": (1, 1, 0, 0, 0, 0, 0, 0, 0),
    "96311": (1, 1, 1, 0, 0, 0, 0, 0, 0),
    "96321": (1, 1, 1, 0, 1, 0, 0, 1, 1),
    "96501": (1, 1, 1, 1, 0, 0, 1, 1, 1),
    "96502": (1, 0, 0, 0, 0, 0, 0, 0, 0),
}

# ---------------------------------------------------------------------------
# 玩家：95000001 ~ 95000066，分布到各代理（含存量代理 8888/10086/10010/1688）
# ---------------------------------------------------------------------------
PLAYER_PLAN = [
    ("8888",     6), ("10086", 6), ("10010", 4), ("1688",  4),
    ("96101",    8), ("96102", 6), ("96103", 5), ("96201", 6),
    ("96202",    4), ("96301", 4), ("96302", 3), ("96311", 3),
    ("96321",    3), ("55555555", 2), ("mtest001", 2),
]

NAMES = [
    "富婆爱养生", "阿豪不抽烟", "江湖小虾米", "淡定哥", "龙在天涯", "红中哥",
    "夜色温柔", "老K", "一枪爆头", "发财姐", "独钓寒江雪", "低调的奢华",
    "南城旧梦", "赌神高进", "蓝色妖姬", "土豪金", "半岛铁盒", "风一样的男子",
    "小仙女", "奶茶不加糖", "铁头娃", "一叶知秋", "深海鱼雷", "峰哥",
    "拉霸小王子", "玫瑰花的葬礼", "稳如老狗", "骚气冲天", "云顶之巅", "佛系玩家",
    "暴走的螃蟹", "柠檬精", "一夜暴富", "北巷不夏", "斗地主老爷子", "深巷老猫",
    "大金牙", "摇钱树", "清风徐来", "火凤凰本凰", "狗都不玩", "躺平大师",
    "榴莲忘返", "御风而行", "铁公鸡", "孤勇者", "白龙马", "财神爷附体",
    "迷失的小鹿", "铁血真汉子", "沉默的羔羊", "蜘蛛侠", "咸鱼翻身", "燃烧的蔬菜",
    "街角风铃", "狂野飙车", "麻将钉子户", "一枪一个小朋友", "金蟾进宝", "老板来杯奶茶",
    "键盘侠", "月光族", "过江龙", "卧龙先生", "皮皮虾", "天选打工人",
]

ONLINE_IDX = {1, 4, 7, 11, 17, 21, 24, 29, 33, 40, 45, 50, 57, 62}   # INHALL=1 在线
FROZEN_IDX = {9, 23, 41, 52, 64}                                      # 冻结玩家
# 手工指定的今日输赢（排序测试用：赢最多/输最多一眼可见），其余随机
TODAY_WINLOSS_FIX = {21: 258000, 33: 182400, 7: -198500, 40: -246000,
                     50: 96500, 24: -152000, 57: 128800, 62: -88000}

GAMES = [2, 3, 5, 6, 10, 15, 21, 29]        # games 表存在的 GameId（流水/在线状态展示用）
GAME_NAME = {2: "彩金单挑", 3: "金蟾捕鱼", 5: "火凤凰", 6: "_slot", 10: "_laba",
             15: "_laba2", 21: "_baire", 29: "_xuanwu"}
TEL_PREFIX = ["138", "139", "135", "188", "150", "152", "157", "158", "182", "185", "177", "131"]


def grade_of(buy):
    if buy >= 10000000: return 9
    if buy >= 6000000:  return 8
    if buy >= 3000000:  return 7
    if buy >= 1000000:  return 6
    if buy >= 500000:   return 5
    if buy >= 200000:   return 4
    if buy >= 50000:    return 3
    if buy >= 10000:    return 2
    return 1


def r100(v):
    """取整到百位"""
    return int(round(v / 100.0)) * 100


def build_players():
    players = []
    idx = 0
    uid = 880000
    for agency, cnt in PLAYER_PLAN:
        for _ in range(cnt):
            idx += 1
            uid += 1
            pid = 95000000 + idx
            name = NAMES[idx - 1]
            if idx in FROZEN_IDX:
                buy = r100(random.uniform(300000, 2600000))
            elif idx in (21, 33):
                buy = r100(random.uniform(12000000, 26000000))   # 大R
            elif idx % 9 == 0:
                buy = r100(random.uniform(1500, 9000))           # 穷人
            elif idx % 3 == 0:
                buy = r100(random.uniform(200000, 1500000))      # 中R
            else:
                buy = r100(random.uniform(12000, 400000))
            back_rate = random.uniform(0.52, 1.06)
            if idx in (33, 57):
                back_rate = random.uniform(1.10, 1.35)           # 总盈利为正的赢家
            back = r100(buy * back_rate)
            if idx in FROZEN_IDX:
                coins = r100(random.uniform(100000, 900000))
            elif idx % 7 == 0:
                coins = r100(random.uniform(30, 900))            # 快见底的
            else:
                coins = r100(max(200, (buy - back) * random.uniform(0.15, 0.85)
                                 + random.uniform(0, 60000)))
            safe = r100(random.uniform(0, 200000)) if idx % 2 == 0 else 0
            score = r100(random.uniform(0, 6000000)) if idx % 4 else 0
            tel = random.choice(TEL_PREFIX) + "".join(str(random.randint(0, 9)) for _ in range(8))
            players.append({
                "idx": idx, "id": str(pid), "name": name, "agency": agency,
                "uid": uid, "coins": coins, "buy": buy, "back": back,
                "safe": safe, "score": score, "grade": grade_of(buy),
                "tel": tel, "online": idx in ONLINE_IDX, "frozen": idx in FROZEN_IDX,
                "days": random.randint(2, 90), "sex": random.choice([1, 2]),
                "pic": random.randint(0, 9),
            })
    return players


def build_daily_winloss(players):
    """user_daily_winloss：今天 + 前 6 天；今天 8 成玩家有数据。"""
    rows = []
    for p in players:
        for d in range(7):
            if d == 0 and p["idx"] not in TODAY_WINLOSS_FIX and random.random() < 0.2:
                continue
            if p["idx"] in TODAY_WINLOSS_FIX and d == 0:
                wl = TODAY_WINLOSS_FIX[p["idx"]]
            else:
                wl = random.choice([
                    lambda: -int(random.uniform(200, 50000)),
                    lambda: -int(random.uniform(200, 50000)),
                    lambda: -int(random.uniform(200, 90000)),
                    lambda: int(random.uniform(200, 60000)),
                    lambda: int(random.uniform(200, 120000)),
                ])()
                wl = r100(wl)
            rows.append((p["id"], d, wl))
    return rows


def build_optlog(players):
    """useroptlog：每人 2~5 条；在线玩家最新一条是"正在玩"（近 40 分钟内），离线玩家最新一条是最后登录。"""
    rows = []
    for p in players:
        n = random.randint(2, 5)
        for k in range(n):
            latest = (k == n - 1)
            if latest:
                if p["online"]:
                    mins = random.randint(2, 40)
                    gt = random.choice(GAMES)
                    rows.append((p["id"], 2, r100(random.uniform(1000, 50000)),
                                 p["coins"], p["score"], random.randint(1, 6),
                                 random.randint(1, 24), random.randint(1, 8),
                                 gt, mins, "MINUTE"))
                else:
                    rows.append((p["id"], 1, 0, p["coins"], 0, 0, 0, 0, 0,
                                 random.randint(3, 160), "HOUR"))
            else:
                rows.append((p["id"], random.choice([1, 2]), r100(random.uniform(0, 30000)),
                             p["coins"], p["score"], random.randint(0, 6),
                             random.randint(0, 24), random.randint(0, 8),
                             random.choice(GAMES + [0]),
                             random.randint(1, 160), "HOUR"))
    return rows


def build_recharge(players):
    """rechargerecords：最近 7 天约 110 条，今天占比高；TS 单号前缀保证幂等清理。"""
    by_agency = {}
    for p in players:
        by_agency.setdefault(p["agency"], []).append(p)
    # 每代理出几条流水；直接全局随机挑玩家
    plan = ([("20", 38), ("21", 24), ("22", 10), ("23", 6),
             ("30", 18), ("31", 14)])
    rows = []
    seq = 0
    for rtype, cnt in plan:
        for _ in range(cnt):
            seq += 1
            p = random.choice(players)
            if rtype == "20":
                coin = r100(random.uniform(100, 200000))
            elif rtype == "21":
                coin = r100(random.uniform(100, 150000))
            elif rtype == "22":
                coin = r100(random.uniform(500, 50000))
            elif rtype == "23":
                coin = r100(random.uniform(500, 30000))
            elif rtype == "30":
                coin = r100(random.uniform(100, 100000))
            else:
                coin = r100(random.uniform(100, 80000))
            bef = max(0, int(p["coins"] * random.uniform(0.3, 1.4)))
            if rtype in ("20", "22", "30"):
                aft = bef + coin
            else:
                aft = max(0, bef - coin)
            # 前端充提 2 成待处理（Recharge 页待办可见）
            processed = 1
            if rtype in ("30", "31") and random.random() < 0.22:
                processed = 0
            operator = "NULL"
            payno = "NULL"
            if rtype in ("20", "21", "22", "23"):
                operator = random.choice(["atmadmin", p["agency"],
                                          AGENT_PARENT.get(p["agency"], "atmadmin")])
                operator = "'%s'" % operator
            else:
                payno = "'TSPY%08d'" % seq
            if random.random() < 0.35:   # 今天的流水（几分钟~11 小时前）
                t = "NOW() - INTERVAL %d MINUTE" % random.randint(3, 660)
            else:
                t = "NOW() - INTERVAL %d HOUR" % random.randint(13, 166)
            rows.append((seq, rtype, coin, bef, aft, p, processed, operator, payno, t))
    return rows


AGENT_PARENT = {a[0]: a[2] for a in AGENTS}

CONTROL_ROWS = [
    # userid, mode, gameId, target, consumed, granted, killratio, status, createdby, created(-m), expired
    # status: 0 执行中 1 过期 2 手动关闭
    (95000021, 4, 0, 200000, 65000, 0, 6, 0, "atmadmin", 125, "NULL"),
    (95000040, 5, 0, 150000, 0, 48000, 4, 0, "96001", 42, "NULL"),
    (95000029, 6, 12, 8, 0, 0, 2, 0, "atmadmin", 15, "DATE_ADD(NOW(), INTERVAL 2 HOUR)"),
    (95000007, 4, 0, 80000, 82000, 0, 5, 1, "atmadmin", 3230, "NOW() - INTERVAL 1490 MINUTE"),
    (95000045, 4, 0, 300000, 301500, 0, 8, 1, "96101", 5900, "NOW() - INTERVAL 4600 MINUTE"),
    (95000033, 5, 0, 100000, 0, 101200, 3, 1, "atmadmin", 4400, "NOW() - INTERVAL 3000 MINUTE"),
    (95000055, 6, 15, 10, 0, 0, 6, 1, "96201", 8700, "NOW() - INTERVAL 7300 MINUTE"),
    (95000050, 4, 0, 150000, 43000, 0, 7, 2, "atmadmin", 7100, "NOW() - INTERVAL 6100 MINUTE"),
    (95000060, 5, 0, 60000, 0, 21000, 2, 2, "96002", 2900, "NOW() - INTERVAL 1800 MINUTE"),
]

ABNORMAL = [
    # 账号, MissCount, IP（LoginResult=0；站点跑 5 分钟后会被定时任务自动清零解封）
    ("95000007", 5,  "112.49.240.88"),
    ("95000023", 12, "106.6.150.32"),
    ("95000041", 8,  "39.144.8.117"),
    ("95000057", 6,  "115.205.231.161"),
    ("96003",    17, "223.104.55.187"),
    ("mtest001", 9,  "112.49.240.228"),
    ("ghost777", 23, "171.88.66.21"),      # 不存在的账号 → 页面类型"未知"
    ("95000015", 2,  "113.57.182.44"),     # 未达锁定阈值，页面不展示
]

AGENCY_OPTLOG = [
    # OptID, ID, DestUserTitle(封号提示/说明), OPT, BEF, AFT, 相对分钟
    ("atmadmin", "96501", "违规使用外挂脚本，禁用账号", 24, 1, 0, 2900),
    ("atmadmin", "96502", "长期未活跃，临时禁用",       24, 1, 0, 7300),
    ("atmadmin", "96502", "禁用已解除",                 25, 1, 1, 4300),
    ("atmadmin", "96103", "投诉核查，临时禁用",         24, 1, 0, 8600),
    ("atmadmin", "96103", "禁用已解除",                 25, 1, 1, 5800),
]

INVITE_USED = {"7001": 21, "7101": 29, "7102": 33, "7201": 40, "7003": 45}


def q(s):
    return "'" + str(s).replace("\\", "\\\\").replace("'", "''") + "'"


def main():
    players = build_players()
    player_ids = [p["id"] for p in players]
    pid_in = ",".join("'%s'" % p for p in player_ids)
    agent_in = ",".join("'%s'" % a for a in AGENT_IDS)

    out = io.open(OUT, "w", encoding="utf-8", newline="\n")
    w = out.write

    w("-- ============================================================\n")
    w("-- 手机端后台测试数据（由 Tools/one-off/_seed_phone_testdata.py 生成，勿手改）\n")
    w("-- 灌库：docker exec -i mth-mysql mysql -uroot -p123456 --default-character-set=utf8mb4 mth < 本文件\n")
    w("-- 账号号段：代理 96xxx / 玩家 950000xx / 充退单号 TS 前缀，重复执行先清后插（幂等）。\n")
    w("-- 时间一律 NOW()-INTERVAL 相对值；流水/日志仅落最近 7 天（站点定时任务会清 7 天前数据）。\n")
    w("-- ============================================================\n")
    w("SET NAMES utf8mb4;\n\n")

    w("-- ---- 0. 清理旧种子数据（幂等） ----\n")
    w("DELETE FROM rechargerecords WHERE OrderNo LIKE 'TS%';\n")
    w("DELETE FROM useroptlog WHERE UserID IN (%s);\n" % pid_in)
    w("DELETE FROM user_daily_winloss WHERE UserID IN (%s);\n" % pid_in)
    w("DELETE FROM usercontrolstatus WHERE GameType = 9 AND UserID IN (%s);\n" % pid_in)
    w("DELETE FROM usercontrolvalue WHERE USERID IN (%s);\n" % pid_in)
    w("DELETE FROM userrelations WHERE ID IN (%s);\n" % pid_in)
    w("DELETE FROM users WHERE ID IN (%s);\n" % pid_in)
    w("DELETE FROM admin WHERE ID IN (%s);\n" % agent_in)
    w("DELETE FROM agencyoptlog WHERE ID IN (%s) AND OPT IN (24, 25);\n" % agent_in)
    w("DELETE FROM loginmissrecord WHERE ID IN (%s);\n"
      % ",".join("'%s'" % a[0] for a in ABNORMAL))
    w("DELETE FROM invite_codes WHERE AgentID IN (%s) OR UsedBy IN (%s);\n\n" % (agent_in, pid_in))

    # ---- 1. 代理 ----
    w("-- ---- 1. 代理（我的代理/添加代理/禁用代理） ----\n")
    w("UPDATE admin SET COINS = 888888888 WHERE ID = 'atmadmin';\n")
    w("UPDATE admin SET COINS = 20000000 WHERE ID = 'mtest001';\n")
    w("UPDATE admin SET COINS = 5000000 WHERE ID = '55555555';\n")
    for aid, priv, parent, invite, enable in AGENTS:
        coins, rech, exch, buy, back, days = AGENT_LEDGER[aid]
        up, fz, kick, ca, prob, kill, rel, vp, mp = AGENT_PERMS[aid]
        w("INSERT INTO admin (ID,PWD,PRIV,AGENCY,COINS,RECHARGE,EXCHANGE,COINS_BUY,COINS_BACK,"
          "RE_ENABLE,IsUpDown,IsFrozen,IsProbability,IsKicking,IsCreateAgent,IsViewPwd,IsModifyPwd,"
          "IsKill,IsRelease,InviteCode,CommissionRate,CreateTime) VALUES "
          "(%s,'123456',%d,%s,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%s,%.2f,"
          "NOW() - INTERVAL %d DAY);\n"
          % (q(aid), priv, q(parent), coins, rech, exch, buy, back, enable,
             up, fz, prob, kick, ca, vp, mp, kill, rel, q(invite),
             random.uniform(0.12, 0.30), days))
    w("\n")

    # ---- 2. 玩家 + 关系表 ----
    w("-- ---- 2. 玩家（玩家列表/会员盈亏/冻结账号/玩家详情） ----\n")
    for p in players:
        w("INSERT INTO users (ID,NAME,PWD,AGENCY,PIC_INDEX,FROZEN,COINS,COINS_EXP,COINS_BUY,"
          "COINS_BACK,VIDEOGAMEID,WXHEADIMG,SEX,LoginType,TELEPHONE,INHALL,IsRegister,GAME_SCORE,"
          "SAFE_PWD,SAFE_COINS,GRADE,CreateTime,Remark) VALUES "
          "(%s,%s,'123456',%s,%d,%d,%d,0,%d,%d,-1,'nowxheadimg',%d,0,%s,%d,1,%d,'123456',%d,%d,"
          "NOW() - INTERVAL %d DAY,'') ;\n"
          % (q(p["id"]), q(p["name"]), q(p["agency"]), p["pic"], 1 if p["frozen"] else 0,
             p["coins"], p["buy"], p["back"], p["sex"], q(p["tel"]),
             1 if p["online"] else 0, p["score"], p["safe"], p["grade"], p["days"]))
    w("\nINSERT INTO userrelations (UserID, ID) VALUES\n")
    rel = [("(%d, '%s')" % (p["uid"], p["id"])) for p in players]
    w(",\n".join(rel) + ";\n")
    # 执行中总控的目标玩家需要有像样的余额，否则"吃分20万/余额500"一眼假
    for _pid, _coins in ((21, 1580000), (40, 830000), (29, 326000)):
        w("UPDATE users SET COINS = %d WHERE ID = '950000%02d';\n" % (_coins, _pid))
    w("\n")

    # ---- 3. 今日/近 7 日输赢 ----
    wl = build_daily_winloss(players)
    w("-- ---- 3. 每日输赢（头部『今日玩家总输赢』+ 会员盈亏排序） ----\n")
    w("INSERT INTO user_daily_winloss (UserID, DAY, WINLOSS) VALUES\n")
    lines = []
    for pid, d, v in wl:
        lines.append("(%s, DATE_SUB(CURDATE(), INTERVAL %d DAY), %d)" % (q(pid), d, v))
    w(",\n".join(lines) + ";\n\n")

    # ---- 4. 玩家操作日志（在线状态/最后登录/玩家流水） ----
    ol = build_optlog(players)
    w("-- ---- 4. 玩家操作日志（在线『正在玩』+ 最后登录时间 + 玩家流水） ----\n")
    w("INSERT INTO useroptlog (UserID, OPT, OPT_COINS, COINS, SCORE, ROOM, TABLE_ID, SEAT_ID, "
      "GAME_TYPE, REC_TIME, REC_WEEK) VALUES\n")
    lines = []
    for pid, opt, optcoins, coins, score, room, table, seat, gt, n, unit in ol:
        lines.append("(%s, %d, %d, %d, %d, %d, %d, %d, %d, NOW() - INTERVAL %d %s, %d)"
                     % (q(pid), opt, optcoins, coins, score, room, table, seat, gt, n, unit, 35))
    w(",\n".join(lines) + ";\n\n")

    # ---- 5. 充退流水 ----
    rc = build_recharge(players)
    w("-- ---- 5. 充退流水（充值管理待办 + 充退记录页，最近 7 天） ----\n")
    w("INSERT INTO rechargerecords (OrderNo, RechargeType, Coin, BEF_COINS, AFT_COINS, GameID, "
      "AccountType, Agency, PayNo, Processed, CreateTime, Operator) VALUES\n")
    lines = []
    for seq, rtype, coin, bef, aft, p, processed, operator, payno, t in rc:
        lines.append("('TS%08d', %s, %d, %d, %d, %s, 0, %s, %s, %d, %s, %s)"
                     % (seq, rtype, coin, bef, aft, q(p["id"]), q(p["agency"]),
                        payno, processed, t, operator))
    w(",\n".join(lines) + ";\n\n")

    # ---- 6. 异常登录锁定（冻结明细页；5 分钟后会被自动解封） ----
    w("-- ---- 6. 异常登录锁定（冻结明细页） ----\n")
    for acc, miss, ip in ABNORMAL:
        w("INSERT INTO loginmissrecord (ID, LoginResult, MissCount, IPAddr, LoginTime) VALUES "
          "(%s, 0, %d, %s, NOW() - INTERVAL %d MINUTE);\n"
          % (q(acc), miss, q(ip), random.randint(0, 4)))
    w("\n")

    # ---- 7. 代理禁用/恢复记录（禁用代理页） ----
    w("-- ---- 7. 代理禁用/恢复记录（禁用代理页列表） ----\n")
    for optid, target, title, opt, bef, aft, mins in AGENCY_OPTLOG:
        w("INSERT INTO agencyoptlog (OptID, SrcUserTitle, ID, DestUserTitle, REC_TIME, OPT, "
          "COINS, BEF_COINS, AFT_COINS, WEEK) VALUES "
          "(%s, %s, %s, %s, NOW() - INTERVAL %d MINUTE, %d, 0, %d, %d, 35);\n"
          % (q(optid), q(optid), q(target), q(title), mins, opt, bef, aft))
    w("\n")

    # ---- 8. 总控记录（控制管理页；GameType=9 总控，mode 4吃分/5送分/6控牌） ----
    w("-- ---- 8. 总控记录（控制管理页） ----\n")
    for uid_, mode, gid, target, consumed, granted, kr, status, by, cmins, exp in CONTROL_ROWS:
        w("INSERT INTO usercontrolstatus (UserID, GameType, GameId, ControlMode, TargetCoins, "
          "ConsumedCoins, GrantedCoins, LimitCoins, KillRatio, Status, CreatedBy, CreatedTime, "
          "ExpiredTime) VALUES "
          "(%s, 9, %d, %d, %d, %d, %d, 0, %d, %d, %s, NOW() - INTERVAL %d MINUTE, %s);\n"
          % (q(str(uid_)), gid, mode, target, consumed, granted, kr, status, q(by), cmins, exp))
    # 控牌次数回显（usercontrolvalue：CONTROL_TYPE=GameId，NUMBER>0 才会显示）
    w("INSERT INTO usercontrolvalue (USERID, GAME_TYPE, CONTROL_TYPE, CONTROL_VALUE, NUMBER, "
      "TOTAL_NUMBER) VALUES ('95000029', 1, 12, 2, 8, 20), ('95000055', 1, 15, 6, 0, 10);\n\n")

    # ---- 9. 邀请码 ----
    w("-- ---- 9. 邀请码（玩家详情页展示注册来源） ----\n")
    for aid, priv, parent, invite, enable in AGENTS:
        used_by = INVITE_USED.get(invite)
        if used_by:
            w("INSERT INTO invite_codes (InviteCode, AgentID, AgentLevel, IsUsed, UsedBy, UsedTime, "
              "CreateTime) VALUES (%s, %s, %d, 1, %s, NOW() - INTERVAL %d DAY, NOW() - INTERVAL %d DAY);\n"
              % (q(invite), q(aid), priv, q(str(95000000 + used_by)),
                 random.randint(2, 60), random.randint(2, 80)))
        else:
            w("INSERT INTO invite_codes (InviteCode, AgentID, AgentLevel, IsUsed, CreateTime) VALUES "
              "(%s, %s, %d, 0, NOW() - INTERVAL %d DAY);\n"
              % (q(invite), q(aid), priv, random.randint(1, 60)))
    w("\n")

    out.close()

    online = sum(1 for p in players if p["online"])
    frozen = sum(1 for p in players if p["frozen"])
    today_rows = sum(1 for _, d, _ in wl if d == 0)
    today_sum = sum(v for _, d, v in wl if d == 0)
    pending = sum(1 for r in rc if r[6] == 0)
    print("OK -> %s" % OUT)
    print("代理 %d 个（禁用中 2 个） | 玩家 %d 个（在线 %d / 冻结 %d）" % (len(AGENTS), len(players), online, frozen))
    print("每日输赢 %d 行（今天 %d 行，合计 %s）" % (len(wl), today_rows, format(today_sum, "+,")))
    print("操作日志 %d 行 | 充退流水 %d 条（待处理 %d） | 总控 %d 条 | 异常锁定 %d 条"
          % (len(ol), len(rc), pending, len(CONTROL_ROWS), len(ABNORMAL)))


if __name__ == "__main__":
    main()
