/*
 Navicat Premium Data Transfer

 Source Server         : localhost
 Source Server Type    : MySQL
 Source Server Version : 50744
 Source Host           : 127.0.0.1:3306
 Source Schema         : mth

 Target Server Type    : MySQL
 Target Server Version : 50744
 File Encoding         : 65001

 Date: 02/07/2026 15:07:56
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for accountlog
-- ----------------------------
DROP TABLE IF EXISTS `accountlog`;
CREATE TABLE `accountlog`  (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `UserName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `CreateTime` datetime(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0),
  `PlayGame` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `IP` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of accountlog
-- ----------------------------

-- ----------------------------
-- Table structure for activity
-- ----------------------------
DROP TABLE IF EXISTS `activity`;
CREATE TABLE `activity`  (
  `ID` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `TITLE` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '活动标题',
  `ACTIVITY` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '活动内容',
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '活动管理表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of activity
-- ----------------------------

-- ----------------------------
-- Table structure for admin
-- ----------------------------
DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin`  (
  `ID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '账号',
  `PWD` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码',
  `PRIV` int(11) NOT NULL DEFAULT -1 COMMENT '代理层级',
  `AGENCY` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '上级代理',
  `COINS` bigint(20) NOT NULL DEFAULT 0 COMMENT '金币数量',
  `RECHARGE` bigint(20) NOT NULL DEFAULT 0 COMMENT '充值数量',
  `EXCHANGE` bigint(20) NOT NULL DEFAULT 0 COMMENT '兑换数量',
  `COINS_BUY` bigint(20) NOT NULL DEFAULT 0 COMMENT '购币数',
  `COINS_BACK` bigint(20) NOT NULL DEFAULT 0 COMMENT '退币数',
  `RE_ENABLE` int(11) NOT NULL DEFAULT 0 COMMENT '是否启用  0不启用  1启用',
  `AGENCY_LIMIT` int(11) NOT NULL DEFAULT 0 COMMENT '分代上限',
  `IsUpDown` int(11) NOT NULL DEFAULT 1 COMMENT '上下分权限 0无 1有',
  `IsFrozen` int(11) NOT NULL DEFAULT 0 COMMENT '冻结权限',
  `IsProbability` int(11) NOT NULL DEFAULT 0 COMMENT '是否有几率控制权限(点杀放水)',
  `IsKicking` int(11) NOT NULL DEFAULT 0 COMMENT '踢人权限',
  `KickScope` int(11) NOT NULL DEFAULT 1 COMMENT '踢人范围',
  `IsDelete` int(11) NOT NULL DEFAULT 0 COMMENT '删除权限',
  `IsGift` int(11) NOT NULL DEFAULT 0 COMMENT '赠送权限',
  `IsCreateAgent` int(11) NOT NULL DEFAULT 0 COMMENT '开代理权限',
  `IsViewPwd` int(11) NOT NULL DEFAULT 0 COMMENT '查看密码权限',
  `IsModifyPwd` int(11) NOT NULL DEFAULT 0 COMMENT '修改密码权限',
  `IsResetSafePwd` int(11) NOT NULL DEFAULT 0 COMMENT '重置保险密码权限',
  `ManageScope` int(11) NOT NULL DEFAULT 1 COMMENT '管理范围 1仅直属 2全部下级',
  `InviteCode` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '邀请码',
  `CommissionRate` decimal(32, 2) NULL DEFAULT NULL COMMENT '佣金比例',
  `CustomerServiceUrl` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '客服链接',
  `CreateTime` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `UpdateTime` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `IsKill` int(11) NOT NULL DEFAULT 0,
  `IsRelease` int(11) NOT NULL DEFAULT 0,
  `IsViewSafePwd` int(11) NOT NULL DEFAULT 0,
  `IsModifySafePwd` int(11) NOT NULL DEFAULT 0,
  `IsCardKill` int(11) NOT NULL DEFAULT 0 COMMENT '牌机点杀权限',
  `IsCardRelease` int(11) NOT NULL DEFAULT 0 COMMENT '牌机放水权限',
  PRIMARY KEY (`ID`) USING BTREE,
  UNIQUE INDEX `idx_invite_code`(`InviteCode`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '管理、代理信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of admin
-- ----------------------------
INSERT INTO `admin` VALUES ('10010', '123456', 3, '10086', 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 2, 0, 0, 1, 0, 0, 0, 2, '6666', 0.00, NULL, '2026-05-24 22:54:46', '2026-05-24 23:06:14', 1, 1, 0, 0, 0, 0);
INSERT INTO `admin` VALUES ('10086', '123456', 2, '1688', 19958999, 41001, 0, 20000000, 0, 1, 0, 1, 1, 1, 1, 2, 1, 0, 1, 0, 0, 0, 2, '1088', 0.00, NULL, '2026-05-21 20:43:15', '2026-05-26 12:13:55', 1, 1, 0, 0, 1, 1);
INSERT INTO `admin` VALUES ('1688', 'zxc1.2.3.', 1, 'admin', 199996500, 9000, 5500, 200000000, 0, 1, 0, 1, 1, 1, 1, 2, 1, 0, 0, 0, 1, 0, 2, '8188', 0.00, NULL, '2026-05-21 20:07:32', '2026-05-23 17:42:22', 1, 1, 0, 0, 1, 1);
INSERT INTO `admin` VALUES ('55555555', '1.2.3.', 1, 'admin', 0, 0, 0, 2, 2, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, '1000', 0.00, NULL, '2026-04-30 17:29:15', '2026-05-23 17:42:01', 0, 0, 0, 0, 0, 0);
INSERT INTO `admin` VALUES ('8888', 'qwe@8899', 2, '1688', 50000, 0, 0, 50000, 0, 1, 0, 1, 1, 1, 1, 2, 0, 0, 1, 0, 0, 0, 2, '88888', 0.00, NULL, '2026-05-21 20:08:34', '2026-05-23 17:38:05', 1, 1, 0, 0, 1, 1);
INSERT INTO `admin` VALUES ('admin', '123456', 0, '', 0, 2673036880, 111021886, 0, 0, 1, 6, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, NULL, 0.00, 'www.baidu.com', '2026-04-15 16:49:42', '2026-06-05 15:39:42', 0, 0, 0, 0, 1, 1);

-- ----------------------------
-- Table structure for agencyoptlog
-- ----------------------------
DROP TABLE IF EXISTS `agencyoptlog`;
CREATE TABLE `agencyoptlog`  (
  `LID` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '日志标识ID',
  `OptID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '操作人账号',
  `SrcUserTitle` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '操作人账号类型',
  `ID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '被操作账号',
  `DestUserTitle` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '被操作人账号类型',
  `REC_TIME` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0),
  `OPT` tinyint(4) NOT NULL DEFAULT 0 COMMENT '充值/兑换',
  `COINS` bigint(20) NOT NULL DEFAULT 0 COMMENT '操作金币量',
  `BEF_COINS` bigint(20) NOT NULL DEFAULT 0 COMMENT '操作前金币量',
  `AFT_COINS` bigint(20) NOT NULL DEFAULT 0 COMMENT '操作后金币量',
  `WEEK` tinyint(4) NOT NULL DEFAULT 0 COMMENT '周数',
  PRIMARY KEY (`LID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 146 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '代理日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of agencyoptlog
-- ----------------------------
INSERT INTO `agencyoptlog` VALUES (101, 'admin', '超级管理', 'admin', '超级管理', '2026-06-17 17:57:38', 2, 0, 0, 0, 25);
INSERT INTO `agencyoptlog` VALUES (102, 'admin', '超级管理', 'admin', '超级管理', '2026-06-17 17:58:24', 2, 0, 0, 0, 25);
INSERT INTO `agencyoptlog` VALUES (103, 'admin', '超级管理', 'admin', '超级管理', '2026-06-17 18:10:13', 2, 0, 0, 0, 25);
INSERT INTO `agencyoptlog` VALUES (104, 'admin', '超级管理', 'admin', '超级管理', '2026-06-18 20:10:09', 2, 0, 0, 0, 25);
INSERT INTO `agencyoptlog` VALUES (105, 'admin', '超级管理', 'admin', '超级管理', '2026-06-22 10:35:24', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (106, 'admin', '超级管理', 'admin', '超级管理', '2026-06-22 12:05:42', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (107, 'admin', '超级管理', 'admin', '超级管理', '2026-06-22 14:00:20', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (108, 'admin', '超级管理', 'admin', '超级管理', '2026-06-22 14:10:19', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (109, 'admin', '超级管理', 'admin', '超级管理', '2026-06-22 16:48:59', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (110, 'admin', '超级管理', 'admin', '超级管理', '2026-06-22 17:35:48', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (111, 'admin', '超级管理', 'admin', '超级管理', '2026-06-22 17:59:55', 3, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (112, 'admin', '超级管理', 'admin', '超级管理', '2026-06-22 17:59:57', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (113, 'admin', '超级管理', 'admin', '超级管理', '2026-06-22 18:00:34', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (114, 'admin', '超级管理', 'admin', '超级管理', '2026-06-22 18:01:08', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (115, 'admin', '超级管理', 'admin', '超级管理', '2026-06-22 19:07:59', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (116, 'admin', '超级管理', 'admin', '超级管理', '2026-06-23 09:42:41', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (117, 'admin', '超级管理', 'admin', '超级管理', '2026-06-23 10:27:03', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (118, 'admin', '超级管理', 'admin', '超级管理', '2026-06-23 11:29:34', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (119, 'admin', '超级管理', 'admin', '超级管理', '2026-06-23 13:45:45', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (120, 'admin', '超级管理', 'admin', '超级管理', '2026-06-23 13:50:55', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (121, 'admin', '超级管理', 'admin', '超级管理', '2026-06-24 14:06:45', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (122, 'admin', '超级管理', 'admin', '超级管理', '2026-06-26 09:43:34', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (123, 'admin', '超级管理', 'admin', '超级管理', '2026-06-26 14:48:01', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (124, 'admin', '超级管理', 'admin', '超级管理', '2026-06-26 14:55:00', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (125, 'admin', '超级管理', 'admin', '超级管理', '2026-06-26 14:56:22', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (126, 'admin', '超级管理', 'admin', '超级管理', '2026-06-26 15:00:52', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (127, 'admin', '超级管理', 'admin', '超级管理', '2026-06-26 15:03:05', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (128, 'admin', '超级管理', 'admin', '超级管理', '2026-06-26 16:51:15', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (129, 'admin', '超级管理', 'admin', '超级管理', '2026-06-26 18:41:21', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (130, 'admin', '超级管理', 'admin', '超级管理', '2026-06-26 20:19:42', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (131, 'admin', '超级管理', 'admin', '超级管理', '2026-06-26 22:04:35', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (132, 'admin', '超级管理', 'admin', '超级管理', '2026-06-26 22:04:58', 2, 0, 0, 0, 26);
INSERT INTO `agencyoptlog` VALUES (133, 'admin', '超级管理', 'admin', '超级管理', '2026-06-29 19:10:24', 2, 0, 0, 0, 27);
INSERT INTO `agencyoptlog` VALUES (134, 'admin', '超级管理', 'admin', '超级管理', '2026-06-30 10:02:02', 2, 0, 0, 0, 27);
INSERT INTO `agencyoptlog` VALUES (135, 'admin', '超级管理', 'admin', '超级管理', '2026-06-30 10:17:42', 2, 0, 0, 0, 27);
INSERT INTO `agencyoptlog` VALUES (136, 'admin', '超级管理', 'admin', '超级管理', '2026-06-30 10:18:15', 2, 0, 0, 0, 27);
INSERT INTO `agencyoptlog` VALUES (137, 'admin', '超级管理', 'admin', '超级管理', '2026-06-30 10:38:07', 2, 0, 0, 0, 27);
INSERT INTO `agencyoptlog` VALUES (138, 'admin', '超级管理', 'admin', '超级管理', '2026-06-30 11:42:15', 2, 0, 0, 0, 27);
INSERT INTO `agencyoptlog` VALUES (139, 'admin', '超级管理', 'admin', '超级管理', '2026-06-30 14:53:07', 2, 0, 0, 0, 27);
INSERT INTO `agencyoptlog` VALUES (140, 'admin', '超级管理', 'admin', '超级管理', '2026-06-30 15:45:28', 2, 0, 0, 0, 27);
INSERT INTO `agencyoptlog` VALUES (141, 'admin', '超级管理', 'admin', '超级管理', '2026-06-30 15:47:10', 2, 0, 0, 0, 27);
INSERT INTO `agencyoptlog` VALUES (142, 'admin', '超级管理', 'admin', '超级管理', '2026-06-30 18:16:50', 2, 0, 0, 0, 27);
INSERT INTO `agencyoptlog` VALUES (143, 'admin', '超级管理', 'admin', '超级管理', '2026-07-01 16:43:49', 2, 0, 0, 0, 27);
INSERT INTO `agencyoptlog` VALUES (144, 'admin', '超级管理', 'admin', '超级管理', '2026-07-01 20:57:08', 2, 0, 0, 0, 27);
INSERT INTO `agencyoptlog` VALUES (145, 'admin', '超级管理', 'admin', '超级管理', '2026-07-02 14:22:51', 2, 0, 0, 0, 27);

-- ----------------------------
-- Table structure for agent_hierarchy
-- ----------------------------
DROP TABLE IF EXISTS `agent_hierarchy`;
CREATE TABLE `agent_hierarchy`  (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `AgentID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '代理账号',
  `ParentID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '上级代理',
  `Level` int(11) NOT NULL COMMENT '层级 1-8',
  `Path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '层级路径 如: admin/agent1/agent2',
  `CreateTime` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`ID`) USING BTREE,
  INDEX `idx_agent`(`AgentID`) USING BTREE,
  INDEX `idx_parent`(`ParentID`) USING BTREE,
  INDEX `idx_level`(`Level`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '代理层级关系表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of agent_hierarchy
-- ----------------------------

-- ----------------------------
-- Table structure for agent_permission_template
-- ----------------------------
DROP TABLE IF EXISTS `agent_permission_template`;
CREATE TABLE `agent_permission_template`  (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Level` int(11) NOT NULL COMMENT '代理层级 1-8',
  `TemplateName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '模板名称',
  `IsUpDown` int(11) NULL DEFAULT 1,
  `IsFrozen` int(11) NULL DEFAULT 1,
  `IsProbability` int(11) NULL DEFAULT 0,
  `IsKicking` int(11) NULL DEFAULT 1,
  `KickScope` int(11) NULL DEFAULT 1,
  `IsDelete` int(11) NULL DEFAULT 0,
  `IsGift` int(11) NULL DEFAULT 0,
  `IsCreateAgent` int(11) NULL DEFAULT 0,
  `IsViewPwd` int(11) NULL DEFAULT 0,
  `IsModifyPwd` int(11) NULL DEFAULT 0,
  `IsResetSafePwd` int(11) NULL DEFAULT 0,
  `ManageScope` int(11) NULL DEFAULT 1,
  `IsKill` int(11) NOT NULL DEFAULT 0 COMMENT '注机点杀权限',
  `IsRelease` int(11) NOT NULL DEFAULT 0 COMMENT '注机放水权限',
  `IsCardKill` int(11) NOT NULL DEFAULT 0 COMMENT '牌机点杀权限',
  `IsCardRelease` int(11) NOT NULL DEFAULT 0 COMMENT '牌机放水权限',
  PRIMARY KEY (`ID`) USING BTREE,
  UNIQUE INDEX `idx_level`(`Level`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '代理权限模板表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of agent_permission_template
-- ----------------------------
INSERT INTO `agent_permission_template` VALUES (1, 1, '一级代理默认权限', 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 2, 1, 1, 1, 1);
INSERT INTO `agent_permission_template` VALUES (2, 2, '二级代理默认权限', 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0);
INSERT INTO `agent_permission_template` VALUES (3, 3, '三级代理默认权限', 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0);
INSERT INTO `agent_permission_template` VALUES (4, 4, '四级代理默认权限', 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0);
INSERT INTO `agent_permission_template` VALUES (5, 5, '五级代理默认权限', 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0);
INSERT INTO `agent_permission_template` VALUES (6, 6, '六级代理默认权限', 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0);
INSERT INTO `agent_permission_template` VALUES (7, 7, '七级代理默认权限', 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0);
INSERT INTO `agent_permission_template` VALUES (8, 8, '八级代理默认权限', 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0);

-- ----------------------------
-- Table structure for cardpayoutprofile
-- ----------------------------
DROP TABLE IF EXISTS `cardpayoutprofile`;
CREATE TABLE `cardpayoutprofile`  (
  `ID` int(11) NOT NULL AUTO_INCREMENT COMMENT '唯一自增主键',
  `GAME_ID` int(11) NOT NULL COMMENT '关联的游戏ID',
  `TableId` int(11) NOT NULL COMMENT '牌机具体机台号',
  `HandType` int(11) NOT NULL COMMENT '牌型枚举 (杂牌/同花等)',
  `PayoutMultiplier` int(11) NOT NULL DEFAULT 0 COMMENT '赔率倍数',
  `ProbabilityBasis` int(11) NOT NULL DEFAULT 0 COMMENT '出货概率基数 (权重)',
  `StockLimit` bigint(20) NOT NULL DEFAULT 0 COMMENT '当前机台最高库存限制',
  `StockRemain` bigint(20) NOT NULL DEFAULT 0 COMMENT '当前剩余库存',
  `Enabled` int(11) NOT NULL DEFAULT 1 COMMENT '是否启用此牌型',
  PRIMARY KEY (`ID`) USING BTREE,
  INDEX `idx_game_table_hand`(`GAME_ID`, `TableId`, `HandType`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '牌机出货与库存配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cardpayoutprofile
-- ----------------------------

-- ----------------------------
-- Table structure for cashierinfo
-- ----------------------------
DROP TABLE IF EXISTS `cashierinfo`;
CREATE TABLE `cashierinfo`  (
  `CID` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收款人信息标识ID',
  `Name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收款人姓名',
  `Account` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收款账号（微信/支付宝账号）',
  `Agency` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '所属代理ID',
  `QRCodeImg` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '收款二维码',
  `PayType` tinyint(4) NULL DEFAULT NULL COMMENT '收款类型  1微信  2支付宝',
  `UseQRCodeImg` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否设置为收款码 0不设置 1设置',
  `Enable` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否启用  0不启用  1启用',
  `CreateTime` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  PRIMARY KEY (`CID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '收款信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cashierinfo
-- ----------------------------

-- ----------------------------
-- Table structure for clientexchangerecord
-- ----------------------------
DROP TABLE IF EXISTS `clientexchangerecord`;
CREATE TABLE `clientexchangerecord`  (
  `CRID` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '标识ID',
  `ID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户账号',
  `Coins` bigint(20) NOT NULL COMMENT '下分',
  `WxPay` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '用户微信号',
  `AliPayName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '支付宝账户名',
  `AliPay` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '用户支付宝号',
  `AccountName` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '银行账户名',
  `BankAccount` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '用户银行账号',
  `BankName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '开户银行名称',
  `BranchBankName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '开户支行名称',
  `Processed` int(11) NULL DEFAULT 0 COMMENT '处理状态 0未处理 1确认下分 2取消下分 3服务器已处理',
  `OptID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '处理人账号',
  `Agency` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '所属代理',
  `ProcessTime` datetime(0) NULL DEFAULT NULL COMMENT '处理时间',
  `CreateTime` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '记录生成时间',
  PRIMARY KEY (`CRID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '客户端下分记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of clientexchangerecord
-- ----------------------------

-- ----------------------------
-- Table structure for ex_change
-- ----------------------------
DROP TABLE IF EXISTS `ex_change`;
CREATE TABLE `ex_change`  (
  `ID` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID 主键',
  `PLAYER_ID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '玩家账号',
  `COINS` bigint(20) NULL DEFAULT NULL COMMENT '兑换的金币',
  `PHONE_NUMBER` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号码',
  `PWD` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '游戏密码',
  `CREATE_TIME` datetime(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `AGENCY` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '所属代理',
  `STATUS` int(11) NULL DEFAULT 0 COMMENT '状态，默认0未处理，1已处理，2已拒绝',
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '兑换记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ex_change
-- ----------------------------

-- ----------------------------
-- Table structure for gameacclaba
-- ----------------------------
-- [LabaFruit] 列类型对齐 C++ ts_LabaAcc (Int64), 原 int(11) 最大 21 亿有溢出风险
DROP TABLE IF EXISTS `gameacclaba`;
CREATE TABLE `gameacclaba`  (
  `GameId` int(11) NOT NULL,
  `Stock` bigint(20) NULL DEFAULT NULL,
  `MiniJackpot` bigint(20) NULL DEFAULT NULL,
  `MidJackpot` bigint(20) NULL DEFAULT NULL,
  `LargeJackpot` bigint(20) NULL DEFAULT NULL,
  PRIMARY KEY (`GameId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gameacclaba
-- ----------------------------
INSERT INTO `gameacclaba` VALUES (16, 0, 0, 0, 204800);
INSERT INTO `gameacclaba` VALUES (39, 0, 0, 0, 204800);
INSERT INTO `gameacclaba` VALUES (40, 0, 0, 0, 204800);
INSERT INTO `gameacclaba` VALUES (41, 0, 0, 0, 204800);
INSERT INTO `gameacclaba` VALUES (53, 0, 0, 0, 204800);

-- ----------------------------
-- Table structure for gamecommandoutbox
-- ----------------------------
DROP TABLE IF EXISTS `gamecommandoutbox`;
CREATE TABLE `gamecommandoutbox`  (
  `CommandId` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `CommandType` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `TargetUserId` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Payload` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `Status` int(11) NOT NULL DEFAULT 0,
  `RawResponse` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `ErrorMessage` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `RetryCount` int(11) NOT NULL DEFAULT 0,
  `CreatedAt` datetime(0) NOT NULL,
  `SentAt` datetime(0) NULL DEFAULT NULL,
  `LastTriedAt` datetime(0) NULL DEFAULT NULL,
  `NextRetryAt` datetime(0) NULL DEFAULT NULL,
  `UpdatedAt` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`CommandId`) USING BTREE,
  INDEX `IX_GameCommandOutbox_Status`(`Status`) USING BTREE,
  INDEX `IX_GameCommandOutbox_TargetUserId`(`TargetUserId`) USING BTREE,
  INDEX `IX_GameCommandOutbox_NextRetryAt`(`NextRetryAt`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '游戏服务命令Outbox' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gamecommandoutbox
-- ----------------------------
INSERT INTO `gamecommandoutbox` VALUES ('c47c712f380b471da5d01c39fcce5644', 'UL', 'test01', '{\"RechargeType\":0,\"Result\":1,\"Coins\":999999,\"UserAccount\":\"test01\"}', 3, '数据发送失败！管道尚未连接。', '数据发送失败！管道尚未连接。', 5, '2026-06-17 17:56:57', '2026-06-17 18:03:57', '2026-06-17 18:04:07', '2026-06-17 18:08:17', '2026-06-17 18:04:07');

-- ----------------------------
-- Table structure for gameconfiglaba
-- ----------------------------
DROP TABLE IF EXISTS `gameconfiglaba`;
CREATE TABLE `gameconfiglaba`  (
  `GameId` int(11) NOT NULL COMMENT '用户账号',
  `OptKey` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '功能',
  `OptValue` int(11) NOT NULL COMMENT '控值',
  `Type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `TIME` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '设置时间',
  PRIMARY KEY (`GameId`, `OptKey`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '机率控制记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gameconfiglaba
-- ----------------------------
INSERT INTO `gameconfiglaba` VALUES (16, 'Payout0', 2, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (16, 'Payout1', 3, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (16, 'Payout2', 4, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (16, 'Payout3', 5, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (16, 'Payout4', 8, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (16, 'Payout5', 10, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (16, 'Payout6', 15, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (16, 'Payout7', 30, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (40, 'Payout0', 2, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (40, 'Payout1', 3, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (40, 'Payout2', 4, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (40, 'Payout3', 5, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (40, 'Payout4', 8, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (40, 'Payout5', 10, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (40, 'Payout6', 15, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (40, 'Payout7', 30, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (53, 'Payout0', 2, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (53, 'Payout1', 3, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (53, 'Payout2', 4, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (53, 'Payout3', 5, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (53, 'Payout4', 8, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (53, 'Payout5', 10, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (53, 'Payout6', 15, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (53, 'Payout7', 30, 'Payout', '2026-07-01 22:30:32');

-- [LabaFruit-P0] 拉霸档位配置（Type='Room' 区分于赔付的 'Payout'）
-- 水果拉霸 GameId=40
INSERT INTO `gameconfiglaba` VALUES (40, 'betMin',           100, 'Room', '2026-07-06 00:00:00');
INSERT INTO `gameconfiglaba` VALUES (40, 'betMax',         10000, 'Room', '2026-07-06 00:00:00');
INSERT INTO `gameconfiglaba` VALUES (40, 'coinsNeed',          0, 'Room', '2026-07-06 00:00:00');
INSERT INTO `gameconfiglaba` VALUES (40, 'defaultBetIndex',    0, 'Room', '2026-07-06 00:00:00');
-- 明星97 GameId=16
INSERT INTO `gameconfiglaba` VALUES (16, 'betMin',           100, 'Room', '2026-07-06 00:00:00');
INSERT INTO `gameconfiglaba` VALUES (16, 'betMax',         10000, 'Room', '2026-07-06 00:00:00');
INSERT INTO `gameconfiglaba` VALUES (16, 'coinsNeed',          0, 'Room', '2026-07-06 00:00:00');
INSERT INTO `gameconfiglaba` VALUES (16, 'defaultBetIndex',    0, 'Room', '2026-07-06 00:00:00');
-- 水浒传 GameId=53（10 种符号，还需 Payout8/Payout9）
INSERT INTO `gameconfiglaba` VALUES (53, 'betMin',           100, 'Room', '2026-07-06 00:00:00');
INSERT INTO `gameconfiglaba` VALUES (53, 'betMax',         10000, 'Room', '2026-07-06 00:00:00');
INSERT INTO `gameconfiglaba` VALUES (53, 'coinsNeed',          0, 'Room', '2026-07-06 00:00:00');
INSERT INTO `gameconfiglaba` VALUES (53, 'defaultBetIndex',    0, 'Room', '2026-07-06 00:00:00');
-- 水浒传第9/10种符号赔付倍率（补齐 10 符号）
INSERT INTO `gameconfiglaba` VALUES (53, 'Payout8', 20, 'Payout', '2026-07-06 00:00:00');
INSERT INTO `gameconfiglaba` VALUES (53, 'Payout9', 30, 'Payout', '2026-07-06 00:00:00');

-- ----------------------------
-- Table structure for gamemo
-- ----------------------------
DROP TABLE IF EXISTS `gamemo`;
CREATE TABLE `gamemo`  (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `GameMoType` tinyint(4) NULL DEFAULT 1 COMMENT '游戏模式1 真金模式2金币模式',
  `GameMoName` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gamemo
-- ----------------------------
INSERT INTO `gamemo` VALUES (1, 0, '模式设置');

-- ----------------------------
-- Table structure for gamepara
-- ----------------------------
DROP TABLE IF EXISTS `gamepara`;
CREATE TABLE `gamepara`  (
  `PID` int(11) NOT NULL AUTO_INCREMENT COMMENT '标识ID',
  `ParaType` int(11) NOT NULL COMMENT '参数类型',
  `GameId` int(11) NOT NULL COMMENT '游戏ID',
  `OptName` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '功能名称',
  `OptVal` int(11) NOT NULL COMMENT '控值',
  `CtrlGroup` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '控件分组',
  `CtrlLabel` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '控件标签',
  `CtrlType` int(11) NULL DEFAULT 0 COMMENT '控件类型 0文本框 1数字框 2下拉框 3单选框',
  `CtrlValType` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'String' COMMENT '参数值类型',
  `CtrlIsNullable` tinyint(4) NULL DEFAULT 0 COMMENT '是否可空值 0不可以 1可以',
  `CtrlOrder` int(11) NOT NULL DEFAULT 0 COMMENT '排序',
  `Remark` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`PID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '游戏参数信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gamepara
-- ----------------------------

-- ----------------------------
-- Table structure for games
-- ----------------------------
DROP TABLE IF EXISTS `games`;
CREATE TABLE `games`  (
  `GameId` int(11) NOT NULL COMMENT '游戏ID',
  `Name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '游戏名称',
  `Enable` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否启用  0不启用  1启用',
  `GameType` tinyint(4) NOT NULL COMMENT '游戏类型   0押注类  1牌机类  2鱼机类  3其它类',
  `Num` int(10) NULL DEFAULT 0 COMMENT '机器人数量',
  PRIMARY KEY (`GameId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '游戏信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of games
-- ----------------------------
INSERT INTO `games` VALUES (1, '骰宝', 0, 0, 0);
INSERT INTO `games` VALUES (2, '彩金单挑', 1, 0, 0);
INSERT INTO `games` VALUES (3, '金蟾捕鱼', 1, 2, 0);
INSERT INTO `games` VALUES (4, '捕鱼达人', 0, 2, 0);
INSERT INTO `games` VALUES (5, '火凤凰', 1, 1, 0);
INSERT INTO `games` VALUES (6, '牛魔王', 1, 2, 0);
INSERT INTO `games` VALUES (7, '三色鳄鱼', 0, 2, 0);
INSERT INTO `games` VALUES (8, 'ATT连环炮', 0, 1, 0);
INSERT INTO `games` VALUES (9, '人鱼传说', 0, 1, 0);
INSERT INTO `games` VALUES (10, '幸运六狮', 1, 0, 0);
INSERT INTO `games` VALUES (11, '3D猎鸟', 0, 2, 0);
INSERT INTO `games` VALUES (12, '幸运牛牛', 0, 0, 0);
INSERT INTO `games` VALUES (13, '李逵劈鱼', 1, 2, 0);
INSERT INTO `games` VALUES (14, '金皇冠', 1, 1, 0);
INSERT INTO `games` VALUES (15, '大字板', 1, 1, 0);
INSERT INTO `games` VALUES (16, '明星97', 1, 3, 0);
INSERT INTO `games` VALUES (17, '海王2', 0, 2, 0);
INSERT INTO `games` VALUES (18, '西游争霸', 0, 0, 0);
INSERT INTO `games` VALUES (19, '摇钱树', 1, 2, 0);
INSERT INTO `games` VALUES (20, 'Ring捕鱼', 0, 2, 0);
INSERT INTO `games` VALUES (21, '双响金龙鱼', 1, 2, 0);
INSERT INTO `games` VALUES (22, '空战英豪', 0, 2, 0);
INSERT INTO `games` VALUES (23, '火麒麟', 0, 2, 0);
INSERT INTO `games` VALUES (24, 'ATT至尊版', 0, 1, 0);
INSERT INTO `games` VALUES (25, 'ATT满花板', 0, 1, 0);
INSERT INTO `games` VALUES (26, '三色龙', 0, 0, 0);
INSERT INTO `games` VALUES (27, '铁甲飞龙', 0, 2, 0);
INSERT INTO `games` VALUES (28, '极速飞车', 0, 0, 0);
INSERT INTO `games` VALUES (29, '金鲨银鲨', 1, 0, 0);
INSERT INTO `games` VALUES (30, '钻石大亨', 0, 2, 0);
INSERT INTO `games` VALUES (31, '八鲨闹海', 0, 2, 0);
INSERT INTO `games` VALUES (32, '神龙宝藏', 1, 2, 0);
INSERT INTO `games` VALUES (33, '史前巨鳄', 1, 2, 0);
INSERT INTO `games` VALUES (34, '双响企鹅', 0, 2, 0);
INSERT INTO `games` VALUES (35, '娱乐红蟹', 0, 2, 0);
INSERT INTO `games` VALUES (36, 'ATT超级至尊', 0, 1, 0);
INSERT INTO `games` VALUES (37, 'ATT3', 0, 1, 0);
INSERT INTO `games` VALUES (38, '3D捕鱼', 0, 2, 0);
INSERT INTO `games` VALUES (39, '糖果派对', 0, 3, 0);
INSERT INTO `games` VALUES (40, '水果拉霸', 1, 3, 0);
INSERT INTO `games` VALUES (41, '财神发发发', 0, 3, 0);
INSERT INTO `games` VALUES (42, '八爪鱼', 0, 2, 0);
INSERT INTO `games` VALUES (43, '龙太子', 0, 0, 0);
INSERT INTO `games` VALUES (44, 'NBA', 1, 1, 0);
INSERT INTO `games` VALUES (45, '真人百家乐', 0, 3, 0);
INSERT INTO `games` VALUES (46, '大兵小将', 0, 1, 0);
INSERT INTO `games` VALUES (47, '奔驰宝马', 1, 0, 0);
INSERT INTO `games` VALUES (49, '美人鱼', 1, 2, 0);
INSERT INTO `games` VALUES (53, '水浒传', 1, 3, 0);

-- ----------------------------
-- Table structure for games_money_spent
-- ----------------------------
DROP TABLE IF EXISTS `games_money_spent`;
CREATE TABLE `games_money_spent`  (
  `USERID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户账号',
  `GameId` int(11) NOT NULL COMMENT '游戏ID',
  `Money` int(11) NOT NULL DEFAULT 0 COMMENT '花费的钱',
  PRIMARY KEY (`USERID`, `GameId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '游戏信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of games_money_spent
-- ----------------------------

-- ----------------------------
-- Table structure for invite_codes
-- ----------------------------
DROP TABLE IF EXISTS `invite_codes`;
CREATE TABLE `invite_codes`  (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `InviteCode` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '邀请码',
  `AgentID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '所属代理',
  `AgentLevel` int(11) NOT NULL COMMENT '代理层级',
  `IsUsed` int(11) NOT NULL DEFAULT 0 COMMENT '是否已使用 0未使用 1已使用',
  `UsedBy` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '使用者账号',
  `UsedTime` datetime(0) NULL DEFAULT NULL COMMENT '使用时间',
  `CreateTime` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`ID`) USING BTREE,
  UNIQUE INDEX `idx_code`(`InviteCode`) USING BTREE,
  INDEX `idx_agent`(`AgentID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '邀请码管理表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of invite_codes
-- ----------------------------

-- ----------------------------
-- Table structure for loginmissrecord
-- ----------------------------
DROP TABLE IF EXISTS `loginmissrecord`;
CREATE TABLE `loginmissrecord`  (
  `LMID` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '标识ID',
  `ID` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户账号',
  `LoginResult` int(11) NULL DEFAULT 0 COMMENT '登录结果  0失败  1成功',
  `MissCount` int(11) NULL DEFAULT 0 COMMENT '登录失败次数',
  `IPAddr` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT 'ip地址',
  `LoginTime` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '登录时间',
  PRIMARY KEY (`LMID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 254 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户登录错误记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of loginmissrecord
-- ----------------------------
INSERT INTO `loginmissrecord` VALUES (205, 'admin', 1, 0, '::1', '2026-07-02 14:22:51');
INSERT INTO `loginmissrecord` VALUES (206, '12345', 1, 0, '112.49.240.88', '2023-08-14 15:13:08');
INSERT INTO `loginmissrecord` VALUES (207, '00000', 1, 0, '106.6.150.32', '2023-08-14 14:47:59');
INSERT INTO `loginmissrecord` VALUES (208, '11111', 0, 0, '106.6.150.32', '2023-08-14 12:02:26');
INSERT INTO `loginmissrecord` VALUES (209, '88888', 1, 0, '112.49.240.228', '2023-08-27 20:31:55');
INSERT INTO `loginmissrecord` VALUES (210, '999', 1, 0, '39.144.8.117', '2023-08-17 18:37:12');
INSERT INTO `loginmissrecord` VALUES (211, '33333', 1, 0, '112.49.240.228', '2023-08-26 14:09:59');
INSERT INTO `loginmissrecord` VALUES (212, '66666', 1, 0, '115.205.231.161', '2026-05-06 17:46:20');
INSERT INTO `loginmissrecord` VALUES (213, '888888', 1, 0, '117.44.84.129', '2023-09-06 19:25:24');
INSERT INTO `loginmissrecord` VALUES (214, '555', 1, 0, '39.144.10.49', '2023-08-27 12:12:12');
INSERT INTO `loginmissrecord` VALUES (215, '77777', 1, 0, '103.27.25.149', '2023-08-27 22:32:17');
INSERT INTO `loginmissrecord` VALUES (216, '22222', 1, 0, '117.136.75.71', '2023-08-28 00:52:26');
INSERT INTO `loginmissrecord` VALUES (217, 'yyyy11', 0, 0, '8.222.169.148', '2023-08-29 00:54:52');
INSERT INTO `loginmissrecord` VALUES (218, '99999', 0, 0, '43.243.157.217', '2023-09-02 16:51:05');
INSERT INTO `loginmissrecord` VALUES (219, '666666', 1, 0, '43.243.157.217', '2023-09-28 14:19:04');
INSERT INTO `loginmissrecord` VALUES (220, 'Administrator', 0, 0, '116.167.37.152', '2023-09-04 16:57:19');
INSERT INTO `loginmissrecord` VALUES (221, '123456789', 0, 0, '116.167.37.152', '2023-09-25 13:21:24');
INSERT INTO `loginmissrecord` VALUES (222, '123456', 1, 0, '116.167.37.152', '2023-09-09 21:29:18');
INSERT INTO `loginmissrecord` VALUES (223, '222222', 0, 0, '116.167.37.152', '2023-11-15 22:05:24');
INSERT INTO `loginmissrecord` VALUES (224, '333333', 1, 0, '119.41.235.195', '2023-09-15 14:11:11');
INSERT INTO `loginmissrecord` VALUES (225, '555555', 0, 0, '119.41.225.123', '2023-11-15 22:05:36');
INSERT INTO `loginmissrecord` VALUES (226, '777777', 1, 0, '183.254.25.235', '2023-09-07 16:08:19');
INSERT INTO `loginmissrecord` VALUES (227, '55555', 0, 0, '139.189.20.230', '2023-09-08 10:12:14');
INSERT INTO `loginmissrecord` VALUES (228, '999999', 1, 0, '116.167.36.160', '2023-09-23 16:51:04');
INSERT INTO `loginmissrecord` VALUES (229, '112233', 1, 0, '119.41.225.23', '2023-09-22 22:46:26');
INSERT INTO `loginmissrecord` VALUES (230, 'dong12345', 0, 0, '36.101.158.187', '2023-09-14 21:17:49');
INSERT INTO `loginmissrecord` VALUES (231, '460006198511124831', 0, 0, '39.144.69.222', '2023-09-15 17:59:42');
INSERT INTO `loginmissrecord` VALUES (232, '686868', 1, 0, '117.136.13.58', '2023-09-29 18:59:38');
INSERT INTO `loginmissrecord` VALUES (233, '686868', 1, 0, '117.136.13.58', '2023-09-21 14:33:41');
INSERT INTO `loginmissrecord` VALUES (234, '11233', 0, 0, '39.144.69.201', '2023-09-22 22:46:07');
INSERT INTO `loginmissrecord` VALUES (235, '11223344', 0, 0, '39.144.69.201', '2023-09-22 22:46:18');
INSERT INTO `loginmissrecord` VALUES (236, 'test01', 1, 0, '151.242.36.181', '2026-05-21 14:11:41');
INSERT INTO `loginmissrecord` VALUES (237, '1011', 1, 0, '203.160.80.45', '2026-05-21 18:28:31');
INSERT INTO `loginmissrecord` VALUES (238, '8888', 1, 0, '110.189.205.253', '2026-05-21 20:10:45');
INSERT INTO `loginmissrecord` VALUES (239, 'a123123', 0, 0, '8.222.251.116', '2026-04-29 22:04:38');
INSERT INTO `loginmissrecord` VALUES (240, '1088', 1, 0, '182.239.92.151', '2026-05-21 03:21:42');
INSERT INTO `loginmissrecord` VALUES (241, '55555555', 1, 0, '203.160.80.45', '2026-05-18 16:26:44');
INSERT INTO `loginmissrecord` VALUES (242, 'qwe@8899', 0, 0, '182.143.162.8', '2026-05-02 02:17:19');
INSERT INTO `loginmissrecord` VALUES (244, 'admimn', 0, 0, '203.160.72.104', '2026-05-19 20:11:21');
INSERT INTO `loginmissrecord` VALUES (245, 'test001', 1, 0, '47.239.65.23', '2026-05-21 13:57:26');
INSERT INTO `loginmissrecord` VALUES (246, '1022', 1, 0, '203.160.72.104', '2026-05-21 14:40:53');
INSERT INTO `loginmissrecord` VALUES (247, '1033', 1, 0, '203.160.72.104', '2026-05-20 18:09:08');
INSERT INTO `loginmissrecord` VALUES (248, '1044', 1, 0, '203.160.72.104', '2026-05-20 18:09:29');
INSERT INTO `loginmissrecord` VALUES (249, '1688', 1, 0, '203.160.72.104', '2026-05-23 19:15:16');
INSERT INTO `loginmissrecord` VALUES (250, '10086', 1, 0, '112.51.68.144', '2026-05-26 12:13:08');
INSERT INTO `loginmissrecord` VALUES (251, '10584', 0, 0, '203.160.80.85', '2026-05-22 14:12:30');
INSERT INTO `loginmissrecord` VALUES (252, '666888', 1, 0, '111.55.145.79', '2026-05-22 23:10:44');
INSERT INTO `loginmissrecord` VALUES (253, '10010', 1, 0, '203.160.86.164', '2026-05-24 23:26:04');

-- ----------------------------
-- Table structure for manageropt
-- ----------------------------
DROP TABLE IF EXISTS `manageropt`;
CREATE TABLE `manageropt`  (
  `UserID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户账号',
  `NAME` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名称',
  `Opt` int(11) NOT NULL COMMENT '功能',
  `OptValue` int(11) NOT NULL COMMENT '控值',
  `Type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `TIME` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '设置时间'
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '机率控制记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of manageropt
-- ----------------------------

-- ----------------------------
-- Table structure for mgrpermission
-- ----------------------------
DROP TABLE IF EXISTS `mgrpermission`;
CREATE TABLE `mgrpermission`  (
  `PID` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户账号',
  `Modules` int(11) NOT NULL DEFAULT 0 COMMENT '模块标识',
  `OptID` int(11) NOT NULL DEFAULT 0 COMMENT '操作标识',
  `PermisionID` tinyint(4) NOT NULL DEFAULT 0 COMMENT '权限值  0无权限  1有权限',
  PRIMARY KEY (`PID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '权限信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of mgrpermission
-- ----------------------------

-- ----------------------------
-- Table structure for notice
-- ----------------------------
DROP TABLE IF EXISTS `notice`;
CREATE TABLE `notice`  (
  `ID` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `TITLE` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标题',
  `NOTICE` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '公告内容',
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '公告信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notice
-- ----------------------------

-- ----------------------------
-- Table structure for parabet
-- ----------------------------
DROP TABLE IF EXISTS `parabet`;
CREATE TABLE `parabet`  (
  `ID` int(11) NOT NULL,
  `GAME_ID` int(11) NULL DEFAULT NULL,
  `DIF` int(11) NULL DEFAULT NULL,
  `HAR` int(11) NULL DEFAULT NULL,
  `SITE_TYPE` int(11) NULL DEFAULT NULL,
  `BANKER_DIF` int(11) NULL DEFAULT NULL,
  `BANKER_HAR` int(11) NULL DEFAULT NULL,
  `BANKER_SITE_TYPE` int(11) NULL DEFAULT NULL,
  `BANKER_PER` int(11) NULL DEFAULT NULL,
  `Kill_Big` int(11) NULL DEFAULT 0,
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '押注类机台参数表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of parabet
-- ----------------------------
INSERT INTO `parabet` VALUES (2000, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2001, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2002, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2003, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2004, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2005, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2006, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2007, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2008, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2009, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2010, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2011, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2012, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2013, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2014, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2015, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10000, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10001, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10002, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10003, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10004, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10005, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10006, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10007, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10008, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10009, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10010, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10011, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10012, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10013, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10014, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10015, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10016, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10017, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10018, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10019, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10020, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10021, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10022, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10023, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10024, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (16000, 16, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (16001, 16, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (16002, 16, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (29000, 29, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (29001, 29, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (29002, 29, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (29003, 29, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (29004, 29, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (29005, 29, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (29006, 29, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (29007, 29, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (29008, 29, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (29009, 29, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (29010, 29, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (29011, 29, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (29012, 29, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (29013, 29, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (29014, 29, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (29015, 29, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (47000, 47, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (47001, 47, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (47002, 47, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (47003, 47, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (47004, 47, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (47005, 47, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (47006, 47, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (47007, 47, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (47008, 47, 4, 4, 1, 0, 0, 1, 30, 0);

-- ----------------------------
-- Table structure for parabetroom
-- ----------------------------
DROP TABLE IF EXISTS `parabetroom`;
CREATE TABLE `parabetroom`  (
  `ID` int(11) NULL DEFAULT NULL,
  `GAME_ID` int(11) NULL DEFAULT NULL,
  `BET_TIME` int(11) NULL DEFAULT NULL,
  `NUM` int(11) NULL DEFAULT NULL,
  `BET_MAX` int(11) NULL DEFAULT NULL,
  `BET_MIN` int(11) NULL DEFAULT NULL,
  `BET_MAX_VICE` int(11) NULL DEFAULT NULL,
  `BET_MIN_VICE` int(11) NULL DEFAULT NULL,
  `BET_MAX_DRAW` int(11) NULL DEFAULT NULL,
  `BET_MIN_DRAW` int(11) NULL DEFAULT NULL,
  `EX_COIN` int(11) NULL DEFAULT NULL,
  `COIN_SC` int(11) NULL DEFAULT NULL,
  `COIN_NEED` int(11) NULL DEFAULT NULL,
  `BANKER_SC_NEED` int(11) NULL DEFAULT NULL,
  `SC_LIMIT_SING` int(11) NULL DEFAULT NULL,
  `SC_LIMIT_ALL` int(11) NULL DEFAULT NULL,
  `Game_MO` int(11) NULL DEFAULT NULL,
  `BetScores` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '投注档位',
  `DefaultBetIndex` tinyint(4) NULL DEFAULT 0 COMMENT '默认档位索引',
  `TableName` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '??',
  `MaxSeats` int(11) NOT NULL DEFAULT 6 COMMENT '????????C++?????',
  `IdleFireTimeoutSec` int(11) NOT NULL DEFAULT 0 COMMENT '???????(?)',
  `IdleFireKickEnabled` bit(1) NOT NULL DEFAULT b'1' COMMENT '是否开启无发炮踢出',
  `Enabled` bit(1) NOT NULL DEFAULT b'1' COMMENT '??????'
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '押注类房间参数表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of parabetroom
-- ----------------------------
INSERT INTO `parabetroom` VALUES (10000, 10, 10, 5, 1000, 10, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, NULL, 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (10001, 10, 10, 5, 1000, 10, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, NULL, 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (10002, 10, 10, 5, 1000, 10, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, NULL, 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (47000, 47, 10, 3, 1000, 0, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '桌台1', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (47001, 47, 10, 3, 1000, 0, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '桌台2', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (47002, 47, 10, 3, 1000, 0, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '桌台3', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (2000, 2, 10, 4, 1000, 0, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '桌台1', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (2001, 2, 10, 4, 1000, 0, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '桌台2', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (2002, 2, 10, 4, 1000, 0, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '桌台3', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (29000, 29, 10, 3, 1000, 0, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '桌台1', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (29001, 29, 10, 3, 1000, 1, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '桌台2', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (29002, 29, 10, 3, 1000, 1, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '桌台3', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (2003, 2, 10, 4, 1000, 10, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '004', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (16000, 16, 10, 1, 1000, 10, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, NULL, 6, 0, b'1', b'1');
INSERT INTO `parabetroom` VALUES (16001, 16, 10, 1, 1000, 10, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, NULL, 6, 0, b'1', b'1');
INSERT INTO `parabetroom` VALUES (16002, 16, 10, 1, 1000, 10, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, NULL, 6, 0, b'1', b'1');
INSERT INTO `parabetroom` VALUES (10003, 10, 10, 5, 1000, 10, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '78', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (10004, 10, 10, 5, 1000, 10, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '78', 6, 120, b'1', b'1');

-- ----------------------------
-- Table structure for paracard
-- ----------------------------
DROP TABLE IF EXISTS `paracard`;
CREATE TABLE `paracard`  (
  `ID` int(11) NULL DEFAULT NULL,
  `GAME_ID` int(11) NULL DEFAULT NULL,
  `DIF` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `HYPE_TYPE` int(11) NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '牌机机台参数表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of paracard
-- ----------------------------
INSERT INTO `paracard` VALUES (15000, 15, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (15001, 15, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (15002, 15, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (15003, 15, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (15004, 15, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (15005, 15, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (15006, 15, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (15007, 15, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (15008, 15, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (15009, 15, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (15010, 15, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (15011, 15, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (15012, 15, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (15013, 15, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (15014, 15, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (14000, 14, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (14001, 14, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (14002, 14, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (14003, 14, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (14004, 14, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (14005, 14, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (14006, 14, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (14007, 14, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (14008, 14, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (14009, 14, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (14010, 14, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (14011, 14, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (14012, 14, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (14013, 14, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (14014, 14, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (5000, 5, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (5001, 5, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (5002, 5, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (5003, 5, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (5004, 5, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (5005, 5, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (5006, 5, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (5007, 5, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (5008, 5, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (5009, 5, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (5010, 5, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (5011, 5, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (5012, 5, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (5013, 5, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (5014, 5, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (44000, 44, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (44001, 44, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (44002, 44, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (44003, 44, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (44004, 44, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (44005, 44, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (44006, 44, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (44007, 44, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (44008, 44, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (44009, 44, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (44010, 44, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (44011, 44, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (44012, 44, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (44013, 44, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (44014, 44, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (52000, 52, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (52001, 52, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (52002, 52, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (52003, 52, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (52004, 52, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (52005, 52, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (52006, 52, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (52007, 52, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (52008, 52, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (52009, 52, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (52010, 52, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (52011, 52, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (52012, 52, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (52013, 52, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (52014, 52, '3434453555777533', 0);

-- ----------------------------
-- Table structure for parafish
-- ----------------------------
DROP TABLE IF EXISTS `parafish`;
CREATE TABLE `parafish`  (
  `ID` int(11) NOT NULL,
  `GAME_ID` int(11) NULL DEFAULT NULL,
  `DIF` int(11) NULL DEFAULT NULL,
  `HAR` int(11) NULL DEFAULT NULL,
  `SITE_TYPE` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鱼机机台参数表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of parafish
-- ----------------------------
INSERT INTO `parafish` VALUES (3000, 3, 6, 6, 1);
INSERT INTO `parafish` VALUES (3001, 3, 6, 6, 1);
INSERT INTO `parafish` VALUES (3002, 3, 6, 6, 1);
INSERT INTO `parafish` VALUES (3003, 3, 6, 6, 1);
INSERT INTO `parafish` VALUES (3004, 3, 6, 6, 1);
INSERT INTO `parafish` VALUES (3005, 3, 6, 6, 1);
INSERT INTO `parafish` VALUES (3006, 3, 6, 6, 1);
INSERT INTO `parafish` VALUES (3007, 3, 6, 6, 1);
INSERT INTO `parafish` VALUES (3008, 3, 6, 6, 1);
INSERT INTO `parafish` VALUES (6000, 6, 0, 6, 1);
INSERT INTO `parafish` VALUES (6001, 6, 6, 6, 1);
INSERT INTO `parafish` VALUES (6002, 6, 6, 6, 1);
INSERT INTO `parafish` VALUES (6003, 6, 6, 6, 1);
INSERT INTO `parafish` VALUES (6004, 6, 6, 6, 1);
INSERT INTO `parafish` VALUES (6005, 6, 6, 6, 1);
INSERT INTO `parafish` VALUES (6006, 6, 6, 6, 1);
INSERT INTO `parafish` VALUES (6007, 6, 6, 6, 1);
INSERT INTO `parafish` VALUES (6008, 6, 6, 6, 1);
INSERT INTO `parafish` VALUES (13000, 13, 6, 6, 1);
INSERT INTO `parafish` VALUES (13001, 13, 6, 6, 1);
INSERT INTO `parafish` VALUES (13002, 13, 6, 6, 1);
INSERT INTO `parafish` VALUES (13003, 13, 6, 6, 1);
INSERT INTO `parafish` VALUES (13004, 13, 6, 6, 1);
INSERT INTO `parafish` VALUES (13005, 13, 6, 6, 1);
INSERT INTO `parafish` VALUES (13006, 13, 6, 6, 1);
INSERT INTO `parafish` VALUES (13007, 13, 6, 6, 1);
INSERT INTO `parafish` VALUES (13008, 13, 6, 6, 1);
INSERT INTO `parafish` VALUES (13009, 13, 6, 6, 1);
INSERT INTO `parafish` VALUES (13010, 13, 6, 6, 1);
INSERT INTO `parafish` VALUES (13011, 13, 6, 6, 1);
INSERT INTO `parafish` VALUES (19000, 19, 4, 0, 1);
INSERT INTO `parafish` VALUES (19001, 19, 0, 6, 0);
INSERT INTO `parafish` VALUES (19002, 19, 0, 6, 0);
INSERT INTO `parafish` VALUES (19003, 19, 0, 6, 0);
INSERT INTO `parafish` VALUES (19004, 19, 0, 6, 0);
INSERT INTO `parafish` VALUES (19005, 19, 0, 6, 0);
INSERT INTO `parafish` VALUES (19006, 19, 0, 6, 0);
INSERT INTO `parafish` VALUES (19007, 19, 0, 6, 0);
INSERT INTO `parafish` VALUES (19008, 19, 0, 6, 0);
INSERT INTO `parafish` VALUES (19009, 19, 0, 6, 0);
INSERT INTO `parafish` VALUES (19010, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19011, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19012, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19013, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19014, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19015, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19016, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19017, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19018, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19019, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19020, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19021, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19022, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19023, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19024, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19025, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19026, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19027, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19028, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19029, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19030, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19031, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19032, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19033, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19034, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19035, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19036, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19037, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19038, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19039, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19040, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19041, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19042, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19043, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19044, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19045, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19046, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19047, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19048, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19049, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19050, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19051, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19052, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19053, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19054, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19055, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19056, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19057, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19058, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19059, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19060, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19061, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19062, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19063, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19064, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19065, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19066, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19067, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19068, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19069, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19070, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19071, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19072, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19073, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19074, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19075, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19076, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19077, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19078, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19079, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19080, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19081, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19082, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19083, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19084, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19085, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19086, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19087, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19088, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19089, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19090, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19091, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19092, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19093, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19094, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19095, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19096, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19097, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19098, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19099, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19100, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19101, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19102, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19103, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19104, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19105, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19106, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19107, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19108, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19109, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19110, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19111, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19112, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19113, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19114, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19115, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19116, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19117, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19118, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19119, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19120, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19121, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19122, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19123, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19124, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19125, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19126, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19127, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19128, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19129, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19130, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19131, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19132, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19133, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19134, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19135, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19136, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19137, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19138, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19139, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19140, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19141, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19142, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19143, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (21000, 21, 6, 6, 1);
INSERT INTO `parafish` VALUES (21001, 21, 6, 6, 1);
INSERT INTO `parafish` VALUES (21002, 21, 6, 6, 1);
INSERT INTO `parafish` VALUES (21003, 21, 6, 6, 1);
INSERT INTO `parafish` VALUES (21004, 21, 6, 6, 1);
INSERT INTO `parafish` VALUES (21005, 21, 6, 6, 1);
INSERT INTO `parafish` VALUES (21006, 21, 6, 6, 1);
INSERT INTO `parafish` VALUES (21007, 21, 6, 6, 1);
INSERT INTO `parafish` VALUES (21008, 21, 6, 6, 1);
INSERT INTO `parafish` VALUES (22000, 22, 6, 6, 1);
INSERT INTO `parafish` VALUES (22001, 22, 6, 6, 1);
INSERT INTO `parafish` VALUES (22002, 22, 6, 6, 1);
INSERT INTO `parafish` VALUES (22003, 22, 6, 6, 1);
INSERT INTO `parafish` VALUES (22004, 22, 6, 6, 1);
INSERT INTO `parafish` VALUES (22005, 22, 6, 6, 1);
INSERT INTO `parafish` VALUES (22006, 22, 6, 6, 1);
INSERT INTO `parafish` VALUES (22007, 22, 6, 6, 1);
INSERT INTO `parafish` VALUES (22008, 22, 6, 6, 1);
INSERT INTO `parafish` VALUES (32000, 32, 6, 6, 1);
INSERT INTO `parafish` VALUES (32001, 32, 6, 6, 1);
INSERT INTO `parafish` VALUES (32002, 32, 6, 6, 1);
INSERT INTO `parafish` VALUES (32003, 32, 6, 6, 1);
INSERT INTO `parafish` VALUES (32004, 32, 6, 6, 1);
INSERT INTO `parafish` VALUES (32005, 32, 6, 6, 1);
INSERT INTO `parafish` VALUES (32006, 32, 6, 6, 1);
INSERT INTO `parafish` VALUES (32007, 32, 6, 6, 1);
INSERT INTO `parafish` VALUES (32008, 32, 6, 6, 1);
INSERT INTO `parafish` VALUES (33000, 33, 6, 6, 1);
INSERT INTO `parafish` VALUES (33001, 33, 6, 6, 1);
INSERT INTO `parafish` VALUES (33002, 33, 6, 6, 1);
INSERT INTO `parafish` VALUES (33003, 33, 6, 6, 1);
INSERT INTO `parafish` VALUES (33004, 33, 6, 6, 1);
INSERT INTO `parafish` VALUES (33005, 33, 6, 6, 1);
INSERT INTO `parafish` VALUES (33006, 33, 6, 6, 1);
INSERT INTO `parafish` VALUES (33007, 33, 6, 6, 1);
INSERT INTO `parafish` VALUES (33008, 33, 6, 6, 1);
INSERT INTO `parafish` VALUES (42000, 42, 6, 6, 1);
INSERT INTO `parafish` VALUES (42001, 42, 6, 6, 1);
INSERT INTO `parafish` VALUES (42002, 42, 6, 6, 1);
INSERT INTO `parafish` VALUES (42003, 42, 6, 6, 1);
INSERT INTO `parafish` VALUES (42004, 42, 6, 6, 1);
INSERT INTO `parafish` VALUES (42005, 42, 6, 6, 1);
INSERT INTO `parafish` VALUES (42006, 42, 6, 6, 1);
INSERT INTO `parafish` VALUES (42007, 42, 6, 6, 1);
INSERT INTO `parafish` VALUES (42008, 42, 6, 6, 1);
INSERT INTO `parafish` VALUES (49000, 49, 6, 6, 1);
INSERT INTO `parafish` VALUES (49001, 49, 6, 6, 1);
INSERT INTO `parafish` VALUES (49002, 49, 6, 6, 1);
INSERT INTO `parafish` VALUES (49003, 49, 6, 6, 1);
INSERT INTO `parafish` VALUES (49004, 49, 6, 6, 1);
INSERT INTO `parafish` VALUES (49005, 49, 6, 6, 1);
INSERT INTO `parafish` VALUES (49006, 49, 6, 6, 1);
INSERT INTO `parafish` VALUES (49007, 49, 6, 6, 1);
INSERT INTO `parafish` VALUES (49008, 49, 6, 6, 1);
INSERT INTO `parafish` VALUES (49009, 49, 6, 6, 1);
INSERT INTO `parafish` VALUES (49010, 49, 6, 6, 1);
INSERT INTO `parafish` VALUES (49011, 49, 6, 6, 1);
INSERT INTO `parafish` VALUES (51000, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51001, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51002, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51003, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51004, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51005, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51006, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51007, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51008, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51009, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51010, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51011, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51012, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51013, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51014, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51015, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51016, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51017, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51018, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51019, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51020, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51021, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51022, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51023, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51024, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51025, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51026, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51027, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51028, 51, 6, 6, 1);
INSERT INTO `parafish` VALUES (51029, 51, 6, 6, 1);

-- ----------------------------
-- Table structure for paragame
-- ----------------------------
DROP TABLE IF EXISTS `paragame`;
CREATE TABLE `paragame`  (
  `ID` int(11) NOT NULL,
  `ROOM_MAX` int(11) NULL DEFAULT NULL,
  `PLY_MAX` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of paragame
-- ----------------------------
INSERT INTO `paragame` VALUES (2, 4, 6);
INSERT INTO `paragame` VALUES (3, 3, 6);
INSERT INTO `paragame` VALUES (5, 3, 1);
INSERT INTO `paragame` VALUES (6, 3, 6);
INSERT INTO `paragame` VALUES (10, 5, 6);
INSERT INTO `paragame` VALUES (13, 3, 6);
INSERT INTO `paragame` VALUES (14, 3, 1);
INSERT INTO `paragame` VALUES (15, 3, 1);
INSERT INTO `paragame` VALUES (16, 3, 1000);
INSERT INTO `paragame` VALUES (19, 10, 6);
INSERT INTO `paragame` VALUES (21, 3, 6);
INSERT INTO `paragame` VALUES (22, 3, 6);
INSERT INTO `paragame` VALUES (29, 3, 6);
INSERT INTO `paragame` VALUES (32, 3, 6);
INSERT INTO `paragame` VALUES (33, 3, 6);
INSERT INTO `paragame` VALUES (42, 3, 6);
INSERT INTO `paragame` VALUES (44, 3, 1);
INSERT INTO `paragame` VALUES (47, 3, 6);
INSERT INTO `paragame` VALUES (49, 3, 6);
INSERT INTO `paragame` VALUES (51, 3, 6);
INSERT INTO `paragame` VALUES (52, 3, 1);

-- ----------------------------
-- Table structure for pararoom
-- ----------------------------
DROP TABLE IF EXISTS `pararoom`;
CREATE TABLE `pararoom`  (
  `ID` int(11) NOT NULL,
  `GAME_ID` int(11) NULL DEFAULT NULL COMMENT '游戏ID',
  `NUM` int(11) NULL DEFAULT NULL,
  `BET_MIN` int(11) NULL DEFAULT NULL COMMENT '最小下注',
  `BET_MAX` int(11) NULL DEFAULT NULL COMMENT '最大下注',
  `EX_COIN` int(11) NULL DEFAULT NULL COMMENT '单次要换的金币',
  `COIN_SC` int(11) NULL DEFAULT NULL COMMENT '1金币换多少分数',
  `COIN_NEED` int(11) NULL DEFAULT NULL COMMENT '入场最小金币数',
  `scoreSwitch` int(11) NULL DEFAULT 1 COMMENT '加减炮幅度',
  `BetMinValLimit` int(11) NULL DEFAULT 0 COMMENT '最小押分值限制',
  `BetMaxValLimit` int(11) NULL DEFAULT 0 COMMENT '最大押分值限制',
  `Game_Mo` int(11) NULL DEFAULT NULL,
  `TableName` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '桌名',
  `MaxSeats` int(11) NOT NULL DEFAULT 6 COMMENT '最大坐席数，配合C++端数组扩容',
  `IdleFireTimeoutSec` int(11) NOT NULL DEFAULT 0 COMMENT '无发炮踢出时间(秒)',
  `IdleFireKickEnabled` bit(1) NOT NULL DEFAULT b'1' COMMENT '是否开启无发炮踢出',
  `Enabled` bit(1) NOT NULL DEFAULT b'1' COMMENT '桌台开关状态',
  `MinBetUnits` int(11) NOT NULL DEFAULT 0 COMMENT '最小下注炮值(整数单位，显示值x10)',
  `MaxBetUnits` int(11) NOT NULL DEFAULT 0 COMMENT '最大下注炮值(整数单位，显示值x10)',
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '牌机、鱼机房间参数表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of pararoom
-- ----------------------------
INSERT INTO `pararoom` VALUES (3000, 3, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (3001, 3, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (3002, 3, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (5000, 5, 5, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 0, 0, b'1', b'1', 100, 10000);
INSERT INTO `pararoom` VALUES (5001, 5, 5, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 0, 0, b'1', b'1', 100, 10000);
INSERT INTO `pararoom` VALUES (5002, 5, 5, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 0, 0, b'1', b'1', 100, 10000);
INSERT INTO `pararoom` VALUES (6000, 6, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, '桌台1', 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (6001, 6, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (6002, 6, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (13000, 13, 4, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (13001, 13, 4, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (13002, 13, 4, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (13003, 13, 4, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, '789', 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (14000, 14, 5, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 0, 0, b'1', b'1', 100, 10000);
INSERT INTO `pararoom` VALUES (14001, 14, 5, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 0, 0, b'1', b'1', 100, 10000);
INSERT INTO `pararoom` VALUES (14002, 14, 5, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 0, 0, b'1', b'1', 100, 10000);
INSERT INTO `pararoom` VALUES (15000, 15, 5, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 0, 0, b'1', b'1', 100, 10000);
INSERT INTO `pararoom` VALUES (15001, 15, 5, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 0, 0, b'1', b'1', 100, 10000);
INSERT INTO `pararoom` VALUES (15002, 15, 5, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 0, 0, b'1', b'1', 100, 10000);
INSERT INTO `pararoom` VALUES (19000, 19, 10, 5, 100, 1, 1, 0, 5, 0, 0, 0, '001', 6, 0, b'1', b'1', 50, 1000);
INSERT INTO `pararoom` VALUES (19001, 19, 10, 1, 9999999, 1, 1, 0, 1, 0, 0, 0, '008', 6, 0, b'1', b'1', 10, 99999990);
INSERT INTO `pararoom` VALUES (19002, 19, 10, 1, 2, 1, 1, 0, 1, 0, 0, 0, '009', 6, 0, b'1', b'1', 10, 20);
INSERT INTO `pararoom` VALUES (19003, 19, 10, 1, 2, 1, 1, 0, 1, 0, 0, 0, '010', 6, 0, b'1', b'1', 10, 20);
INSERT INTO `pararoom` VALUES (19004, 19, 10, 1, 2, 1, 1, 0, 1, 0, 0, 0, '011', 6, 0, b'1', b'1', 10, 20);
INSERT INTO `pararoom` VALUES (19005, 19, 10, 1, 2, 1, 1, 0, 1, 0, 0, 0, '012', 6, 0, b'1', b'1', 10, 20);
INSERT INTO `pararoom` VALUES (19006, 19, 10, 1, 2, 1, 1, 0, 1, 0, 0, 0, '013', 6, 0, b'1', b'1', 10, 20);
INSERT INTO `pararoom` VALUES (19007, 19, 10, 1, 2, 1, 1, 0, 1, 0, 0, 0, '014', 6, 0, b'1', b'1', 10, 20);
INSERT INTO `pararoom` VALUES (19008, 19, 10, 1, 2, 1, 1, 0, 1, 0, 0, 0, '016', 6, 0, b'1', b'1', 10, 20);
INSERT INTO `pararoom` VALUES (19009, 19, 10, 1, 2, 1, 1, 0, 1, 0, 0, 0, '017', 6, 0, b'1', b'1', 10, 20);
INSERT INTO `pararoom` VALUES (21000, 21, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (21001, 21, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (21002, 21, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (22000, 22, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (22001, 22, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (22002, 22, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (32000, 32, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (32001, 32, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (32002, 32, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (33000, 33, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (33001, 33, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (33002, 33, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (42000, 42, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (42001, 42, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (42002, 42, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (44000, 44, 5, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 0, 0, b'1', b'1', 100, 10000);
INSERT INTO `pararoom` VALUES (44001, 44, 5, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 0, 0, b'1', b'1', 100, 10000);
INSERT INTO `pararoom` VALUES (44002, 44, 5, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 0, 0, b'1', b'1', 100, 10000);
INSERT INTO `pararoom` VALUES (49000, 49, 4, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (49001, 49, 4, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (49002, 49, 4, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (49003, 49, 4, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, '88', 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (51000, 51, 10, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 0, 0);
INSERT INTO `pararoom` VALUES (51001, 51, 10, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 0, 0);
INSERT INTO `pararoom` VALUES (51002, 51, 10, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 0, 0);
INSERT INTO `pararoom` VALUES (52000, 52, 5, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 6, 0, b'1', b'1', 0, 0);
INSERT INTO `pararoom` VALUES (52001, 52, 5, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 6, 0, b'1', b'1', 0, 0);
INSERT INTO `pararoom` VALUES (52002, 52, 5, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 6, 0, b'1', b'1', 0, 0);

-- ----------------------------
-- Table structure for plattype
-- ----------------------------
DROP TABLE IF EXISTS `plattype`;
CREATE TABLE `plattype`  (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '视讯平台名称',
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '视讯平台类型',
  `Enable` bit(1) NULL DEFAULT b'1' COMMENT '0禁用 1启用',
  `CreateTime` datetime(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 53 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of plattype
-- ----------------------------
INSERT INTO `plattype` VALUES (1, '亚游', 'ag', b'1', '2023-05-31 09:32:32');
INSERT INTO `plattype` VALUES (52, '云游', 'yoo', b'1', '2023-05-31 09:46:51');

-- ----------------------------
-- Table structure for rank
-- ----------------------------
DROP TABLE IF EXISTS `rank`;
CREATE TABLE `rank`  (
  `RankID` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '序号',
  `GameID` int(11) NOT NULL COMMENT '游戏ID',
  `Coin` int(11) NOT NULL COMMENT '金币',
  `PrizeID` int(11) NOT NULL COMMENT '打到的大奖',
  `Time` int(11) NOT NULL COMMENT '时间戳',
  `Lev` int(11) NOT NULL COMMENT '等级',
  `Ico` int(11) NOT NULL COMMENT '头像ID',
  `User` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名',
  `Dis` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '描述',
  `PrizeName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '怪物名称',
  PRIMARY KEY (`RankID`, `GameID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of rank
-- ----------------------------
INSERT INTO `rank` VALUES (1, 2, 400000, 400000, 1700082149, 0, 0, '381185127', '381185127', '中大奖');
INSERT INTO `rank` VALUES (1, 6, 78640, 1, 1779475257, 0, 0, 'plm123', 'plm123', '牛魔王(983倍)');
INSERT INTO `rank` VALUES (1, 10, 46000, 46000, 1777474492, 0, 0, '55555', '55555', '中大奖');
INSERT INTO `rank` VALUES (1, 13, 58000, 2, 1700078609, 0, 0, 'woshini', 'woshini', '李逵(58倍)');
INSERT INTO `rank` VALUES (1, 19, 7700000, 4, 1777371046, 0, 0, '123123', '123123', '全屏炸弹(770倍)');
INSERT INTO `rank` VALUES (1, 21, 6000, 1, 1777465905, 0, 0, '55555', '55555', '金龙鱼(120倍)');
INSERT INTO `rank` VALUES (1, 22, 16000, 2, 1777402210, 0, 0, '321321', '321321', '全屏炸弹(800倍)');
INSERT INTO `rank` VALUES (1, 32, 40000, 2, 1777558235, 0, 0, 'ijb222', 'ijb222', '超级炸弹(800倍)');
INSERT INTO `rank` VALUES (1, 33, 707000, 2, 1699934387, 0, 0, '11111', '11111', '超级炸弹(707倍)');
INSERT INTO `rank` VALUES (1, 42, 8550, 1, 1777300105, 0, 0, '55555', '55555', '金蟾(285倍)');
INSERT INTO `rank` VALUES (1, 1000, 100000000, 1000, 1777435416, 1, 0, '888888', '888888', '888888');
INSERT INTO `rank` VALUES (1, 1001, 1, 1001, 1699932065, 1, 0, '11111', '11111', '11111');
INSERT INTO `rank` VALUES (2, 2, 380000, 380000, 1700082191, 0, 0, '381185127', '381185127', '中大奖');
INSERT INTO `rank` VALUES (2, 6, 70960, 1, 1779475431, 0, 0, 'plm123', 'plm123', '牛魔王(887倍)');
INSERT INTO `rank` VALUES (2, 10, 42500, 42500, 1777303405, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (2, 19, 7636590, 4, 1700054807, 0, 0, 'woshini', 'woshini', '全屏炸弹(793倍)');
INSERT INTO `rank` VALUES (2, 21, 6000, 1, 1777466025, 0, 0, '55555', '55555', '金龙鱼(120倍)');
INSERT INTO `rank` VALUES (2, 22, 16000, 2, 1777402328, 0, 0, '321321', '321321', '全屏炸弹(800倍)');
INSERT INTO `rank` VALUES (2, 32, 39600, 2, 1777468289, 0, 0, '55555', '55555', '超级炸弹(792倍)');
INSERT INTO `rank` VALUES (2, 33, 500000, 0, 1699934419, 0, 0, '11111', '11111', '巨鳄(500倍)');
INSERT INTO `rank` VALUES (2, 42, 7830, 1, 1777300154, 0, 0, '55555', '55555', '金蟾(261倍)');
INSERT INTO `rank` VALUES (2, 1000, 10515943, 1000, 1777457211, 1, 0, '777777', '777777', '777777');
INSERT INTO `rank` VALUES (2, 1001, 1, 1001, 1700050483, 1, 0, '381185127', '381185127', '381185127');
INSERT INTO `rank` VALUES (3, 2, 380000, 380000, 1700082232, 0, 0, '381185127', '381185127', '中大奖');
INSERT INTO `rank` VALUES (3, 6, 68480, 1, 1779476537, 0, 0, 'plm123', 'plm123', '牛魔王(856倍)');
INSERT INTO `rank` VALUES (3, 10, 40000, 40000, 1777303904, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (3, 19, 5970000, 2, 1777371024, 0, 0, '123123', '123123', '金龟(597倍)');
INSERT INTO `rank` VALUES (3, 21, 6000, 1, 1777466038, 0, 0, '55555', '55555', '金龙鱼(120倍)');
INSERT INTO `rank` VALUES (3, 22, 14660, 2, 1777402494, 0, 0, '321321', '321321', '全屏炸弹(733倍)');
INSERT INTO `rank` VALUES (3, 32, 38850, 2, 1777474363, 0, 0, '55555', '55555', '超级炸弹(777倍)');
INSERT INTO `rank` VALUES (3, 33, 500000, 0, 1699934443, 0, 0, '11111', '11111', '巨鳄(500倍)');
INSERT INTO `rank` VALUES (3, 42, 1266, 2, 1777468602, 0, 0, '55555', '55555', '金龙(422倍)');
INSERT INTO `rank` VALUES (3, 1000, 9999999, 1000, 1777368529, 1, 0, '123123', '123123', '123123');
INSERT INTO `rank` VALUES (3, 1001, 1, 1001, 1777427167, 1, 0, '121212', '121212', '121212');
INSERT INTO `rank` VALUES (4, 2, 138292, 138292, 1777318480, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (4, 6, 64000, 2, 1779476188, 0, 0, 'plm123', 'plm123', '超级炸弹(800倍)');
INSERT INTO `rank` VALUES (4, 10, 40000, 40000, 1777476778, 0, 0, '55555', '55555', '中大奖');
INSERT INTO `rank` VALUES (4, 19, 5750000, 4, 1700055851, 0, 0, 'woshini', 'woshini', '全屏炸弹(575倍)');
INSERT INTO `rank` VALUES (4, 21, 4200, 0, 1777558170, 0, 0, 'plm123', 'plm123', '金鲨(84倍)');
INSERT INTO `rank` VALUES (4, 22, 12800, 2, 1777402251, 0, 0, '321321', '321321', '全屏炸弹(640倍)');
INSERT INTO `rank` VALUES (4, 32, 38800, 2, 1777558523, 0, 0, 'ijb222', 'ijb222', '超级炸弹(776倍)');
INSERT INTO `rank` VALUES (4, 33, 500000, 0, 1699934466, 0, 0, '11111', '11111', '巨鳄(500倍)');
INSERT INTO `rank` VALUES (4, 1000, 1578588, 1000, 1780392074, 1, 0, 'test03', 'test03', 'test03');
INSERT INTO `rank` VALUES (4, 1001, 1, 1001, 1777453755, 1, 0, '999999', '999999', '999999');
INSERT INTO `rank` VALUES (5, 2, 137856, 137856, 1777313485, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (5, 6, 64000, 2, 1779475813, 0, 0, 'plm123', 'plm123', '超级炸弹(800倍)');
INSERT INTO `rank` VALUES (5, 10, 35000, 35000, 1777475491, 0, 0, '55555', '55555', '中大奖');
INSERT INTO `rank` VALUES (5, 19, 5480000, 4, 1777371017, 0, 0, '123123', '123123', '全屏炸弹(548倍)');
INSERT INTO `rank` VALUES (5, 21, 3900, 0, 1777466054, 0, 0, '55555', '55555', '金鲨(78倍)');
INSERT INTO `rank` VALUES (5, 22, 9860, 2, 1777402726, 0, 0, '321321', '321321', '全屏炸弹(493倍)');
INSERT INTO `rank` VALUES (5, 32, 37950, 2, 1777558066, 0, 0, 'ijb222', 'ijb222', '超级炸弹(759倍)');
INSERT INTO `rank` VALUES (5, 33, 495000, 0, 1699934202, 0, 0, '11111', '11111', '巨鳄(500倍)');
INSERT INTO `rank` VALUES (5, 1000, 1215480, 1000, 1777453755, 1, 0, '999999', '999999', '999999');
INSERT INTO `rank` VALUES (5, 1001, 1, 1001, 1777368326, 1, 0, '123123', '123123', '123123');
INSERT INTO `rank` VALUES (6, 2, 137856, 137856, 1777313527, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (6, 6, 63760, 1, 1779475644, 0, 0, 'plm123', 'plm123', '牛魔王(797倍)');
INSERT INTO `rank` VALUES (6, 10, 33500, 33500, 1777297588, 0, 0, '55555', '55555', '中大奖');
INSERT INTO `rank` VALUES (6, 19, 5330000, 2, 1777371022, 0, 0, '123123', '123123', '金龟(533倍)');
INSERT INTO `rank` VALUES (6, 21, 3700, 0, 1777466021, 0, 0, '55555', '55555', '金鲨(74倍)');
INSERT INTO `rank` VALUES (6, 22, 6000, 1, 1777402545, 0, 0, '321321', '321321', '黄金轰炸机(300倍)');
INSERT INTO `rank` VALUES (6, 32, 37800, 2, 1777468458, 0, 0, '55555', '55555', '超级炸弹(756倍)');
INSERT INTO `rank` VALUES (6, 33, 495000, 0, 1699934324, 0, 0, '11111', '11111', '巨鳄(500倍)');
INSERT INTO `rank` VALUES (6, 1000, 1008923, 1000, 1782901183, 1, 0, 'test01', '测试勿动', '测试勿动');
INSERT INTO `rank` VALUES (6, 1001, 1, 1001, 1777369446, 1, 0, '321321', '321321', '321321');
INSERT INTO `rank` VALUES (7, 2, 137856, 137856, 1777313609, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (7, 6, 63440, 2, 1779475982, 0, 0, 'plm123', 'plm123', '超级炸弹(793倍)');
INSERT INTO `rank` VALUES (7, 10, 28600, 28600, 1777556767, 0, 0, 'okn122', 'okn122', '中大奖');
INSERT INTO `rank` VALUES (7, 19, 4990000, 4, 1700078046, 0, 0, 'woshini', 'woshini', '全屏炸弹(499倍)');
INSERT INTO `rank` VALUES (7, 21, 3100, 0, 1777567362, 0, 0, 'ijb222', 'ijb222', '金鲨(62倍)');
INSERT INTO `rank` VALUES (7, 22, 6000, 1, 1777402595, 0, 0, '321321', '321321', '黄金轰炸机(300倍)');
INSERT INTO `rank` VALUES (7, 32, 37800, 2, 1777558727, 0, 0, 'plm123', 'plm123', '超级炸弹(756倍)');
INSERT INTO `rank` VALUES (7, 33, 467280, 1, 1699934209, 0, 0, '11111', '11111', '局部炸弹(472倍)');
INSERT INTO `rank` VALUES (7, 1000, 999999, 1000, 1777295667, 1, 0, '121212', '121212', '121212');
INSERT INTO `rank` VALUES (7, 1001, 1, 1001, 1777428730, 1, 0, '777777', '777777', '777777');
INSERT INTO `rank` VALUES (8, 2, 137856, 137856, 1777313650, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (8, 6, 62560, 1, 1779476504, 0, 0, 'plm123', 'plm123', '牛魔王(782倍)');
INSERT INTO `rank` VALUES (8, 10, 28000, 28000, 1777464610, 0, 0, '55555', '55555', '中大奖');
INSERT INTO `rank` VALUES (8, 19, 4830000, 3, 1700061876, 0, 0, 'woshini', 'woshini', '局部炸弹(483倍)');
INSERT INTO `rank` VALUES (8, 21, 2650, 0, 1777465938, 0, 0, '55555', '55555', '金鲨(53倍)');
INSERT INTO `rank` VALUES (8, 22, 6000, 1, 1777402236, 0, 0, '321321', '321321', '黄金轰炸机(300倍)');
INSERT INTO `rank` VALUES (8, 32, 37750, 2, 1777558576, 0, 0, 'ijb222', 'ijb222', '超级炸弹(755倍)');
INSERT INTO `rank` VALUES (8, 33, 42500, 2, 1777569258, 0, 0, 'ijb222', 'ijb222', '超级炸弹(850倍)');
INSERT INTO `rank` VALUES (8, 1000, 999819, 1000, 1777369518, 1, 0, '321321', '321321', '321321');
INSERT INTO `rank` VALUES (8, 1001, 1, 1001, 1777454276, 1, 0, '55555', '55555', '55555');
INSERT INTO `rank` VALUES (9, 2, 137856, 137856, 1777313733, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (9, 6, 62240, 2, 1779517263, 0, 0, 'ijb222', 'ijb222', '超级炸弹(778倍)');
INSERT INTO `rank` VALUES (9, 10, 28000, 28000, 1777478561, 0, 0, '55555', '55555', '中大奖');
INSERT INTO `rank` VALUES (9, 19, 4300000, 3, 1777370917, 0, 0, '123123', '123123', '局部炸弹(430倍)');
INSERT INTO `rank` VALUES (9, 21, 2650, 0, 1777465938, 0, 0, '55555', '55555', '金鲨(53倍)');
INSERT INTO `rank` VALUES (9, 22, 6000, 1, 1777402733, 0, 0, '321321', '321321', '黄金轰炸机(300倍)');
INSERT INTO `rank` VALUES (9, 32, 36550, 2, 1777558663, 0, 0, 'ijb222', 'ijb222', '超级炸弹(731倍)');
INSERT INTO `rank` VALUES (9, 33, 25000, 0, 1777569176, 0, 0, 'ijb222', 'ijb222', '巨鳄(500倍)');
INSERT INTO `rank` VALUES (9, 1000, 998880, 1000, 1779357694, 1, 0, '112244', '112244', '112244');
INSERT INTO `rank` VALUES (9, 1001, 1, 1001, 1777456412, 1, 0, '666666', '666666', '666666');
INSERT INTO `rank` VALUES (10, 2, 137856, 137856, 1777313774, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (10, 6, 60720, 2, 1779476135, 0, 0, 'plm123', 'plm123', '超级炸弹(759倍)');
INSERT INTO `rank` VALUES (10, 10, 28000, 28000, 1777475848, 0, 0, '55555', '55555', '中大奖');
INSERT INTO `rank` VALUES (10, 19, 3960000, 2, 1777370890, 0, 0, '123123', '123123', '金龟(396倍)');
INSERT INTO `rank` VALUES (10, 21, 2650, 0, 1777567390, 0, 0, 'ijb222', 'ijb222', '金鲨(53倍)');
INSERT INTO `rank` VALUES (10, 22, 6000, 1, 1777402824, 0, 0, '321321', '321321', '黄金轰炸机(300倍)');
INSERT INTO `rank` VALUES (10, 32, 36200, 2, 1777558551, 0, 0, 'ijb222', 'ijb222', '超级炸弹(724倍)');
INSERT INTO `rank` VALUES (10, 33, 25000, 0, 1777569205, 0, 0, 'ijb222', 'ijb222', '巨鳄(500倍)');
INSERT INTO `rank` VALUES (10, 1000, 638145, 1000, 1777468799, 1, 0, '55555', '55555', '55555');
INSERT INTO `rank` VALUES (10, 1001, 1, 1001, 1777458262, 1, 0, '113300', '113300', '113300');
INSERT INTO `rank` VALUES (11, 2, 137856, 137856, 1777313815, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (11, 6, 58480, 2, 1779476559, 0, 0, 'plm123', 'plm123', '超级炸弹(731倍)');
INSERT INTO `rank` VALUES (11, 10, 25200, 25200, 1779199382, 0, 0, 'a1316', 'a1316', '中大奖');
INSERT INTO `rank` VALUES (11, 19, 3700000, 3, 1777370860, 0, 0, '123123', '123123', '局部炸弹(370倍)');
INSERT INTO `rank` VALUES (11, 21, 2300, 0, 1777558189, 0, 0, 'plm123', 'plm123', '金鲨(46倍)');
INSERT INTO `rank` VALUES (11, 22, 3560, 0, 1777402456, 0, 0, '321321', '321321', '武装轰炸机(178倍)');
INSERT INTO `rank` VALUES (11, 32, 36200, 2, 1777558423, 0, 0, 'ijb222', 'ijb222', '超级炸弹(724倍)');
INSERT INTO `rank` VALUES (11, 33, 25000, 0, 1777557672, 0, 0, 'plm123', 'plm123', '巨鳄(500倍)');
INSERT INTO `rank` VALUES (11, 1000, 174045, 1000, 1779708842, 1, 0, 'ijb222', 'ijb222', 'ijb222');
INSERT INTO `rank` VALUES (11, 1001, 1, 1001, 1777458790, 1, 0, '113301', '113301', '113301');
INSERT INTO `rank` VALUES (12, 2, 137856, 137856, 1777313857, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (12, 6, 57760, 1, 1779709021, 0, 0, 'ijb222', 'ijb222', '牛魔王(722倍)');
INSERT INTO `rank` VALUES (12, 10, 23600, 23600, 1777557052, 0, 0, 'okn122', 'okn122', '中大奖');
INSERT INTO `rank` VALUES (12, 19, 3600000, 3, 1777370936, 0, 0, '123123', '123123', '局部炸弹(360倍)');
INSERT INTO `rank` VALUES (12, 21, 1550, 0, 1777896530, 0, 0, '11223300', '11223300', '金鲨(62倍)');
INSERT INTO `rank` VALUES (12, 22, 1860, 0, 1777402800, 0, 0, '321321', '321321', '武装轰炸机(93倍)');
INSERT INTO `rank` VALUES (12, 32, 36050, 2, 1777558175, 0, 0, 'ijb222', 'ijb222', '超级炸弹(721倍)');
INSERT INTO `rank` VALUES (12, 33, 25000, 0, 1777569270, 0, 0, 'ijb222', 'ijb222', '巨鳄(500倍)');
INSERT INTO `rank` VALUES (12, 1000, 90484, 1000, 1779276257, 1, 0, '112233', '112233', '112233');
INSERT INTO `rank` VALUES (12, 1001, 1, 1001, 1777462473, 1, 0, 'a123123', 'a123123', 'a123123');
INSERT INTO `rank` VALUES (13, 2, 137856, 137856, 1777313898, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (13, 6, 57040, 2, 1779709544, 0, 0, 'ijb222', 'ijb222', '超级炸弹(713倍)');
INSERT INTO `rank` VALUES (13, 10, 23000, 23000, 1777478133, 0, 0, '55555', '55555', '中大奖');
INSERT INTO `rank` VALUES (13, 19, 3120000, 2, 1777371056, 0, 0, '123123', '123123', '金龟(312倍)');
INSERT INTO `rank` VALUES (13, 22, 1480, 0, 1777402362, 0, 0, '321321', '321321', '武装轰炸机(74倍)');
INSERT INTO `rank` VALUES (13, 32, 35700, 2, 1777557184, 0, 0, 'ijb222', 'ijb222', '超级炸弹(714倍)');
INSERT INTO `rank` VALUES (13, 33, 25000, 0, 1777569314, 0, 0, 'ijb222', 'ijb222', '巨鳄(500倍)');
INSERT INTO `rank` VALUES (13, 1000, 72222, 1000, 1700050483, 1, 0, '381185127', '381185127', '381185127');
INSERT INTO `rank` VALUES (13, 1001, 1, 1001, 1777464775, 1, 0, '18879090617', '18879090617', '18879090617');
INSERT INTO `rank` VALUES (14, 2, 137856, 137856, 1777313939, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (14, 6, 56320, 2, 1779475879, 0, 0, 'plm123', 'plm123', '超级炸弹(704倍)');
INSERT INTO `rank` VALUES (14, 10, 22400, 22400, 1777464824, 0, 0, '55555', '55555', '中大奖');
INSERT INTO `rank` VALUES (14, 19, 2970000, 4, 1700062351, 0, 0, 'woshini', 'woshini', '全屏炸弹(297倍)');
INSERT INTO `rank` VALUES (14, 22, 1120, 0, 1777402262, 0, 0, '321321', '321321', '武装轰炸机(56倍)');
INSERT INTO `rank` VALUES (14, 32, 34800, 2, 1777557750, 0, 0, 'ijb222', 'ijb222', '超级炸弹(696倍)');
INSERT INTO `rank` VALUES (14, 33, 25000, 0, 1777569357, 0, 0, 'ijb222', 'ijb222', '巨鳄(500倍)');
INSERT INTO `rank` VALUES (14, 1000, 50000, 1000, 1700051941, 1, 0, 'woshini', 'woshini', 'woshini');
INSERT INTO `rank` VALUES (14, 1001, 1, 1001, 1779276257, 1, 0, '112233', '112233', '112233');
INSERT INTO `rank` VALUES (15, 2, 137856, 137856, 1777314063, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (15, 6, 53120, 2, 1779477070, 0, 0, 'plm123', 'plm123', '超级炸弹(664倍)');
INSERT INTO `rank` VALUES (15, 10, 21000, 21000, 1777297446, 0, 0, '55555', '55555', '中大奖');
INSERT INTO `rank` VALUES (15, 19, 1740000, 5, 1700077840, 0, 0, 'woshini', 'woshini', '大三元(174倍)');
INSERT INTO `rank` VALUES (15, 32, 34100, 2, 1777557605, 0, 0, 'plm123', 'plm123', '超级炸弹(682倍)');
INSERT INTO `rank` VALUES (15, 33, 23000, 1, 1777557678, 0, 0, 'plm123', 'plm123', '局部炸弹(460倍)');
INSERT INTO `rank` VALUES (15, 1000, 27462, 1000, 1779714798, 1, 0, 'a1314', 'a1314', 'a1314');
INSERT INTO `rank` VALUES (15, 1001, 1, 1001, 1777466185, 1, 0, '6758854', '6758854', '6758854');
INSERT INTO `rank` VALUES (16, 2, 137856, 137856, 1777314145, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (16, 6, 53040, 1, 1779709076, 0, 0, 'ijb222', 'ijb222', '牛魔王(663倍)');
INSERT INTO `rank` VALUES (16, 10, 20000, 20000, 1777478276, 0, 0, '55555', '55555', '中大奖');
INSERT INTO `rank` VALUES (16, 19, 1740000, 5, 1700051002, 0, 0, '381185127', '381185127', '大三元(174倍)');
INSERT INTO `rank` VALUES (16, 32, 33600, 2, 1777468485, 0, 0, '55555', '55555', '超级炸弹(672倍)');
INSERT INTO `rank` VALUES (16, 33, 8500, 1, 1777557994, 0, 0, 'plm123', 'plm123', '局部炸弹(170倍)');
INSERT INTO `rank` VALUES (16, 1000, 25215, 1000, 1779474536, 1, 0, 'plm123', 'plm123', 'plm123');
INSERT INTO `rank` VALUES (16, 1001, 1, 1001, 1778580606, 1, 0, '898989', '898989', '898989');
INSERT INTO `rank` VALUES (17, 2, 137856, 137856, 1777314187, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (17, 6, 52960, 2, 1779479185, 0, 0, 'ijb222', 'ijb222', '超级炸弹(662倍)');
INSERT INTO `rank` VALUES (17, 10, 20000, 20000, 1777475919, 0, 0, '55555', '55555', '中大奖');
INSERT INTO `rank` VALUES (17, 19, 1740000, 5, 1700078327, 0, 0, 'woshini', 'woshini', '大三元(174倍)');
INSERT INTO `rank` VALUES (17, 32, 31200, 2, 1777558687, 0, 0, 'ijb222', 'ijb222', '超级炸弹(624倍)');
INSERT INTO `rank` VALUES (17, 1000, 20005, 1000, 1699933775, 1, 0, '11111', '11111', '11111');
INSERT INTO `rank` VALUES (17, 1001, 1, 1001, 1777468005, 1, 0, '66455', '66455', '66455');
INSERT INTO `rank` VALUES (18, 2, 137856, 137856, 1777314269, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (18, 6, 52880, 1, 1779512384, 0, 0, 'plm123', 'plm123', '牛魔王(661倍)');
INSERT INTO `rank` VALUES (18, 10, 20000, 20000, 1777476205, 0, 0, '55555', '55555', '中大奖');
INSERT INTO `rank` VALUES (18, 19, 1740000, 5, 1700078909, 0, 0, 'woshini', 'woshini', '大三元(174倍)');
INSERT INTO `rank` VALUES (18, 32, 29350, 2, 1777468376, 0, 0, '55555', '55555', '超级炸弹(587倍)');
INSERT INTO `rank` VALUES (18, 1000, 20001, 1000, 1779708184, 1, 0, '168169', '168169', '168169');
INSERT INTO `rank` VALUES (18, 1001, 1, 1001, 1777488160, 1, 0, '2352314623', '2352314623', '2352314623');
INSERT INTO `rank` VALUES (19, 2, 137856, 137856, 1777314310, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (19, 6, 51440, 2, 1779709180, 0, 0, 'ijb222', 'ijb222', '超级炸弹(643倍)');
INSERT INTO `rank` VALUES (19, 10, 20000, 20000, 1777303833, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (19, 19, 1740000, 5, 1700079202, 0, 0, 'woshini', 'woshini', '大三元(174倍)');
INSERT INTO `rank` VALUES (19, 32, 28600, 2, 1777557913, 0, 0, 'ijb222', 'ijb222', '超级炸弹(572倍)');
INSERT INTO `rank` VALUES (19, 1000, 19972, 1000, 1779441863, 1, 0, 'mm23456', 'mm23456', 'mm23456');
INSERT INTO `rank` VALUES (19, 1001, 1, 1001, 1782901182, 1, 1, 'test01', '测试勿动', '测试勿动');
INSERT INTO `rank` VALUES (20, 2, 137856, 137856, 1777314352, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (20, 6, 51280, 2, 1779474830, 0, 0, 'plm123', 'plm123', '超级炸弹(641倍)');
INSERT INTO `rank` VALUES (20, 10, 20000, 20000, 1777474992, 0, 0, '55555', '55555', '中大奖');
INSERT INTO `rank` VALUES (20, 19, 1740000, 5, 1700079268, 0, 0, 'woshini', 'woshini', '大三元(174倍)');
INSERT INTO `rank` VALUES (20, 32, 27750, 2, 1777558263, 0, 0, 'ijb222', 'ijb222', '超级炸弹(555倍)');
INSERT INTO `rank` VALUES (20, 1000, 19407, 1000, 1779760253, 1, 0, 'M5120', 'M5120', 'M5120');

-- ----------------------------
-- Table structure for rechargerecords
-- ----------------------------
DROP TABLE IF EXISTS `rechargerecords`;
CREATE TABLE `rechargerecords`  (
  `OrderNo` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '订单编号',
  `RechargeType` int(11) NULL DEFAULT NULL COMMENT '充值类型 1微信 2支付宝',
  `Coin` bigint(20) NULL DEFAULT NULL COMMENT '充值数量',
  `BEF_COINS` bigint(20) NULL DEFAULT 0 COMMENT '充值前金币',
  `AFT_COINS` bigint(20) NULL DEFAULT 0 COMMENT '充值后金币',
  `GameID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '玩家游戏ID',
  `AccountType` int(11) NULL DEFAULT 0 COMMENT '账号类型  0玩家  1代理',
  `Agency` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '代理ID',
  `PayNo` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '付款账号',
  `Processed` int(11) NULL DEFAULT 0 COMMENT '处理状态 0未处理 1已处理 2拒绝处理',
  `CreateTime` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  PRIMARY KEY (`OrderNo`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '充值记录信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of rechargerecords
-- ----------------------------

-- ----------------------------
-- Table structure for robot_seat
-- ----------------------------
DROP TABLE IF EXISTS `robot_seat`;
CREATE TABLE `robot_seat`  (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `GAME_TYPE` int(11) NULL DEFAULT NULL COMMENT '游戏类型',
  `GAME_ID` int(11) NULL DEFAULT NULL COMMENT '游戏ID',
  `GAME_NAME` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '游戏名称',
  `ROOM_NAME` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '房间名称',
  `ROOM_ID` int(11) NULL DEFAULT NULL COMMENT '房间id',
  `TABLE_ID` int(11) NULL DEFAULT NULL COMMENT '机台id',
  `ROBOT_NO` int(11) NULL DEFAULT NULL COMMENT '机器人 人数',
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 511 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of robot_seat
-- ----------------------------
INSERT INTO `robot_seat` VALUES (413, 2, 3, '金蟾捕鱼', '中级场', 1, 2, 2);
INSERT INTO `robot_seat` VALUES (414, 2, 3, '金蟾捕鱼', '高级场', 2, 1, 2);
INSERT INTO `robot_seat` VALUES (416, 2, 6, '牛魔王', '中级场', 1, 1, 3);
INSERT INTO `robot_seat` VALUES (419, 2, 13, '李逵劈鱼', '中级场', 1, 1, 3);
INSERT INTO `robot_seat` VALUES (420, 2, 13, '李逵劈鱼', '高级场', 2, 1, 2);
INSERT INTO `robot_seat` VALUES (426, 2, 21, '双响金龙鱼', '中级场', 1, 1, 2);
INSERT INTO `robot_seat` VALUES (432, 2, 32, '神龙宝藏', '中级场', 1, 1, 2);
INSERT INTO `robot_seat` VALUES (433, 2, 32, '神龙宝藏', '高级场', 2, 1, 2);
INSERT INTO `robot_seat` VALUES (435, 2, 33, '史前巨鳄', '中级场', 1, 1, 2);
INSERT INTO `robot_seat` VALUES (441, 2, 49, '美人鱼', '中级场', 1, 1, 2);
INSERT INTO `robot_seat` VALUES (442, 2, 49, '美人鱼', '高级场', 2, 1, 2);
INSERT INTO `robot_seat` VALUES (443, 0, 2, '彩金单挑', '初级场', 0, 1, 3);
INSERT INTO `robot_seat` VALUES (444, 0, 2, '彩金单挑', '中级场', 1, 1, 4);
INSERT INTO `robot_seat` VALUES (445, 0, 2, '彩金单挑', '高级场', 2, 1, 3);
INSERT INTO `robot_seat` VALUES (447, 0, 10, '幸运六狮', '中级场', 1, 1, 2);
INSERT INTO `robot_seat` VALUES (449, 1, 5, '火凤凰', '初级场', 0, 1, 1);
INSERT INTO `robot_seat` VALUES (450, 1, 5, '火凤凰', '初级场', 0, 3, 1);
INSERT INTO `robot_seat` VALUES (451, 1, 5, '火凤凰', '中级场', 1, 2, 1);
INSERT INTO `robot_seat` VALUES (452, 1, 5, '火凤凰', '中级场', 1, 5, 1);
INSERT INTO `robot_seat` VALUES (453, 1, 5, '火凤凰', '高级场', 2, 1, 1);
INSERT INTO `robot_seat` VALUES (454, 1, 5, '火凤凰', '高级场', 2, 4, 1);
INSERT INTO `robot_seat` VALUES (455, 1, 15, '大字板', '初级场', 0, 3, 1);
INSERT INTO `robot_seat` VALUES (456, 1, 15, '大字板', '初级场', 0, 1, 1);
INSERT INTO `robot_seat` VALUES (457, 1, 15, '大字板', '中级场', 1, 2, 1);
INSERT INTO `robot_seat` VALUES (458, 1, 15, '大字板', '中级场', 1, 6, 1);
INSERT INTO `robot_seat` VALUES (459, 1, 15, '大字板', '高级场', 2, 7, 1);
INSERT INTO `robot_seat` VALUES (460, 1, 15, '大字板', '高级场', 2, 1, 1);
INSERT INTO `robot_seat` VALUES (463, 2, 6, '牛魔王', '高级场', 2, 3, 1);
INSERT INTO `robot_seat` VALUES (468, 0, 2, '彩金单挑', '初级场', 0, 2, 3);
INSERT INTO `robot_seat` VALUES (474, 2, 3, '金蟾捕鱼', '初级场', 0, 1, 2);
INSERT INTO `robot_seat` VALUES (475, 2, 6, '牛魔王', '初级场', 0, 1, 3);
INSERT INTO `robot_seat` VALUES (476, 2, 13, '李逵劈鱼', '初级场', 0, 1, 3);
INSERT INTO `robot_seat` VALUES (477, 2, 19, '摇钱树', '初级场', 0, 2, 2);
INSERT INTO `robot_seat` VALUES (478, 2, 32, '神龙宝藏', '初级场', 0, 1, 3);
INSERT INTO `robot_seat` VALUES (479, 2, 33, '史前巨鳄', '初级场', 0, 2, 3);
INSERT INTO `robot_seat` VALUES (480, 2, 49, '美人鱼', '初级场', 0, 2, 3);
INSERT INTO `robot_seat` VALUES (481, 2, 21, '双响金龙鱼', '初级场', 0, 2, 2);
INSERT INTO `robot_seat` VALUES (482, 2, 19, '摇钱树', '中级场', 1, 2, 3);
INSERT INTO `robot_seat` VALUES (483, 2, 19, '摇钱树', '高级场', 2, 1, 3);
INSERT INTO `robot_seat` VALUES (484, 2, 21, '双响金龙鱼', '高级场', 2, 2, 3);
INSERT INTO `robot_seat` VALUES (485, 2, 33, '史前巨鳄', '高级场', 2, 1, 2);
INSERT INTO `robot_seat` VALUES (487, 2, 3, '金蟾捕鱼', '初级场', 0, 0, 3);
INSERT INTO `robot_seat` VALUES (490, 0, 10, '幸运六狮', '初级场', 0, 0, 3);
INSERT INTO `robot_seat` VALUES (492, 2, 19, '摇钱树', '初级场', 0, 3, 4);
INSERT INTO `robot_seat` VALUES (493, 0, 47, '奔驰宝马', '初级场', 0, 1, 3);
INSERT INTO `robot_seat` VALUES (494, 0, 47, '奔驰宝马', '中级场', 1, 2, 4);
INSERT INTO `robot_seat` VALUES (495, 0, 47, '奔驰宝马', '高级场', 2, 2, 4);
INSERT INTO `robot_seat` VALUES (496, 0, 29, '金鲨银鲨', '初级场', 0, 1, 3);
INSERT INTO `robot_seat` VALUES (497, 0, 29, '金鲨银鲨', '中级场', 1, 1, 3);
INSERT INTO `robot_seat` VALUES (498, 0, 29, '金鲨银鲨', '高级场', 2, 1, 5);
INSERT INTO `robot_seat` VALUES (499, 0, 2, '彩金单挑', '初级场', 0, 0, 2);
INSERT INTO `robot_seat` VALUES (500, 0, 29, '金鲨银鲨', '初级场', 0, 0, 8);
INSERT INTO `robot_seat` VALUES (501, 1, 44, 'NBA', '初级场', 0, 1, 1);
INSERT INTO `robot_seat` VALUES (502, 3, 16, '明星97', '', 0, 1, 2);
INSERT INTO `robot_seat` VALUES (503, 3, 16, '明星97', '', 1, 1, 2);
INSERT INTO `robot_seat` VALUES (504, 3, 16, '明星97', '', 2, 1, 2);
INSERT INTO `robot_seat` VALUES (505, 3, 40, '水果拉霸', '', 0, 1, 2);
INSERT INTO `robot_seat` VALUES (506, 3, 40, '水果拉霸', '', 1, 1, 2);
INSERT INTO `robot_seat` VALUES (507, 3, 40, '水果拉霸', '', 2, 1, 2);
INSERT INTO `robot_seat` VALUES (508, 3, 53, '水浒传', '', 0, 1, 2);
INSERT INTO `robot_seat` VALUES (509, 3, 53, '水浒传', '', 1, 1, 2);
INSERT INTO `robot_seat` VALUES (510, 3, 53, '水浒传', '', 2, 1, 2);

-- ----------------------------
-- Table structure for roomtableconfig
-- ----------------------------
DROP TABLE IF EXISTS `roomtableconfig`;
CREATE TABLE `roomtableconfig`  (
  `ID` int(11) NOT NULL AUTO_INCREMENT COMMENT '唯一自增主键',
  `GAME_ID` int(11) NOT NULL COMMENT '关联的游戏ID',
  `RoomIndex` int(11) NOT NULL COMMENT '房间号',
  `TableIndex` int(11) NOT NULL DEFAULT -1 COMMENT '桌号（-1表示该房通用）',
  `TableName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '独立桌名显示',
  `SeatCount` int(11) NOT NULL DEFAULT 4 COMMENT '桌台座位上限数（支持4人/6人）',
  `ExchangeRate` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '1:1' COMMENT '游戏兑换比率',
  `MinBringIn` bigint(20) NOT NULL DEFAULT 0 COMMENT '最小带入金币',
  `MaxBringIn` bigint(20) NOT NULL DEFAULT 0 COMMENT '最大带入金币（0为不设限）',
  `IdleFireTimeoutSec` int(11) NOT NULL DEFAULT 0 COMMENT '无发炮踢出秒数，0=不踢',
  `IdleFireKickEnabled` int(11) NOT NULL DEFAULT 0 COMMENT '是否启用踢出机制 (0/1)',
  `MinBetUnits` int(11) NOT NULL DEFAULT 0 COMMENT '最小下注/炮值（缩放整数格式）',
  `DifScaled` int(11) NOT NULL DEFAULT 0 COMMENT '难度（缩放整数）',
  `Enabled` int(11) NOT NULL DEFAULT 1 COMMENT '启用/隐藏状态',
  `MaxSeats` int(11) NOT NULL DEFAULT 6 COMMENT '??????0=?????6=?????8=????',
  PRIMARY KEY (`ID`) USING BTREE,
  INDEX `idx_game_room_table`(`GAME_ID`, `RoomIndex`, `TableIndex`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5300001 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '动态桌台配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of roomtableconfig
-- ----------------------------
INSERT INTO `roomtableconfig` VALUES (200000, 2, 0, 0, '桌台1', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (200001, 2, 0, 1, '桌台2', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (200002, 2, 0, 2, '桌台3', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (200003, 2, 0, 3, '004', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (300000, 3, 0, 0, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (300001, 3, 0, 1, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (300002, 3, 0, 2, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (500000, 5, 0, 0, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 0);
INSERT INTO `roomtableconfig` VALUES (500001, 5, 0, 1, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 0);
INSERT INTO `roomtableconfig` VALUES (500002, 5, 0, 2, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 0);
INSERT INTO `roomtableconfig` VALUES (600000, 6, 0, 0, '桌台1', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (600001, 6, 0, 1, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (600002, 6, 0, 2, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (1000000, 10, 0, 0, '', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (1000001, 10, 0, 1, '', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (1000002, 10, 0, 2, '', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (1300000, 13, 0, 0, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (1300001, 13, 0, 1, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (1300002, 13, 0, 2, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (1300003, 13, 0, 3, '789', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (1400000, 14, 0, 0, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 0);
INSERT INTO `roomtableconfig` VALUES (1400001, 14, 0, 1, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 0);
INSERT INTO `roomtableconfig` VALUES (1400002, 14, 0, 2, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 0);
INSERT INTO `roomtableconfig` VALUES (1500000, 15, 0, 0, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 0);
INSERT INTO `roomtableconfig` VALUES (1500001, 15, 0, 1, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 0);
INSERT INTO `roomtableconfig` VALUES (1500002, 15, 0, 2, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 0);
INSERT INTO `roomtableconfig` VALUES (1600000, 16, 0, 0, '明星97', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (1900000, 19, 0, 0, '001', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (1900001, 19, 0, 1, '008', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (1900002, 19, 0, 2, '009', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (1900003, 19, 0, 3, '010', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (1900004, 19, 0, 4, '011', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (1900005, 19, 0, 5, '012', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (1900006, 19, 0, 6, '013', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (1900007, 19, 0, 7, '014', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (1900008, 19, 0, 8, '016', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (1900009, 19, 0, 9, '017', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (2100000, 21, 0, 0, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (2100001, 21, 0, 1, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (2100002, 21, 0, 2, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (2200000, 22, 0, 0, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (2200001, 22, 0, 1, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (2200002, 22, 0, 2, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (2900000, 29, 0, 0, '桌台1', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (2900001, 29, 0, 1, '桌台2', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (2900002, 29, 0, 2, '桌台3', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (2900003, 29, 0, 3, '004', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (3200000, 32, 0, 0, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (3200001, 32, 0, 1, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (3200002, 32, 0, 2, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (3300000, 33, 0, 0, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (3300001, 33, 0, 1, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (3300002, 33, 0, 2, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (4000000, 40, 0, 0, '水果拉霸', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (4200000, 42, 0, 0, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (4200001, 42, 0, 1, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (4200002, 42, 0, 2, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (4400000, 44, 0, 0, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 0);
INSERT INTO `roomtableconfig` VALUES (4400001, 44, 0, 1, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 0);
INSERT INTO `roomtableconfig` VALUES (4400002, 44, 0, 2, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 0);
INSERT INTO `roomtableconfig` VALUES (4700000, 47, 0, 0, '桌台1', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (4700001, 47, 0, 1, '桌台2', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (4700002, 47, 0, 2, '桌台3', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (4900000, 49, 0, 0, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (4900001, 49, 0, 1, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (4900002, 49, 0, 2, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (4900003, 49, 0, 3, '88', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6);
INSERT INTO `roomtableconfig` VALUES (5300000, 53, 0, 0, '水浒传', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6);

-- ----------------------------
-- Table structure for safe_coins_log
-- ----------------------------
DROP TABLE IF EXISTS `safe_coins_log`;
CREATE TABLE `safe_coins_log`  (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `USER_ID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户id',
  `TYPE` int(11) NULL DEFAULT NULL COMMENT '类型，0取出，1存入',
  `COINS` bigint(20) NULL DEFAULT 0 COMMENT '取出、存入金额',
  `NEW_COINS` bigint(20) NULL DEFAULT NULL COMMENT '剩余金额',
  `SAFE_COINS` bigint(20) NULL DEFAULT NULL COMMENT '保险柜金额',
  `CREATE_TIME` datetime(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '保险柜取出存入金额记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of safe_coins_log
-- ----------------------------
INSERT INTO `safe_coins_log` VALUES (1, '123123', 1, 999, 9999000, 999, '2026-04-28 17:29:09');
INSERT INTO `safe_coins_log` VALUES (2, '123123', 0, 999, 999, 0, '2026-04-28 18:15:21');
INSERT INTO `safe_coins_log` VALUES (3, '321321', 1, 500000, 512122, 500000, '2026-04-29 02:13:13');

-- ----------------------------
-- Table structure for sharebonus
-- ----------------------------
DROP TABLE IF EXISTS `sharebonus`;
CREATE TABLE `sharebonus`  (
  `ID` int(11) NOT NULL AUTO_INCREMENT COMMENT '推广主键ID',
  `UserId` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户ID',
  `Coin` decimal(32, 2) NULL DEFAULT NULL COMMENT '充值数量',
  `Processed` int(11) NULL DEFAULT 0 COMMENT '状态 0未领取 1已领取',
  `CreateTime` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `CommissionRate` decimal(32, 2) NULL DEFAULT 10.00 COMMENT '佣金比例  百分比  0.01%-100%',
  `DestUserId` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '充值人的账号',
  `Remarks` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '推广分享奖金日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sharebonus
-- ----------------------------
INSERT INTO `sharebonus` VALUES (3, '333', 50.00, 0, '2023-07-25 19:32:43', 5.00, NULL, NULL);
INSERT INTO `sharebonus` VALUES (4, '333', 100.00, 0, '2023-07-25 19:33:00', 10.00, NULL, NULL);
INSERT INTO `sharebonus` VALUES (5, '333', 50.00, 0, '2023-07-25 19:46:41', 5.00, '444', '用户[444]充值金币1000，代理[333]根据佣金比例5.00%，获取奖励50.00');
INSERT INTO `sharebonus` VALUES (6, '222', 100.00, 1, '2023-07-25 19:46:41', 10.00, '444', '用户[444]充值金币1000，代理[222]根据佣金比例10.00%，获取奖励100.00');
INSERT INTO `sharebonus` VALUES (7, '444', 300.00, 0, '2023-07-27 19:54:47', 10.00, NULL, NULL);
INSERT INTO `sharebonus` VALUES (8, '555', 4000.00, 0, '2023-07-27 19:55:01', 10.00, NULL, NULL);
INSERT INTO `sharebonus` VALUES (9, '222', 5000.00, 0, '2023-07-27 19:55:10', 10.00, NULL, NULL);

-- ----------------------------
-- Table structure for tablecoinrecord
-- ----------------------------
DROP TABLE IF EXISTS `tablecoinrecord`;
CREATE TABLE `tablecoinrecord`  (
  `RecIndex` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '标识ID',
  `GameID` int(11) NOT NULL COMMENT '游戏ID',
  `RoomID` int(11) NOT NULL COMMENT '房间ID',
  `TableID` int(11) NOT NULL COMMENT '桌子索引',
  `Coins` bigint(20) NOT NULL COMMENT '金币数量',
  `CreateTime` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '记录时间',
  PRIMARY KEY (`RecIndex`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '桌子账目信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of tablecoinrecord
-- ----------------------------
INSERT INTO `tablecoinrecord` VALUES (1, 19, 0, 1, -870, '2026-06-25 18:57:31');
INSERT INTO `tablecoinrecord` VALUES (2, 6, 0, 1, -3400, '2026-06-26 16:19:59');
INSERT INTO `tablecoinrecord` VALUES (3, 6, 0, 9, -900, '2026-06-26 16:20:22');
INSERT INTO `tablecoinrecord` VALUES (4, 19, 0, 5, 1250, '2026-06-26 21:24:31');
INSERT INTO `tablecoinrecord` VALUES (5, 19, 0, 9, 15110, '2026-06-26 22:59:11');
INSERT INTO `tablecoinrecord` VALUES (6, 33, 0, 3, -35100, '2026-06-29 19:05:23');
INSERT INTO `tablecoinrecord` VALUES (7, 44, 0, 1, 10, '2026-06-29 19:05:48');
INSERT INTO `tablecoinrecord` VALUES (8, 29, 1, 4, -120, '2026-07-01 20:40:53');
INSERT INTO `tablecoinrecord` VALUES (9, 29, 0, 0, -10, '2026-07-01 20:47:08');
INSERT INTO `tablecoinrecord` VALUES (10, 2, 0, 1, -20, '2026-07-01 21:18:57');
INSERT INTO `tablecoinrecord` VALUES (11, 47, 0, 0, 301, '2026-07-01 21:25:59');
INSERT INTO `tablecoinrecord` VALUES (12, 33, 0, 1, -2000, '2026-07-01 21:30:29');
INSERT INTO `tablecoinrecord` VALUES (13, 5, 0, 2, 10, '2026-07-01 21:52:56');
INSERT INTO `tablecoinrecord` VALUES (14, 14, 0, 4, -10, '2026-07-01 21:53:14');
INSERT INTO `tablecoinrecord` VALUES (15, 44, 0, 4, -10, '2026-07-01 21:53:47');
INSERT INTO `tablecoinrecord` VALUES (16, 47, 2, 6, -88, '2026-07-02 14:01:22');
INSERT INTO `tablecoinrecord` VALUES (17, 19, 0, 3, 9365, '2026-07-02 14:02:46');
INSERT INTO `tablecoinrecord` VALUES (18, 10, 0, 1, -15, '2026-07-02 14:05:03');
INSERT INTO `tablecoinrecord` VALUES (19, 29, 2, 6, -73, '2026-07-02 14:37:47');

-- ----------------------------
-- Table structure for transferlog
-- ----------------------------
DROP TABLE IF EXISTS `transferlog`;
CREATE TABLE `transferlog`  (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `UserName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户',
  `Status` int(11) NULL DEFAULT NULL COMMENT '免转状态',
  `ClientTransferId` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '订单号',
  `Money` int(11) NULL DEFAULT NULL COMMENT '金额',
  `CreateTime` datetime(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '日期',
  `Remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PlatType` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of transferlog
-- ----------------------------

-- ----------------------------
-- Table structure for updateaddrnew
-- ----------------------------
DROP TABLE IF EXISTS `updateaddrnew`;
CREATE TABLE `updateaddrnew`  (
  `Idx` int(11) NOT NULL AUTO_INCREMENT,
  `AndriodVer` int(11) NULL DEFAULT NULL,
  `AndroidAddr` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '',
  `IOSVer` int(11) NULL DEFAULT 0,
  `IOSAddr` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '',
  `PCVer` int(11) NULL DEFAULT 0,
  `PCAddr` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '',
  `NAME` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '',
  PRIMARY KEY (`Idx`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '更新地址表_NEW' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of updateaddrnew
-- ----------------------------

-- ----------------------------
-- Table structure for uploadsimage
-- ----------------------------
DROP TABLE IF EXISTS `uploadsimage`;
CREATE TABLE `uploadsimage`  (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `ImagePath` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `ImageName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `ImageType` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of uploadsimage
-- ----------------------------
INSERT INTO `uploadsimage` VALUES (1, '(二维码)202103111038072633.jpg', '支付宝收款二维码', 'http://8.129.72.227:8081/Upload/');
INSERT INTO `uploadsimage` VALUES (2, '(二维码)202103111038137926.jpg', '微信收款二维码', 'http://8.129.72.227:8081/Upload/');

-- ----------------------------
-- Table structure for usercontrolstatus
-- ----------------------------
DROP TABLE IF EXISTS `usercontrolstatus`;
CREATE TABLE `usercontrolstatus`  (
  `ID` int(11) NOT NULL AUTO_INCREMENT COMMENT '唯一自增主键',
  `UserID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '被控玩家账号ID',
  `GameType` int(11) NOT NULL COMMENT '游戏类型枚举（1鱼机/2注机/3牌机/4押注类）',
  `GameId` int(11) NOT NULL COMMENT '针对的具体游戏',
  `ControlMode` int(11) NOT NULL COMMENT '1=Kill(点杀), 2=Release(放水), 3=Limit(金币上限)',
  `TargetCoins` bigint(20) NOT NULL DEFAULT 0 COMMENT '目标吸/放金币总数',
  `ConsumedCoins` bigint(20) NOT NULL DEFAULT 0 COMMENT '已吃/已消耗金币数',
  `GrantedCoins` bigint(20) NOT NULL DEFAULT 0 COMMENT '已放/已赠予金币数',
  `LimitCoins` bigint(20) NOT NULL DEFAULT 0 COMMENT '金币上限阈值',
  `KillRatio` int(11) NOT NULL DEFAULT 60 COMMENT '点杀/放水时的单局胜率/抽水控制系数(如60代表6/4开)',
  `Status` int(11) NOT NULL DEFAULT 0 COMMENT '0=Active(执行中), 1=Expired(过期), 2=Completed(达成)',
  `CreatedBy` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '建立此控制的操作人账号',
  `CreatedTime` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '控制起始时间',
  `ExpiredTime` datetime(0) NULL DEFAULT NULL COMMENT '预设的失效时间',
  PRIMARY KEY (`ID`) USING BTREE,
  INDEX `idx_userid_status`(`UserID`, `Status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '玩家控制有限状态机表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of usercontrolstatus
-- ----------------------------

-- ----------------------------
-- Table structure for usercontrolvalue
-- ----------------------------
DROP TABLE IF EXISTS `usercontrolvalue`;
CREATE TABLE `usercontrolvalue`  (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `USERID` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `GAME_TYPE` int(11) NULL DEFAULT NULL,
  `CONTROL_TYPE` int(11) NULL DEFAULT NULL COMMENT '功能',
  `CONTROL_VALUE` int(11) NULL DEFAULT NULL COMMENT '控值',
  `NUMBER` int(11) NULL DEFAULT NULL COMMENT '次数',
  `TOTAL_NUMBER` int(11) NULL DEFAULT NULL COMMENT '总次数',
  PRIMARY KEY (`ID`, `USERID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 335 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of usercontrolvalue
-- ----------------------------
INSERT INTO `usercontrolvalue` VALUES (308, 'yyyy11', 1, 14, 3, 2, 10);
INSERT INTO `usercontrolvalue` VALUES (309, '11111', 2, 2, 9, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (310, '123123', 2, 2, 9, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (311, '321321', 2, 2, 9, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (312, '55555', 0, 3, 0, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (313, 'a123123', 2, 2, 3, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (314, '113301', 2, 2, 3, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (315, 'okn199', 2, 2, 0, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (316, 'okn668', 0, 4, 3, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (317, 'plm123', 2, 1, 0, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (318, 'okn122', 2, 1, 0, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (319, 'ijb222', 2, 2, 0, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (320, 'uhv333', 2, 1, 0, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (321, 'a1314', 2, 2, 0, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (322, '112255', 0, 4, 0, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (323, '112244', 2, 1, 0, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (324, 'hs112233', 0, 3, 0, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (325, 'lai9982660', 2, 2, 3, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (326, '11223300', 2, 1, 0, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (327, '88668899', 2, 2, 3, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (328, 'a1315', 2, 2, 0, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (329, '111111', 2, 2, 3, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (330, 'a1311', 2, 2, 0, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (331, 'mm23456', 2, 1, 0, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (332, '0001897777777', 1, 5, 0, 10, 20);
INSERT INTO `usercontrolvalue` VALUES (333, '1897777777', 2, 1, 9, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (334, '001897777777', 1, 5, 0, 10, 10);

-- ----------------------------
-- Table structure for userlockrecord
-- ----------------------------
DROP TABLE IF EXISTS `userlockrecord`;
CREATE TABLE `userlockrecord`  (
  `RecIndex` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '标识ID',
  `RechargeType` int(11) NULL DEFAULT NULL COMMENT '充值类型 1微信 2支付宝 20后台充值 21后台兑换',
  `OptResult` int(11) NULL DEFAULT 0 COMMENT '充值、兑换后台处理结果  0失败  1成功',
  `ID` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户账号',
  PRIMARY KEY (`RecIndex`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户锁定记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of userlockrecord
-- ----------------------------
INSERT INTO `userlockrecord` VALUES (1, 1, 1, 'yyyy22');
INSERT INTO `userlockrecord` VALUES (2, 1, 1, 'qaz998877');
INSERT INTO `userlockrecord` VALUES (3, 0, 1, 'wx123456');
INSERT INTO `userlockrecord` VALUES (4, 0, 1, '122133144');
INSERT INTO `userlockrecord` VALUES (5, 0, 1, '381185127');
INSERT INTO `userlockrecord` VALUES (6, 0, 1, '55555');
INSERT INTO `userlockrecord` VALUES (7, 0, 1, '999999');
INSERT INTO `userlockrecord` VALUES (8, 0, 1, '888888');
INSERT INTO `userlockrecord` VALUES (9, 0, 1, 'a123123');
INSERT INTO `userlockrecord` VALUES (10, 0, 1, '6758854');
INSERT INTO `userlockrecord` VALUES (11, 0, 1, 'plm123');
INSERT INTO `userlockrecord` VALUES (12, 0, 1, 'okn122');
INSERT INTO `userlockrecord` VALUES (13, 0, 1, 'ijb222');
INSERT INTO `userlockrecord` VALUES (14, 0, 1, 'uhv333');
INSERT INTO `userlockrecord` VALUES (15, 0, 1, 'z9889');
INSERT INTO `userlockrecord` VALUES (16, 0, 1, 'tt010');
INSERT INTO `userlockrecord` VALUES (17, 0, 1, 'wang88');
INSERT INTO `userlockrecord` VALUES (18, 0, 1, 'mm666888');
INSERT INTO `userlockrecord` VALUES (19, 0, 1, '898989');
INSERT INTO `userlockrecord` VALUES (20, 0, 1, '112233');
INSERT INTO `userlockrecord` VALUES (21, 0, 1, '112244');
INSERT INTO `userlockrecord` VALUES (22, 3, 1, 'okn199');
INSERT INTO `userlockrecord` VALUES (23, 0, 1, '1007628203');
INSERT INTO `userlockrecord` VALUES (24, 0, 1, 'iii101');

-- ----------------------------
-- Table structure for useroptlog
-- ----------------------------
DROP TABLE IF EXISTS `useroptlog`;
CREATE TABLE `useroptlog`  (
  `LID` bigint(20) NOT NULL AUTO_INCREMENT,
  `UserID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '玩家账号',
  `OPT` int(11) NULL DEFAULT 0 COMMENT '操作类型',
  `OPT_COINS` bigint(20) NULL DEFAULT 0 COMMENT '操作币数量',
  `COINS` bigint(20) NULL DEFAULT 0 COMMENT '当前币量',
  `SCORE` bigint(20) NULL DEFAULT 0 COMMENT '分值',
  `ROOM` int(11) NULL DEFAULT 0,
  `GAME_TYPE` int(11) NULL DEFAULT 0,
  `REC_TIME` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  `REC_WEEK` int(11) NULL DEFAULT 0,
  `TABLE_ID` int(11) NULL DEFAULT 0 COMMENT '桌子号',
  `SEAT_ID` int(11) NULL DEFAULT 0 COMMENT '位置号',
  PRIMARY KEY (`LID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 108 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of useroptlog
-- ----------------------------
INSERT INTO `useroptlog` VALUES (1, 'test01', 8, 0, 999978, 0, 0, 19, '2026-06-25 18:57:04', 0, 0, 3);
INSERT INTO `useroptlog` VALUES (2, 'test01', 7, 0, 999788, 0, 0, 19, '2026-06-25 18:57:31', 0, 0, 3);
INSERT INTO `useroptlog` VALUES (3, 'test01', 8, 0, 999788, 0, 0, 19, '2026-06-26 11:30:44', 0, 0, 3);
INSERT INTO `useroptlog` VALUES (4, 'test01', 7, 0, 999558, 0, 0, 19, '2026-06-26 11:31:14', 0, 0, 3);
INSERT INTO `useroptlog` VALUES (5, 'test01', 8, 0, 999558, 0, 0, 19, '2026-06-26 14:47:35', 0, 0, 4);
INSERT INTO `useroptlog` VALUES (6, 'test01', 7, 0, 999483, 0, 0, 19, '2026-06-26 14:47:55', 0, 0, 4);
INSERT INTO `useroptlog` VALUES (7, 'test01', 8, 0, 999483, 0, 0, 19, '2026-06-26 14:47:58', 0, 0, 5);
INSERT INTO `useroptlog` VALUES (8, 'test01', 7, 0, 999418, 0, 0, 19, '2026-06-26 14:48:11', 0, 0, 5);
INSERT INTO `useroptlog` VALUES (9, 'test01', 8, 0, 999418, 0, 0, 19, '2026-06-26 14:48:13', 0, 0, 3);
INSERT INTO `useroptlog` VALUES (10, 'test01', 7, 0, 999418, 0, 0, 19, '2026-06-26 14:48:23', 0, 0, 3);
INSERT INTO `useroptlog` VALUES (11, 'test01', 8, 0, 999418, 0, 0, 19, '2026-06-26 14:48:25', 0, 0, 2);
INSERT INTO `useroptlog` VALUES (12, 'test01', 7, 0, 999398, 0, 0, 19, '2026-06-26 14:48:33', 0, 0, 2);
INSERT INTO `useroptlog` VALUES (13, 'test01', 8, 0, 999398, 0, 0, 19, '2026-06-26 16:16:50', 0, 0, 4);
INSERT INTO `useroptlog` VALUES (14, 'test01', 7, 0, 999273, 0, 0, 19, '2026-06-26 16:19:26', 0, 0, 4);
INSERT INTO `useroptlog` VALUES (15, 'test01', 8, 0, 999273, 0, 0, 6, '2026-06-26 16:19:39', 0, 0, 4);
INSERT INTO `useroptlog` VALUES (16, 'test01', 7, 0, 995873, 0, 0, 6, '2026-06-26 16:19:59', 0, 0, 4);
INSERT INTO `useroptlog` VALUES (17, 'test01', 8, 0, 995873, 0, 0, 6, '2026-06-26 16:20:11', 0, 8, 4);
INSERT INTO `useroptlog` VALUES (18, 'test01', 7, 0, 994973, 0, 0, 6, '2026-06-26 16:20:22', 0, 8, 4);
INSERT INTO `useroptlog` VALUES (19, 'test01', 8, 0, 994973, 0, 0, 5, '2026-06-26 21:04:04', 0, 4, 0);
INSERT INTO `useroptlog` VALUES (20, 'test01', 7, 0, 994973, 0, 0, 5, '2026-06-26 21:04:14', 0, 4, 0);
INSERT INTO `useroptlog` VALUES (21, 'test01', 8, 0, 994973, 0, 0, 19, '2026-06-26 21:24:21', 0, 4, 1);
INSERT INTO `useroptlog` VALUES (22, 'test01', 7, 0, 996223, 0, 0, 19, '2026-06-26 21:24:31', 0, 4, 1);
INSERT INTO `useroptlog` VALUES (23, 'test01', 8, 0, 996223, 0, 0, 19, '2026-06-26 22:58:12', 0, 8, 4);
INSERT INTO `useroptlog` VALUES (24, 'test01', 7, 0, 1011333, 0, 0, 19, '2026-06-26 22:59:11', 0, 8, 4);
INSERT INTO `useroptlog` VALUES (25, 'test01', 8, 0, 1011333, 0, 0, 19, '2026-06-29 14:03:10', 0, 0, 1);
INSERT INTO `useroptlog` VALUES (26, 'test01', 8, 0, 1011313, 0, 0, 14, '2026-06-29 19:04:27', 0, 2, 0);
INSERT INTO `useroptlog` VALUES (27, 'test01', 7, 0, 1011313, 0, 0, 14, '2026-06-29 19:04:36', 0, 2, 0);
INSERT INTO `useroptlog` VALUES (28, 'test01', 8, 0, 1011313, 0, 0, 33, '2026-06-29 19:04:49', 0, 2, 1);
INSERT INTO `useroptlog` VALUES (29, 'test01', 7, 0, 1008913, 0, 0, 33, '2026-06-29 19:05:23', 0, 2, 1);
INSERT INTO `useroptlog` VALUES (30, 'test01', 8, 0, 1008913, 0, 0, 44, '2026-06-29 19:05:31', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (31, 'test01', 7, 0, 1008923, 0, 0, 44, '2026-06-29 19:05:49', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (32, 'test01', 8, 0, 1008923, 0, 1, 29, '2026-06-29 19:06:13', 0, 4, 0);
INSERT INTO `useroptlog` VALUES (33, 'test01', 7, 0, 1008923, 0, 1, 29, '2026-06-29 19:06:31', 0, 4, 0);
INSERT INTO `useroptlog` VALUES (34, 'test01', 8, 0, 1008923, 0, 0, 10, '2026-06-29 19:06:39', 0, 0, 7);
INSERT INTO `useroptlog` VALUES (35, 'test01', 7, 0, 1008923, 0, 0, 10, '2026-06-29 19:06:55', 0, 0, 7);
INSERT INTO `useroptlog` VALUES (36, 'test01', 8, 0, 1008923, 0, 0, 29, '2026-06-29 19:07:39', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (37, 'test01', 7, 0, 1008923, 0, 0, 29, '2026-06-29 19:07:46', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (38, 'test01', 8, 0, 1008923, 0, 0, 47, '2026-06-29 19:07:54', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (39, 'test01', 7, 0, 1008923, 0, 0, 47, '2026-06-29 19:08:14', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (40, 'test01', 8, 0, 1008923, 0, 0, 2, '2026-06-29 19:08:22', 0, 0, 3);
INSERT INTO `useroptlog` VALUES (41, 'test01', 7, 0, 1008923, 0, 0, 2, '2026-06-29 19:08:31', 0, 0, 3);
INSERT INTO `useroptlog` VALUES (42, 'test01', 8, 0, 1008923, 0, 0, 15, '2026-06-29 19:08:38', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (43, 'test01', 7, 0, 1008923, 0, 0, 15, '2026-06-29 19:08:42', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (44, 'test01', 8, 0, 1008923, 0, 0, 29, '2026-06-29 19:14:38', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (45, 'test01', 7, 0, 1008923, 0, 0, 29, '2026-06-29 19:15:01', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (46, 'test01', 8, 0, 1008923, 0, 1, 29, '2026-07-01 18:31:48', 0, 4, 0);
INSERT INTO `useroptlog` VALUES (47, 'test01', 7, 0, 1008923, 0, 1, 29, '2026-07-01 18:32:28', 0, 4, 0);
INSERT INTO `useroptlog` VALUES (48, 'test01', 8, 0, 1008923, 0, 0, 33, '2026-07-01 18:32:57', 0, 2, 1);
INSERT INTO `useroptlog` VALUES (49, 'test01', 7, 0, 976223, 0, 0, 33, '2026-07-01 18:36:14', 0, 2, 1);
INSERT INTO `useroptlog` VALUES (50, 'test01', 8, 0, 976223, 0, 1, 47, '2026-07-01 18:40:26', 0, 1, 0);
INSERT INTO `useroptlog` VALUES (51, 'test01', 7, 0, 976223, 0, 1, 47, '2026-07-01 18:41:36', 0, 1, 0);
INSERT INTO `useroptlog` VALUES (52, 'test01', 8, 0, 976223, 0, 0, 2, '2026-07-01 19:58:44', 0, 0, 5);
INSERT INTO `useroptlog` VALUES (53, 'test01', 7, 0, 976223, 0, 0, 2, '2026-07-01 19:58:57', 0, 0, 5);
INSERT INTO `useroptlog` VALUES (54, 'test01', 8, 0, 976223, 0, 0, 10, '2026-07-01 19:59:07', 0, 0, 6);
INSERT INTO `useroptlog` VALUES (55, 'test01', 7, 0, 976223, 0, 0, 10, '2026-07-01 19:59:16', 0, 0, 6);
INSERT INTO `useroptlog` VALUES (56, 'test01', 8, 0, 976223, 0, 1, 29, '2026-07-01 19:59:23', 0, 4, 0);
INSERT INTO `useroptlog` VALUES (57, 'test01', 7, 0, 976223, 0, 1, 29, '2026-07-01 20:00:31', 0, 4, 0);
INSERT INTO `useroptlog` VALUES (58, 'test01', 8, 0, 976223, 0, 1, 29, '2026-07-01 20:33:15', 0, 4, 0);
INSERT INTO `useroptlog` VALUES (59, 'test01', 7, 0, 976223, 0, 1, 29, '2026-07-01 20:38:34', 0, 4, 0);
INSERT INTO `useroptlog` VALUES (60, 'test01', 8, 0, 976223, 0, 1, 29, '2026-07-01 20:39:16', 0, 4, 0);
INSERT INTO `useroptlog` VALUES (61, 'test01', 7, 0, 976183, 0, 1, 29, '2026-07-01 20:40:53', 0, 4, 0);
INSERT INTO `useroptlog` VALUES (62, 'test01', 8, 0, 976183, 0, 1, 29, '2026-07-01 20:41:18', 0, 4, 0);
INSERT INTO `useroptlog` VALUES (63, 'test01', 7, 0, 976103, 0, 1, 29, '2026-07-01 20:43:40', 0, 4, 0);
INSERT INTO `useroptlog` VALUES (64, 'test01', 8, 0, 976103, 0, 0, 29, '2026-07-01 20:43:55', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (65, 'test01', 7, 0, 976093, 0, 0, 29, '2026-07-01 20:47:08', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (66, 'test01', 8, 0, 976093, 0, 1, 29, '2026-07-01 21:01:13', 0, 4, 0);
INSERT INTO `useroptlog` VALUES (67, 'test01', 7, 0, 976093, 0, 1, 29, '2026-07-01 21:01:21', 0, 4, 0);
INSERT INTO `useroptlog` VALUES (68, 'test01', 8, 0, 976093, 0, 0, 2, '2026-07-01 21:17:56', 0, 0, 4);
INSERT INTO `useroptlog` VALUES (69, 'test01', 8, 0, 976073, 0, 0, 47, '2026-07-01 21:24:42', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (70, 'test01', 8, 0, 976073, 0, 0, 47, '2026-07-01 21:25:02', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (71, 'test01', 7, 0, 976374, 0, 0, 47, '2026-07-01 21:25:59', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (72, 'test01', 8, 0, 976374, 0, 0, 33, '2026-07-01 21:29:57', 0, 0, 2);
INSERT INTO `useroptlog` VALUES (73, 'test01', 7, 0, 974374, 0, 0, 33, '2026-07-01 21:30:29', 0, 0, 2);
INSERT INTO `useroptlog` VALUES (74, 'test01', 8, 0, 974374, 0, 0, 19, '2026-07-01 21:44:27', 0, 0, 1);
INSERT INTO `useroptlog` VALUES (75, 'test01', 7, 0, 974209, 0, 0, 19, '2026-07-01 21:45:03', 0, 0, 1);
INSERT INTO `useroptlog` VALUES (76, 'test01', 8, 0, 974209, 0, 0, 47, '2026-07-01 21:45:19', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (77, 'test01', 7, 0, 974209, 0, 0, 47, '2026-07-01 21:45:26', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (78, 'test01', 8, 0, 974209, 0, 0, 5, '2026-07-01 21:51:29', 0, 1, 0);
INSERT INTO `useroptlog` VALUES (79, 'test01', 7, 0, 974219, 0, 0, 5, '2026-07-01 21:52:56', 0, 1, 0);
INSERT INTO `useroptlog` VALUES (80, 'test01', 8, 0, 974219, 0, 0, 14, '2026-07-01 21:53:04', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (81, 'test01', 7, 0, 974209, 0, 0, 14, '2026-07-01 21:53:14', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (82, 'test01', 8, 0, 974209, 0, 0, 15, '2026-07-01 21:53:22', 0, 4, 0);
INSERT INTO `useroptlog` VALUES (83, 'test01', 7, 0, 974209, 0, 0, 15, '2026-07-01 21:53:29', 0, 4, 0);
INSERT INTO `useroptlog` VALUES (84, 'test01', 8, 0, 974209, 0, 0, 44, '2026-07-01 21:53:37', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (85, 'test01', 7, 0, 974199, 0, 0, 44, '2026-07-01 21:53:47', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (86, 'test01', 8, 0, 974199, 0, 0, 10, '2026-07-01 21:54:20', 0, 0, 7);
INSERT INTO `useroptlog` VALUES (87, 'test01', 7, 0, 974199, 0, 0, 10, '2026-07-01 21:54:33', 0, 0, 7);
INSERT INTO `useroptlog` VALUES (88, 'test01', 8, 0, 974199, 0, 0, 47, '2026-07-01 22:53:09', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (89, 'test01', 7, 0, 974199, 0, 0, 47, '2026-07-01 22:53:13', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (90, 'test01', 8, 0, 974199, 0, 1, 47, '2026-07-01 23:04:08', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (91, 'test01', 7, 0, 974199, 0, 1, 47, '2026-07-01 23:04:16', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (92, 'test01', 8, 0, 974199, 0, 0, 47, '2026-07-01 23:29:29', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (93, 'test01', 7, 0, 974199, 0, 0, 47, '2026-07-01 23:29:33', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (94, 'test01', 8, 0, 974199, 0, 1, 47, '2026-07-01 23:59:27', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (95, 'test01', 7, 0, 974199, 0, 1, 47, '2026-07-01 23:59:31', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (96, 'test01', 8, 0, 974199, 0, 2, 47, '2026-07-02 13:59:33', 0, 6, 0);
INSERT INTO `useroptlog` VALUES (97, 'test01', 7, 0, 974111, 0, 2, 47, '2026-07-02 14:01:22', 0, 6, 0);
INSERT INTO `useroptlog` VALUES (98, 'test01', 8, 0, 974111, 0, 0, 19, '2026-07-02 14:02:18', 0, 2, 1);
INSERT INTO `useroptlog` VALUES (99, 'test01', 7, 0, 983476, 0, 0, 19, '2026-07-02 14:02:46', 0, 2, 1);
INSERT INTO `useroptlog` VALUES (100, 'test01', 8, 0, 983476, 0, 0, 10, '2026-07-02 14:04:47', 0, 0, 5);
INSERT INTO `useroptlog` VALUES (101, 'test01', 7, 0, 983461, 0, 0, 10, '2026-07-02 14:05:03', 0, 0, 5);
INSERT INTO `useroptlog` VALUES (102, 'test01', 8, 0, 983461, 0, 1, 29, '2026-07-02 14:34:53', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (103, 'test01', 7, 0, 983461, 0, 1, 29, '2026-07-02 14:35:00', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (104, 'test01', 8, 0, 983461, 0, 2, 29, '2026-07-02 14:37:10', 0, 6, 0);
INSERT INTO `useroptlog` VALUES (105, 'test01', 7, 0, 983388, 0, 2, 29, '2026-07-02 14:37:48', 0, 6, 0);
INSERT INTO `useroptlog` VALUES (106, 'test01', 8, 0, 983388, 0, 1, 47, '2026-07-02 14:38:00', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (107, 'test01', 7, 0, 983388, 0, 1, 47, '2026-07-02 14:38:05', 0, 3, 0);

-- ----------------------------
-- Table structure for userrelations
-- ----------------------------
DROP TABLE IF EXISTS `userrelations`;
CREATE TABLE `userrelations`  (
  `UserID` int(11) NOT NULL AUTO_INCREMENT COMMENT '用户唯一标识ID',
  `ID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户账号',
  PRIMARY KEY (`UserID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 800714 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户唯一标识信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of userrelations
-- ----------------------------
INSERT INTO `userrelations` VALUES (800614, 'yyyy11');
INSERT INTO `userrelations` VALUES (800615, '11111');
INSERT INTO `userrelations` VALUES (800616, '381185127');
INSERT INTO `userrelations` VALUES (800617, 'woshini');
INSERT INTO `userrelations` VALUES (800618, '951291243');
INSERT INTO `userrelations` VALUES (800619, '121212');
INSERT INTO `userrelations` VALUES (800620, '55555');
INSERT INTO `userrelations` VALUES (800621, '999999');
INSERT INTO `userrelations` VALUES (800622, '123123');
INSERT INTO `userrelations` VALUES (800623, '321321');
INSERT INTO `userrelations` VALUES (800624, '777777');
INSERT INTO `userrelations` VALUES (800625, '888888');
INSERT INTO `userrelations` VALUES (800626, '666666');
INSERT INTO `userrelations` VALUES (800627, '113300');
INSERT INTO `userrelations` VALUES (800628, '113301');
INSERT INTO `userrelations` VALUES (800629, 'a123123');
INSERT INTO `userrelations` VALUES (800630, '18879090617');
INSERT INTO `userrelations` VALUES (800631, '112233');
INSERT INTO `userrelations` VALUES (800632, '6758854');
INSERT INTO `userrelations` VALUES (800633, '898989');
INSERT INTO `userrelations` VALUES (800634, '66455');
INSERT INTO `userrelations` VALUES (800635, 'jhucxnbxbbxd');
INSERT INTO `userrelations` VALUES (800636, '2352314623');
INSERT INTO `userrelations` VALUES (800637, '112233');
INSERT INTO `userrelations` VALUES (800643, 'mm666888');
INSERT INTO `userrelations` VALUES (800644, 'plm123');
INSERT INTO `userrelations` VALUES (800645, 'okn122');
INSERT INTO `userrelations` VALUES (800646, 'ijb222');
INSERT INTO `userrelations` VALUES (800647, 'uhv333');
INSERT INTO `userrelations` VALUES (800648, 'a1314');
INSERT INTO `userrelations` VALUES (800649, 'iii101');
INSERT INTO `userrelations` VALUES (800650, '99801');
INSERT INTO `userrelations` VALUES (800651, '112233');
INSERT INTO `userrelations` VALUES (800652, '1007628203');
INSERT INTO `userrelations` VALUES (800653, 'kk12345');
INSERT INTO `userrelations` VALUES (800654, '66466');
INSERT INTO `userrelations` VALUES (800655, '1389045');
INSERT INTO `userrelations` VALUES (800656, 'Ljp6569111');
INSERT INTO `userrelations` VALUES (800657, 'z9889');
INSERT INTO `userrelations` VALUES (800658, 'tt010');
INSERT INTO `userrelations` VALUES (800659, 'wang88');
INSERT INTO `userrelations` VALUES (800660, 'dayzxc');
INSERT INTO `userrelations` VALUES (800661, 'xy001');
INSERT INTO `userrelations` VALUES (800662, '13890456');
INSERT INTO `userrelations` VALUES (800663, 'hs112233');
INSERT INTO `userrelations` VALUES (800664, '2859587153');
INSERT INTO `userrelations` VALUES (800665, '21584');
INSERT INTO `userrelations` VALUES (800666, 'yu233131422');
INSERT INTO `userrelations` VALUES (800669, '898989');
INSERT INTO `userrelations` VALUES (800670, 'a5882907');
INSERT INTO `userrelations` VALUES (800672, 'li890801');
INSERT INTO `userrelations` VALUES (800673, '369258');
INSERT INTO `userrelations` VALUES (800678, '147258369');
INSERT INTO `userrelations` VALUES (800679, '55555555');
INSERT INTO `userrelations` VALUES (800681, 'a1315');
INSERT INTO `userrelations` VALUES (800682, 'a1316');
INSERT INTO `userrelations` VALUES (800684, '111111');
INSERT INTO `userrelations` VALUES (800685, 'a1317');
INSERT INTO `userrelations` VALUES (800687, 'a1311');
INSERT INTO `userrelations` VALUES (800688, 'a1322');
INSERT INTO `userrelations` VALUES (800689, 'a1333');
INSERT INTO `userrelations` VALUES (800690, 'a1344');
INSERT INTO `userrelations` VALUES (800691, '13655861091');
INSERT INTO `userrelations` VALUES (800692, 'mm23456');
INSERT INTO `userrelations` VALUES (800693, 'okn199');
INSERT INTO `userrelations` VALUES (800694, 'test01');
INSERT INTO `userrelations` VALUES (800695, 'a1319');
INSERT INTO `userrelations` VALUES (800696, '555666');
INSERT INTO `userrelations` VALUES (800697, '1897777777');
INSERT INTO `userrelations` VALUES (800698, 'a13111');
INSERT INTO `userrelations` VALUES (800699, 'a13112');
INSERT INTO `userrelations` VALUES (800700, 'test02');
INSERT INTO `userrelations` VALUES (800701, 'a13114');
INSERT INTO `userrelations` VALUES (800702, 'a13115');
INSERT INTO `userrelations` VALUES (800703, 'test03');
INSERT INTO `userrelations` VALUES (800704, 'a0011');
INSERT INTO `userrelations` VALUES (800705, 'a0022');
INSERT INTO `userrelations` VALUES (800706, '147741');
INSERT INTO `userrelations` VALUES (800707, 'a1319');
INSERT INTO `userrelations` VALUES (800708, '888669');
INSERT INTO `userrelations` VALUES (800709, 'M5120');
INSERT INTO `userrelations` VALUES (800710, 'L5520');
INSERT INTO `userrelations` VALUES (800711, '168169');
INSERT INTO `userrelations` VALUES (800713, 'xt43240788');

-- ----------------------------
-- Table structure for userrobot
-- ----------------------------
DROP TABLE IF EXISTS `userrobot`;
CREATE TABLE `userrobot`  (
  `ID` int(11) NOT NULL AUTO_INCREMENT COMMENT '机器人用户编号',
  `UserName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '机器人账户',
  `UserNick` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '机器人妮称',
  `PassW` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码',
  `Ico` int(10) NOT NULL COMMENT '头像编号',
  `Lev` int(10) NOT NULL COMMENT '等级',
  `Sex` int(10) NOT NULL COMMENT '性别',
  `Gold` int(10) UNSIGNED NOT NULL DEFAULT 1000 COMMENT '金币',
  `IsRobot` int(10) NOT NULL COMMENT '2是1否是机器人',
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1001296 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of userrobot
-- ----------------------------
INSERT INTO `userrobot` VALUES (1001164, 'vnmzw418', '枕星河', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001165, 'tbxph257', '风逐川', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001166, 'sgjdk694', '揽月客', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001167, 'rtsfm371', '醉浮生', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001168, 'qlcnv852', '雾寻踪', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001169, 'pzsqd146', '寒江渡', '123456654321', 0, 1, 0, 23333, 0);
INSERT INTO `userrobot` VALUES (1001170, 'nfbgj739', '赴山河', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001171, 'mvrhk528', '云间鹤', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001172, 'lwdtg367', '枕清欢', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001173, 'kxprm915', '夜归尘', '123456654321', 0, 1, 0, 17777, 0);
INSERT INTO `userrobot` VALUES (1001174, 'jzylv472', '晚风渡山河', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001175, 'hqnbs638', '月下折清欢', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001176, 'fgwrm259', '人间一过客', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001177, 'evjcx814', '烟雨染清秋', '123456654321', 0, 1, 0, 16666, 0);
INSERT INTO `userrobot` VALUES (1001178, 'dltkz375', '枕星入梦来', '123456654321', 0, 1, 0, 16666, 0);
INSERT INTO `userrobot` VALUES (1001179, 'cfpdn592', '青山渡我心', '123456654321', 0, 1, 0, 16666, 0);
INSERT INTO `userrobot` VALUES (1001180, 'bmshg741', '浮生借流年', '123456654321', 0, 1, 0, 17777, 0);
INSERT INTO `userrobot` VALUES (1001181, 'akrbf263', '风寄孤舟', '123456654321', 0, 1, 0, 16666, 0);
INSERT INTO `userrobot` VALUES (1001182, 'hzm248', '鹤归云深处', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001183, 'jbx935', '十里赴长风', '123456654321', 0, 1, 0, 14444, 0);
INSERT INTO `userrobot` VALUES (1001184, 'fqn467', '云端揽清风', '123456654321', 0, 1, 0, 14444, 0);
INSERT INTO `userrobot` VALUES (1001185, 'prv852', '听晚风', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001186, 'cty319', '河皆入梦', '123456654321', 0, 1, 0, 33333, 0);
INSERT INTO `userrobot` VALUES (1001187, 'wgd726', '酌清酒', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001188, 'khj583', '浮生渡流年', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001189, 'zbp941', '晚风不识我', '123456654321', 0, 1, 0, 14555, 0);
INSERT INTO `userrobot` VALUES (1001190, 'lmf275', '孤舟寄', '123456654321', 0, 1, 0, 14444, 0);
INSERT INTO `userrobot` VALUES (1001191, 'qwt592', '无故人', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001192, 'snd638', '人间独行者', '123456654321', 0, 1, 0, 14444, 0);
INSERT INTO `userrobot` VALUES (1001193, 'wxh574', '黑星', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001194, 'dzm328', '花开', '123456654321', 0, 1, 0, 14444, 0);
INSERT INTO `userrobot` VALUES (1001195, 'nly963', '越来越爆', '123456654321', 0, 1, 0, 14544, 0);
INSERT INTO `userrobot` VALUES (1001196, 'vkp482', '啤酒肚', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001197, 'rcz735', '烤鸭', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001198, 'jhd619', '西红柿', '123456654321', 0, 1, 0, 16666, 0);
INSERT INTO `userrobot` VALUES (1001199, 'fyv257', '他来了', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001200, 'bmx846', '飞蛾', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001201, 'gsn371', '非泵', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001202, 'kyg862', '情人', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001203, 'plh254', '还完', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001204, 'zrf937', '厂长', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001205, 'jnl681', '爆来吧', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001206, 'dqj725', '新云注', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001207, 'taz348', '星河落满怀', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001208, 'vbm576', '一起去', '123456654321', 0, 1, 0, 15455, 0);
INSERT INTO `userrobot` VALUES (1001209, 'cwg492', 'qqq', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001210, 'hpx813', '人间借过客', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001211, 'skj265', '里赴千山', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001212, 'lnd751', 'huan', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001213, 'fzt382', '望山河啊', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001214, 'rkm947', 'aaa', '123456654321', 0, 1, 0, 14444, 0);
INSERT INTO `userrobot` VALUES (1001215, 'yph623', '来来来', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001216, 'wcq519', '789789', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001217, 'bzk274', '王敏', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001218, 'nvd835', '清冷', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001219, 'xjf461', '一期生', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001220, 'glr729', '幻想', '123456654321', 0, 1, 0, 14444, 0);
INSERT INTO `userrobot` VALUES (1001221, 'msh358', '黄芪', '123456654321', 0, 1, 0, 16666, 0);
INSERT INTO `userrobot` VALUES (1001222, 'tky268', '修改你', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001223, 'rjx475', '爆你啊', '123456654321', 0, 1, 0, 14444, 0);
INSERT INTO `userrobot` VALUES (1001224, 'pvg814', '干饭第一名', '123456654321', 0, 1, 0, 14444, 0);
INSERT INTO `userrobot` VALUES (1001225, 'czm527', '别打我很菜', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001226, 'bwj369', '专业送人头', '123456654321', 0, 1, 0, 33333, 0);
INSERT INTO `userrobot` VALUES (1001227, 'htn71', '躺平不打工', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001228, 'fdk24', '迷路小能手', '123456654321', 0, 1, 0, 15545, 0);
INSERT INTO `userrobot` VALUES (1001229, 'qrp58', '智商已下线', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001230, 'lzx97', '发呆第一名', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001231, 'smg63', '对手请留情', '123456654321', 0, 1, 0, 16666, 0);
INSERT INTO `userrobot` VALUES (1001232, 'yckv824', '菜到没人打', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001233, 'wfhl536', '偷偷苟个分', '123456654321', 0, 1, 0, 14444, 0);
INSERT INTO `userrobot` VALUES (1001234, 'nzjt147', '晚点', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001235, 'dprg268', '华人', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001236, 'bsqm359', '背着我打', '123456654321', 0, 1, 0, 14444, 0);
INSERT INTO `userrobot` VALUES (1001237, 'hwy462', '一起开始', '123456654321', 0, 1, 0, 11111, 0);
INSERT INTO `userrobot` VALUES (1001238, 'rzt827', '患者', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001239, 'flx615', '搞笑', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001240, 'jdm739', '望着', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001241, 'kvn528', '批量', '123456654321', 0, 1, 0, 18888, 0);
INSERT INTO `userrobot` VALUES (1001242, 'ysdmj369', '牛牛牛', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001243, 'zkrfw258', '雾里看月', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001244, 'bglqv147', '浅念时光', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001245, 'cjxnt782', '落日归期', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001246, 'dprhz531', '随风而a', '123456654321', 0, 1, 0, 11122, 0);
INSERT INTO `userrobot` VALUES (1001247, 'fmwks946', '温渡余', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001248, 'gvbey273', '河入梦', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001249, 'hldpu615', '人间过客1', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001250, 'zcg824', '山野寻风', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001251, 'ksfvn357', '晚风叙', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001252, '1544ff', '花湖话', '123456654321', 0, 1, 0, 11111, 0);
INSERT INTO `userrobot` VALUES (1001253, 'cfdaaa', '245438', '123456654321', 0, 1, 0, 11111, 0);
INSERT INTO `userrobot` VALUES (1001254, '012354', '724505', '123456654321', 0, 1, 0, 11111, 0);
INSERT INTO `userrobot` VALUES (1001255, '665433', '664633', '123456654321', 0, 1, 0, 8888, 0);
INSERT INTO `userrobot` VALUES (1001256, 'jjj28441', '9344741', '123456654321', 0, 1, 0, 12341, 0);
INSERT INTO `userrobot` VALUES (1001257, 'ttt1111', 'juuytrr', '123456654321', 0, 1, 0, 11111, 0);
INSERT INTO `userrobot` VALUES (1001258, 'tre2221', '788777', '123456654321', 0, 1, 0, 15555, 0);
INSERT INTO `userrobot` VALUES (1001259, 'ioiyuu', 'hhhhaa', '123456654321', 0, 1, 0, 22222, 0);
INSERT INTO `userrobot` VALUES (1001260, '521332', '521332', '123456654321', 0, 1, 0, 13332, 0);
INSERT INTO `userrobot` VALUES (1001261, '10125411', '8908021', '123456654321', 0, 1, 0, 12334, 0);
INSERT INTO `userrobot` VALUES (1001262, '3777899', '73090691', '123456654321', 0, 1, 0, 16666, 0);
INSERT INTO `userrobot` VALUES (1001263, '718990', 'VIP878780', '123456654321', 0, 1, 0, 9999, 0);
INSERT INTO `userrobot` VALUES (1001264, '124441', 'VIP718908', '123456654321', 0, 1, 0, 8888, 0);
INSERT INTO `userrobot` VALUES (1001265, '855522', 'VIP188378', '123456654321', 0, 1, 0, 8888, 0);
INSERT INTO `userrobot` VALUES (1001266, '885565', 'VIP457848', '123456654321', 0, 1, 0, 8888, 0);
INSERT INTO `userrobot` VALUES (1001267, '397976', 'VIP397976', '123456654321', 0, 1, 0, 8888, 0);
INSERT INTO `userrobot` VALUES (1001268, '667446', 'VIP667446', '123456654321', 0, 1, 0, 8888, 0);
INSERT INTO `userrobot` VALUES (1001269, '5074741', 'VIP507574', '123456654321', 0, 1, 0, 8888, 0);
INSERT INTO `userrobot` VALUES (1001270, '8770431', 'VIP877043', '123456654321', 0, 1, 0, 8888, 0);
INSERT INTO `userrobot` VALUES (1001271, '2465151', 'VIP246513', '123456654321', 0, 1, 0, 8888, 0);
INSERT INTO `userrobot` VALUES (1001272, '186641', 'VIP186641', '123456654321', 0, 1, 0, 8888, 0);
INSERT INTO `userrobot` VALUES (1001273, '4561112', 'VIP456111', '123456654321', 0, 1, 0, 8888, 0);
INSERT INTO `userrobot` VALUES (1001274, '7255815', 'VIP725581', '123456654321', 0, 1, 0, 8888, 0);
INSERT INTO `userrobot` VALUES (1001275, '6657801', 'VIP665709', '123456654321', 0, 1, 0, 8888, 0);
INSERT INTO `userrobot` VALUES (1001276, '935178', 'VIP935178', '123456654321', 0, 1, 0, 8888, 0);
INSERT INTO `userrobot` VALUES (1001277, '7753061', 'VIP775306', '123456654321', 0, 1, 0, 9999, 0);
INSERT INTO `userrobot` VALUES (1001278, '9166067', 'VIP916067', '123456654321', 0, 1, 0, 6666, 0);
INSERT INTO `userrobot` VALUES (1001279, '4885741', 'VIP485537', '123456654321', 0, 1, 0, 6666, 0);
INSERT INTO `userrobot` VALUES (1001280, 'RB1001280', 'RB1001280', '123456654321', 0, 1, 0, 300000, 2);
INSERT INTO `userrobot` VALUES (1001281, 'RB1001281', 'RB1001281', '123456654321', 1, 1, 1, 300000, 2);
INSERT INTO `userrobot` VALUES (1001282, 'RB1001282', 'RB1001282', '123456654321', 2, 1, 0, 300000, 2);
INSERT INTO `userrobot` VALUES (1001283, 'RB1001283', 'RB1001283', '123456654321', 3, 1, 1, 300000, 2);
INSERT INTO `userrobot` VALUES (1001284, 'RB1001284', 'RB1001284', '123456654321', 4, 1, 0, 300000, 2);
INSERT INTO `userrobot` VALUES (1001285, 'RB1001285', 'RB1001285', '123456654321', 5, 1, 1, 300000, 2);
INSERT INTO `userrobot` VALUES (1001286, 'RB1001286', 'RB1001286', '123456654321', 6, 1, 0, 300000, 2);
INSERT INTO `userrobot` VALUES (1001287, 'RB1001287', 'RB1001287', '123456654321', 7, 1, 1, 300000, 2);
INSERT INTO `userrobot` VALUES (1001288, 'RB1001288', 'RB1001288', '123456654321', 8, 1, 0, 300000, 2);
INSERT INTO `userrobot` VALUES (1001289, 'RB1001289', 'RB1001289', '123456654321', 9, 1, 1, 300000, 2);
INSERT INTO `userrobot` VALUES (1001290, 'RB1001290', 'RB1001290', '123456654321', 0, 1, 0, 300000, 2);
INSERT INTO `userrobot` VALUES (1001291, 'VIP244644', 'VIP244644', '123456654321', 1, 1, 1, 9999, 0);
INSERT INTO `userrobot` VALUES (1001292, 'VIP833309', 'VIP833309', '123456654321', 1, 1, 1, 9999, 0);
INSERT INTO `userrobot` VALUES (1001293, 'VIP302779', 'VIP302779', '123456654321', 1, 1, 1, 9999, 0);
INSERT INTO `userrobot` VALUES (1001294, 'VIP412377', 'VIP412377', '123456654321', 1, 1, 1, 9999, 0);
INSERT INTO `userrobot` VALUES (1001295, 'VIP621974', 'VIP621974', '123456654321', 1, 1, 1, 9999, 0);

-- ----------------------------
-- Table structure for userrobotnum
-- ----------------------------
DROP TABLE IF EXISTS `userrobotnum`;
CREATE TABLE `userrobotnum`  (
  `GameId` int(11) NOT NULL COMMENT '游戏ID',
  `Name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '游戏名称',
  `Enable` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否启用  0不启用  1启用',
  `GameType` tinyint(4) NOT NULL COMMENT '游戏类型   0押注类  1牌机类  2鱼机类  3其它类',
  `Num` int(11) NOT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '游戏信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of userrobotnum
-- ----------------------------
INSERT INTO `userrobotnum` VALUES (47, '奔驰宝马', 1, 0, 0);
INSERT INTO `userrobotnum` VALUES (1, '骰宝', 1, 0, 0);
INSERT INTO `userrobotnum` VALUES (2, '彩金单挑', 1, 0, 0);
INSERT INTO `userrobotnum` VALUES (3, '金蟾捕鱼', 1, 2, 10);
INSERT INTO `userrobotnum` VALUES (4, '捕鱼达人', 0, 2, 10);
INSERT INTO `userrobotnum` VALUES (5, '火凤凰', 1, 1, 0);
INSERT INTO `userrobotnum` VALUES (6, '牛魔王', 1, 2, 10);
INSERT INTO `userrobotnum` VALUES (7, '三色鳄鱼', 0, 2, 10);
INSERT INTO `userrobotnum` VALUES (8, 'ATT连环炮', 1, 1, 0);
INSERT INTO `userrobotnum` VALUES (9, '人鱼传说', 1, 1, 0);
INSERT INTO `userrobotnum` VALUES (10, '幸运六狮', 1, 0, 0);
INSERT INTO `userrobotnum` VALUES (11, '3D猎鸟', 0, 2, 10);
INSERT INTO `userrobotnum` VALUES (12, '幸运牛牛', 1, 0, 0);
INSERT INTO `userrobotnum` VALUES (13, '李逵劈鱼', 1, 2, 10);
INSERT INTO `userrobotnum` VALUES (14, '金皇冠', 1, 1, 0);
INSERT INTO `userrobotnum` VALUES (15, '大字板', 1, 1, 0);
INSERT INTO `userrobotnum` VALUES (16, '明星97', 0, 0, 0);
INSERT INTO `userrobotnum` VALUES (17, '海王2', 0, 2, 10);
INSERT INTO `userrobotnum` VALUES (18, '西游争霸', 1, 0, 0);
INSERT INTO `userrobotnum` VALUES (19, '摇钱树', 1, 2, 10);
INSERT INTO `userrobotnum` VALUES (20, 'Ring捕鱼', 0, 2, 10);
INSERT INTO `userrobotnum` VALUES (21, '娱乐无穷', 1, 2, 10);
INSERT INTO `userrobotnum` VALUES (22, '空战英豪', 1, 2, 10);
INSERT INTO `userrobotnum` VALUES (23, '火麒麟', 0, 2, 10);
INSERT INTO `userrobotnum` VALUES (24, 'ATT至尊版', 1, 1, 0);
INSERT INTO `userrobotnum` VALUES (25, 'ATT满花板', 1, 1, 0);
INSERT INTO `userrobotnum` VALUES (26, '三色龙', 1, 0, 0);
INSERT INTO `userrobotnum` VALUES (27, '铁甲飞龙', 0, 2, 10);
INSERT INTO `userrobotnum` VALUES (28, '极速飞车', 1, 0, 0);
INSERT INTO `userrobotnum` VALUES (29, '金鲨银鲨', 1, 0, 0);
INSERT INTO `userrobotnum` VALUES (30, '钻石大亨', 0, 2, 10);
INSERT INTO `userrobotnum` VALUES (31, '八鲨闹海', 0, 2, 10);
INSERT INTO `userrobotnum` VALUES (32, '神龙宝藏', 1, 2, 10);
INSERT INTO `userrobotnum` VALUES (33, '史前巨鳄', 1, 2, 10);
INSERT INTO `userrobotnum` VALUES (34, '双响企鹅', 0, 2, 10);
INSERT INTO `userrobotnum` VALUES (35, '娱乐红蟹', 0, 2, 10);
INSERT INTO `userrobotnum` VALUES (36, 'ATT超级至尊', 1, 1, 0);
INSERT INTO `userrobotnum` VALUES (37, 'ATT3', 1, 1, 0);
INSERT INTO `userrobotnum` VALUES (38, '3D捕鱼', 0, 2, 10);
INSERT INTO `userrobotnum` VALUES (39, '糖果派对', 1, 3, 0);
INSERT INTO `userrobotnum` VALUES (40, '水果拉霸', 1, 3, 0);
INSERT INTO `userrobotnum` VALUES (41, '财神发发发', 1, 3, 0);
INSERT INTO `userrobotnum` VALUES (42, '八爪鱼', 1, 2, 10);
INSERT INTO `userrobotnum` VALUES (43, '龙太子', 1, 0, 0);
INSERT INTO `userrobotnum` VALUES (44, 'NBA', 1, 1, 0);
INSERT INTO `userrobotnum` VALUES (45, '真人百家乐', 1, 3, 0);
INSERT INTO `userrobotnum` VALUES (46, '大兵小将', 1, 1, 0);
INSERT INTO `userrobotnum` VALUES (49, '美人鱼', 1, 2, 10);
INSERT INTO `userrobotnum` VALUES (50, '大闹天宫', 0, 2, 10);

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `ID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户账号',
  `NAME` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户昵称',
  `PWD` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '密码',
  `AGENCY` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '代理账号',
  `PIC_INDEX` int(11) NULL DEFAULT 0 COMMENT '头像索引',
  `FROZEN` int(11) NULL DEFAULT 0 COMMENT '冻结  0不冻结  1冻结',
  `COINS` bigint(20) NULL DEFAULT 0 COMMENT '金币',
  `COINS_EXP` bigint(20) NULL DEFAULT 0,
  `COINS_BUY` bigint(20) NULL DEFAULT 0,
  `COINS_BACK` bigint(20) NULL DEFAULT 0,
  `VIDEOGAMEID` int(11) NULL DEFAULT -1,
  `WXHEADIMG` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'nowxheadimg' COMMENT '微信头像',
  `SEX` int(11) NULL DEFAULT 1 COMMENT '性别  1男  2女',
  `LoginType` int(11) NULL DEFAULT 0 COMMENT '登录类型  0普通登录  1微信登录',
  `BMW_SCORE` bigint(20) NULL DEFAULT 0,
  `DICE_SCORE` bigint(20) NULL DEFAULT 0,
  `DT_SCORE` bigint(20) NULL DEFAULT 0,
  `PHENIX_SCORE` bigint(20) NULL DEFAULT 0,
  `JC_SCORE` bigint(20) NULL DEFAULT 0,
  `MAGNATE_SCORE` bigint(20) NULL DEFAULT 0,
  `FISH_COW_SCORE` bigint(20) NULL DEFAULT 0,
  `FISH_CROCODILE_SCORE` bigint(20) NULL DEFAULT 0,
  `CARD_ATT2_SCORE` bigint(20) NOT NULL DEFAULT 0,
  `CARD_FISH_SCORE` bigint(20) NULL DEFAULT 0,
  `BET_ANIMAL_SCORE` bigint(20) NULL DEFAULT 0,
  `FISH_BIRD_SCORE` bigint(20) NULL DEFAULT 0,
  `BET_COW_SCORE` bigint(20) NULL DEFAULT 0,
  `TELEPHONE` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号',
  `INHALL` bit(1) NULL DEFAULT b'0' COMMENT '在线状态',
  `IsRegister` bit(1) NULL DEFAULT b'0' COMMENT '是否注册过视讯，0未注册，1注册',
  `GAME_SCORE` bigint(20) NULL DEFAULT 0,
  `SAFE_PWD` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '123456' COMMENT '保险柜密码，默认123456',
  `SAFE_COINS` bigint(20) NULL DEFAULT 0 COMMENT '保险柜金币数量',
  `GRADE` int(11) NULL DEFAULT 1 COMMENT '等级，默认1',
  `CreateTime` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `Remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '后台备注',
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES ('test01', '测试勿动', '123456', 'admin', 2, 0, 983388, 0, 2037690, 3157236, -1, 'nowxheadimg', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '123', b'1', b'0', 0, '123456', 0, 1, '2026-05-22 11:46:49', '');

-- ----------------------------
-- Table structure for userscoresnapshotledger
-- ----------------------------
DROP TABLE IF EXISTS `userscoresnapshotledger`;
CREATE TABLE `userscoresnapshotledger`  (
  `LID` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `UserID` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `GameID` int(11) NOT NULL DEFAULT 0,
  `LoginSession` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `Coins` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `GameScore` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `TempCoin` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `RecoveredCoins` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `Reason` varchar(96) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `REC_TIME` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`LID`) USING BTREE,
  INDEX `IDX_UserScoreSnapshotLedger_UserID`(`UserID`) USING BTREE,
  INDEX `IDX_UserScoreSnapshotLedger_Reason`(`Reason`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1784 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of userscoresnapshotledger
-- ----------------------------
INSERT INTO `userscoresnapshotledger` VALUES (1, 'test01', 19, 2, 0, 999978, 999978, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:05');
INSERT INTO `userscoresnapshotledger` VALUES (2, 'test01', 19, 2, 0, 999973, 999973, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:14');
INSERT INTO `userscoresnapshotledger` VALUES (3, 'test01', 19, 2, 0, 999968, 999968, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:14');
INSERT INTO `userscoresnapshotledger` VALUES (4, 'test01', 19, 2, 0, 1000013, 1000013, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:14');
INSERT INTO `userscoresnapshotledger` VALUES (5, 'test01', 19, 2, 0, 1000008, 1000008, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:15');
INSERT INTO `userscoresnapshotledger` VALUES (6, 'test01', 19, 2, 0, 1000003, 1000003, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:15');
INSERT INTO `userscoresnapshotledger` VALUES (7, 'test01', 19, 2, 0, 999998, 999998, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:15');
INSERT INTO `userscoresnapshotledger` VALUES (8, 'test01', 19, 2, 0, 999993, 999993, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:15');
INSERT INTO `userscoresnapshotledger` VALUES (9, 'test01', 19, 2, 0, 999988, 999988, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:16');
INSERT INTO `userscoresnapshotledger` VALUES (10, 'test01', 19, 2, 0, 999983, 999983, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:16');
INSERT INTO `userscoresnapshotledger` VALUES (11, 'test01', 19, 2, 0, 999978, 999978, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:17');
INSERT INTO `userscoresnapshotledger` VALUES (12, 'test01', 19, 2, 0, 999973, 999973, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:17');
INSERT INTO `userscoresnapshotledger` VALUES (13, 'test01', 19, 2, 0, 999968, 999968, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:17');
INSERT INTO `userscoresnapshotledger` VALUES (14, 'test01', 19, 2, 0, 999963, 999963, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:17');
INSERT INTO `userscoresnapshotledger` VALUES (15, 'test01', 19, 2, 0, 999958, 999958, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:18');
INSERT INTO `userscoresnapshotledger` VALUES (16, 'test01', 19, 2, 0, 999953, 999953, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:18');
INSERT INTO `userscoresnapshotledger` VALUES (17, 'test01', 19, 2, 0, 999948, 999948, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:18');
INSERT INTO `userscoresnapshotledger` VALUES (18, 'test01', 19, 2, 0, 999943, 999943, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:19');
INSERT INTO `userscoresnapshotledger` VALUES (19, 'test01', 19, 2, 0, 999938, 999938, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:19');
INSERT INTO `userscoresnapshotledger` VALUES (20, 'test01', 19, 2, 0, 999933, 999933, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:23');
INSERT INTO `userscoresnapshotledger` VALUES (21, 'test01', 19, 2, 0, 999928, 999928, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:24');
INSERT INTO `userscoresnapshotledger` VALUES (22, 'test01', 19, 2, 0, 999923, 999923, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:24');
INSERT INTO `userscoresnapshotledger` VALUES (23, 'test01', 19, 2, 0, 999918, 999918, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:24');
INSERT INTO `userscoresnapshotledger` VALUES (24, 'test01', 19, 2, 0, 999913, 999913, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:25');
INSERT INTO `userscoresnapshotledger` VALUES (25, 'test01', 19, 2, 0, 999908, 999908, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:25');
INSERT INTO `userscoresnapshotledger` VALUES (26, 'test01', 19, 2, 0, 999903, 999903, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:25');
INSERT INTO `userscoresnapshotledger` VALUES (27, 'test01', 19, 2, 0, 999898, 999898, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:25');
INSERT INTO `userscoresnapshotledger` VALUES (28, 'test01', 19, 2, 0, 999893, 999893, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:26');
INSERT INTO `userscoresnapshotledger` VALUES (29, 'test01', 19, 2, 0, 999888, 999888, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:26');
INSERT INTO `userscoresnapshotledger` VALUES (30, 'test01', 19, 2, 0, 999883, 999883, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:26');
INSERT INTO `userscoresnapshotledger` VALUES (31, 'test01', 19, 2, 0, 999878, 999878, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:26');
INSERT INTO `userscoresnapshotledger` VALUES (32, 'test01', 19, 2, 0, 999873, 999873, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:26');
INSERT INTO `userscoresnapshotledger` VALUES (33, 'test01', 19, 2, 0, 999868, 999868, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:27');
INSERT INTO `userscoresnapshotledger` VALUES (34, 'test01', 19, 2, 0, 999863, 999863, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:27');
INSERT INTO `userscoresnapshotledger` VALUES (35, 'test01', 19, 2, 0, 999858, 999858, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:27');
INSERT INTO `userscoresnapshotledger` VALUES (36, 'test01', 19, 2, 0, 999853, 999853, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:27');
INSERT INTO `userscoresnapshotledger` VALUES (37, 'test01', 19, 2, 0, 999848, 999848, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:28');
INSERT INTO `userscoresnapshotledger` VALUES (38, 'test01', 19, 2, 0, 999843, 999843, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:28');
INSERT INTO `userscoresnapshotledger` VALUES (39, 'test01', 19, 2, 0, 999838, 999838, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:28');
INSERT INTO `userscoresnapshotledger` VALUES (40, 'test01', 19, 2, 0, 999833, 999833, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:28');
INSERT INTO `userscoresnapshotledger` VALUES (41, 'test01', 19, 2, 0, 999828, 999828, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:29');
INSERT INTO `userscoresnapshotledger` VALUES (42, 'test01', 19, 2, 0, 999823, 999823, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:29');
INSERT INTO `userscoresnapshotledger` VALUES (43, 'test01', 19, 2, 0, 999818, 999818, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:29');
INSERT INTO `userscoresnapshotledger` VALUES (44, 'test01', 19, 2, 0, 999813, 999813, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:29');
INSERT INTO `userscoresnapshotledger` VALUES (45, 'test01', 19, 2, 0, 999808, 999808, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:30');
INSERT INTO `userscoresnapshotledger` VALUES (46, 'test01', 19, 2, 0, 999803, 999803, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:30');
INSERT INTO `userscoresnapshotledger` VALUES (47, 'test01', 19, 2, 0, 999798, 999798, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:30');
INSERT INTO `userscoresnapshotledger` VALUES (48, 'test01', 19, 2, 0, 999793, 999793, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:30');
INSERT INTO `userscoresnapshotledger` VALUES (49, 'test01', 19, 2, 0, 999788, 999788, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:31');
INSERT INTO `userscoresnapshotledger` VALUES (50, 'test01', 19, 2, 999788, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:31');
INSERT INTO `userscoresnapshotledger` VALUES (51, 'test01', 0, 2, 999788, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-25 18:57:43');
INSERT INTO `userscoresnapshotledger` VALUES (52, 'test01', 53, 0, 999788, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 11:24:38');
INSERT INTO `userscoresnapshotledger` VALUES (53, 'test01', 19, 2, 999788, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:26:26');
INSERT INTO `userscoresnapshotledger` VALUES (54, 'test01', 53, 0, 999788, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 11:29:38');
INSERT INTO `userscoresnapshotledger` VALUES (55, 'test01', 19, 2, 0, 999788, 999788, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:30:44');
INSERT INTO `userscoresnapshotledger` VALUES (56, 'test01', 19, 2, 0, 999783, 999783, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:30:56');
INSERT INTO `userscoresnapshotledger` VALUES (57, 'test01', 19, 2, 0, 999778, 999778, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:30:57');
INSERT INTO `userscoresnapshotledger` VALUES (58, 'test01', 19, 2, 0, 999773, 999773, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:30:57');
INSERT INTO `userscoresnapshotledger` VALUES (59, 'test01', 19, 2, 0, 999768, 999768, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:30:58');
INSERT INTO `userscoresnapshotledger` VALUES (60, 'test01', 19, 2, 0, 999763, 999763, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:30:59');
INSERT INTO `userscoresnapshotledger` VALUES (61, 'test01', 19, 2, 0, 999758, 999758, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:00');
INSERT INTO `userscoresnapshotledger` VALUES (62, 'test01', 19, 2, 0, 999753, 999753, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:00');
INSERT INTO `userscoresnapshotledger` VALUES (63, 'test01', 19, 2, 0, 999748, 999748, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:00');
INSERT INTO `userscoresnapshotledger` VALUES (64, 'test01', 19, 2, 0, 999743, 999743, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:01');
INSERT INTO `userscoresnapshotledger` VALUES (65, 'test01', 19, 2, 0, 999738, 999738, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:01');
INSERT INTO `userscoresnapshotledger` VALUES (66, 'test01', 19, 2, 0, 999733, 999733, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:01');
INSERT INTO `userscoresnapshotledger` VALUES (67, 'test01', 19, 2, 0, 999728, 999728, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:02');
INSERT INTO `userscoresnapshotledger` VALUES (68, 'test01', 19, 2, 0, 999723, 999723, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:02');
INSERT INTO `userscoresnapshotledger` VALUES (69, 'test01', 19, 2, 0, 999718, 999718, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:02');
INSERT INTO `userscoresnapshotledger` VALUES (70, 'test01', 19, 2, 0, 999713, 999713, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:03');
INSERT INTO `userscoresnapshotledger` VALUES (71, 'test01', 19, 2, 0, 999708, 999708, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:03');
INSERT INTO `userscoresnapshotledger` VALUES (72, 'test01', 19, 2, 0, 999703, 999703, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:03');
INSERT INTO `userscoresnapshotledger` VALUES (73, 'test01', 19, 2, 0, 999698, 999698, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:03');
INSERT INTO `userscoresnapshotledger` VALUES (74, 'test01', 19, 2, 0, 999693, 999693, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:03');
INSERT INTO `userscoresnapshotledger` VALUES (75, 'test01', 19, 2, 0, 999688, 999688, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:04');
INSERT INTO `userscoresnapshotledger` VALUES (76, 'test01', 19, 2, 0, 999683, 999683, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:04');
INSERT INTO `userscoresnapshotledger` VALUES (77, 'test01', 19, 2, 0, 999678, 999678, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:04');
INSERT INTO `userscoresnapshotledger` VALUES (78, 'test01', 19, 2, 0, 999673, 999673, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:05');
INSERT INTO `userscoresnapshotledger` VALUES (79, 'test01', 19, 2, 0, 999668, 999668, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:05');
INSERT INTO `userscoresnapshotledger` VALUES (80, 'test01', 19, 2, 0, 999663, 999663, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:05');
INSERT INTO `userscoresnapshotledger` VALUES (81, 'test01', 19, 2, 0, 999658, 999658, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:05');
INSERT INTO `userscoresnapshotledger` VALUES (82, 'test01', 19, 2, 0, 999653, 999653, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:06');
INSERT INTO `userscoresnapshotledger` VALUES (83, 'test01', 19, 2, 0, 999688, 999688, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:06');
INSERT INTO `userscoresnapshotledger` VALUES (84, 'test01', 19, 2, 0, 999683, 999683, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:07');
INSERT INTO `userscoresnapshotledger` VALUES (85, 'test01', 19, 2, 0, 999678, 999678, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:07');
INSERT INTO `userscoresnapshotledger` VALUES (86, 'test01', 19, 2, 0, 999673, 999673, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:07');
INSERT INTO `userscoresnapshotledger` VALUES (87, 'test01', 19, 2, 0, 999668, 999668, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:08');
INSERT INTO `userscoresnapshotledger` VALUES (88, 'test01', 19, 2, 0, 999663, 999663, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:08');
INSERT INTO `userscoresnapshotledger` VALUES (89, 'test01', 19, 2, 0, 999658, 999658, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:08');
INSERT INTO `userscoresnapshotledger` VALUES (90, 'test01', 19, 2, 0, 999653, 999653, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:08');
INSERT INTO `userscoresnapshotledger` VALUES (91, 'test01', 19, 2, 0, 999648, 999648, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:09');
INSERT INTO `userscoresnapshotledger` VALUES (92, 'test01', 19, 2, 0, 999643, 999643, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:09');
INSERT INTO `userscoresnapshotledger` VALUES (93, 'test01', 19, 2, 0, 999638, 999638, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:10');
INSERT INTO `userscoresnapshotledger` VALUES (94, 'test01', 19, 2, 0, 999633, 999633, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:10');
INSERT INTO `userscoresnapshotledger` VALUES (95, 'test01', 19, 2, 0, 999628, 999628, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:10');
INSERT INTO `userscoresnapshotledger` VALUES (96, 'test01', 19, 2, 0, 999623, 999623, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:11');
INSERT INTO `userscoresnapshotledger` VALUES (97, 'test01', 19, 2, 0, 999618, 999618, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:11');
INSERT INTO `userscoresnapshotledger` VALUES (98, 'test01', 19, 2, 0, 999613, 999613, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:11');
INSERT INTO `userscoresnapshotledger` VALUES (99, 'test01', 19, 2, 0, 999608, 999608, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:11');
INSERT INTO `userscoresnapshotledger` VALUES (100, 'test01', 19, 2, 0, 999603, 999603, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:12');
INSERT INTO `userscoresnapshotledger` VALUES (101, 'test01', 19, 2, 0, 999598, 999598, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:12');
INSERT INTO `userscoresnapshotledger` VALUES (102, 'test01', 19, 2, 0, 999593, 999593, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:12');
INSERT INTO `userscoresnapshotledger` VALUES (103, 'test01', 19, 2, 0, 999588, 999588, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:12');
INSERT INTO `userscoresnapshotledger` VALUES (104, 'test01', 19, 2, 0, 999583, 999583, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:12');
INSERT INTO `userscoresnapshotledger` VALUES (105, 'test01', 19, 2, 0, 999578, 999578, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:13');
INSERT INTO `userscoresnapshotledger` VALUES (106, 'test01', 19, 2, 0, 999573, 999573, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:13');
INSERT INTO `userscoresnapshotledger` VALUES (107, 'test01', 19, 2, 0, 999568, 999568, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:13');
INSERT INTO `userscoresnapshotledger` VALUES (108, 'test01', 19, 2, 0, 999563, 999563, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:13');
INSERT INTO `userscoresnapshotledger` VALUES (109, 'test01', 19, 2, 0, 999558, 999558, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:14');
INSERT INTO `userscoresnapshotledger` VALUES (110, 'test01', 19, 2, 999558, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 11:31:14');
INSERT INTO `userscoresnapshotledger` VALUES (111, 'test01', 0, 2, 999558, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 12:11:47');
INSERT INTO `userscoresnapshotledger` VALUES (112, 'test01', 53, 0, 999558, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 14:36:53');
INSERT INTO `userscoresnapshotledger` VALUES (113, 'test01', 53, 0, 999558, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 14:37:40');
INSERT INTO `userscoresnapshotledger` VALUES (114, 'test01', 53, 0, 999558, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 14:47:20');
INSERT INTO `userscoresnapshotledger` VALUES (115, 'test01', 19, 6, 0, 999558, 999558, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:35');
INSERT INTO `userscoresnapshotledger` VALUES (116, 'test01', 19, 6, 0, 999553, 999553, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:38');
INSERT INTO `userscoresnapshotledger` VALUES (117, 'test01', 19, 6, 0, 999548, 999548, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:38');
INSERT INTO `userscoresnapshotledger` VALUES (118, 'test01', 19, 6, 0, 999543, 999543, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:38');
INSERT INTO `userscoresnapshotledger` VALUES (119, 'test01', 19, 6, 0, 999538, 999538, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:39');
INSERT INTO `userscoresnapshotledger` VALUES (120, 'test01', 19, 6, 0, 999533, 999533, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:39');
INSERT INTO `userscoresnapshotledger` VALUES (121, 'test01', 19, 6, 0, 999528, 999528, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:39');
INSERT INTO `userscoresnapshotledger` VALUES (122, 'test01', 19, 6, 0, 999523, 999523, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:40');
INSERT INTO `userscoresnapshotledger` VALUES (123, 'test01', 19, 6, 0, 999518, 999518, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:40');
INSERT INTO `userscoresnapshotledger` VALUES (124, 'test01', 19, 6, 0, 999513, 999513, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:40');
INSERT INTO `userscoresnapshotledger` VALUES (125, 'test01', 19, 6, 0, 999508, 999508, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:40');
INSERT INTO `userscoresnapshotledger` VALUES (126, 'test01', 19, 6, 0, 999503, 999503, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:41');
INSERT INTO `userscoresnapshotledger` VALUES (127, 'test01', 19, 6, 0, 999498, 999498, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:41');
INSERT INTO `userscoresnapshotledger` VALUES (128, 'test01', 19, 6, 0, 999493, 999493, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:41');
INSERT INTO `userscoresnapshotledger` VALUES (129, 'test01', 19, 6, 0, 999488, 999488, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:41');
INSERT INTO `userscoresnapshotledger` VALUES (130, 'test01', 19, 6, 0, 999483, 999483, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:41');
INSERT INTO `userscoresnapshotledger` VALUES (131, 'test01', 19, 6, 0, 999478, 999478, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:42');
INSERT INTO `userscoresnapshotledger` VALUES (132, 'test01', 19, 6, 0, 999473, 999473, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:42');
INSERT INTO `userscoresnapshotledger` VALUES (133, 'test01', 19, 6, 0, 999468, 999468, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:42');
INSERT INTO `userscoresnapshotledger` VALUES (134, 'test01', 19, 6, 0, 999463, 999463, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:42');
INSERT INTO `userscoresnapshotledger` VALUES (135, 'test01', 19, 6, 0, 999458, 999458, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:43');
INSERT INTO `userscoresnapshotledger` VALUES (136, 'test01', 19, 6, 0, 999453, 999453, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:43');
INSERT INTO `userscoresnapshotledger` VALUES (137, 'test01', 19, 6, 0, 999448, 999448, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:43');
INSERT INTO `userscoresnapshotledger` VALUES (138, 'test01', 19, 6, 0, 999443, 999443, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:44');
INSERT INTO `userscoresnapshotledger` VALUES (139, 'test01', 19, 6, 0, 999533, 999533, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:44');
INSERT INTO `userscoresnapshotledger` VALUES (140, 'test01', 19, 6, 0, 999528, 999528, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:44');
INSERT INTO `userscoresnapshotledger` VALUES (141, 'test01', 19, 6, 0, 999523, 999523, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:44');
INSERT INTO `userscoresnapshotledger` VALUES (142, 'test01', 19, 6, 0, 999518, 999518, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:44');
INSERT INTO `userscoresnapshotledger` VALUES (143, 'test01', 19, 6, 0, 999513, 999513, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:44');
INSERT INTO `userscoresnapshotledger` VALUES (144, 'test01', 19, 6, 0, 999508, 999508, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:45');
INSERT INTO `userscoresnapshotledger` VALUES (145, 'test01', 19, 6, 0, 999503, 999503, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:45');
INSERT INTO `userscoresnapshotledger` VALUES (146, 'test01', 19, 6, 0, 999498, 999498, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:45');
INSERT INTO `userscoresnapshotledger` VALUES (147, 'test01', 19, 6, 0, 999493, 999493, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:45');
INSERT INTO `userscoresnapshotledger` VALUES (148, 'test01', 19, 6, 0, 999488, 999488, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:46');
INSERT INTO `userscoresnapshotledger` VALUES (149, 'test01', 19, 6, 0, 999483, 999483, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:46');
INSERT INTO `userscoresnapshotledger` VALUES (150, 'test01', 19, 6, 0, 999478, 999478, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:46');
INSERT INTO `userscoresnapshotledger` VALUES (151, 'test01', 19, 6, 0, 999518, 999518, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:46');
INSERT INTO `userscoresnapshotledger` VALUES (152, 'test01', 19, 6, 0, 999513, 999513, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:47');
INSERT INTO `userscoresnapshotledger` VALUES (153, 'test01', 19, 6, 0, 999508, 999508, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:47');
INSERT INTO `userscoresnapshotledger` VALUES (154, 'test01', 19, 6, 0, 999503, 999503, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:47');
INSERT INTO `userscoresnapshotledger` VALUES (155, 'test01', 19, 6, 0, 999498, 999498, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:47');
INSERT INTO `userscoresnapshotledger` VALUES (156, 'test01', 19, 6, 0, 999493, 999493, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:48');
INSERT INTO `userscoresnapshotledger` VALUES (157, 'test01', 19, 6, 0, 999488, 999488, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:48');
INSERT INTO `userscoresnapshotledger` VALUES (158, 'test01', 19, 6, 0, 999483, 999483, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:48');
INSERT INTO `userscoresnapshotledger` VALUES (159, 'test01', 19, 6, 999483, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:54');
INSERT INTO `userscoresnapshotledger` VALUES (160, 'test01', 19, 6, 999483, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:54');
INSERT INTO `userscoresnapshotledger` VALUES (161, 'test01', 19, 6, 999483, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:55');
INSERT INTO `userscoresnapshotledger` VALUES (162, 'test01', 19, 6, 0, 999483, 999483, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:47:58');
INSERT INTO `userscoresnapshotledger` VALUES (163, 'test01', 19, 6, 0, 999478, 999478, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:02');
INSERT INTO `userscoresnapshotledger` VALUES (164, 'test01', 19, 6, 0, 999473, 999473, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:02');
INSERT INTO `userscoresnapshotledger` VALUES (165, 'test01', 19, 6, 0, 999468, 999468, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:03');
INSERT INTO `userscoresnapshotledger` VALUES (166, 'test01', 19, 6, 0, 999463, 999463, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:03');
INSERT INTO `userscoresnapshotledger` VALUES (167, 'test01', 19, 6, 0, 999458, 999458, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:03');
INSERT INTO `userscoresnapshotledger` VALUES (168, 'test01', 19, 6, 0, 999453, 999453, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:03');
INSERT INTO `userscoresnapshotledger` VALUES (169, 'test01', 19, 6, 0, 999448, 999448, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:03');
INSERT INTO `userscoresnapshotledger` VALUES (170, 'test01', 19, 6, 0, 999443, 999443, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:04');
INSERT INTO `userscoresnapshotledger` VALUES (171, 'test01', 19, 6, 0, 999438, 999438, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:04');
INSERT INTO `userscoresnapshotledger` VALUES (172, 'test01', 19, 6, 0, 999433, 999433, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:04');
INSERT INTO `userscoresnapshotledger` VALUES (173, 'test01', 19, 6, 0, 999428, 999428, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:05');
INSERT INTO `userscoresnapshotledger` VALUES (174, 'test01', 19, 6, 0, 999423, 999423, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:05');
INSERT INTO `userscoresnapshotledger` VALUES (175, 'test01', 19, 6, 0, 999418, 999418, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:06');
INSERT INTO `userscoresnapshotledger` VALUES (176, 'test01', 19, 6, 999418, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:09');
INSERT INTO `userscoresnapshotledger` VALUES (177, 'test01', 19, 6, 999418, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:10');
INSERT INTO `userscoresnapshotledger` VALUES (178, 'test01', 19, 6, 999418, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:10');
INSERT INTO `userscoresnapshotledger` VALUES (179, 'test01', 19, 6, 0, 999418, 999418, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:14');
INSERT INTO `userscoresnapshotledger` VALUES (180, 'test01', 19, 6, 999418, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:22');
INSERT INTO `userscoresnapshotledger` VALUES (181, 'test01', 19, 6, 999418, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:23');
INSERT INTO `userscoresnapshotledger` VALUES (182, 'test01', 19, 6, 0, 999418, 999418, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:26');
INSERT INTO `userscoresnapshotledger` VALUES (183, 'test01', 19, 6, 0, 999413, 999413, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:28');
INSERT INTO `userscoresnapshotledger` VALUES (184, 'test01', 19, 6, 0, 999408, 999408, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:28');
INSERT INTO `userscoresnapshotledger` VALUES (185, 'test01', 19, 6, 0, 999403, 999403, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:29');
INSERT INTO `userscoresnapshotledger` VALUES (186, 'test01', 19, 6, 0, 999398, 999398, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:29');
INSERT INTO `userscoresnapshotledger` VALUES (187, 'test01', 19, 6, 999398, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:32');
INSERT INTO `userscoresnapshotledger` VALUES (188, 'test01', 19, 6, 999398, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:32');
INSERT INTO `userscoresnapshotledger` VALUES (189, 'test01', 19, 6, 999398, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 14:48:33');
INSERT INTO `userscoresnapshotledger` VALUES (190, 'test01', 53, 0, 999398, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 14:49:24');
INSERT INTO `userscoresnapshotledger` VALUES (191, 'test01', 53, 0, 999398, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 14:50:10');
INSERT INTO `userscoresnapshotledger` VALUES (192, 'test01', 53, 0, 999398, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 14:51:58');
INSERT INTO `userscoresnapshotledger` VALUES (193, 'test01', 0, 8, 999398, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 15:10:57');
INSERT INTO `userscoresnapshotledger` VALUES (194, 'test01', 53, 0, 999398, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 16:06:46');
INSERT INTO `userscoresnapshotledger` VALUES (195, 'test01', 19, 3, 0, 999398, 999398, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:16:51');
INSERT INTO `userscoresnapshotledger` VALUES (196, 'test01', 19, 3, 0, 999393, 999393, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:19');
INSERT INTO `userscoresnapshotledger` VALUES (197, 'test01', 19, 3, 0, 999388, 999388, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:19');
INSERT INTO `userscoresnapshotledger` VALUES (198, 'test01', 19, 3, 0, 999383, 999383, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:20');
INSERT INTO `userscoresnapshotledger` VALUES (199, 'test01', 19, 3, 0, 999378, 999378, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:20');
INSERT INTO `userscoresnapshotledger` VALUES (200, 'test01', 19, 3, 0, 999373, 999373, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:21');
INSERT INTO `userscoresnapshotledger` VALUES (201, 'test01', 19, 3, 0, 999368, 999368, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:21');
INSERT INTO `userscoresnapshotledger` VALUES (202, 'test01', 19, 3, 0, 999363, 999363, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:21');
INSERT INTO `userscoresnapshotledger` VALUES (203, 'test01', 19, 3, 0, 999358, 999358, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:21');
INSERT INTO `userscoresnapshotledger` VALUES (204, 'test01', 19, 3, 0, 999353, 999353, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:21');
INSERT INTO `userscoresnapshotledger` VALUES (205, 'test01', 19, 3, 0, 999348, 999348, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:22');
INSERT INTO `userscoresnapshotledger` VALUES (206, 'test01', 19, 3, 0, 999343, 999343, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:22');
INSERT INTO `userscoresnapshotledger` VALUES (207, 'test01', 19, 3, 0, 999338, 999338, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:22');
INSERT INTO `userscoresnapshotledger` VALUES (208, 'test01', 19, 3, 0, 999333, 999333, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:22');
INSERT INTO `userscoresnapshotledger` VALUES (209, 'test01', 19, 3, 0, 999328, 999328, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:23');
INSERT INTO `userscoresnapshotledger` VALUES (210, 'test01', 19, 3, 0, 999323, 999323, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:23');
INSERT INTO `userscoresnapshotledger` VALUES (211, 'test01', 19, 3, 0, 999318, 999318, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:23');
INSERT INTO `userscoresnapshotledger` VALUES (212, 'test01', 19, 3, 0, 999313, 999313, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:23');
INSERT INTO `userscoresnapshotledger` VALUES (213, 'test01', 19, 3, 0, 999308, 999308, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:23');
INSERT INTO `userscoresnapshotledger` VALUES (214, 'test01', 19, 3, 0, 999303, 999303, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:24');
INSERT INTO `userscoresnapshotledger` VALUES (215, 'test01', 19, 3, 0, 999298, 999298, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:24');
INSERT INTO `userscoresnapshotledger` VALUES (216, 'test01', 19, 3, 0, 999293, 999293, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:24');
INSERT INTO `userscoresnapshotledger` VALUES (217, 'test01', 19, 3, 0, 999288, 999288, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:24');
INSERT INTO `userscoresnapshotledger` VALUES (218, 'test01', 19, 3, 0, 999283, 999283, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:24');
INSERT INTO `userscoresnapshotledger` VALUES (219, 'test01', 19, 3, 0, 999278, 999278, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:25');
INSERT INTO `userscoresnapshotledger` VALUES (220, 'test01', 19, 3, 0, 999273, 999273, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:25');
INSERT INTO `userscoresnapshotledger` VALUES (221, 'test01', 19, 3, 999273, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:25');
INSERT INTO `userscoresnapshotledger` VALUES (222, 'test01', 19, 3, 999273, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:26');
INSERT INTO `userscoresnapshotledger` VALUES (223, 'test01', 53, 0, 999273, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 16:19:31');
INSERT INTO `userscoresnapshotledger` VALUES (224, 'test01', 6, 4, 0, 999273, 999273, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:39');
INSERT INTO `userscoresnapshotledger` VALUES (225, 'test01', 6, 4, 0, 999173, 999173, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:49');
INSERT INTO `userscoresnapshotledger` VALUES (226, 'test01', 6, 4, 0, 999073, 999073, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:49');
INSERT INTO `userscoresnapshotledger` VALUES (227, 'test01', 6, 4, 0, 998973, 998973, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:50');
INSERT INTO `userscoresnapshotledger` VALUES (228, 'test01', 6, 4, 0, 998873, 998873, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:50');
INSERT INTO `userscoresnapshotledger` VALUES (229, 'test01', 6, 4, 0, 998773, 998773, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:50');
INSERT INTO `userscoresnapshotledger` VALUES (230, 'test01', 6, 4, 0, 998673, 998673, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:50');
INSERT INTO `userscoresnapshotledger` VALUES (231, 'test01', 6, 4, 0, 998573, 998573, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:51');
INSERT INTO `userscoresnapshotledger` VALUES (232, 'test01', 6, 4, 0, 998473, 998473, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:51');
INSERT INTO `userscoresnapshotledger` VALUES (233, 'test01', 6, 4, 0, 998373, 998373, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:51');
INSERT INTO `userscoresnapshotledger` VALUES (234, 'test01', 6, 4, 0, 998273, 998273, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:51');
INSERT INTO `userscoresnapshotledger` VALUES (235, 'test01', 6, 4, 0, 998173, 998173, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:51');
INSERT INTO `userscoresnapshotledger` VALUES (236, 'test01', 6, 4, 0, 998073, 998073, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:52');
INSERT INTO `userscoresnapshotledger` VALUES (237, 'test01', 6, 4, 0, 997973, 997973, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:52');
INSERT INTO `userscoresnapshotledger` VALUES (238, 'test01', 6, 4, 0, 997873, 997873, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:52');
INSERT INTO `userscoresnapshotledger` VALUES (239, 'test01', 6, 4, 0, 997773, 997773, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:52');
INSERT INTO `userscoresnapshotledger` VALUES (240, 'test01', 6, 4, 0, 997673, 997673, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:53');
INSERT INTO `userscoresnapshotledger` VALUES (241, 'test01', 6, 4, 0, 997573, 997573, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:53');
INSERT INTO `userscoresnapshotledger` VALUES (242, 'test01', 6, 4, 0, 997473, 997473, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:53');
INSERT INTO `userscoresnapshotledger` VALUES (243, 'test01', 6, 4, 0, 997373, 997373, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:54');
INSERT INTO `userscoresnapshotledger` VALUES (244, 'test01', 6, 4, 0, 997273, 997273, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:54');
INSERT INTO `userscoresnapshotledger` VALUES (245, 'test01', 6, 4, 0, 997173, 997173, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:54');
INSERT INTO `userscoresnapshotledger` VALUES (246, 'test01', 6, 4, 0, 997073, 997073, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:54');
INSERT INTO `userscoresnapshotledger` VALUES (247, 'test01', 6, 4, 0, 996973, 996973, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:54');
INSERT INTO `userscoresnapshotledger` VALUES (248, 'test01', 6, 4, 0, 996873, 996873, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:54');
INSERT INTO `userscoresnapshotledger` VALUES (249, 'test01', 6, 4, 0, 996773, 996773, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:55');
INSERT INTO `userscoresnapshotledger` VALUES (250, 'test01', 6, 4, 0, 996673, 996673, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:55');
INSERT INTO `userscoresnapshotledger` VALUES (251, 'test01', 6, 4, 0, 996573, 996573, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:55');
INSERT INTO `userscoresnapshotledger` VALUES (252, 'test01', 6, 4, 0, 996473, 996473, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:56');
INSERT INTO `userscoresnapshotledger` VALUES (253, 'test01', 6, 4, 0, 996373, 996373, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:56');
INSERT INTO `userscoresnapshotledger` VALUES (254, 'test01', 6, 4, 0, 996273, 996273, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:56');
INSERT INTO `userscoresnapshotledger` VALUES (255, 'test01', 6, 4, 0, 996173, 996173, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:56');
INSERT INTO `userscoresnapshotledger` VALUES (256, 'test01', 6, 4, 0, 996073, 996073, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:56');
INSERT INTO `userscoresnapshotledger` VALUES (257, 'test01', 6, 4, 0, 995973, 995973, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:56');
INSERT INTO `userscoresnapshotledger` VALUES (258, 'test01', 6, 4, 0, 995873, 995873, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:57');
INSERT INTO `userscoresnapshotledger` VALUES (259, 'test01', 6, 4, 995873, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:57');
INSERT INTO `userscoresnapshotledger` VALUES (260, 'test01', 6, 4, 995873, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:19:59');
INSERT INTO `userscoresnapshotledger` VALUES (261, 'test01', 6, 4, 0, 995873, 995873, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:20:12');
INSERT INTO `userscoresnapshotledger` VALUES (262, 'test01', 6, 4, 0, 995773, 995773, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:20:19');
INSERT INTO `userscoresnapshotledger` VALUES (263, 'test01', 6, 4, 0, 995673, 995673, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:20:19');
INSERT INTO `userscoresnapshotledger` VALUES (264, 'test01', 6, 4, 0, 995573, 995573, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:20:20');
INSERT INTO `userscoresnapshotledger` VALUES (265, 'test01', 6, 4, 0, 995473, 995473, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:20:20');
INSERT INTO `userscoresnapshotledger` VALUES (266, 'test01', 6, 4, 0, 995373, 995373, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:20:20');
INSERT INTO `userscoresnapshotledger` VALUES (267, 'test01', 6, 4, 0, 995273, 995273, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:20:20');
INSERT INTO `userscoresnapshotledger` VALUES (268, 'test01', 6, 4, 0, 995173, 995173, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:20:21');
INSERT INTO `userscoresnapshotledger` VALUES (269, 'test01', 6, 4, 0, 995073, 995073, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:20:21');
INSERT INTO `userscoresnapshotledger` VALUES (270, 'test01', 6, 4, 0, 994973, 994973, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:20:21');
INSERT INTO `userscoresnapshotledger` VALUES (271, 'test01', 6, 4, 994973, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:20:21');
INSERT INTO `userscoresnapshotledger` VALUES (272, 'test01', 6, 4, 994973, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:20:22');
INSERT INTO `userscoresnapshotledger` VALUES (273, 'test01', 6, 4, 994973, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:20:22');
INSERT INTO `userscoresnapshotledger` VALUES (274, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 16:20:40');
INSERT INTO `userscoresnapshotledger` VALUES (275, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 16:20:48');
INSERT INTO `userscoresnapshotledger` VALUES (276, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 16:21:51');
INSERT INTO `userscoresnapshotledger` VALUES (277, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 16:21:58');
INSERT INTO `userscoresnapshotledger` VALUES (278, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 16:22:04');
INSERT INTO `userscoresnapshotledger` VALUES (279, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 16:22:13');
INSERT INTO `userscoresnapshotledger` VALUES (280, 'test01', 0, 10, 994973, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 16:23:02');
INSERT INTO `userscoresnapshotledger` VALUES (281, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 16:33:59');
INSERT INTO `userscoresnapshotledger` VALUES (282, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 16:34:14');
INSERT INTO `userscoresnapshotledger` VALUES (283, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 16:34:26');
INSERT INTO `userscoresnapshotledger` VALUES (284, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 16:37:04');
INSERT INTO `userscoresnapshotledger` VALUES (285, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 16:51:07');
INSERT INTO `userscoresnapshotledger` VALUES (286, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 16:51:23');
INSERT INTO `userscoresnapshotledger` VALUES (287, 'test01', 0, 10, 994973, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 17:02:19');
INSERT INTO `userscoresnapshotledger` VALUES (288, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 17:30:57');
INSERT INTO `userscoresnapshotledger` VALUES (289, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 17:31:02');
INSERT INTO `userscoresnapshotledger` VALUES (290, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 17:31:07');
INSERT INTO `userscoresnapshotledger` VALUES (291, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 17:31:29');
INSERT INTO `userscoresnapshotledger` VALUES (292, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 17:32:15');
INSERT INTO `userscoresnapshotledger` VALUES (293, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 17:35:10');
INSERT INTO `userscoresnapshotledger` VALUES (294, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 17:36:13');
INSERT INTO `userscoresnapshotledger` VALUES (295, 'test01', 0, 13, 994973, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 17:40:33');
INSERT INTO `userscoresnapshotledger` VALUES (296, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 18:40:22');
INSERT INTO `userscoresnapshotledger` VALUES (297, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 18:40:28');
INSERT INTO `userscoresnapshotledger` VALUES (298, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 18:40:35');
INSERT INTO `userscoresnapshotledger` VALUES (299, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 18:41:39');
INSERT INTO `userscoresnapshotledger` VALUES (300, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 18:41:44');
INSERT INTO `userscoresnapshotledger` VALUES (301, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 18:41:53');
INSERT INTO `userscoresnapshotledger` VALUES (302, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 18:42:03');
INSERT INTO `userscoresnapshotledger` VALUES (303, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 18:42:09');
INSERT INTO `userscoresnapshotledger` VALUES (304, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 18:42:31');
INSERT INTO `userscoresnapshotledger` VALUES (305, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 18:42:47');
INSERT INTO `userscoresnapshotledger` VALUES (306, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 18:43:04');
INSERT INTO `userscoresnapshotledger` VALUES (307, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 18:43:17');
INSERT INTO `userscoresnapshotledger` VALUES (308, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 18:43:22');
INSERT INTO `userscoresnapshotledger` VALUES (309, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 18:43:28');
INSERT INTO `userscoresnapshotledger` VALUES (310, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 18:43:34');
INSERT INTO `userscoresnapshotledger` VALUES (311, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 18:43:39');
INSERT INTO `userscoresnapshotledger` VALUES (312, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 18:43:45');
INSERT INTO `userscoresnapshotledger` VALUES (313, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 18:43:51');
INSERT INTO `userscoresnapshotledger` VALUES (314, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 18:43:58');
INSERT INTO `userscoresnapshotledger` VALUES (315, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 18:46:19');
INSERT INTO `userscoresnapshotledger` VALUES (316, 'test01', 0, 24, 994973, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 19:08:34');
INSERT INTO `userscoresnapshotledger` VALUES (317, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 20:02:13');
INSERT INTO `userscoresnapshotledger` VALUES (318, 'test01', 0, 2, 994973, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 20:05:59');
INSERT INTO `userscoresnapshotledger` VALUES (319, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 20:38:15');
INSERT INTO `userscoresnapshotledger` VALUES (320, 'test01', 0, 1, 994973, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 20:38:17');
INSERT INTO `userscoresnapshotledger` VALUES (321, 'test01', 5, 2, 0, 994973, 994973, 0, 'SNAPSHOT_SAVE', '2026-06-26 21:04:05');
INSERT INTO `userscoresnapshotledger` VALUES (322, 'test01', 5, 2, 994973, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 21:04:13');
INSERT INTO `userscoresnapshotledger` VALUES (323, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 21:04:15');
INSERT INTO `userscoresnapshotledger` VALUES (324, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 21:08:57');
INSERT INTO `userscoresnapshotledger` VALUES (325, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 21:24:06');
INSERT INTO `userscoresnapshotledger` VALUES (326, 'test01', 53, 0, 994973, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 21:24:11');
INSERT INTO `userscoresnapshotledger` VALUES (327, 'test01', 19, 6, 0, 994973, 994973, 0, 'SNAPSHOT_SAVE', '2026-06-26 21:24:21');
INSERT INTO `userscoresnapshotledger` VALUES (328, 'test01', 19, 6, 0, 994968, 994968, 0, 'SNAPSHOT_SAVE', '2026-06-26 21:24:25');
INSERT INTO `userscoresnapshotledger` VALUES (329, 'test01', 19, 6, 0, 994963, 994963, 0, 'SNAPSHOT_SAVE', '2026-06-26 21:24:25');
INSERT INTO `userscoresnapshotledger` VALUES (330, 'test01', 19, 6, 0, 995053, 995053, 0, 'SNAPSHOT_SAVE', '2026-06-26 21:24:26');
INSERT INTO `userscoresnapshotledger` VALUES (331, 'test01', 19, 6, 0, 995048, 995048, 0, 'SNAPSHOT_SAVE', '2026-06-26 21:24:26');
INSERT INTO `userscoresnapshotledger` VALUES (332, 'test01', 19, 6, 0, 995043, 995043, 0, 'SNAPSHOT_SAVE', '2026-06-26 21:24:27');
INSERT INTO `userscoresnapshotledger` VALUES (333, 'test01', 19, 6, 0, 995053, 995053, 0, 'SNAPSHOT_SAVE', '2026-06-26 21:24:27');
INSERT INTO `userscoresnapshotledger` VALUES (334, 'test01', 19, 6, 0, 995048, 995048, 0, 'SNAPSHOT_SAVE', '2026-06-26 21:24:28');
INSERT INTO `userscoresnapshotledger` VALUES (335, 'test01', 19, 6, 0, 995043, 995043, 0, 'SNAPSHOT_SAVE', '2026-06-26 21:24:28');
INSERT INTO `userscoresnapshotledger` VALUES (336, 'test01', 19, 6, 0, 995543, 995543, 0, 'SNAPSHOT_SAVE', '2026-06-26 21:24:28');
INSERT INTO `userscoresnapshotledger` VALUES (337, 'test01', 19, 6, 0, 995633, 995633, 0, 'SNAPSHOT_SAVE', '2026-06-26 21:24:29');
INSERT INTO `userscoresnapshotledger` VALUES (338, 'test01', 19, 6, 0, 995723, 995723, 0, 'SNAPSHOT_SAVE', '2026-06-26 21:24:29');
INSERT INTO `userscoresnapshotledger` VALUES (339, 'test01', 19, 6, 995723, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 21:24:29');
INSERT INTO `userscoresnapshotledger` VALUES (340, 'test01', 19, 6, 995723, 500, 500, 0, 'SNAPSHOT_SAVE', '2026-06-26 21:24:30');
INSERT INTO `userscoresnapshotledger` VALUES (341, 'test01', 19, 6, 996223, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 21:24:30');
INSERT INTO `userscoresnapshotledger` VALUES (342, 'test01', 19, 6, 996223, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 21:24:31');
INSERT INTO `userscoresnapshotledger` VALUES (343, 'test01', 53, 0, 996223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 21:25:28');
INSERT INTO `userscoresnapshotledger` VALUES (344, 'test01', 53, 0, 996223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 21:26:13');
INSERT INTO `userscoresnapshotledger` VALUES (345, 'test01', 53, 0, 996223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 21:26:44');
INSERT INTO `userscoresnapshotledger` VALUES (346, 'test01', 53, 0, 996223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 21:29:13');
INSERT INTO `userscoresnapshotledger` VALUES (347, 'test01', 0, 10, 996223, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 21:29:15');
INSERT INTO `userscoresnapshotledger` VALUES (348, 'test01', 53, 0, 996223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 21:40:03');
INSERT INTO `userscoresnapshotledger` VALUES (349, 'test01', 53, 0, 996223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 21:40:16');
INSERT INTO `userscoresnapshotledger` VALUES (350, 'test01', 53, 0, 996223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 21:40:22');
INSERT INTO `userscoresnapshotledger` VALUES (351, 'test01', 53, 0, 996223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 21:40:49');
INSERT INTO `userscoresnapshotledger` VALUES (352, 'test01', 53, 0, 996223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 21:41:01');
INSERT INTO `userscoresnapshotledger` VALUES (353, 'test01', 53, 0, 996223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 21:55:49');
INSERT INTO `userscoresnapshotledger` VALUES (354, 'test01', 53, 0, 996223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 21:58:01');
INSERT INTO `userscoresnapshotledger` VALUES (355, 'test01', 53, 0, 996223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 21:58:10');
INSERT INTO `userscoresnapshotledger` VALUES (356, 'test01', 53, 0, 996223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 22:04:32');
INSERT INTO `userscoresnapshotledger` VALUES (357, 'test01', 53, 0, 996223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 22:05:11');
INSERT INTO `userscoresnapshotledger` VALUES (358, 'test01', 53, 0, 996223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 22:05:51');
INSERT INTO `userscoresnapshotledger` VALUES (359, 'test01', 53, 0, 996223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-26 22:06:00');
INSERT INTO `userscoresnapshotledger` VALUES (360, 'test01', 0, 15, 996223, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:11:56');
INSERT INTO `userscoresnapshotledger` VALUES (361, 'test01', 19, 1, 996223, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:57:40');
INSERT INTO `userscoresnapshotledger` VALUES (362, 'test01', 19, 1, 0, 996223, 996223, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:12');
INSERT INTO `userscoresnapshotledger` VALUES (363, 'test01', 19, 1, 0, 996218, 996218, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:17');
INSERT INTO `userscoresnapshotledger` VALUES (364, 'test01', 19, 1, 0, 996213, 996213, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:19');
INSERT INTO `userscoresnapshotledger` VALUES (365, 'test01', 19, 1, 0, 996413, 996413, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:19');
INSERT INTO `userscoresnapshotledger` VALUES (366, 'test01', 19, 1, 0, 996463, 996463, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:19');
INSERT INTO `userscoresnapshotledger` VALUES (367, 'test01', 19, 1, 0, 996458, 996458, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:19');
INSERT INTO `userscoresnapshotledger` VALUES (368, 'test01', 19, 1, 0, 996558, 996558, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:19');
INSERT INTO `userscoresnapshotledger` VALUES (369, 'test01', 19, 1, 0, 996553, 996553, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:19');
INSERT INTO `userscoresnapshotledger` VALUES (370, 'test01', 19, 1, 0, 996548, 996548, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:19');
INSERT INTO `userscoresnapshotledger` VALUES (371, 'test01', 19, 1, 0, 996543, 996543, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:19');
INSERT INTO `userscoresnapshotledger` VALUES (372, 'test01', 19, 1, 0, 996538, 996538, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:20');
INSERT INTO `userscoresnapshotledger` VALUES (373, 'test01', 19, 1, 0, 996553, 996553, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:20');
INSERT INTO `userscoresnapshotledger` VALUES (374, 'test01', 19, 1, 0, 996548, 996548, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:20');
INSERT INTO `userscoresnapshotledger` VALUES (375, 'test01', 19, 1, 0, 996563, 996563, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:20');
INSERT INTO `userscoresnapshotledger` VALUES (376, 'test01', 19, 1, 0, 996558, 996558, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:20');
INSERT INTO `userscoresnapshotledger` VALUES (377, 'test01', 19, 1, 0, 996553, 996553, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:21');
INSERT INTO `userscoresnapshotledger` VALUES (378, 'test01', 19, 1, 0, 996548, 996548, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:22');
INSERT INTO `userscoresnapshotledger` VALUES (379, 'test01', 19, 1, 0, 996648, 996648, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:22');
INSERT INTO `userscoresnapshotledger` VALUES (380, 'test01', 19, 1, 0, 996643, 996643, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:22');
INSERT INTO `userscoresnapshotledger` VALUES (381, 'test01', 19, 1, 0, 996638, 996638, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:22');
INSERT INTO `userscoresnapshotledger` VALUES (382, 'test01', 19, 1, 0, 996633, 996633, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:22');
INSERT INTO `userscoresnapshotledger` VALUES (383, 'test01', 19, 1, 0, 996723, 996723, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:22');
INSERT INTO `userscoresnapshotledger` VALUES (384, 'test01', 19, 1, 0, 996718, 996718, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:23');
INSERT INTO `userscoresnapshotledger` VALUES (385, 'test01', 19, 1, 0, 996748, 996748, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:23');
INSERT INTO `userscoresnapshotledger` VALUES (386, 'test01', 19, 1, 0, 996743, 996743, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:23');
INSERT INTO `userscoresnapshotledger` VALUES (387, 'test01', 19, 1, 0, 996738, 996738, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:23');
INSERT INTO `userscoresnapshotledger` VALUES (388, 'test01', 19, 1, 0, 996798, 996798, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:23');
INSERT INTO `userscoresnapshotledger` VALUES (389, 'test01', 19, 1, 0, 996793, 996793, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:24');
INSERT INTO `userscoresnapshotledger` VALUES (390, 'test01', 19, 1, 0, 996838, 996838, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:24');
INSERT INTO `userscoresnapshotledger` VALUES (391, 'test01', 19, 1, 0, 996833, 996833, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:24');
INSERT INTO `userscoresnapshotledger` VALUES (392, 'test01', 19, 1, 0, 996828, 996828, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:24');
INSERT INTO `userscoresnapshotledger` VALUES (393, 'test01', 19, 1, 0, 996823, 996823, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:24');
INSERT INTO `userscoresnapshotledger` VALUES (394, 'test01', 19, 1, 0, 996948, 996948, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:24');
INSERT INTO `userscoresnapshotledger` VALUES (395, 'test01', 19, 1, 0, 996943, 996943, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:24');
INSERT INTO `userscoresnapshotledger` VALUES (396, 'test01', 19, 1, 0, 996938, 996938, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:25');
INSERT INTO `userscoresnapshotledger` VALUES (397, 'test01', 19, 1, 0, 996953, 996953, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:25');
INSERT INTO `userscoresnapshotledger` VALUES (398, 'test01', 19, 1, 0, 997003, 997003, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:25');
INSERT INTO `userscoresnapshotledger` VALUES (399, 'test01', 19, 1, 0, 996998, 996998, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:25');
INSERT INTO `userscoresnapshotledger` VALUES (400, 'test01', 19, 1, 0, 997043, 997043, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:25');
INSERT INTO `userscoresnapshotledger` VALUES (401, 'test01', 19, 1, 0, 997038, 997038, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:25');
INSERT INTO `userscoresnapshotledger` VALUES (402, 'test01', 19, 1, 0, 997033, 997033, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:26');
INSERT INTO `userscoresnapshotledger` VALUES (403, 'test01', 19, 1, 0, 997158, 997158, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:26');
INSERT INTO `userscoresnapshotledger` VALUES (404, 'test01', 19, 1, 0, 997248, 997248, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:26');
INSERT INTO `userscoresnapshotledger` VALUES (405, 'test01', 19, 1, 0, 997258, 997258, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:26');
INSERT INTO `userscoresnapshotledger` VALUES (406, 'test01', 19, 1, 0, 997253, 997253, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:26');
INSERT INTO `userscoresnapshotledger` VALUES (407, 'test01', 19, 1, 0, 997248, 997248, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:26');
INSERT INTO `userscoresnapshotledger` VALUES (408, 'test01', 19, 1, 0, 997348, 997348, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:27');
INSERT INTO `userscoresnapshotledger` VALUES (409, 'test01', 19, 1, 0, 997343, 997343, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:27');
INSERT INTO `userscoresnapshotledger` VALUES (410, 'test01', 19, 1, 0, 997338, 997338, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:27');
INSERT INTO `userscoresnapshotledger` VALUES (411, 'test01', 19, 1, 0, 997353, 997353, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:28');
INSERT INTO `userscoresnapshotledger` VALUES (412, 'test01', 19, 1, 0, 997428, 997428, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:28');
INSERT INTO `userscoresnapshotledger` VALUES (413, 'test01', 19, 1, 0, 997423, 997423, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:28');
INSERT INTO `userscoresnapshotledger` VALUES (414, 'test01', 19, 1, 0, 997433, 997433, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:28');
INSERT INTO `userscoresnapshotledger` VALUES (415, 'test01', 19, 1, 0, 997428, 997428, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:29');
INSERT INTO `userscoresnapshotledger` VALUES (416, 'test01', 19, 1, 0, 997488, 997488, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:29');
INSERT INTO `userscoresnapshotledger` VALUES (417, 'test01', 19, 1, 0, 997988, 997988, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:30');
INSERT INTO `userscoresnapshotledger` VALUES (418, 'test01', 19, 1, 0, 997983, 997983, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:30');
INSERT INTO `userscoresnapshotledger` VALUES (419, 'test01', 19, 1, 0, 998028, 998028, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:30');
INSERT INTO `userscoresnapshotledger` VALUES (420, 'test01', 19, 1, 0, 998023, 998023, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:30');
INSERT INTO `userscoresnapshotledger` VALUES (421, 'test01', 19, 1, 0, 998223, 998223, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:30');
INSERT INTO `userscoresnapshotledger` VALUES (422, 'test01', 19, 1, 0, 998373, 998373, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:30');
INSERT INTO `userscoresnapshotledger` VALUES (423, 'test01', 19, 1, 0, 998368, 998368, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:31');
INSERT INTO `userscoresnapshotledger` VALUES (424, 'test01', 19, 1, 0, 998458, 998458, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:31');
INSERT INTO `userscoresnapshotledger` VALUES (425, 'test01', 19, 1, 0, 998548, 998548, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:31');
INSERT INTO `userscoresnapshotledger` VALUES (426, 'test01', 19, 1, 0, 998593, 998593, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:31');
INSERT INTO `userscoresnapshotledger` VALUES (427, 'test01', 19, 1, 0, 998588, 998588, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:31');
INSERT INTO `userscoresnapshotledger` VALUES (428, 'test01', 19, 1, 0, 998583, 998583, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:31');
INSERT INTO `userscoresnapshotledger` VALUES (429, 'test01', 19, 1, 0, 998783, 998783, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:31');
INSERT INTO `userscoresnapshotledger` VALUES (430, 'test01', 19, 1, 0, 998778, 998778, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:31');
INSERT INTO `userscoresnapshotledger` VALUES (431, 'test01', 19, 1, 0, 998788, 998788, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:31');
INSERT INTO `userscoresnapshotledger` VALUES (432, 'test01', 19, 1, 0, 998783, 998783, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:32');
INSERT INTO `userscoresnapshotledger` VALUES (433, 'test01', 19, 1, 0, 998793, 998793, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:32');
INSERT INTO `userscoresnapshotledger` VALUES (434, 'test01', 19, 1, 0, 998788, 998788, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:32');
INSERT INTO `userscoresnapshotledger` VALUES (435, 'test01', 19, 1, 0, 998783, 998783, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:33');
INSERT INTO `userscoresnapshotledger` VALUES (436, 'test01', 19, 1, 0, 998778, 998778, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:33');
INSERT INTO `userscoresnapshotledger` VALUES (437, 'test01', 19, 1, 0, 998773, 998773, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:33');
INSERT INTO `userscoresnapshotledger` VALUES (438, 'test01', 19, 1, 0, 998823, 998823, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:33');
INSERT INTO `userscoresnapshotledger` VALUES (439, 'test01', 19, 1, 0, 998818, 998818, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:33');
INSERT INTO `userscoresnapshotledger` VALUES (440, 'test01', 19, 1, 0, 998828, 998828, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:34');
INSERT INTO `userscoresnapshotledger` VALUES (441, 'test01', 19, 1, 0, 998823, 998823, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:34');
INSERT INTO `userscoresnapshotledger` VALUES (442, 'test01', 19, 1, 0, 998818, 998818, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:34');
INSERT INTO `userscoresnapshotledger` VALUES (443, 'test01', 19, 1, 0, 998828, 998828, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:34');
INSERT INTO `userscoresnapshotledger` VALUES (444, 'test01', 19, 1, 0, 998823, 998823, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:34');
INSERT INTO `userscoresnapshotledger` VALUES (445, 'test01', 19, 1, 0, 998868, 998868, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:34');
INSERT INTO `userscoresnapshotledger` VALUES (446, 'test01', 19, 1, 0, 998863, 998863, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:34');
INSERT INTO `userscoresnapshotledger` VALUES (447, 'test01', 19, 1, 0, 998858, 998858, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:35');
INSERT INTO `userscoresnapshotledger` VALUES (448, 'test01', 19, 1, 0, 999008, 999008, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:35');
INSERT INTO `userscoresnapshotledger` VALUES (449, 'test01', 19, 1, 0, 999003, 999003, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:35');
INSERT INTO `userscoresnapshotledger` VALUES (450, 'test01', 19, 1, 0, 999503, 999503, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:35');
INSERT INTO `userscoresnapshotledger` VALUES (451, 'test01', 19, 1, 0, 999593, 999593, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:36');
INSERT INTO `userscoresnapshotledger` VALUES (452, 'test01', 19, 1, 0, 999588, 999588, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:36');
INSERT INTO `userscoresnapshotledger` VALUES (453, 'test01', 19, 1, 0, 999583, 999583, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:36');
INSERT INTO `userscoresnapshotledger` VALUES (454, 'test01', 19, 1, 0, 1000453, 1000453, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:37');
INSERT INTO `userscoresnapshotledger` VALUES (455, 'test01', 19, 1, 0, 1000448, 1000448, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:38');
INSERT INTO `userscoresnapshotledger` VALUES (456, 'test01', 19, 1, 0, 1001318, 1001318, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:38');
INSERT INTO `userscoresnapshotledger` VALUES (457, 'test01', 19, 1, 0, 1001618, 1001618, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:38');
INSERT INTO `userscoresnapshotledger` VALUES (458, 'test01', 19, 1, 0, 1001743, 1001743, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:38');
INSERT INTO `userscoresnapshotledger` VALUES (459, 'test01', 19, 1, 0, 1001833, 1001833, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:38');
INSERT INTO `userscoresnapshotledger` VALUES (460, 'test01', 19, 1, 0, 1001828, 1001828, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:38');
INSERT INTO `userscoresnapshotledger` VALUES (461, 'test01', 19, 1, 0, 1001823, 1001823, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:38');
INSERT INTO `userscoresnapshotledger` VALUES (462, 'test01', 19, 1, 0, 1002663, 1002663, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:39');
INSERT INTO `userscoresnapshotledger` VALUES (463, 'test01', 19, 1, 0, 1002658, 1002658, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:39');
INSERT INTO `userscoresnapshotledger` VALUES (464, 'test01', 19, 1, 0, 1002653, 1002653, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:40');
INSERT INTO `userscoresnapshotledger` VALUES (465, 'test01', 19, 1, 0, 1002778, 1002778, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:40');
INSERT INTO `userscoresnapshotledger` VALUES (466, 'test01', 19, 1, 0, 1002773, 1002773, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:40');
INSERT INTO `userscoresnapshotledger` VALUES (467, 'test01', 19, 1, 0, 1002768, 1002768, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:41');
INSERT INTO `userscoresnapshotledger` VALUES (468, 'test01', 19, 1, 0, 1002813, 1002813, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:41');
INSERT INTO `userscoresnapshotledger` VALUES (469, 'test01', 19, 1, 0, 1002808, 1002808, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:41');
INSERT INTO `userscoresnapshotledger` VALUES (470, 'test01', 19, 1, 0, 1002823, 1002823, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:41');
INSERT INTO `userscoresnapshotledger` VALUES (471, 'test01', 19, 1, 0, 1003323, 1003323, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:41');
INSERT INTO `userscoresnapshotledger` VALUES (472, 'test01', 19, 1, 0, 1003318, 1003318, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:41');
INSERT INTO `userscoresnapshotledger` VALUES (473, 'test01', 19, 1, 0, 1003333, 1003333, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:41');
INSERT INTO `userscoresnapshotledger` VALUES (474, 'test01', 19, 1, 0, 1003328, 1003328, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:41');
INSERT INTO `userscoresnapshotledger` VALUES (475, 'test01', 19, 1, 0, 1003323, 1003323, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:41');
INSERT INTO `userscoresnapshotledger` VALUES (476, 'test01', 19, 1, 0, 1003623, 1003623, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:42');
INSERT INTO `userscoresnapshotledger` VALUES (477, 'test01', 19, 1, 0, 1003618, 1003618, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:42');
INSERT INTO `userscoresnapshotledger` VALUES (478, 'test01', 19, 1, 0, 1006618, 1006618, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:42');
INSERT INTO `userscoresnapshotledger` VALUES (479, 'test01', 19, 1, 0, 1006743, 1006743, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:42');
INSERT INTO `userscoresnapshotledger` VALUES (480, 'test01', 19, 1, 0, 1006738, 1006738, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:42');
INSERT INTO `userscoresnapshotledger` VALUES (481, 'test01', 19, 1, 0, 1006783, 1006783, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:42');
INSERT INTO `userscoresnapshotledger` VALUES (482, 'test01', 19, 1, 0, 1006778, 1006778, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:42');
INSERT INTO `userscoresnapshotledger` VALUES (483, 'test01', 19, 1, 0, 1006788, 1006788, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:42');
INSERT INTO `userscoresnapshotledger` VALUES (484, 'test01', 19, 1, 0, 1006783, 1006783, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:42');
INSERT INTO `userscoresnapshotledger` VALUES (485, 'test01', 19, 1, 0, 1006778, 1006778, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:43');
INSERT INTO `userscoresnapshotledger` VALUES (486, 'test01', 19, 1, 0, 1006773, 1006773, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:43');
INSERT INTO `userscoresnapshotledger` VALUES (487, 'test01', 19, 1, 0, 1006798, 1006798, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:43');
INSERT INTO `userscoresnapshotledger` VALUES (488, 'test01', 19, 1, 0, 1006793, 1006793, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:43');
INSERT INTO `userscoresnapshotledger` VALUES (489, 'test01', 19, 1, 0, 1006868, 1006868, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:43');
INSERT INTO `userscoresnapshotledger` VALUES (490, 'test01', 19, 1, 0, 1006863, 1006863, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:43');
INSERT INTO `userscoresnapshotledger` VALUES (491, 'test01', 19, 1, 0, 1006858, 1006858, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:43');
INSERT INTO `userscoresnapshotledger` VALUES (492, 'test01', 19, 1, 0, 1006903, 1006903, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:44');
INSERT INTO `userscoresnapshotledger` VALUES (493, 'test01', 19, 1, 0, 1006898, 1006898, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:44');
INSERT INTO `userscoresnapshotledger` VALUES (494, 'test01', 19, 1, 0, 1006893, 1006893, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:44');
INSERT INTO `userscoresnapshotledger` VALUES (495, 'test01', 19, 1, 0, 1006918, 1006918, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:44');
INSERT INTO `userscoresnapshotledger` VALUES (496, 'test01', 19, 1, 0, 1006913, 1006913, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:44');
INSERT INTO `userscoresnapshotledger` VALUES (497, 'test01', 19, 1, 0, 1006988, 1006988, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:44');
INSERT INTO `userscoresnapshotledger` VALUES (498, 'test01', 19, 1, 0, 1006983, 1006983, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:44');
INSERT INTO `userscoresnapshotledger` VALUES (499, 'test01', 19, 1, 0, 1007043, 1007043, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:45');
INSERT INTO `userscoresnapshotledger` VALUES (500, 'test01', 19, 1, 0, 1007038, 1007038, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:45');
INSERT INTO `userscoresnapshotledger` VALUES (501, 'test01', 19, 1, 0, 1007033, 1007033, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:45');
INSERT INTO `userscoresnapshotledger` VALUES (502, 'test01', 19, 1, 0, 1007068, 1007068, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:45');
INSERT INTO `userscoresnapshotledger` VALUES (503, 'test01', 19, 1, 0, 1007063, 1007063, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:45');
INSERT INTO `userscoresnapshotledger` VALUES (504, 'test01', 19, 1, 0, 1007098, 1007098, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:46');
INSERT INTO `userscoresnapshotledger` VALUES (505, 'test01', 19, 1, 0, 1007108, 1007108, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:46');
INSERT INTO `userscoresnapshotledger` VALUES (506, 'test01', 19, 1, 0, 1007103, 1007103, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:46');
INSERT INTO `userscoresnapshotledger` VALUES (507, 'test01', 19, 1, 0, 1007973, 1007973, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:46');
INSERT INTO `userscoresnapshotledger` VALUES (508, 'test01', 19, 1, 0, 1008098, 1008098, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:46');
INSERT INTO `userscoresnapshotledger` VALUES (509, 'test01', 19, 1, 0, 1008093, 1008093, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:47');
INSERT INTO `userscoresnapshotledger` VALUES (510, 'test01', 19, 1, 0, 1008088, 1008088, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:47');
INSERT INTO `userscoresnapshotledger` VALUES (511, 'test01', 19, 1, 0, 1008588, 1008588, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:47');
INSERT INTO `userscoresnapshotledger` VALUES (512, 'test01', 19, 1, 0, 1008583, 1008583, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:47');
INSERT INTO `userscoresnapshotledger` VALUES (513, 'test01', 19, 1, 0, 1008658, 1008658, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:47');
INSERT INTO `userscoresnapshotledger` VALUES (514, 'test01', 19, 1, 0, 1008858, 1008858, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:47');
INSERT INTO `userscoresnapshotledger` VALUES (515, 'test01', 19, 1, 0, 1008853, 1008853, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:48');
INSERT INTO `userscoresnapshotledger` VALUES (516, 'test01', 19, 1, 0, 1008848, 1008848, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:48');
INSERT INTO `userscoresnapshotledger` VALUES (517, 'test01', 19, 1, 0, 1008863, 1008863, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:49');
INSERT INTO `userscoresnapshotledger` VALUES (518, 'test01', 19, 1, 0, 1008913, 1008913, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:49');
INSERT INTO `userscoresnapshotledger` VALUES (519, 'test01', 19, 1, 0, 1009038, 1009038, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:49');
INSERT INTO `userscoresnapshotledger` VALUES (520, 'test01', 19, 1, 0, 1009033, 1009033, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:49');
INSERT INTO `userscoresnapshotledger` VALUES (521, 'test01', 19, 1, 0, 1009028, 1009028, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:49');
INSERT INTO `userscoresnapshotledger` VALUES (522, 'test01', 19, 1, 0, 1009063, 1009063, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:49');
INSERT INTO `userscoresnapshotledger` VALUES (523, 'test01', 19, 1, 0, 1009933, 1009933, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:49');
INSERT INTO `userscoresnapshotledger` VALUES (524, 'test01', 19, 1, 0, 1009993, 1009993, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:49');
INSERT INTO `userscoresnapshotledger` VALUES (525, 'test01', 19, 1, 0, 1009988, 1009988, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:49');
INSERT INTO `userscoresnapshotledger` VALUES (526, 'test01', 19, 1, 0, 1010023, 1010023, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:49');
INSERT INTO `userscoresnapshotledger` VALUES (527, 'test01', 19, 1, 0, 1010018, 1010018, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:49');
INSERT INTO `userscoresnapshotledger` VALUES (528, 'test01', 19, 1, 0, 1010013, 1010013, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:50');
INSERT INTO `userscoresnapshotledger` VALUES (529, 'test01', 19, 1, 0, 1010023, 1010023, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:50');
INSERT INTO `userscoresnapshotledger` VALUES (530, 'test01', 19, 1, 0, 1010073, 1010073, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:50');
INSERT INTO `userscoresnapshotledger` VALUES (531, 'test01', 19, 1, 0, 1010068, 1010068, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:50');
INSERT INTO `userscoresnapshotledger` VALUES (532, 'test01', 19, 1, 0, 1010368, 1010368, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:50');
INSERT INTO `userscoresnapshotledger` VALUES (533, 'test01', 19, 1, 0, 1010363, 1010363, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:50');
INSERT INTO `userscoresnapshotledger` VALUES (534, 'test01', 19, 1, 0, 1010423, 1010423, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:50');
INSERT INTO `userscoresnapshotledger` VALUES (535, 'test01', 19, 1, 0, 1010458, 1010458, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:51');
INSERT INTO `userscoresnapshotledger` VALUES (536, 'test01', 19, 1, 0, 1010608, 1010608, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:51');
INSERT INTO `userscoresnapshotledger` VALUES (537, 'test01', 19, 1, 0, 1010668, 1010668, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:53');
INSERT INTO `userscoresnapshotledger` VALUES (538, 'test01', 19, 1, 0, 1010703, 1010703, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:53');
INSERT INTO `userscoresnapshotledger` VALUES (539, 'test01', 19, 1, 0, 1010738, 1010738, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:54');
INSERT INTO `userscoresnapshotledger` VALUES (540, 'test01', 19, 1, 0, 1011038, 1011038, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:58:54');
INSERT INTO `userscoresnapshotledger` VALUES (541, 'test01', 19, 1, 0, 1011033, 1011033, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:59:07');
INSERT INTO `userscoresnapshotledger` VALUES (542, 'test01', 19, 1, 0, 1011333, 1011333, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:59:07');
INSERT INTO `userscoresnapshotledger` VALUES (543, 'test01', 19, 1, 1011333, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 22:59:11');
INSERT INTO `userscoresnapshotledger` VALUES (544, 'test01', 0, 2, 1011333, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-26 23:12:23');
INSERT INTO `userscoresnapshotledger` VALUES (545, 'test01', 53, 0, 1011333, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-29 14:02:28');
INSERT INTO `userscoresnapshotledger` VALUES (546, 'test01', 19, 3, 0, 1011333, 1011333, 0, 'SNAPSHOT_SAVE', '2026-06-29 14:03:10');
INSERT INTO `userscoresnapshotledger` VALUES (547, 'test01', 19, 3, 0, 1011328, 1011328, 0, 'SNAPSHOT_SAVE', '2026-06-29 14:03:26');
INSERT INTO `userscoresnapshotledger` VALUES (548, 'test01', 19, 3, 0, 1011323, 1011323, 0, 'SNAPSHOT_SAVE', '2026-06-29 14:03:28');
INSERT INTO `userscoresnapshotledger` VALUES (549, 'test01', 19, 3, 0, 1011318, 1011318, 0, 'SNAPSHOT_SAVE', '2026-06-29 14:03:28');
INSERT INTO `userscoresnapshotledger` VALUES (550, 'test01', 19, 3, 0, 1011313, 1011313, 0, 'SNAPSHOT_SAVE', '2026-06-29 14:03:29');
INSERT INTO `userscoresnapshotledger` VALUES (551, 'test01', 53, 0, 1011313, 0, 0, 1011313, 'SNAPSHOT_RECOVER:GAME_LOST', '2026-06-29 14:03:29');
INSERT INTO `userscoresnapshotledger` VALUES (552, 'test01', 0, 3, 1011313, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-29 14:03:30');
INSERT INTO `userscoresnapshotledger` VALUES (553, 'test01', 0, 2, 1011313, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-29 14:07:06');
INSERT INTO `userscoresnapshotledger` VALUES (554, 'test01', 53, 0, 1011313, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-29 19:02:24');
INSERT INTO `userscoresnapshotledger` VALUES (555, 'test01', 53, 0, 1011313, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-29 19:02:29');
INSERT INTO `userscoresnapshotledger` VALUES (556, 'test01', 53, 0, 1011313, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-29 19:02:35');
INSERT INTO `userscoresnapshotledger` VALUES (557, 'test01', 53, 0, 1011313, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-29 19:03:58');
INSERT INTO `userscoresnapshotledger` VALUES (558, 'test01', 53, 0, 1011313, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-29 19:04:19');
INSERT INTO `userscoresnapshotledger` VALUES (559, 'test01', 14, 6, 0, 1011313, 1011313, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:04:27');
INSERT INTO `userscoresnapshotledger` VALUES (560, 'test01', 14, 6, 0, 1011303, 1011303, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:04:31');
INSERT INTO `userscoresnapshotledger` VALUES (561, 'test01', 14, 6, 1011313, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:04:36');
INSERT INTO `userscoresnapshotledger` VALUES (562, 'test01', 53, 0, 1011313, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-29 19:04:37');
INSERT INTO `userscoresnapshotledger` VALUES (563, 'test01', 53, 0, 1011313, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-29 19:04:43');
INSERT INTO `userscoresnapshotledger` VALUES (564, 'test01', 33, 8, 0, 1011313, 1011313, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:04:49');
INSERT INTO `userscoresnapshotledger` VALUES (565, 'test01', 33, 8, 0, 1011213, 1011213, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:04:51');
INSERT INTO `userscoresnapshotledger` VALUES (566, 'test01', 33, 8, 0, 1011113, 1011113, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:04:52');
INSERT INTO `userscoresnapshotledger` VALUES (567, 'test01', 33, 8, 0, 1011013, 1011013, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:04:52');
INSERT INTO `userscoresnapshotledger` VALUES (568, 'test01', 33, 8, 0, 1010913, 1010913, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:04:53');
INSERT INTO `userscoresnapshotledger` VALUES (569, 'test01', 33, 8, 0, 1010813, 1010813, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:04:53');
INSERT INTO `userscoresnapshotledger` VALUES (570, 'test01', 33, 8, 0, 1010713, 1010713, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:04:53');
INSERT INTO `userscoresnapshotledger` VALUES (571, 'test01', 33, 8, 0, 1010613, 1010613, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:04:54');
INSERT INTO `userscoresnapshotledger` VALUES (572, 'test01', 33, 8, 0, 1010513, 1010513, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:04:54');
INSERT INTO `userscoresnapshotledger` VALUES (573, 'test01', 33, 8, 0, 1010413, 1010413, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:04:54');
INSERT INTO `userscoresnapshotledger` VALUES (574, 'test01', 33, 8, 0, 1010313, 1010313, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:04:55');
INSERT INTO `userscoresnapshotledger` VALUES (575, 'test01', 33, 8, 0, 1010213, 1010213, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:04:55');
INSERT INTO `userscoresnapshotledger` VALUES (576, 'test01', 33, 8, 0, 1010113, 1010113, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:04:55');
INSERT INTO `userscoresnapshotledger` VALUES (577, 'test01', 33, 8, 0, 1010013, 1010013, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:04:55');
INSERT INTO `userscoresnapshotledger` VALUES (578, 'test01', 33, 8, 0, 1009913, 1009913, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:04:56');
INSERT INTO `userscoresnapshotledger` VALUES (579, 'test01', 33, 8, 0, 1009813, 1009813, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:04:56');
INSERT INTO `userscoresnapshotledger` VALUES (580, 'test01', 33, 8, 0, 1009713, 1009713, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:04:56');
INSERT INTO `userscoresnapshotledger` VALUES (581, 'test01', 33, 8, 0, 1009613, 1009613, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:04:56');
INSERT INTO `userscoresnapshotledger` VALUES (582, 'test01', 33, 8, 0, 1009513, 1009513, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:04:57');
INSERT INTO `userscoresnapshotledger` VALUES (583, 'test01', 33, 8, 0, 1009413, 1009413, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:04:57');
INSERT INTO `userscoresnapshotledger` VALUES (584, 'test01', 33, 8, 0, 1009313, 1009313, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:04:57');
INSERT INTO `userscoresnapshotledger` VALUES (585, 'test01', 33, 8, 0, 1009213, 1009213, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:04:57');
INSERT INTO `userscoresnapshotledger` VALUES (586, 'test01', 33, 8, 0, 1009113, 1009113, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:05:09');
INSERT INTO `userscoresnapshotledger` VALUES (587, 'test01', 33, 8, 0, 1009013, 1009013, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:05:10');
INSERT INTO `userscoresnapshotledger` VALUES (588, 'test01', 33, 8, 0, 1008913, 1008913, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:05:10');
INSERT INTO `userscoresnapshotledger` VALUES (589, 'test01', 33, 8, 1008913, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:05:21');
INSERT INTO `userscoresnapshotledger` VALUES (590, 'test01', 33, 8, 1008913, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:05:22');
INSERT INTO `userscoresnapshotledger` VALUES (591, 'test01', 53, 0, 1008913, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-29 19:05:24');
INSERT INTO `userscoresnapshotledger` VALUES (592, 'test01', 44, 9, 0, 1008913, 1008913, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:05:31');
INSERT INTO `userscoresnapshotledger` VALUES (593, 'test01', 44, 9, 0, 1008903, 1008903, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:05:33');
INSERT INTO `userscoresnapshotledger` VALUES (594, 'test01', 44, 9, 0, 1008923, 1008923, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:05:47');
INSERT INTO `userscoresnapshotledger` VALUES (595, 'test01', 44, 9, 1008923, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:05:48');
INSERT INTO `userscoresnapshotledger` VALUES (596, 'test01', 53, 0, 1008923, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-29 19:05:50');
INSERT INTO `userscoresnapshotledger` VALUES (597, 'test01', 29, 11, 0, 1008923, 1008923, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:06:13');
INSERT INTO `userscoresnapshotledger` VALUES (598, 'test01', 29, 11, 0, 1008923, 1008923, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:06:20');
INSERT INTO `userscoresnapshotledger` VALUES (599, 'test01', 29, 11, 0, 1008923, 1008923, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:06:25');
INSERT INTO `userscoresnapshotledger` VALUES (600, 'test01', 29, 11, 1008923, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:06:31');
INSERT INTO `userscoresnapshotledger` VALUES (601, 'test01', 53, 0, 1008923, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-29 19:06:33');
INSERT INTO `userscoresnapshotledger` VALUES (602, 'test01', 10, 12, 0, 1008923, 1008923, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:06:39');
INSERT INTO `userscoresnapshotledger` VALUES (603, 'test01', 10, 12, 0, 1008923, 1008923, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:06:53');
INSERT INTO `userscoresnapshotledger` VALUES (604, 'test01', 10, 12, 1008923, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:06:55');
INSERT INTO `userscoresnapshotledger` VALUES (605, 'test01', 53, 0, 1008923, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-29 19:06:58');
INSERT INTO `userscoresnapshotledger` VALUES (606, 'test01', 29, 14, 0, 1008923, 1008923, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:07:39');
INSERT INTO `userscoresnapshotledger` VALUES (607, 'test01', 29, 14, 0, 1008923, 1008923, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:07:42');
INSERT INTO `userscoresnapshotledger` VALUES (608, 'test01', 29, 14, 0, 1008923, 1008923, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:07:43');
INSERT INTO `userscoresnapshotledger` VALUES (609, 'test01', 29, 14, 0, 1008923, 1008923, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:07:44');
INSERT INTO `userscoresnapshotledger` VALUES (610, 'test01', 29, 14, 1008923, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:07:46');
INSERT INTO `userscoresnapshotledger` VALUES (611, 'test01', 53, 0, 1008923, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-29 19:07:47');
INSERT INTO `userscoresnapshotledger` VALUES (612, 'test01', 47, 15, 0, 1008923, 1008923, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:07:54');
INSERT INTO `userscoresnapshotledger` VALUES (613, 'test01', 47, 15, 0, 1008923, 1008923, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:07:58');
INSERT INTO `userscoresnapshotledger` VALUES (614, 'test01', 47, 15, 0, 1008923, 1008923, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:08:06');
INSERT INTO `userscoresnapshotledger` VALUES (615, 'test01', 47, 15, 0, 1008923, 1008923, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:08:07');
INSERT INTO `userscoresnapshotledger` VALUES (616, 'test01', 47, 15, 1008923, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:08:14');
INSERT INTO `userscoresnapshotledger` VALUES (617, 'test01', 53, 0, 1008923, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-29 19:08:16');
INSERT INTO `userscoresnapshotledger` VALUES (618, 'test01', 2, 16, 0, 1008923, 1008923, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:08:22');
INSERT INTO `userscoresnapshotledger` VALUES (619, 'test01', 2, 16, 1008923, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:08:31');
INSERT INTO `userscoresnapshotledger` VALUES (620, 'test01', 53, 0, 1008923, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-29 19:08:33');
INSERT INTO `userscoresnapshotledger` VALUES (621, 'test01', 15, 17, 0, 1008923, 1008923, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:08:38');
INSERT INTO `userscoresnapshotledger` VALUES (622, 'test01', 15, 17, 0, 1008913, 1008913, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:08:40');
INSERT INTO `userscoresnapshotledger` VALUES (623, 'test01', 15, 17, 1008923, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:08:42');
INSERT INTO `userscoresnapshotledger` VALUES (624, 'test01', 53, 0, 1008923, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-29 19:08:44');
INSERT INTO `userscoresnapshotledger` VALUES (625, 'test01', 53, 0, 1008923, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-29 19:08:50');
INSERT INTO `userscoresnapshotledger` VALUES (626, 'test01', 29, 21, 0, 1008923, 1008923, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:14:38');
INSERT INTO `userscoresnapshotledger` VALUES (627, 'test01', 29, 21, 0, 1008923, 1008923, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:14:52');
INSERT INTO `userscoresnapshotledger` VALUES (628, 'test01', 29, 21, 1008923, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-29 19:15:01');
INSERT INTO `userscoresnapshotledger` VALUES (629, 'test01', 29, 22, 1008923, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-06-30 09:43:37');
INSERT INTO `userscoresnapshotledger` VALUES (630, 'test01', 53, 0, 1008923, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-30 18:18:14');
INSERT INTO `userscoresnapshotledger` VALUES (631, 'test01', 53, 0, 1008923, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-06-30 18:18:27');
INSERT INTO `userscoresnapshotledger` VALUES (632, 'test01', 0, 3, 1008923, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 14:42:23');
INSERT INTO `userscoresnapshotledger` VALUES (633, 'test01', 54, 0, 1008923, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 18:20:11');
INSERT INTO `userscoresnapshotledger` VALUES (634, 'test01', 54, 0, 1008923, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 18:20:53');
INSERT INTO `userscoresnapshotledger` VALUES (635, 'test01', 54, 0, 1008923, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 18:21:26');
INSERT INTO `userscoresnapshotledger` VALUES (636, 'test01', 54, 0, 1008923, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 18:31:14');
INSERT INTO `userscoresnapshotledger` VALUES (637, 'test01', 54, 0, 1008923, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 18:31:18');
INSERT INTO `userscoresnapshotledger` VALUES (638, 'test01', 54, 0, 1008923, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 18:31:26');
INSERT INTO `userscoresnapshotledger` VALUES (639, 'test01', 29, 8, 0, 1008923, 1008923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:31:48');
INSERT INTO `userscoresnapshotledger` VALUES (640, 'test01', 29, 8, 0, 1008923, 1008923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:32:02');
INSERT INTO `userscoresnapshotledger` VALUES (641, 'test01', 29, 8, 1008923, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:32:28');
INSERT INTO `userscoresnapshotledger` VALUES (642, 'test01', 54, 0, 1008923, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 18:32:31');
INSERT INTO `userscoresnapshotledger` VALUES (643, 'test01', 33, 9, 0, 1008923, 1008923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:32:57');
INSERT INTO `userscoresnapshotledger` VALUES (644, 'test01', 33, 9, 0, 1008823, 1008823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:01');
INSERT INTO `userscoresnapshotledger` VALUES (645, 'test01', 33, 9, 0, 1008723, 1008723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:02');
INSERT INTO `userscoresnapshotledger` VALUES (646, 'test01', 33, 9, 0, 1008623, 1008623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:02');
INSERT INTO `userscoresnapshotledger` VALUES (647, 'test01', 33, 9, 0, 1008523, 1008523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:03');
INSERT INTO `userscoresnapshotledger` VALUES (648, 'test01', 33, 9, 0, 1008423, 1008423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:03');
INSERT INTO `userscoresnapshotledger` VALUES (649, 'test01', 33, 9, 0, 1008323, 1008323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:03');
INSERT INTO `userscoresnapshotledger` VALUES (650, 'test01', 33, 9, 0, 1008223, 1008223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:04');
INSERT INTO `userscoresnapshotledger` VALUES (651, 'test01', 33, 9, 0, 1008123, 1008123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:04');
INSERT INTO `userscoresnapshotledger` VALUES (652, 'test01', 33, 9, 0, 1008023, 1008023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:06');
INSERT INTO `userscoresnapshotledger` VALUES (653, 'test01', 33, 9, 0, 1008223, 1008223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:06');
INSERT INTO `userscoresnapshotledger` VALUES (654, 'test01', 33, 9, 0, 1008123, 1008123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:08');
INSERT INTO `userscoresnapshotledger` VALUES (655, 'test01', 33, 9, 0, 1008023, 1008023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:08');
INSERT INTO `userscoresnapshotledger` VALUES (656, 'test01', 33, 9, 0, 1007923, 1007923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:08');
INSERT INTO `userscoresnapshotledger` VALUES (657, 'test01', 33, 9, 0, 1007823, 1007823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:10');
INSERT INTO `userscoresnapshotledger` VALUES (658, 'test01', 33, 9, 0, 1007723, 1007723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:10');
INSERT INTO `userscoresnapshotledger` VALUES (659, 'test01', 33, 9, 0, 1007623, 1007623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:11');
INSERT INTO `userscoresnapshotledger` VALUES (660, 'test01', 33, 9, 0, 1007523, 1007523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:14');
INSERT INTO `userscoresnapshotledger` VALUES (661, 'test01', 33, 9, 0, 1007423, 1007423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:16');
INSERT INTO `userscoresnapshotledger` VALUES (662, 'test01', 33, 9, 0, 1007323, 1007323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:16');
INSERT INTO `userscoresnapshotledger` VALUES (663, 'test01', 33, 9, 0, 1007223, 1007223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:16');
INSERT INTO `userscoresnapshotledger` VALUES (664, 'test01', 33, 9, 0, 1007123, 1007123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:16');
INSERT INTO `userscoresnapshotledger` VALUES (665, 'test01', 33, 9, 0, 1007023, 1007023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:17');
INSERT INTO `userscoresnapshotledger` VALUES (666, 'test01', 33, 9, 0, 1006923, 1006923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:17');
INSERT INTO `userscoresnapshotledger` VALUES (667, 'test01', 33, 9, 0, 1006823, 1006823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:17');
INSERT INTO `userscoresnapshotledger` VALUES (668, 'test01', 33, 9, 0, 1006723, 1006723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:18');
INSERT INTO `userscoresnapshotledger` VALUES (669, 'test01', 33, 9, 0, 1006623, 1006623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:18');
INSERT INTO `userscoresnapshotledger` VALUES (670, 'test01', 33, 9, 0, 1006523, 1006523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:20');
INSERT INTO `userscoresnapshotledger` VALUES (671, 'test01', 33, 9, 0, 1006423, 1006423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:20');
INSERT INTO `userscoresnapshotledger` VALUES (672, 'test01', 33, 9, 0, 1006323, 1006323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:20');
INSERT INTO `userscoresnapshotledger` VALUES (673, 'test01', 33, 9, 0, 1006223, 1006223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:20');
INSERT INTO `userscoresnapshotledger` VALUES (674, 'test01', 33, 9, 0, 1006123, 1006123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:23');
INSERT INTO `userscoresnapshotledger` VALUES (675, 'test01', 33, 9, 0, 1006023, 1006023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:25');
INSERT INTO `userscoresnapshotledger` VALUES (676, 'test01', 33, 9, 0, 1005923, 1005923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:25');
INSERT INTO `userscoresnapshotledger` VALUES (677, 'test01', 33, 9, 0, 1005823, 1005823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:26');
INSERT INTO `userscoresnapshotledger` VALUES (678, 'test01', 33, 9, 0, 1005723, 1005723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:28');
INSERT INTO `userscoresnapshotledger` VALUES (679, 'test01', 33, 9, 0, 1005623, 1005623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:28');
INSERT INTO `userscoresnapshotledger` VALUES (680, 'test01', 33, 9, 0, 1005523, 1005523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:29');
INSERT INTO `userscoresnapshotledger` VALUES (681, 'test01', 33, 9, 0, 1005423, 1005423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:29');
INSERT INTO `userscoresnapshotledger` VALUES (682, 'test01', 33, 9, 0, 1005323, 1005323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:29');
INSERT INTO `userscoresnapshotledger` VALUES (683, 'test01', 33, 9, 0, 1005223, 1005223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:29');
INSERT INTO `userscoresnapshotledger` VALUES (684, 'test01', 33, 9, 0, 1005123, 1005123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:30');
INSERT INTO `userscoresnapshotledger` VALUES (685, 'test01', 33, 9, 0, 1005023, 1005023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:30');
INSERT INTO `userscoresnapshotledger` VALUES (686, 'test01', 33, 9, 0, 1004923, 1004923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:32');
INSERT INTO `userscoresnapshotledger` VALUES (687, 'test01', 33, 9, 0, 1004823, 1004823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:32');
INSERT INTO `userscoresnapshotledger` VALUES (688, 'test01', 33, 9, 0, 1004723, 1004723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:32');
INSERT INTO `userscoresnapshotledger` VALUES (689, 'test01', 33, 9, 0, 1004623, 1004623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:33');
INSERT INTO `userscoresnapshotledger` VALUES (690, 'test01', 33, 9, 0, 1004523, 1004523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:33');
INSERT INTO `userscoresnapshotledger` VALUES (691, 'test01', 33, 9, 0, 1004423, 1004423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:33');
INSERT INTO `userscoresnapshotledger` VALUES (692, 'test01', 33, 9, 0, 1004323, 1004323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:33');
INSERT INTO `userscoresnapshotledger` VALUES (693, 'test01', 33, 9, 0, 1004223, 1004223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:35');
INSERT INTO `userscoresnapshotledger` VALUES (694, 'test01', 33, 9, 0, 1004123, 1004123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:35');
INSERT INTO `userscoresnapshotledger` VALUES (695, 'test01', 33, 9, 0, 1004023, 1004023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:35');
INSERT INTO `userscoresnapshotledger` VALUES (696, 'test01', 33, 9, 0, 1003923, 1003923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:35');
INSERT INTO `userscoresnapshotledger` VALUES (697, 'test01', 33, 9, 0, 1003823, 1003823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:36');
INSERT INTO `userscoresnapshotledger` VALUES (698, 'test01', 33, 9, 0, 1003723, 1003723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:36');
INSERT INTO `userscoresnapshotledger` VALUES (699, 'test01', 33, 9, 0, 1003623, 1003623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:36');
INSERT INTO `userscoresnapshotledger` VALUES (700, 'test01', 33, 9, 0, 1003523, 1003523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:36');
INSERT INTO `userscoresnapshotledger` VALUES (701, 'test01', 33, 9, 0, 1003423, 1003423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:37');
INSERT INTO `userscoresnapshotledger` VALUES (702, 'test01', 33, 9, 0, 1003323, 1003323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:37');
INSERT INTO `userscoresnapshotledger` VALUES (703, 'test01', 33, 9, 0, 1003223, 1003223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:37');
INSERT INTO `userscoresnapshotledger` VALUES (704, 'test01', 33, 9, 0, 1003123, 1003123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:37');
INSERT INTO `userscoresnapshotledger` VALUES (705, 'test01', 33, 9, 0, 1003023, 1003023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:38');
INSERT INTO `userscoresnapshotledger` VALUES (706, 'test01', 33, 9, 0, 1002923, 1002923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:38');
INSERT INTO `userscoresnapshotledger` VALUES (707, 'test01', 33, 9, 0, 1002823, 1002823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:38');
INSERT INTO `userscoresnapshotledger` VALUES (708, 'test01', 33, 9, 0, 1002723, 1002723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:38');
INSERT INTO `userscoresnapshotledger` VALUES (709, 'test01', 33, 9, 0, 1006723, 1006723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:38');
INSERT INTO `userscoresnapshotledger` VALUES (710, 'test01', 33, 9, 0, 1006623, 1006623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:39');
INSERT INTO `userscoresnapshotledger` VALUES (711, 'test01', 33, 9, 0, 1006523, 1006523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:39');
INSERT INTO `userscoresnapshotledger` VALUES (712, 'test01', 33, 9, 0, 1006423, 1006423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:39');
INSERT INTO `userscoresnapshotledger` VALUES (713, 'test01', 33, 9, 0, 1006323, 1006323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:40');
INSERT INTO `userscoresnapshotledger` VALUES (714, 'test01', 33, 9, 0, 1006223, 1006223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:40');
INSERT INTO `userscoresnapshotledger` VALUES (715, 'test01', 33, 9, 0, 1006123, 1006123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:40');
INSERT INTO `userscoresnapshotledger` VALUES (716, 'test01', 33, 9, 0, 1006023, 1006023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:40');
INSERT INTO `userscoresnapshotledger` VALUES (717, 'test01', 33, 9, 0, 1005923, 1005923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:41');
INSERT INTO `userscoresnapshotledger` VALUES (718, 'test01', 33, 9, 0, 1005823, 1005823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:41');
INSERT INTO `userscoresnapshotledger` VALUES (719, 'test01', 33, 9, 0, 1005723, 1005723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:41');
INSERT INTO `userscoresnapshotledger` VALUES (720, 'test01', 33, 9, 0, 1005623, 1005623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:42');
INSERT INTO `userscoresnapshotledger` VALUES (721, 'test01', 33, 9, 0, 1005523, 1005523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:42');
INSERT INTO `userscoresnapshotledger` VALUES (722, 'test01', 33, 9, 0, 1005423, 1005423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:42');
INSERT INTO `userscoresnapshotledger` VALUES (723, 'test01', 33, 9, 0, 1005323, 1005323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:42');
INSERT INTO `userscoresnapshotledger` VALUES (724, 'test01', 33, 9, 0, 1005223, 1005223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:42');
INSERT INTO `userscoresnapshotledger` VALUES (725, 'test01', 33, 9, 0, 1005123, 1005123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:43');
INSERT INTO `userscoresnapshotledger` VALUES (726, 'test01', 33, 9, 0, 1005023, 1005023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:43');
INSERT INTO `userscoresnapshotledger` VALUES (727, 'test01', 33, 9, 0, 1004923, 1004923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:43');
INSERT INTO `userscoresnapshotledger` VALUES (728, 'test01', 33, 9, 0, 1004823, 1004823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:43');
INSERT INTO `userscoresnapshotledger` VALUES (729, 'test01', 33, 9, 0, 1004723, 1004723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:44');
INSERT INTO `userscoresnapshotledger` VALUES (730, 'test01', 33, 9, 0, 1004623, 1004623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:44');
INSERT INTO `userscoresnapshotledger` VALUES (731, 'test01', 33, 9, 0, 1004523, 1004523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:44');
INSERT INTO `userscoresnapshotledger` VALUES (732, 'test01', 33, 9, 0, 1004423, 1004423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:44');
INSERT INTO `userscoresnapshotledger` VALUES (733, 'test01', 33, 9, 0, 1004323, 1004323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:44');
INSERT INTO `userscoresnapshotledger` VALUES (734, 'test01', 33, 9, 0, 1004223, 1004223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:45');
INSERT INTO `userscoresnapshotledger` VALUES (735, 'test01', 33, 9, 0, 1004123, 1004123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:45');
INSERT INTO `userscoresnapshotledger` VALUES (736, 'test01', 33, 9, 0, 1004023, 1004023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:45');
INSERT INTO `userscoresnapshotledger` VALUES (737, 'test01', 33, 9, 0, 1003923, 1003923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:45');
INSERT INTO `userscoresnapshotledger` VALUES (738, 'test01', 33, 9, 0, 1003823, 1003823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:46');
INSERT INTO `userscoresnapshotledger` VALUES (739, 'test01', 33, 9, 0, 1003723, 1003723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:46');
INSERT INTO `userscoresnapshotledger` VALUES (740, 'test01', 33, 9, 0, 1003623, 1003623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:46');
INSERT INTO `userscoresnapshotledger` VALUES (741, 'test01', 33, 9, 0, 1003523, 1003523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:46');
INSERT INTO `userscoresnapshotledger` VALUES (742, 'test01', 33, 9, 0, 1003423, 1003423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:47');
INSERT INTO `userscoresnapshotledger` VALUES (743, 'test01', 33, 9, 0, 1003323, 1003323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:47');
INSERT INTO `userscoresnapshotledger` VALUES (744, 'test01', 33, 9, 0, 1003223, 1003223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:47');
INSERT INTO `userscoresnapshotledger` VALUES (745, 'test01', 33, 9, 0, 1003123, 1003123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:47');
INSERT INTO `userscoresnapshotledger` VALUES (746, 'test01', 33, 9, 0, 1003023, 1003023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:47');
INSERT INTO `userscoresnapshotledger` VALUES (747, 'test01', 33, 9, 0, 1002923, 1002923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:48');
INSERT INTO `userscoresnapshotledger` VALUES (748, 'test01', 33, 9, 0, 1002823, 1002823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:48');
INSERT INTO `userscoresnapshotledger` VALUES (749, 'test01', 33, 9, 0, 1002723, 1002723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:48');
INSERT INTO `userscoresnapshotledger` VALUES (750, 'test01', 33, 9, 0, 1002623, 1002623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:48');
INSERT INTO `userscoresnapshotledger` VALUES (751, 'test01', 33, 9, 0, 1002523, 1002523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:49');
INSERT INTO `userscoresnapshotledger` VALUES (752, 'test01', 33, 9, 0, 1002423, 1002423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:49');
INSERT INTO `userscoresnapshotledger` VALUES (753, 'test01', 33, 9, 0, 1002323, 1002323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:49');
INSERT INTO `userscoresnapshotledger` VALUES (754, 'test01', 33, 9, 0, 1002223, 1002223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:49');
INSERT INTO `userscoresnapshotledger` VALUES (755, 'test01', 33, 9, 0, 1002123, 1002123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:49');
INSERT INTO `userscoresnapshotledger` VALUES (756, 'test01', 33, 9, 0, 1002023, 1002023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:50');
INSERT INTO `userscoresnapshotledger` VALUES (757, 'test01', 33, 9, 0, 1002823, 1002823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:50');
INSERT INTO `userscoresnapshotledger` VALUES (758, 'test01', 33, 9, 0, 1002723, 1002723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:50');
INSERT INTO `userscoresnapshotledger` VALUES (759, 'test01', 33, 9, 0, 1002623, 1002623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:51');
INSERT INTO `userscoresnapshotledger` VALUES (760, 'test01', 33, 9, 0, 1002523, 1002523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:51');
INSERT INTO `userscoresnapshotledger` VALUES (761, 'test01', 33, 9, 0, 1002423, 1002423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:52');
INSERT INTO `userscoresnapshotledger` VALUES (762, 'test01', 33, 9, 0, 1002323, 1002323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:52');
INSERT INTO `userscoresnapshotledger` VALUES (763, 'test01', 33, 9, 0, 1002223, 1002223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:52');
INSERT INTO `userscoresnapshotledger` VALUES (764, 'test01', 33, 9, 0, 1002123, 1002123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:52');
INSERT INTO `userscoresnapshotledger` VALUES (765, 'test01', 33, 9, 0, 1002023, 1002023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:53');
INSERT INTO `userscoresnapshotledger` VALUES (766, 'test01', 33, 9, 0, 1001923, 1001923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:53');
INSERT INTO `userscoresnapshotledger` VALUES (767, 'test01', 33, 9, 0, 1001823, 1001823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:53');
INSERT INTO `userscoresnapshotledger` VALUES (768, 'test01', 33, 9, 0, 1001723, 1001723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:53');
INSERT INTO `userscoresnapshotledger` VALUES (769, 'test01', 33, 9, 0, 1001623, 1001623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:53');
INSERT INTO `userscoresnapshotledger` VALUES (770, 'test01', 33, 9, 0, 1001523, 1001523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:54');
INSERT INTO `userscoresnapshotledger` VALUES (771, 'test01', 33, 9, 0, 1001423, 1001423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:54');
INSERT INTO `userscoresnapshotledger` VALUES (772, 'test01', 33, 9, 0, 1001323, 1001323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:54');
INSERT INTO `userscoresnapshotledger` VALUES (773, 'test01', 33, 9, 0, 1001223, 1001223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:54');
INSERT INTO `userscoresnapshotledger` VALUES (774, 'test01', 33, 9, 0, 1001123, 1001123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:55');
INSERT INTO `userscoresnapshotledger` VALUES (775, 'test01', 33, 9, 0, 1001023, 1001023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:55');
INSERT INTO `userscoresnapshotledger` VALUES (776, 'test01', 33, 9, 0, 1000923, 1000923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:55');
INSERT INTO `userscoresnapshotledger` VALUES (777, 'test01', 33, 9, 0, 1001123, 1001123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:55');
INSERT INTO `userscoresnapshotledger` VALUES (778, 'test01', 33, 9, 0, 1001023, 1001023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:55');
INSERT INTO `userscoresnapshotledger` VALUES (779, 'test01', 33, 9, 0, 1000923, 1000923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:56');
INSERT INTO `userscoresnapshotledger` VALUES (780, 'test01', 33, 9, 0, 1000823, 1000823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:56');
INSERT INTO `userscoresnapshotledger` VALUES (781, 'test01', 33, 9, 0, 1000723, 1000723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:56');
INSERT INTO `userscoresnapshotledger` VALUES (782, 'test01', 33, 9, 0, 1000923, 1000923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:56');
INSERT INTO `userscoresnapshotledger` VALUES (783, 'test01', 33, 9, 0, 1000823, 1000823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:56');
INSERT INTO `userscoresnapshotledger` VALUES (784, 'test01', 33, 9, 0, 1000723, 1000723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:56');
INSERT INTO `userscoresnapshotledger` VALUES (785, 'test01', 33, 9, 0, 1000623, 1000623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:57');
INSERT INTO `userscoresnapshotledger` VALUES (786, 'test01', 33, 9, 0, 1000523, 1000523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:57');
INSERT INTO `userscoresnapshotledger` VALUES (787, 'test01', 33, 9, 0, 1000423, 1000423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:57');
INSERT INTO `userscoresnapshotledger` VALUES (788, 'test01', 33, 9, 0, 1000323, 1000323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:57');
INSERT INTO `userscoresnapshotledger` VALUES (789, 'test01', 33, 9, 0, 1000223, 1000223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:58');
INSERT INTO `userscoresnapshotledger` VALUES (790, 'test01', 33, 9, 0, 1000123, 1000123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:58');
INSERT INTO `userscoresnapshotledger` VALUES (791, 'test01', 33, 9, 0, 1000023, 1000023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:58');
INSERT INTO `userscoresnapshotledger` VALUES (792, 'test01', 33, 9, 0, 999923, 999923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:58');
INSERT INTO `userscoresnapshotledger` VALUES (793, 'test01', 33, 9, 0, 999823, 999823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:58');
INSERT INTO `userscoresnapshotledger` VALUES (794, 'test01', 33, 9, 0, 999723, 999723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:59');
INSERT INTO `userscoresnapshotledger` VALUES (795, 'test01', 33, 9, 0, 999623, 999623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:59');
INSERT INTO `userscoresnapshotledger` VALUES (796, 'test01', 33, 9, 0, 999523, 999523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:59');
INSERT INTO `userscoresnapshotledger` VALUES (797, 'test01', 33, 9, 0, 999423, 999423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:33:59');
INSERT INTO `userscoresnapshotledger` VALUES (798, 'test01', 33, 9, 0, 999323, 999323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:00');
INSERT INTO `userscoresnapshotledger` VALUES (799, 'test01', 33, 9, 0, 999223, 999223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:00');
INSERT INTO `userscoresnapshotledger` VALUES (800, 'test01', 33, 9, 0, 999123, 999123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:00');
INSERT INTO `userscoresnapshotledger` VALUES (801, 'test01', 33, 9, 0, 999023, 999023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:00');
INSERT INTO `userscoresnapshotledger` VALUES (802, 'test01', 33, 9, 0, 998923, 998923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:00');
INSERT INTO `userscoresnapshotledger` VALUES (803, 'test01', 33, 9, 0, 998823, 998823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:01');
INSERT INTO `userscoresnapshotledger` VALUES (804, 'test01', 33, 9, 0, 998723, 998723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:01');
INSERT INTO `userscoresnapshotledger` VALUES (805, 'test01', 33, 9, 0, 998623, 998623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:01');
INSERT INTO `userscoresnapshotledger` VALUES (806, 'test01', 33, 9, 0, 998523, 998523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:01');
INSERT INTO `userscoresnapshotledger` VALUES (807, 'test01', 33, 9, 0, 998823, 998823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:01');
INSERT INTO `userscoresnapshotledger` VALUES (808, 'test01', 33, 9, 0, 998723, 998723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:02');
INSERT INTO `userscoresnapshotledger` VALUES (809, 'test01', 33, 9, 0, 998623, 998623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:02');
INSERT INTO `userscoresnapshotledger` VALUES (810, 'test01', 33, 9, 0, 998523, 998523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:02');
INSERT INTO `userscoresnapshotledger` VALUES (811, 'test01', 33, 9, 0, 998423, 998423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:02');
INSERT INTO `userscoresnapshotledger` VALUES (812, 'test01', 33, 9, 0, 998323, 998323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:03');
INSERT INTO `userscoresnapshotledger` VALUES (813, 'test01', 33, 9, 0, 998223, 998223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:03');
INSERT INTO `userscoresnapshotledger` VALUES (814, 'test01', 33, 9, 0, 998123, 998123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:03');
INSERT INTO `userscoresnapshotledger` VALUES (815, 'test01', 33, 9, 0, 998023, 998023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:03');
INSERT INTO `userscoresnapshotledger` VALUES (816, 'test01', 33, 9, 0, 997923, 997923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:03');
INSERT INTO `userscoresnapshotledger` VALUES (817, 'test01', 33, 9, 0, 997823, 997823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:04');
INSERT INTO `userscoresnapshotledger` VALUES (818, 'test01', 33, 9, 0, 998123, 998123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:04');
INSERT INTO `userscoresnapshotledger` VALUES (819, 'test01', 33, 9, 0, 998023, 998023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:04');
INSERT INTO `userscoresnapshotledger` VALUES (820, 'test01', 33, 9, 0, 997923, 997923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:04');
INSERT INTO `userscoresnapshotledger` VALUES (821, 'test01', 33, 9, 0, 997823, 997823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:05');
INSERT INTO `userscoresnapshotledger` VALUES (822, 'test01', 33, 9, 0, 997723, 997723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:05');
INSERT INTO `userscoresnapshotledger` VALUES (823, 'test01', 33, 9, 0, 997623, 997623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:05');
INSERT INTO `userscoresnapshotledger` VALUES (824, 'test01', 33, 9, 0, 997523, 997523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:05');
INSERT INTO `userscoresnapshotledger` VALUES (825, 'test01', 33, 9, 0, 997823, 997823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:05');
INSERT INTO `userscoresnapshotledger` VALUES (826, 'test01', 33, 9, 0, 997723, 997723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:05');
INSERT INTO `userscoresnapshotledger` VALUES (827, 'test01', 33, 9, 0, 997623, 997623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:06');
INSERT INTO `userscoresnapshotledger` VALUES (828, 'test01', 33, 9, 0, 997523, 997523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:06');
INSERT INTO `userscoresnapshotledger` VALUES (829, 'test01', 33, 9, 0, 997423, 997423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:06');
INSERT INTO `userscoresnapshotledger` VALUES (830, 'test01', 33, 9, 0, 997323, 997323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:06');
INSERT INTO `userscoresnapshotledger` VALUES (831, 'test01', 33, 9, 0, 997223, 997223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:07');
INSERT INTO `userscoresnapshotledger` VALUES (832, 'test01', 33, 9, 0, 997123, 997123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:07');
INSERT INTO `userscoresnapshotledger` VALUES (833, 'test01', 33, 9, 0, 997023, 997023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:07');
INSERT INTO `userscoresnapshotledger` VALUES (834, 'test01', 33, 9, 0, 996923, 996923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:07');
INSERT INTO `userscoresnapshotledger` VALUES (835, 'test01', 33, 9, 0, 996823, 996823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:07');
INSERT INTO `userscoresnapshotledger` VALUES (836, 'test01', 33, 9, 0, 996723, 996723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:08');
INSERT INTO `userscoresnapshotledger` VALUES (837, 'test01', 33, 9, 0, 996623, 996623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:08');
INSERT INTO `userscoresnapshotledger` VALUES (838, 'test01', 33, 9, 0, 996523, 996523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:08');
INSERT INTO `userscoresnapshotledger` VALUES (839, 'test01', 33, 9, 0, 996423, 996423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:08');
INSERT INTO `userscoresnapshotledger` VALUES (840, 'test01', 33, 9, 0, 996323, 996323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:09');
INSERT INTO `userscoresnapshotledger` VALUES (841, 'test01', 33, 9, 0, 996223, 996223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:09');
INSERT INTO `userscoresnapshotledger` VALUES (842, 'test01', 33, 9, 0, 996123, 996123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:09');
INSERT INTO `userscoresnapshotledger` VALUES (843, 'test01', 33, 9, 0, 996023, 996023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:10');
INSERT INTO `userscoresnapshotledger` VALUES (844, 'test01', 33, 9, 0, 995923, 995923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:10');
INSERT INTO `userscoresnapshotledger` VALUES (845, 'test01', 33, 9, 0, 995823, 995823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:11');
INSERT INTO `userscoresnapshotledger` VALUES (846, 'test01', 33, 9, 0, 995723, 995723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:11');
INSERT INTO `userscoresnapshotledger` VALUES (847, 'test01', 33, 9, 0, 995623, 995623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:11');
INSERT INTO `userscoresnapshotledger` VALUES (848, 'test01', 33, 9, 0, 995523, 995523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:11');
INSERT INTO `userscoresnapshotledger` VALUES (849, 'test01', 33, 9, 0, 995423, 995423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:12');
INSERT INTO `userscoresnapshotledger` VALUES (850, 'test01', 33, 9, 0, 995323, 995323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:12');
INSERT INTO `userscoresnapshotledger` VALUES (851, 'test01', 33, 9, 0, 995223, 995223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:12');
INSERT INTO `userscoresnapshotledger` VALUES (852, 'test01', 33, 9, 0, 995123, 995123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:13');
INSERT INTO `userscoresnapshotledger` VALUES (853, 'test01', 33, 9, 0, 995023, 995023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:13');
INSERT INTO `userscoresnapshotledger` VALUES (854, 'test01', 33, 9, 0, 994923, 994923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:13');
INSERT INTO `userscoresnapshotledger` VALUES (855, 'test01', 33, 9, 0, 994823, 994823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:13');
INSERT INTO `userscoresnapshotledger` VALUES (856, 'test01', 33, 9, 0, 994723, 994723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:14');
INSERT INTO `userscoresnapshotledger` VALUES (857, 'test01', 33, 9, 0, 994623, 994623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:14');
INSERT INTO `userscoresnapshotledger` VALUES (858, 'test01', 33, 9, 0, 994523, 994523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:14');
INSERT INTO `userscoresnapshotledger` VALUES (859, 'test01', 33, 9, 0, 994423, 994423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:14');
INSERT INTO `userscoresnapshotledger` VALUES (860, 'test01', 33, 9, 0, 994323, 994323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:15');
INSERT INTO `userscoresnapshotledger` VALUES (861, 'test01', 33, 9, 0, 994223, 994223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:15');
INSERT INTO `userscoresnapshotledger` VALUES (862, 'test01', 33, 9, 0, 994123, 994123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:15');
INSERT INTO `userscoresnapshotledger` VALUES (863, 'test01', 33, 9, 0, 994023, 994023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:15');
INSERT INTO `userscoresnapshotledger` VALUES (864, 'test01', 33, 9, 0, 993923, 993923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:15');
INSERT INTO `userscoresnapshotledger` VALUES (865, 'test01', 33, 9, 0, 993823, 993823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:16');
INSERT INTO `userscoresnapshotledger` VALUES (866, 'test01', 33, 9, 0, 993723, 993723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:16');
INSERT INTO `userscoresnapshotledger` VALUES (867, 'test01', 33, 9, 0, 996723, 996723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:16');
INSERT INTO `userscoresnapshotledger` VALUES (868, 'test01', 33, 9, 0, 996623, 996623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:17');
INSERT INTO `userscoresnapshotledger` VALUES (869, 'test01', 33, 9, 0, 996523, 996523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:25');
INSERT INTO `userscoresnapshotledger` VALUES (870, 'test01', 33, 9, 0, 996423, 996423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:25');
INSERT INTO `userscoresnapshotledger` VALUES (871, 'test01', 33, 9, 0, 996323, 996323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:25');
INSERT INTO `userscoresnapshotledger` VALUES (872, 'test01', 33, 9, 0, 996223, 996223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:29');
INSERT INTO `userscoresnapshotledger` VALUES (873, 'test01', 33, 9, 0, 996123, 996123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:29');
INSERT INTO `userscoresnapshotledger` VALUES (874, 'test01', 33, 9, 0, 996023, 996023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:29');
INSERT INTO `userscoresnapshotledger` VALUES (875, 'test01', 33, 9, 0, 995923, 995923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:30');
INSERT INTO `userscoresnapshotledger` VALUES (876, 'test01', 33, 9, 0, 995823, 995823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:30');
INSERT INTO `userscoresnapshotledger` VALUES (877, 'test01', 33, 9, 0, 995723, 995723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:30');
INSERT INTO `userscoresnapshotledger` VALUES (878, 'test01', 33, 9, 0, 995623, 995623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:30');
INSERT INTO `userscoresnapshotledger` VALUES (879, 'test01', 33, 9, 0, 995523, 995523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:30');
INSERT INTO `userscoresnapshotledger` VALUES (880, 'test01', 33, 9, 0, 995423, 995423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:30');
INSERT INTO `userscoresnapshotledger` VALUES (881, 'test01', 33, 9, 0, 995323, 995323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:30');
INSERT INTO `userscoresnapshotledger` VALUES (882, 'test01', 33, 9, 0, 995223, 995223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:30');
INSERT INTO `userscoresnapshotledger` VALUES (883, 'test01', 33, 9, 0, 995123, 995123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:30');
INSERT INTO `userscoresnapshotledger` VALUES (884, 'test01', 33, 9, 0, 995023, 995023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:30');
INSERT INTO `userscoresnapshotledger` VALUES (885, 'test01', 33, 9, 0, 994923, 994923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:31');
INSERT INTO `userscoresnapshotledger` VALUES (886, 'test01', 33, 9, 0, 994823, 994823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:31');
INSERT INTO `userscoresnapshotledger` VALUES (887, 'test01', 33, 9, 0, 994723, 994723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:31');
INSERT INTO `userscoresnapshotledger` VALUES (888, 'test01', 33, 9, 0, 994623, 994623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:31');
INSERT INTO `userscoresnapshotledger` VALUES (889, 'test01', 33, 9, 0, 994523, 994523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:31');
INSERT INTO `userscoresnapshotledger` VALUES (890, 'test01', 33, 9, 0, 994423, 994423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:31');
INSERT INTO `userscoresnapshotledger` VALUES (891, 'test01', 33, 9, 0, 994323, 994323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:31');
INSERT INTO `userscoresnapshotledger` VALUES (892, 'test01', 33, 9, 0, 994223, 994223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:31');
INSERT INTO `userscoresnapshotledger` VALUES (893, 'test01', 33, 9, 0, 994123, 994123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:31');
INSERT INTO `userscoresnapshotledger` VALUES (894, 'test01', 33, 9, 0, 994023, 994023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:31');
INSERT INTO `userscoresnapshotledger` VALUES (895, 'test01', 33, 9, 0, 993923, 993923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:31');
INSERT INTO `userscoresnapshotledger` VALUES (896, 'test01', 33, 9, 0, 993823, 993823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:32');
INSERT INTO `userscoresnapshotledger` VALUES (897, 'test01', 33, 9, 0, 993723, 993723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:32');
INSERT INTO `userscoresnapshotledger` VALUES (898, 'test01', 33, 9, 0, 993623, 993623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:32');
INSERT INTO `userscoresnapshotledger` VALUES (899, 'test01', 33, 9, 0, 993923, 993923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:32');
INSERT INTO `userscoresnapshotledger` VALUES (900, 'test01', 33, 9, 0, 993823, 993823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:32');
INSERT INTO `userscoresnapshotledger` VALUES (901, 'test01', 33, 9, 0, 993723, 993723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:32');
INSERT INTO `userscoresnapshotledger` VALUES (902, 'test01', 33, 9, 0, 993623, 993623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:32');
INSERT INTO `userscoresnapshotledger` VALUES (903, 'test01', 33, 9, 0, 993523, 993523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:32');
INSERT INTO `userscoresnapshotledger` VALUES (904, 'test01', 33, 9, 0, 993423, 993423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:32');
INSERT INTO `userscoresnapshotledger` VALUES (905, 'test01', 33, 9, 0, 993323, 993323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:32');
INSERT INTO `userscoresnapshotledger` VALUES (906, 'test01', 33, 9, 0, 993223, 993223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:32');
INSERT INTO `userscoresnapshotledger` VALUES (907, 'test01', 33, 9, 0, 993123, 993123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:33');
INSERT INTO `userscoresnapshotledger` VALUES (908, 'test01', 33, 9, 0, 993923, 993923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:33');
INSERT INTO `userscoresnapshotledger` VALUES (909, 'test01', 33, 9, 0, 993823, 993823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:33');
INSERT INTO `userscoresnapshotledger` VALUES (910, 'test01', 33, 9, 0, 994623, 994623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:33');
INSERT INTO `userscoresnapshotledger` VALUES (911, 'test01', 33, 9, 0, 994923, 994923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:33');
INSERT INTO `userscoresnapshotledger` VALUES (912, 'test01', 33, 9, 0, 994823, 994823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:33');
INSERT INTO `userscoresnapshotledger` VALUES (913, 'test01', 33, 9, 0, 994723, 994723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:33');
INSERT INTO `userscoresnapshotledger` VALUES (914, 'test01', 33, 9, 0, 994623, 994623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:33');
INSERT INTO `userscoresnapshotledger` VALUES (915, 'test01', 33, 9, 0, 994523, 994523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:33');
INSERT INTO `userscoresnapshotledger` VALUES (916, 'test01', 33, 9, 0, 994423, 994423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:33');
INSERT INTO `userscoresnapshotledger` VALUES (917, 'test01', 33, 9, 0, 994323, 994323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:33');
INSERT INTO `userscoresnapshotledger` VALUES (918, 'test01', 33, 9, 0, 994223, 994223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:34');
INSERT INTO `userscoresnapshotledger` VALUES (919, 'test01', 33, 9, 0, 994123, 994123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:34');
INSERT INTO `userscoresnapshotledger` VALUES (920, 'test01', 33, 9, 0, 994023, 994023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:34');
INSERT INTO `userscoresnapshotledger` VALUES (921, 'test01', 33, 9, 0, 993923, 993923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:34');
INSERT INTO `userscoresnapshotledger` VALUES (922, 'test01', 33, 9, 0, 993823, 993823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:34');
INSERT INTO `userscoresnapshotledger` VALUES (923, 'test01', 33, 9, 0, 993723, 993723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:34');
INSERT INTO `userscoresnapshotledger` VALUES (924, 'test01', 33, 9, 0, 993623, 993623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:34');
INSERT INTO `userscoresnapshotledger` VALUES (925, 'test01', 33, 9, 0, 993523, 993523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:34');
INSERT INTO `userscoresnapshotledger` VALUES (926, 'test01', 33, 9, 0, 993423, 993423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:34');
INSERT INTO `userscoresnapshotledger` VALUES (927, 'test01', 33, 9, 0, 993323, 993323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:34');
INSERT INTO `userscoresnapshotledger` VALUES (928, 'test01', 33, 9, 0, 993223, 993223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:34');
INSERT INTO `userscoresnapshotledger` VALUES (929, 'test01', 33, 9, 0, 993123, 993123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:35');
INSERT INTO `userscoresnapshotledger` VALUES (930, 'test01', 33, 9, 0, 993023, 993023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:35');
INSERT INTO `userscoresnapshotledger` VALUES (931, 'test01', 33, 9, 0, 992923, 992923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:35');
INSERT INTO `userscoresnapshotledger` VALUES (932, 'test01', 33, 9, 0, 992823, 992823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:35');
INSERT INTO `userscoresnapshotledger` VALUES (933, 'test01', 33, 9, 0, 992723, 992723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:35');
INSERT INTO `userscoresnapshotledger` VALUES (934, 'test01', 33, 9, 0, 992623, 992623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:35');
INSERT INTO `userscoresnapshotledger` VALUES (935, 'test01', 33, 9, 0, 992523, 992523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:35');
INSERT INTO `userscoresnapshotledger` VALUES (936, 'test01', 33, 9, 0, 992423, 992423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:35');
INSERT INTO `userscoresnapshotledger` VALUES (937, 'test01', 33, 9, 0, 992323, 992323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:35');
INSERT INTO `userscoresnapshotledger` VALUES (938, 'test01', 33, 9, 0, 992223, 992223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:35');
INSERT INTO `userscoresnapshotledger` VALUES (939, 'test01', 33, 9, 0, 992123, 992123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:36');
INSERT INTO `userscoresnapshotledger` VALUES (940, 'test01', 33, 9, 0, 992023, 992023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:36');
INSERT INTO `userscoresnapshotledger` VALUES (941, 'test01', 33, 9, 0, 991923, 991923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:36');
INSERT INTO `userscoresnapshotledger` VALUES (942, 'test01', 33, 9, 0, 991823, 991823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:36');
INSERT INTO `userscoresnapshotledger` VALUES (943, 'test01', 33, 9, 0, 991723, 991723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:36');
INSERT INTO `userscoresnapshotledger` VALUES (944, 'test01', 33, 9, 0, 992023, 992023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:36');
INSERT INTO `userscoresnapshotledger` VALUES (945, 'test01', 33, 9, 0, 991923, 991923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:36');
INSERT INTO `userscoresnapshotledger` VALUES (946, 'test01', 33, 9, 0, 991823, 991823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:36');
INSERT INTO `userscoresnapshotledger` VALUES (947, 'test01', 33, 9, 0, 991723, 991723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:36');
INSERT INTO `userscoresnapshotledger` VALUES (948, 'test01', 33, 9, 0, 991623, 991623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:36');
INSERT INTO `userscoresnapshotledger` VALUES (949, 'test01', 33, 9, 0, 991523, 991523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:37');
INSERT INTO `userscoresnapshotledger` VALUES (950, 'test01', 33, 9, 0, 991423, 991423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:37');
INSERT INTO `userscoresnapshotledger` VALUES (951, 'test01', 33, 9, 0, 991323, 991323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:37');
INSERT INTO `userscoresnapshotledger` VALUES (952, 'test01', 33, 9, 0, 991823, 991823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:37');
INSERT INTO `userscoresnapshotledger` VALUES (953, 'test01', 33, 9, 0, 991723, 991723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:37');
INSERT INTO `userscoresnapshotledger` VALUES (954, 'test01', 33, 9, 0, 991623, 991623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:37');
INSERT INTO `userscoresnapshotledger` VALUES (955, 'test01', 33, 9, 0, 991523, 991523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:37');
INSERT INTO `userscoresnapshotledger` VALUES (956, 'test01', 33, 9, 0, 991423, 991423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:37');
INSERT INTO `userscoresnapshotledger` VALUES (957, 'test01', 33, 9, 0, 991323, 991323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:37');
INSERT INTO `userscoresnapshotledger` VALUES (958, 'test01', 33, 9, 0, 991223, 991223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:37');
INSERT INTO `userscoresnapshotledger` VALUES (959, 'test01', 33, 9, 0, 991123, 991123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:37');
INSERT INTO `userscoresnapshotledger` VALUES (960, 'test01', 33, 9, 0, 991023, 991023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:37');
INSERT INTO `userscoresnapshotledger` VALUES (961, 'test01', 33, 9, 0, 990923, 990923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:38');
INSERT INTO `userscoresnapshotledger` VALUES (962, 'test01', 33, 9, 0, 990823, 990823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:38');
INSERT INTO `userscoresnapshotledger` VALUES (963, 'test01', 33, 9, 0, 990723, 990723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:38');
INSERT INTO `userscoresnapshotledger` VALUES (964, 'test01', 33, 9, 0, 990623, 990623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:38');
INSERT INTO `userscoresnapshotledger` VALUES (965, 'test01', 33, 9, 0, 990523, 990523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:38');
INSERT INTO `userscoresnapshotledger` VALUES (966, 'test01', 33, 9, 0, 990423, 990423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:38');
INSERT INTO `userscoresnapshotledger` VALUES (967, 'test01', 33, 9, 0, 990323, 990323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:38');
INSERT INTO `userscoresnapshotledger` VALUES (968, 'test01', 33, 9, 0, 990223, 990223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:38');
INSERT INTO `userscoresnapshotledger` VALUES (969, 'test01', 33, 9, 0, 990123, 990123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:38');
INSERT INTO `userscoresnapshotledger` VALUES (970, 'test01', 33, 9, 0, 990023, 990023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:39');
INSERT INTO `userscoresnapshotledger` VALUES (971, 'test01', 33, 9, 0, 989923, 989923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:39');
INSERT INTO `userscoresnapshotledger` VALUES (972, 'test01', 33, 9, 0, 989823, 989823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:39');
INSERT INTO `userscoresnapshotledger` VALUES (973, 'test01', 33, 9, 0, 995823, 995823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:39');
INSERT INTO `userscoresnapshotledger` VALUES (974, 'test01', 33, 9, 0, 995723, 995723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:39');
INSERT INTO `userscoresnapshotledger` VALUES (975, 'test01', 33, 9, 0, 995623, 995623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:39');
INSERT INTO `userscoresnapshotledger` VALUES (976, 'test01', 33, 9, 0, 995523, 995523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:39');
INSERT INTO `userscoresnapshotledger` VALUES (977, 'test01', 33, 9, 0, 995423, 995423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:39');
INSERT INTO `userscoresnapshotledger` VALUES (978, 'test01', 33, 9, 0, 995323, 995323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:39');
INSERT INTO `userscoresnapshotledger` VALUES (979, 'test01', 33, 9, 0, 995223, 995223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:39');
INSERT INTO `userscoresnapshotledger` VALUES (980, 'test01', 33, 9, 0, 995123, 995123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:39');
INSERT INTO `userscoresnapshotledger` VALUES (981, 'test01', 33, 9, 0, 995023, 995023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:40');
INSERT INTO `userscoresnapshotledger` VALUES (982, 'test01', 33, 9, 0, 994923, 994923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:40');
INSERT INTO `userscoresnapshotledger` VALUES (983, 'test01', 33, 9, 0, 994823, 994823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:40');
INSERT INTO `userscoresnapshotledger` VALUES (984, 'test01', 33, 9, 0, 994723, 994723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:40');
INSERT INTO `userscoresnapshotledger` VALUES (985, 'test01', 33, 9, 0, 994623, 994623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:40');
INSERT INTO `userscoresnapshotledger` VALUES (986, 'test01', 33, 9, 0, 994523, 994523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:40');
INSERT INTO `userscoresnapshotledger` VALUES (987, 'test01', 33, 9, 0, 994423, 994423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:41');
INSERT INTO `userscoresnapshotledger` VALUES (988, 'test01', 33, 9, 0, 994323, 994323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:41');
INSERT INTO `userscoresnapshotledger` VALUES (989, 'test01', 33, 9, 0, 994223, 994223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:41');
INSERT INTO `userscoresnapshotledger` VALUES (990, 'test01', 33, 9, 0, 994123, 994123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:41');
INSERT INTO `userscoresnapshotledger` VALUES (991, 'test01', 33, 9, 0, 994023, 994023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:41');
INSERT INTO `userscoresnapshotledger` VALUES (992, 'test01', 33, 9, 0, 993923, 993923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:42');
INSERT INTO `userscoresnapshotledger` VALUES (993, 'test01', 33, 9, 0, 993823, 993823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:42');
INSERT INTO `userscoresnapshotledger` VALUES (994, 'test01', 33, 9, 0, 993723, 993723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:42');
INSERT INTO `userscoresnapshotledger` VALUES (995, 'test01', 33, 9, 0, 993623, 993623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:42');
INSERT INTO `userscoresnapshotledger` VALUES (996, 'test01', 33, 9, 0, 993523, 993523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:42');
INSERT INTO `userscoresnapshotledger` VALUES (997, 'test01', 33, 9, 0, 993423, 993423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:42');
INSERT INTO `userscoresnapshotledger` VALUES (998, 'test01', 33, 9, 0, 993323, 993323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:43');
INSERT INTO `userscoresnapshotledger` VALUES (999, 'test01', 33, 9, 0, 993223, 993223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:43');
INSERT INTO `userscoresnapshotledger` VALUES (1000, 'test01', 33, 9, 0, 993123, 993123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:43');
INSERT INTO `userscoresnapshotledger` VALUES (1001, 'test01', 33, 9, 0, 993023, 993023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:43');
INSERT INTO `userscoresnapshotledger` VALUES (1002, 'test01', 33, 9, 0, 992923, 992923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:43');
INSERT INTO `userscoresnapshotledger` VALUES (1003, 'test01', 33, 9, 0, 992823, 992823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:43');
INSERT INTO `userscoresnapshotledger` VALUES (1004, 'test01', 33, 9, 0, 992723, 992723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:43');
INSERT INTO `userscoresnapshotledger` VALUES (1005, 'test01', 33, 9, 0, 992623, 992623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:43');
INSERT INTO `userscoresnapshotledger` VALUES (1006, 'test01', 33, 9, 0, 992523, 992523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:44');
INSERT INTO `userscoresnapshotledger` VALUES (1007, 'test01', 33, 9, 0, 992423, 992423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:44');
INSERT INTO `userscoresnapshotledger` VALUES (1008, 'test01', 33, 9, 0, 992323, 992323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:44');
INSERT INTO `userscoresnapshotledger` VALUES (1009, 'test01', 33, 9, 0, 992223, 992223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:44');
INSERT INTO `userscoresnapshotledger` VALUES (1010, 'test01', 33, 9, 0, 992123, 992123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:44');
INSERT INTO `userscoresnapshotledger` VALUES (1011, 'test01', 33, 9, 0, 992023, 992023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:45');
INSERT INTO `userscoresnapshotledger` VALUES (1012, 'test01', 33, 9, 0, 991923, 991923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:45');
INSERT INTO `userscoresnapshotledger` VALUES (1013, 'test01', 33, 9, 0, 991823, 991823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:45');
INSERT INTO `userscoresnapshotledger` VALUES (1014, 'test01', 33, 9, 0, 991723, 991723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:45');
INSERT INTO `userscoresnapshotledger` VALUES (1015, 'test01', 33, 9, 0, 991623, 991623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:45');
INSERT INTO `userscoresnapshotledger` VALUES (1016, 'test01', 33, 9, 0, 991523, 991523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:45');
INSERT INTO `userscoresnapshotledger` VALUES (1017, 'test01', 33, 9, 0, 991423, 991423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:45');
INSERT INTO `userscoresnapshotledger` VALUES (1018, 'test01', 33, 9, 0, 991323, 991323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:45');
INSERT INTO `userscoresnapshotledger` VALUES (1019, 'test01', 33, 9, 0, 991223, 991223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:45');
INSERT INTO `userscoresnapshotledger` VALUES (1020, 'test01', 33, 9, 0, 991123, 991123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:45');
INSERT INTO `userscoresnapshotledger` VALUES (1021, 'test01', 33, 9, 0, 991023, 991023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:46');
INSERT INTO `userscoresnapshotledger` VALUES (1022, 'test01', 33, 9, 0, 990923, 990923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:46');
INSERT INTO `userscoresnapshotledger` VALUES (1023, 'test01', 33, 9, 0, 990823, 990823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:46');
INSERT INTO `userscoresnapshotledger` VALUES (1024, 'test01', 33, 9, 0, 990723, 990723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:46');
INSERT INTO `userscoresnapshotledger` VALUES (1025, 'test01', 33, 9, 0, 990623, 990623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:47');
INSERT INTO `userscoresnapshotledger` VALUES (1026, 'test01', 33, 9, 0, 990523, 990523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:47');
INSERT INTO `userscoresnapshotledger` VALUES (1027, 'test01', 33, 9, 0, 990423, 990423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:47');
INSERT INTO `userscoresnapshotledger` VALUES (1028, 'test01', 33, 9, 0, 990323, 990323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:47');
INSERT INTO `userscoresnapshotledger` VALUES (1029, 'test01', 33, 9, 0, 990223, 990223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:48');
INSERT INTO `userscoresnapshotledger` VALUES (1030, 'test01', 33, 9, 0, 990123, 990123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:48');
INSERT INTO `userscoresnapshotledger` VALUES (1031, 'test01', 33, 9, 0, 990023, 990023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:48');
INSERT INTO `userscoresnapshotledger` VALUES (1032, 'test01', 33, 9, 0, 989923, 989923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:48');
INSERT INTO `userscoresnapshotledger` VALUES (1033, 'test01', 33, 9, 0, 989823, 989823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:48');
INSERT INTO `userscoresnapshotledger` VALUES (1034, 'test01', 33, 9, 0, 989723, 989723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:48');
INSERT INTO `userscoresnapshotledger` VALUES (1035, 'test01', 33, 9, 0, 989623, 989623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:48');
INSERT INTO `userscoresnapshotledger` VALUES (1036, 'test01', 33, 9, 0, 989523, 989523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:48');
INSERT INTO `userscoresnapshotledger` VALUES (1037, 'test01', 33, 9, 0, 989423, 989423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:48');
INSERT INTO `userscoresnapshotledger` VALUES (1038, 'test01', 33, 9, 0, 989323, 989323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:49');
INSERT INTO `userscoresnapshotledger` VALUES (1039, 'test01', 33, 9, 0, 989223, 989223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:49');
INSERT INTO `userscoresnapshotledger` VALUES (1040, 'test01', 33, 9, 0, 989123, 989123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:49');
INSERT INTO `userscoresnapshotledger` VALUES (1041, 'test01', 33, 9, 0, 989723, 989723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:49');
INSERT INTO `userscoresnapshotledger` VALUES (1042, 'test01', 33, 9, 0, 989623, 989623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:50');
INSERT INTO `userscoresnapshotledger` VALUES (1043, 'test01', 33, 9, 0, 989523, 989523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:50');
INSERT INTO `userscoresnapshotledger` VALUES (1044, 'test01', 33, 9, 0, 989423, 989423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:50');
INSERT INTO `userscoresnapshotledger` VALUES (1045, 'test01', 33, 9, 0, 989323, 989323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:50');
INSERT INTO `userscoresnapshotledger` VALUES (1046, 'test01', 33, 9, 0, 989223, 989223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:50');
INSERT INTO `userscoresnapshotledger` VALUES (1047, 'test01', 33, 9, 0, 989123, 989123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:50');
INSERT INTO `userscoresnapshotledger` VALUES (1048, 'test01', 33, 9, 0, 989023, 989023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:50');
INSERT INTO `userscoresnapshotledger` VALUES (1049, 'test01', 33, 9, 0, 988923, 988923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:50');
INSERT INTO `userscoresnapshotledger` VALUES (1050, 'test01', 33, 9, 0, 988823, 988823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:50');
INSERT INTO `userscoresnapshotledger` VALUES (1051, 'test01', 33, 9, 0, 988723, 988723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:51');
INSERT INTO `userscoresnapshotledger` VALUES (1052, 'test01', 33, 9, 0, 988623, 988623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:51');
INSERT INTO `userscoresnapshotledger` VALUES (1053, 'test01', 33, 9, 0, 988523, 988523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:51');
INSERT INTO `userscoresnapshotledger` VALUES (1054, 'test01', 33, 9, 0, 988423, 988423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:51');
INSERT INTO `userscoresnapshotledger` VALUES (1055, 'test01', 33, 9, 0, 988323, 988323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:51');
INSERT INTO `userscoresnapshotledger` VALUES (1056, 'test01', 33, 9, 0, 988223, 988223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:51');
INSERT INTO `userscoresnapshotledger` VALUES (1057, 'test01', 33, 9, 0, 988123, 988123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:52');
INSERT INTO `userscoresnapshotledger` VALUES (1058, 'test01', 33, 9, 0, 988023, 988023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:52');
INSERT INTO `userscoresnapshotledger` VALUES (1059, 'test01', 33, 9, 0, 987923, 987923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:52');
INSERT INTO `userscoresnapshotledger` VALUES (1060, 'test01', 33, 9, 0, 987823, 987823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:52');
INSERT INTO `userscoresnapshotledger` VALUES (1061, 'test01', 33, 9, 0, 987723, 987723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:52');
INSERT INTO `userscoresnapshotledger` VALUES (1062, 'test01', 33, 9, 0, 987623, 987623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:53');
INSERT INTO `userscoresnapshotledger` VALUES (1063, 'test01', 33, 9, 0, 987523, 987523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:53');
INSERT INTO `userscoresnapshotledger` VALUES (1064, 'test01', 33, 9, 0, 987423, 987423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:53');
INSERT INTO `userscoresnapshotledger` VALUES (1065, 'test01', 33, 9, 0, 987323, 987323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:54');
INSERT INTO `userscoresnapshotledger` VALUES (1066, 'test01', 33, 9, 0, 987223, 987223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:54');
INSERT INTO `userscoresnapshotledger` VALUES (1067, 'test01', 33, 9, 0, 987123, 987123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:54');
INSERT INTO `userscoresnapshotledger` VALUES (1068, 'test01', 33, 9, 0, 987023, 987023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:54');
INSERT INTO `userscoresnapshotledger` VALUES (1069, 'test01', 33, 9, 0, 986923, 986923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:55');
INSERT INTO `userscoresnapshotledger` VALUES (1070, 'test01', 33, 9, 0, 986823, 986823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:55');
INSERT INTO `userscoresnapshotledger` VALUES (1071, 'test01', 33, 9, 0, 986723, 986723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:55');
INSERT INTO `userscoresnapshotledger` VALUES (1072, 'test01', 33, 9, 0, 986623, 986623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:55');
INSERT INTO `userscoresnapshotledger` VALUES (1073, 'test01', 33, 9, 0, 986523, 986523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:55');
INSERT INTO `userscoresnapshotledger` VALUES (1074, 'test01', 33, 9, 0, 986423, 986423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:55');
INSERT INTO `userscoresnapshotledger` VALUES (1075, 'test01', 33, 9, 0, 986323, 986323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:56');
INSERT INTO `userscoresnapshotledger` VALUES (1076, 'test01', 33, 9, 0, 986223, 986223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:56');
INSERT INTO `userscoresnapshotledger` VALUES (1077, 'test01', 33, 9, 0, 986123, 986123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:56');
INSERT INTO `userscoresnapshotledger` VALUES (1078, 'test01', 33, 9, 0, 986023, 986023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:56');
INSERT INTO `userscoresnapshotledger` VALUES (1079, 'test01', 33, 9, 0, 985923, 985923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:56');
INSERT INTO `userscoresnapshotledger` VALUES (1080, 'test01', 33, 9, 0, 985823, 985823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:57');
INSERT INTO `userscoresnapshotledger` VALUES (1081, 'test01', 33, 9, 0, 985723, 985723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:57');
INSERT INTO `userscoresnapshotledger` VALUES (1082, 'test01', 33, 9, 0, 985623, 985623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:57');
INSERT INTO `userscoresnapshotledger` VALUES (1083, 'test01', 33, 9, 0, 985523, 985523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:57');
INSERT INTO `userscoresnapshotledger` VALUES (1084, 'test01', 33, 9, 0, 985423, 985423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:57');
INSERT INTO `userscoresnapshotledger` VALUES (1085, 'test01', 33, 9, 0, 985323, 985323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:57');
INSERT INTO `userscoresnapshotledger` VALUES (1086, 'test01', 33, 9, 0, 985223, 985223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:57');
INSERT INTO `userscoresnapshotledger` VALUES (1087, 'test01', 33, 9, 0, 985123, 985123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:57');
INSERT INTO `userscoresnapshotledger` VALUES (1088, 'test01', 33, 9, 0, 985023, 985023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:57');
INSERT INTO `userscoresnapshotledger` VALUES (1089, 'test01', 33, 9, 0, 984923, 984923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:57');
INSERT INTO `userscoresnapshotledger` VALUES (1090, 'test01', 33, 9, 0, 984823, 984823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:58');
INSERT INTO `userscoresnapshotledger` VALUES (1091, 'test01', 33, 9, 0, 984723, 984723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:58');
INSERT INTO `userscoresnapshotledger` VALUES (1092, 'test01', 33, 9, 0, 986223, 986223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:58');
INSERT INTO `userscoresnapshotledger` VALUES (1093, 'test01', 33, 9, 0, 986123, 986123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:58');
INSERT INTO `userscoresnapshotledger` VALUES (1094, 'test01', 33, 9, 0, 987923, 987923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:58');
INSERT INTO `userscoresnapshotledger` VALUES (1095, 'test01', 33, 9, 0, 987823, 987823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:58');
INSERT INTO `userscoresnapshotledger` VALUES (1096, 'test01', 33, 9, 0, 987723, 987723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:58');
INSERT INTO `userscoresnapshotledger` VALUES (1097, 'test01', 33, 9, 0, 987623, 987623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:58');
INSERT INTO `userscoresnapshotledger` VALUES (1098, 'test01', 33, 9, 0, 987523, 987523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:58');
INSERT INTO `userscoresnapshotledger` VALUES (1099, 'test01', 33, 9, 0, 987423, 987423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:59');
INSERT INTO `userscoresnapshotledger` VALUES (1100, 'test01', 33, 9, 0, 987623, 987623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:59');
INSERT INTO `userscoresnapshotledger` VALUES (1101, 'test01', 33, 9, 0, 987523, 987523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:59');
INSERT INTO `userscoresnapshotledger` VALUES (1102, 'test01', 33, 9, 0, 987423, 987423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:59');
INSERT INTO `userscoresnapshotledger` VALUES (1103, 'test01', 33, 9, 0, 987323, 987323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:59');
INSERT INTO `userscoresnapshotledger` VALUES (1104, 'test01', 33, 9, 0, 987223, 987223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:59');
INSERT INTO `userscoresnapshotledger` VALUES (1105, 'test01', 33, 9, 0, 987123, 987123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:34:59');
INSERT INTO `userscoresnapshotledger` VALUES (1106, 'test01', 33, 9, 0, 987023, 987023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:00');
INSERT INTO `userscoresnapshotledger` VALUES (1107, 'test01', 33, 9, 0, 986923, 986923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:00');
INSERT INTO `userscoresnapshotledger` VALUES (1108, 'test01', 33, 9, 0, 986823, 986823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:00');
INSERT INTO `userscoresnapshotledger` VALUES (1109, 'test01', 33, 9, 0, 986723, 986723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:00');
INSERT INTO `userscoresnapshotledger` VALUES (1110, 'test01', 33, 9, 0, 986623, 986623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:01');
INSERT INTO `userscoresnapshotledger` VALUES (1111, 'test01', 33, 9, 0, 986523, 986523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:01');
INSERT INTO `userscoresnapshotledger` VALUES (1112, 'test01', 33, 9, 0, 986423, 986423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:01');
INSERT INTO `userscoresnapshotledger` VALUES (1113, 'test01', 33, 9, 0, 986323, 986323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:01');
INSERT INTO `userscoresnapshotledger` VALUES (1114, 'test01', 33, 9, 0, 986223, 986223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:01');
INSERT INTO `userscoresnapshotledger` VALUES (1115, 'test01', 33, 9, 0, 986123, 986123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:02');
INSERT INTO `userscoresnapshotledger` VALUES (1116, 'test01', 33, 9, 0, 986023, 986023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:02');
INSERT INTO `userscoresnapshotledger` VALUES (1117, 'test01', 33, 9, 0, 985923, 985923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:02');
INSERT INTO `userscoresnapshotledger` VALUES (1118, 'test01', 33, 9, 0, 985823, 985823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:02');
INSERT INTO `userscoresnapshotledger` VALUES (1119, 'test01', 33, 9, 0, 985723, 985723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:02');
INSERT INTO `userscoresnapshotledger` VALUES (1120, 'test01', 33, 9, 0, 985623, 985623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:02');
INSERT INTO `userscoresnapshotledger` VALUES (1121, 'test01', 33, 9, 0, 985523, 985523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:02');
INSERT INTO `userscoresnapshotledger` VALUES (1122, 'test01', 33, 9, 0, 985423, 985423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:03');
INSERT INTO `userscoresnapshotledger` VALUES (1123, 'test01', 33, 9, 0, 985323, 985323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:03');
INSERT INTO `userscoresnapshotledger` VALUES (1124, 'test01', 33, 9, 0, 985223, 985223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:03');
INSERT INTO `userscoresnapshotledger` VALUES (1125, 'test01', 33, 9, 0, 985123, 985123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:03');
INSERT INTO `userscoresnapshotledger` VALUES (1126, 'test01', 33, 9, 0, 985023, 985023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:03');
INSERT INTO `userscoresnapshotledger` VALUES (1127, 'test01', 33, 9, 0, 985223, 985223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:04');
INSERT INTO `userscoresnapshotledger` VALUES (1128, 'test01', 33, 9, 0, 985123, 985123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:04');
INSERT INTO `userscoresnapshotledger` VALUES (1129, 'test01', 33, 9, 0, 985023, 985023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:04');
INSERT INTO `userscoresnapshotledger` VALUES (1130, 'test01', 33, 9, 0, 984923, 984923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:04');
INSERT INTO `userscoresnapshotledger` VALUES (1131, 'test01', 33, 9, 0, 984823, 984823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:04');
INSERT INTO `userscoresnapshotledger` VALUES (1132, 'test01', 33, 9, 0, 984723, 984723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:04');
INSERT INTO `userscoresnapshotledger` VALUES (1133, 'test01', 33, 9, 0, 984623, 984623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:04');
INSERT INTO `userscoresnapshotledger` VALUES (1134, 'test01', 33, 9, 0, 984523, 984523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:05');
INSERT INTO `userscoresnapshotledger` VALUES (1135, 'test01', 33, 9, 0, 984423, 984423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:05');
INSERT INTO `userscoresnapshotledger` VALUES (1136, 'test01', 33, 9, 0, 984323, 984323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:05');
INSERT INTO `userscoresnapshotledger` VALUES (1137, 'test01', 33, 9, 0, 984223, 984223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:06');
INSERT INTO `userscoresnapshotledger` VALUES (1138, 'test01', 33, 9, 0, 984123, 984123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:06');
INSERT INTO `userscoresnapshotledger` VALUES (1139, 'test01', 33, 9, 0, 984023, 984023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:06');
INSERT INTO `userscoresnapshotledger` VALUES (1140, 'test01', 33, 9, 0, 983923, 983923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:06');
INSERT INTO `userscoresnapshotledger` VALUES (1141, 'test01', 33, 9, 0, 983823, 983823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:06');
INSERT INTO `userscoresnapshotledger` VALUES (1142, 'test01', 33, 9, 0, 983723, 983723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:06');
INSERT INTO `userscoresnapshotledger` VALUES (1143, 'test01', 33, 9, 0, 983623, 983623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:06');
INSERT INTO `userscoresnapshotledger` VALUES (1144, 'test01', 33, 9, 0, 983523, 983523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:06');
INSERT INTO `userscoresnapshotledger` VALUES (1145, 'test01', 33, 9, 0, 983423, 983423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:07');
INSERT INTO `userscoresnapshotledger` VALUES (1146, 'test01', 33, 9, 0, 983323, 983323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:07');
INSERT INTO `userscoresnapshotledger` VALUES (1147, 'test01', 33, 9, 0, 983223, 983223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:07');
INSERT INTO `userscoresnapshotledger` VALUES (1148, 'test01', 33, 9, 0, 983123, 983123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:08');
INSERT INTO `userscoresnapshotledger` VALUES (1149, 'test01', 33, 9, 0, 983023, 983023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:08');
INSERT INTO `userscoresnapshotledger` VALUES (1150, 'test01', 33, 9, 0, 982923, 982923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:08');
INSERT INTO `userscoresnapshotledger` VALUES (1151, 'test01', 33, 9, 0, 982823, 982823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:08');
INSERT INTO `userscoresnapshotledger` VALUES (1152, 'test01', 33, 9, 0, 982723, 982723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:09');
INSERT INTO `userscoresnapshotledger` VALUES (1153, 'test01', 33, 9, 0, 982623, 982623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:09');
INSERT INTO `userscoresnapshotledger` VALUES (1154, 'test01', 33, 9, 0, 982523, 982523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:09');
INSERT INTO `userscoresnapshotledger` VALUES (1155, 'test01', 33, 9, 0, 982423, 982423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:09');
INSERT INTO `userscoresnapshotledger` VALUES (1156, 'test01', 33, 9, 0, 982323, 982323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:09');
INSERT INTO `userscoresnapshotledger` VALUES (1157, 'test01', 33, 9, 0, 982223, 982223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:09');
INSERT INTO `userscoresnapshotledger` VALUES (1158, 'test01', 33, 9, 0, 982123, 982123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:10');
INSERT INTO `userscoresnapshotledger` VALUES (1159, 'test01', 33, 9, 0, 982023, 982023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:10');
INSERT INTO `userscoresnapshotledger` VALUES (1160, 'test01', 33, 9, 0, 981923, 981923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:10');
INSERT INTO `userscoresnapshotledger` VALUES (1161, 'test01', 33, 9, 0, 981823, 981823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:10');
INSERT INTO `userscoresnapshotledger` VALUES (1162, 'test01', 33, 9, 0, 981723, 981723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:10');
INSERT INTO `userscoresnapshotledger` VALUES (1163, 'test01', 33, 9, 0, 981623, 981623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:10');
INSERT INTO `userscoresnapshotledger` VALUES (1164, 'test01', 33, 9, 0, 981523, 981523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:11');
INSERT INTO `userscoresnapshotledger` VALUES (1165, 'test01', 33, 9, 0, 981423, 981423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:11');
INSERT INTO `userscoresnapshotledger` VALUES (1166, 'test01', 33, 9, 0, 981323, 981323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:11');
INSERT INTO `userscoresnapshotledger` VALUES (1167, 'test01', 33, 9, 0, 981223, 981223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:11');
INSERT INTO `userscoresnapshotledger` VALUES (1168, 'test01', 33, 9, 0, 981123, 981123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:11');
INSERT INTO `userscoresnapshotledger` VALUES (1169, 'test01', 33, 9, 0, 981023, 981023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:11');
INSERT INTO `userscoresnapshotledger` VALUES (1170, 'test01', 33, 9, 0, 980923, 980923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:12');
INSERT INTO `userscoresnapshotledger` VALUES (1171, 'test01', 33, 9, 0, 980823, 980823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:12');
INSERT INTO `userscoresnapshotledger` VALUES (1172, 'test01', 33, 9, 0, 982623, 982623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:12');
INSERT INTO `userscoresnapshotledger` VALUES (1173, 'test01', 33, 9, 0, 982523, 982523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:12');
INSERT INTO `userscoresnapshotledger` VALUES (1174, 'test01', 33, 9, 0, 982423, 982423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:13');
INSERT INTO `userscoresnapshotledger` VALUES (1175, 'test01', 33, 9, 0, 982323, 982323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:13');
INSERT INTO `userscoresnapshotledger` VALUES (1176, 'test01', 33, 9, 0, 982223, 982223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:13');
INSERT INTO `userscoresnapshotledger` VALUES (1177, 'test01', 33, 9, 0, 982123, 982123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:13');
INSERT INTO `userscoresnapshotledger` VALUES (1178, 'test01', 33, 9, 0, 982023, 982023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:13');
INSERT INTO `userscoresnapshotledger` VALUES (1179, 'test01', 33, 9, 0, 981923, 981923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:13');
INSERT INTO `userscoresnapshotledger` VALUES (1180, 'test01', 33, 9, 0, 981823, 981823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:14');
INSERT INTO `userscoresnapshotledger` VALUES (1181, 'test01', 33, 9, 0, 981723, 981723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:14');
INSERT INTO `userscoresnapshotledger` VALUES (1182, 'test01', 33, 9, 0, 981623, 981623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:14');
INSERT INTO `userscoresnapshotledger` VALUES (1183, 'test01', 33, 9, 0, 981523, 981523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:14');
INSERT INTO `userscoresnapshotledger` VALUES (1184, 'test01', 33, 9, 0, 981423, 981423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:15');
INSERT INTO `userscoresnapshotledger` VALUES (1185, 'test01', 33, 9, 0, 981323, 981323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:15');
INSERT INTO `userscoresnapshotledger` VALUES (1186, 'test01', 33, 9, 0, 981223, 981223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:15');
INSERT INTO `userscoresnapshotledger` VALUES (1187, 'test01', 33, 9, 0, 981123, 981123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:15');
INSERT INTO `userscoresnapshotledger` VALUES (1188, 'test01', 33, 9, 0, 981023, 981023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:15');
INSERT INTO `userscoresnapshotledger` VALUES (1189, 'test01', 33, 9, 0, 980923, 980923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:15');
INSERT INTO `userscoresnapshotledger` VALUES (1190, 'test01', 33, 9, 0, 981223, 981223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:15');
INSERT INTO `userscoresnapshotledger` VALUES (1191, 'test01', 33, 9, 0, 981123, 981123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:16');
INSERT INTO `userscoresnapshotledger` VALUES (1192, 'test01', 33, 9, 0, 981023, 981023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:16');
INSERT INTO `userscoresnapshotledger` VALUES (1193, 'test01', 33, 9, 0, 980923, 980923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:16');
INSERT INTO `userscoresnapshotledger` VALUES (1194, 'test01', 33, 9, 0, 980823, 980823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:16');
INSERT INTO `userscoresnapshotledger` VALUES (1195, 'test01', 33, 9, 0, 980723, 980723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:16');
INSERT INTO `userscoresnapshotledger` VALUES (1196, 'test01', 33, 9, 0, 980623, 980623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:16');
INSERT INTO `userscoresnapshotledger` VALUES (1197, 'test01', 33, 9, 0, 980523, 980523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:16');
INSERT INTO `userscoresnapshotledger` VALUES (1198, 'test01', 33, 9, 0, 980423, 980423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:16');
INSERT INTO `userscoresnapshotledger` VALUES (1199, 'test01', 33, 9, 0, 980323, 980323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:16');
INSERT INTO `userscoresnapshotledger` VALUES (1200, 'test01', 33, 9, 0, 980223, 980223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:16');
INSERT INTO `userscoresnapshotledger` VALUES (1201, 'test01', 33, 9, 0, 980123, 980123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:16');
INSERT INTO `userscoresnapshotledger` VALUES (1202, 'test01', 33, 9, 0, 980023, 980023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:17');
INSERT INTO `userscoresnapshotledger` VALUES (1203, 'test01', 33, 9, 0, 979923, 979923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:17');
INSERT INTO `userscoresnapshotledger` VALUES (1204, 'test01', 33, 9, 0, 979823, 979823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:17');
INSERT INTO `userscoresnapshotledger` VALUES (1205, 'test01', 33, 9, 0, 979723, 979723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:17');
INSERT INTO `userscoresnapshotledger` VALUES (1206, 'test01', 33, 9, 0, 979623, 979623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:18');
INSERT INTO `userscoresnapshotledger` VALUES (1207, 'test01', 33, 9, 0, 979523, 979523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:18');
INSERT INTO `userscoresnapshotledger` VALUES (1208, 'test01', 33, 9, 0, 979423, 979423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:18');
INSERT INTO `userscoresnapshotledger` VALUES (1209, 'test01', 33, 9, 0, 979323, 979323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:18');
INSERT INTO `userscoresnapshotledger` VALUES (1210, 'test01', 33, 9, 0, 979223, 979223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:19');
INSERT INTO `userscoresnapshotledger` VALUES (1211, 'test01', 33, 9, 0, 979123, 979123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:19');
INSERT INTO `userscoresnapshotledger` VALUES (1212, 'test01', 33, 9, 0, 979023, 979023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:19');
INSERT INTO `userscoresnapshotledger` VALUES (1213, 'test01', 33, 9, 0, 978923, 978923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:19');
INSERT INTO `userscoresnapshotledger` VALUES (1214, 'test01', 33, 9, 0, 978823, 978823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:19');
INSERT INTO `userscoresnapshotledger` VALUES (1215, 'test01', 33, 9, 0, 978723, 978723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:20');
INSERT INTO `userscoresnapshotledger` VALUES (1216, 'test01', 33, 9, 0, 978623, 978623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:20');
INSERT INTO `userscoresnapshotledger` VALUES (1217, 'test01', 33, 9, 0, 978523, 978523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:20');
INSERT INTO `userscoresnapshotledger` VALUES (1218, 'test01', 33, 9, 0, 978423, 978423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:20');
INSERT INTO `userscoresnapshotledger` VALUES (1219, 'test01', 33, 9, 0, 978323, 978323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:20');
INSERT INTO `userscoresnapshotledger` VALUES (1220, 'test01', 33, 9, 0, 978223, 978223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:21');
INSERT INTO `userscoresnapshotledger` VALUES (1221, 'test01', 33, 9, 0, 978123, 978123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:21');
INSERT INTO `userscoresnapshotledger` VALUES (1222, 'test01', 33, 9, 0, 978023, 978023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:21');
INSERT INTO `userscoresnapshotledger` VALUES (1223, 'test01', 33, 9, 0, 977923, 977923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:21');
INSERT INTO `userscoresnapshotledger` VALUES (1224, 'test01', 33, 9, 0, 977823, 977823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:22');
INSERT INTO `userscoresnapshotledger` VALUES (1225, 'test01', 33, 9, 0, 977723, 977723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:22');
INSERT INTO `userscoresnapshotledger` VALUES (1226, 'test01', 33, 9, 0, 977623, 977623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:22');
INSERT INTO `userscoresnapshotledger` VALUES (1227, 'test01', 33, 9, 0, 977523, 977523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:22');
INSERT INTO `userscoresnapshotledger` VALUES (1228, 'test01', 33, 9, 0, 980023, 980023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:22');
INSERT INTO `userscoresnapshotledger` VALUES (1229, 'test01', 33, 9, 0, 979923, 979923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:22');
INSERT INTO `userscoresnapshotledger` VALUES (1230, 'test01', 33, 9, 0, 979823, 979823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:22');
INSERT INTO `userscoresnapshotledger` VALUES (1231, 'test01', 33, 9, 0, 979723, 979723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:23');
INSERT INTO `userscoresnapshotledger` VALUES (1232, 'test01', 33, 9, 0, 979623, 979623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:23');
INSERT INTO `userscoresnapshotledger` VALUES (1233, 'test01', 33, 9, 0, 979523, 979523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:23');
INSERT INTO `userscoresnapshotledger` VALUES (1234, 'test01', 33, 9, 0, 979423, 979423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:23');
INSERT INTO `userscoresnapshotledger` VALUES (1235, 'test01', 33, 9, 0, 979323, 979323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:24');
INSERT INTO `userscoresnapshotledger` VALUES (1236, 'test01', 33, 9, 0, 979223, 979223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:24');
INSERT INTO `userscoresnapshotledger` VALUES (1237, 'test01', 33, 9, 0, 979123, 979123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:24');
INSERT INTO `userscoresnapshotledger` VALUES (1238, 'test01', 33, 9, 0, 979023, 979023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:24');
INSERT INTO `userscoresnapshotledger` VALUES (1239, 'test01', 33, 9, 0, 978923, 978923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:24');
INSERT INTO `userscoresnapshotledger` VALUES (1240, 'test01', 33, 9, 0, 978823, 978823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:25');
INSERT INTO `userscoresnapshotledger` VALUES (1241, 'test01', 33, 9, 0, 978723, 978723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:25');
INSERT INTO `userscoresnapshotledger` VALUES (1242, 'test01', 33, 9, 0, 978623, 978623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:25');
INSERT INTO `userscoresnapshotledger` VALUES (1243, 'test01', 33, 9, 0, 978523, 978523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:25');
INSERT INTO `userscoresnapshotledger` VALUES (1244, 'test01', 33, 9, 0, 978423, 978423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:26');
INSERT INTO `userscoresnapshotledger` VALUES (1245, 'test01', 33, 9, 0, 978323, 978323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:26');
INSERT INTO `userscoresnapshotledger` VALUES (1246, 'test01', 33, 9, 0, 978223, 978223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:26');
INSERT INTO `userscoresnapshotledger` VALUES (1247, 'test01', 33, 9, 0, 978123, 978123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:26');
INSERT INTO `userscoresnapshotledger` VALUES (1248, 'test01', 33, 9, 0, 978023, 978023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:27');
INSERT INTO `userscoresnapshotledger` VALUES (1249, 'test01', 33, 9, 0, 977923, 977923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:27');
INSERT INTO `userscoresnapshotledger` VALUES (1250, 'test01', 33, 9, 0, 977823, 977823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:27');
INSERT INTO `userscoresnapshotledger` VALUES (1251, 'test01', 33, 9, 0, 977723, 977723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:27');
INSERT INTO `userscoresnapshotledger` VALUES (1252, 'test01', 33, 9, 0, 977623, 977623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:27');
INSERT INTO `userscoresnapshotledger` VALUES (1253, 'test01', 33, 9, 0, 977523, 977523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:28');
INSERT INTO `userscoresnapshotledger` VALUES (1254, 'test01', 33, 9, 0, 977423, 977423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:28');
INSERT INTO `userscoresnapshotledger` VALUES (1255, 'test01', 33, 9, 0, 977323, 977323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:28');
INSERT INTO `userscoresnapshotledger` VALUES (1256, 'test01', 33, 9, 0, 977223, 977223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:28');
INSERT INTO `userscoresnapshotledger` VALUES (1257, 'test01', 33, 9, 0, 977123, 977123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:28');
INSERT INTO `userscoresnapshotledger` VALUES (1258, 'test01', 33, 9, 0, 977023, 977023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:29');
INSERT INTO `userscoresnapshotledger` VALUES (1259, 'test01', 33, 9, 0, 976923, 976923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:29');
INSERT INTO `userscoresnapshotledger` VALUES (1260, 'test01', 33, 9, 0, 976823, 976823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:29');
INSERT INTO `userscoresnapshotledger` VALUES (1261, 'test01', 33, 9, 0, 976723, 976723, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:29');
INSERT INTO `userscoresnapshotledger` VALUES (1262, 'test01', 33, 9, 0, 976623, 976623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:29');
INSERT INTO `userscoresnapshotledger` VALUES (1263, 'test01', 33, 9, 0, 976523, 976523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:30');
INSERT INTO `userscoresnapshotledger` VALUES (1264, 'test01', 33, 9, 0, 976423, 976423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:30');
INSERT INTO `userscoresnapshotledger` VALUES (1265, 'test01', 33, 9, 0, 976323, 976323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:30');
INSERT INTO `userscoresnapshotledger` VALUES (1266, 'test01', 33, 9, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:31');
INSERT INTO `userscoresnapshotledger` VALUES (1267, 'test01', 33, 9, 0, 976123, 976123, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:31');
INSERT INTO `userscoresnapshotledger` VALUES (1268, 'test01', 33, 9, 0, 976023, 976023, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:31');
INSERT INTO `userscoresnapshotledger` VALUES (1269, 'test01', 33, 9, 0, 975923, 975923, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:31');
INSERT INTO `userscoresnapshotledger` VALUES (1270, 'test01', 33, 9, 0, 975823, 975823, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:32');
INSERT INTO `userscoresnapshotledger` VALUES (1271, 'test01', 33, 9, 0, 976623, 976623, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:32');
INSERT INTO `userscoresnapshotledger` VALUES (1272, 'test01', 33, 9, 0, 976523, 976523, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:32');
INSERT INTO `userscoresnapshotledger` VALUES (1273, 'test01', 33, 9, 0, 976423, 976423, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:33');
INSERT INTO `userscoresnapshotledger` VALUES (1274, 'test01', 33, 9, 0, 976323, 976323, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:33');
INSERT INTO `userscoresnapshotledger` VALUES (1275, 'test01', 33, 9, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:35:33');
INSERT INTO `userscoresnapshotledger` VALUES (1276, 'test01', 33, 9, 976223, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:36:14');
INSERT INTO `userscoresnapshotledger` VALUES (1277, 'test01', 47, 10, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:40:26');
INSERT INTO `userscoresnapshotledger` VALUES (1278, 'test01', 47, 10, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:40:40');
INSERT INTO `userscoresnapshotledger` VALUES (1279, 'test01', 47, 10, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:41:01');
INSERT INTO `userscoresnapshotledger` VALUES (1280, 'test01', 47, 10, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:41:07');
INSERT INTO `userscoresnapshotledger` VALUES (1281, 'test01', 47, 10, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:41:34');
INSERT INTO `userscoresnapshotledger` VALUES (1282, 'test01', 47, 10, 976223, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:41:35');
INSERT INTO `userscoresnapshotledger` VALUES (1283, 'test01', 54, 0, 976223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 18:42:46');
INSERT INTO `userscoresnapshotledger` VALUES (1284, 'test01', 54, 0, 976223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 18:46:51');
INSERT INTO `userscoresnapshotledger` VALUES (1285, 'test01', 0, 15, 976223, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 18:50:27');
INSERT INTO `userscoresnapshotledger` VALUES (1286, 'test01', 54, 0, 976223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 19:50:39');
INSERT INTO `userscoresnapshotledger` VALUES (1287, 'test01', 54, 0, 976223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 19:51:14');
INSERT INTO `userscoresnapshotledger` VALUES (1288, 'test01', 54, 0, 976223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 19:51:36');
INSERT INTO `userscoresnapshotledger` VALUES (1289, 'test01', 54, 0, 976223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 19:51:40');
INSERT INTO `userscoresnapshotledger` VALUES (1290, 'test01', 54, 0, 976223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 19:51:43');
INSERT INTO `userscoresnapshotledger` VALUES (1291, 'test01', 54, 0, 976223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 19:52:37');
INSERT INTO `userscoresnapshotledger` VALUES (1292, 'test01', 54, 0, 976223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 19:52:48');
INSERT INTO `userscoresnapshotledger` VALUES (1293, 'test01', 54, 0, 976223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 19:52:52');
INSERT INTO `userscoresnapshotledger` VALUES (1294, 'test01', 54, 0, 976223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 19:54:08');
INSERT INTO `userscoresnapshotledger` VALUES (1295, 'test01', 54, 0, 976223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 19:57:06');
INSERT INTO `userscoresnapshotledger` VALUES (1296, 'test01', 54, 0, 976223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 19:58:27');
INSERT INTO `userscoresnapshotledger` VALUES (1297, 'test01', 2, 14, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 19:58:44');
INSERT INTO `userscoresnapshotledger` VALUES (1298, 'test01', 2, 14, 976223, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 19:58:57');
INSERT INTO `userscoresnapshotledger` VALUES (1299, 'test01', 54, 0, 976223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 19:58:59');
INSERT INTO `userscoresnapshotledger` VALUES (1300, 'test01', 54, 0, 976223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 19:59:02');
INSERT INTO `userscoresnapshotledger` VALUES (1301, 'test01', 10, 16, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 19:59:08');
INSERT INTO `userscoresnapshotledger` VALUES (1302, 'test01', 10, 16, 976223, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 19:59:16');
INSERT INTO `userscoresnapshotledger` VALUES (1303, 'test01', 54, 0, 976223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 19:59:17');
INSERT INTO `userscoresnapshotledger` VALUES (1304, 'test01', 29, 17, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 19:59:23');
INSERT INTO `userscoresnapshotledger` VALUES (1305, 'test01', 29, 17, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 19:59:35');
INSERT INTO `userscoresnapshotledger` VALUES (1306, 'test01', 29, 17, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:00:04');
INSERT INTO `userscoresnapshotledger` VALUES (1307, 'test01', 29, 17, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:00:31');
INSERT INTO `userscoresnapshotledger` VALUES (1308, 'test01', 29, 17, 976223, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:00:31');
INSERT INTO `userscoresnapshotledger` VALUES (1309, 'test01', 54, 0, 976223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 20:01:39');
INSERT INTO `userscoresnapshotledger` VALUES (1310, 'test01', 54, 0, 976223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 20:04:38');
INSERT INTO `userscoresnapshotledger` VALUES (1311, 'test01', 54, 0, 976223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 20:08:18');
INSERT INTO `userscoresnapshotledger` VALUES (1312, 'test01', 54, 0, 976223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 20:31:41');
INSERT INTO `userscoresnapshotledger` VALUES (1313, 'test01', 54, 0, 976223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 20:31:45');
INSERT INTO `userscoresnapshotledger` VALUES (1314, 'test01', 29, 29, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:33:16');
INSERT INTO `userscoresnapshotledger` VALUES (1315, 'test01', 29, 29, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:33:30');
INSERT INTO `userscoresnapshotledger` VALUES (1316, 'test01', 29, 29, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:34:11');
INSERT INTO `userscoresnapshotledger` VALUES (1317, 'test01', 29, 29, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:34:38');
INSERT INTO `userscoresnapshotledger` VALUES (1318, 'test01', 29, 29, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:35:05');
INSERT INTO `userscoresnapshotledger` VALUES (1319, 'test01', 29, 29, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:35:24');
INSERT INTO `userscoresnapshotledger` VALUES (1320, 'test01', 29, 29, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:35:33');
INSERT INTO `userscoresnapshotledger` VALUES (1321, 'test01', 29, 29, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:36:00');
INSERT INTO `userscoresnapshotledger` VALUES (1322, 'test01', 29, 29, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:36:27');
INSERT INTO `userscoresnapshotledger` VALUES (1323, 'test01', 29, 29, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:36:55');
INSERT INTO `userscoresnapshotledger` VALUES (1324, 'test01', 29, 29, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:37:22');
INSERT INTO `userscoresnapshotledger` VALUES (1325, 'test01', 29, 29, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:37:49');
INSERT INTO `userscoresnapshotledger` VALUES (1326, 'test01', 29, 29, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:38:17');
INSERT INTO `userscoresnapshotledger` VALUES (1327, 'test01', 29, 29, 976223, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:38:34');
INSERT INTO `userscoresnapshotledger` VALUES (1328, 'test01', 54, 0, 976223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 20:38:47');
INSERT INTO `userscoresnapshotledger` VALUES (1329, 'test01', 29, 30, 0, 976223, 976223, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:39:16');
INSERT INTO `userscoresnapshotledger` VALUES (1330, 'test01', 29, 30, 0, 976203, 976203, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:39:29');
INSERT INTO `userscoresnapshotledger` VALUES (1331, 'test01', 29, 30, 0, 976183, 976183, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:39:56');
INSERT INTO `userscoresnapshotledger` VALUES (1332, 'test01', 29, 30, 0, 976183, 976183, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:40:46');
INSERT INTO `userscoresnapshotledger` VALUES (1333, 'test01', 29, 30, 976183, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:40:53');
INSERT INTO `userscoresnapshotledger` VALUES (1334, 'test01', 54, 0, 976183, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 20:41:04');
INSERT INTO `userscoresnapshotledger` VALUES (1335, 'test01', 29, 32, 0, 976183, 976183, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:41:18');
INSERT INTO `userscoresnapshotledger` VALUES (1336, 'test01', 29, 32, 0, 976183, 976183, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:41:24');
INSERT INTO `userscoresnapshotledger` VALUES (1337, 'test01', 29, 32, 0, 976183, 976183, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:41:25');
INSERT INTO `userscoresnapshotledger` VALUES (1338, 'test01', 29, 32, 0, 976163, 976163, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:41:31');
INSERT INTO `userscoresnapshotledger` VALUES (1339, 'test01', 29, 32, 0, 976103, 976103, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:41:58');
INSERT INTO `userscoresnapshotledger` VALUES (1340, 'test01', 29, 32, 0, 976103, 976103, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:42:25');
INSERT INTO `userscoresnapshotledger` VALUES (1341, 'test01', 29, 32, 0, 976103, 976103, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:42:53');
INSERT INTO `userscoresnapshotledger` VALUES (1342, 'test01', 29, 32, 0, 976103, 976103, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:43:20');
INSERT INTO `userscoresnapshotledger` VALUES (1343, 'test01', 29, 32, 976103, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:43:40');
INSERT INTO `userscoresnapshotledger` VALUES (1344, 'test01', 54, 0, 976103, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 20:43:41');
INSERT INTO `userscoresnapshotledger` VALUES (1345, 'test01', 29, 33, 0, 976103, 976103, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:43:55');
INSERT INTO `userscoresnapshotledger` VALUES (1346, 'test01', 29, 33, 0, 976093, 976093, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:44:08');
INSERT INTO `userscoresnapshotledger` VALUES (1347, 'test01', 29, 33, 0, 976093, 976093, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:44:36');
INSERT INTO `userscoresnapshotledger` VALUES (1348, 'test01', 29, 33, 0, 976093, 976093, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:45:04');
INSERT INTO `userscoresnapshotledger` VALUES (1349, 'test01', 29, 33, 0, 976093, 976093, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:45:34');
INSERT INTO `userscoresnapshotledger` VALUES (1350, 'test01', 29, 33, 0, 976093, 976093, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:46:02');
INSERT INTO `userscoresnapshotledger` VALUES (1351, 'test01', 29, 33, 0, 976093, 976093, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:46:29');
INSERT INTO `userscoresnapshotledger` VALUES (1352, 'test01', 29, 33, 0, 976093, 976093, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:46:56');
INSERT INTO `userscoresnapshotledger` VALUES (1353, 'test01', 54, 0, 976093, 0, 0, 976093, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 20:47:06');
INSERT INTO `userscoresnapshotledger` VALUES (1354, 'test01', 29, 33, 976093, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 20:47:07');
INSERT INTO `userscoresnapshotledger` VALUES (1355, 'test01', 54, 0, 976093, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 20:55:42');
INSERT INTO `userscoresnapshotledger` VALUES (1356, 'test01', 54, 0, 976093, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 20:58:43');
INSERT INTO `userscoresnapshotledger` VALUES (1357, 'test01', 29, 36, 0, 976093, 976093, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:01:13');
INSERT INTO `userscoresnapshotledger` VALUES (1358, 'test01', 29, 36, 976093, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:01:21');
INSERT INTO `userscoresnapshotledger` VALUES (1359, 'test01', 29, 41, 976093, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:03:09');
INSERT INTO `userscoresnapshotledger` VALUES (1360, 'test01', 0, 4, 976093, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:05:43');
INSERT INTO `userscoresnapshotledger` VALUES (1361, 'test01', 2, 1, 0, 976093, 976093, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:17:56');
INSERT INTO `userscoresnapshotledger` VALUES (1362, 'test01', 2, 1, 0, 976093, 976093, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:18:10');
INSERT INTO `userscoresnapshotledger` VALUES (1363, 'test01', 2, 1, 0, 976073, 976073, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:18:45');
INSERT INTO `userscoresnapshotledger` VALUES (1364, 'test01', 2, 1, 976073, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:18:57');
INSERT INTO `userscoresnapshotledger` VALUES (1365, 'test01', 54, 0, 976073, 0, 0, 0, 'SNAPSHOT_RECOVER:GAME_LOST', '2026-07-01 21:18:57');
INSERT INTO `userscoresnapshotledger` VALUES (1366, 'test01', 47, 6, 0, 976073, 976073, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:24:42');
INSERT INTO `userscoresnapshotledger` VALUES (1367, 'test01', 54, 0, 976073, 0, 0, 976073, 'SNAPSHOT_RECOVER:GAME_LOST', '2026-07-01 21:24:56');
INSERT INTO `userscoresnapshotledger` VALUES (1368, 'test01', 47, 7, 0, 976073, 976073, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:25:02');
INSERT INTO `userscoresnapshotledger` VALUES (1369, 'test01', 47, 7, 0, 976228, 976228, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:25:14');
INSERT INTO `userscoresnapshotledger` VALUES (1370, 'test01', 47, 7, 0, 976374, 976374, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:25:56');
INSERT INTO `userscoresnapshotledger` VALUES (1371, 'test01', 47, 7, 976374, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:25:58');
INSERT INTO `userscoresnapshotledger` VALUES (1372, 'test01', 54, 0, 976374, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 21:26:01');
INSERT INTO `userscoresnapshotledger` VALUES (1373, 'test01', 33, 9, 0, 976374, 976374, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:29:57');
INSERT INTO `userscoresnapshotledger` VALUES (1374, 'test01', 33, 9, 0, 976274, 976274, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:30:08');
INSERT INTO `userscoresnapshotledger` VALUES (1375, 'test01', 33, 9, 0, 976174, 976174, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:30:11');
INSERT INTO `userscoresnapshotledger` VALUES (1376, 'test01', 33, 9, 0, 976074, 976074, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:30:12');
INSERT INTO `userscoresnapshotledger` VALUES (1377, 'test01', 33, 9, 0, 975974, 975974, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:30:12');
INSERT INTO `userscoresnapshotledger` VALUES (1378, 'test01', 33, 9, 0, 975874, 975874, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:30:13');
INSERT INTO `userscoresnapshotledger` VALUES (1379, 'test01', 33, 9, 0, 975774, 975774, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:30:13');
INSERT INTO `userscoresnapshotledger` VALUES (1380, 'test01', 33, 9, 0, 975674, 975674, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:30:14');
INSERT INTO `userscoresnapshotledger` VALUES (1381, 'test01', 33, 9, 0, 975574, 975574, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:30:15');
INSERT INTO `userscoresnapshotledger` VALUES (1382, 'test01', 33, 9, 0, 975474, 975474, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:30:16');
INSERT INTO `userscoresnapshotledger` VALUES (1383, 'test01', 33, 9, 0, 975374, 975374, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:30:16');
INSERT INTO `userscoresnapshotledger` VALUES (1384, 'test01', 33, 9, 0, 975274, 975274, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:30:17');
INSERT INTO `userscoresnapshotledger` VALUES (1385, 'test01', 33, 9, 0, 975174, 975174, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:30:17');
INSERT INTO `userscoresnapshotledger` VALUES (1386, 'test01', 33, 9, 0, 975074, 975074, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:30:17');
INSERT INTO `userscoresnapshotledger` VALUES (1387, 'test01', 33, 9, 0, 974974, 974974, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:30:17');
INSERT INTO `userscoresnapshotledger` VALUES (1388, 'test01', 33, 9, 0, 974874, 974874, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:30:18');
INSERT INTO `userscoresnapshotledger` VALUES (1389, 'test01', 33, 9, 0, 974774, 974774, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:30:18');
INSERT INTO `userscoresnapshotledger` VALUES (1390, 'test01', 33, 9, 0, 974674, 974674, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:30:19');
INSERT INTO `userscoresnapshotledger` VALUES (1391, 'test01', 33, 9, 0, 974574, 974574, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:30:19');
INSERT INTO `userscoresnapshotledger` VALUES (1392, 'test01', 33, 9, 0, 974474, 974474, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:30:20');
INSERT INTO `userscoresnapshotledger` VALUES (1393, 'test01', 33, 9, 0, 974374, 974374, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:30:20');
INSERT INTO `userscoresnapshotledger` VALUES (1394, 'test01', 33, 9, 974374, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:30:29');
INSERT INTO `userscoresnapshotledger` VALUES (1395, 'test01', 0, 9, 974374, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:39:45');
INSERT INTO `userscoresnapshotledger` VALUES (1396, 'test01', 19, 1, 0, 974374, 974374, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:27');
INSERT INTO `userscoresnapshotledger` VALUES (1397, 'test01', 19, 1, 0, 974369, 974369, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:31');
INSERT INTO `userscoresnapshotledger` VALUES (1398, 'test01', 19, 1, 0, 974364, 974364, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:31');
INSERT INTO `userscoresnapshotledger` VALUES (1399, 'test01', 19, 1, 0, 974359, 974359, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:32');
INSERT INTO `userscoresnapshotledger` VALUES (1400, 'test01', 19, 1, 0, 974354, 974354, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:32');
INSERT INTO `userscoresnapshotledger` VALUES (1401, 'test01', 19, 1, 0, 974349, 974349, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:32');
INSERT INTO `userscoresnapshotledger` VALUES (1402, 'test01', 19, 1, 0, 974344, 974344, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:34');
INSERT INTO `userscoresnapshotledger` VALUES (1403, 'test01', 19, 1, 0, 974339, 974339, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:34');
INSERT INTO `userscoresnapshotledger` VALUES (1404, 'test01', 19, 1, 0, 974334, 974334, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:34');
INSERT INTO `userscoresnapshotledger` VALUES (1405, 'test01', 19, 1, 0, 974329, 974329, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:34');
INSERT INTO `userscoresnapshotledger` VALUES (1406, 'test01', 19, 1, 0, 974324, 974324, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:34');
INSERT INTO `userscoresnapshotledger` VALUES (1407, 'test01', 19, 1, 0, 974349, 974349, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:35');
INSERT INTO `userscoresnapshotledger` VALUES (1408, 'test01', 19, 1, 0, 974344, 974344, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:35');
INSERT INTO `userscoresnapshotledger` VALUES (1409, 'test01', 19, 1, 0, 974339, 974339, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:35');
INSERT INTO `userscoresnapshotledger` VALUES (1410, 'test01', 19, 1, 0, 974334, 974334, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:35');
INSERT INTO `userscoresnapshotledger` VALUES (1411, 'test01', 19, 1, 0, 974329, 974329, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:35');
INSERT INTO `userscoresnapshotledger` VALUES (1412, 'test01', 19, 1, 0, 974324, 974324, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:35');
INSERT INTO `userscoresnapshotledger` VALUES (1413, 'test01', 19, 1, 0, 974319, 974319, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:35');
INSERT INTO `userscoresnapshotledger` VALUES (1414, 'test01', 19, 1, 0, 974314, 974314, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:35');
INSERT INTO `userscoresnapshotledger` VALUES (1415, 'test01', 19, 1, 0, 974309, 974309, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:36');
INSERT INTO `userscoresnapshotledger` VALUES (1416, 'test01', 19, 1, 0, 974304, 974304, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:36');
INSERT INTO `userscoresnapshotledger` VALUES (1417, 'test01', 19, 1, 0, 974299, 974299, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:36');
INSERT INTO `userscoresnapshotledger` VALUES (1418, 'test01', 19, 1, 0, 974294, 974294, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:36');
INSERT INTO `userscoresnapshotledger` VALUES (1419, 'test01', 19, 1, 0, 974289, 974289, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:36');
INSERT INTO `userscoresnapshotledger` VALUES (1420, 'test01', 19, 1, 0, 974284, 974284, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:36');
INSERT INTO `userscoresnapshotledger` VALUES (1421, 'test01', 19, 1, 0, 974279, 974279, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:36');
INSERT INTO `userscoresnapshotledger` VALUES (1422, 'test01', 19, 1, 0, 974274, 974274, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:36');
INSERT INTO `userscoresnapshotledger` VALUES (1423, 'test01', 19, 1, 0, 974269, 974269, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:36');
INSERT INTO `userscoresnapshotledger` VALUES (1424, 'test01', 19, 1, 0, 974264, 974264, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:36');
INSERT INTO `userscoresnapshotledger` VALUES (1425, 'test01', 19, 1, 0, 974259, 974259, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:37');
INSERT INTO `userscoresnapshotledger` VALUES (1426, 'test01', 19, 1, 0, 974254, 974254, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:37');
INSERT INTO `userscoresnapshotledger` VALUES (1427, 'test01', 19, 1, 0, 974249, 974249, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:37');
INSERT INTO `userscoresnapshotledger` VALUES (1428, 'test01', 19, 1, 0, 974244, 974244, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:37');
INSERT INTO `userscoresnapshotledger` VALUES (1429, 'test01', 19, 1, 0, 974239, 974239, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:37');
INSERT INTO `userscoresnapshotledger` VALUES (1430, 'test01', 19, 1, 0, 974234, 974234, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:37');
INSERT INTO `userscoresnapshotledger` VALUES (1431, 'test01', 19, 1, 0, 974229, 974229, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:37');
INSERT INTO `userscoresnapshotledger` VALUES (1432, 'test01', 19, 1, 0, 974224, 974224, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:38');
INSERT INTO `userscoresnapshotledger` VALUES (1433, 'test01', 19, 1, 0, 974219, 974219, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:38');
INSERT INTO `userscoresnapshotledger` VALUES (1434, 'test01', 19, 1, 0, 974214, 974214, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:38');
INSERT INTO `userscoresnapshotledger` VALUES (1435, 'test01', 19, 1, 0, 974209, 974209, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:38');
INSERT INTO `userscoresnapshotledger` VALUES (1436, 'test01', 19, 1, 0, 974204, 974204, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:38');
INSERT INTO `userscoresnapshotledger` VALUES (1437, 'test01', 19, 1, 0, 974199, 974199, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:38');
INSERT INTO `userscoresnapshotledger` VALUES (1438, 'test01', 19, 1, 0, 974194, 974194, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:38');
INSERT INTO `userscoresnapshotledger` VALUES (1439, 'test01', 19, 1, 0, 974189, 974189, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:38');
INSERT INTO `userscoresnapshotledger` VALUES (1440, 'test01', 19, 1, 0, 974184, 974184, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:38');
INSERT INTO `userscoresnapshotledger` VALUES (1441, 'test01', 19, 1, 0, 974259, 974259, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:38');
INSERT INTO `userscoresnapshotledger` VALUES (1442, 'test01', 19, 1, 0, 974254, 974254, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:39');
INSERT INTO `userscoresnapshotledger` VALUES (1443, 'test01', 19, 1, 0, 974249, 974249, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:39');
INSERT INTO `userscoresnapshotledger` VALUES (1444, 'test01', 19, 1, 0, 974244, 974244, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:39');
INSERT INTO `userscoresnapshotledger` VALUES (1445, 'test01', 19, 1, 0, 974239, 974239, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:40');
INSERT INTO `userscoresnapshotledger` VALUES (1446, 'test01', 19, 1, 0, 974234, 974234, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:40');
INSERT INTO `userscoresnapshotledger` VALUES (1447, 'test01', 19, 1, 0, 974229, 974229, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:40');
INSERT INTO `userscoresnapshotledger` VALUES (1448, 'test01', 19, 1, 0, 974224, 974224, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:40');
INSERT INTO `userscoresnapshotledger` VALUES (1449, 'test01', 19, 1, 0, 974219, 974219, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:40');
INSERT INTO `userscoresnapshotledger` VALUES (1450, 'test01', 19, 1, 0, 974214, 974214, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:40');
INSERT INTO `userscoresnapshotledger` VALUES (1451, 'test01', 19, 1, 0, 974209, 974209, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:40');
INSERT INTO `userscoresnapshotledger` VALUES (1452, 'test01', 19, 1, 0, 974204, 974204, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:40');
INSERT INTO `userscoresnapshotledger` VALUES (1453, 'test01', 19, 1, 0, 974244, 974244, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:40');
INSERT INTO `userscoresnapshotledger` VALUES (1454, 'test01', 19, 1, 0, 974239, 974239, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:41');
INSERT INTO `userscoresnapshotledger` VALUES (1455, 'test01', 19, 1, 0, 974234, 974234, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:41');
INSERT INTO `userscoresnapshotledger` VALUES (1456, 'test01', 19, 1, 0, 974229, 974229, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:41');
INSERT INTO `userscoresnapshotledger` VALUES (1457, 'test01', 19, 1, 0, 974224, 974224, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:41');
INSERT INTO `userscoresnapshotledger` VALUES (1458, 'test01', 19, 1, 0, 974219, 974219, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:41');
INSERT INTO `userscoresnapshotledger` VALUES (1459, 'test01', 19, 1, 0, 974214, 974214, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:42');
INSERT INTO `userscoresnapshotledger` VALUES (1460, 'test01', 19, 1, 0, 974209, 974209, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:42');
INSERT INTO `userscoresnapshotledger` VALUES (1461, 'test01', 19, 1, 0, 974204, 974204, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:42');
INSERT INTO `userscoresnapshotledger` VALUES (1462, 'test01', 19, 1, 0, 974199, 974199, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:42');
INSERT INTO `userscoresnapshotledger` VALUES (1463, 'test01', 19, 1, 0, 974194, 974194, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:42');
INSERT INTO `userscoresnapshotledger` VALUES (1464, 'test01', 19, 1, 0, 974189, 974189, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:42');
INSERT INTO `userscoresnapshotledger` VALUES (1465, 'test01', 19, 1, 0, 974184, 974184, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:43');
INSERT INTO `userscoresnapshotledger` VALUES (1466, 'test01', 19, 1, 0, 974179, 974179, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:43');
INSERT INTO `userscoresnapshotledger` VALUES (1467, 'test01', 19, 1, 0, 974174, 974174, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:43');
INSERT INTO `userscoresnapshotledger` VALUES (1468, 'test01', 19, 1, 0, 974169, 974169, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:44');
INSERT INTO `userscoresnapshotledger` VALUES (1469, 'test01', 19, 1, 0, 974164, 974164, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:45');
INSERT INTO `userscoresnapshotledger` VALUES (1470, 'test01', 19, 1, 0, 974159, 974159, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:45');
INSERT INTO `userscoresnapshotledger` VALUES (1471, 'test01', 19, 1, 0, 974154, 974154, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:45');
INSERT INTO `userscoresnapshotledger` VALUES (1472, 'test01', 19, 1, 0, 974149, 974149, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:45');
INSERT INTO `userscoresnapshotledger` VALUES (1473, 'test01', 19, 1, 0, 974144, 974144, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:46');
INSERT INTO `userscoresnapshotledger` VALUES (1474, 'test01', 19, 1, 0, 974139, 974139, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:46');
INSERT INTO `userscoresnapshotledger` VALUES (1475, 'test01', 19, 1, 0, 974134, 974134, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:46');
INSERT INTO `userscoresnapshotledger` VALUES (1476, 'test01', 19, 1, 0, 974129, 974129, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:46');
INSERT INTO `userscoresnapshotledger` VALUES (1477, 'test01', 19, 1, 0, 974124, 974124, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:47');
INSERT INTO `userscoresnapshotledger` VALUES (1478, 'test01', 19, 1, 0, 974119, 974119, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:47');
INSERT INTO `userscoresnapshotledger` VALUES (1479, 'test01', 19, 1, 0, 974114, 974114, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:47');
INSERT INTO `userscoresnapshotledger` VALUES (1480, 'test01', 19, 1, 0, 974109, 974109, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:47');
INSERT INTO `userscoresnapshotledger` VALUES (1481, 'test01', 19, 1, 0, 974104, 974104, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:47');
INSERT INTO `userscoresnapshotledger` VALUES (1482, 'test01', 19, 1, 0, 974099, 974099, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:47');
INSERT INTO `userscoresnapshotledger` VALUES (1483, 'test01', 19, 1, 0, 974094, 974094, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:47');
INSERT INTO `userscoresnapshotledger` VALUES (1484, 'test01', 19, 1, 0, 974089, 974089, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:47');
INSERT INTO `userscoresnapshotledger` VALUES (1485, 'test01', 19, 1, 0, 974084, 974084, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:47');
INSERT INTO `userscoresnapshotledger` VALUES (1486, 'test01', 19, 1, 0, 974079, 974079, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:48');
INSERT INTO `userscoresnapshotledger` VALUES (1487, 'test01', 19, 1, 0, 974124, 974124, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:48');
INSERT INTO `userscoresnapshotledger` VALUES (1488, 'test01', 19, 1, 0, 974119, 974119, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:48');
INSERT INTO `userscoresnapshotledger` VALUES (1489, 'test01', 19, 1, 0, 974114, 974114, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:48');
INSERT INTO `userscoresnapshotledger` VALUES (1490, 'test01', 19, 1, 0, 974109, 974109, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:49');
INSERT INTO `userscoresnapshotledger` VALUES (1491, 'test01', 19, 1, 0, 974104, 974104, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:49');
INSERT INTO `userscoresnapshotledger` VALUES (1492, 'test01', 19, 1, 0, 974099, 974099, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:49');
INSERT INTO `userscoresnapshotledger` VALUES (1493, 'test01', 19, 1, 0, 974094, 974094, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:49');
INSERT INTO `userscoresnapshotledger` VALUES (1494, 'test01', 19, 1, 0, 974089, 974089, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:49');
INSERT INTO `userscoresnapshotledger` VALUES (1495, 'test01', 19, 1, 0, 974084, 974084, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:50');
INSERT INTO `userscoresnapshotledger` VALUES (1496, 'test01', 19, 1, 0, 974079, 974079, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:50');
INSERT INTO `userscoresnapshotledger` VALUES (1497, 'test01', 19, 1, 0, 974074, 974074, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:50');
INSERT INTO `userscoresnapshotledger` VALUES (1498, 'test01', 19, 1, 0, 974069, 974069, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:50');
INSERT INTO `userscoresnapshotledger` VALUES (1499, 'test01', 19, 1, 0, 974064, 974064, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:51');
INSERT INTO `userscoresnapshotledger` VALUES (1500, 'test01', 19, 1, 0, 974059, 974059, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:51');
INSERT INTO `userscoresnapshotledger` VALUES (1501, 'test01', 19, 1, 0, 974054, 974054, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:51');
INSERT INTO `userscoresnapshotledger` VALUES (1502, 'test01', 19, 1, 0, 974049, 974049, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:52');
INSERT INTO `userscoresnapshotledger` VALUES (1503, 'test01', 19, 1, 0, 974044, 974044, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:52');
INSERT INTO `userscoresnapshotledger` VALUES (1504, 'test01', 19, 1, 0, 974039, 974039, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:52');
INSERT INTO `userscoresnapshotledger` VALUES (1505, 'test01', 19, 1, 0, 974034, 974034, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:52');
INSERT INTO `userscoresnapshotledger` VALUES (1506, 'test01', 19, 1, 0, 974029, 974029, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:52');
INSERT INTO `userscoresnapshotledger` VALUES (1507, 'test01', 19, 1, 0, 974024, 974024, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:52');
INSERT INTO `userscoresnapshotledger` VALUES (1508, 'test01', 19, 1, 0, 974019, 974019, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:52');
INSERT INTO `userscoresnapshotledger` VALUES (1509, 'test01', 19, 1, 0, 974014, 974014, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:53');
INSERT INTO `userscoresnapshotledger` VALUES (1510, 'test01', 19, 1, 0, 974009, 974009, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:53');
INSERT INTO `userscoresnapshotledger` VALUES (1511, 'test01', 19, 1, 0, 974004, 974004, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:53');
INSERT INTO `userscoresnapshotledger` VALUES (1512, 'test01', 19, 1, 0, 973999, 973999, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:53');
INSERT INTO `userscoresnapshotledger` VALUES (1513, 'test01', 19, 1, 0, 973994, 973994, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:53');
INSERT INTO `userscoresnapshotledger` VALUES (1514, 'test01', 19, 1, 0, 973989, 973989, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:53');
INSERT INTO `userscoresnapshotledger` VALUES (1515, 'test01', 19, 1, 0, 973984, 973984, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:53');
INSERT INTO `userscoresnapshotledger` VALUES (1516, 'test01', 19, 1, 0, 973979, 973979, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:53');
INSERT INTO `userscoresnapshotledger` VALUES (1517, 'test01', 19, 1, 0, 973974, 973974, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:53');
INSERT INTO `userscoresnapshotledger` VALUES (1518, 'test01', 19, 1, 0, 973969, 973969, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:53');
INSERT INTO `userscoresnapshotledger` VALUES (1519, 'test01', 19, 1, 0, 973964, 973964, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:54');
INSERT INTO `userscoresnapshotledger` VALUES (1520, 'test01', 19, 1, 0, 973959, 973959, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:54');
INSERT INTO `userscoresnapshotledger` VALUES (1521, 'test01', 19, 1, 0, 973954, 973954, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:54');
INSERT INTO `userscoresnapshotledger` VALUES (1522, 'test01', 19, 1, 0, 973949, 973949, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:54');
INSERT INTO `userscoresnapshotledger` VALUES (1523, 'test01', 19, 1, 0, 973944, 973944, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:54');
INSERT INTO `userscoresnapshotledger` VALUES (1524, 'test01', 19, 1, 0, 973939, 973939, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:54');
INSERT INTO `userscoresnapshotledger` VALUES (1525, 'test01', 19, 1, 0, 973934, 973934, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:54');
INSERT INTO `userscoresnapshotledger` VALUES (1526, 'test01', 19, 1, 0, 973929, 973929, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:54');
INSERT INTO `userscoresnapshotledger` VALUES (1527, 'test01', 19, 1, 0, 974004, 974004, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:54');
INSERT INTO `userscoresnapshotledger` VALUES (1528, 'test01', 19, 1, 0, 973999, 973999, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:55');
INSERT INTO `userscoresnapshotledger` VALUES (1529, 'test01', 19, 1, 0, 974099, 974099, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:55');
INSERT INTO `userscoresnapshotledger` VALUES (1530, 'test01', 19, 1, 0, 974299, 974299, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:55');
INSERT INTO `userscoresnapshotledger` VALUES (1531, 'test01', 19, 1, 0, 974294, 974294, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:55');
INSERT INTO `userscoresnapshotledger` VALUES (1532, 'test01', 19, 1, 0, 974289, 974289, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:55');
INSERT INTO `userscoresnapshotledger` VALUES (1533, 'test01', 19, 1, 0, 974284, 974284, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:55');
INSERT INTO `userscoresnapshotledger` VALUES (1534, 'test01', 19, 1, 0, 974279, 974279, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:56');
INSERT INTO `userscoresnapshotledger` VALUES (1535, 'test01', 19, 1, 0, 974274, 974274, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:56');
INSERT INTO `userscoresnapshotledger` VALUES (1536, 'test01', 19, 1, 0, 974374, 974374, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:56');
INSERT INTO `userscoresnapshotledger` VALUES (1537, 'test01', 19, 1, 0, 974369, 974369, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:56');
INSERT INTO `userscoresnapshotledger` VALUES (1538, 'test01', 19, 1, 0, 974364, 974364, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:56');
INSERT INTO `userscoresnapshotledger` VALUES (1539, 'test01', 19, 1, 0, 974359, 974359, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:56');
INSERT INTO `userscoresnapshotledger` VALUES (1540, 'test01', 19, 1, 0, 974354, 974354, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:57');
INSERT INTO `userscoresnapshotledger` VALUES (1541, 'test01', 19, 1, 0, 974349, 974349, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:57');
INSERT INTO `userscoresnapshotledger` VALUES (1542, 'test01', 19, 1, 0, 974344, 974344, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:57');
INSERT INTO `userscoresnapshotledger` VALUES (1543, 'test01', 19, 1, 0, 974339, 974339, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:57');
INSERT INTO `userscoresnapshotledger` VALUES (1544, 'test01', 19, 1, 0, 974334, 974334, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:57');
INSERT INTO `userscoresnapshotledger` VALUES (1545, 'test01', 19, 1, 0, 974329, 974329, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:58');
INSERT INTO `userscoresnapshotledger` VALUES (1546, 'test01', 19, 1, 0, 974324, 974324, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:58');
INSERT INTO `userscoresnapshotledger` VALUES (1547, 'test01', 19, 1, 0, 974319, 974319, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:58');
INSERT INTO `userscoresnapshotledger` VALUES (1548, 'test01', 19, 1, 0, 974314, 974314, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:58');
INSERT INTO `userscoresnapshotledger` VALUES (1549, 'test01', 19, 1, 0, 974309, 974309, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:58');
INSERT INTO `userscoresnapshotledger` VALUES (1550, 'test01', 19, 1, 0, 974304, 974304, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:58');
INSERT INTO `userscoresnapshotledger` VALUES (1551, 'test01', 19, 1, 0, 974299, 974299, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:59');
INSERT INTO `userscoresnapshotledger` VALUES (1552, 'test01', 19, 1, 0, 974294, 974294, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:59');
INSERT INTO `userscoresnapshotledger` VALUES (1553, 'test01', 19, 1, 0, 974289, 974289, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:59');
INSERT INTO `userscoresnapshotledger` VALUES (1554, 'test01', 19, 1, 0, 974284, 974284, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:59');
INSERT INTO `userscoresnapshotledger` VALUES (1555, 'test01', 19, 1, 0, 974279, 974279, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:59');
INSERT INTO `userscoresnapshotledger` VALUES (1556, 'test01', 19, 1, 0, 974274, 974274, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:59');
INSERT INTO `userscoresnapshotledger` VALUES (1557, 'test01', 19, 1, 0, 974269, 974269, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:44:59');
INSERT INTO `userscoresnapshotledger` VALUES (1558, 'test01', 19, 1, 0, 974264, 974264, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:45:00');
INSERT INTO `userscoresnapshotledger` VALUES (1559, 'test01', 19, 1, 0, 974259, 974259, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:45:00');
INSERT INTO `userscoresnapshotledger` VALUES (1560, 'test01', 19, 1, 0, 974254, 974254, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:45:00');
INSERT INTO `userscoresnapshotledger` VALUES (1561, 'test01', 19, 1, 0, 974249, 974249, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:45:00');
INSERT INTO `userscoresnapshotledger` VALUES (1562, 'test01', 19, 1, 0, 974244, 974244, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:45:00');
INSERT INTO `userscoresnapshotledger` VALUES (1563, 'test01', 19, 1, 0, 974239, 974239, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:45:01');
INSERT INTO `userscoresnapshotledger` VALUES (1564, 'test01', 19, 1, 0, 974234, 974234, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:45:01');
INSERT INTO `userscoresnapshotledger` VALUES (1565, 'test01', 19, 1, 0, 974229, 974229, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:45:01');
INSERT INTO `userscoresnapshotledger` VALUES (1566, 'test01', 19, 1, 0, 974224, 974224, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:45:01');
INSERT INTO `userscoresnapshotledger` VALUES (1567, 'test01', 19, 1, 0, 974219, 974219, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:45:01');
INSERT INTO `userscoresnapshotledger` VALUES (1568, 'test01', 19, 1, 0, 974214, 974214, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:45:01');
INSERT INTO `userscoresnapshotledger` VALUES (1569, 'test01', 19, 1, 0, 974209, 974209, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:45:01');
INSERT INTO `userscoresnapshotledger` VALUES (1570, 'test01', 19, 1, 974209, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:45:01');
INSERT INTO `userscoresnapshotledger` VALUES (1571, 'test01', 19, 1, 974209, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:45:02');
INSERT INTO `userscoresnapshotledger` VALUES (1572, 'test01', 19, 1, 974209, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:45:03');
INSERT INTO `userscoresnapshotledger` VALUES (1573, 'test01', 54, 0, 974209, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 21:45:04');
INSERT INTO `userscoresnapshotledger` VALUES (1574, 'test01', 47, 3, 0, 974209, 974209, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:45:19');
INSERT INTO `userscoresnapshotledger` VALUES (1575, 'test01', 47, 3, 974209, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:45:26');
INSERT INTO `userscoresnapshotledger` VALUES (1576, 'test01', 54, 0, 974209, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 21:45:27');
INSERT INTO `userscoresnapshotledger` VALUES (1577, 'test01', 54, 0, 974209, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 21:45:43');
INSERT INTO `userscoresnapshotledger` VALUES (1578, 'test01', 54, 0, 974209, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 21:45:46');
INSERT INTO `userscoresnapshotledger` VALUES (1579, 'test01', 5, 10, 0, 974209, 974209, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:51:29');
INSERT INTO `userscoresnapshotledger` VALUES (1580, 'test01', 5, 10, 0, 974199, 974199, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:52:43');
INSERT INTO `userscoresnapshotledger` VALUES (1581, 'test01', 5, 10, 0, 974219, 974219, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:52:53');
INSERT INTO `userscoresnapshotledger` VALUES (1582, 'test01', 5, 10, 974219, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:52:56');
INSERT INTO `userscoresnapshotledger` VALUES (1583, 'test01', 54, 0, 974219, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 21:52:57');
INSERT INTO `userscoresnapshotledger` VALUES (1584, 'test01', 14, 11, 0, 974219, 974219, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:53:04');
INSERT INTO `userscoresnapshotledger` VALUES (1585, 'test01', 14, 11, 0, 974209, 974209, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:53:08');
INSERT INTO `userscoresnapshotledger` VALUES (1586, 'test01', 14, 11, 974209, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:53:14');
INSERT INTO `userscoresnapshotledger` VALUES (1587, 'test01', 54, 0, 974209, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 21:53:15');
INSERT INTO `userscoresnapshotledger` VALUES (1588, 'test01', 15, 12, 0, 974209, 974209, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:53:22');
INSERT INTO `userscoresnapshotledger` VALUES (1589, 'test01', 15, 12, 0, 974199, 974199, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:53:25');
INSERT INTO `userscoresnapshotledger` VALUES (1590, 'test01', 15, 12, 974209, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:53:29');
INSERT INTO `userscoresnapshotledger` VALUES (1591, 'test01', 54, 0, 974209, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 21:53:30');
INSERT INTO `userscoresnapshotledger` VALUES (1592, 'test01', 44, 13, 0, 974209, 974209, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:53:37');
INSERT INTO `userscoresnapshotledger` VALUES (1593, 'test01', 44, 13, 0, 974199, 974199, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:53:43');
INSERT INTO `userscoresnapshotledger` VALUES (1594, 'test01', 44, 13, 974199, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:53:47');
INSERT INTO `userscoresnapshotledger` VALUES (1595, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 21:53:48');
INSERT INTO `userscoresnapshotledger` VALUES (1596, 'test01', 10, 17, 0, 974199, 974199, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:54:20');
INSERT INTO `userscoresnapshotledger` VALUES (1597, 'test01', 10, 17, 974199, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:54:32');
INSERT INTO `userscoresnapshotledger` VALUES (1598, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 21:54:38');
INSERT INTO `userscoresnapshotledger` VALUES (1599, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 21:54:44');
INSERT INTO `userscoresnapshotledger` VALUES (1600, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 21:55:14');
INSERT INTO `userscoresnapshotledger` VALUES (1601, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 21:56:12');
INSERT INTO `userscoresnapshotledger` VALUES (1602, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 21:57:35');
INSERT INTO `userscoresnapshotledger` VALUES (1603, 'test01', 0, 24, 974199, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 21:57:47');
INSERT INTO `userscoresnapshotledger` VALUES (1604, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 22:06:07');
INSERT INTO `userscoresnapshotledger` VALUES (1605, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 22:06:13');
INSERT INTO `userscoresnapshotledger` VALUES (1606, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 22:06:16');
INSERT INTO `userscoresnapshotledger` VALUES (1607, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 22:06:21');
INSERT INTO `userscoresnapshotledger` VALUES (1608, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 22:06:42');
INSERT INTO `userscoresnapshotledger` VALUES (1609, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 22:06:57');
INSERT INTO `userscoresnapshotledger` VALUES (1610, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 22:07:37');
INSERT INTO `userscoresnapshotledger` VALUES (1611, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 22:08:21');
INSERT INTO `userscoresnapshotledger` VALUES (1612, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 22:11:24');
INSERT INTO `userscoresnapshotledger` VALUES (1613, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 22:23:44');
INSERT INTO `userscoresnapshotledger` VALUES (1614, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 22:24:01');
INSERT INTO `userscoresnapshotledger` VALUES (1615, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 22:26:20');
INSERT INTO `userscoresnapshotledger` VALUES (1616, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 22:28:40');
INSERT INTO `userscoresnapshotledger` VALUES (1617, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 22:41:49');
INSERT INTO `userscoresnapshotledger` VALUES (1618, 'test01', 0, 31, 974199, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 22:51:08');
INSERT INTO `userscoresnapshotledger` VALUES (1619, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 22:53:05');
INSERT INTO `userscoresnapshotledger` VALUES (1620, 'test01', 47, 4, 0, 974199, 974199, 0, 'SNAPSHOT_SAVE', '2026-07-01 22:53:09');
INSERT INTO `userscoresnapshotledger` VALUES (1621, 'test01', 47, 4, 974199, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 22:53:13');
INSERT INTO `userscoresnapshotledger` VALUES (1622, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 22:53:15');
INSERT INTO `userscoresnapshotledger` VALUES (1623, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 22:53:23');
INSERT INTO `userscoresnapshotledger` VALUES (1624, 'test01', 0, 8, 974199, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 22:56:30');
INSERT INTO `userscoresnapshotledger` VALUES (1625, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 23:00:13');
INSERT INTO `userscoresnapshotledger` VALUES (1626, 'test01', 29, 4, 974199, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 23:02:01');
INSERT INTO `userscoresnapshotledger` VALUES (1627, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 23:04:00');
INSERT INTO `userscoresnapshotledger` VALUES (1628, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 23:04:05');
INSERT INTO `userscoresnapshotledger` VALUES (1629, 'test01', 47, 7, 0, 974199, 974199, 0, 'SNAPSHOT_SAVE', '2026-07-01 23:04:08');
INSERT INTO `userscoresnapshotledger` VALUES (1630, 'test01', 47, 7, 974199, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 23:04:16');
INSERT INTO `userscoresnapshotledger` VALUES (1631, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 23:04:17');
INSERT INTO `userscoresnapshotledger` VALUES (1632, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 23:06:06');
INSERT INTO `userscoresnapshotledger` VALUES (1633, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 23:08:06');
INSERT INTO `userscoresnapshotledger` VALUES (1634, 'test01', 0, 14, 974199, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 23:21:38');
INSERT INTO `userscoresnapshotledger` VALUES (1635, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 23:24:24');
INSERT INTO `userscoresnapshotledger` VALUES (1636, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 23:28:01');
INSERT INTO `userscoresnapshotledger` VALUES (1637, 'test01', 47, 11, 0, 974199, 974199, 0, 'SNAPSHOT_SAVE', '2026-07-01 23:29:29');
INSERT INTO `userscoresnapshotledger` VALUES (1638, 'test01', 47, 11, 974199, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 23:29:33');
INSERT INTO `userscoresnapshotledger` VALUES (1639, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 23:29:38');
INSERT INTO `userscoresnapshotledger` VALUES (1640, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 23:46:06');
INSERT INTO `userscoresnapshotledger` VALUES (1641, 'test01', 0, 15, 974199, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 23:46:25');
INSERT INTO `userscoresnapshotledger` VALUES (1642, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 23:59:12');
INSERT INTO `userscoresnapshotledger` VALUES (1643, 'test01', 47, 5, 0, 974199, 974199, 0, 'SNAPSHOT_SAVE', '2026-07-01 23:59:27');
INSERT INTO `userscoresnapshotledger` VALUES (1644, 'test01', 47, 5, 974199, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-01 23:59:31');
INSERT INTO `userscoresnapshotledger` VALUES (1645, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-01 23:59:33');
INSERT INTO `userscoresnapshotledger` VALUES (1646, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-02 00:00:27');
INSERT INTO `userscoresnapshotledger` VALUES (1647, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-02 00:00:33');
INSERT INTO `userscoresnapshotledger` VALUES (1648, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-02 00:00:41');
INSERT INTO `userscoresnapshotledger` VALUES (1649, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-02 00:00:47');
INSERT INTO `userscoresnapshotledger` VALUES (1650, 'test01', 0, 12, 974199, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-02 11:02:26');
INSERT INTO `userscoresnapshotledger` VALUES (1651, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-02 11:48:53');
INSERT INTO `userscoresnapshotledger` VALUES (1652, 'test01', 29, 4, 974199, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-02 11:49:17');
INSERT INTO `userscoresnapshotledger` VALUES (1653, 'test01', 54, 0, 974199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-02 13:59:04');
INSERT INTO `userscoresnapshotledger` VALUES (1654, 'test01', 47, 4, 0, 974199, 974199, 0, 'SNAPSHOT_SAVE', '2026-07-02 13:59:33');
INSERT INTO `userscoresnapshotledger` VALUES (1655, 'test01', 47, 4, 0, 974199, 974199, 0, 'SNAPSHOT_SAVE', '2026-07-02 13:59:47');
INSERT INTO `userscoresnapshotledger` VALUES (1656, 'test01', 47, 4, 0, 974158, 974158, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:00:40');
INSERT INTO `userscoresnapshotledger` VALUES (1657, 'test01', 47, 4, 0, 974111, 974111, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:01:09');
INSERT INTO `userscoresnapshotledger` VALUES (1658, 'test01', 47, 4, 974111, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:01:22');
INSERT INTO `userscoresnapshotledger` VALUES (1659, 'test01', 19, 5, 0, 974111, 974111, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:18');
INSERT INTO `userscoresnapshotledger` VALUES (1660, 'test01', 19, 5, 0, 974106, 974106, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:29');
INSERT INTO `userscoresnapshotledger` VALUES (1661, 'test01', 19, 5, 0, 974101, 974101, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:30');
INSERT INTO `userscoresnapshotledger` VALUES (1662, 'test01', 19, 5, 0, 974201, 974201, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:30');
INSERT INTO `userscoresnapshotledger` VALUES (1663, 'test01', 19, 5, 0, 974196, 974196, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:30');
INSERT INTO `userscoresnapshotledger` VALUES (1664, 'test01', 19, 5, 0, 974346, 974346, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:30');
INSERT INTO `userscoresnapshotledger` VALUES (1665, 'test01', 19, 5, 0, 974341, 974341, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:30');
INSERT INTO `userscoresnapshotledger` VALUES (1666, 'test01', 19, 5, 0, 974336, 974336, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:30');
INSERT INTO `userscoresnapshotledger` VALUES (1667, 'test01', 19, 5, 0, 974331, 974331, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:31');
INSERT INTO `userscoresnapshotledger` VALUES (1668, 'test01', 19, 5, 0, 974831, 974831, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:31');
INSERT INTO `userscoresnapshotledger` VALUES (1669, 'test01', 19, 5, 0, 974891, 974891, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:31');
INSERT INTO `userscoresnapshotledger` VALUES (1670, 'test01', 19, 5, 0, 974886, 974886, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:31');
INSERT INTO `userscoresnapshotledger` VALUES (1671, 'test01', 19, 5, 0, 974936, 974936, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:31');
INSERT INTO `userscoresnapshotledger` VALUES (1672, 'test01', 19, 5, 0, 974931, 974931, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:31');
INSERT INTO `userscoresnapshotledger` VALUES (1673, 'test01', 19, 5, 0, 974926, 974926, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:31');
INSERT INTO `userscoresnapshotledger` VALUES (1674, 'test01', 19, 5, 0, 974976, 974976, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:31');
INSERT INTO `userscoresnapshotledger` VALUES (1675, 'test01', 19, 5, 0, 974971, 974971, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:32');
INSERT INTO `userscoresnapshotledger` VALUES (1676, 'test01', 19, 5, 0, 974966, 974966, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:32');
INSERT INTO `userscoresnapshotledger` VALUES (1677, 'test01', 19, 5, 0, 974961, 974961, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:32');
INSERT INTO `userscoresnapshotledger` VALUES (1678, 'test01', 19, 5, 0, 974971, 974971, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:32');
INSERT INTO `userscoresnapshotledger` VALUES (1679, 'test01', 19, 5, 0, 974966, 974966, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:32');
INSERT INTO `userscoresnapshotledger` VALUES (1680, 'test01', 19, 5, 0, 974981, 974981, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:33');
INSERT INTO `userscoresnapshotledger` VALUES (1681, 'test01', 19, 5, 0, 975041, 975041, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:33');
INSERT INTO `userscoresnapshotledger` VALUES (1682, 'test01', 19, 5, 0, 975066, 975066, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:33');
INSERT INTO `userscoresnapshotledger` VALUES (1683, 'test01', 19, 5, 0, 975061, 975061, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:33');
INSERT INTO `userscoresnapshotledger` VALUES (1684, 'test01', 19, 5, 0, 975056, 975056, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:33');
INSERT INTO `userscoresnapshotledger` VALUES (1685, 'test01', 19, 5, 0, 975146, 975146, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:33');
INSERT INTO `userscoresnapshotledger` VALUES (1686, 'test01', 19, 5, 0, 975191, 975191, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:33');
INSERT INTO `userscoresnapshotledger` VALUES (1687, 'test01', 19, 5, 0, 975186, 975186, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:33');
INSERT INTO `userscoresnapshotledger` VALUES (1688, 'test01', 19, 5, 0, 975261, 975261, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:33');
INSERT INTO `userscoresnapshotledger` VALUES (1689, 'test01', 19, 5, 0, 975256, 975256, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:33');
INSERT INTO `userscoresnapshotledger` VALUES (1690, 'test01', 19, 5, 0, 975251, 975251, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:34');
INSERT INTO `userscoresnapshotledger` VALUES (1691, 'test01', 19, 5, 0, 975261, 975261, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:34');
INSERT INTO `userscoresnapshotledger` VALUES (1692, 'test01', 19, 5, 0, 975361, 975361, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:34');
INSERT INTO `userscoresnapshotledger` VALUES (1693, 'test01', 19, 5, 0, 975356, 975356, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:34');
INSERT INTO `userscoresnapshotledger` VALUES (1694, 'test01', 19, 5, 0, 977816, 977816, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:34');
INSERT INTO `userscoresnapshotledger` VALUES (1695, 'test01', 19, 5, 0, 977811, 977811, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:34');
INSERT INTO `userscoresnapshotledger` VALUES (1696, 'test01', 19, 5, 0, 977806, 977806, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:35');
INSERT INTO `userscoresnapshotledger` VALUES (1697, 'test01', 19, 5, 0, 977801, 977801, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:35');
INSERT INTO `userscoresnapshotledger` VALUES (1698, 'test01', 19, 5, 0, 977811, 977811, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:35');
INSERT INTO `userscoresnapshotledger` VALUES (1699, 'test01', 19, 5, 0, 977806, 977806, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:35');
INSERT INTO `userscoresnapshotledger` VALUES (1700, 'test01', 19, 5, 0, 977801, 977801, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:35');
INSERT INTO `userscoresnapshotledger` VALUES (1701, 'test01', 19, 5, 0, 977796, 977796, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:35');
INSERT INTO `userscoresnapshotledger` VALUES (1702, 'test01', 19, 5, 0, 977791, 977791, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:36');
INSERT INTO `userscoresnapshotledger` VALUES (1703, 'test01', 19, 5, 0, 977786, 977786, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:36');
INSERT INTO `userscoresnapshotledger` VALUES (1704, 'test01', 19, 5, 0, 977876, 977876, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:36');
INSERT INTO `userscoresnapshotledger` VALUES (1705, 'test01', 19, 5, 0, 978886, 978886, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:36');
INSERT INTO `userscoresnapshotledger` VALUES (1706, 'test01', 19, 5, 0, 978881, 978881, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:36');
INSERT INTO `userscoresnapshotledger` VALUES (1707, 'test01', 19, 5, 0, 978916, 978916, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:36');
INSERT INTO `userscoresnapshotledger` VALUES (1708, 'test01', 19, 5, 0, 978911, 978911, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:36');
INSERT INTO `userscoresnapshotledger` VALUES (1709, 'test01', 19, 5, 0, 978906, 978906, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:36');
INSERT INTO `userscoresnapshotledger` VALUES (1710, 'test01', 19, 5, 0, 978901, 978901, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:37');
INSERT INTO `userscoresnapshotledger` VALUES (1711, 'test01', 19, 5, 0, 979001, 979001, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:37');
INSERT INTO `userscoresnapshotledger` VALUES (1712, 'test01', 19, 5, 0, 979061, 979061, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:37');
INSERT INTO `userscoresnapshotledger` VALUES (1713, 'test01', 19, 5, 0, 979056, 979056, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:37');
INSERT INTO `userscoresnapshotledger` VALUES (1714, 'test01', 19, 5, 0, 979556, 979556, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:37');
INSERT INTO `userscoresnapshotledger` VALUES (1715, 'test01', 19, 5, 0, 979551, 979551, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:38');
INSERT INTO `userscoresnapshotledger` VALUES (1716, 'test01', 19, 5, 0, 980421, 980421, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:38');
INSERT INTO `userscoresnapshotledger` VALUES (1717, 'test01', 19, 5, 0, 980416, 980416, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:38');
INSERT INTO `userscoresnapshotledger` VALUES (1718, 'test01', 19, 5, 0, 980411, 980411, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:38');
INSERT INTO `userscoresnapshotledger` VALUES (1719, 'test01', 19, 5, 0, 980711, 980711, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:38');
INSERT INTO `userscoresnapshotledger` VALUES (1720, 'test01', 19, 5, 0, 980706, 980706, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:39');
INSERT INTO `userscoresnapshotledger` VALUES (1721, 'test01', 19, 5, 0, 981206, 981206, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:39');
INSERT INTO `userscoresnapshotledger` VALUES (1722, 'test01', 19, 5, 0, 981201, 981201, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:40');
INSERT INTO `userscoresnapshotledger` VALUES (1723, 'test01', 19, 5, 0, 981291, 981291, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:40');
INSERT INTO `userscoresnapshotledger` VALUES (1724, 'test01', 19, 5, 0, 981301, 981301, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:40');
INSERT INTO `userscoresnapshotledger` VALUES (1725, 'test01', 19, 5, 0, 981296, 981296, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:40');
INSERT INTO `userscoresnapshotledger` VALUES (1726, 'test01', 19, 5, 0, 981346, 981346, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:40');
INSERT INTO `userscoresnapshotledger` VALUES (1727, 'test01', 19, 5, 0, 981341, 981341, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:40');
INSERT INTO `userscoresnapshotledger` VALUES (1728, 'test01', 19, 5, 0, 981336, 981336, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:40');
INSERT INTO `userscoresnapshotledger` VALUES (1729, 'test01', 19, 5, 0, 981426, 981426, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:40');
INSERT INTO `userscoresnapshotledger` VALUES (1730, 'test01', 19, 5, 0, 981421, 981421, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:41');
INSERT INTO `userscoresnapshotledger` VALUES (1731, 'test01', 19, 5, 0, 981546, 981546, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:41');
INSERT INTO `userscoresnapshotledger` VALUES (1732, 'test01', 19, 5, 0, 981581, 981581, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:41');
INSERT INTO `userscoresnapshotledger` VALUES (1733, 'test01', 19, 5, 0, 981576, 981576, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:41');
INSERT INTO `userscoresnapshotledger` VALUES (1734, 'test01', 19, 5, 0, 981571, 981571, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:41');
INSERT INTO `userscoresnapshotledger` VALUES (1735, 'test01', 19, 5, 0, 981606, 981606, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:41');
INSERT INTO `userscoresnapshotledger` VALUES (1736, 'test01', 19, 5, 0, 981601, 981601, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:41');
INSERT INTO `userscoresnapshotledger` VALUES (1737, 'test01', 19, 5, 0, 981596, 981596, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:41');
INSERT INTO `userscoresnapshotledger` VALUES (1738, 'test01', 19, 5, 0, 981696, 981696, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:42');
INSERT INTO `userscoresnapshotledger` VALUES (1739, 'test01', 19, 5, 0, 981691, 981691, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:42');
INSERT INTO `userscoresnapshotledger` VALUES (1740, 'test01', 19, 5, 0, 981726, 981726, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:42');
INSERT INTO `userscoresnapshotledger` VALUES (1741, 'test01', 19, 5, 0, 981721, 981721, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:42');
INSERT INTO `userscoresnapshotledger` VALUES (1742, 'test01', 19, 5, 0, 981716, 981716, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:42');
INSERT INTO `userscoresnapshotledger` VALUES (1743, 'test01', 19, 5, 0, 981711, 981711, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:42');
INSERT INTO `userscoresnapshotledger` VALUES (1744, 'test01', 19, 5, 0, 981706, 981706, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:43');
INSERT INTO `userscoresnapshotledger` VALUES (1745, 'test01', 19, 5, 0, 981701, 981701, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:43');
INSERT INTO `userscoresnapshotledger` VALUES (1746, 'test01', 19, 5, 0, 981716, 981716, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:43');
INSERT INTO `userscoresnapshotledger` VALUES (1747, 'test01', 19, 5, 0, 981726, 981726, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:43');
INSERT INTO `userscoresnapshotledger` VALUES (1748, 'test01', 19, 5, 0, 981721, 981721, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:43');
INSERT INTO `userscoresnapshotledger` VALUES (1749, 'test01', 19, 5, 0, 982591, 982591, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:43');
INSERT INTO `userscoresnapshotledger` VALUES (1750, 'test01', 19, 5, 0, 982641, 982641, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:43');
INSERT INTO `userscoresnapshotledger` VALUES (1751, 'test01', 19, 5, 0, 982636, 982636, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:43');
INSERT INTO `userscoresnapshotledger` VALUES (1752, 'test01', 19, 5, 0, 983136, 983136, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:44');
INSERT INTO `userscoresnapshotledger` VALUES (1753, 'test01', 19, 5, 0, 983131, 983131, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:44');
INSERT INTO `userscoresnapshotledger` VALUES (1754, 'test01', 19, 5, 0, 983166, 983166, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:44');
INSERT INTO `userscoresnapshotledger` VALUES (1755, 'test01', 19, 5, 0, 983161, 983161, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:44');
INSERT INTO `userscoresnapshotledger` VALUES (1756, 'test01', 19, 5, 0, 983221, 983221, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:44');
INSERT INTO `userscoresnapshotledger` VALUES (1757, 'test01', 19, 5, 0, 983216, 983216, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:44');
INSERT INTO `userscoresnapshotledger` VALUES (1758, 'test01', 19, 5, 0, 983261, 983261, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:45');
INSERT INTO `userscoresnapshotledger` VALUES (1759, 'test01', 19, 5, 0, 983256, 983256, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:45');
INSERT INTO `userscoresnapshotledger` VALUES (1760, 'test01', 19, 5, 0, 983456, 983456, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:45');
INSERT INTO `userscoresnapshotledger` VALUES (1761, 'test01', 19, 5, 0, 983451, 983451, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:46');
INSERT INTO `userscoresnapshotledger` VALUES (1762, 'test01', 19, 5, 0, 983481, 983481, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:46');
INSERT INTO `userscoresnapshotledger` VALUES (1763, 'test01', 19, 5, 0, 983476, 983476, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:46');
INSERT INTO `userscoresnapshotledger` VALUES (1764, 'test01', 19, 5, 983476, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:02:46');
INSERT INTO `userscoresnapshotledger` VALUES (1765, 'test01', 10, 6, 0, 983476, 983476, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:04:47');
INSERT INTO `userscoresnapshotledger` VALUES (1766, 'test01', 10, 6, 0, 983461, 983461, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:05:00');
INSERT INTO `userscoresnapshotledger` VALUES (1767, 'test01', 10, 6, 983461, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:05:03');
INSERT INTO `userscoresnapshotledger` VALUES (1768, 'test01', 54, 0, 983461, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-02 14:05:05');
INSERT INTO `userscoresnapshotledger` VALUES (1769, 'test01', 54, 0, 983461, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-02 14:06:30');
INSERT INTO `userscoresnapshotledger` VALUES (1770, 'test01', 54, 0, 983461, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-02 14:20:04');
INSERT INTO `userscoresnapshotledger` VALUES (1771, 'test01', 54, 0, 983461, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-02 14:20:09');
INSERT INTO `userscoresnapshotledger` VALUES (1772, 'test01', 54, 0, 983461, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-02 14:24:51');
INSERT INTO `userscoresnapshotledger` VALUES (1773, 'test01', 0, 14, 983461, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:28:53');
INSERT INTO `userscoresnapshotledger` VALUES (1774, 'test01', 29, 1, 0, 983461, 983461, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:34:53');
INSERT INTO `userscoresnapshotledger` VALUES (1775, 'test01', 29, 1, 983461, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:35:00');
INSERT INTO `userscoresnapshotledger` VALUES (1776, 'test01', 54, 0, 983461, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-02 14:35:01');
INSERT INTO `userscoresnapshotledger` VALUES (1777, 'test01', 29, 4, 0, 983461, 983461, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:37:10');
INSERT INTO `userscoresnapshotledger` VALUES (1778, 'test01', 29, 4, 0, 983388, 983388, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:37:23');
INSERT INTO `userscoresnapshotledger` VALUES (1779, 'test01', 29, 4, 983388, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:37:47');
INSERT INTO `userscoresnapshotledger` VALUES (1780, 'test01', 54, 0, 983388, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-02 14:37:49');
INSERT INTO `userscoresnapshotledger` VALUES (1781, 'test01', 47, 5, 0, 983388, 983388, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:38:00');
INSERT INTO `userscoresnapshotledger` VALUES (1782, 'test01', 47, 5, 983388, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-02 14:38:05');
INSERT INTO `userscoresnapshotledger` VALUES (1783, 'test01', 54, 0, 983388, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-02 14:38:07');

-- ----------------------------
-- Table structure for videogamecoinrecord
-- ----------------------------
DROP TABLE IF EXISTS `videogamecoinrecord`;
CREATE TABLE `videogamecoinrecord`  (
  `ID` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '玩家账号',
  `TRADEID` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '订单信息',
  `ERRORCODE` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `SRCCOIN` int(11) NULL DEFAULT NULL,
  `DSTCOIN` int(11) NULL DEFAULT NULL,
  `STATUS` int(11) NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of videogamecoinrecord
-- ----------------------------

-- ----------------------------
-- View structure for v_manageroptwithusers
-- ----------------------------
DROP VIEW IF EXISTS `v_manageroptwithusers`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_manageroptwithusers` AS select `t2`.`UserID` AS `UserID`,`t2`.`NAME` AS `NAME`,`t2`.`Opt` AS `Opt`,`t2`.`OptValue` AS `OptValue`,`t2`.`Type` AS `Type`,`t2`.`TIME` AS `TIME`,`t1`.`AGENCY` AS `AGENCY` from (`users` `t1` join `manageropt` `t2` on((`t1`.`ID` = `t2`.`UserID`)));

-- ----------------------------
-- Procedure structure for findOrgChildList
-- ----------------------------
DROP PROCEDURE IF EXISTS `findOrgChildList`;
delimiter ;;
CREATE PROCEDURE `findOrgChildList`(IN orgId VARCHAR(20))
BEGIN
  DECLARE v_org VARCHAR(20) DEFAULT '';
  DECLARE done INTEGER DEFAULT 0;
  DECLARE C_org CURSOR FOR SELECT d.id FROM `admin` d WHERE d.AGENCY = orgId;
  DECLARE CONTINUE HANDLER FOR NOT found SET done = 1;
  set max_sp_recursion_depth  = 50;

  INSERT INTO tmp_org VALUES (orgId);
  OPEN C_org;
  FETCH C_org INTO v_org;
  WHILE (done=0)
  DO
    CALL findOrgChildList(v_org);
    FETCH C_org INTO v_org;
  END WHILE;
  CLOSE C_org;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for findOrgList
-- ----------------------------
DROP PROCEDURE IF EXISTS `findOrgList`;
delimiter ;;
CREATE PROCEDURE `findOrgList`(IN orgId VARCHAR(20))
BEGIN
  DROP TEMPORARY TABLE IF EXISTS tmp_org;
    CREATE TEMPORARY TABLE tmp_org(org_id VARCHAR(20) CHARSET utf8  COLLATE utf8_general_ci);
    DELETE FROM tmp_org;
    CALL findOrgChildList(orgId);
    SELECT org_id FROM tmp_org ORDER BY org_id;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for prc_CreateNotice
-- ----------------------------
DROP PROCEDURE IF EXISTS `prc_CreateNotice`;
delimiter ;;
CREATE PROCEDURE `prc_CreateNotice`(P_ID VARCHAR(20),
	P_Notice VARCHAR(200),
	OUT P_RowCnt INT)
  COMMENT '添加公告'
BEGIN
	SET P_RowCnt = 0;

	INSERT INTO Notice(ID,Notice) 
	SELECT ID,Notice 
	FROM Admin
	WHERE AGENCY = ID 
		AND ID NOT IN(SELECT ID FROM Notice) 
		AND ID != P_ID;
	SET P_RowCnt = P_RowCnt + FOUND_ROWS();
	
	UPDATE Notice 
	SET Notice = Notice 
	WHERE ID IN (SELECT ID FROM Admin WHERE AGENCY = P_ID);
	SET P_RowCnt = P_RowCnt + FOUND_ROWS();
	
END
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
