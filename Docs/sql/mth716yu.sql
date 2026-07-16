/*
 Navicat Premium Data Transfer

 Source Server         : 127.0.0.1
 Source Server Type    : MySQL
 Source Server Version : 50744
 Source Host           : localhost:3306
 Source Schema         : mth

 Target Server Type    : MySQL
 Target Server Version : 50744
 File Encoding         : 65001

 Date: 16/07/2026 14:31:45
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
INSERT INTO `admin` VALUES ('admin', '123456', 0, '', 0, 2684992870, 111021886, 0, 0, 1, 6, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, NULL, 0.00, 'www.baidu.com', '2026-04-15 16:49:42', '2026-07-14 17:55:01', 0, 0, 0, 0, 1, 1);

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
) ENGINE = InnoDB AUTO_INCREMENT = 280 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '代理日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of agencyoptlog
-- ----------------------------
INSERT INTO `agencyoptlog` VALUES (150, 'admin', '超级管理', 'admin', '超级管理', '2026-07-08 10:02:34', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (151, 'admin', '超级管理', 'admin', '超级管理', '2026-07-08 13:49:12', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (152, 'admin', '超级管理', 'test002', '用户', '2026-07-08 17:18:29', 20, 100000, 0, 100000, 28);
INSERT INTO `agencyoptlog` VALUES (153, 'admin', '超级管理', 'admin', '超级管理', '2026-07-08 18:08:04', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (154, 'admin', '超级管理', 'admin', '超级管理', '2026-07-08 18:44:13', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (155, 'admin', '超级管理', 'admin', '超级管理', '2026-07-08 18:48:03', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (156, 'admin', '超级管理', 'admin', '超级管理', '2026-07-08 18:49:32', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (157, 'admin', '超级管理', 'admin', '超级管理', '2026-07-08 19:12:11', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (158, 'admin', '超级管理', 'admin', '超级管理', '2026-07-08 19:45:48', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (159, 'admin', '超级管理', 'admin', '超级管理', '2026-07-09 09:44:40', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (160, 'admin', '超级管理', 'test03', '用户', '2026-07-09 09:46:46', 20, 155465, 0, 155465, 28);
INSERT INTO `agencyoptlog` VALUES (161, 'admin', '超级管理', 'test03', '用户', '2026-07-09 09:47:09', 20, 155465, 155465, 310930, 28);
INSERT INTO `agencyoptlog` VALUES (162, 'admin', '超级管理', 'admin', '超级管理', '2026-07-09 11:41:16', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (163, 'admin', '超级管理', 'admin', '超级管理', '2026-07-09 12:56:21', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (164, 'admin', '超级管理', 'admin', '超级管理', '2026-07-09 13:06:04', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (165, 'admin', '超级管理', 'admin', '超级管理', '2026-07-09 13:29:00', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (166, 'admin', '超级管理', 'admin', '超级管理', '2026-07-09 14:13:17', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (167, 'admin', '超级管理', 'admin', '超级管理', '2026-07-09 14:28:48', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (168, 'admin', '超级管理', 'admin', '超级管理', '2026-07-09 15:06:15', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (169, 'admin', '超级管理', 'admin', '超级管理', '2026-07-09 15:27:43', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (170, 'admin', '超级管理', 'admin', '超级管理', '2026-07-09 16:04:20', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (171, 'admin', '超级管理', 'admin', '超级管理', '2026-07-09 16:09:37', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (172, 'admin', '超级管理', 'admin', '超级管理', '2026-07-09 16:11:57', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (173, 'admin', '超级管理', 'admin', '超级管理', '2026-07-09 16:12:39', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (174, 'admin', '超级管理', 'admin', '超级管理', '2026-07-09 16:20:14', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (175, 'admin', '超级管理', 'admin', '超级管理', '2026-07-09 16:28:05', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (176, 'admin', '超级管理', 'admin', '超级管理', '2026-07-09 17:38:02', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (177, 'admin', '超级管理', 'admin', '超级管理', '2026-07-10 09:59:38', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (178, 'admin', '超级管理', 'admin', '超级管理', '2026-07-10 11:37:21', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (179, 'admin', '超级管理', 'admin', '超级管理', '2026-07-10 12:09:07', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (180, 'admin', '超级管理', 'admin', '超级管理', '2026-07-10 14:06:20', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (181, 'admin', '超级管理', 'admin', '超级管理', '2026-07-10 14:32:10', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (182, 'admin', '超级管理', 'admin', '超级管理', '2026-07-10 14:40:06', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (183, 'admin', '超级管理', 'admin', '超级管理', '2026-07-10 14:43:59', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (184, 'admin', '超级管理', 'admin', '超级管理', '2026-07-10 14:58:02', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (185, 'admin', '超级管理', 'admin', '超级管理', '2026-07-10 15:25:34', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (186, 'admin', '超级管理', 'admin', '超级管理', '2026-07-10 15:51:53', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (187, 'admin', '超级管理', 'admin', '超级管理', '2026-07-10 15:57:35', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (188, 'admin', '超级管理', 'admin', '超级管理', '2026-07-10 16:20:23', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (189, 'admin', '超级管理', 'admin', '超级管理', '2026-07-10 16:35:27', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (190, 'admin', '超级管理', 'admin', '超级管理', '2026-07-10 16:48:44', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (191, 'admin', '超级管理', 'admin', '超级管理', '2026-07-10 16:53:26', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (192, 'admin', '超级管理', 'admin', '超级管理', '2026-07-10 17:07:40', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (193, 'admin', '超级管理', 'admin', '超级管理', '2026-07-10 19:39:13', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (194, 'admin', '超级管理', 'admin', '超级管理', '2026-07-10 19:47:22', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (195, 'admin', '超级管理', 'admin', '超级管理', '2026-07-10 19:47:22', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (196, 'admin', '超级管理', 'admin', '超级管理', '2026-07-10 20:02:33', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (197, 'admin', '超级管理', 'admin', '超级管理', '2026-07-10 20:18:19', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (198, 'admin', '超级管理', 'admin', '超级管理', '2026-07-10 20:34:11', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (199, 'admin', '超级管理', 'admin', '超级管理', '2026-07-10 20:38:59', 2, 0, 0, 0, 28);
INSERT INTO `agencyoptlog` VALUES (200, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 09:34:44', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (201, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 10:47:59', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (202, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 10:55:12', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (203, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 11:24:14', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (204, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 11:34:30', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (205, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 11:38:04', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (206, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 11:43:24', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (207, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 11:49:43', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (208, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 11:58:58', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (209, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 12:03:32', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (210, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 12:05:07', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (211, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 13:40:38', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (212, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 13:45:50', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (213, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 13:48:40', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (214, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 13:52:49', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (215, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 14:12:07', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (216, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 14:26:16', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (217, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 14:35:59', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (218, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 14:40:25', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (219, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 14:43:57', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (220, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 14:49:28', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (221, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 15:25:58', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (222, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 15:37:40', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (223, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 15:40:44', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (224, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 15:45:16', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (225, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 15:48:38', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (226, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 16:07:04', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (227, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 16:32:50', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (228, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 16:36:28', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (229, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 17:34:32', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (230, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 17:47:18', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (231, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 18:42:36', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (232, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 19:10:40', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (233, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 19:15:10', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (234, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 19:18:02', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (235, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 19:26:26', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (236, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 19:38:26', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (237, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 19:44:30', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (238, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 19:52:37', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (239, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 19:57:04', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (240, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 20:01:54', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (241, 'admin', '超级管理', 'admin', '超级管理', '2026-07-13 20:08:47', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (242, 'admin', '超级管理', 'admin', '超级管理', '2026-07-14 10:38:43', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (243, 'admin', '超级管理', 'test01', '用户', '2026-07-14 10:39:08', 20, 151533, 1018531, 1170064, 29);
INSERT INTO `agencyoptlog` VALUES (244, 'admin', '超级管理', 'admin', '超级管理', '2026-07-14 11:11:01', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (245, 'admin', '超级管理', 'admin', '超级管理', '2026-07-14 11:16:58', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (246, 'admin', '超级管理', 'admin', '超级管理', '2026-07-14 11:31:38', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (247, 'admin', '超级管理', 'admin', '超级管理', '2026-07-14 11:37:52', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (248, 'admin', '超级管理', 'admin', '超级管理', '2026-07-14 11:47:45', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (249, 'admin', '超级管理', 'admin', '超级管理', '2026-07-14 14:33:32', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (250, 'admin', '超级管理', 'test01', '用户', '2026-07-14 14:40:24', 20, 4501113, 0, 4501113, 29);
INSERT INTO `agencyoptlog` VALUES (251, 'admin', '超级管理', 'test01', '用户', '2026-07-14 14:40:27', 20, 4501113, 4501113, 9002226, 29);
INSERT INTO `agencyoptlog` VALUES (252, 'admin', '超级管理', 'test01', '用户', '2026-07-14 14:46:21', 20, 455564, 0, 455564, 29);
INSERT INTO `agencyoptlog` VALUES (253, 'admin', '超级管理', 'admin', '超级管理', '2026-07-14 15:28:51', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (254, 'admin', '超级管理', 'admin', '超级管理', '2026-07-14 17:12:58', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (255, 'admin', '超级管理', 'test01', '用户', '2026-07-14 17:15:22', 20, 1415552, 0, 1415552, 29);
INSERT INTO `agencyoptlog` VALUES (256, 'admin', '超级管理', 'admin', '超级管理', '2026-07-14 17:38:22', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (257, 'admin', '超级管理', 'test01', '用户', '2026-07-14 17:38:33', 20, 65621, 0, 65621, 29);
INSERT INTO `agencyoptlog` VALUES (258, 'admin', '超级管理', 'test002', '用户', '2026-07-14 17:55:02', 20, 454564, 0, 454564, 29);
INSERT INTO `agencyoptlog` VALUES (259, 'admin', '超级管理', 'admin', '超级管理', '2026-07-14 18:15:26', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (260, 'admin', '超级管理', 'admin', '超级管理', '2026-07-14 18:46:14', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (261, 'admin', '超级管理', 'admin', '超级管理', '2026-07-15 09:49:37', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (262, 'admin', '超级管理', 'admin', '超级管理', '2026-07-15 10:31:31', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (263, 'admin', '超级管理', 'admin', '超级管理', '2026-07-15 14:03:21', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (264, 'admin', '超级管理', 'admin', '超级管理', '2026-07-15 14:27:35', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (265, 'admin', '超级管理', 'admin', '超级管理', '2026-07-15 14:36:38', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (266, 'admin', '超级管理', 'admin', '超级管理', '2026-07-15 14:41:49', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (267, 'admin', '超级管理', 'admin', '超级管理', '2026-07-15 14:46:33', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (268, 'admin', '超级管理', 'admin', '超级管理', '2026-07-15 14:52:20', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (269, 'admin', '超级管理', 'admin', '超级管理', '2026-07-15 15:35:16', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (270, 'admin', '超级管理', 'admin', '超级管理', '2026-07-15 16:13:20', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (271, 'admin', '超级管理', 'admin', '超级管理', '2026-07-15 16:33:28', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (272, 'admin', '超级管理', 'admin', '超级管理', '2026-07-15 16:43:06', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (273, 'admin', '超级管理', 'admin', '超级管理', '2026-07-15 16:45:12', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (274, 'admin', '超级管理', 'admin', '超级管理', '2026-07-15 16:47:38', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (275, 'admin', '超级管理', 'admin', '超级管理', '2026-07-15 16:49:53', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (276, 'admin', '超级管理', 'admin', '超级管理', '2026-07-16 10:27:15', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (277, 'admin', '超级管理', 'admin', '超级管理', '2026-07-16 14:03:07', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (278, 'admin', '超级管理', 'admin', '超级管理', '2026-07-16 14:10:45', 2, 0, 0, 0, 29);
INSERT INTO `agencyoptlog` VALUES (279, 'admin', '超级管理', 'admin', '超级管理', '2026-07-16 14:13:11', 2, 0, 0, 0, 29);

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
) ENGINE = InnoDB AUTO_INCREMENT = 49 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '牌机出货与库存配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cardpayoutprofile
-- ----------------------------
INSERT INTO `cardpayoutprofile` VALUES (37, 5, 0, 0, 4, 500, 0, 0, 1);
INSERT INTO `cardpayoutprofile` VALUES (38, 5, 0, 1, 0, 2000, 0, 0, 1);
INSERT INTO `cardpayoutprofile` VALUES (39, 5, 0, 2, 2, 10, 0, 0, 1);
INSERT INTO `cardpayoutprofile` VALUES (40, 5, 0, 3, 3, 500, 0, 0, 1);
INSERT INTO `cardpayoutprofile` VALUES (41, 5, 0, 4, 5, 400, 0, 0, 1);
INSERT INTO `cardpayoutprofile` VALUES (42, 5, 0, 5, 2, 60, 0, 0, 1);
INSERT INTO `cardpayoutprofile` VALUES (43, 5, 0, 6, 15, 20, 0, 0, 1);
INSERT INTO `cardpayoutprofile` VALUES (44, 5, 0, 7, 65, 10, 0, 0, 1);
INSERT INTO `cardpayoutprofile` VALUES (45, 5, 0, 8, 65, 0, 0, 0, 1);
INSERT INTO `cardpayoutprofile` VALUES (46, 5, 0, 9, 150, 5, 0, 0, 1);
INSERT INTO `cardpayoutprofile` VALUES (47, 5, 0, 10, 500, 2, 0, 0, 1);
INSERT INTO `cardpayoutprofile` VALUES (48, 5, 0, 11, 250, 4, 0, 0, 1);

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
DROP TABLE IF EXISTS `gameacclaba`;
CREATE TABLE `gameacclaba`  (
  `GameId` int(11) NOT NULL,
  `Stock` int(11) NULL DEFAULT NULL,
  `MiniJackpot` int(11) NULL DEFAULT NULL,
  `MidJackpot` int(11) NULL DEFAULT NULL,
  `LargeJackpot` int(11) NULL DEFAULT NULL,
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
INSERT INTO `gamecommandoutbox` VALUES ('06e86b145c5a4faeb104d6193099ee01', 'UC', 'test002', '{\"Args\":[\"07\",\"000000001000\",\"0000\",\"test002\"]}', 3, 'UCER', '服务器内部错误。(UCER)', 5, '2026-07-13 11:54:06', '2026-07-13 12:02:48', '2026-07-13 12:02:48', '2026-07-13 12:06:58', '2026-07-13 12:02:48');
INSERT INTO `gamecommandoutbox` VALUES ('0852b76be7234a139b9c42b8862ec6bd', 'UC', 'test002', '{\"Args\":[\"27\",\"09\",0,\"test002\"]}', 3, NULL, '数据发送失败！管道尚未连接。', 5, '2026-07-14 11:17:55', '2026-07-14 11:25:47', '2026-07-14 11:25:57', '2026-07-14 11:30:07', '2026-07-14 11:25:57');
INSERT INTO `gamecommandoutbox` VALUES ('09ff024b4e824520a74c4e63ddefa743', 'UC', 'test002', '{\"Args\":[\"01\",\"03\",0,\"test002\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 13:42:00', '2026-07-13 13:53:38', '2026-07-13 13:53:39', '2026-07-13 13:57:49', '2026-07-13 13:53:39');
INSERT INTO `gamecommandoutbox` VALUES ('0c6f1a839a734397800126e46aaa63d3', 'UL', 'test002', '{\"RechargeType\":0,\"Result\":1,\"Coins\":100000,\"UserAccount\":\"test002\"}', 2, 'ULOK', NULL, 0, '2026-07-08 17:18:29', '2026-07-08 17:18:29', '2026-07-08 17:18:29', NULL, '2026-07-08 17:18:30');
INSERT INTO `gamecommandoutbox` VALUES ('0df06b8c76c94c9cb50fd9455a02eed2', 'UC', 'test002', '{\"Args\":[\"01\",\"03\",0,\"test002\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 11:54:06', '2026-07-13 12:02:48', '2026-07-13 12:02:48', '2026-07-13 12:06:58', '2026-07-13 12:02:48');
INSERT INTO `gamecommandoutbox` VALUES ('101e4a136acd44b7bac7c6872d82bd19', 'UC', 'test01', '{\"Args\":[\"01\",\"03\",0,\"test01\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 13:35:14', '2026-07-13 13:46:40', '2026-07-13 13:46:41', '2026-07-13 13:50:51', '2026-07-13 13:46:41');
INSERT INTO `gamecommandoutbox` VALUES ('1190e9cadbd04ab3ae7b3630ada6521f', 'UC', 'test002', '{\"Args\":[\"01\",\"03\",0,\"test002\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 11:52:12', '2026-07-13 11:59:48', '2026-07-13 11:59:48', '2026-07-13 12:03:58', '2026-07-13 11:59:48');
INSERT INTO `gamecommandoutbox` VALUES ('1253ed729f5141d9acce21c7d61c8ec8', 'UC', 'test002', '{\"Args\":[\"07\",\"000000001000\",\"0000\",\"test002\"]}', 3, 'UCER', '服务器内部错误。(UCER)', 5, '2026-07-13 11:50:26', '2026-07-13 11:59:48', '2026-07-13 11:59:48', '2026-07-13 12:03:58', '2026-07-13 11:59:48');
INSERT INTO `gamecommandoutbox` VALUES ('175b35b51644457a8b56c267cc0f8934', 'UC', 'test002', '{\"Args\":[\"03\",\"03\",0,\"test002\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 13:46:04', '2026-07-13 13:53:39', '2026-07-13 13:53:39', '2026-07-13 13:57:49', '2026-07-13 13:53:39');
INSERT INTO `gamecommandoutbox` VALUES ('1fe452cb59184c81b52e1e5572fe3eba', 'UC', 'test002', '{\"Args\":[\"05\",\"00\",\"00\",\"00\",0,\"test002\"]}', 3, 'UCER', '服务器内部错误。(UCER)', 5, '2026-07-13 20:02:45', '2026-07-14 10:42:16', '2026-07-14 10:42:16', '2026-07-14 10:46:26', '2026-07-14 10:42:16');
INSERT INTO `gamecommandoutbox` VALUES ('268f77927b0d4f1eb8cec7ddca3e4319', 'UC', 'test002', '{\"Args\":[\"15\",\"03\",0,\"test002\"]}', 3, 'UCER', '服务器内部错误。(UCER)', 5, '2026-07-13 14:13:40', '2026-07-13 14:26:43', '2026-07-13 14:26:43', '2026-07-13 14:30:53', '2026-07-13 14:26:43');
INSERT INTO `gamecommandoutbox` VALUES ('27c35cfdd35d4dc3b57cbe6af9e4f56c', 'UC', 'test002', '{\"Args\":[\"15\",\"00\",\"01\",\"05\",0,\"test002\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 20:02:16', '2026-07-14 10:39:17', '2026-07-14 10:39:17', '2026-07-14 10:43:27', '2026-07-14 10:39:17');
INSERT INTO `gamecommandoutbox` VALUES ('2c8631b819e64b19ab029ad3766db2cd', 'UC', 'test002', '{\"Args\":[\"-1\",\"00\",\"00\",\"00\",0,\"test002\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 13:41:14', '2026-07-13 13:53:37', '2026-07-13 13:53:37', '2026-07-13 13:57:47', '2026-07-13 13:53:37');
INSERT INTO `gamecommandoutbox` VALUES ('30d397b99831482bb983beda3518eae3', 'UC', 'test002', '{\"Args\":[\"06\",\"04\",\"09\",\"10\",0,\"test002\"]}', 3, NULL, '数据发送失败！管道尚未连接。', 5, '2026-07-14 11:33:21', '2026-07-14 11:41:42', '2026-07-14 11:41:52', '2026-07-14 11:46:02', '2026-07-14 11:41:52');
INSERT INTO `gamecommandoutbox` VALUES ('30f9156a8e014340baab4d79dfd9e713', 'UC', 'test01', '{\"Args\":[\"01\",\"03\",0,\"test01\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 13:37:36', '2026-07-13 13:49:33', '2026-07-13 13:49:33', '2026-07-13 13:53:43', '2026-07-13 13:49:33');
INSERT INTO `gamecommandoutbox` VALUES ('3906179bd8004e478b178496b2bcf994', 'UC', 'test002', '{\"Args\":[\"05\",\"00\",\"00\",\"00\",0,\"test002\"]}', 3, NULL, '数据发送失败！管道尚未连接。', 5, '2026-07-13 20:03:06', '2026-07-14 10:44:16', '2026-07-14 10:44:26', '2026-07-14 10:48:36', '2026-07-14 10:44:26');
INSERT INTO `gamecommandoutbox` VALUES ('441292eb233d49f1b07f3d2aa442964e', 'UL', 'test002', '{\"RechargeType\":0,\"Result\":1,\"Coins\":454564,\"UserAccount\":\"test002\"}', 2, 'ULOK', NULL, 0, '2026-07-14 17:55:02', '2026-07-14 17:55:02', '2026-07-14 17:55:02', NULL, '2026-07-14 17:55:02');
INSERT INTO `gamecommandoutbox` VALUES ('456f4b210311421bab0f2e58f7015647', 'UL', 'test01', '{\"RechargeType\":0,\"Result\":1,\"Coins\":151533,\"UserAccount\":\"test01\"}', 2, 'ULER', NULL, 0, '2026-07-14 10:39:08', '2026-07-14 10:39:10', '2026-07-14 10:39:10', NULL, '2026-07-14 10:39:11');
INSERT INTO `gamecommandoutbox` VALUES ('4905af06d5a24962804a7208ac590957', 'UC', 'test002', '{\"Args\":[\"07\",\"000000001000\",\"0000\",\"test002\"]}', 3, 'UCER', '服务器内部错误。(UCER)', 5, '2026-07-13 11:49:54', '2026-07-13 11:56:32', '2026-07-13 11:56:32', '2026-07-13 12:00:42', '2026-07-13 11:56:32');
INSERT INTO `gamecommandoutbox` VALUES ('4a80e355c2b043878bb1cc2df39a5dee', 'UC', 'test01', '{\"Args\":[\"01\",\"09\",0,\"test01\"]}', 3, NULL, '数据发送失败！管道尚未连接。', 5, '2026-07-13 20:09:44', '2026-07-14 10:44:26', '2026-07-14 10:44:36', '2026-07-14 10:48:46', '2026-07-14 10:44:36');
INSERT INTO `gamecommandoutbox` VALUES ('4f04210a3f8e4b3c8f45c1dd61d1b39b', 'LK', 'test03', '{\"UserAccount\":\"test03\"}', 2, 'LKOK', NULL, 4, '2026-07-09 09:46:59', '2026-07-09 09:55:29', '2026-07-09 09:55:29', NULL, '2026-07-09 09:55:29');
INSERT INTO `gamecommandoutbox` VALUES ('5023e5a6c38c45a2827df50dfc31ac2e', 'UC', 'test03', '{\"Args\":[\"03\",\"03\",0,\"test03\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 13:46:17', '2026-07-13 13:54:36', '2026-07-13 13:54:36', '2026-07-13 13:58:46', '2026-07-13 13:54:36');
INSERT INTO `gamecommandoutbox` VALUES ('506dc32834064266b056ab06f693bfc8', 'UC', 'test002', '{\"Args\":[\"01\",\"03\",0,\"test002\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 11:59:55', '2026-07-13 12:08:01', '2026-07-13 12:08:01', '2026-07-13 12:12:11', '2026-07-13 12:08:01');
INSERT INTO `gamecommandoutbox` VALUES ('51b0b793cb2b4363a98aa7f32cc92e1d', 'LK', 'test01', '{\"UserAccount\":\"test01\"}', 2, 'LKOK', NULL, 0, '2026-07-14 17:15:22', '2026-07-14 17:15:22', '2026-07-14 17:15:22', NULL, '2026-07-14 17:15:22');
INSERT INTO `gamecommandoutbox` VALUES ('537508b78f1b4971af44f83375b9a85b', 'LK', 'test002', '{\"UserAccount\":\"test002\"}', 2, 'LKOK', NULL, 0, '2026-07-08 17:18:29', '2026-07-08 17:18:29', '2026-07-08 17:18:29', NULL, '2026-07-08 17:18:29');
INSERT INTO `gamecommandoutbox` VALUES ('5e8d9e094f1f4dda99880eacfc183a81', 'UC', 'test002', '{\"Args\":[\"27\",\"06\",0,\"test002\"]}', 3, NULL, '数据发送失败！管道尚未连接。', 5, '2026-07-14 11:17:30', '2026-07-14 11:24:47', '2026-07-14 11:24:57', '2026-07-14 11:29:07', '2026-07-14 11:24:57');
INSERT INTO `gamecommandoutbox` VALUES ('5ecf826e20ca4a769401a797fa558831', 'LK', 'test01', '{\"UserAccount\":\"test01\"}', 2, 'LKOK', NULL, 0, '2026-07-14 14:40:24', '2026-07-14 14:40:24', '2026-07-14 14:40:24', NULL, '2026-07-14 14:40:24');
INSERT INTO `gamecommandoutbox` VALUES ('5ed9a3874222490c8790bab111584d65', 'LK', 'test01', '{\"UserAccount\":\"test01\"}', 2, 'LKOK', NULL, 0, '2026-07-14 14:46:21', '2026-07-14 14:46:21', '2026-07-14 14:46:21', NULL, '2026-07-14 14:46:21');
INSERT INTO `gamecommandoutbox` VALUES ('5fc730b0d78a40939ecbfd6e98bd8aa5', 'LK', 'test01', '{\"UserAccount\":\"test01\"}', 2, 'LKOK', NULL, 0, '2026-07-14 10:39:08', '2026-07-14 10:39:08', '2026-07-14 10:39:08', NULL, '2026-07-14 10:39:08');
INSERT INTO `gamecommandoutbox` VALUES ('60239cb0a97e40d28fbc4d4733297f39', 'UC', 'test01', '{\"Args\":[\"01\",\"03\",0,\"test01\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 11:50:30', '2026-07-13 11:59:48', '2026-07-13 11:59:48', '2026-07-13 12:03:58', '2026-07-13 11:59:48');
INSERT INTO `gamecommandoutbox` VALUES ('607727875aa44c868a31d7c66e8f49e0', 'UC', 'test002', '{\"Args\":[\"01\",\"03\",0,\"test002\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 11:49:53', '2026-07-13 11:56:32', '2026-07-13 11:56:32', '2026-07-13 12:00:42', '2026-07-13 11:56:32');
INSERT INTO `gamecommandoutbox` VALUES ('61c5086c089e4e74bd207e212d1176d3', 'UC', 'test002', '{\"Args\":[\"01\",\"06\",0,\"test002\"]}', 3, NULL, '数据发送失败！管道尚未连接。', 5, '2026-07-14 17:13:32', '2026-07-14 17:19:47', '2026-07-14 17:19:57', '2026-07-14 17:24:07', '2026-07-14 17:19:57');
INSERT INTO `gamecommandoutbox` VALUES ('65c10424958b470c979acfda23ec3910', 'UC', 'test03', '{\"Args\":[\"15\",\"00\",\"01\",\"05\",0,\"test03\"]}', 3, NULL, '数据发送失败！管道尚未连接。', 5, '2026-07-13 15:28:08', '2026-07-13 15:41:31', '2026-07-13 15:41:41', '2026-07-13 15:45:51', '2026-07-13 15:41:41');
INSERT INTO `gamecommandoutbox` VALUES ('6918559b9ba04f7d9c09d481c6476267', 'LK', 'test01', '{\"UserAccount\":\"test01\"}', 2, 'LKOK', NULL, 0, '2026-07-14 17:38:33', '2026-07-14 17:38:33', '2026-07-14 17:38:33', NULL, '2026-07-14 17:38:33');
INSERT INTO `gamecommandoutbox` VALUES ('6bcbd500180443ab97027f97e3839136', 'UC', 'test01', '{\"Args\":[\"01\",\"03\",0,\"test01\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 13:41:31', '2026-07-13 13:53:38', '2026-07-13 13:53:38', '2026-07-13 13:57:48', '2026-07-13 13:53:38');
INSERT INTO `gamecommandoutbox` VALUES ('6bcf3959a29f4b308118f2877ab23811', 'UC', 'test002', '{\"Args\":[\"25\",\"09\",0,\"test002\"]}', 3, NULL, '数据发送失败！管道尚未连接。', 5, '2026-07-14 11:38:35', '2026-07-14 11:52:45', '2026-07-14 11:52:55', '2026-07-14 11:57:05', '2026-07-14 11:52:55');
INSERT INTO `gamecommandoutbox` VALUES ('702b85d125894878a9c3ba8684765c4d', 'UC', 'test03', '{\"Args\":[\"01\",\"03\",0,\"test03\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 12:05:59', '2026-07-13 12:13:01', '2026-07-13 12:13:01', '2026-07-13 12:17:11', '2026-07-13 12:13:01');
INSERT INTO `gamecommandoutbox` VALUES ('73fec132825142f5861f305942c6845b', 'UC', 'test03', '{\"Args\":[\"01\",\"06\",0,\"test03\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 17:51:06', '2026-07-13 17:58:05', '2026-07-13 17:58:05', '2026-07-13 18:02:15', '2026-07-13 17:58:05');
INSERT INTO `gamecommandoutbox` VALUES ('75edfc7cfd2140adad2154376b56f3c4', 'UC', 'test01', '{\"Args\":[\"01\",\"03\",0,\"test01\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 13:46:01', '2026-07-13 13:53:39', '2026-07-13 13:53:39', '2026-07-13 13:57:49', '2026-07-13 13:53:39');
INSERT INTO `gamecommandoutbox` VALUES ('797845f8b5da4d96b76049cb20a4b904', 'UC', 'test03', '{\"Args\":[\"05\",\"00\",\"00\",\"00\",0,\"test03\"]}', 3, 'UCER', '服务器内部错误。(UCER)', 5, '2026-07-13 13:46:08', '2026-07-13 13:53:39', '2026-07-13 13:53:39', '2026-07-13 13:57:49', '2026-07-13 13:53:39');
INSERT INTO `gamecommandoutbox` VALUES ('7b51b007568e460eb94cb166c29b2b1f', 'UC', 'test03', '{\"Args\":[\"03\",\"03\",0,\"test03\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 13:41:28', '2026-07-13 13:53:38', '2026-07-13 13:53:38', '2026-07-13 13:57:48', '2026-07-13 13:53:38');
INSERT INTO `gamecommandoutbox` VALUES ('7ccbae3d1e854552b12e57b5051a8748', 'UC', 'test002', '{\"Args\":[\"01\",\"03\",0,\"test002\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 12:06:43', '2026-07-13 12:13:01', '2026-07-13 12:13:01', '2026-07-13 12:17:11', '2026-07-13 12:13:01');
INSERT INTO `gamecommandoutbox` VALUES ('7fa456cebaf14259b462038b2230ac22', 'UC', 'test01', '{\"Args\":[\"08\",\"04\",\"00\",\"00\",0,\"test01\"]}', 3, NULL, '数据发送失败！管道尚未连接。', 5, '2026-07-13 15:41:01', '2026-07-13 15:51:57', '2026-07-13 15:52:07', '2026-07-13 15:56:17', '2026-07-13 15:52:07');
INSERT INTO `gamecommandoutbox` VALUES ('84fd823c6f694e68aca3e8821d000409', 'UC', 'test01', '{\"Args\":[\"01\",\"03\",0,\"test01\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 13:40:56', '2026-07-13 13:49:33', '2026-07-13 13:49:33', '2026-07-13 13:53:43', '2026-07-13 13:49:33');
INSERT INTO `gamecommandoutbox` VALUES ('88c8e1f4d5904468a8e64f7032cbde97', 'LK', 'test03', '{\"UserAccount\":\"test03\"}', 3, NULL, '数据发送失败！管道尚未连接。', 5, '2026-07-09 09:46:36', '2026-07-09 09:53:29', '2026-07-09 09:53:39', '2026-07-09 09:57:49', '2026-07-09 09:53:39');
INSERT INTO `gamecommandoutbox` VALUES ('8b9ae3ca9364417c865de32a3630d71b', 'UC', 'test002', '{\"Args\":[\"01\",\"03\",0,\"test002\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 11:50:25', '2026-07-13 11:59:48', '2026-07-13 11:59:48', '2026-07-13 12:03:58', '2026-07-13 11:59:48');
INSERT INTO `gamecommandoutbox` VALUES ('8f6e2621a5d841fcb2d5a21af7732fd2', 'UL', 'test01', '{\"RechargeType\":0,\"Result\":1,\"Coins\":455564,\"UserAccount\":\"test01\"}', 2, 'ULOK', NULL, 0, '2026-07-14 14:46:21', '2026-07-14 14:46:21', '2026-07-14 14:46:21', NULL, '2026-07-14 14:46:21');
INSERT INTO `gamecommandoutbox` VALUES ('a1e6d10d881f46588be819c49ecd30f3', 'UC', 'test002', '{\"Args\":[\"15\",\"02\",\"02\",\"10\",0,\"test002\"]}', 3, NULL, '数据发送失败！管道尚未连接。', 5, '2026-07-14 11:18:19', '2026-07-14 11:26:47', '2026-07-14 11:26:57', '2026-07-14 11:31:07', '2026-07-14 11:26:57');
INSERT INTO `gamecommandoutbox` VALUES ('a42e0e48d4b0463ba71c65741109f246', 'UC', 'test01', '{\"Args\":[\"01\",\"03\",0,\"test01\"]}', 3, NULL, '数据发送失败！管道尚未连接。', 5, '2026-07-14 11:24:18', '2026-07-14 11:35:26', '2026-07-14 11:35:36', '2026-07-14 11:39:46', '2026-07-14 11:35:36');
INSERT INTO `gamecommandoutbox` VALUES ('a791164fdb5a4a5c90c709b81607a257', 'UC', 'test002', '{\"Args\":[\"27\",\"09\",0,\"test002\"]}', 3, NULL, '数据发送失败！管道尚未连接。', 5, '2026-07-14 11:35:26', '2026-07-14 11:48:46', '2026-07-14 11:48:56', '2026-07-14 11:53:06', '2026-07-14 11:48:56');
INSERT INTO `gamecommandoutbox` VALUES ('a81de5cadb2c4dc79fdaa88209764755', 'UC', 'test03', '{\"Args\":[\"05\",\"00\",\"00\",\"00\",0,\"test03\"]}', 3, 'UCER', '服务器内部错误。(UCER)', 5, '2026-07-13 13:48:56', '2026-07-13 13:56:36', '2026-07-13 13:56:37', '2026-07-13 14:00:47', '2026-07-13 13:56:37');
INSERT INTO `gamecommandoutbox` VALUES ('a8d7ec209fcf4b0a906f0353456e9daa', 'UC', 'test01', '{\"Args\":[\"01\",\"03\",0,\"test01\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 13:42:09', '2026-07-13 13:53:39', '2026-07-13 13:53:39', '2026-07-13 13:57:49', '2026-07-13 13:53:39');
INSERT INTO `gamecommandoutbox` VALUES ('a91393ba9d47490db119fc3b25d5cb57', 'UC', 'test03', '{\"Args\":[\"05\",\"00\",\"00\",\"00\",0,\"test03\"]}', 3, 'UCER', '服务器内部错误。(UCER)', 5, '2026-07-13 13:41:08', '2026-07-13 13:53:37', '2026-07-13 13:53:37', '2026-07-13 13:57:47', '2026-07-13 13:53:37');
INSERT INTO `gamecommandoutbox` VALUES ('b02c73ae615840a0b0b86463effe6905', 'UC', 'test002', '{\"Args\":[\"25\",\"09\",0,\"test002\"]}', 2, 'UCOK', NULL, 4, '2026-07-13 20:02:55', '2026-07-14 10:42:16', '2026-07-14 10:42:16', NULL, '2026-07-14 10:42:16');
INSERT INTO `gamecommandoutbox` VALUES ('b2e5f9fc9b5249c0ac2a49ae8ab20ede', 'UC', 'test002', '{\"Args\":[\"-1\",\"00\",\"00\",\"00\",0,\"test002\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 13:41:20', '2026-07-13 13:53:38', '2026-07-13 13:53:38', '2026-07-13 13:57:48', '2026-07-13 13:53:38');
INSERT INTO `gamecommandoutbox` VALUES ('b2e7b1a5eca2499eaa60de59b5309799', 'UC', 'test01', '{\"Args\":[\"07\",\"000000001000\",\"0000\",\"test01\"]}', 3, 'UCER', '服务器内部错误。(UCER)', 5, '2026-07-13 11:50:30', '2026-07-13 11:59:48', '2026-07-13 11:59:48', '2026-07-13 12:03:58', '2026-07-13 11:59:48');
INSERT INTO `gamecommandoutbox` VALUES ('b806c9e5dd4b47c381c615ad9fbf82d5', 'UC', 'test002', '{\"Args\":[\"27\",\"09\",0,\"test002\"]}', 2, 'UCOK', NULL, 4, '2026-07-13 20:02:26', '2026-07-14 10:42:15', '2026-07-14 10:42:15', NULL, '2026-07-14 10:42:16');
INSERT INTO `gamecommandoutbox` VALUES ('b97e53d0efde49508db086ca2a594592', 'UC', 'test002', '{\"Args\":[\"07\",\"000000001000\",\"0000\",\"test002\"]}', 3, 'UCER', '服务器内部错误。(UCER)', 5, '2026-07-13 11:53:41', '2026-07-13 12:02:47', '2026-07-13 12:02:48', '2026-07-13 12:06:58', '2026-07-13 12:02:48');
INSERT INTO `gamecommandoutbox` VALUES ('b986c2c5ced6452a8bd424547d8d0456', 'UC', 'test002', '{\"Args\":[\"01\",\"09\",0,\"test002\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 12:00:52', '2026-07-13 12:08:01', '2026-07-13 12:08:01', '2026-07-13 12:12:11', '2026-07-13 12:08:01');
INSERT INTO `gamecommandoutbox` VALUES ('bf1366d52e0b4c7c967bdeb21ca73fe8', 'UC', 'test002', '{\"Args\":[\"27\",\"09\",0,\"test002\"]}', 3, NULL, '数据发送失败！管道尚未连接。', 5, '2026-07-14 11:35:37', '2026-07-14 11:48:56', '2026-07-14 11:49:06', '2026-07-14 11:53:16', '2026-07-14 11:49:06');
INSERT INTO `gamecommandoutbox` VALUES ('c1e044da0380451d9648f4169175edbd', 'UC', 'test01', '{\"Args\":[\"-1\",\"00\",\"00\",\"00\",0,\"test01\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 13:41:24', '2026-07-13 13:53:38', '2026-07-13 13:53:38', '2026-07-13 13:57:48', '2026-07-13 13:53:38');
INSERT INTO `gamecommandoutbox` VALUES ('c33ac82f33354ae4b6e0e54470823739', 'UC', 'test002', '{\"Args\":[\"02\",\"06\",0,\"test002\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 12:01:02', '2026-07-13 12:08:01', '2026-07-13 12:08:01', '2026-07-13 12:12:11', '2026-07-13 12:08:01');
INSERT INTO `gamecommandoutbox` VALUES ('c47c712f380b471da5d01c39fcce5644', 'UL', 'test01', '{\"RechargeType\":0,\"Result\":1,\"Coins\":999999,\"UserAccount\":\"test01\"}', 3, '数据发送失败！管道尚未连接。', '数据发送失败！管道尚未连接。', 5, '2026-06-17 17:56:57', '2026-06-17 18:03:57', '2026-06-17 18:04:07', '2026-06-17 18:08:17', '2026-06-17 18:04:07');
INSERT INTO `gamecommandoutbox` VALUES ('ca075ab958e0418f8ba51cb3bea101a3', 'UC', 'test002', '{\"Args\":[\"01\",\"03\",0,\"test002\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 12:05:40', '2026-07-13 12:12:00', '2026-07-13 12:12:00', '2026-07-13 12:16:10', '2026-07-13 12:12:00');
INSERT INTO `gamecommandoutbox` VALUES ('ce42bd55f1584f22957215bbbc84da1b', 'UC', 'test01', '{\"Args\":[\"03\",\"03\",0,\"test01\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 13:37:13', '2026-07-13 13:49:32', '2026-07-13 13:49:32', '2026-07-13 13:53:42', '2026-07-13 13:49:32');
INSERT INTO `gamecommandoutbox` VALUES ('d030ae6472104fd289a4d2b63c60d99c', 'UC', 'test002', '{\"Args\":[\"15\",\"00\",\"01\",\"05\",0,\"test002\"]}', 3, NULL, '数据发送失败！管道尚未连接。', 5, '2026-07-13 19:44:54', '2026-07-13 19:53:27', '2026-07-13 19:53:37', '2026-07-13 19:57:47', '2026-07-13 19:53:37');
INSERT INTO `gamecommandoutbox` VALUES ('d10bfaba6cf24f6599b603769e706af7', 'UC', 'test01', '{\"Args\":[\"01\",\"06\",0,\"test01\"]}', 3, NULL, '数据发送失败！管道尚未连接。', 5, '2026-07-13 15:49:24', '2026-07-13 15:56:57', '2026-07-13 15:57:07', '2026-07-13 16:01:17', '2026-07-13 15:57:07');
INSERT INTO `gamecommandoutbox` VALUES ('d17d8bc0a59f49f998a13b8a7f015a30', 'UL', 'test03', '{\"RechargeType\":0,\"Result\":1,\"Coins\":155465,\"UserAccount\":\"test03\"}', 2, 'ULER', NULL, 4, '2026-07-09 09:46:46', '2026-07-09 09:54:29', '2026-07-09 09:54:29', NULL, '2026-07-09 09:54:29');
INSERT INTO `gamecommandoutbox` VALUES ('d6371fdd848942d6a123636a1d04d732', 'UC', 'test002', '{\"Args\":[\"25\",\"03\",0,\"test002\"]}', 3, NULL, '数据发送失败！管道尚未连接。', 5, '2026-07-14 11:34:48', '2026-07-14 11:48:35', '2026-07-14 11:48:45', '2026-07-14 11:52:55', '2026-07-14 11:48:45');
INSERT INTO `gamecommandoutbox` VALUES ('d6885793cc3d42b3ac4ae7183eb638c5', 'UC', 'test01', '{\"Args\":[\"01\",\"03\",0,\"test01\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 13:37:30', '2026-07-13 13:49:32', '2026-07-13 13:49:33', '2026-07-13 13:53:43', '2026-07-13 13:49:33');
INSERT INTO `gamecommandoutbox` VALUES ('d956cfdbdb764c5ab8befaa69505fd2e', 'LK', 'test01', '{\"UserAccount\":\"test01\"}', 2, 'LKOK', NULL, 0, '2026-07-14 14:40:27', '2026-07-14 14:40:27', '2026-07-14 14:40:27', NULL, '2026-07-14 14:40:27');
INSERT INTO `gamecommandoutbox` VALUES ('d9858a09ec154de49e03819943d0f987', 'UC', 'test03', '{\"Args\":[\"01\",\"03\",0,\"test03\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 13:37:21', '2026-07-13 13:49:32', '2026-07-13 13:49:32', '2026-07-13 13:53:42', '2026-07-13 13:49:32');
INSERT INTO `gamecommandoutbox` VALUES ('df7add293e0f477788e1999408300526', 'UC', 'test002', '{\"Args\":[\"15\",\"02\",\"02\",\"10\",0,\"test002\"]}', 3, NULL, '数据发送失败！管道尚未连接。', 5, '2026-07-14 11:18:30', '2026-07-14 11:26:57', '2026-07-14 11:27:07', '2026-07-14 11:31:17', '2026-07-14 11:27:07');
INSERT INTO `gamecommandoutbox` VALUES ('e018d4692799461db03e382915aa78e9', 'UC', 'test002', '{\"Args\":[\"01\",\"03\",0,\"test002\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 11:53:59', '2026-07-13 12:02:48', '2026-07-13 12:02:48', '2026-07-13 12:06:58', '2026-07-13 12:02:48');
INSERT INTO `gamecommandoutbox` VALUES ('e191ca5ec300471aa1babccff7b63605', 'UL', 'test01', '{\"RechargeType\":0,\"Result\":1,\"Coins\":65621,\"UserAccount\":\"test01\"}', 2, 'ULOK', NULL, 0, '2026-07-14 17:38:33', '2026-07-14 17:38:35', '2026-07-14 17:38:35', NULL, '2026-07-14 17:38:36');
INSERT INTO `gamecommandoutbox` VALUES ('e2b6c69d252243189879449987a71c09', 'UL', 'test01', '{\"RechargeType\":0,\"Result\":1,\"Coins\":4501113,\"UserAccount\":\"test01\"}', 2, 'ULOK', NULL, 0, '2026-07-14 14:40:27', '2026-07-14 14:40:27', '2026-07-14 14:40:27', NULL, '2026-07-14 14:40:27');
INSERT INTO `gamecommandoutbox` VALUES ('e43520310dd34dbea9d714cf7d5b055b', 'UL', 'test03', '{\"RechargeType\":0,\"Result\":1,\"Coins\":155465,\"UserAccount\":\"test03\"}', 2, 'ULER', NULL, 4, '2026-07-09 09:47:09', '2026-07-09 09:55:29', '2026-07-09 09:55:29', NULL, '2026-07-09 09:55:29');
INSERT INTO `gamecommandoutbox` VALUES ('e47549e79e9543478e6ad8ecbfea52a8', 'UC', 'test01', '{\"Args\":[\"-1\",\"00\",\"00\",\"00\",0,\"test01\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 13:46:13', '2026-07-13 13:53:40', '2026-07-13 13:53:40', '2026-07-13 13:57:50', '2026-07-13 13:53:40');
INSERT INTO `gamecommandoutbox` VALUES ('e4830c2dac69419eb4e290d71d5fbe99', 'UC', 'test002', '{\"Args\":[\"27\",\"06\",0,\"test002\"]}', 3, NULL, '数据发送失败！管道尚未连接。', 5, '2026-07-13 19:45:04', '2026-07-13 19:53:37', '2026-07-13 19:53:48', '2026-07-13 19:57:58', '2026-07-13 19:53:48');
INSERT INTO `gamecommandoutbox` VALUES ('e511fde48ebf4d6abd3e0dd14e008542', 'UC', 'test01', '{\"Args\":[\"01\",\"03\",0,\"test01\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 13:48:48', '2026-07-13 13:56:36', '2026-07-13 13:56:36', '2026-07-13 14:00:46', '2026-07-13 13:56:36');
INSERT INTO `gamecommandoutbox` VALUES ('e7c35eb316374cebb8636d3a73981be0', 'UC', 'test03', '{\"Args\":[\"16\",\"06\",\"01\",\"05\",0,\"test03\"]}', 3, NULL, '数据发送失败！管道尚未连接。', 5, '2026-07-13 15:49:12', '2026-07-13 15:55:57', '2026-07-13 15:56:07', '2026-07-13 16:00:17', '2026-07-13 15:56:07');
INSERT INTO `gamecommandoutbox` VALUES ('e87b56238f084d4da5083d10b91508ae', 'UC', 'test002', '{\"Args\":[\"05\",\"02\",\"01\",\"10\",0,\"test002\"]}', 3, NULL, '数据发送失败！管道尚未连接。', 5, '2026-07-14 11:38:13', '2026-07-14 11:52:35', '2026-07-14 11:52:45', '2026-07-14 11:56:55', '2026-07-14 11:52:45');
INSERT INTO `gamecommandoutbox` VALUES ('e90602f0c7b6469f9ac2f378319d248d', 'UL', 'test01', '{\"RechargeType\":0,\"Result\":1,\"Coins\":4501113,\"UserAccount\":\"test01\"}', 2, 'ULOK', NULL, 0, '2026-07-14 14:40:24', '2026-07-14 14:40:26', '2026-07-14 14:40:26', NULL, '2026-07-14 14:40:27');
INSERT INTO `gamecommandoutbox` VALUES ('e9b9e0fc0e8f4937b9eef107a791abe6', 'LK', 'test002', '{\"UserAccount\":\"test002\"}', 2, 'LKOK', NULL, 0, '2026-07-14 17:55:02', '2026-07-14 17:55:02', '2026-07-14 17:55:02', NULL, '2026-07-14 17:55:02');
INSERT INTO `gamecommandoutbox` VALUES ('ea55a0b6a8df41c1aea7266cb80ce07f', 'UC', 'test03', '{\"Args\":[\"01\",\"06\",0,\"test03\"]}', 3, NULL, '数据发送失败！管道尚未连接。', 5, '2026-07-13 11:00:47', '2026-07-13 11:08:03', '2026-07-13 11:08:13', '2026-07-13 11:12:23', '2026-07-13 11:08:13');
INSERT INTO `gamecommandoutbox` VALUES ('f00e9025bd984c739d94da062af9d0fd', 'UL', 'test01', '{\"RechargeType\":0,\"Result\":1,\"Coins\":1415552,\"UserAccount\":\"test01\"}', 2, 'ULOK', NULL, 0, '2026-07-14 17:15:22', '2026-07-14 17:15:25', '2026-07-14 17:15:25', NULL, '2026-07-14 17:15:25');
INSERT INTO `gamecommandoutbox` VALUES ('f0141882887b47fb9d88fef6fc344510', 'UC', 'test002', '{\"Args\":[\"01\",\"03\",0,\"test002\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 13:45:57', '2026-07-13 13:53:39', '2026-07-13 13:53:39', '2026-07-13 13:57:49', '2026-07-13 13:53:39');
INSERT INTO `gamecommandoutbox` VALUES ('f02fb39134e44ed7a2d3fb63381a16ee', 'UC', 'test002', '{\"Args\":[\"01\",\"03\",0,\"test002\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 11:53:41', '2026-07-13 12:02:48', '2026-07-13 12:02:48', '2026-07-13 12:06:58', '2026-07-13 12:02:48');
INSERT INTO `gamecommandoutbox` VALUES ('f165e76ccec942ad81d88786d46badc6', 'UC', 'test002', '{\"Args\":[\"07\",\"000000001000\",\"0000\",\"test002\"]}', 3, 'UCER', '服务器内部错误。(UCER)', 5, '2026-07-13 11:53:59', '2026-07-13 12:02:48', '2026-07-13 12:02:48', '2026-07-13 12:06:58', '2026-07-13 12:02:48');
INSERT INTO `gamecommandoutbox` VALUES ('f6fd1c408fa14f3bb102a311144c04fb', 'UC', 'test002', '{\"Args\":[\"01\",\"03\",0,\"test002\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 13:48:52', '2026-07-13 13:56:36', '2026-07-13 13:56:36', '2026-07-13 14:00:46', '2026-07-13 13:56:36');
INSERT INTO `gamecommandoutbox` VALUES ('fb3cfb6808e2429a8afd5c966288c409', 'UC', 'test002', '{\"Args\":[\"03\",\"06\",0,\"test002\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 19:57:53', '2026-07-14 10:39:16', '2026-07-14 10:39:17', '2026-07-14 10:43:27', '2026-07-14 10:39:17');
INSERT INTO `gamecommandoutbox` VALUES ('fd455b2575e7410e9df5c7eaccab9299', 'UC', 'test002', '{\"Args\":[\"05\",\"00\",\"00\",\"00\",0,\"test002\"]}', 3, 'UCER', '服务器内部错误。(UCER)', 5, '2026-07-13 12:05:52', '2026-07-13 12:13:01', '2026-07-13 12:13:01', '2026-07-13 12:17:11', '2026-07-13 12:13:01');
INSERT INTO `gamecommandoutbox` VALUES ('fe53cdabc2fc455faf361319531f69bc', 'UC', 'test002', '{\"Args\":[\"07\",\"000000001000\",\"0000\",\"test002\"]}', 3, 'UCER', '服务器内部错误。(UCER)', 5, '2026-07-13 11:52:12', '2026-07-13 11:59:48', '2026-07-13 11:59:48', '2026-07-13 12:03:58', '2026-07-13 11:59:48');
INSERT INTO `gamecommandoutbox` VALUES ('fe84f1d3cb1b412ebe17d2bcc1188393', 'UC', 'test01', '{\"Args\":[\"01\",\"03\",0,\"test01\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 11:59:21', '2026-07-13 12:06:00', '2026-07-13 12:06:01', '2026-07-13 12:10:11', '2026-07-13 12:06:01');
INSERT INTO `gamecommandoutbox` VALUES ('ffc990f7fef74b7bbd667fca102346ea', 'UC', 'test002', '{\"Args\":[\"01\",\"03\",0,\"test002\"]}', 3, 'UCNL', '设定成功！玩家现在不在线，玩家下次登陆后生效。(UCNL)', 5, '2026-07-13 13:40:51', '2026-07-13 13:49:33', '2026-07-13 13:49:33', '2026-07-13 13:53:43', '2026-07-13 13:49:33');

-- ----------------------------
-- Table structure for gameconfiglaba
-- ----------------------------
DROP TABLE IF EXISTS `gameconfiglaba`;
CREATE TABLE `gameconfiglaba`  (
  `GameId` int(11) NOT NULL COMMENT '用户账号',
  `TableIndex` int(11) NOT NULL DEFAULT 0 COMMENT '桌台索引',
  `OptKey` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '功能',
  `OptValue` int(11) NOT NULL COMMENT '控值',
  `Type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `TIME` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '设置时间',
  PRIMARY KEY (`GameId`, `TableIndex`, `OptKey`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '机率控制记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gameconfiglaba
-- ----------------------------
INSERT INTO `gameconfiglaba` VALUES (16, 0, 'Payout0', 2, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (16, 0, 'Payout1', 3, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (16, 0, 'Payout2', 4, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (16, 0, 'Payout3', 5, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (16, 0, 'Payout4', 8, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (16, 0, 'Payout5', 10, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (16, 0, 'Payout6', 15, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (16, 0, 'Payout7', 30, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (16, 1, 'ExchangeScore', 0, '', '2026-07-09 15:39:11');
INSERT INTO `gameconfiglaba` VALUES (16, 2, 'betMax', 404, 'Room', '2026-07-13 16:07:22');
INSERT INTO `gameconfiglaba` VALUES (16, 2, 'betMin', 10, 'Room', '2026-07-13 16:07:22');
INSERT INTO `gameconfiglaba` VALUES (16, 2, 'coinsNeed', 0, 'Room', '2026-07-13 16:07:22');
INSERT INTO `gameconfiglaba` VALUES (40, 0, 'betMax', 1000, 'Room', '2026-07-10 15:30:19');
INSERT INTO `gameconfiglaba` VALUES (40, 0, 'betMin', 30, 'Room', '2026-07-10 15:30:19');
INSERT INTO `gameconfiglaba` VALUES (40, 0, 'coinsNeed', 0, 'Room', '2026-07-10 15:30:19');
INSERT INTO `gameconfiglaba` VALUES (40, 0, 'Payout0', 2, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (40, 0, 'Payout1', 3, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (40, 0, 'Payout2', 4, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (40, 0, 'Payout3', 5, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (40, 0, 'Payout4', 8, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (40, 0, 'Payout5', 10, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (40, 0, 'Payout6', 15, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (40, 0, 'Payout7', 30, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (40, 1, 'betMax', 300, 'Room', '2026-07-10 16:27:43');
INSERT INTO `gameconfiglaba` VALUES (40, 1, 'betMin', 1, 'Room', '2026-07-10 16:27:43');
INSERT INTO `gameconfiglaba` VALUES (40, 1, 'coinsNeed', 0, 'Room', '2026-07-10 16:27:43');
INSERT INTO `gameconfiglaba` VALUES (40, 1, 'Payout0', 2, 'Payout', '2026-07-10 11:38:12');
INSERT INTO `gameconfiglaba` VALUES (40, 1, 'Payout1', 3, 'Payout', '2026-07-10 11:38:12');
INSERT INTO `gameconfiglaba` VALUES (40, 1, 'Payout2', 4, 'Payout', '2026-07-10 11:38:12');
INSERT INTO `gameconfiglaba` VALUES (40, 1, 'Payout3', 5, 'Payout', '2026-07-10 11:38:12');
INSERT INTO `gameconfiglaba` VALUES (40, 1, 'Payout4', 8, 'Payout', '2026-07-10 11:38:12');
INSERT INTO `gameconfiglaba` VALUES (40, 1, 'Payout5', 10, 'Payout', '2026-07-10 11:38:12');
INSERT INTO `gameconfiglaba` VALUES (40, 1, 'Payout6', 15, 'Payout', '2026-07-10 11:38:12');
INSERT INTO `gameconfiglaba` VALUES (40, 1, 'Payout7', 30, 'Payout', '2026-07-10 11:38:12');
INSERT INTO `gameconfiglaba` VALUES (40, 2, 'betMax', 100, 'Room', '2026-07-10 16:02:45');
INSERT INTO `gameconfiglaba` VALUES (40, 2, 'betMin', 1, 'Room', '2026-07-10 16:02:45');
INSERT INTO `gameconfiglaba` VALUES (40, 2, 'coinsNeed', 0, 'Room', '2026-07-10 16:02:45');
INSERT INTO `gameconfiglaba` VALUES (40, 2, 'Payout0', 2, 'Payout', '2026-07-10 16:02:45');
INSERT INTO `gameconfiglaba` VALUES (40, 2, 'Payout1', 3, 'Payout', '2026-07-10 16:02:45');
INSERT INTO `gameconfiglaba` VALUES (40, 2, 'Payout2', 4, 'Payout', '2026-07-10 16:02:45');
INSERT INTO `gameconfiglaba` VALUES (40, 2, 'Payout3', 5, 'Payout', '2026-07-10 16:02:45');
INSERT INTO `gameconfiglaba` VALUES (40, 2, 'Payout4', 8, 'Payout', '2026-07-10 16:02:45');
INSERT INTO `gameconfiglaba` VALUES (40, 2, 'Payout5', 10, 'Payout', '2026-07-10 16:02:45');
INSERT INTO `gameconfiglaba` VALUES (40, 2, 'Payout6', 15, 'Payout', '2026-07-10 16:02:45');
INSERT INTO `gameconfiglaba` VALUES (40, 2, 'Payout7', 30, 'Payout', '2026-07-10 16:02:45');
INSERT INTO `gameconfiglaba` VALUES (53, 0, 'betMax', 100, 'Room', '2026-07-10 15:25:55');
INSERT INTO `gameconfiglaba` VALUES (53, 0, 'betMin', 1, 'Room', '2026-07-10 15:25:55');
INSERT INTO `gameconfiglaba` VALUES (53, 0, 'coinsNeed', 0, 'Room', '2026-07-10 15:25:55');
INSERT INTO `gameconfiglaba` VALUES (53, 0, 'Payout0', 2, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (53, 0, 'Payout1', 3, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (53, 0, 'Payout2', 4, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (53, 0, 'Payout3', 5, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (53, 0, 'Payout4', 8, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (53, 0, 'Payout5', 10, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (53, 0, 'Payout6', 15, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (53, 0, 'Payout7', 30, 'Payout', '2026-07-01 22:30:32');
INSERT INTO `gameconfiglaba` VALUES (53, 0, 'Payout8', 0, 'Payout', '2026-07-10 14:58:37');
INSERT INTO `gameconfiglaba` VALUES (53, 0, 'Payout9', 0, 'Payout', '2026-07-10 14:58:37');
INSERT INTO `gameconfiglaba` VALUES (53, 1, 'betMax', 1000, 'Room', '2026-07-10 17:08:27');
INSERT INTO `gameconfiglaba` VALUES (53, 1, 'betMin', 100, 'Room', '2026-07-10 17:08:27');
INSERT INTO `gameconfiglaba` VALUES (53, 1, 'coinsNeed', 0, 'Room', '2026-07-10 17:08:27');
INSERT INTO `gameconfiglaba` VALUES (53, 1, 'ExchangeScore', 0, '', '2026-07-09 10:14:31');
INSERT INTO `gameconfiglaba` VALUES (53, 1, 'Payout0', 0, 'Payout', '2026-07-10 17:08:27');
INSERT INTO `gameconfiglaba` VALUES (53, 1, 'Payout1', 0, 'Payout', '2026-07-10 17:08:27');
INSERT INTO `gameconfiglaba` VALUES (53, 1, 'Payout2', 0, 'Payout', '2026-07-10 17:08:27');
INSERT INTO `gameconfiglaba` VALUES (53, 1, 'Payout3', 0, 'Payout', '2026-07-10 17:08:27');
INSERT INTO `gameconfiglaba` VALUES (53, 1, 'Payout4', 0, 'Payout', '2026-07-10 17:08:27');
INSERT INTO `gameconfiglaba` VALUES (53, 1, 'Payout5', 0, 'Payout', '2026-07-10 17:08:27');
INSERT INTO `gameconfiglaba` VALUES (53, 1, 'Payout6', 0, 'Payout', '2026-07-10 17:08:27');
INSERT INTO `gameconfiglaba` VALUES (53, 1, 'Payout7', 0, 'Payout', '2026-07-10 17:08:27');
INSERT INTO `gameconfiglaba` VALUES (53, 1, 'Payout8', 0, 'Payout', '2026-07-10 17:08:27');
INSERT INTO `gameconfiglaba` VALUES (53, 1, 'Payout9', 0, 'Payout', '2026-07-10 17:08:27');
INSERT INTO `gameconfiglaba` VALUES (53, 2, 'betMax', 1000, 'Room', '2026-07-10 17:10:17');
INSERT INTO `gameconfiglaba` VALUES (53, 2, 'betMin', 250, 'Room', '2026-07-10 17:10:17');
INSERT INTO `gameconfiglaba` VALUES (53, 2, 'coinsNeed', 0, 'Room', '2026-07-10 17:10:17');
INSERT INTO `gameconfiglaba` VALUES (53, 2, 'ExchangeScore', 0, '', '2026-07-09 10:16:53');
INSERT INTO `gameconfiglaba` VALUES (53, 2, 'Payout0', 0, 'Payout', '2026-07-10 17:10:17');
INSERT INTO `gameconfiglaba` VALUES (53, 2, 'Payout1', 0, 'Payout', '2026-07-10 17:10:17');
INSERT INTO `gameconfiglaba` VALUES (53, 2, 'Payout2', 0, 'Payout', '2026-07-10 17:10:17');
INSERT INTO `gameconfiglaba` VALUES (53, 2, 'Payout3', 0, 'Payout', '2026-07-10 17:10:17');
INSERT INTO `gameconfiglaba` VALUES (53, 2, 'Payout4', 0, 'Payout', '2026-07-10 17:10:17');
INSERT INTO `gameconfiglaba` VALUES (53, 2, 'Payout5', 0, 'Payout', '2026-07-10 17:10:17');
INSERT INTO `gameconfiglaba` VALUES (53, 2, 'Payout6', 0, 'Payout', '2026-07-10 17:10:17');
INSERT INTO `gameconfiglaba` VALUES (53, 2, 'Payout7', 0, 'Payout', '2026-07-10 17:10:17');
INSERT INTO `gameconfiglaba` VALUES (53, 2, 'Payout8', 0, 'Payout', '2026-07-10 17:10:17');
INSERT INTO `gameconfiglaba` VALUES (53, 2, 'Payout9', 0, 'Payout', '2026-07-10 17:10:17');
INSERT INTO `gameconfiglaba` VALUES (53, 5, 'betMax', 410, 'Room', '2026-07-10 16:00:03');
INSERT INTO `gameconfiglaba` VALUES (53, 5, 'betMin', 1, 'Room', '2026-07-10 16:00:03');
INSERT INTO `gameconfiglaba` VALUES (53, 5, 'coinsNeed', 0, 'Room', '2026-07-10 16:00:03');
INSERT INTO `gameconfiglaba` VALUES (53, 5, 'Payout0', 0, 'Payout', '2026-07-10 16:00:03');
INSERT INTO `gameconfiglaba` VALUES (53, 5, 'Payout1', 0, 'Payout', '2026-07-10 16:00:03');
INSERT INTO `gameconfiglaba` VALUES (53, 5, 'Payout2', 0, 'Payout', '2026-07-10 16:00:03');
INSERT INTO `gameconfiglaba` VALUES (53, 5, 'Payout3', 0, 'Payout', '2026-07-10 16:00:03');
INSERT INTO `gameconfiglaba` VALUES (53, 5, 'Payout4', 0, 'Payout', '2026-07-10 16:00:03');
INSERT INTO `gameconfiglaba` VALUES (53, 5, 'Payout5', 0, 'Payout', '2026-07-10 16:00:03');
INSERT INTO `gameconfiglaba` VALUES (53, 5, 'Payout6', 0, 'Payout', '2026-07-10 16:00:03');
INSERT INTO `gameconfiglaba` VALUES (53, 5, 'Payout7', 0, 'Payout', '2026-07-10 16:00:03');
INSERT INTO `gameconfiglaba` VALUES (53, 5, 'Payout8', 0, 'Payout', '2026-07-10 16:00:03');
INSERT INTO `gameconfiglaba` VALUES (53, 5, 'Payout9', 0, 'Payout', '2026-07-10 16:00:03');
INSERT INTO `gameconfiglaba` VALUES (53, 6, 'betMax', 4100, 'Room', '2026-07-10 20:03:03');
INSERT INTO `gameconfiglaba` VALUES (53, 6, 'betMin', 40, 'Room', '2026-07-10 20:03:03');
INSERT INTO `gameconfiglaba` VALUES (53, 6, 'coinsNeed', 0, 'Room', '2026-07-10 20:03:03');

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
INSERT INTO `games` VALUES (37, 'ATT3', 1, 1, 0);
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
INSERT INTO `loginmissrecord` VALUES (205, 'admin', 1, 0, '::1', '2026-07-16 14:13:11');
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
INSERT INTO `manageropt` VALUES ('test002', '', 1, 3, 'UC', '2026-07-13 11:49:53');
INSERT INTO `manageropt` VALUES ('test002', '', 1, 3, 'UC', '2026-07-13 11:50:25');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 11:50:29');
INSERT INTO `manageropt` VALUES ('test002', '', 1, 3, 'UC', '2026-07-13 11:50:34');
INSERT INTO `manageropt` VALUES ('test002', '', 1, 3, 'UC', '2026-07-13 11:51:33');
INSERT INTO `manageropt` VALUES ('test002', '', 1, 3, 'UC', '2026-07-13 11:51:33');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 11:51:33');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 11:52:11');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 11:52:32');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 11:52:32');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 11:52:32');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 11:53:32');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 11:53:32');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 11:53:41');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 11:53:58');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 11:54:05');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 11:54:32');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 11:54:32');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 11:54:33');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 11:54:33');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 11:54:34');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 11:55:32');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 11:55:33');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 11:55:33');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 11:55:33');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 11:56:31');
INSERT INTO `manageropt` VALUES ('test01', '', 1, 3, 'UC', '2026-07-13 11:59:21');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 11:59:47');
INSERT INTO `manageropt` VALUES ('test01', '', 1, 3, 'UC', '2026-07-13 11:59:47');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 11:59:48');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 11:59:48');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 11:59:48');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 11:59:49');
INSERT INTO `manageropt` VALUES ('test01', '', 1, 3, 'UC', '2026-07-13 11:59:49');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 11:59:55');
INSERT INTO `manageropt` VALUES ('test01', '', 1, 3, 'UC', '2026-07-13 12:00:46');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 12:00:47');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 9, 'UC', '2026-07-13 12:00:51');
INSERT INTO `manageropt` VALUES ('test002', '111', 2, 6, 'UC', '2026-07-13 12:01:02');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 12:01:47');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 9, 'UC', '2026-07-13 12:01:47');
INSERT INTO `manageropt` VALUES ('test002', '111', 2, 6, 'UC', '2026-07-13 12:01:47');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 12:02:47');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 12:02:47');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 12:02:48');
INSERT INTO `manageropt` VALUES ('test01', '', 1, 3, 'UC', '2026-07-13 12:02:48');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 9, 'UC', '2026-07-13 12:02:48');
INSERT INTO `manageropt` VALUES ('test002', '111', 2, 6, 'UC', '2026-07-13 12:02:49');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 12:05:07');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 9, 'UC', '2026-07-13 12:05:08');
INSERT INTO `manageropt` VALUES ('test002', '111', 2, 6, 'UC', '2026-07-13 12:05:08');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 12:05:40');
INSERT INTO `manageropt` VALUES ('test03', '', 1, 3, 'UC', '2026-07-13 12:05:59');
INSERT INTO `manageropt` VALUES ('test01', '', 1, 3, 'UC', '2026-07-13 12:06:00');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 12:06:00');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 12:06:42');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 12:07:00');
INSERT INTO `manageropt` VALUES ('test03', '', 1, 3, 'UC', '2026-07-13 12:07:00');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 12:07:01');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 12:08:00');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 9, 'UC', '2026-07-13 12:08:01');
INSERT INTO `manageropt` VALUES ('test002', '111', 2, 6, 'UC', '2026-07-13 12:08:01');
INSERT INTO `manageropt` VALUES ('test03', '', 1, 3, 'UC', '2026-07-13 12:08:01');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 12:08:01');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 12:09:00');
INSERT INTO `manageropt` VALUES ('test03', '', 1, 3, 'UC', '2026-07-13 12:10:00');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 12:10:01');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 12:12:00');
INSERT INTO `manageropt` VALUES ('test03', '', 1, 3, 'UC', '2026-07-13 12:13:00');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 12:13:01');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:35:13');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:36:01');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:37:01');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 3, 3, 'UC', '2026-07-13 13:37:12');
INSERT INTO `manageropt` VALUES ('test03', '', 1, 3, 'UC', '2026-07-13 13:37:21');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:37:30');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:37:35');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 3, 3, 'UC', '2026-07-13 13:38:01');
INSERT INTO `manageropt` VALUES ('test03', '', 1, 3, 'UC', '2026-07-13 13:38:01');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:38:02');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:38:02');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 13:40:51');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:40:55');
INSERT INTO `manageropt` VALUES ('0000test002', '', 2147483647, 0, 'UC', '2026-07-13 13:41:14');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:41:18');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 3, 3, 'UC', '2026-07-13 13:41:18');
INSERT INTO `manageropt` VALUES ('test03', '', 1, 3, 'UC', '2026-07-13 13:41:18');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:41:19');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:41:19');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 13:41:19');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:41:20');
INSERT INTO `manageropt` VALUES ('0000test002', '', 2147483647, 0, 'UC', '2026-07-13 13:41:20');
INSERT INTO `manageropt` VALUES ('0000test01', '', 2147483647, 0, 'UC', '2026-07-13 13:41:24');
INSERT INTO `manageropt` VALUES ('test03', '', 3, 3, 'UC', '2026-07-13 13:41:27');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:41:31');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 13:41:59');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:42:09');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 13:42:18');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:42:18');
INSERT INTO `manageropt` VALUES ('0000test002', '', 2147483647, 0, 'UC', '2026-07-13 13:42:19');
INSERT INTO `manageropt` VALUES ('0000test002', '', 2147483647, 0, 'UC', '2026-07-13 13:42:19');
INSERT INTO `manageropt` VALUES ('0000test01', '', 2147483647, 0, 'UC', '2026-07-13 13:42:19');
INSERT INTO `manageropt` VALUES ('test03', '', 3, 3, 'UC', '2026-07-13 13:42:20');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:42:20');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 13:42:20');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 13:45:56');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:46:00');
INSERT INTO `manageropt` VALUES ('test002', '111', 3, 3, 'UC', '2026-07-13 13:46:04');
INSERT INTO `manageropt` VALUES ('0000test01', '', 2147483647, 0, 'UC', '2026-07-13 13:46:13');
INSERT INTO `manageropt` VALUES ('test03', '', 3, 3, 'UC', '2026-07-13 13:46:16');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:46:40');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 3, 3, 'UC', '2026-07-13 13:46:40');
INSERT INTO `manageropt` VALUES ('test03', '', 1, 3, 'UC', '2026-07-13 13:46:40');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:46:41');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:46:43');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 13:46:43');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:46:44');
INSERT INTO `manageropt` VALUES ('0000test002', '', 2147483647, 0, 'UC', '2026-07-13 13:46:44');
INSERT INTO `manageropt` VALUES ('0000test002', '', 2147483647, 0, 'UC', '2026-07-13 13:46:44');
INSERT INTO `manageropt` VALUES ('0000test01', '', 2147483647, 0, 'UC', '2026-07-13 13:46:44');
INSERT INTO `manageropt` VALUES ('test03', '', 3, 3, 'UC', '2026-07-13 13:46:44');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:46:45');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 13:46:45');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:46:45');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 13:46:45');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:46:46');
INSERT INTO `manageropt` VALUES ('test002', '111', 3, 3, 'UC', '2026-07-13 13:46:46');
INSERT INTO `manageropt` VALUES ('0000test01', '', 2147483647, 0, 'UC', '2026-07-13 13:46:46');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:47:39');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 13:47:39');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:47:40');
INSERT INTO `manageropt` VALUES ('test002', '111', 3, 3, 'UC', '2026-07-13 13:47:40');
INSERT INTO `manageropt` VALUES ('0000test01', '', 2147483647, 0, 'UC', '2026-07-13 13:47:40');
INSERT INTO `manageropt` VALUES ('test03', '', 3, 3, 'UC', '2026-07-13 13:47:41');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:48:48');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 13:48:51');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 3, 3, 'UC', '2026-07-13 13:49:31');
INSERT INTO `manageropt` VALUES ('test03', '', 1, 3, 'UC', '2026-07-13 13:49:31');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:49:32');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:49:32');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 13:49:33');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:49:33');
INSERT INTO `manageropt` VALUES ('0000test002', '', 2147483647, 0, 'UC', '2026-07-13 13:49:33');
INSERT INTO `manageropt` VALUES ('0000test002', '', 2147483647, 0, 'UC', '2026-07-13 13:49:33');
INSERT INTO `manageropt` VALUES ('0000test01', '', 2147483647, 0, 'UC', '2026-07-13 13:49:34');
INSERT INTO `manageropt` VALUES ('test03', '', 3, 3, 'UC', '2026-07-13 13:49:34');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:49:34');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 13:49:34');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:49:34');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 13:49:35');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:49:35');
INSERT INTO `manageropt` VALUES ('test002', '111', 3, 3, 'UC', '2026-07-13 13:49:35');
INSERT INTO `manageropt` VALUES ('0000test01', '', 2147483647, 0, 'UC', '2026-07-13 13:49:35');
INSERT INTO `manageropt` VALUES ('test03', '', 3, 3, 'UC', '2026-07-13 13:49:36');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:50:28');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 13:50:28');
INSERT INTO `manageropt` VALUES ('test03', '', 3, 3, 'UC', '2026-07-13 13:51:28');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:51:28');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 13:51:28');
INSERT INTO `manageropt` VALUES ('0000test002', '', 2147483647, 0, 'UC', '2026-07-13 13:53:37');
INSERT INTO `manageropt` VALUES ('0000test002', '', 2147483647, 0, 'UC', '2026-07-13 13:53:37');
INSERT INTO `manageropt` VALUES ('0000test01', '', 2147483647, 0, 'UC', '2026-07-13 13:53:37');
INSERT INTO `manageropt` VALUES ('test03', '', 3, 3, 'UC', '2026-07-13 13:53:37');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:53:38');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 13:53:38');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:53:38');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 13:53:38');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:53:39');
INSERT INTO `manageropt` VALUES ('test002', '111', 3, 3, 'UC', '2026-07-13 13:53:39');
INSERT INTO `manageropt` VALUES ('0000test01', '', 2147483647, 0, 'UC', '2026-07-13 13:53:39');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:53:39');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 13:53:39');
INSERT INTO `manageropt` VALUES ('test03', '', 3, 3, 'UC', '2026-07-13 13:54:36');
INSERT INTO `manageropt` VALUES ('test01', '测试勿动', 1, 3, 'UC', '2026-07-13 13:56:36');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 3, 'UC', '2026-07-13 13:56:36');
INSERT INTO `manageropt` VALUES ('test03', '', 1, 6, 'UC', '2026-07-13 17:51:06');
INSERT INTO `manageropt` VALUES ('test03', '', 1, 6, 'UC', '2026-07-13 17:52:04');
INSERT INTO `manageropt` VALUES ('test03', '', 1, 6, 'UC', '2026-07-13 17:53:04');
INSERT INTO `manageropt` VALUES ('test03', '', 1, 6, 'UC', '2026-07-13 17:55:07');
INSERT INTO `manageropt` VALUES ('test03', '', 1, 6, 'UC', '2026-07-13 17:58:04');
INSERT INTO `manageropt` VALUES ('test002', '', 3, 6, 'UC', '2026-07-14 10:39:16');
INSERT INTO `manageropt` VALUES ('test002', '', 15, 0, 'UC', '2026-07-14 10:39:16');
INSERT INTO `manageropt` VALUES ('test002', '', 27, 9, 'UC', '2026-07-14 10:39:16');
INSERT INTO `manageropt` VALUES ('test002', '', 25, 9, 'UC', '2026-07-14 10:39:17');
INSERT INTO `manageropt` VALUES ('test01', '', 1, 9, 'UC', '2026-07-14 10:39:17');
INSERT INTO `manageropt` VALUES ('test01', '', 1, 9, 'UC', '2026-07-14 10:41:15');
INSERT INTO `manageropt` VALUES ('test002', '111', 27, 9, 'UC', '2026-07-14 10:42:15');
INSERT INTO `manageropt` VALUES ('test002', '111', 25, 9, 'UC', '2026-07-14 10:42:15');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 6, 'UC', '2026-07-14 17:13:31');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 6, 'UC', '2026-07-14 17:13:46');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 6, 'UC', '2026-07-14 17:14:46');
INSERT INTO `manageropt` VALUES ('test002', '111', 1, 6, 'UC', '2026-07-14 17:16:46');

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
INSERT INTO `parabet` VALUES (2006, 2, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `parabet` VALUES (2007, 2, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `parabet` VALUES (2008, 2, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `parabet` VALUES (2009, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2010, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2011, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2012, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2013, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2014, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2015, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2016, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2017, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2018, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2019, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2020, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2021, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2022, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2023, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2024, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2025, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2026, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2027, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2028, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2029, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2030, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2031, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2032, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2033, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2034, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2035, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2036, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2037, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2038, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2039, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2040, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2041, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2042, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2043, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2044, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2045, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2046, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2047, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2048, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2049, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2050, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2051, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2052, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2053, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2054, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2055, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2056, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2057, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2058, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2059, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2060, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2061, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2062, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2063, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2064, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2065, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2066, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2067, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2068, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2069, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2070, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2071, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2072, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2073, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2074, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2075, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2076, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2077, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2078, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2079, 2, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (2080, 2, 4, 4, 1, 0, 0, 1, 30, 0);
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
INSERT INTO `parabet` VALUES (10025, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10026, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10027, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10028, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10029, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10030, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10031, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10032, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10033, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10034, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10035, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10036, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10037, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10038, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10039, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10040, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10041, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10042, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10043, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10044, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10045, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10046, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10047, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10048, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10049, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10050, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10051, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10052, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10053, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10054, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10055, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10056, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10057, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10058, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10059, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10060, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10061, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10062, 10, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (10063, 10, 4, 4, 1, 0, 0, 1, 30, 0);
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
INSERT INTO `parabet` VALUES (40000, 40, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (40001, 40, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (40002, 40, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (47000, 47, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (47001, 47, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (47002, 47, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (47003, 47, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (47004, 47, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (47005, 47, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (47006, 47, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (47007, 47, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (47008, 47, 4, 4, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (53000, 53, 5, 5, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (53001, 53, 5, 5, 1, 0, 0, 1, 30, 0);
INSERT INTO `parabet` VALUES (53002, 53, 5, 5, 1, 0, 0, 1, 30, 0);

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
INSERT INTO `parabetroom` VALUES (10000, 10, 10, 8, 1000, 30, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '桌台1', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (10001, 10, 10, 8, 1000, 20, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '桌台2', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (10002, 10, 10, 8, 1000, 29, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '桌台3', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (47000, 47, 10, 3, 1000, 0, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '桌台1', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (47001, 47, 10, 3, 1000, 0, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '桌台2', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (47002, 47, 10, 3, 1000, 0, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '桌台3', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (2000, 2, 10, 9, 1000, 0, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '桌台1', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (2001, 2, 10, 9, 1000, 0, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '桌台2', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (2002, 2, 10, 9, 1000, 20, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '桌台3', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (29000, 29, 10, 3, 1000, 0, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '桌台1', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (29001, 29, 10, 3, 1000, 1, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '桌台2', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (29002, 29, 10, 3, 1000, 1, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '桌台3', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (2003, 2, 10, 9, 1000, 10, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '004', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (16000, 16, 10, 1, 1000, 10, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, NULL, 6, 0, b'1', b'1');
INSERT INTO `parabetroom` VALUES (16001, 16, 10, 1, 1000, 10, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, NULL, 6, 0, b'1', b'1');
INSERT INTO `parabetroom` VALUES (16002, 16, 10, 1, 1000, 10, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, NULL, 6, 0, b'1', b'1');
INSERT INTO `parabetroom` VALUES (10003, 10, 10, 8, 1000, 10, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '78', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (10004, 10, 10, 8, 1000, 10, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '78', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (15000, 15, 10, 1, 1000, 10, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '初级桌1', 1, 0, b'1', b'1');
INSERT INTO `parabetroom` VALUES (15001, 15, 10, 1, 1000, 10, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '初级桌2', 1, 0, b'1', b'1');
INSERT INTO `parabetroom` VALUES (15002, 15, 10, 1, 1000, 10, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '初级桌3', 1, 0, b'1', b'1');
INSERT INTO `parabetroom` VALUES (10005, 10, 10, 8, 1000, 20, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '1', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (10006, 10, 10, 8, 1000, 20, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '5', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (10007, 10, 10, 8, 1000, 20, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '5', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (2004, 2, 10, 9, 1000, 30, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '01', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (2005, 2, 10, 9, 1000, 30, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, '01', 6, 120, b'1', b'1');
INSERT INTO `parabetroom` VALUES (2006, 2, 0, 9, 1000, 100, 0, 0, 0, 0, 10000, 1, 10000, 0, 0, 0, 100, '0,0,0,0,0', 0, '', 6, 0, b'1', b'1');
INSERT INTO `parabetroom` VALUES (2007, 2, 0, 9, 1000, 99, 0, 0, 0, 0, 10000, 1, 10000, 0, 0, 0, 100, '0,0,0,0,0', 0, '555', 6, 0, b'1', b'1');
INSERT INTO `parabetroom` VALUES (2008, 2, 0, 9, 1000, 99, 0, 0, 0, 0, 10000, 1, 10000, 0, 0, 0, 100, '0,0,0,0,0', 0, '555', 6, 0, b'1', b'1');
INSERT INTO `parabetroom` VALUES (53000, 53, 10, 1, 10000, 100, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '100,500,1000,5000,10000', 0, '机台1', 1, 0, b'1', b'1');
INSERT INTO `parabetroom` VALUES (53001, 53, 10, 1, 10000, 100, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '100,500,1000,5000,10000', 0, '机台2', 1, 0, b'1', b'1');
INSERT INTO `parabetroom` VALUES (53002, 53, 10, 1, 10000, 100, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '100,500,1000,5000,10000', 0, '机台3', 1, 0, b'1', b'1');
INSERT INTO `parabetroom` VALUES (40000, 40, 10, 1, 1000, 10, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, NULL, 6, 0, b'1', b'1');
INSERT INTO `parabetroom` VALUES (40001, 40, 10, 1, 1000, 10, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, NULL, 6, 0, b'1', b'1');
INSERT INTO `parabetroom` VALUES (40002, 40, 10, 1, 1000, 10, 1000, 10, 1000, 10, 10000, 1, 0, 500000, 3000, 10000, 100, '1,5,10,15,20', 0, NULL, 6, 0, b'1', b'1');

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
INSERT INTO `paracard` VALUES (37000, 37, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (37001, 37, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (37002, 37, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (37003, 37, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (37004, 37, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (37005, 37, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (37006, 37, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (37007, 37, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (37008, 37, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (37009, 37, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (37010, 37, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (37011, 37, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (37012, 37, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (37013, 37, '3434453555777533', 0);
INSERT INTO `paracard` VALUES (37014, 37, '3434453555777533', 0);

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
INSERT INTO `parafish` VALUES (6000, 6, 6, 6, 1);
INSERT INTO `parafish` VALUES (6001, 6, 6, 6, 1);
INSERT INTO `parafish` VALUES (6002, 6, 6, 6, 1);
INSERT INTO `parafish` VALUES (6003, 6, 6, 6, 1);
INSERT INTO `parafish` VALUES (6004, 6, 6, 6, 1);
INSERT INTO `parafish` VALUES (6005, 6, 6, 6, 1);
INSERT INTO `parafish` VALUES (6006, 6, 6, 6, 1);
INSERT INTO `parafish` VALUES (6007, 6, 6, 6, 1);
INSERT INTO `parafish` VALUES (6008, 6, 6, 6, 1);
INSERT INTO `parafish` VALUES (6009, 6, 6, 6, 1);
INSERT INTO `parafish` VALUES (6010, 6, 6, 6, 1);
INSERT INTO `parafish` VALUES (13000, 13, 6, 6, 1);
INSERT INTO `parafish` VALUES (13001, 13, 6, 6, 1);
INSERT INTO `parafish` VALUES (13002, 13, 6, 6, 1);
INSERT INTO `parafish` VALUES (19000, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19001, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19002, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (19003, 19, 6, 6, 1);
INSERT INTO `parafish` VALUES (21000, 21, 6, 6, 1);
INSERT INTO `parafish` VALUES (21001, 21, 6, 6, 1);
INSERT INTO `parafish` VALUES (21002, 21, 6, 6, 1);
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
INSERT INTO `parafish` VALUES (33000, 33, 6, 6, 1);
INSERT INTO `parafish` VALUES (33001, 33, 6, 6, 1);
INSERT INTO `parafish` VALUES (33002, 33, 6, 6, 1);
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
INSERT INTO `paragame` VALUES (2, 9, 6);
INSERT INTO `paragame` VALUES (3, 1, 6);
INSERT INTO `paragame` VALUES (5, 3, 1);
INSERT INTO `paragame` VALUES (6, 1, 6);
INSERT INTO `paragame` VALUES (10, 8, 6);
INSERT INTO `paragame` VALUES (13, 1, 6);
INSERT INTO `paragame` VALUES (14, 3, 1);
INSERT INTO `paragame` VALUES (15, 3, 1);
INSERT INTO `paragame` VALUES (16, 3, 1000);
INSERT INTO `paragame` VALUES (19, 1, 6);
INSERT INTO `paragame` VALUES (21, 1, 6);
INSERT INTO `paragame` VALUES (22, 3, 6);
INSERT INTO `paragame` VALUES (29, 3, 6);
INSERT INTO `paragame` VALUES (32, 1, 6);
INSERT INTO `paragame` VALUES (33, 1, 6);
INSERT INTO `paragame` VALUES (37, 3, 1);
INSERT INTO `paragame` VALUES (40, 3, 1000);
INSERT INTO `paragame` VALUES (42, 3, 6);
INSERT INTO `paragame` VALUES (44, 3, 1);
INSERT INTO `paragame` VALUES (47, 3, 6);
INSERT INTO `paragame` VALUES (49, 1, 6);
INSERT INTO `paragame` VALUES (51, 3, 6);
INSERT INTO `paragame` VALUES (52, 3, 1);
INSERT INTO `paragame` VALUES (53, 3, 1);

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
INSERT INTO `pararoom` VALUES (3000, 3, 5, 10, 100, 10000, 1, 10000, 1, 0, 0, NULL, NULL, 6, 0, b'1', b'1', 100, 1000);
INSERT INTO `pararoom` VALUES (5000, 5, 3, 10, 1000, 10000, 1, 0, 0, 0, 0, 100, '桌台1', 0, 0, b'1', b'1', 100, 10000);
INSERT INTO `pararoom` VALUES (5001, 5, 3, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 0, 0, b'1', b'1', 100, 10000);
INSERT INTO `pararoom` VALUES (5002, 5, 3, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 0, 0, b'1', b'1', 100, 10000);
INSERT INTO `pararoom` VALUES (6000, 6, 9, 100, 1000, 10000, 1, 10000, 1, 0, 0, NULL, NULL, 6, 0, b'1', b'1', 0, 0);
INSERT INTO `pararoom` VALUES (13000, 13, 3, 100, 1000, 10000, 1, 10000, 1, 0, 0, NULL, NULL, 6, 0, b'1', b'1', 0, 0);
INSERT INTO `pararoom` VALUES (14000, 14, 3, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 0, 0, b'1', b'1', 100, 10000);
INSERT INTO `pararoom` VALUES (14001, 14, 5, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 0, 0, b'1', b'1', 100, 10000);
INSERT INTO `pararoom` VALUES (14002, 14, 5, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 0, 0, b'1', b'1', 100, 10000);
INSERT INTO `pararoom` VALUES (15000, 15, 3, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 0, 0, b'1', b'1', 100, 10000);
INSERT INTO `pararoom` VALUES (15001, 15, 5, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 0, 0, b'1', b'1', 100, 10000);
INSERT INTO `pararoom` VALUES (15002, 15, 5, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 0, 0, b'1', b'1', 100, 10000);
INSERT INTO `pararoom` VALUES (19000, 19, 4, 100, 1000, 10000, 1, 10000, 1, 0, 0, NULL, NULL, 6, 0, b'1', b'1', 0, 0);
INSERT INTO `pararoom` VALUES (21000, 21, 3, 100, 1000, 10000, 1, 10000, 1, 0, 0, NULL, NULL, 6, 0, b'1', b'1', 0, 0);
INSERT INTO `pararoom` VALUES (22000, 22, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (22001, 22, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (22002, 22, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (32000, 32, 3, 100, 1000, 10000, 1, 10000, 1, 0, 0, NULL, NULL, 6, 0, b'1', b'1', 0, 0);
INSERT INTO `pararoom` VALUES (33000, 33, 3, 100, 1000, 10000, 1, 10000, 1, 0, 0, NULL, NULL, 6, 0, b'1', b'1', 0, 0);
INSERT INTO `pararoom` VALUES (37000, 37, 5, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 6, 0, b'1', b'1', 0, 0);
INSERT INTO `pararoom` VALUES (37001, 37, 5, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 6, 0, b'1', b'1', 0, 0);
INSERT INTO `pararoom` VALUES (37002, 37, 5, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 6, 0, b'1', b'1', 0, 0);
INSERT INTO `pararoom` VALUES (42000, 42, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (42001, 42, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (42002, 42, 3, 100, 1000, 10000, 1, 10000, 100, 0, 0, 100, NULL, 6, 0, b'1', b'1', 1000, 10000);
INSERT INTO `pararoom` VALUES (44000, 44, 3, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 0, 0, b'1', b'1', 100, 10000);
INSERT INTO `pararoom` VALUES (44001, 44, 5, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 0, 0, b'1', b'1', 100, 10000);
INSERT INTO `pararoom` VALUES (44002, 44, 5, 10, 1000, 10000, 1, 10000, 0, 0, 0, 100, NULL, 0, 0, b'1', b'1', 100, 10000);
INSERT INTO `pararoom` VALUES (49000, 49, 3, 100, 1000, 10000, 1, 10000, 1, 0, 0, NULL, NULL, 6, 0, b'1', b'1', 0, 0);
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
INSERT INTO `rank` VALUES (4, 1000, 1215480, 1000, 1777453755, 1, 0, '999999', '999999', '999999');
INSERT INTO `rank` VALUES (4, 1001, 1, 1001, 1777453755, 1, 0, '999999', '999999', '999999');
INSERT INTO `rank` VALUES (5, 2, 137856, 137856, 1777313485, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (5, 6, 64000, 2, 1779475813, 0, 0, 'plm123', 'plm123', '超级炸弹(800倍)');
INSERT INTO `rank` VALUES (5, 10, 35000, 35000, 1777475491, 0, 0, '55555', '55555', '中大奖');
INSERT INTO `rank` VALUES (5, 19, 5480000, 4, 1777371017, 0, 0, '123123', '123123', '全屏炸弹(548倍)');
INSERT INTO `rank` VALUES (5, 21, 3900, 0, 1777466054, 0, 0, '55555', '55555', '金鲨(78倍)');
INSERT INTO `rank` VALUES (5, 22, 9860, 2, 1777402726, 0, 0, '321321', '321321', '全屏炸弹(493倍)');
INSERT INTO `rank` VALUES (5, 32, 37950, 2, 1777558066, 0, 0, 'ijb222', 'ijb222', '超级炸弹(759倍)');
INSERT INTO `rank` VALUES (5, 33, 495000, 0, 1699934202, 0, 0, '11111', '11111', '巨鳄(500倍)');
INSERT INTO `rank` VALUES (5, 1000, 999999, 1000, 1777295667, 1, 0, '121212', '121212', '121212');
INSERT INTO `rank` VALUES (5, 1001, 1, 1001, 1777368326, 1, 0, '123123', '123123', '123123');
INSERT INTO `rank` VALUES (6, 2, 137856, 137856, 1777313527, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (6, 6, 63760, 1, 1779475644, 0, 0, 'plm123', 'plm123', '牛魔王(797倍)');
INSERT INTO `rank` VALUES (6, 10, 33500, 33500, 1777297588, 0, 0, '55555', '55555', '中大奖');
INSERT INTO `rank` VALUES (6, 19, 5330000, 2, 1777371022, 0, 0, '123123', '123123', '金龟(533倍)');
INSERT INTO `rank` VALUES (6, 21, 3700, 0, 1777466021, 0, 0, '55555', '55555', '金鲨(74倍)');
INSERT INTO `rank` VALUES (6, 22, 6000, 1, 1777402545, 0, 0, '321321', '321321', '黄金轰炸机(300倍)');
INSERT INTO `rank` VALUES (6, 32, 37800, 2, 1777468458, 0, 0, '55555', '55555', '超级炸弹(756倍)');
INSERT INTO `rank` VALUES (6, 33, 495000, 0, 1699934324, 0, 0, '11111', '11111', '巨鳄(500倍)');
INSERT INTO `rank` VALUES (6, 1000, 999819, 1000, 1777369518, 1, 0, '321321', '321321', '321321');
INSERT INTO `rank` VALUES (6, 1001, 1, 1001, 1777369446, 1, 0, '321321', '321321', '321321');
INSERT INTO `rank` VALUES (7, 2, 137856, 137856, 1777313609, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (7, 6, 63440, 2, 1779475982, 0, 0, 'plm123', 'plm123', '超级炸弹(793倍)');
INSERT INTO `rank` VALUES (7, 10, 28600, 28600, 1777556767, 0, 0, 'okn122', 'okn122', '中大奖');
INSERT INTO `rank` VALUES (7, 19, 4990000, 4, 1700078046, 0, 0, 'woshini', 'woshini', '全屏炸弹(499倍)');
INSERT INTO `rank` VALUES (7, 21, 3100, 0, 1777567362, 0, 0, 'ijb222', 'ijb222', '金鲨(62倍)');
INSERT INTO `rank` VALUES (7, 22, 6000, 1, 1777402595, 0, 0, '321321', '321321', '黄金轰炸机(300倍)');
INSERT INTO `rank` VALUES (7, 32, 37800, 2, 1777558727, 0, 0, 'plm123', 'plm123', '超级炸弹(756倍)');
INSERT INTO `rank` VALUES (7, 33, 467280, 1, 1699934209, 0, 0, '11111', '11111', '局部炸弹(472倍)');
INSERT INTO `rank` VALUES (7, 1000, 998880, 1000, 1779357694, 1, 0, '112244', '112244', '112244');
INSERT INTO `rank` VALUES (7, 1001, 1, 1001, 1777428730, 1, 0, '777777', '777777', '777777');
INSERT INTO `rank` VALUES (8, 2, 137856, 137856, 1777313650, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (8, 6, 62560, 1, 1779476504, 0, 0, 'plm123', 'plm123', '牛魔王(782倍)');
INSERT INTO `rank` VALUES (8, 10, 28000, 28000, 1777464610, 0, 0, '55555', '55555', '中大奖');
INSERT INTO `rank` VALUES (8, 19, 4830000, 3, 1700061876, 0, 0, 'woshini', 'woshini', '局部炸弹(483倍)');
INSERT INTO `rank` VALUES (8, 21, 2650, 0, 1777465938, 0, 0, '55555', '55555', '金鲨(53倍)');
INSERT INTO `rank` VALUES (8, 22, 6000, 1, 1777402236, 0, 0, '321321', '321321', '黄金轰炸机(300倍)');
INSERT INTO `rank` VALUES (8, 32, 37750, 2, 1777558576, 0, 0, 'ijb222', 'ijb222', '超级炸弹(755倍)');
INSERT INTO `rank` VALUES (8, 33, 42500, 2, 1777569258, 0, 0, 'ijb222', 'ijb222', '超级炸弹(850倍)');
INSERT INTO `rank` VALUES (8, 1000, 638145, 1000, 1777468799, 1, 0, '55555', '55555', '55555');
INSERT INTO `rank` VALUES (8, 1001, 1, 1001, 1777454276, 1, 0, '55555', '55555', '55555');
INSERT INTO `rank` VALUES (9, 2, 137856, 137856, 1777313733, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (9, 6, 62240, 2, 1779517263, 0, 0, 'ijb222', 'ijb222', '超级炸弹(778倍)');
INSERT INTO `rank` VALUES (9, 10, 28000, 28000, 1777478561, 0, 0, '55555', '55555', '中大奖');
INSERT INTO `rank` VALUES (9, 19, 4300000, 3, 1777370917, 0, 0, '123123', '123123', '局部炸弹(430倍)');
INSERT INTO `rank` VALUES (9, 21, 2650, 0, 1777465938, 0, 0, '55555', '55555', '金鲨(53倍)');
INSERT INTO `rank` VALUES (9, 22, 6000, 1, 1777402733, 0, 0, '321321', '321321', '黄金轰炸机(300倍)');
INSERT INTO `rank` VALUES (9, 32, 36550, 2, 1777558663, 0, 0, 'ijb222', 'ijb222', '超级炸弹(731倍)');
INSERT INTO `rank` VALUES (9, 33, 25000, 0, 1777569176, 0, 0, 'ijb222', 'ijb222', '巨鳄(500倍)');
INSERT INTO `rank` VALUES (9, 1000, 454564, 1000, 1784169590, 1, 0, 'test002', '111', '111');
INSERT INTO `rank` VALUES (9, 1001, 1, 1001, 1777456412, 1, 0, '666666', '666666', '666666');
INSERT INTO `rank` VALUES (10, 2, 137856, 137856, 1777313774, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (10, 6, 60720, 2, 1779476135, 0, 0, 'plm123', 'plm123', '超级炸弹(759倍)');
INSERT INTO `rank` VALUES (10, 10, 28000, 28000, 1777475848, 0, 0, '55555', '55555', '中大奖');
INSERT INTO `rank` VALUES (10, 19, 3960000, 2, 1777370890, 0, 0, '123123', '123123', '金龟(396倍)');
INSERT INTO `rank` VALUES (10, 21, 2650, 0, 1777567390, 0, 0, 'ijb222', 'ijb222', '金鲨(53倍)');
INSERT INTO `rank` VALUES (10, 22, 6000, 1, 1777402824, 0, 0, '321321', '321321', '黄金轰炸机(300倍)');
INSERT INTO `rank` VALUES (10, 32, 36200, 2, 1777558551, 0, 0, 'ijb222', 'ijb222', '超级炸弹(724倍)');
INSERT INTO `rank` VALUES (10, 33, 25000, 0, 1777569205, 0, 0, 'ijb222', 'ijb222', '巨鳄(500倍)');
INSERT INTO `rank` VALUES (10, 1000, 310930, 1000, 1783663558, 1, 0, 'test03', 'test03', 'test03');
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
INSERT INTO `rank` VALUES (14, 1000, 65307, 1000, 1784182229, 1, 0, 'test01', '测试勿动', '测试勿动');
INSERT INTO `rank` VALUES (14, 1001, 1, 1001, 1779276257, 1, 0, '112233', '112233', '112233');
INSERT INTO `rank` VALUES (15, 2, 137856, 137856, 1777314063, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (15, 6, 53120, 2, 1779477070, 0, 0, 'plm123', 'plm123', '超级炸弹(664倍)');
INSERT INTO `rank` VALUES (15, 10, 21000, 21000, 1777297446, 0, 0, '55555', '55555', '中大奖');
INSERT INTO `rank` VALUES (15, 19, 1740000, 5, 1700077840, 0, 0, 'woshini', 'woshini', '大三元(174倍)');
INSERT INTO `rank` VALUES (15, 32, 34100, 2, 1777557605, 0, 0, 'plm123', 'plm123', '超级炸弹(682倍)');
INSERT INTO `rank` VALUES (15, 33, 23000, 1, 1777557678, 0, 0, 'plm123', 'plm123', '局部炸弹(460倍)');
INSERT INTO `rank` VALUES (15, 1000, 50000, 1000, 1700051941, 1, 0, 'woshini', 'woshini', 'woshini');
INSERT INTO `rank` VALUES (15, 1001, 1, 1001, 1777466185, 1, 0, '6758854', '6758854', '6758854');
INSERT INTO `rank` VALUES (16, 2, 137856, 137856, 1777314145, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (16, 6, 53040, 1, 1779709076, 0, 0, 'ijb222', 'ijb222', '牛魔王(663倍)');
INSERT INTO `rank` VALUES (16, 10, 20000, 20000, 1777478276, 0, 0, '55555', '55555', '中大奖');
INSERT INTO `rank` VALUES (16, 19, 1740000, 5, 1700051002, 0, 0, '381185127', '381185127', '大三元(174倍)');
INSERT INTO `rank` VALUES (16, 32, 33600, 2, 1777468485, 0, 0, '55555', '55555', '超级炸弹(672倍)');
INSERT INTO `rank` VALUES (16, 33, 8500, 1, 1777557994, 0, 0, 'plm123', 'plm123', '局部炸弹(170倍)');
INSERT INTO `rank` VALUES (16, 1000, 27462, 1000, 1779714798, 1, 0, 'a1314', 'a1314', 'a1314');
INSERT INTO `rank` VALUES (16, 1001, 1, 1001, 1778580606, 1, 0, '898989', '898989', '898989');
INSERT INTO `rank` VALUES (17, 2, 137856, 137856, 1777314187, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (17, 6, 52960, 2, 1779479185, 0, 0, 'ijb222', 'ijb222', '超级炸弹(662倍)');
INSERT INTO `rank` VALUES (17, 10, 20000, 20000, 1777475919, 0, 0, '55555', '55555', '中大奖');
INSERT INTO `rank` VALUES (17, 19, 1740000, 5, 1700078327, 0, 0, 'woshini', 'woshini', '大三元(174倍)');
INSERT INTO `rank` VALUES (17, 32, 31200, 2, 1777558687, 0, 0, 'ijb222', 'ijb222', '超级炸弹(624倍)');
INSERT INTO `rank` VALUES (17, 1000, 25215, 1000, 1779474536, 1, 0, 'plm123', 'plm123', 'plm123');
INSERT INTO `rank` VALUES (17, 1001, 1, 1001, 1777468005, 1, 0, '66455', '66455', '66455');
INSERT INTO `rank` VALUES (18, 2, 137856, 137856, 1777314269, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (18, 6, 52880, 1, 1779512384, 0, 0, 'plm123', 'plm123', '牛魔王(661倍)');
INSERT INTO `rank` VALUES (18, 10, 20000, 20000, 1777476205, 0, 0, '55555', '55555', '中大奖');
INSERT INTO `rank` VALUES (18, 19, 1740000, 5, 1700078909, 0, 0, 'woshini', 'woshini', '大三元(174倍)');
INSERT INTO `rank` VALUES (18, 32, 29350, 2, 1777468376, 0, 0, '55555', '55555', '超级炸弹(587倍)');
INSERT INTO `rank` VALUES (18, 1000, 20005, 1000, 1699933775, 1, 0, '11111', '11111', '11111');
INSERT INTO `rank` VALUES (18, 1001, 1, 1001, 1777488160, 1, 0, '2352314623', '2352314623', '2352314623');
INSERT INTO `rank` VALUES (19, 2, 137856, 137856, 1777314310, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (19, 6, 51440, 2, 1779709180, 0, 0, 'ijb222', 'ijb222', '超级炸弹(643倍)');
INSERT INTO `rank` VALUES (19, 10, 20000, 20000, 1777303833, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (19, 19, 1740000, 5, 1700079202, 0, 0, 'woshini', 'woshini', '大三元(174倍)');
INSERT INTO `rank` VALUES (19, 32, 28600, 2, 1777557913, 0, 0, 'ijb222', 'ijb222', '超级炸弹(572倍)');
INSERT INTO `rank` VALUES (19, 1000, 20001, 1000, 1779708184, 1, 0, '168169', '168169', '168169');
INSERT INTO `rank` VALUES (19, 1001, 1, 1001, 1784182229, 1, 2, 'test01', '测试勿动', '测试勿动');
INSERT INTO `rank` VALUES (20, 2, 137856, 137856, 1777314352, 0, 0, '121212', '121212', '中大奖');
INSERT INTO `rank` VALUES (20, 6, 51280, 2, 1779474830, 0, 0, 'plm123', 'plm123', '超级炸弹(641倍)');
INSERT INTO `rank` VALUES (20, 10, 20000, 20000, 1777474992, 0, 0, '55555', '55555', '中大奖');
INSERT INTO `rank` VALUES (20, 19, 1740000, 5, 1700079268, 0, 0, 'woshini', 'woshini', '大三元(174倍)');
INSERT INTO `rank` VALUES (20, 32, 27750, 2, 1777558263, 0, 0, 'ijb222', 'ijb222', '超级炸弹(555倍)');
INSERT INTO `rank` VALUES (20, 1000, 19972, 1000, 1779441863, 1, 0, 'mm23456', 'mm23456', 'mm23456');

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
INSERT INTO `rechargerecords` VALUES ('1b4e35ab5b7d4d1e96227d9b93b58278', 20, 455564, 0, 455564, 'test01', 0, 'admin', '', 1, '2026-07-14 14:46:21');
INSERT INTO `rechargerecords` VALUES ('3b839197be314eaba60383fc8f4fe6ff', 20, 155465, 0, 155465, 'test03', 0, 'admin', '', 1, '2026-07-09 09:46:46');
INSERT INTO `rechargerecords` VALUES ('85c8ed9d99574db18e52488b5335fd83', 20, 4501113, 0, 4501113, 'test01', 0, 'admin', '', 1, '2026-07-14 14:40:24');
INSERT INTO `rechargerecords` VALUES ('903c4563da6c42bdae1cc8023dceaefd', 20, 155465, 155465, 310930, 'test03', 0, 'admin', '', 1, '2026-07-09 09:47:09');
INSERT INTO `rechargerecords` VALUES ('9c36b000c1db459bbff7e5306241edd9', 20, 4501113, 4501113, 9002226, 'test01', 0, 'admin', '', 1, '2026-07-14 14:40:27');
INSERT INTO `rechargerecords` VALUES ('9ca0dd8a7cc148d298ebfe8654a2a433', 20, 1415552, 0, 1415552, 'test01', 0, 'admin', '', 1, '2026-07-14 17:15:22');
INSERT INTO `rechargerecords` VALUES ('ae7194e2457d4a54ad45b9f8b1a4e40d', 20, 454564, 0, 454564, 'test002', 0, 'admin', '', 1, '2026-07-14 17:55:02');
INSERT INTO `rechargerecords` VALUES ('cfaf00ebb375497aae91d67d6a713935', 20, 65621, 0, 65621, 'test01', 0, 'admin', '', 1, '2026-07-14 17:38:33');
INSERT INTO `rechargerecords` VALUES ('e506c4ff67b74569af97b124f1c5fa8d', 20, 151533, 1018531, 1170064, 'test01', 0, 'admin', '', 1, '2026-07-14 10:39:08');
INSERT INTO `rechargerecords` VALUES ('f26ee91eea99402faaf46a4fbfc71ecc', 20, 100000, 0, 100000, 'test002', 0, 'admin', '', 1, '2026-07-08 17:18:29');

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
  `OneCoinScore` int(11) NOT NULL DEFAULT 0,
  `BetMin` int(11) NOT NULL DEFAULT 0,
  `BetMax` int(11) NOT NULL DEFAULT 0,
  `CoinsNeed` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`ID`) USING BTREE,
  INDEX `idx_game_room_table`(`GAME_ID`, `RoomIndex`, `TableIndex`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5300390 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '动态桌台配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of roomtableconfig
-- ----------------------------
INSERT INTO `roomtableconfig` VALUES (200000, 2, 0, 0, '桌台1', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (200001, 2, 0, 1, '桌台2', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (200002, 2, 0, 2, '桌台3', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (200003, 2, 0, 3, '004', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (500000, 5, 0, 0, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (500001, 5, 0, 1, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (500002, 5, 0, 2, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (1000000, 10, 0, 0, '', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (1000001, 10, 0, 1, '', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (1000002, 10, 0, 2, '', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (1400000, 14, 0, 0, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (1400001, 14, 0, 1, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (1400002, 14, 0, 2, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (1500000, 15, 0, 0, '桌台1', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (1500001, 15, 0, 1, '桌台2', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (1500002, 15, 0, 2, '桌台3', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (1600000, 16, 0, 0, '明星97', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (2200000, 22, 0, 0, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (2200001, 22, 0, 1, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (2200002, 22, 0, 2, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (2900000, 29, 0, 0, '桌台1', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (2900001, 29, 0, 1, '桌台2', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (2900002, 29, 0, 2, '桌台3', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (2900003, 29, 0, 3, '004', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (4200000, 42, 0, 0, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (4200001, 42, 0, 1, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (4200002, 42, 0, 2, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (4400000, 44, 0, 0, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (4400001, 44, 0, 1, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (4400002, 44, 0, 2, '', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (4700000, 47, 0, 0, '桌台1', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (4700001, 47, 0, 1, '桌台2', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (4700002, 47, 0, 2, '桌台3', 4, '1:1', 0, 0, 120, 1, 0, 0, 1, 6, 0, 0, 0, 0);
INSERT INTO `roomtableconfig` VALUES (5300018, 6, 0, 5, '机台6', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 1, 1, 100, 1000, 10000);
INSERT INTO `roomtableconfig` VALUES (5300019, 6, 0, 6, '机台7', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 1, 1, 100, 1000, 10000);
INSERT INTO `roomtableconfig` VALUES (5300024, 6, 0, 3, '机台4', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6, 1, 10, 1000, 10000);
INSERT INTO `roomtableconfig` VALUES (5300026, 6, 0, 4, '机台5', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6, 1, 50, 1000, 0);
INSERT INTO `roomtableconfig` VALUES (5300314, 6, 0, 1, '05', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6, 1, 55, 1000, 0);
INSERT INTO `roomtableconfig` VALUES (5300318, 6, 0, 8, '006', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6, 1, 366, 1000, 0);
INSERT INTO `roomtableconfig` VALUES (5300319, 6, 0, 9, '003', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6, 1, 352, 1000, 0);
INSERT INTO `roomtableconfig` VALUES (5300343, 3, 0, 1, '机台2', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 20, 1000, 10000);
INSERT INTO `roomtableconfig` VALUES (5300344, 3, 0, 2, '机台3', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 30, 1000, 10000);
INSERT INTO `roomtableconfig` VALUES (5300345, 13, 0, 0, '机台1', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 10, 1000, 10000);
INSERT INTO `roomtableconfig` VALUES (5300346, 13, 0, 1, '机台2', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 20, 1000, 10000);
INSERT INTO `roomtableconfig` VALUES (5300347, 13, 0, 2, '机台3', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 30, 1000, 10000);
INSERT INTO `roomtableconfig` VALUES (5300350, 19, 0, 2, '机台3', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 30, 1000, 10000);
INSERT INTO `roomtableconfig` VALUES (5300351, 21, 0, 0, '机台1', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 10, 1000, 10000);
INSERT INTO `roomtableconfig` VALUES (5300352, 21, 0, 1, '机台2', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 20, 1000, 10000);
INSERT INTO `roomtableconfig` VALUES (5300353, 21, 0, 2, '机台3', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 30, 1000, 10000);
INSERT INTO `roomtableconfig` VALUES (5300354, 32, 0, 0, '机台1', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 10, 1000, 10000);
INSERT INTO `roomtableconfig` VALUES (5300355, 32, 0, 1, '机台2', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 20, 1000, 10000);
INSERT INTO `roomtableconfig` VALUES (5300356, 32, 0, 2, '机台3', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 30, 1000, 10000);
INSERT INTO `roomtableconfig` VALUES (5300357, 33, 0, 0, '机台1', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 10, 1000, 10000);
INSERT INTO `roomtableconfig` VALUES (5300358, 33, 0, 1, '机台2', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 20, 1000, 10000);
INSERT INTO `roomtableconfig` VALUES (5300359, 33, 0, 2, '机台3', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 30, 1000, 10000);
INSERT INTO `roomtableconfig` VALUES (5300360, 49, 0, 0, '机台1', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 10, 1000, 10000);
INSERT INTO `roomtableconfig` VALUES (5300361, 49, 0, 1, '机台2', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 20, 1000, 10000);
INSERT INTO `roomtableconfig` VALUES (5300362, 49, 0, 2, '机台3', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 30, 1000, 10000);
INSERT INTO `roomtableconfig` VALUES (5300363, 19, 0, 3, '124', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6, 1, 50, 1000, 0);
INSERT INTO `roomtableconfig` VALUES (5300368, 53, 0, 0, '001', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 1, 100, 0);
INSERT INTO `roomtableconfig` VALUES (5300370, 40, 0, 2, '003', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 1, 100, 0);
INSERT INTO `roomtableconfig` VALUES (5300371, 53, 0, 5, '007', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 1, 410, 0);
INSERT INTO `roomtableconfig` VALUES (5300372, 40, 0, 1, '002', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 1, 300, 0);
INSERT INTO `roomtableconfig` VALUES (5300373, 40, 0, 0, '001', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 30, 1000, 0);
INSERT INTO `roomtableconfig` VALUES (5300374, 19, 0, 0, '机台1', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6, 1, 10, 1000, 0);
INSERT INTO `roomtableconfig` VALUES (5300375, 19, 0, 1, '机台2', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6, 1, 20, 1000, 0);
INSERT INTO `roomtableconfig` VALUES (5300376, 53, 0, 1, '机台2', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 100, 1000, 0);
INSERT INTO `roomtableconfig` VALUES (5300378, 53, 0, 2, '0031', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 250, 1000, 0);
INSERT INTO `roomtableconfig` VALUES (5300379, 53, 0, 6, '015', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 40, 4100, 0);
INSERT INTO `roomtableconfig` VALUES (5300380, 16, 0, 2, '113', 4, '1:1', 0, 0, 0, 0, 0, 0, 1, 6, 1, 10, 404, 0);
INSERT INTO `roomtableconfig` VALUES (5300381, 6, 0, 2, '机台3', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6, 1, 10, 1000, 0);
INSERT INTO `roomtableconfig` VALUES (5300384, 6, 0, 0, '机台1', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6, 1, 0, 1000, 10000);
INSERT INTO `roomtableconfig` VALUES (5300386, 3, 0, 0, '机台1', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6, 1, 100, 1000, 10000);
INSERT INTO `roomtableconfig` VALUES (5300388, 3, 0, 4, '005', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6, 1, 500, 5200, 10000);
INSERT INTO `roomtableconfig` VALUES (5300389, 3, 0, 3, '004', 4, '1:1', 0, 0, 0, 1, 0, 0, 1, 6, 1, 1, 1500, 10000);

-- ----------------------------
-- Table structure for roomtableconfig_bet
-- ----------------------------
DROP TABLE IF EXISTS `roomtableconfig_bet`;
CREATE TABLE `roomtableconfig_bet`  (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `GAME_ID` int(11) NOT NULL COMMENT '游戏ID',
  `RoomIndex` int(11) NOT NULL DEFAULT 0 COMMENT '房间索引（大厅废除后恒0）',
  `TableIndex` int(11) NOT NULL COMMENT '桌台全局索引',
  `BetTime` int(11) NOT NULL DEFAULT 0 COMMENT '押注时长(秒)',
  `BetMin` int(11) NOT NULL DEFAULT 0 COMMENT '本桌最小押注',
  `BetMax` int(11) NOT NULL DEFAULT 0 COMMENT '本桌最大押注',
  `BankerScoreNeed` int(11) NOT NULL DEFAULT 0 COMMENT '抢庄分数门槛/DT全台敞口上限',
  `ItemSingleScoreLimit` int(11) NOT NULL DEFAULT 0 COMMENT '单门限红(DT填0不校验)',
  `ItemAllScoreLimit` int(11) NOT NULL DEFAULT 0 COMMENT '全台限红(DT填0不校验)',
  `CoinsNeed` int(11) NOT NULL DEFAULT 0 COMMENT '进场金币门槛',
  `OneCoinScore` int(11) NOT NULL DEFAULT 0 COMMENT '1币兑换分',
  `BetScores` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '投注档位串(逗号分隔)',
  `DefaultBetIndex` tinyint(4) NOT NULL DEFAULT 0 COMMENT '默认档位索引(0-based)',
  `BetMinVice` int(11) NOT NULL DEFAULT 0 COMMENT '副玩法大小最小押注(仅Animal)',
  `BetMaxVice` int(11) NOT NULL DEFAULT 0 COMMENT '副玩法大小最大押注(仅Animal)',
  `BetMinDraw` int(11) NOT NULL DEFAULT 0 COMMENT '副玩法和最小押注(仅Animal)',
  `BetMaxDraw` int(11) NOT NULL DEFAULT 0 COMMENT '副玩法和最大押注(仅Animal)',
  PRIMARY KEY (`ID`) USING BTREE,
  INDEX `idx_game_table`(`GAME_ID`, `TableIndex`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 36 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '押注类桌台扩展参数表(按桌)' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of roomtableconfig_bet
-- ----------------------------
INSERT INTO `roomtableconfig_bet` VALUES (1, 10, 0, 0, 10, 30, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (2, 10, 0, 1, 10, 20, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (3, 10, 0, 2, 10, 29, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (4, 47, 0, 0, 10, 0, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (5, 47, 0, 1, 10, 0, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (6, 47, 0, 2, 10, 0, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (7, 2, 0, 0, 10, 0, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (8, 2, 0, 1, 10, 0, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (9, 2, 0, 2, 10, 20, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (10, 29, 0, 0, 10, 0, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (11, 29, 0, 1, 10, 1, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (12, 29, 0, 2, 10, 1, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (13, 2, 0, 3, 10, 10, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (14, 16, 0, 0, 10, 10, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (15, 16, 0, 1, 10, 10, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (16, 16, 0, 2, 10, 10, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (17, 10, 0, 3, 10, 10, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (18, 10, 0, 4, 10, 10, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (19, 15, 0, 0, 10, 10, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (20, 15, 0, 1, 10, 10, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (21, 15, 0, 2, 10, 10, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (22, 10, 0, 5, 10, 20, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (23, 10, 0, 6, 10, 20, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (24, 10, 0, 7, 10, 20, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (25, 2, 0, 4, 10, 30, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (26, 2, 0, 5, 10, 30, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (27, 2, 0, 6, 0, 100, 1000, 0, 0, 0, 10000, 1, '0,0,0,0,0', 0, 0, 0, 0, 0);
INSERT INTO `roomtableconfig_bet` VALUES (28, 2, 0, 7, 0, 99, 1000, 0, 0, 0, 10000, 1, '0,0,0,0,0', 0, 0, 0, 0, 0);
INSERT INTO `roomtableconfig_bet` VALUES (29, 2, 0, 8, 0, 99, 1000, 0, 0, 0, 10000, 1, '0,0,0,0,0', 0, 0, 0, 0, 0);
INSERT INTO `roomtableconfig_bet` VALUES (30, 53, 0, 0, 10, 100, 10000, 500000, 3000, 10000, 0, 1, '100,500,1000,5000,10000', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (31, 53, 0, 1, 10, 100, 10000, 500000, 3000, 10000, 0, 1, '100,500,1000,5000,10000', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (32, 53, 0, 2, 10, 100, 10000, 500000, 3000, 10000, 0, 1, '100,500,1000,5000,10000', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (33, 40, 0, 0, 10, 10, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (34, 40, 0, 1, 10, 10, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);
INSERT INTO `roomtableconfig_bet` VALUES (35, 40, 0, 2, 10, 10, 1000, 500000, 3000, 10000, 0, 1, '1,5,10,15,20', 0, 10, 1000, 10, 1000);

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
) ENGINE = InnoDB AUTO_INCREMENT = 36 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '桌子账目信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of tablecoinrecord
-- ----------------------------
INSERT INTO `tablecoinrecord` VALUES (21, 6, 0, 3, -7800, '2026-07-08 11:49:10');
INSERT INTO `tablecoinrecord` VALUES (22, 6, 1, 1, -1000, '2026-07-08 11:49:38');
INSERT INTO `tablecoinrecord` VALUES (23, 19, 0, 1, 79990, '2026-07-08 17:19:45');
INSERT INTO `tablecoinrecord` VALUES (24, 49, 0, 1, -2600, '2026-07-09 14:37:49');
INSERT INTO `tablecoinrecord` VALUES (25, 5, 0, 4, -10, '2026-07-10 22:11:57');
INSERT INTO `tablecoinrecord` VALUES (26, 49, 0, 3, -300, '2026-07-10 22:33:16');
INSERT INTO `tablecoinrecord` VALUES (27, 49, 0, 2, -1800, '2026-07-13 11:37:44');
INSERT INTO `tablecoinrecord` VALUES (28, 47, 0, 0, -10618154, '2026-07-14 14:05:33');
INSERT INTO `tablecoinrecord` VALUES (29, 6, 0, 1, -9700, '2026-07-14 17:13:41');
INSERT INTO `tablecoinrecord` VALUES (30, 2, 0, 1, -1415554, '2026-07-14 17:15:52');
INSERT INTO `tablecoinrecord` VALUES (31, 2, 0, 3, -87990, '2026-07-14 17:17:58');
INSERT INTO `tablecoinrecord` VALUES (32, 5, 0, 2, -30, '2026-07-14 17:56:40');
INSERT INTO `tablecoinrecord` VALUES (33, 3, 0, 3, -3130, '2026-07-15 14:06:01');
INSERT INTO `tablecoinrecord` VALUES (34, 5, 0, 1, 70, '2026-07-16 11:45:45');
INSERT INTO `tablecoinrecord` VALUES (35, 3, 0, 4, -430, '2026-07-16 14:11:21');

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
) ENGINE = InnoDB AUTO_INCREMENT = 55 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '玩家控制有限状态机表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of usercontrolstatus
-- ----------------------------
INSERT INTO `usercontrolstatus` VALUES (1, 'test01', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-13 11:59:21', '2026-07-13 13:35:14');
INSERT INTO `usercontrolstatus` VALUES (2, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-13 11:59:56', '2026-07-13 12:00:52');
INSERT INTO `usercontrolstatus` VALUES (3, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-13 12:00:52', '2026-07-13 12:01:03');
INSERT INTO `usercontrolstatus` VALUES (4, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-13 12:01:03', '2026-07-13 12:05:41');
INSERT INTO `usercontrolstatus` VALUES (5, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-13 12:05:41', '2026-07-13 12:05:52');
INSERT INTO `usercontrolstatus` VALUES (6, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-13 12:05:52', '2026-07-13 12:06:43');
INSERT INTO `usercontrolstatus` VALUES (7, 'test03', 1, 0, 3, 0, 0, 0, 500, 60, 1, 'admin', '2026-07-13 12:06:00', '2026-07-13 13:37:21');
INSERT INTO `usercontrolstatus` VALUES (8, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-13 12:06:43', '2026-07-13 13:40:51');
INSERT INTO `usercontrolstatus` VALUES (9, 'test01', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-13 13:35:14', '2026-07-13 13:37:13');
INSERT INTO `usercontrolstatus` VALUES (10, 'test01', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-13 13:37:13', '2026-07-13 13:37:30');
INSERT INTO `usercontrolstatus` VALUES (11, 'test03', 1, 0, 3, 0, 0, 0, 500, 60, 1, 'admin', '2026-07-13 13:37:21', '2026-07-13 13:41:08');
INSERT INTO `usercontrolstatus` VALUES (12, 'test01', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-13 13:37:30', '2026-07-13 13:37:36');
INSERT INTO `usercontrolstatus` VALUES (13, 'test01', 1, 0, 3, 0, 0, 0, 300, 60, 1, 'admin', '2026-07-13 13:37:36', '2026-07-13 13:40:56');
INSERT INTO `usercontrolstatus` VALUES (14, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-13 13:40:51', '2026-07-13 13:41:15');
INSERT INTO `usercontrolstatus` VALUES (15, 'test01', 1, 0, 3, 0, 0, 0, 300, 60, 1, 'admin', '2026-07-13 13:40:56', '2026-07-13 13:41:25');
INSERT INTO `usercontrolstatus` VALUES (16, 'test03', 1, 0, 3, 0, 0, 0, 500, 60, 1, 'admin', '2026-07-13 13:41:08', '2026-07-13 13:41:28');
INSERT INTO `usercontrolstatus` VALUES (17, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-13 13:41:15', '2026-07-13 13:41:21');
INSERT INTO `usercontrolstatus` VALUES (18, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-13 13:41:21', '2026-07-13 13:42:00');
INSERT INTO `usercontrolstatus` VALUES (19, 'test01', 1, 0, 3, 0, 0, 0, 300, 60, 1, 'admin', '2026-07-13 13:41:25', '2026-07-13 13:41:31');
INSERT INTO `usercontrolstatus` VALUES (20, 'test03', 1, 0, 3, 0, 0, 0, 500, 60, 1, 'admin', '2026-07-13 13:41:28', '2026-07-13 13:46:08');
INSERT INTO `usercontrolstatus` VALUES (21, 'test01', 1, 0, 3, 0, 0, 0, 300, 60, 1, 'admin', '2026-07-13 13:41:31', '2026-07-13 13:42:09');
INSERT INTO `usercontrolstatus` VALUES (22, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-13 13:42:00', '2026-07-13 13:45:57');
INSERT INTO `usercontrolstatus` VALUES (23, 'test01', 1, 0, 3, 0, 0, 0, 300, 60, 1, 'admin', '2026-07-13 13:42:09', '2026-07-13 13:46:01');
INSERT INTO `usercontrolstatus` VALUES (24, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-13 13:45:57', '2026-07-13 13:46:05');
INSERT INTO `usercontrolstatus` VALUES (25, 'test01', 1, 0, 3, 0, 0, 0, 300, 60, 1, 'admin', '2026-07-13 13:46:01', '2026-07-13 13:46:13');
INSERT INTO `usercontrolstatus` VALUES (26, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-13 13:46:05', '2026-07-13 13:48:52');
INSERT INTO `usercontrolstatus` VALUES (27, 'test03', 1, 0, 3, 0, 0, 0, 500, 60, 1, 'admin', '2026-07-13 13:46:08', '2026-07-13 13:46:17');
INSERT INTO `usercontrolstatus` VALUES (28, 'test01', 1, 0, 3, 0, 0, 0, 300, 60, 1, 'admin', '2026-07-13 13:46:13', '2026-07-13 13:48:48');
INSERT INTO `usercontrolstatus` VALUES (29, 'test03', 1, 0, 3, 0, 0, 0, 500, 60, 1, 'admin', '2026-07-13 13:46:17', '2026-07-13 13:48:56');
INSERT INTO `usercontrolstatus` VALUES (30, 'test01', 1, 0, 3, 0, 0, 0, 300, 60, 1, 'admin', '2026-07-13 13:48:48', '2026-07-13 15:41:11');
INSERT INTO `usercontrolstatus` VALUES (31, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-13 13:48:52', '2026-07-13 14:13:40');
INSERT INTO `usercontrolstatus` VALUES (32, 'test03', 1, 0, 3, 0, 0, 0, 500, 60, 1, 'admin', '2026-07-13 13:48:56', '2026-07-13 15:28:19');
INSERT INTO `usercontrolstatus` VALUES (33, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-13 14:13:40', '2026-07-13 19:45:15');
INSERT INTO `usercontrolstatus` VALUES (34, 'test03', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-13 15:28:19', '2026-07-13 15:49:22');
INSERT INTO `usercontrolstatus` VALUES (35, 'test03', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-13 15:49:22', '2026-07-13 17:51:07');
INSERT INTO `usercontrolstatus` VALUES (36, 'test01', 1, 0, 3, 0, 0, 0, 100, 60, 1, 'admin', '2026-07-13 15:49:35', '2026-07-13 20:09:54');
INSERT INTO `usercontrolstatus` VALUES (37, 'test03', 1, 0, 3, 0, 0, 0, 150, 60, 0, 'admin', '2026-07-13 17:51:07', NULL);
INSERT INTO `usercontrolstatus` VALUES (38, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-13 19:45:15', '2026-07-13 19:58:03');
INSERT INTO `usercontrolstatus` VALUES (39, 'test002', 1, 0, 3, 0, 0, 0, 100, 60, 1, 'admin', '2026-07-13 19:58:03', '2026-07-13 20:02:36');
INSERT INTO `usercontrolstatus` VALUES (40, 'test002', 1, 0, 3, 0, 0, 0, 100, 60, 1, 'admin', '2026-07-13 20:02:36', '2026-07-13 20:03:06');
INSERT INTO `usercontrolstatus` VALUES (41, 'test002', 1, 0, 3, 0, 0, 0, 100, 60, 1, 'admin', '2026-07-13 20:03:06', '2026-07-14 11:17:40');
INSERT INTO `usercontrolstatus` VALUES (42, 'test01', 1, 0, 3, 0, 0, 0, 100, 60, 1, 'admin', '2026-07-13 20:09:54', '2026-07-14 11:24:28');
INSERT INTO `usercontrolstatus` VALUES (43, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-14 11:17:40', '2026-07-14 11:18:05');
INSERT INTO `usercontrolstatus` VALUES (44, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-14 11:18:05', '2026-07-14 11:18:29');
INSERT INTO `usercontrolstatus` VALUES (45, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-14 11:18:29', '2026-07-14 11:18:40');
INSERT INTO `usercontrolstatus` VALUES (46, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-14 11:18:40', '2026-07-14 11:33:31');
INSERT INTO `usercontrolstatus` VALUES (47, 'test01', 1, 0, 3, 0, 0, 0, 100, 60, 2, 'admin', '2026-07-14 11:24:28', '2026-07-14 17:13:40');
INSERT INTO `usercontrolstatus` VALUES (48, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-14 11:33:31', '2026-07-14 11:34:58');
INSERT INTO `usercontrolstatus` VALUES (49, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-14 11:34:58', '2026-07-14 11:35:37');
INSERT INTO `usercontrolstatus` VALUES (50, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-14 11:35:37', '2026-07-14 11:35:47');
INSERT INTO `usercontrolstatus` VALUES (51, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-14 11:35:47', '2026-07-14 11:38:24');
INSERT INTO `usercontrolstatus` VALUES (52, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 1, 'admin', '2026-07-14 11:38:24', '2026-07-14 11:38:45');
INSERT INTO `usercontrolstatus` VALUES (53, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 2, 'admin', '2026-07-14 11:38:45', '2026-07-14 17:10:46');
INSERT INTO `usercontrolstatus` VALUES (54, 'test002', 1, 0, 3, 0, 0, 0, 1000, 60, 2, 'admin', '2026-07-14 17:13:32', '2026-07-14 17:55:02');

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
) ENGINE = InnoDB AUTO_INCREMENT = 342 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

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
INSERT INTO `usercontrolvalue` VALUES (335, 'test002', 0, 0, 0, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (336, 'test01', 0, 0, 0, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (337, 'test03', 2, 1, 6, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (338, '0000test002', -1, -1, 0, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (339, '0000test01', -1, -1, 0, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (340, 'test002', 0, 0, 0, 0, 0);
INSERT INTO `usercontrolvalue` VALUES (341, 'test002', 0, 0, 0, 0, 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 297 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of useroptlog
-- ----------------------------
INSERT INTO `useroptlog` VALUES (114, 'test01', 8, 0, 967388, 0, 0, 19, '2026-07-07 18:44:34', 0, 2, 1);
INSERT INTO `useroptlog` VALUES (115, 'test01', 8, 0, 994833, 0, 0, 19, '2026-07-07 18:46:17', 0, 0, 5);
INSERT INTO `useroptlog` VALUES (116, 'test01', 8, 0, 1024703, 0, 0, 19, '2026-07-07 18:47:42', 0, 0, 5);
INSERT INTO `useroptlog` VALUES (117, 'test01', 7, 0, 1024733, 0, 0, 19, '2026-07-07 18:47:53', 0, 0, 5);
INSERT INTO `useroptlog` VALUES (118, 'test01', 8, 0, 1024733, 0, 0, 19, '2026-07-07 18:47:56', 0, 0, 2);
INSERT INTO `useroptlog` VALUES (119, 'test01', 7, 0, 1023013, 0, 0, 19, '2026-07-07 18:49:41', 0, 0, 2);
INSERT INTO `useroptlog` VALUES (120, 'test002', 8, 0, 0, 0, 0, 29, '2026-07-08 11:27:33', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (121, 'test002', 7, 0, 0, 0, 0, 29, '2026-07-08 11:27:40', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (122, 'test002', 8, 0, 0, 0, 1, 29, '2026-07-08 11:27:41', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (123, 'test002', 7, 0, 0, 0, 1, 29, '2026-07-08 11:27:44', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (124, 'test002', 8, 0, 0, 0, 2, 29, '2026-07-08 11:27:45', 0, 6, 0);
INSERT INTO `useroptlog` VALUES (125, 'test002', 7, 0, 0, 0, 2, 29, '2026-07-08 11:27:48', 0, 6, 0);
INSERT INTO `useroptlog` VALUES (126, 'test002', 8, 0, 0, 0, 0, 29, '2026-07-08 11:27:59', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (127, 'test002', 7, 0, 0, 0, 0, 29, '2026-07-08 11:28:06', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (128, 'test002', 8, 0, 0, 0, 1, 29, '2026-07-08 11:28:08', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (129, 'test002', 7, 0, 0, 0, 1, 29, '2026-07-08 11:28:13', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (130, 'test002', 8, 0, 0, 0, 1, 47, '2026-07-08 11:36:00', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (131, 'test002', 7, 0, 0, 0, 1, 47, '2026-07-08 11:36:04', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (132, 'test002', 8, 0, 0, 0, 1, 47, '2026-07-08 11:36:11', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (133, 'test002', 7, 0, 0, 0, 1, 47, '2026-07-08 11:36:18', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (134, 'test01', 8, 0, 1023013, 0, 0, 6, '2026-07-08 11:48:44', 0, 2, 1);
INSERT INTO `useroptlog` VALUES (135, 'test01', 7, 0, 1015213, 0, 0, 6, '2026-07-08 11:49:10', 0, 2, 1);
INSERT INTO `useroptlog` VALUES (136, 'test01', 8, 0, 1015213, 0, 1, 6, '2026-07-08 11:49:27', 0, 3, 1);
INSERT INTO `useroptlog` VALUES (137, 'test01', 7, 0, 1014213, 0, 1, 6, '2026-07-08 11:49:38', 0, 3, 1);
INSERT INTO `useroptlog` VALUES (138, 'test002', 8, 0, 0, 0, 0, 19, '2026-07-08 13:51:24', 0, 0, 5);
INSERT INTO `useroptlog` VALUES (139, 'test002', 7, 0, 0, 0, 0, 19, '2026-07-08 13:51:36', 0, 0, 5);
INSERT INTO `useroptlog` VALUES (140, 'test002', 8, 0, 0, 0, 0, 19, '2026-07-08 14:21:16', 0, 0, 1);
INSERT INTO `useroptlog` VALUES (141, 'test01', 8, 0, 1014213, 0, 0, 44, '2026-07-08 16:58:45', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (142, 'test01', 7, 0, 1014213, 0, 0, 44, '2026-07-08 16:58:47', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (143, 'test002', 8, 0, 0, 0, 0, 19, '2026-07-08 17:17:54', 0, 0, 4);
INSERT INTO `useroptlog` VALUES (144, 'test002', 0, 0, 100000, 0, 0, 0, '2026-07-08 17:18:29', 0, 0, 4);
INSERT INTO `useroptlog` VALUES (145, 'test002', 7, 0, 90390, 0, 0, 19, '2026-07-08 17:19:45', 0, 0, 4);
INSERT INTO `useroptlog` VALUES (146, 'test03', 0, 0, 310930, 0, 0, 0, '2026-07-09 09:54:28', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (147, 'test002', 8, 0, 90390, 0, 0, 49, '2026-07-09 14:37:29', 0, 0, 4);
INSERT INTO `useroptlog` VALUES (148, 'test002', 7, 0, 88290, 0, 0, 49, '2026-07-09 14:37:49', 0, 0, 4);
INSERT INTO `useroptlog` VALUES (149, 'test01', 8, 0, 1009911, 0, 0, 49, '2026-07-10 13:43:45', 0, 0, 4);
INSERT INTO `useroptlog` VALUES (150, 'test01', 7, 0, 1009911, 0, 0, 49, '2026-07-10 13:44:06', 0, 0, 4);
INSERT INTO `useroptlog` VALUES (151, 'test01', 7, 0, 1009911, 0, 1, 40, '2026-07-10 14:04:22', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (152, 'test01', 7, 0, 1009908, 0, 1, 40, '2026-07-10 14:27:35', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (153, 'test01', 7, 0, 1009908, 0, 1, 40, '2026-07-10 14:46:01', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (154, 'test01', 7, 0, 1011031, 0, 1, 40, '2026-07-10 15:20:38', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (155, 'test01', 7, 0, 1011030, 0, 1, 40, '2026-07-10 15:21:28', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (156, 'test01', 7, 0, 1011026, 0, 1, 40, '2026-07-10 15:23:34', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (157, 'test01', 7, 0, 1013554, 0, 1, 40, '2026-07-10 15:30:33', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (158, 'test01', 7, 0, 1022281, 0, 1, 40, '2026-07-10 15:44:32', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (159, 'test01', 7, 0, 1022281, 0, 1, 40, '2026-07-10 16:32:55', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (160, 'test01', 8, 0, 1022233, 0, 0, 47, '2026-07-10 20:39:12', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (161, 'test01', 7, 0, 1022233, 0, 0, 47, '2026-07-10 20:39:20', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (162, 'test01', 8, 0, 1022233, 0, 0, 47, '2026-07-10 20:39:24', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (163, 'test01', 7, 0, 1022233, 0, 0, 47, '2026-07-10 20:39:26', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (164, 'test01', 8, 0, 1022233, 0, 0, 29, '2026-07-10 20:39:30', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (165, 'test01', 7, 0, 1022233, 0, 0, 29, '2026-07-10 20:39:36', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (166, 'test01', 8, 0, 1022233, 0, 0, 5, '2026-07-10 22:11:53', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (167, 'test01', 7, 0, 1022223, 0, 0, 5, '2026-07-10 22:11:57', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (168, 'test01', 8, 0, 1022223, 0, 0, 2, '2026-07-10 22:12:31', 0, 0, 2);
INSERT INTO `useroptlog` VALUES (169, 'test01', 7, 0, 1022223, 0, 0, 2, '2026-07-10 22:12:41', 0, 0, 2);
INSERT INTO `useroptlog` VALUES (170, 'test01', 8, 0, 1022223, 0, 0, 29, '2026-07-10 22:12:50', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (171, 'test01', 7, 0, 1022223, 0, 0, 29, '2026-07-10 22:12:55', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (172, 'test01', 8, 0, 1022223, 0, 0, 49, '2026-07-10 22:32:50', 0, 2, 0);
INSERT INTO `useroptlog` VALUES (173, 'test01', 7, 0, 1021923, 0, 0, 49, '2026-07-10 22:33:16', 0, 2, 0);
INSERT INTO `useroptlog` VALUES (174, 'test01', 8, 0, 1021923, 0, 0, 19, '2026-07-10 22:33:43', 0, 0, 2);
INSERT INTO `useroptlog` VALUES (175, 'test01', 7, 0, 1020723, 0, 0, 19, '2026-07-10 22:33:51', 0, 0, 2);
INSERT INTO `useroptlog` VALUES (176, 'test01', 7, 0, 1020759, 0, 1, 40, '2026-07-13 11:26:55', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (177, 'test01', 8, 0, 1020755, 0, 0, 49, '2026-07-13 11:36:48', 0, 1, 3);
INSERT INTO `useroptlog` VALUES (178, 'test01', 7, 0, 1018955, 0, 0, 49, '2026-07-13 11:37:44', 0, 1, 3);
INSERT INTO `useroptlog` VALUES (179, 'test01', 7, 0, 1018963, 0, 1, 40, '2026-07-13 14:03:16', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (180, 'test01', 7, 0, 1018995, 0, 1, 40, '2026-07-13 14:09:57', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (181, 'test01', 7, 0, 1019065, 0, 1, 40, '2026-07-13 17:56:29', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (182, 'test01', 8, 0, 1019031, 0, 0, 49, '2026-07-13 18:10:23', 0, 0, 1);
INSERT INTO `useroptlog` VALUES (183, 'test01', 7, 0, 1018531, 0, 0, 49, '2026-07-13 18:10:34', 0, 0, 1);
INSERT INTO `useroptlog` VALUES (184, 'test01', 8, 0, 1018531, 0, 0, 49, '2026-07-13 18:11:35', 0, 0, 2);
INSERT INTO `useroptlog` VALUES (185, 'test01', 7, 0, 1018531, 0, 0, 49, '2026-07-13 18:11:40', 0, 0, 2);
INSERT INTO `useroptlog` VALUES (186, 'test01', 0, 0, 1170064, 0, 0, 0, '2026-07-14 10:39:10', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (187, 'test002', 8, 0, 88290, 0, 0, 19, '2026-07-14 10:40:22', 0, 0, 2);
INSERT INTO `useroptlog` VALUES (188, 'test002', 7, 0, 87990, 0, 0, 19, '2026-07-14 10:43:30', 0, 0, 2);
INSERT INTO `useroptlog` VALUES (189, 'test01', 8, 0, 1170064, 0, 0, 47, '2026-07-14 14:05:01', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (190, 'test01', 7, 0, 0, 0, 0, 47, '2026-07-14 14:05:33', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (191, 'test01', 0, 0, 4501113, 0, 0, 0, '2026-07-14 14:40:26', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (192, 'test01', 0, 0, 9002226, 0, 0, 0, '2026-07-14 14:40:27', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (193, 'test01', 8, 0, 9002226, 0, 0, 47, '2026-07-14 14:41:18', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (194, 'test01', 7, 0, 0, 0, 0, 47, '2026-07-14 14:41:26', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (195, 'test01', 0, 0, 455564, 0, 0, 0, '2026-07-14 14:46:21', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (196, 'test01', 8, 0, 455564, 0, 0, 6, '2026-07-14 17:12:57', 0, 0, 2);
INSERT INTO `useroptlog` VALUES (197, 'test01', 7, 0, 445864, 0, 0, 6, '2026-07-14 17:13:41', 0, 0, 2);
INSERT INTO `useroptlog` VALUES (198, 'test01', 8, 0, 445864, 0, 0, 47, '2026-07-14 17:14:52', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (199, 'test01', 7, 0, 0, 0, 0, 47, '2026-07-14 17:14:55', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (200, 'test01', 8, 0, 0, 0, 0, 29, '2026-07-14 17:15:16', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (201, 'test01', 7, 0, 0, 0, 0, 29, '2026-07-14 17:15:18', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (202, 'test01', 8, 0, 0, 0, 1, 29, '2026-07-14 17:15:19', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (203, 'test01', 7, 0, 0, 0, 1, 29, '2026-07-14 17:15:21', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (204, 'test01', 0, 0, 1415552, 0, 0, 0, '2026-07-14 17:15:24', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (205, 'test01', 8, 0, 1415552, 0, 0, 2, '2026-07-14 17:15:36', 0, 0, 4);
INSERT INTO `useroptlog` VALUES (206, 'test01', 7, 0, 0, 0, 0, 2, '2026-07-14 17:15:52', 0, 0, 4);
INSERT INTO `useroptlog` VALUES (207, 'test002', 8, 0, 87990, 0, 0, 2, '2026-07-14 17:17:53', 0, 2, 3);
INSERT INTO `useroptlog` VALUES (208, 'test002', 7, 0, 0, 0, 0, 2, '2026-07-14 17:17:58', 0, 2, 3);
INSERT INTO `useroptlog` VALUES (209, 'test01', 0, 0, 65621, 0, 0, 0, '2026-07-14 17:38:35', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (210, 'test002', 0, 0, 454564, 0, 0, 0, '2026-07-14 17:55:02', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (211, 'test002', 8, 0, 454564, 0, 0, 5, '2026-07-14 17:55:54', 0, 2, 0);
INSERT INTO `useroptlog` VALUES (212, 'test002', 7, 0, 454564, 0, 0, 5, '2026-07-14 17:56:01', 0, 2, 0);
INSERT INTO `useroptlog` VALUES (213, 'test002', 8, 0, 454564, 0, 0, 14, '2026-07-14 17:56:05', 0, 1, 0);
INSERT INTO `useroptlog` VALUES (214, 'test002', 7, 0, 454564, 0, 0, 14, '2026-07-14 17:56:07', 0, 1, 0);
INSERT INTO `useroptlog` VALUES (215, 'test01', 8, 0, 65621, 0, 0, 5, '2026-07-14 17:56:23', 0, 1, 0);
INSERT INTO `useroptlog` VALUES (216, 'test01', 7, 0, 65591, 0, 0, 5, '2026-07-14 17:56:40', 0, 1, 0);
INSERT INTO `useroptlog` VALUES (217, 'test01', 8, 0, 65591, 0, 0, 3, '2026-07-15 14:05:04', 0, 2, 1);
INSERT INTO `useroptlog` VALUES (218, 'test01', 7, 0, 64191, 0, 0, 3, '2026-07-15 14:06:01', 0, 2, 1);
INSERT INTO `useroptlog` VALUES (219, 'test01', 8, 0, 64191, 0, 0, 3, '2026-07-15 16:35:54', 0, 1, 1);
INSERT INTO `useroptlog` VALUES (220, 'test01', 7, 0, 64191, 0, 0, 3, '2026-07-15 16:36:01', 0, 1, 1);
INSERT INTO `useroptlog` VALUES (221, 'test01', 8, 0, 64191, 0, 0, 2, '2026-07-15 16:36:12', 0, 0, 3);
INSERT INTO `useroptlog` VALUES (222, 'test01', 7, 0, 64191, 0, 0, 2, '2026-07-15 16:36:28', 0, 0, 3);
INSERT INTO `useroptlog` VALUES (223, 'test01', 8, 0, 64191, 0, 0, 29, '2026-07-15 16:36:50', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (224, 'test01', 7, 0, 64191, 0, 0, 29, '2026-07-15 16:37:19', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (225, 'test01', 8, 0, 64191, 0, 0, 19, '2026-07-15 16:40:23', 0, 0, 1);
INSERT INTO `useroptlog` VALUES (226, 'test01', 7, 0, 63591, 0, 0, 19, '2026-07-15 16:42:29', 0, 0, 1);
INSERT INTO `useroptlog` VALUES (227, 'test01', 7, 0, 63591, 0, 1, 40, '2026-07-15 17:36:50', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (228, 'test01', 7, 0, 63675, 0, 1, 40, '2026-07-15 18:14:45', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (229, 'test01', 8, 0, 63669, 0, 0, 2, '2026-07-15 18:25:56', 0, 0, 4);
INSERT INTO `useroptlog` VALUES (230, 'test01', 7, 0, 63665, 0, 0, 2, '2026-07-15 18:26:10', 0, 0, 4);
INSERT INTO `useroptlog` VALUES (231, 'test01', 8, 0, 63665, 0, 0, 29, '2026-07-15 18:26:23', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (232, 'test01', 7, 0, 63665, 0, 0, 29, '2026-07-15 18:26:27', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (233, 'test01', 8, 0, 63665, 0, 0, 47, '2026-07-15 18:26:56', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (234, 'test01', 7, 0, 63665, 0, 0, 47, '2026-07-15 18:27:01', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (235, 'test01', 8, 0, 63665, 0, 0, 2, '2026-07-15 19:11:45', 0, 0, 4);
INSERT INTO `useroptlog` VALUES (236, 'test01', 7, 0, 63665, 0, 0, 2, '2026-07-15 19:12:04', 0, 0, 4);
INSERT INTO `useroptlog` VALUES (237, 'test01', 8, 0, 63665, 0, 0, 2, '2026-07-15 19:12:34', 0, 0, 1);
INSERT INTO `useroptlog` VALUES (238, 'test01', 7, 0, 63665, 0, 0, 2, '2026-07-15 19:13:14', 0, 0, 1);
INSERT INTO `useroptlog` VALUES (239, 'test01', 8, 0, 63665, 0, 0, 2, '2026-07-15 20:01:15', 0, 0, 5);
INSERT INTO `useroptlog` VALUES (240, 'test01', 7, 0, 63665, 0, 0, 2, '2026-07-15 20:01:27', 0, 0, 5);
INSERT INTO `useroptlog` VALUES (241, 'test01', 8, 0, 63665, 0, 0, 5, '2026-07-15 20:02:05', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (242, 'test01', 7, 0, 63665, 0, 0, 5, '2026-07-15 20:02:18', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (243, 'test01', 8, 0, 63665, 0, 0, 5, '2026-07-15 20:02:40', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (244, 'test01', 7, 0, 63665, 0, 0, 5, '2026-07-15 20:02:59', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (245, 'test01', 8, 0, 63665, 0, 0, 15, '2026-07-15 20:03:12', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (246, 'test01', 7, 0, 63665, 0, 0, 15, '2026-07-15 20:03:53', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (247, 'test01', 8, 0, 63665, 0, 0, 2, '2026-07-15 20:10:09', 0, 0, 2);
INSERT INTO `useroptlog` VALUES (248, 'test01', 7, 0, 63665, 0, 0, 2, '2026-07-15 20:10:49', 0, 0, 2);
INSERT INTO `useroptlog` VALUES (249, 'test01', 8, 0, 63665, 0, 0, 2, '2026-07-15 20:28:17', 0, 0, 4);
INSERT INTO `useroptlog` VALUES (250, 'test01', 7, 0, 63674, 0, 0, 2, '2026-07-15 20:28:32', 0, 0, 4);
INSERT INTO `useroptlog` VALUES (251, 'test01', 8, 0, 63674, 0, 0, 2, '2026-07-16 09:49:43', 0, 0, 4);
INSERT INTO `useroptlog` VALUES (252, 'test01', 7, 0, 63699, 0, 0, 2, '2026-07-16 09:50:44', 0, 0, 4);
INSERT INTO `useroptlog` VALUES (253, 'test01', 8, 0, 63699, 0, 0, 2, '2026-07-16 10:12:44', 0, 0, 3);
INSERT INTO `useroptlog` VALUES (254, 'test01', 7, 0, 63667, 0, 0, 2, '2026-07-16 10:14:15', 0, 0, 3);
INSERT INTO `useroptlog` VALUES (255, 'test01', 8, 0, 63667, 0, 0, 2, '2026-07-16 10:14:21', 0, 2, 2);
INSERT INTO `useroptlog` VALUES (256, 'test01', 7, 0, 63667, 0, 0, 2, '2026-07-16 10:14:33', 0, 2, 2);
INSERT INTO `useroptlog` VALUES (257, 'test01', 8, 0, 63667, 0, 0, 10, '2026-07-16 10:14:41', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (258, 'test01', 7, 0, 63667, 0, 0, 10, '2026-07-16 10:16:50', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (259, 'test01', 8, 0, 63667, 0, 0, 29, '2026-07-16 10:19:14', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (260, 'test01', 7, 0, 63667, 0, 0, 29, '2026-07-16 10:19:25', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (261, 'test01', 8, 0, 63667, 0, 0, 29, '2026-07-16 10:19:42', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (262, 'test01', 7, 0, 63667, 0, 0, 29, '2026-07-16 10:19:52', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (263, 'test01', 8, 0, 63667, 0, 0, 3, '2026-07-16 10:23:27', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (264, 'test01', 7, 0, 63667, 0, 0, 3, '2026-07-16 10:23:42', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (265, 'test01', 8, 0, 63667, 0, 0, 3, '2026-07-16 10:34:23', 0, 2, 0);
INSERT INTO `useroptlog` VALUES (266, 'test01', 7, 0, 61987, 0, 0, 3, '2026-07-16 10:35:32', 0, 2, 0);
INSERT INTO `useroptlog` VALUES (267, 'test01', 8, 0, 61987, 0, 0, 44, '2026-07-16 10:51:14', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (268, 'test01', 7, 0, 61987, 0, 0, 44, '2026-07-16 10:51:17', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (269, 'test01', 8, 0, 61987, 0, 0, 2, '2026-07-16 10:51:57', 0, 0, 2);
INSERT INTO `useroptlog` VALUES (270, 'test01', 7, 0, 61987, 0, 0, 2, '2026-07-16 10:52:04', 0, 0, 2);
INSERT INTO `useroptlog` VALUES (271, 'test01', 8, 0, 61987, 0, 0, 47, '2026-07-16 10:53:58', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (272, 'test01', 7, 0, 61987, 0, 0, 47, '2026-07-16 10:54:03', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (273, 'test01', 8, 0, 61987, 0, 0, 19, '2026-07-16 10:57:02', 0, 0, 1);
INSERT INTO `useroptlog` VALUES (274, 'test01', 7, 0, 65287, 0, 0, 19, '2026-07-16 10:57:26', 0, 0, 1);
INSERT INTO `useroptlog` VALUES (275, 'test01', 8, 0, 65287, 0, 0, 19, '2026-07-16 10:57:37', 0, 0, 2);
INSERT INTO `useroptlog` VALUES (276, 'test01', 7, 0, 65287, 0, 0, 19, '2026-07-16 10:57:44', 0, 0, 2);
INSERT INTO `useroptlog` VALUES (277, 'test01', 8, 0, 65287, 0, 0, 10, '2026-07-16 11:01:06', 0, 2, 0);
INSERT INTO `useroptlog` VALUES (278, 'test01', 7, 0, 65287, 0, 0, 10, '2026-07-16 11:01:27', 0, 2, 0);
INSERT INTO `useroptlog` VALUES (279, 'test01', 8, 0, 65287, 0, 0, 10, '2026-07-16 11:01:40', 0, 0, 1);
INSERT INTO `useroptlog` VALUES (280, 'test01', 7, 0, 65287, 0, 0, 10, '2026-07-16 11:01:48', 0, 0, 1);
INSERT INTO `useroptlog` VALUES (281, 'test01', 8, 0, 65287, 0, 0, 10, '2026-07-16 11:03:04', 0, 0, 5);
INSERT INTO `useroptlog` VALUES (282, 'test01', 7, 0, 65287, 0, 0, 10, '2026-07-16 11:03:43', 0, 0, 5);
INSERT INTO `useroptlog` VALUES (283, 'test01', 8, 0, 65287, 0, 0, 5, '2026-07-16 11:45:28', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (284, 'test01', 7, 0, 65357, 0, 0, 5, '2026-07-16 11:45:45', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (285, 'test01', 8, 0, 65357, 0, 0, 3, '2026-07-16 11:46:05', 0, 2, 1);
INSERT INTO `useroptlog` VALUES (286, 'test01', 7, 0, 65307, 0, 0, 3, '2026-07-16 11:46:13', 0, 2, 1);
INSERT INTO `useroptlog` VALUES (287, 'test01', 8, 0, 65307, 0, 0, 19, '2026-07-16 14:10:34', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (288, 'test01', 7, 0, 53707, 0, 0, 19, '2026-07-16 14:10:57', 0, 0, 0);
INSERT INTO `useroptlog` VALUES (289, 'test01', 8, 0, 53707, 0, 0, 3, '2026-07-16 14:11:05', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (290, 'test01', 7, 0, 53657, 0, 0, 3, '2026-07-16 14:11:22', 0, 3, 0);
INSERT INTO `useroptlog` VALUES (291, 'test01', 8, 0, 53657, 0, 0, 3, '2026-07-16 14:12:50', 0, 3, 5);
INSERT INTO `useroptlog` VALUES (292, 'test01', 7, 0, 53567, 0, 0, 3, '2026-07-16 14:13:00', 0, 3, 5);
INSERT INTO `useroptlog` VALUES (293, 'test01', 8, 0, 53567, 0, 0, 3, '2026-07-16 14:13:41', 0, 3, 1);
INSERT INTO `useroptlog` VALUES (294, 'test01', 7, 0, 53327, 0, 0, 3, '2026-07-16 14:16:22', 0, 3, 1);
INSERT INTO `useroptlog` VALUES (295, 'test01', 8, 0, 53327, 0, 0, 3, '2026-07-16 14:20:22', 0, 3, 1);
INSERT INTO `useroptlog` VALUES (296, 'test01', 7, 0, 53277, 0, 0, 3, '2026-07-16 14:24:58', 0, 3, 1);

-- ----------------------------
-- Table structure for userrelations
-- ----------------------------
DROP TABLE IF EXISTS `userrelations`;
CREATE TABLE `userrelations`  (
  `UserID` int(11) NOT NULL AUTO_INCREMENT COMMENT '用户唯一标识ID',
  `ID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户账号',
  PRIMARY KEY (`UserID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 800715 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户唯一标识信息表' ROW_FORMAT = Dynamic;

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
INSERT INTO `userrelations` VALUES (800714, 'test002');

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
INSERT INTO `users` VALUES ('test002', '111', '123456', 'admin', 0, 0, 454564, 0, 554564, 0, -1, 'nowxheadimg', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '1', b'0', b'0', 0, '123456', 0, 1, '2026-07-08 10:25:49', '');
INSERT INTO `users` VALUES ('test01', '测试勿动', '123456', 'admin', 2, 0, 53277, 0, 13128186, 3157236, -1, 'nowxheadimg', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '123', b'1', b'0', 0, '123456', 0, 1, '2026-05-22 11:46:49', '');
INSERT INTO `users` VALUES ('test03', '1515', '123456', 'admin', 0, 0, 310930, 0, 310930, 0, -1, 'nowxheadimg', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '1', b'0', b'0', 0, '123456', 0, 1, '2026-07-09 09:46:25', '');

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
) ENGINE = InnoDB AUTO_INCREMENT = 4638 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

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
INSERT INTO `userscoresnapshotledger` VALUES (1784, 'test01', 54, 0, 983388, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-07 16:50:23');
INSERT INTO `userscoresnapshotledger` VALUES (1785, 'test01', 54, 0, 983388, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-07 16:54:53');
INSERT INTO `userscoresnapshotledger` VALUES (1786, 'test01', 54, 0, 983388, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-07 16:55:15');
INSERT INTO `userscoresnapshotledger` VALUES (1787, 'test01', 10, 5, 0, 983388, 983388, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:01:35');
INSERT INTO `userscoresnapshotledger` VALUES (1788, 'test01', 10, 5, 983388, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:01:35');
INSERT INTO `userscoresnapshotledger` VALUES (1789, 'test01', 10, 6, 0, 983388, 983388, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:01:50');
INSERT INTO `userscoresnapshotledger` VALUES (1790, 'test01', 10, 6, 0, 983388, 983388, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:02:04');
INSERT INTO `userscoresnapshotledger` VALUES (1791, 'test01', 10, 6, 0, 983388, 983388, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:02:58');
INSERT INTO `userscoresnapshotledger` VALUES (1792, 'test01', 10, 6, 983388, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:04');
INSERT INTO `userscoresnapshotledger` VALUES (1793, 'test01', 3, 7, 0, 983388, 983388, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:45');
INSERT INTO `userscoresnapshotledger` VALUES (1794, 'test01', 3, 7, 0, 983288, 983288, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:50');
INSERT INTO `userscoresnapshotledger` VALUES (1795, 'test01', 3, 7, 0, 983188, 983188, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:50');
INSERT INTO `userscoresnapshotledger` VALUES (1796, 'test01', 3, 7, 0, 983088, 983088, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:50');
INSERT INTO `userscoresnapshotledger` VALUES (1797, 'test01', 3, 7, 0, 982988, 982988, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:51');
INSERT INTO `userscoresnapshotledger` VALUES (1798, 'test01', 3, 7, 0, 982888, 982888, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:51');
INSERT INTO `userscoresnapshotledger` VALUES (1799, 'test01', 3, 7, 0, 982788, 982788, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:51');
INSERT INTO `userscoresnapshotledger` VALUES (1800, 'test01', 3, 7, 0, 982688, 982688, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:51');
INSERT INTO `userscoresnapshotledger` VALUES (1801, 'test01', 3, 7, 0, 982588, 982588, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:52');
INSERT INTO `userscoresnapshotledger` VALUES (1802, 'test01', 3, 7, 0, 982488, 982488, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:52');
INSERT INTO `userscoresnapshotledger` VALUES (1803, 'test01', 3, 7, 0, 982388, 982388, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:52');
INSERT INTO `userscoresnapshotledger` VALUES (1804, 'test01', 3, 7, 0, 982288, 982288, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:52');
INSERT INTO `userscoresnapshotledger` VALUES (1805, 'test01', 3, 7, 0, 982188, 982188, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:52');
INSERT INTO `userscoresnapshotledger` VALUES (1806, 'test01', 3, 7, 0, 982088, 982088, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:53');
INSERT INTO `userscoresnapshotledger` VALUES (1807, 'test01', 3, 7, 0, 981988, 981988, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:53');
INSERT INTO `userscoresnapshotledger` VALUES (1808, 'test01', 3, 7, 0, 981888, 981888, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:53');
INSERT INTO `userscoresnapshotledger` VALUES (1809, 'test01', 3, 7, 0, 981788, 981788, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:53');
INSERT INTO `userscoresnapshotledger` VALUES (1810, 'test01', 3, 7, 0, 981688, 981688, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:54');
INSERT INTO `userscoresnapshotledger` VALUES (1811, 'test01', 3, 7, 0, 981588, 981588, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:54');
INSERT INTO `userscoresnapshotledger` VALUES (1812, 'test01', 3, 7, 0, 981488, 981488, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:54');
INSERT INTO `userscoresnapshotledger` VALUES (1813, 'test01', 3, 7, 0, 981388, 981388, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:54');
INSERT INTO `userscoresnapshotledger` VALUES (1814, 'test01', 3, 7, 0, 981588, 981588, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:54');
INSERT INTO `userscoresnapshotledger` VALUES (1815, 'test01', 3, 7, 0, 981488, 981488, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:54');
INSERT INTO `userscoresnapshotledger` VALUES (1816, 'test01', 3, 7, 0, 981388, 981388, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:55');
INSERT INTO `userscoresnapshotledger` VALUES (1817, 'test01', 3, 7, 0, 981288, 981288, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:55');
INSERT INTO `userscoresnapshotledger` VALUES (1818, 'test01', 3, 7, 0, 981188, 981188, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:55');
INSERT INTO `userscoresnapshotledger` VALUES (1819, 'test01', 3, 7, 0, 981088, 981088, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:55');
INSERT INTO `userscoresnapshotledger` VALUES (1820, 'test01', 3, 7, 0, 980988, 980988, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:56');
INSERT INTO `userscoresnapshotledger` VALUES (1821, 'test01', 3, 7, 0, 980888, 980888, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:56');
INSERT INTO `userscoresnapshotledger` VALUES (1822, 'test01', 3, 7, 0, 980788, 980788, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:56');
INSERT INTO `userscoresnapshotledger` VALUES (1823, 'test01', 3, 7, 0, 980688, 980688, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:56');
INSERT INTO `userscoresnapshotledger` VALUES (1824, 'test01', 3, 7, 0, 980588, 980588, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:56');
INSERT INTO `userscoresnapshotledger` VALUES (1825, 'test01', 3, 7, 0, 980488, 980488, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:57');
INSERT INTO `userscoresnapshotledger` VALUES (1826, 'test01', 3, 7, 0, 980388, 980388, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:57');
INSERT INTO `userscoresnapshotledger` VALUES (1827, 'test01', 3, 7, 0, 980288, 980288, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:57');
INSERT INTO `userscoresnapshotledger` VALUES (1828, 'test01', 3, 7, 0, 980188, 980188, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:57');
INSERT INTO `userscoresnapshotledger` VALUES (1829, 'test01', 3, 7, 0, 980088, 980088, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:58');
INSERT INTO `userscoresnapshotledger` VALUES (1830, 'test01', 3, 7, 0, 979988, 979988, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:58');
INSERT INTO `userscoresnapshotledger` VALUES (1831, 'test01', 3, 7, 0, 979888, 979888, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:58');
INSERT INTO `userscoresnapshotledger` VALUES (1832, 'test01', 3, 7, 0, 979788, 979788, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:58');
INSERT INTO `userscoresnapshotledger` VALUES (1833, 'test01', 3, 7, 0, 979688, 979688, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:59');
INSERT INTO `userscoresnapshotledger` VALUES (1834, 'test01', 3, 7, 0, 979588, 979588, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:59');
INSERT INTO `userscoresnapshotledger` VALUES (1835, 'test01', 3, 7, 0, 979488, 979488, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:59');
INSERT INTO `userscoresnapshotledger` VALUES (1836, 'test01', 3, 7, 0, 979988, 979988, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:59');
INSERT INTO `userscoresnapshotledger` VALUES (1837, 'test01', 3, 7, 0, 979888, 979888, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:59');
INSERT INTO `userscoresnapshotledger` VALUES (1838, 'test01', 3, 7, 0, 979788, 979788, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:03:59');
INSERT INTO `userscoresnapshotledger` VALUES (1839, 'test01', 3, 7, 0, 979688, 979688, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:00');
INSERT INTO `userscoresnapshotledger` VALUES (1840, 'test01', 3, 7, 0, 979588, 979588, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:00');
INSERT INTO `userscoresnapshotledger` VALUES (1841, 'test01', 3, 7, 0, 979488, 979488, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:00');
INSERT INTO `userscoresnapshotledger` VALUES (1842, 'test01', 3, 7, 0, 979388, 979388, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:00');
INSERT INTO `userscoresnapshotledger` VALUES (1843, 'test01', 3, 7, 0, 979288, 979288, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:01');
INSERT INTO `userscoresnapshotledger` VALUES (1844, 'test01', 3, 7, 0, 979188, 979188, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:01');
INSERT INTO `userscoresnapshotledger` VALUES (1845, 'test01', 3, 7, 0, 979088, 979088, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:01');
INSERT INTO `userscoresnapshotledger` VALUES (1846, 'test01', 3, 7, 0, 978988, 978988, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:01');
INSERT INTO `userscoresnapshotledger` VALUES (1847, 'test01', 3, 7, 0, 978888, 978888, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:01');
INSERT INTO `userscoresnapshotledger` VALUES (1848, 'test01', 3, 7, 0, 978788, 978788, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:02');
INSERT INTO `userscoresnapshotledger` VALUES (1849, 'test01', 3, 7, 0, 978688, 978688, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:02');
INSERT INTO `userscoresnapshotledger` VALUES (1850, 'test01', 3, 7, 0, 978588, 978588, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:02');
INSERT INTO `userscoresnapshotledger` VALUES (1851, 'test01', 3, 7, 0, 978488, 978488, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:02');
INSERT INTO `userscoresnapshotledger` VALUES (1852, 'test01', 3, 7, 0, 978388, 978388, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:03');
INSERT INTO `userscoresnapshotledger` VALUES (1853, 'test01', 3, 7, 0, 978288, 978288, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:03');
INSERT INTO `userscoresnapshotledger` VALUES (1854, 'test01', 3, 7, 0, 978188, 978188, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:03');
INSERT INTO `userscoresnapshotledger` VALUES (1855, 'test01', 3, 7, 0, 978088, 978088, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:03');
INSERT INTO `userscoresnapshotledger` VALUES (1856, 'test01', 3, 7, 0, 977988, 977988, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:03');
INSERT INTO `userscoresnapshotledger` VALUES (1857, 'test01', 3, 7, 0, 977888, 977888, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:04');
INSERT INTO `userscoresnapshotledger` VALUES (1858, 'test01', 3, 7, 0, 977788, 977788, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:04');
INSERT INTO `userscoresnapshotledger` VALUES (1859, 'test01', 3, 7, 0, 977688, 977688, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:04');
INSERT INTO `userscoresnapshotledger` VALUES (1860, 'test01', 3, 7, 0, 977588, 977588, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:04');
INSERT INTO `userscoresnapshotledger` VALUES (1861, 'test01', 3, 7, 0, 977488, 977488, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:05');
INSERT INTO `userscoresnapshotledger` VALUES (1862, 'test01', 3, 7, 0, 977388, 977388, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:05');
INSERT INTO `userscoresnapshotledger` VALUES (1863, 'test01', 3, 7, 0, 977288, 977288, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:05');
INSERT INTO `userscoresnapshotledger` VALUES (1864, 'test01', 3, 7, 0, 977188, 977188, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:05');
INSERT INTO `userscoresnapshotledger` VALUES (1865, 'test01', 3, 7, 0, 977088, 977088, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:05');
INSERT INTO `userscoresnapshotledger` VALUES (1866, 'test01', 3, 7, 0, 976988, 976988, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:06');
INSERT INTO `userscoresnapshotledger` VALUES (1867, 'test01', 3, 7, 0, 976888, 976888, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:06');
INSERT INTO `userscoresnapshotledger` VALUES (1868, 'test01', 3, 7, 0, 976788, 976788, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:06');
INSERT INTO `userscoresnapshotledger` VALUES (1869, 'test01', 3, 7, 0, 976688, 976688, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:06');
INSERT INTO `userscoresnapshotledger` VALUES (1870, 'test01', 3, 7, 0, 976588, 976588, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:07');
INSERT INTO `userscoresnapshotledger` VALUES (1871, 'test01', 3, 7, 0, 976488, 976488, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:07');
INSERT INTO `userscoresnapshotledger` VALUES (1872, 'test01', 3, 7, 0, 976388, 976388, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:07');
INSERT INTO `userscoresnapshotledger` VALUES (1873, 'test01', 3, 7, 0, 976288, 976288, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:07');
INSERT INTO `userscoresnapshotledger` VALUES (1874, 'test01', 3, 7, 0, 976188, 976188, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:07');
INSERT INTO `userscoresnapshotledger` VALUES (1875, 'test01', 3, 7, 0, 976088, 976088, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:08');
INSERT INTO `userscoresnapshotledger` VALUES (1876, 'test01', 3, 7, 0, 975988, 975988, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:08');
INSERT INTO `userscoresnapshotledger` VALUES (1877, 'test01', 3, 7, 0, 975888, 975888, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:08');
INSERT INTO `userscoresnapshotledger` VALUES (1878, 'test01', 3, 7, 0, 975788, 975788, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:08');
INSERT INTO `userscoresnapshotledger` VALUES (1879, 'test01', 3, 7, 0, 975688, 975688, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:09');
INSERT INTO `userscoresnapshotledger` VALUES (1880, 'test01', 3, 7, 0, 975588, 975588, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:09');
INSERT INTO `userscoresnapshotledger` VALUES (1881, 'test01', 3, 7, 0, 975488, 975488, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:09');
INSERT INTO `userscoresnapshotledger` VALUES (1882, 'test01', 3, 7, 0, 975388, 975388, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:09');
INSERT INTO `userscoresnapshotledger` VALUES (1883, 'test01', 3, 7, 0, 975988, 975988, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:09');
INSERT INTO `userscoresnapshotledger` VALUES (1884, 'test01', 3, 7, 0, 975888, 975888, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:10');
INSERT INTO `userscoresnapshotledger` VALUES (1885, 'test01', 3, 7, 0, 975788, 975788, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:10');
INSERT INTO `userscoresnapshotledger` VALUES (1886, 'test01', 3, 7, 0, 975688, 975688, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:10');
INSERT INTO `userscoresnapshotledger` VALUES (1887, 'test01', 3, 7, 0, 975588, 975588, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:10');
INSERT INTO `userscoresnapshotledger` VALUES (1888, 'test01', 3, 7, 0, 975488, 975488, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:10');
INSERT INTO `userscoresnapshotledger` VALUES (1889, 'test01', 3, 7, 0, 975388, 975388, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:11');
INSERT INTO `userscoresnapshotledger` VALUES (1890, 'test01', 3, 7, 0, 975288, 975288, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:11');
INSERT INTO `userscoresnapshotledger` VALUES (1891, 'test01', 3, 7, 0, 975188, 975188, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:11');
INSERT INTO `userscoresnapshotledger` VALUES (1892, 'test01', 3, 7, 0, 975088, 975088, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:11');
INSERT INTO `userscoresnapshotledger` VALUES (1893, 'test01', 3, 7, 0, 974988, 974988, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:12');
INSERT INTO `userscoresnapshotledger` VALUES (1894, 'test01', 3, 7, 0, 974888, 974888, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:12');
INSERT INTO `userscoresnapshotledger` VALUES (1895, 'test01', 3, 7, 0, 974788, 974788, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:12');
INSERT INTO `userscoresnapshotledger` VALUES (1896, 'test01', 3, 7, 0, 974688, 974688, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:12');
INSERT INTO `userscoresnapshotledger` VALUES (1897, 'test01', 3, 7, 0, 974588, 974588, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:12');
INSERT INTO `userscoresnapshotledger` VALUES (1898, 'test01', 3, 7, 0, 974488, 974488, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:13');
INSERT INTO `userscoresnapshotledger` VALUES (1899, 'test01', 3, 7, 0, 974388, 974388, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:13');
INSERT INTO `userscoresnapshotledger` VALUES (1900, 'test01', 3, 7, 0, 974288, 974288, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:13');
INSERT INTO `userscoresnapshotledger` VALUES (1901, 'test01', 3, 7, 0, 974188, 974188, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:13');
INSERT INTO `userscoresnapshotledger` VALUES (1902, 'test01', 3, 7, 0, 974088, 974088, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:14');
INSERT INTO `userscoresnapshotledger` VALUES (1903, 'test01', 3, 7, 0, 973988, 973988, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:14');
INSERT INTO `userscoresnapshotledger` VALUES (1904, 'test01', 3, 7, 0, 973888, 973888, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:14');
INSERT INTO `userscoresnapshotledger` VALUES (1905, 'test01', 3, 7, 0, 973788, 973788, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:14');
INSERT INTO `userscoresnapshotledger` VALUES (1906, 'test01', 3, 7, 0, 973688, 973688, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:14');
INSERT INTO `userscoresnapshotledger` VALUES (1907, 'test01', 3, 7, 0, 973588, 973588, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:15');
INSERT INTO `userscoresnapshotledger` VALUES (1908, 'test01', 3, 7, 0, 973488, 973488, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:15');
INSERT INTO `userscoresnapshotledger` VALUES (1909, 'test01', 3, 7, 0, 973388, 973388, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:15');
INSERT INTO `userscoresnapshotledger` VALUES (1910, 'test01', 3, 7, 0, 973288, 973288, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:15');
INSERT INTO `userscoresnapshotledger` VALUES (1911, 'test01', 3, 7, 0, 973188, 973188, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:16');
INSERT INTO `userscoresnapshotledger` VALUES (1912, 'test01', 3, 7, 0, 973088, 973088, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:16');
INSERT INTO `userscoresnapshotledger` VALUES (1913, 'test01', 3, 7, 0, 972988, 972988, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:16');
INSERT INTO `userscoresnapshotledger` VALUES (1914, 'test01', 3, 7, 0, 972888, 972888, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:16');
INSERT INTO `userscoresnapshotledger` VALUES (1915, 'test01', 3, 7, 0, 972788, 972788, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:16');
INSERT INTO `userscoresnapshotledger` VALUES (1916, 'test01', 3, 7, 0, 972688, 972688, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:17');
INSERT INTO `userscoresnapshotledger` VALUES (1917, 'test01', 3, 7, 0, 972588, 972588, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:17');
INSERT INTO `userscoresnapshotledger` VALUES (1918, 'test01', 3, 7, 0, 972488, 972488, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:17');
INSERT INTO `userscoresnapshotledger` VALUES (1919, 'test01', 3, 7, 0, 972388, 972388, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:17');
INSERT INTO `userscoresnapshotledger` VALUES (1920, 'test01', 3, 7, 0, 972288, 972288, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:18');
INSERT INTO `userscoresnapshotledger` VALUES (1921, 'test01', 3, 7, 0, 972188, 972188, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:18');
INSERT INTO `userscoresnapshotledger` VALUES (1922, 'test01', 3, 7, 0, 972088, 972088, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:18');
INSERT INTO `userscoresnapshotledger` VALUES (1923, 'test01', 3, 7, 0, 971988, 971988, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:18');
INSERT INTO `userscoresnapshotledger` VALUES (1924, 'test01', 3, 7, 0, 971888, 971888, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:18');
INSERT INTO `userscoresnapshotledger` VALUES (1925, 'test01', 3, 7, 0, 971788, 971788, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:19');
INSERT INTO `userscoresnapshotledger` VALUES (1926, 'test01', 3, 7, 0, 971688, 971688, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:19');
INSERT INTO `userscoresnapshotledger` VALUES (1927, 'test01', 3, 7, 0, 971588, 971588, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:19');
INSERT INTO `userscoresnapshotledger` VALUES (1928, 'test01', 3, 7, 0, 971488, 971488, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:19');
INSERT INTO `userscoresnapshotledger` VALUES (1929, 'test01', 3, 7, 0, 971388, 971388, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:20');
INSERT INTO `userscoresnapshotledger` VALUES (1930, 'test01', 3, 7, 0, 971288, 971288, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:20');
INSERT INTO `userscoresnapshotledger` VALUES (1931, 'test01', 3, 7, 0, 971488, 971488, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:20');
INSERT INTO `userscoresnapshotledger` VALUES (1932, 'test01', 3, 7, 0, 971388, 971388, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:20');
INSERT INTO `userscoresnapshotledger` VALUES (1933, 'test01', 3, 7, 0, 971288, 971288, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:20');
INSERT INTO `userscoresnapshotledger` VALUES (1934, 'test01', 3, 7, 0, 971188, 971188, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:21');
INSERT INTO `userscoresnapshotledger` VALUES (1935, 'test01', 3, 7, 0, 971088, 971088, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:21');
INSERT INTO `userscoresnapshotledger` VALUES (1936, 'test01', 3, 7, 0, 970988, 970988, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:21');
INSERT INTO `userscoresnapshotledger` VALUES (1937, 'test01', 3, 7, 0, 970888, 970888, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:21');
INSERT INTO `userscoresnapshotledger` VALUES (1938, 'test01', 3, 7, 0, 970788, 970788, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:21');
INSERT INTO `userscoresnapshotledger` VALUES (1939, 'test01', 3, 7, 0, 970688, 970688, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:22');
INSERT INTO `userscoresnapshotledger` VALUES (1940, 'test01', 3, 7, 0, 970588, 970588, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:22');
INSERT INTO `userscoresnapshotledger` VALUES (1941, 'test01', 3, 7, 0, 970488, 970488, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:22');
INSERT INTO `userscoresnapshotledger` VALUES (1942, 'test01', 3, 7, 0, 970388, 970388, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:22');
INSERT INTO `userscoresnapshotledger` VALUES (1943, 'test01', 3, 7, 0, 970288, 970288, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:23');
INSERT INTO `userscoresnapshotledger` VALUES (1944, 'test01', 3, 7, 0, 970188, 970188, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:23');
INSERT INTO `userscoresnapshotledger` VALUES (1945, 'test01', 3, 7, 0, 970088, 970088, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:23');
INSERT INTO `userscoresnapshotledger` VALUES (1946, 'test01', 3, 7, 0, 969988, 969988, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:23');
INSERT INTO `userscoresnapshotledger` VALUES (1947, 'test01', 3, 7, 0, 969888, 969888, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:23');
INSERT INTO `userscoresnapshotledger` VALUES (1948, 'test01', 3, 7, 0, 969788, 969788, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:24');
INSERT INTO `userscoresnapshotledger` VALUES (1949, 'test01', 3, 7, 0, 969688, 969688, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:24');
INSERT INTO `userscoresnapshotledger` VALUES (1950, 'test01', 3, 7, 0, 969588, 969588, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:24');
INSERT INTO `userscoresnapshotledger` VALUES (1951, 'test01', 3, 7, 0, 969488, 969488, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:24');
INSERT INTO `userscoresnapshotledger` VALUES (1952, 'test01', 3, 7, 0, 969388, 969388, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:25');
INSERT INTO `userscoresnapshotledger` VALUES (1953, 'test01', 3, 7, 0, 969288, 969288, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:25');
INSERT INTO `userscoresnapshotledger` VALUES (1954, 'test01', 3, 7, 0, 969188, 969188, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:25');
INSERT INTO `userscoresnapshotledger` VALUES (1955, 'test01', 3, 7, 0, 969088, 969088, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:25');
INSERT INTO `userscoresnapshotledger` VALUES (1956, 'test01', 3, 7, 0, 968988, 968988, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:25');
INSERT INTO `userscoresnapshotledger` VALUES (1957, 'test01', 3, 7, 0, 968888, 968888, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:26');
INSERT INTO `userscoresnapshotledger` VALUES (1958, 'test01', 3, 7, 0, 968788, 968788, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:26');
INSERT INTO `userscoresnapshotledger` VALUES (1959, 'test01', 3, 7, 0, 968688, 968688, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:26');
INSERT INTO `userscoresnapshotledger` VALUES (1960, 'test01', 3, 7, 0, 968588, 968588, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:26');
INSERT INTO `userscoresnapshotledger` VALUES (1961, 'test01', 3, 7, 0, 968488, 968488, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:27');
INSERT INTO `userscoresnapshotledger` VALUES (1962, 'test01', 3, 7, 0, 968388, 968388, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:27');
INSERT INTO `userscoresnapshotledger` VALUES (1963, 'test01', 3, 7, 0, 968288, 968288, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:27');
INSERT INTO `userscoresnapshotledger` VALUES (1964, 'test01', 3, 7, 0, 968188, 968188, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:27');
INSERT INTO `userscoresnapshotledger` VALUES (1965, 'test01', 3, 7, 0, 968088, 968088, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:27');
INSERT INTO `userscoresnapshotledger` VALUES (1966, 'test01', 3, 7, 0, 967988, 967988, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:28');
INSERT INTO `userscoresnapshotledger` VALUES (1967, 'test01', 3, 7, 0, 967888, 967888, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:28');
INSERT INTO `userscoresnapshotledger` VALUES (1968, 'test01', 3, 7, 0, 967788, 967788, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:28');
INSERT INTO `userscoresnapshotledger` VALUES (1969, 'test01', 3, 7, 0, 967688, 967688, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:28');
INSERT INTO `userscoresnapshotledger` VALUES (1970, 'test01', 3, 7, 0, 967588, 967588, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:29');
INSERT INTO `userscoresnapshotledger` VALUES (1971, 'test01', 3, 7, 0, 967488, 967488, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:29');
INSERT INTO `userscoresnapshotledger` VALUES (1972, 'test01', 3, 7, 0, 967388, 967388, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:29');
INSERT INTO `userscoresnapshotledger` VALUES (1973, 'test01', 3, 7, 967388, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:33');
INSERT INTO `userscoresnapshotledger` VALUES (1974, 'test01', 3, 7, 967388, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:04:34');
INSERT INTO `userscoresnapshotledger` VALUES (1975, 'test01', 54, 0, 967388, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-07 17:07:25');
INSERT INTO `userscoresnapshotledger` VALUES (1976, 'test01', 53, 9, 967388, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-07 17:17:08');
INSERT INTO `userscoresnapshotledger` VALUES (1977, 'test01', 53, 2, 967388, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:13:24');
INSERT INTO `userscoresnapshotledger` VALUES (1978, 'test01', 54, 0, 967388, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-07 18:44:30');
INSERT INTO `userscoresnapshotledger` VALUES (1979, 'test01', 19, 9, 0, 967388, 967388, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:44:34');
INSERT INTO `userscoresnapshotledger` VALUES (1980, 'test01', 19, 9, 0, 967383, 967383, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:44:41');
INSERT INTO `userscoresnapshotledger` VALUES (1981, 'test01', 19, 9, 0, 967378, 967378, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:44:41');
INSERT INTO `userscoresnapshotledger` VALUES (1982, 'test01', 19, 9, 0, 967373, 967373, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:44:42');
INSERT INTO `userscoresnapshotledger` VALUES (1983, 'test01', 19, 9, 0, 967573, 967573, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:44:42');
INSERT INTO `userscoresnapshotledger` VALUES (1984, 'test01', 19, 9, 0, 967568, 967568, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:44:42');
INSERT INTO `userscoresnapshotledger` VALUES (1985, 'test01', 19, 9, 0, 967563, 967563, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:44:42');
INSERT INTO `userscoresnapshotledger` VALUES (1986, 'test01', 19, 9, 0, 967558, 967558, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:44:43');
INSERT INTO `userscoresnapshotledger` VALUES (1987, 'test01', 19, 9, 0, 967553, 967553, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:44:43');
INSERT INTO `userscoresnapshotledger` VALUES (1988, 'test01', 19, 9, 0, 967643, 967643, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:44:44');
INSERT INTO `userscoresnapshotledger` VALUES (1989, 'test01', 19, 9, 0, 967673, 967673, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:44:44');
INSERT INTO `userscoresnapshotledger` VALUES (1990, 'test01', 19, 9, 0, 967708, 967708, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:44:44');
INSERT INTO `userscoresnapshotledger` VALUES (1991, 'test01', 19, 9, 0, 967718, 967718, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:44:44');
INSERT INTO `userscoresnapshotledger` VALUES (1992, 'test01', 19, 9, 0, 967713, 967713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:44:45');
INSERT INTO `userscoresnapshotledger` VALUES (1993, 'test01', 19, 9, 0, 967708, 967708, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:44:46');
INSERT INTO `userscoresnapshotledger` VALUES (1994, 'test01', 19, 9, 0, 967758, 967758, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:44:46');
INSERT INTO `userscoresnapshotledger` VALUES (1995, 'test01', 19, 9, 0, 967753, 967753, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:44:46');
INSERT INTO `userscoresnapshotledger` VALUES (1996, 'test01', 19, 9, 0, 967803, 967803, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:44:46');
INSERT INTO `userscoresnapshotledger` VALUES (1997, 'test01', 19, 9, 0, 967928, 967928, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:44:46');
INSERT INTO `userscoresnapshotledger` VALUES (1998, 'test01', 19, 9, 0, 968053, 968053, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:44:47');
INSERT INTO `userscoresnapshotledger` VALUES (1999, 'test01', 19, 9, 0, 968153, 968153, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:44:47');
INSERT INTO `userscoresnapshotledger` VALUES (2000, 'test01', 19, 9, 0, 968148, 968148, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:44:48');
INSERT INTO `userscoresnapshotledger` VALUES (2001, 'test01', 19, 9, 0, 968158, 968158, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:44:48');
INSERT INTO `userscoresnapshotledger` VALUES (2002, 'test01', 19, 9, 0, 968153, 968153, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:44:50');
INSERT INTO `userscoresnapshotledger` VALUES (2003, 'test01', 19, 9, 0, 968653, 968653, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:44:50');
INSERT INTO `userscoresnapshotledger` VALUES (2004, 'test01', 19, 9, 0, 968648, 968648, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:02');
INSERT INTO `userscoresnapshotledger` VALUES (2005, 'test01', 19, 9, 0, 969248, 969248, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:03');
INSERT INTO `userscoresnapshotledger` VALUES (2006, 'test01', 19, 9, 0, 969243, 969243, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:07');
INSERT INTO `userscoresnapshotledger` VALUES (2007, 'test01', 19, 9, 0, 970113, 970113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:07');
INSERT INTO `userscoresnapshotledger` VALUES (2008, 'test01', 19, 9, 0, 970108, 970108, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:08');
INSERT INTO `userscoresnapshotledger` VALUES (2009, 'test01', 19, 9, 0, 970198, 970198, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:08');
INSERT INTO `userscoresnapshotledger` VALUES (2010, 'test01', 19, 9, 0, 970193, 970193, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:09');
INSERT INTO `userscoresnapshotledger` VALUES (2011, 'test01', 19, 9, 0, 970213, 970213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:09');
INSERT INTO `userscoresnapshotledger` VALUES (2012, 'test01', 19, 9, 0, 970208, 970208, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:10');
INSERT INTO `userscoresnapshotledger` VALUES (2013, 'test01', 19, 9, 0, 970708, 970708, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:10');
INSERT INTO `userscoresnapshotledger` VALUES (2014, 'test01', 19, 9, 0, 970703, 970703, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:10');
INSERT INTO `userscoresnapshotledger` VALUES (2015, 'test01', 19, 9, 0, 970828, 970828, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:10');
INSERT INTO `userscoresnapshotledger` VALUES (2016, 'test01', 19, 9, 0, 970823, 970823, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:21');
INSERT INTO `userscoresnapshotledger` VALUES (2017, 'test01', 19, 9, 0, 971123, 971123, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:21');
INSERT INTO `userscoresnapshotledger` VALUES (2018, 'test01', 19, 9, 0, 971118, 971118, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:22');
INSERT INTO `userscoresnapshotledger` VALUES (2019, 'test01', 19, 9, 0, 971148, 971148, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:22');
INSERT INTO `userscoresnapshotledger` VALUES (2020, 'test01', 19, 9, 0, 971143, 971143, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:22');
INSERT INTO `userscoresnapshotledger` VALUES (2021, 'test01', 19, 9, 0, 971233, 971233, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:23');
INSERT INTO `userscoresnapshotledger` VALUES (2022, 'test01', 19, 9, 0, 971228, 971228, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:23');
INSERT INTO `userscoresnapshotledger` VALUES (2023, 'test01', 19, 9, 0, 971318, 971318, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:23');
INSERT INTO `userscoresnapshotledger` VALUES (2024, 'test01', 19, 9, 0, 971313, 971313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:23');
INSERT INTO `userscoresnapshotledger` VALUES (2025, 'test01', 19, 9, 0, 971403, 971403, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:24');
INSERT INTO `userscoresnapshotledger` VALUES (2026, 'test01', 19, 9, 0, 971398, 971398, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:27');
INSERT INTO `userscoresnapshotledger` VALUES (2027, 'test01', 19, 9, 0, 971393, 971393, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:27');
INSERT INTO `userscoresnapshotledger` VALUES (2028, 'test01', 19, 9, 0, 971443, 971443, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:27');
INSERT INTO `userscoresnapshotledger` VALUES (2029, 'test01', 19, 9, 0, 971643, 971643, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:27');
INSERT INTO `userscoresnapshotledger` VALUES (2030, 'test01', 19, 9, 0, 971638, 971638, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:27');
INSERT INTO `userscoresnapshotledger` VALUES (2031, 'test01', 19, 9, 0, 971838, 971838, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:28');
INSERT INTO `userscoresnapshotledger` VALUES (2032, 'test01', 19, 9, 0, 971833, 971833, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:28');
INSERT INTO `userscoresnapshotledger` VALUES (2033, 'test01', 19, 9, 0, 971828, 971828, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:28');
INSERT INTO `userscoresnapshotledger` VALUES (2034, 'test01', 19, 9, 0, 972328, 972328, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:28');
INSERT INTO `userscoresnapshotledger` VALUES (2035, 'test01', 19, 9, 0, 972388, 972388, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:28');
INSERT INTO `userscoresnapshotledger` VALUES (2036, 'test01', 19, 9, 0, 972383, 972383, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:29');
INSERT INTO `userscoresnapshotledger` VALUES (2037, 'test01', 19, 9, 0, 972508, 972508, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:29');
INSERT INTO `userscoresnapshotledger` VALUES (2038, 'test01', 19, 9, 0, 972503, 972503, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:29');
INSERT INTO `userscoresnapshotledger` VALUES (2039, 'test01', 19, 9, 0, 972498, 972498, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:30');
INSERT INTO `userscoresnapshotledger` VALUES (2040, 'test01', 19, 9, 0, 972588, 972588, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:30');
INSERT INTO `userscoresnapshotledger` VALUES (2041, 'test01', 19, 9, 0, 972583, 972583, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:30');
INSERT INTO `userscoresnapshotledger` VALUES (2042, 'test01', 19, 9, 0, 972658, 972658, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:30');
INSERT INTO `userscoresnapshotledger` VALUES (2043, 'test01', 19, 9, 0, 972708, 972708, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:30');
INSERT INTO `userscoresnapshotledger` VALUES (2044, 'test01', 19, 9, 0, 972703, 972703, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:33');
INSERT INTO `userscoresnapshotledger` VALUES (2045, 'test01', 19, 9, 0, 972698, 972698, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:33');
INSERT INTO `userscoresnapshotledger` VALUES (2046, 'test01', 19, 9, 0, 972798, 972798, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:33');
INSERT INTO `userscoresnapshotledger` VALUES (2047, 'test01', 19, 9, 0, 972813, 972813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:33');
INSERT INTO `userscoresnapshotledger` VALUES (2048, 'test01', 19, 9, 0, 972808, 972808, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:34');
INSERT INTO `userscoresnapshotledger` VALUES (2049, 'test01', 19, 9, 0, 972803, 972803, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:34');
INSERT INTO `userscoresnapshotledger` VALUES (2050, 'test01', 19, 9, 0, 972863, 972863, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:34');
INSERT INTO `userscoresnapshotledger` VALUES (2051, 'test01', 19, 9, 0, 972963, 972963, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:34');
INSERT INTO `userscoresnapshotledger` VALUES (2052, 'test01', 19, 9, 0, 972958, 972958, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:34');
INSERT INTO `userscoresnapshotledger` VALUES (2053, 'test01', 19, 9, 0, 972953, 972953, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:35');
INSERT INTO `userscoresnapshotledger` VALUES (2054, 'test01', 19, 9, 0, 972968, 972968, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:35');
INSERT INTO `userscoresnapshotledger` VALUES (2055, 'test01', 19, 9, 0, 972963, 972963, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:35');
INSERT INTO `userscoresnapshotledger` VALUES (2056, 'test01', 19, 9, 0, 973038, 973038, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:35');
INSERT INTO `userscoresnapshotledger` VALUES (2057, 'test01', 19, 9, 0, 973033, 973033, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:35');
INSERT INTO `userscoresnapshotledger` VALUES (2058, 'test01', 19, 9, 0, 973028, 973028, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:35');
INSERT INTO `userscoresnapshotledger` VALUES (2059, 'test01', 19, 9, 0, 973153, 973153, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:35');
INSERT INTO `userscoresnapshotledger` VALUES (2060, 'test01', 19, 9, 0, 973148, 973148, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:36');
INSERT INTO `userscoresnapshotledger` VALUES (2061, 'test01', 19, 9, 0, 973163, 973163, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:36');
INSERT INTO `userscoresnapshotledger` VALUES (2062, 'test01', 19, 9, 0, 973158, 973158, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:36');
INSERT INTO `userscoresnapshotledger` VALUES (2063, 'test01', 19, 9, 0, 973218, 973218, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:36');
INSERT INTO `userscoresnapshotledger` VALUES (2064, 'test01', 19, 9, 0, 973368, 973368, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:36');
INSERT INTO `userscoresnapshotledger` VALUES (2065, 'test01', 19, 9, 0, 973363, 973363, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:36');
INSERT INTO `userscoresnapshotledger` VALUES (2066, 'test01', 19, 9, 0, 973358, 973358, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:36');
INSERT INTO `userscoresnapshotledger` VALUES (2067, 'test01', 19, 9, 0, 973353, 973353, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:36');
INSERT INTO `userscoresnapshotledger` VALUES (2068, 'test01', 19, 9, 0, 973853, 973853, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:37');
INSERT INTO `userscoresnapshotledger` VALUES (2069, 'test01', 19, 9, 0, 973848, 973848, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:37');
INSERT INTO `userscoresnapshotledger` VALUES (2070, 'test01', 19, 9, 0, 973843, 973843, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:37');
INSERT INTO `userscoresnapshotledger` VALUES (2071, 'test01', 19, 9, 0, 973993, 973993, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:37');
INSERT INTO `userscoresnapshotledger` VALUES (2072, 'test01', 19, 9, 0, 973988, 973988, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:37');
INSERT INTO `userscoresnapshotledger` VALUES (2073, 'test01', 19, 9, 0, 974858, 974858, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:37');
INSERT INTO `userscoresnapshotledger` VALUES (2074, 'test01', 19, 9, 0, 974933, 974933, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:37');
INSERT INTO `userscoresnapshotledger` VALUES (2075, 'test01', 19, 9, 0, 974928, 974928, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:37');
INSERT INTO `userscoresnapshotledger` VALUES (2076, 'test01', 19, 9, 0, 975028, 975028, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:38');
INSERT INTO `userscoresnapshotledger` VALUES (2077, 'test01', 19, 9, 0, 975023, 975023, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:38');
INSERT INTO `userscoresnapshotledger` VALUES (2078, 'test01', 19, 9, 0, 975018, 975018, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:38');
INSERT INTO `userscoresnapshotledger` VALUES (2079, 'test01', 19, 9, 0, 975013, 975013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:38');
INSERT INTO `userscoresnapshotledger` VALUES (2080, 'test01', 19, 9, 0, 975163, 975163, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:38');
INSERT INTO `userscoresnapshotledger` VALUES (2081, 'test01', 19, 9, 0, 975158, 975158, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:38');
INSERT INTO `userscoresnapshotledger` VALUES (2082, 'test01', 19, 9, 0, 975153, 975153, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:38');
INSERT INTO `userscoresnapshotledger` VALUES (2083, 'test01', 19, 9, 0, 975148, 975148, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:39');
INSERT INTO `userscoresnapshotledger` VALUES (2084, 'test01', 19, 9, 0, 975143, 975143, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:39');
INSERT INTO `userscoresnapshotledger` VALUES (2085, 'test01', 19, 9, 0, 975268, 975268, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:39');
INSERT INTO `userscoresnapshotledger` VALUES (2086, 'test01', 19, 9, 0, 975263, 975263, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:39');
INSERT INTO `userscoresnapshotledger` VALUES (2087, 'test01', 19, 9, 0, 975258, 975258, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:39');
INSERT INTO `userscoresnapshotledger` VALUES (2088, 'test01', 19, 9, 0, 975253, 975253, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:40');
INSERT INTO `userscoresnapshotledger` VALUES (2089, 'test01', 19, 9, 0, 975248, 975248, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:40');
INSERT INTO `userscoresnapshotledger` VALUES (2090, 'test01', 19, 9, 0, 975243, 975243, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:40');
INSERT INTO `userscoresnapshotledger` VALUES (2091, 'test01', 19, 9, 0, 975393, 975393, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:40');
INSERT INTO `userscoresnapshotledger` VALUES (2092, 'test01', 19, 9, 0, 975388, 975388, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:40');
INSERT INTO `userscoresnapshotledger` VALUES (2093, 'test01', 19, 9, 0, 975383, 975383, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:41');
INSERT INTO `userscoresnapshotledger` VALUES (2094, 'test01', 19, 9, 0, 976253, 976253, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:41');
INSERT INTO `userscoresnapshotledger` VALUES (2095, 'test01', 19, 9, 0, 976248, 976248, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:41');
INSERT INTO `userscoresnapshotledger` VALUES (2096, 'test01', 19, 9, 0, 976298, 976298, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:41');
INSERT INTO `userscoresnapshotledger` VALUES (2097, 'test01', 19, 9, 0, 976293, 976293, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:41');
INSERT INTO `userscoresnapshotledger` VALUES (2098, 'test01', 19, 9, 0, 976303, 976303, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:41');
INSERT INTO `userscoresnapshotledger` VALUES (2099, 'test01', 19, 9, 0, 976298, 976298, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:41');
INSERT INTO `userscoresnapshotledger` VALUES (2100, 'test01', 19, 9, 0, 976343, 976343, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:41');
INSERT INTO `userscoresnapshotledger` VALUES (2101, 'test01', 19, 9, 0, 976388, 976388, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:41');
INSERT INTO `userscoresnapshotledger` VALUES (2102, 'test01', 19, 9, 0, 976383, 976383, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:41');
INSERT INTO `userscoresnapshotledger` VALUES (2103, 'test01', 19, 9, 0, 976473, 976473, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:42');
INSERT INTO `userscoresnapshotledger` VALUES (2104, 'test01', 19, 9, 0, 976468, 976468, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:42');
INSERT INTO `userscoresnapshotledger` VALUES (2105, 'test01', 19, 9, 0, 976463, 976463, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:42');
INSERT INTO `userscoresnapshotledger` VALUES (2106, 'test01', 19, 9, 0, 976473, 976473, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:42');
INSERT INTO `userscoresnapshotledger` VALUES (2107, 'test01', 19, 9, 0, 976468, 976468, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:42');
INSERT INTO `userscoresnapshotledger` VALUES (2108, 'test01', 19, 9, 0, 976463, 976463, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:42');
INSERT INTO `userscoresnapshotledger` VALUES (2109, 'test01', 19, 9, 0, 976763, 976763, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:42');
INSERT INTO `userscoresnapshotledger` VALUES (2110, 'test01', 19, 9, 0, 976758, 976758, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:43');
INSERT INTO `userscoresnapshotledger` VALUES (2111, 'test01', 19, 9, 0, 976858, 976858, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:43');
INSERT INTO `userscoresnapshotledger` VALUES (2112, 'test01', 19, 9, 0, 976853, 976853, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:43');
INSERT INTO `userscoresnapshotledger` VALUES (2113, 'test01', 19, 9, 0, 976898, 976898, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:43');
INSERT INTO `userscoresnapshotledger` VALUES (2114, 'test01', 19, 9, 0, 976893, 976893, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:43');
INSERT INTO `userscoresnapshotledger` VALUES (2115, 'test01', 19, 9, 0, 976938, 976938, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:43');
INSERT INTO `userscoresnapshotledger` VALUES (2116, 'test01', 19, 9, 0, 976933, 976933, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:43');
INSERT INTO `userscoresnapshotledger` VALUES (2117, 'test01', 19, 9, 0, 976948, 976948, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:43');
INSERT INTO `userscoresnapshotledger` VALUES (2118, 'test01', 19, 9, 0, 976943, 976943, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:43');
INSERT INTO `userscoresnapshotledger` VALUES (2119, 'test01', 19, 9, 0, 976938, 976938, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:44');
INSERT INTO `userscoresnapshotledger` VALUES (2120, 'test01', 19, 9, 0, 976983, 976983, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:44');
INSERT INTO `userscoresnapshotledger` VALUES (2121, 'test01', 19, 9, 0, 977058, 977058, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:44');
INSERT INTO `userscoresnapshotledger` VALUES (2122, 'test01', 19, 9, 0, 977053, 977053, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:44');
INSERT INTO `userscoresnapshotledger` VALUES (2123, 'test01', 19, 9, 0, 977048, 977048, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:44');
INSERT INTO `userscoresnapshotledger` VALUES (2124, 'test01', 19, 9, 0, 977248, 977248, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:44');
INSERT INTO `userscoresnapshotledger` VALUES (2125, 'test01', 19, 9, 0, 977263, 977263, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:44');
INSERT INTO `userscoresnapshotledger` VALUES (2126, 'test01', 19, 9, 0, 977258, 977258, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:44');
INSERT INTO `userscoresnapshotledger` VALUES (2127, 'test01', 19, 9, 0, 977253, 977253, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:45');
INSERT INTO `userscoresnapshotledger` VALUES (2128, 'test01', 19, 9, 0, 977283, 977283, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:45');
INSERT INTO `userscoresnapshotledger` VALUES (2129, 'test01', 19, 9, 0, 977328, 977328, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:45');
INSERT INTO `userscoresnapshotledger` VALUES (2130, 'test01', 19, 9, 0, 977343, 977343, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:45');
INSERT INTO `userscoresnapshotledger` VALUES (2131, 'test01', 19, 9, 0, 977443, 977443, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:45');
INSERT INTO `userscoresnapshotledger` VALUES (2132, 'test01', 19, 9, 0, 977943, 977943, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:45');
INSERT INTO `userscoresnapshotledger` VALUES (2133, 'test01', 19, 9, 0, 977938, 977938, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:45');
INSERT INTO `userscoresnapshotledger` VALUES (2134, 'test01', 19, 9, 0, 978013, 978013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:45');
INSERT INTO `userscoresnapshotledger` VALUES (2135, 'test01', 19, 9, 0, 978008, 978008, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:45');
INSERT INTO `userscoresnapshotledger` VALUES (2136, 'test01', 19, 9, 0, 978043, 978043, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:45');
INSERT INTO `userscoresnapshotledger` VALUES (2137, 'test01', 19, 9, 0, 978913, 978913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:45');
INSERT INTO `userscoresnapshotledger` VALUES (2138, 'test01', 19, 9, 0, 978908, 978908, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:45');
INSERT INTO `userscoresnapshotledger` VALUES (2139, 'test01', 19, 9, 0, 980743, 980743, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:45');
INSERT INTO `userscoresnapshotledger` VALUES (2140, 'test01', 19, 9, 0, 980738, 980738, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:45');
INSERT INTO `userscoresnapshotledger` VALUES (2141, 'test01', 19, 9, 0, 980733, 980733, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:46');
INSERT INTO `userscoresnapshotledger` VALUES (2142, 'test01', 19, 9, 0, 980743, 980743, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:46');
INSERT INTO `userscoresnapshotledger` VALUES (2143, 'test01', 19, 9, 0, 980943, 980943, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:46');
INSERT INTO `userscoresnapshotledger` VALUES (2144, 'test01', 19, 9, 0, 980938, 980938, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:46');
INSERT INTO `userscoresnapshotledger` VALUES (2145, 'test01', 19, 9, 0, 980948, 980948, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:46');
INSERT INTO `userscoresnapshotledger` VALUES (2146, 'test01', 19, 9, 0, 980943, 980943, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:46');
INSERT INTO `userscoresnapshotledger` VALUES (2147, 'test01', 19, 9, 0, 980983, 980983, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:46');
INSERT INTO `userscoresnapshotledger` VALUES (2148, 'test01', 19, 9, 0, 981028, 981028, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:46');
INSERT INTO `userscoresnapshotledger` VALUES (2149, 'test01', 19, 9, 0, 981023, 981023, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:46');
INSERT INTO `userscoresnapshotledger` VALUES (2150, 'test01', 19, 9, 0, 981173, 981173, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:47');
INSERT INTO `userscoresnapshotledger` VALUES (2151, 'test01', 19, 9, 0, 981168, 981168, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:47');
INSERT INTO `userscoresnapshotledger` VALUES (2152, 'test01', 19, 9, 0, 981258, 981258, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:47');
INSERT INTO `userscoresnapshotledger` VALUES (2153, 'test01', 19, 9, 0, 981253, 981253, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:47');
INSERT INTO `userscoresnapshotledger` VALUES (2154, 'test01', 19, 9, 0, 981248, 981248, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:47');
INSERT INTO `userscoresnapshotledger` VALUES (2155, 'test01', 19, 9, 0, 981308, 981308, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:47');
INSERT INTO `userscoresnapshotledger` VALUES (2156, 'test01', 19, 9, 0, 981303, 981303, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:47');
INSERT INTO `userscoresnapshotledger` VALUES (2157, 'test01', 19, 9, 0, 981603, 981603, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:47');
INSERT INTO `userscoresnapshotledger` VALUES (2158, 'test01', 19, 9, 0, 981598, 981598, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:47');
INSERT INTO `userscoresnapshotledger` VALUES (2159, 'test01', 19, 9, 0, 981748, 981748, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:48');
INSERT INTO `userscoresnapshotledger` VALUES (2160, 'test01', 19, 9, 0, 982248, 982248, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:48');
INSERT INTO `userscoresnapshotledger` VALUES (2161, 'test01', 19, 9, 0, 982243, 982243, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:48');
INSERT INTO `userscoresnapshotledger` VALUES (2162, 'test01', 19, 9, 0, 982238, 982238, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:48');
INSERT INTO `userscoresnapshotledger` VALUES (2163, 'test01', 19, 9, 0, 983108, 983108, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:48');
INSERT INTO `userscoresnapshotledger` VALUES (2164, 'test01', 19, 9, 0, 987108, 987108, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:48');
INSERT INTO `userscoresnapshotledger` VALUES (2165, 'test01', 19, 9, 0, 987103, 987103, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:48');
INSERT INTO `userscoresnapshotledger` VALUES (2166, 'test01', 19, 9, 0, 987098, 987098, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:49');
INSERT INTO `userscoresnapshotledger` VALUES (2167, 'test01', 19, 9, 0, 987173, 987173, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:49');
INSERT INTO `userscoresnapshotledger` VALUES (2168, 'test01', 19, 9, 0, 987183, 987183, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:49');
INSERT INTO `userscoresnapshotledger` VALUES (2169, 'test01', 19, 9, 0, 987178, 987178, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:49');
INSERT INTO `userscoresnapshotledger` VALUES (2170, 'test01', 19, 9, 0, 987173, 987173, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:49');
INSERT INTO `userscoresnapshotledger` VALUES (2171, 'test01', 19, 9, 0, 987168, 987168, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:49');
INSERT INTO `userscoresnapshotledger` VALUES (2172, 'test01', 19, 9, 0, 987163, 987163, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:49');
INSERT INTO `userscoresnapshotledger` VALUES (2173, 'test01', 19, 9, 0, 987158, 987158, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:50');
INSERT INTO `userscoresnapshotledger` VALUES (2174, 'test01', 19, 9, 0, 988028, 988028, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:50');
INSERT INTO `userscoresnapshotledger` VALUES (2175, 'test01', 19, 9, 0, 988023, 988023, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:50');
INSERT INTO `userscoresnapshotledger` VALUES (2176, 'test01', 19, 9, 0, 988018, 988018, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:50');
INSERT INTO `userscoresnapshotledger` VALUES (2177, 'test01', 19, 9, 0, 988068, 988068, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:50');
INSERT INTO `userscoresnapshotledger` VALUES (2178, 'test01', 19, 9, 0, 988063, 988063, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:50');
INSERT INTO `userscoresnapshotledger` VALUES (2179, 'test01', 19, 9, 0, 988663, 988663, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:50');
INSERT INTO `userscoresnapshotledger` VALUES (2180, 'test01', 19, 9, 0, 988658, 988658, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:51');
INSERT INTO `userscoresnapshotledger` VALUES (2181, 'test01', 19, 9, 0, 988653, 988653, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:51');
INSERT INTO `userscoresnapshotledger` VALUES (2182, 'test01', 19, 9, 0, 988648, 988648, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:51');
INSERT INTO `userscoresnapshotledger` VALUES (2183, 'test01', 19, 9, 0, 988848, 988848, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:51');
INSERT INTO `userscoresnapshotledger` VALUES (2184, 'test01', 19, 9, 0, 988908, 988908, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:51');
INSERT INTO `userscoresnapshotledger` VALUES (2185, 'test01', 19, 9, 0, 988903, 988903, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:51');
INSERT INTO `userscoresnapshotledger` VALUES (2186, 'test01', 19, 9, 0, 988898, 988898, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:51');
INSERT INTO `userscoresnapshotledger` VALUES (2187, 'test01', 19, 9, 0, 988893, 988893, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:52');
INSERT INTO `userscoresnapshotledger` VALUES (2188, 'test01', 19, 9, 0, 988993, 988993, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:52');
INSERT INTO `userscoresnapshotledger` VALUES (2189, 'test01', 19, 9, 0, 988988, 988988, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:52');
INSERT INTO `userscoresnapshotledger` VALUES (2190, 'test01', 19, 9, 0, 989288, 989288, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:52');
INSERT INTO `userscoresnapshotledger` VALUES (2191, 'test01', 19, 9, 0, 989283, 989283, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:52');
INSERT INTO `userscoresnapshotledger` VALUES (2192, 'test01', 19, 9, 0, 990153, 990153, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:52');
INSERT INTO `userscoresnapshotledger` VALUES (2193, 'test01', 19, 9, 0, 990148, 990148, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:52');
INSERT INTO `userscoresnapshotledger` VALUES (2194, 'test01', 19, 9, 0, 990348, 990348, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:53');
INSERT INTO `userscoresnapshotledger` VALUES (2195, 'test01', 19, 9, 0, 990343, 990343, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:53');
INSERT INTO `userscoresnapshotledger` VALUES (2196, 'test01', 19, 9, 0, 990393, 990393, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:53');
INSERT INTO `userscoresnapshotledger` VALUES (2197, 'test01', 19, 9, 0, 990403, 990403, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:53');
INSERT INTO `userscoresnapshotledger` VALUES (2198, 'test01', 19, 9, 0, 990398, 990398, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:53');
INSERT INTO `userscoresnapshotledger` VALUES (2199, 'test01', 19, 9, 0, 990523, 990523, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:53');
INSERT INTO `userscoresnapshotledger` VALUES (2200, 'test01', 19, 9, 0, 990518, 990518, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:53');
INSERT INTO `userscoresnapshotledger` VALUES (2201, 'test01', 19, 9, 0, 990513, 990513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:53');
INSERT INTO `userscoresnapshotledger` VALUES (2202, 'test01', 19, 9, 0, 990553, 990553, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:53');
INSERT INTO `userscoresnapshotledger` VALUES (2203, 'test01', 19, 9, 0, 990548, 990548, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:54');
INSERT INTO `userscoresnapshotledger` VALUES (2204, 'test01', 19, 9, 0, 990598, 990598, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:54');
INSERT INTO `userscoresnapshotledger` VALUES (2205, 'test01', 19, 9, 0, 990593, 990593, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:54');
INSERT INTO `userscoresnapshotledger` VALUES (2206, 'test01', 19, 9, 0, 990588, 990588, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:54');
INSERT INTO `userscoresnapshotledger` VALUES (2207, 'test01', 19, 9, 0, 990583, 990583, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:54');
INSERT INTO `userscoresnapshotledger` VALUES (2208, 'test01', 19, 9, 0, 990623, 990623, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:54');
INSERT INTO `userscoresnapshotledger` VALUES (2209, 'test01', 19, 9, 0, 990618, 990618, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:54');
INSERT INTO `userscoresnapshotledger` VALUES (2210, 'test01', 19, 9, 0, 990653, 990653, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:55');
INSERT INTO `userscoresnapshotledger` VALUES (2211, 'test01', 19, 9, 0, 990648, 990648, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:55');
INSERT INTO `userscoresnapshotledger` VALUES (2212, 'test01', 19, 9, 0, 990643, 990643, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:55');
INSERT INTO `userscoresnapshotledger` VALUES (2213, 'test01', 19, 9, 0, 990638, 990638, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:55');
INSERT INTO `userscoresnapshotledger` VALUES (2214, 'test01', 19, 9, 0, 990633, 990633, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:55');
INSERT INTO `userscoresnapshotledger` VALUES (2215, 'test01', 19, 9, 0, 990628, 990628, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:56');
INSERT INTO `userscoresnapshotledger` VALUES (2216, 'test01', 19, 9, 0, 990728, 990728, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:56');
INSERT INTO `userscoresnapshotledger` VALUES (2217, 'test01', 19, 9, 0, 990723, 990723, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:56');
INSERT INTO `userscoresnapshotledger` VALUES (2218, 'test01', 19, 9, 0, 990848, 990848, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:58');
INSERT INTO `userscoresnapshotledger` VALUES (2219, 'test01', 19, 9, 0, 990973, 990973, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:45:58');
INSERT INTO `userscoresnapshotledger` VALUES (2220, 'test01', 19, 9, 0, 991023, 991023, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:00');
INSERT INTO `userscoresnapshotledger` VALUES (2221, 'test01', 19, 9, 0, 991113, 991113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:00');
INSERT INTO `userscoresnapshotledger` VALUES (2222, 'test01', 19, 9, 0, 991128, 991128, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:00');
INSERT INTO `userscoresnapshotledger` VALUES (2223, 'test01', 19, 9, 0, 991138, 991138, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:00');
INSERT INTO `userscoresnapshotledger` VALUES (2224, 'test01', 19, 9, 0, 991153, 991153, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:01');
INSERT INTO `userscoresnapshotledger` VALUES (2225, 'test01', 19, 9, 0, 991653, 991653, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:01');
INSERT INTO `userscoresnapshotledger` VALUES (2226, 'test01', 19, 9, 0, 991663, 991663, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:01');
INSERT INTO `userscoresnapshotledger` VALUES (2227, 'test01', 19, 9, 0, 991658, 991658, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:03');
INSERT INTO `userscoresnapshotledger` VALUES (2228, 'test01', 19, 9, 0, 991668, 991668, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:03');
INSERT INTO `userscoresnapshotledger` VALUES (2229, 'test01', 19, 9, 0, 991663, 991663, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:03');
INSERT INTO `userscoresnapshotledger` VALUES (2230, 'test01', 19, 9, 0, 991963, 991963, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:04');
INSERT INTO `userscoresnapshotledger` VALUES (2231, 'test01', 19, 9, 0, 991958, 991958, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:04');
INSERT INTO `userscoresnapshotledger` VALUES (2232, 'test01', 19, 9, 0, 992018, 992018, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:04');
INSERT INTO `userscoresnapshotledger` VALUES (2233, 'test01', 19, 9, 0, 992013, 992013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:04');
INSERT INTO `userscoresnapshotledger` VALUES (2234, 'test01', 19, 9, 0, 992513, 992513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:04');
INSERT INTO `userscoresnapshotledger` VALUES (2235, 'test01', 19, 9, 0, 992508, 992508, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:04');
INSERT INTO `userscoresnapshotledger` VALUES (2236, 'test01', 19, 9, 0, 992633, 992633, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:04');
INSERT INTO `userscoresnapshotledger` VALUES (2237, 'test01', 19, 9, 0, 992628, 992628, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:04');
INSERT INTO `userscoresnapshotledger` VALUES (2238, 'test01', 19, 9, 0, 992703, 992703, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:05');
INSERT INTO `userscoresnapshotledger` VALUES (2239, 'test01', 19, 9, 0, 992698, 992698, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:05');
INSERT INTO `userscoresnapshotledger` VALUES (2240, 'test01', 19, 9, 0, 992693, 992693, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:05');
INSERT INTO `userscoresnapshotledger` VALUES (2241, 'test01', 19, 9, 0, 992768, 992768, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:05');
INSERT INTO `userscoresnapshotledger` VALUES (2242, 'test01', 19, 9, 0, 992763, 992763, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:05');
INSERT INTO `userscoresnapshotledger` VALUES (2243, 'test01', 19, 9, 0, 992758, 992758, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:05');
INSERT INTO `userscoresnapshotledger` VALUES (2244, 'test01', 19, 9, 0, 993628, 993628, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:05');
INSERT INTO `userscoresnapshotledger` VALUES (2245, 'test01', 19, 9, 0, 993638, 993638, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:05');
INSERT INTO `userscoresnapshotledger` VALUES (2246, 'test01', 19, 9, 0, 993633, 993633, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:06');
INSERT INTO `userscoresnapshotledger` VALUES (2247, 'test01', 19, 9, 0, 993678, 993678, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:06');
INSERT INTO `userscoresnapshotledger` VALUES (2248, 'test01', 19, 9, 0, 993673, 993673, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:06');
INSERT INTO `userscoresnapshotledger` VALUES (2249, 'test01', 19, 9, 0, 993748, 993748, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:06');
INSERT INTO `userscoresnapshotledger` VALUES (2250, 'test01', 19, 9, 0, 993743, 993743, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:06');
INSERT INTO `userscoresnapshotledger` VALUES (2251, 'test01', 19, 9, 0, 993738, 993738, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:06');
INSERT INTO `userscoresnapshotledger` VALUES (2252, 'test01', 19, 9, 0, 993733, 993733, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:06');
INSERT INTO `userscoresnapshotledger` VALUES (2253, 'test01', 19, 9, 0, 993728, 993728, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:07');
INSERT INTO `userscoresnapshotledger` VALUES (2254, 'test01', 19, 9, 0, 993723, 993723, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:07');
INSERT INTO `userscoresnapshotledger` VALUES (2255, 'test01', 19, 9, 0, 993848, 993848, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:07');
INSERT INTO `userscoresnapshotledger` VALUES (2256, 'test01', 19, 9, 0, 993843, 993843, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:07');
INSERT INTO `userscoresnapshotledger` VALUES (2257, 'test01', 19, 9, 0, 994043, 994043, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:07');
INSERT INTO `userscoresnapshotledger` VALUES (2258, 'test01', 19, 9, 0, 994038, 994038, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:07');
INSERT INTO `userscoresnapshotledger` VALUES (2259, 'test01', 19, 9, 0, 994088, 994088, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:07');
INSERT INTO `userscoresnapshotledger` VALUES (2260, 'test01', 19, 9, 0, 994083, 994083, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:08');
INSERT INTO `userscoresnapshotledger` VALUES (2261, 'test01', 19, 9, 0, 994093, 994093, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:08');
INSERT INTO `userscoresnapshotledger` VALUES (2262, 'test01', 19, 9, 0, 994088, 994088, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:08');
INSERT INTO `userscoresnapshotledger` VALUES (2263, 'test01', 19, 9, 0, 994098, 994098, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:08');
INSERT INTO `userscoresnapshotledger` VALUES (2264, 'test01', 19, 9, 0, 994093, 994093, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:08');
INSERT INTO `userscoresnapshotledger` VALUES (2265, 'test01', 19, 9, 0, 994088, 994088, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:08');
INSERT INTO `userscoresnapshotledger` VALUES (2266, 'test01', 19, 9, 0, 994083, 994083, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:08');
INSERT INTO `userscoresnapshotledger` VALUES (2267, 'test01', 19, 9, 0, 994163, 994163, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:09');
INSERT INTO `userscoresnapshotledger` VALUES (2268, 'test01', 19, 9, 0, 994158, 994158, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:09');
INSERT INTO `userscoresnapshotledger` VALUES (2269, 'test01', 19, 9, 0, 994658, 994658, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:09');
INSERT INTO `userscoresnapshotledger` VALUES (2270, 'test01', 19, 9, 0, 994668, 994668, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:09');
INSERT INTO `userscoresnapshotledger` VALUES (2271, 'test01', 19, 9, 0, 994678, 994678, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:09');
INSERT INTO `userscoresnapshotledger` VALUES (2272, 'test01', 19, 9, 0, 994673, 994673, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:09');
INSERT INTO `userscoresnapshotledger` VALUES (2273, 'test01', 19, 9, 0, 994668, 994668, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:09');
INSERT INTO `userscoresnapshotledger` VALUES (2274, 'test01', 19, 9, 0, 994678, 994678, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:09');
INSERT INTO `userscoresnapshotledger` VALUES (2275, 'test01', 19, 9, 0, 994673, 994673, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:09');
INSERT INTO `userscoresnapshotledger` VALUES (2276, 'test01', 19, 9, 0, 994688, 994688, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:09');
INSERT INTO `userscoresnapshotledger` VALUES (2277, 'test01', 19, 9, 0, 994683, 994683, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:10');
INSERT INTO `userscoresnapshotledger` VALUES (2278, 'test01', 19, 9, 0, 994733, 994733, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:10');
INSERT INTO `userscoresnapshotledger` VALUES (2279, 'test01', 19, 9, 0, 994728, 994728, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:10');
INSERT INTO `userscoresnapshotledger` VALUES (2280, 'test01', 19, 9, 0, 994723, 994723, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:10');
INSERT INTO `userscoresnapshotledger` VALUES (2281, 'test01', 19, 9, 0, 994768, 994768, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:10');
INSERT INTO `userscoresnapshotledger` VALUES (2282, 'test01', 19, 9, 0, 994778, 994778, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:10');
INSERT INTO `userscoresnapshotledger` VALUES (2283, 'test01', 19, 9, 0, 994773, 994773, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:10');
INSERT INTO `userscoresnapshotledger` VALUES (2284, 'test01', 19, 9, 0, 994833, 994833, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:10');
INSERT INTO `userscoresnapshotledger` VALUES (2285, 'test01', 19, 9, 0, 994828, 994828, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:10');
INSERT INTO `userscoresnapshotledger` VALUES (2286, 'test01', 19, 9, 0, 994823, 994823, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:11');
INSERT INTO `userscoresnapshotledger` VALUES (2287, 'test01', 19, 9, 0, 994818, 994818, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:11');
INSERT INTO `userscoresnapshotledger` VALUES (2288, 'test01', 19, 9, 0, 994813, 994813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:11');
INSERT INTO `userscoresnapshotledger` VALUES (2289, 'test01', 19, 9, 0, 994833, 994833, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:11');
INSERT INTO `userscoresnapshotledger` VALUES (2290, 'test01', 54, 0, 994833, 0, 0, 994833, 'SNAPSHOT_RECOVER:LOGIN', '2026-07-07 18:46:12');
INSERT INTO `userscoresnapshotledger` VALUES (2291, 'test01', 19, 10, 0, 994833, 994833, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:17');
INSERT INTO `userscoresnapshotledger` VALUES (2292, 'test01', 19, 10, 0, 994828, 994828, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:21');
INSERT INTO `userscoresnapshotledger` VALUES (2293, 'test01', 19, 10, 0, 994823, 994823, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:22');
INSERT INTO `userscoresnapshotledger` VALUES (2294, 'test01', 19, 10, 0, 994818, 994818, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:23');
INSERT INTO `userscoresnapshotledger` VALUES (2295, 'test01', 19, 10, 0, 994813, 994813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:24');
INSERT INTO `userscoresnapshotledger` VALUES (2296, 'test01', 19, 10, 0, 994808, 994808, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:24');
INSERT INTO `userscoresnapshotledger` VALUES (2297, 'test01', 19, 10, 0, 994803, 994803, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:24');
INSERT INTO `userscoresnapshotledger` VALUES (2298, 'test01', 19, 10, 0, 994798, 994798, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:25');
INSERT INTO `userscoresnapshotledger` VALUES (2299, 'test01', 19, 10, 0, 994793, 994793, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:25');
INSERT INTO `userscoresnapshotledger` VALUES (2300, 'test01', 19, 10, 0, 994788, 994788, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:25');
INSERT INTO `userscoresnapshotledger` VALUES (2301, 'test01', 19, 10, 0, 994838, 994838, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:26');
INSERT INTO `userscoresnapshotledger` VALUES (2302, 'test01', 19, 10, 0, 994833, 994833, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:30');
INSERT INTO `userscoresnapshotledger` VALUES (2303, 'test01', 19, 10, 0, 994843, 994843, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:30');
INSERT INTO `userscoresnapshotledger` VALUES (2304, 'test01', 19, 10, 0, 994838, 994838, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:30');
INSERT INTO `userscoresnapshotledger` VALUES (2305, 'test01', 19, 10, 0, 994833, 994833, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:30');
INSERT INTO `userscoresnapshotledger` VALUES (2306, 'test01', 19, 10, 0, 994828, 994828, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:31');
INSERT INTO `userscoresnapshotledger` VALUES (2307, 'test01', 19, 10, 0, 994823, 994823, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:31');
INSERT INTO `userscoresnapshotledger` VALUES (2308, 'test01', 19, 10, 0, 994818, 994818, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:31');
INSERT INTO `userscoresnapshotledger` VALUES (2309, 'test01', 19, 10, 0, 994813, 994813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:31');
INSERT INTO `userscoresnapshotledger` VALUES (2310, 'test01', 19, 10, 0, 994808, 994808, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:31');
INSERT INTO `userscoresnapshotledger` VALUES (2311, 'test01', 19, 10, 0, 994803, 994803, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:32');
INSERT INTO `userscoresnapshotledger` VALUES (2312, 'test01', 19, 10, 0, 994893, 994893, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:32');
INSERT INTO `userscoresnapshotledger` VALUES (2313, 'test01', 19, 10, 0, 994888, 994888, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:32');
INSERT INTO `userscoresnapshotledger` VALUES (2314, 'test01', 19, 10, 0, 994883, 994883, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:32');
INSERT INTO `userscoresnapshotledger` VALUES (2315, 'test01', 19, 10, 0, 994878, 994878, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:32');
INSERT INTO `userscoresnapshotledger` VALUES (2316, 'test01', 19, 10, 0, 994873, 994873, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:32');
INSERT INTO `userscoresnapshotledger` VALUES (2317, 'test01', 19, 10, 0, 994868, 994868, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:33');
INSERT INTO `userscoresnapshotledger` VALUES (2318, 'test01', 19, 10, 0, 994863, 994863, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:33');
INSERT INTO `userscoresnapshotledger` VALUES (2319, 'test01', 19, 10, 0, 994858, 994858, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:33');
INSERT INTO `userscoresnapshotledger` VALUES (2320, 'test01', 19, 10, 0, 994853, 994853, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:33');
INSERT INTO `userscoresnapshotledger` VALUES (2321, 'test01', 19, 10, 0, 994848, 994848, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:33');
INSERT INTO `userscoresnapshotledger` VALUES (2322, 'test01', 19, 10, 0, 994843, 994843, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:34');
INSERT INTO `userscoresnapshotledger` VALUES (2323, 'test01', 19, 10, 0, 994838, 994838, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:34');
INSERT INTO `userscoresnapshotledger` VALUES (2324, 'test01', 19, 10, 0, 994833, 994833, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:34');
INSERT INTO `userscoresnapshotledger` VALUES (2325, 'test01', 19, 10, 0, 994828, 994828, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:34');
INSERT INTO `userscoresnapshotledger` VALUES (2326, 'test01', 19, 10, 0, 994823, 994823, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:34');
INSERT INTO `userscoresnapshotledger` VALUES (2327, 'test01', 19, 10, 0, 994818, 994818, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:35');
INSERT INTO `userscoresnapshotledger` VALUES (2328, 'test01', 19, 10, 0, 994813, 994813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:35');
INSERT INTO `userscoresnapshotledger` VALUES (2329, 'test01', 19, 10, 0, 994808, 994808, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:35');
INSERT INTO `userscoresnapshotledger` VALUES (2330, 'test01', 19, 10, 0, 994803, 994803, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:35');
INSERT INTO `userscoresnapshotledger` VALUES (2331, 'test01', 19, 10, 0, 994798, 994798, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:35');
INSERT INTO `userscoresnapshotledger` VALUES (2332, 'test01', 19, 10, 0, 994793, 994793, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:36');
INSERT INTO `userscoresnapshotledger` VALUES (2333, 'test01', 19, 10, 0, 994788, 994788, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:36');
INSERT INTO `userscoresnapshotledger` VALUES (2334, 'test01', 19, 10, 0, 994783, 994783, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:36');
INSERT INTO `userscoresnapshotledger` VALUES (2335, 'test01', 19, 10, 0, 994778, 994778, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:36');
INSERT INTO `userscoresnapshotledger` VALUES (2336, 'test01', 19, 10, 0, 994878, 994878, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:36');
INSERT INTO `userscoresnapshotledger` VALUES (2337, 'test01', 19, 10, 0, 994873, 994873, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:36');
INSERT INTO `userscoresnapshotledger` VALUES (2338, 'test01', 19, 10, 0, 994923, 994923, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:36');
INSERT INTO `userscoresnapshotledger` VALUES (2339, 'test01', 19, 10, 0, 994918, 994918, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:37');
INSERT INTO `userscoresnapshotledger` VALUES (2340, 'test01', 19, 10, 0, 994913, 994913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:37');
INSERT INTO `userscoresnapshotledger` VALUES (2341, 'test01', 19, 10, 0, 994923, 994923, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:37');
INSERT INTO `userscoresnapshotledger` VALUES (2342, 'test01', 19, 10, 0, 994918, 994918, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:37');
INSERT INTO `userscoresnapshotledger` VALUES (2343, 'test01', 19, 10, 0, 994913, 994913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:37');
INSERT INTO `userscoresnapshotledger` VALUES (2344, 'test01', 19, 10, 0, 994908, 994908, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:37');
INSERT INTO `userscoresnapshotledger` VALUES (2345, 'test01', 19, 10, 0, 994903, 994903, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:38');
INSERT INTO `userscoresnapshotledger` VALUES (2346, 'test01', 19, 10, 0, 994898, 994898, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:38');
INSERT INTO `userscoresnapshotledger` VALUES (2347, 'test01', 19, 10, 0, 994893, 994893, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:38');
INSERT INTO `userscoresnapshotledger` VALUES (2348, 'test01', 19, 10, 0, 994953, 994953, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:38');
INSERT INTO `userscoresnapshotledger` VALUES (2349, 'test01', 19, 10, 0, 994948, 994948, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:38');
INSERT INTO `userscoresnapshotledger` VALUES (2350, 'test01', 19, 10, 0, 994943, 994943, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:38');
INSERT INTO `userscoresnapshotledger` VALUES (2351, 'test01', 19, 10, 0, 994993, 994993, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:38');
INSERT INTO `userscoresnapshotledger` VALUES (2352, 'test01', 19, 10, 0, 994988, 994988, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:39');
INSERT INTO `userscoresnapshotledger` VALUES (2353, 'test01', 19, 10, 0, 994983, 994983, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:39');
INSERT INTO `userscoresnapshotledger` VALUES (2354, 'test01', 19, 10, 0, 994978, 994978, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:39');
INSERT INTO `userscoresnapshotledger` VALUES (2355, 'test01', 19, 10, 0, 994973, 994973, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:39');
INSERT INTO `userscoresnapshotledger` VALUES (2356, 'test01', 19, 10, 0, 994968, 994968, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:39');
INSERT INTO `userscoresnapshotledger` VALUES (2357, 'test01', 19, 10, 0, 994963, 994963, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:40');
INSERT INTO `userscoresnapshotledger` VALUES (2358, 'test01', 19, 10, 0, 994958, 994958, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:40');
INSERT INTO `userscoresnapshotledger` VALUES (2359, 'test01', 19, 10, 0, 994953, 994953, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:40');
INSERT INTO `userscoresnapshotledger` VALUES (2360, 'test01', 19, 10, 0, 994948, 994948, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:40');
INSERT INTO `userscoresnapshotledger` VALUES (2361, 'test01', 19, 10, 0, 994943, 994943, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:40');
INSERT INTO `userscoresnapshotledger` VALUES (2362, 'test01', 19, 10, 0, 994938, 994938, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:41');
INSERT INTO `userscoresnapshotledger` VALUES (2363, 'test01', 19, 10, 0, 994903, 994903, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:46');
INSERT INTO `userscoresnapshotledger` VALUES (2364, 'test01', 19, 10, 0, 994888, 994888, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:52');
INSERT INTO `userscoresnapshotledger` VALUES (2365, 'test01', 19, 10, 0, 994918, 994918, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:52');
INSERT INTO `userscoresnapshotledger` VALUES (2366, 'test01', 19, 10, 0, 994903, 994903, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:46:52');
INSERT INTO `userscoresnapshotledger` VALUES (2367, 'test01', 19, 10, 0, 994803, 994803, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:07');
INSERT INTO `userscoresnapshotledger` VALUES (2368, 'test01', 19, 10, 0, 994703, 994703, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:07');
INSERT INTO `userscoresnapshotledger` VALUES (2369, 'test01', 19, 10, 0, 994603, 994603, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:07');
INSERT INTO `userscoresnapshotledger` VALUES (2370, 'test01', 19, 10, 0, 994503, 994503, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:07');
INSERT INTO `userscoresnapshotledger` VALUES (2371, 'test01', 19, 10, 0, 994403, 994403, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:08');
INSERT INTO `userscoresnapshotledger` VALUES (2372, 'test01', 19, 10, 0, 994303, 994303, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:08');
INSERT INTO `userscoresnapshotledger` VALUES (2373, 'test01', 19, 10, 0, 994203, 994203, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:08');
INSERT INTO `userscoresnapshotledger` VALUES (2374, 'test01', 19, 10, 0, 994103, 994103, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:08');
INSERT INTO `userscoresnapshotledger` VALUES (2375, 'test01', 19, 10, 0, 994003, 994003, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:08');
INSERT INTO `userscoresnapshotledger` VALUES (2376, 'test01', 19, 10, 0, 993903, 993903, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:08');
INSERT INTO `userscoresnapshotledger` VALUES (2377, 'test01', 19, 10, 0, 993803, 993803, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:08');
INSERT INTO `userscoresnapshotledger` VALUES (2378, 'test01', 19, 10, 0, 993703, 993703, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:08');
INSERT INTO `userscoresnapshotledger` VALUES (2379, 'test01', 19, 10, 0, 993603, 993603, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:08');
INSERT INTO `userscoresnapshotledger` VALUES (2380, 'test01', 19, 10, 0, 993503, 993503, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:09');
INSERT INTO `userscoresnapshotledger` VALUES (2381, 'test01', 19, 10, 0, 993403, 993403, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:09');
INSERT INTO `userscoresnapshotledger` VALUES (2382, 'test01', 19, 10, 0, 993303, 993303, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:09');
INSERT INTO `userscoresnapshotledger` VALUES (2383, 'test01', 19, 10, 0, 993203, 993203, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:09');
INSERT INTO `userscoresnapshotledger` VALUES (2384, 'test01', 19, 10, 0, 993103, 993103, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:09');
INSERT INTO `userscoresnapshotledger` VALUES (2385, 'test01', 19, 10, 0, 993003, 993003, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:09');
INSERT INTO `userscoresnapshotledger` VALUES (2386, 'test01', 19, 10, 0, 993903, 993903, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:09');
INSERT INTO `userscoresnapshotledger` VALUES (2387, 'test01', 19, 10, 0, 993803, 993803, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:09');
INSERT INTO `userscoresnapshotledger` VALUES (2388, 'test01', 19, 10, 0, 995803, 995803, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:09');
INSERT INTO `userscoresnapshotledger` VALUES (2389, 'test01', 19, 10, 0, 996103, 996103, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:09');
INSERT INTO `userscoresnapshotledger` VALUES (2390, 'test01', 19, 10, 0, 996003, 996003, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:09');
INSERT INTO `userscoresnapshotledger` VALUES (2391, 'test01', 19, 10, 0, 995903, 995903, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:10');
INSERT INTO `userscoresnapshotledger` VALUES (2392, 'test01', 19, 10, 0, 995803, 995803, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:10');
INSERT INTO `userscoresnapshotledger` VALUES (2393, 'test01', 19, 10, 0, 995703, 995703, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:10');
INSERT INTO `userscoresnapshotledger` VALUES (2394, 'test01', 19, 10, 0, 995603, 995603, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:10');
INSERT INTO `userscoresnapshotledger` VALUES (2395, 'test01', 19, 10, 0, 1013003, 1013003, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:10');
INSERT INTO `userscoresnapshotledger` VALUES (2396, 'test01', 19, 10, 0, 1016003, 1016003, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:10');
INSERT INTO `userscoresnapshotledger` VALUES (2397, 'test01', 19, 10, 0, 1015903, 1015903, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:10');
INSERT INTO `userscoresnapshotledger` VALUES (2398, 'test01', 19, 10, 0, 1015803, 1015803, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:10');
INSERT INTO `userscoresnapshotledger` VALUES (2399, 'test01', 19, 10, 0, 1015703, 1015703, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:10');
INSERT INTO `userscoresnapshotledger` VALUES (2400, 'test01', 19, 10, 0, 1015603, 1015603, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:10');
INSERT INTO `userscoresnapshotledger` VALUES (2401, 'test01', 19, 10, 0, 1015503, 1015503, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:10');
INSERT INTO `userscoresnapshotledger` VALUES (2402, 'test01', 19, 10, 0, 1015403, 1015403, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:10');
INSERT INTO `userscoresnapshotledger` VALUES (2403, 'test01', 19, 10, 0, 1015303, 1015303, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:10');
INSERT INTO `userscoresnapshotledger` VALUES (2404, 'test01', 19, 10, 0, 1015203, 1015203, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:10');
INSERT INTO `userscoresnapshotledger` VALUES (2405, 'test01', 19, 10, 0, 1016103, 1016103, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:11');
INSERT INTO `userscoresnapshotledger` VALUES (2406, 'test01', 19, 10, 0, 1016003, 1016003, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:11');
INSERT INTO `userscoresnapshotledger` VALUES (2407, 'test01', 19, 10, 0, 1015903, 1015903, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:11');
INSERT INTO `userscoresnapshotledger` VALUES (2408, 'test01', 19, 10, 0, 1015803, 1015803, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:11');
INSERT INTO `userscoresnapshotledger` VALUES (2409, 'test01', 19, 10, 0, 1016103, 1016103, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:11');
INSERT INTO `userscoresnapshotledger` VALUES (2410, 'test01', 19, 10, 0, 1016003, 1016003, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:11');
INSERT INTO `userscoresnapshotledger` VALUES (2411, 'test01', 19, 10, 0, 1015903, 1015903, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:11');
INSERT INTO `userscoresnapshotledger` VALUES (2412, 'test01', 19, 10, 0, 1015803, 1015803, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:11');
INSERT INTO `userscoresnapshotledger` VALUES (2413, 'test01', 19, 10, 0, 1015703, 1015703, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:11');
INSERT INTO `userscoresnapshotledger` VALUES (2414, 'test01', 19, 10, 0, 1015603, 1015603, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:11');
INSERT INTO `userscoresnapshotledger` VALUES (2415, 'test01', 19, 10, 0, 1015503, 1015503, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:11');
INSERT INTO `userscoresnapshotledger` VALUES (2416, 'test01', 19, 10, 0, 1015403, 1015403, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:11');
INSERT INTO `userscoresnapshotledger` VALUES (2417, 'test01', 19, 10, 0, 1015303, 1015303, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:12');
INSERT INTO `userscoresnapshotledger` VALUES (2418, 'test01', 19, 10, 0, 1015203, 1015203, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:12');
INSERT INTO `userscoresnapshotledger` VALUES (2419, 'test01', 19, 10, 0, 1015103, 1015103, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:12');
INSERT INTO `userscoresnapshotledger` VALUES (2420, 'test01', 19, 10, 0, 1015003, 1015003, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:12');
INSERT INTO `userscoresnapshotledger` VALUES (2421, 'test01', 19, 10, 0, 1014903, 1014903, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:12');
INSERT INTO `userscoresnapshotledger` VALUES (2422, 'test01', 19, 10, 0, 1014803, 1014803, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:12');
INSERT INTO `userscoresnapshotledger` VALUES (2423, 'test01', 19, 10, 0, 1014703, 1014703, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:12');
INSERT INTO `userscoresnapshotledger` VALUES (2424, 'test01', 19, 10, 0, 1014603, 1014603, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:12');
INSERT INTO `userscoresnapshotledger` VALUES (2425, 'test01', 19, 10, 0, 1014503, 1014503, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:12');
INSERT INTO `userscoresnapshotledger` VALUES (2426, 'test01', 19, 10, 0, 1014403, 1014403, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:12');
INSERT INTO `userscoresnapshotledger` VALUES (2427, 'test01', 19, 10, 0, 1014303, 1014303, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:13');
INSERT INTO `userscoresnapshotledger` VALUES (2428, 'test01', 19, 10, 0, 1014203, 1014203, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:13');
INSERT INTO `userscoresnapshotledger` VALUES (2429, 'test01', 19, 10, 0, 1014103, 1014103, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:13');
INSERT INTO `userscoresnapshotledger` VALUES (2430, 'test01', 19, 10, 0, 1014003, 1014003, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:13');
INSERT INTO `userscoresnapshotledger` VALUES (2431, 'test01', 19, 10, 0, 1013903, 1013903, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:13');
INSERT INTO `userscoresnapshotledger` VALUES (2432, 'test01', 19, 10, 0, 1013803, 1013803, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:13');
INSERT INTO `userscoresnapshotledger` VALUES (2433, 'test01', 19, 10, 0, 1013703, 1013703, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:13');
INSERT INTO `userscoresnapshotledger` VALUES (2434, 'test01', 19, 10, 0, 1013603, 1013603, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:13');
INSERT INTO `userscoresnapshotledger` VALUES (2435, 'test01', 19, 10, 0, 1013503, 1013503, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:13');
INSERT INTO `userscoresnapshotledger` VALUES (2436, 'test01', 19, 10, 0, 1013403, 1013403, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:13');
INSERT INTO `userscoresnapshotledger` VALUES (2437, 'test01', 19, 10, 0, 1013303, 1013303, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:14');
INSERT INTO `userscoresnapshotledger` VALUES (2438, 'test01', 19, 10, 0, 1013203, 1013203, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:14');
INSERT INTO `userscoresnapshotledger` VALUES (2439, 'test01', 19, 10, 0, 1013103, 1013103, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:14');
INSERT INTO `userscoresnapshotledger` VALUES (2440, 'test01', 19, 10, 0, 1013003, 1013003, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:14');
INSERT INTO `userscoresnapshotledger` VALUES (2441, 'test01', 19, 10, 0, 1012903, 1012903, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:14');
INSERT INTO `userscoresnapshotledger` VALUES (2442, 'test01', 19, 10, 0, 1015403, 1015403, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:14');
INSERT INTO `userscoresnapshotledger` VALUES (2443, 'test01', 19, 10, 0, 1015303, 1015303, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:14');
INSERT INTO `userscoresnapshotledger` VALUES (2444, 'test01', 19, 10, 0, 1015203, 1015203, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:14');
INSERT INTO `userscoresnapshotledger` VALUES (2445, 'test01', 19, 10, 0, 1015103, 1015103, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:14');
INSERT INTO `userscoresnapshotledger` VALUES (2446, 'test01', 19, 10, 0, 1015003, 1015003, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:14');
INSERT INTO `userscoresnapshotledger` VALUES (2447, 'test01', 19, 10, 0, 1014903, 1014903, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:14');
INSERT INTO `userscoresnapshotledger` VALUES (2448, 'test01', 19, 10, 0, 1014803, 1014803, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:15');
INSERT INTO `userscoresnapshotledger` VALUES (2449, 'test01', 19, 10, 0, 1014703, 1014703, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:15');
INSERT INTO `userscoresnapshotledger` VALUES (2450, 'test01', 19, 10, 0, 1014603, 1014603, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:15');
INSERT INTO `userscoresnapshotledger` VALUES (2451, 'test01', 19, 10, 0, 1014503, 1014503, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:15');
INSERT INTO `userscoresnapshotledger` VALUES (2452, 'test01', 19, 10, 0, 1014403, 1014403, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:15');
INSERT INTO `userscoresnapshotledger` VALUES (2453, 'test01', 19, 10, 0, 1014803, 1014803, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:15');
INSERT INTO `userscoresnapshotledger` VALUES (2454, 'test01', 19, 10, 0, 1024803, 1024803, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:15');
INSERT INTO `userscoresnapshotledger` VALUES (2455, 'test01', 19, 10, 0, 1024703, 1024703, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:15');
INSERT INTO `userscoresnapshotledger` VALUES (2456, 'test01', 19, 10, 0, 1024603, 1024603, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:15');
INSERT INTO `userscoresnapshotledger` VALUES (2457, 'test01', 19, 10, 0, 1024503, 1024503, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:15');
INSERT INTO `userscoresnapshotledger` VALUES (2458, 'test01', 19, 10, 0, 1024403, 1024403, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:15');
INSERT INTO `userscoresnapshotledger` VALUES (2459, 'test01', 19, 10, 0, 1024303, 1024303, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:15');
INSERT INTO `userscoresnapshotledger` VALUES (2460, 'test01', 19, 10, 0, 1024203, 1024203, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:16');
INSERT INTO `userscoresnapshotledger` VALUES (2461, 'test01', 19, 10, 0, 1024103, 1024103, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:16');
INSERT INTO `userscoresnapshotledger` VALUES (2462, 'test01', 19, 10, 0, 1024003, 1024003, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:16');
INSERT INTO `userscoresnapshotledger` VALUES (2463, 'test01', 19, 10, 0, 1023903, 1023903, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:16');
INSERT INTO `userscoresnapshotledger` VALUES (2464, 'test01', 19, 10, 0, 1023803, 1023803, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:16');
INSERT INTO `userscoresnapshotledger` VALUES (2465, 'test01', 19, 10, 0, 1023703, 1023703, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:16');
INSERT INTO `userscoresnapshotledger` VALUES (2466, 'test01', 19, 10, 0, 1023603, 1023603, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:16');
INSERT INTO `userscoresnapshotledger` VALUES (2467, 'test01', 19, 10, 0, 1023503, 1023503, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:16');
INSERT INTO `userscoresnapshotledger` VALUES (2468, 'test01', 19, 10, 0, 1023403, 1023403, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:16');
INSERT INTO `userscoresnapshotledger` VALUES (2469, 'test01', 19, 10, 0, 1023303, 1023303, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:16');
INSERT INTO `userscoresnapshotledger` VALUES (2470, 'test01', 19, 10, 0, 1023203, 1023203, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:17');
INSERT INTO `userscoresnapshotledger` VALUES (2471, 'test01', 19, 10, 0, 1023103, 1023103, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:17');
INSERT INTO `userscoresnapshotledger` VALUES (2472, 'test01', 19, 10, 0, 1023003, 1023003, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:17');
INSERT INTO `userscoresnapshotledger` VALUES (2473, 'test01', 19, 10, 0, 1022903, 1022903, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:17');
INSERT INTO `userscoresnapshotledger` VALUES (2474, 'test01', 19, 10, 0, 1022803, 1022803, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:17');
INSERT INTO `userscoresnapshotledger` VALUES (2475, 'test01', 19, 10, 0, 1022703, 1022703, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:17');
INSERT INTO `userscoresnapshotledger` VALUES (2476, 'test01', 19, 10, 0, 1022603, 1022603, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:17');
INSERT INTO `userscoresnapshotledger` VALUES (2477, 'test01', 19, 10, 0, 1022503, 1022503, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:17');
INSERT INTO `userscoresnapshotledger` VALUES (2478, 'test01', 19, 10, 0, 1022403, 1022403, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:17');
INSERT INTO `userscoresnapshotledger` VALUES (2479, 'test01', 19, 10, 0, 1022303, 1022303, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:17');
INSERT INTO `userscoresnapshotledger` VALUES (2480, 'test01', 19, 10, 0, 1022203, 1022203, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:18');
INSERT INTO `userscoresnapshotledger` VALUES (2481, 'test01', 19, 10, 0, 1022103, 1022103, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:18');
INSERT INTO `userscoresnapshotledger` VALUES (2482, 'test01', 19, 10, 0, 1022003, 1022003, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:18');
INSERT INTO `userscoresnapshotledger` VALUES (2483, 'test01', 19, 10, 0, 1021903, 1021903, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:18');
INSERT INTO `userscoresnapshotledger` VALUES (2484, 'test01', 19, 10, 0, 1021803, 1021803, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:18');
INSERT INTO `userscoresnapshotledger` VALUES (2485, 'test01', 19, 10, 0, 1025803, 1025803, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:18');
INSERT INTO `userscoresnapshotledger` VALUES (2486, 'test01', 19, 10, 0, 1025703, 1025703, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:18');
INSERT INTO `userscoresnapshotledger` VALUES (2487, 'test01', 19, 10, 0, 1025603, 1025603, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:18');
INSERT INTO `userscoresnapshotledger` VALUES (2488, 'test01', 19, 10, 0, 1025503, 1025503, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:18');
INSERT INTO `userscoresnapshotledger` VALUES (2489, 'test01', 19, 10, 0, 1025403, 1025403, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:18');
INSERT INTO `userscoresnapshotledger` VALUES (2490, 'test01', 19, 10, 0, 1025303, 1025303, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:18');
INSERT INTO `userscoresnapshotledger` VALUES (2491, 'test01', 19, 10, 0, 1025203, 1025203, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:19');
INSERT INTO `userscoresnapshotledger` VALUES (2492, 'test01', 19, 10, 0, 1025103, 1025103, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:19');
INSERT INTO `userscoresnapshotledger` VALUES (2493, 'test01', 19, 10, 0, 1025003, 1025003, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:19');
INSERT INTO `userscoresnapshotledger` VALUES (2494, 'test01', 19, 10, 0, 1024903, 1024903, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:19');
INSERT INTO `userscoresnapshotledger` VALUES (2495, 'test01', 19, 10, 0, 1024803, 1024803, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:19');
INSERT INTO `userscoresnapshotledger` VALUES (2496, 'test01', 19, 10, 0, 1024703, 1024703, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:19');
INSERT INTO `userscoresnapshotledger` VALUES (2497, 'test01', 54, 0, 1024703, 0, 0, 1024703, 'SNAPSHOT_RECOVER:GAME_LOST', '2026-07-07 18:47:19');
INSERT INTO `userscoresnapshotledger` VALUES (2498, 'test01', 19, 11, 0, 1024703, 1024703, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:42');
INSERT INTO `userscoresnapshotledger` VALUES (2499, 'test01', 19, 11, 0, 1024698, 1024698, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:45');
INSERT INTO `userscoresnapshotledger` VALUES (2500, 'test01', 19, 11, 0, 1024743, 1024743, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:45');
INSERT INTO `userscoresnapshotledger` VALUES (2501, 'test01', 19, 11, 0, 1024738, 1024738, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:46');
INSERT INTO `userscoresnapshotledger` VALUES (2502, 'test01', 19, 11, 0, 1024733, 1024733, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:46');
INSERT INTO `userscoresnapshotledger` VALUES (2503, 'test01', 19, 11, 1024733, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:52');
INSERT INTO `userscoresnapshotledger` VALUES (2504, 'test01', 19, 11, 1024733, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:53');
INSERT INTO `userscoresnapshotledger` VALUES (2505, 'test01', 19, 11, 1024733, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:53');
INSERT INTO `userscoresnapshotledger` VALUES (2506, 'test01', 19, 11, 0, 1024733, 1024733, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:56');
INSERT INTO `userscoresnapshotledger` VALUES (2507, 'test01', 19, 11, 0, 1024728, 1024728, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:58');
INSERT INTO `userscoresnapshotledger` VALUES (2508, 'test01', 19, 11, 0, 1024723, 1024723, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:47:59');
INSERT INTO `userscoresnapshotledger` VALUES (2509, 'test01', 19, 11, 0, 1024623, 1024623, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:01');
INSERT INTO `userscoresnapshotledger` VALUES (2510, 'test01', 19, 11, 0, 1024523, 1024523, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:02');
INSERT INTO `userscoresnapshotledger` VALUES (2511, 'test01', 19, 11, 0, 1024613, 1024613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:02');
INSERT INTO `userscoresnapshotledger` VALUES (2512, 'test01', 19, 11, 0, 1024513, 1024513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:02');
INSERT INTO `userscoresnapshotledger` VALUES (2513, 'test01', 19, 11, 0, 1024413, 1024413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:02');
INSERT INTO `userscoresnapshotledger` VALUES (2514, 'test01', 19, 11, 0, 1024313, 1024313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:02');
INSERT INTO `userscoresnapshotledger` VALUES (2515, 'test01', 19, 11, 0, 1024213, 1024213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:03');
INSERT INTO `userscoresnapshotledger` VALUES (2516, 'test01', 19, 11, 0, 1024113, 1024113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:03');
INSERT INTO `userscoresnapshotledger` VALUES (2517, 'test01', 19, 11, 0, 1024013, 1024013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:03');
INSERT INTO `userscoresnapshotledger` VALUES (2518, 'test01', 19, 11, 0, 1023913, 1023913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:03');
INSERT INTO `userscoresnapshotledger` VALUES (2519, 'test01', 19, 11, 0, 1023813, 1023813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:03');
INSERT INTO `userscoresnapshotledger` VALUES (2520, 'test01', 19, 11, 0, 1023713, 1023713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:04');
INSERT INTO `userscoresnapshotledger` VALUES (2521, 'test01', 19, 11, 0, 1023613, 1023613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:04');
INSERT INTO `userscoresnapshotledger` VALUES (2522, 'test01', 19, 11, 0, 1023513, 1023513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:04');
INSERT INTO `userscoresnapshotledger` VALUES (2523, 'test01', 19, 11, 0, 1023413, 1023413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:04');
INSERT INTO `userscoresnapshotledger` VALUES (2524, 'test01', 19, 11, 0, 1023313, 1023313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:04');
INSERT INTO `userscoresnapshotledger` VALUES (2525, 'test01', 19, 11, 0, 1023213, 1023213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:05');
INSERT INTO `userscoresnapshotledger` VALUES (2526, 'test01', 19, 11, 0, 1023113, 1023113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:05');
INSERT INTO `userscoresnapshotledger` VALUES (2527, 'test01', 19, 11, 0, 1023013, 1023013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:05');
INSERT INTO `userscoresnapshotledger` VALUES (2528, 'test01', 19, 11, 0, 1022913, 1022913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:05');
INSERT INTO `userscoresnapshotledger` VALUES (2529, 'test01', 19, 11, 0, 1022813, 1022813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:05');
INSERT INTO `userscoresnapshotledger` VALUES (2530, 'test01', 19, 11, 0, 1022713, 1022713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:06');
INSERT INTO `userscoresnapshotledger` VALUES (2531, 'test01', 19, 11, 0, 1022613, 1022613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:06');
INSERT INTO `userscoresnapshotledger` VALUES (2532, 'test01', 19, 11, 0, 1022513, 1022513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:06');
INSERT INTO `userscoresnapshotledger` VALUES (2533, 'test01', 19, 11, 0, 1022413, 1022413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:06');
INSERT INTO `userscoresnapshotledger` VALUES (2534, 'test01', 19, 11, 0, 1022313, 1022313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:06');
INSERT INTO `userscoresnapshotledger` VALUES (2535, 'test01', 19, 11, 0, 1022213, 1022213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:07');
INSERT INTO `userscoresnapshotledger` VALUES (2536, 'test01', 19, 11, 0, 1022113, 1022113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:07');
INSERT INTO `userscoresnapshotledger` VALUES (2537, 'test01', 19, 11, 0, 1022013, 1022013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:07');
INSERT INTO `userscoresnapshotledger` VALUES (2538, 'test01', 19, 11, 0, 1021913, 1021913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:07');
INSERT INTO `userscoresnapshotledger` VALUES (2539, 'test01', 19, 11, 0, 1021813, 1021813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:07');
INSERT INTO `userscoresnapshotledger` VALUES (2540, 'test01', 19, 11, 0, 1022013, 1022013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:07');
INSERT INTO `userscoresnapshotledger` VALUES (2541, 'test01', 19, 11, 0, 1021913, 1021913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:08');
INSERT INTO `userscoresnapshotledger` VALUES (2542, 'test01', 19, 11, 0, 1021813, 1021813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:08');
INSERT INTO `userscoresnapshotledger` VALUES (2543, 'test01', 19, 11, 0, 1021713, 1021713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:08');
INSERT INTO `userscoresnapshotledger` VALUES (2544, 'test01', 19, 11, 0, 1021613, 1021613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:08');
INSERT INTO `userscoresnapshotledger` VALUES (2545, 'test01', 19, 11, 0, 1021513, 1021513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:08');
INSERT INTO `userscoresnapshotledger` VALUES (2546, 'test01', 19, 11, 0, 1021413, 1021413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:09');
INSERT INTO `userscoresnapshotledger` VALUES (2547, 'test01', 19, 11, 0, 1021313, 1021313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:09');
INSERT INTO `userscoresnapshotledger` VALUES (2548, 'test01', 19, 11, 0, 1021213, 1021213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:09');
INSERT INTO `userscoresnapshotledger` VALUES (2549, 'test01', 19, 11, 0, 1021113, 1021113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:09');
INSERT INTO `userscoresnapshotledger` VALUES (2550, 'test01', 19, 11, 0, 1021013, 1021013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:09');
INSERT INTO `userscoresnapshotledger` VALUES (2551, 'test01', 19, 11, 0, 1020913, 1020913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:10');
INSERT INTO `userscoresnapshotledger` VALUES (2552, 'test01', 19, 11, 0, 1020813, 1020813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:10');
INSERT INTO `userscoresnapshotledger` VALUES (2553, 'test01', 19, 11, 0, 1020713, 1020713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:10');
INSERT INTO `userscoresnapshotledger` VALUES (2554, 'test01', 19, 11, 0, 1020613, 1020613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:10');
INSERT INTO `userscoresnapshotledger` VALUES (2555, 'test01', 19, 11, 0, 1020513, 1020513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:10');
INSERT INTO `userscoresnapshotledger` VALUES (2556, 'test01', 19, 11, 0, 1020413, 1020413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:11');
INSERT INTO `userscoresnapshotledger` VALUES (2557, 'test01', 19, 11, 0, 1020313, 1020313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:11');
INSERT INTO `userscoresnapshotledger` VALUES (2558, 'test01', 19, 11, 0, 1020213, 1020213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:11');
INSERT INTO `userscoresnapshotledger` VALUES (2559, 'test01', 19, 11, 0, 1020113, 1020113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:11');
INSERT INTO `userscoresnapshotledger` VALUES (2560, 'test01', 19, 11, 0, 1020013, 1020013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:11');
INSERT INTO `userscoresnapshotledger` VALUES (2561, 'test01', 19, 11, 0, 1019913, 1019913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:12');
INSERT INTO `userscoresnapshotledger` VALUES (2562, 'test01', 19, 11, 0, 1019813, 1019813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:12');
INSERT INTO `userscoresnapshotledger` VALUES (2563, 'test01', 19, 11, 0, 1019713, 1019713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:12');
INSERT INTO `userscoresnapshotledger` VALUES (2564, 'test01', 19, 11, 0, 1019613, 1019613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:12');
INSERT INTO `userscoresnapshotledger` VALUES (2565, 'test01', 19, 11, 0, 1019513, 1019513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:12');
INSERT INTO `userscoresnapshotledger` VALUES (2566, 'test01', 19, 11, 0, 1019413, 1019413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:13');
INSERT INTO `userscoresnapshotledger` VALUES (2567, 'test01', 19, 11, 0, 1019313, 1019313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:13');
INSERT INTO `userscoresnapshotledger` VALUES (2568, 'test01', 19, 11, 0, 1019213, 1019213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:13');
INSERT INTO `userscoresnapshotledger` VALUES (2569, 'test01', 19, 11, 0, 1019113, 1019113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:13');
INSERT INTO `userscoresnapshotledger` VALUES (2570, 'test01', 19, 11, 0, 1019013, 1019013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:13');
INSERT INTO `userscoresnapshotledger` VALUES (2571, 'test01', 19, 11, 0, 1018913, 1018913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:14');
INSERT INTO `userscoresnapshotledger` VALUES (2572, 'test01', 19, 11, 0, 1018813, 1018813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:14');
INSERT INTO `userscoresnapshotledger` VALUES (2573, 'test01', 19, 11, 0, 1018713, 1018713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:14');
INSERT INTO `userscoresnapshotledger` VALUES (2574, 'test01', 19, 11, 0, 1018613, 1018613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:14');
INSERT INTO `userscoresnapshotledger` VALUES (2575, 'test01', 19, 11, 0, 1018513, 1018513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:14');
INSERT INTO `userscoresnapshotledger` VALUES (2576, 'test01', 19, 11, 0, 1018413, 1018413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:15');
INSERT INTO `userscoresnapshotledger` VALUES (2577, 'test01', 19, 11, 0, 1018313, 1018313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:15');
INSERT INTO `userscoresnapshotledger` VALUES (2578, 'test01', 19, 11, 0, 1018213, 1018213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:15');
INSERT INTO `userscoresnapshotledger` VALUES (2579, 'test01', 19, 11, 0, 1018113, 1018113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:15');
INSERT INTO `userscoresnapshotledger` VALUES (2580, 'test01', 19, 11, 0, 1018913, 1018913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:15');
INSERT INTO `userscoresnapshotledger` VALUES (2581, 'test01', 19, 11, 0, 1018813, 1018813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:15');
INSERT INTO `userscoresnapshotledger` VALUES (2582, 'test01', 19, 11, 0, 1018713, 1018713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:16');
INSERT INTO `userscoresnapshotledger` VALUES (2583, 'test01', 19, 11, 0, 1018613, 1018613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:16');
INSERT INTO `userscoresnapshotledger` VALUES (2584, 'test01', 19, 11, 0, 1018513, 1018513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:16');
INSERT INTO `userscoresnapshotledger` VALUES (2585, 'test01', 19, 11, 0, 1018413, 1018413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:16');
INSERT INTO `userscoresnapshotledger` VALUES (2586, 'test01', 19, 11, 0, 1018313, 1018313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:16');
INSERT INTO `userscoresnapshotledger` VALUES (2587, 'test01', 19, 11, 0, 1018213, 1018213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:17');
INSERT INTO `userscoresnapshotledger` VALUES (2588, 'test01', 19, 11, 0, 1018113, 1018113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:17');
INSERT INTO `userscoresnapshotledger` VALUES (2589, 'test01', 19, 11, 0, 1018013, 1018013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:17');
INSERT INTO `userscoresnapshotledger` VALUES (2590, 'test01', 19, 11, 0, 1017913, 1017913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:17');
INSERT INTO `userscoresnapshotledger` VALUES (2591, 'test01', 19, 11, 0, 1017813, 1017813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:17');
INSERT INTO `userscoresnapshotledger` VALUES (2592, 'test01', 19, 11, 0, 1017713, 1017713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:18');
INSERT INTO `userscoresnapshotledger` VALUES (2593, 'test01', 19, 11, 0, 1017613, 1017613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:18');
INSERT INTO `userscoresnapshotledger` VALUES (2594, 'test01', 19, 11, 0, 1017513, 1017513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:18');
INSERT INTO `userscoresnapshotledger` VALUES (2595, 'test01', 19, 11, 0, 1017413, 1017413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:18');
INSERT INTO `userscoresnapshotledger` VALUES (2596, 'test01', 19, 11, 0, 1017313, 1017313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:18');
INSERT INTO `userscoresnapshotledger` VALUES (2597, 'test01', 19, 11, 0, 1017213, 1017213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:19');
INSERT INTO `userscoresnapshotledger` VALUES (2598, 'test01', 19, 11, 0, 1017413, 1017413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:19');
INSERT INTO `userscoresnapshotledger` VALUES (2599, 'test01', 19, 11, 0, 1017313, 1017313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:19');
INSERT INTO `userscoresnapshotledger` VALUES (2600, 'test01', 19, 11, 0, 1017213, 1017213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:19');
INSERT INTO `userscoresnapshotledger` VALUES (2601, 'test01', 19, 11, 0, 1017113, 1017113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:19');
INSERT INTO `userscoresnapshotledger` VALUES (2602, 'test01', 19, 11, 0, 1017013, 1017013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:19');
INSERT INTO `userscoresnapshotledger` VALUES (2603, 'test01', 19, 11, 0, 1016913, 1016913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:20');
INSERT INTO `userscoresnapshotledger` VALUES (2604, 'test01', 19, 11, 0, 1016813, 1016813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:20');
INSERT INTO `userscoresnapshotledger` VALUES (2605, 'test01', 19, 11, 0, 1016713, 1016713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:20');
INSERT INTO `userscoresnapshotledger` VALUES (2606, 'test01', 19, 11, 0, 1016613, 1016613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:20');
INSERT INTO `userscoresnapshotledger` VALUES (2607, 'test01', 19, 11, 0, 1016513, 1016513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:20');
INSERT INTO `userscoresnapshotledger` VALUES (2608, 'test01', 19, 11, 0, 1016413, 1016413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:21');
INSERT INTO `userscoresnapshotledger` VALUES (2609, 'test01', 19, 11, 0, 1016313, 1016313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:21');
INSERT INTO `userscoresnapshotledger` VALUES (2610, 'test01', 19, 11, 0, 1016213, 1016213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:21');
INSERT INTO `userscoresnapshotledger` VALUES (2611, 'test01', 19, 11, 0, 1016113, 1016113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:21');
INSERT INTO `userscoresnapshotledger` VALUES (2612, 'test01', 19, 11, 0, 1016013, 1016013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:21');
INSERT INTO `userscoresnapshotledger` VALUES (2613, 'test01', 19, 11, 0, 1015913, 1015913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:22');
INSERT INTO `userscoresnapshotledger` VALUES (2614, 'test01', 19, 11, 0, 1015813, 1015813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:22');
INSERT INTO `userscoresnapshotledger` VALUES (2615, 'test01', 19, 11, 0, 1015713, 1015713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:22');
INSERT INTO `userscoresnapshotledger` VALUES (2616, 'test01', 19, 11, 0, 1015613, 1015613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:22');
INSERT INTO `userscoresnapshotledger` VALUES (2617, 'test01', 19, 11, 0, 1015513, 1015513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:22');
INSERT INTO `userscoresnapshotledger` VALUES (2618, 'test01', 19, 11, 0, 1016413, 1016413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:23');
INSERT INTO `userscoresnapshotledger` VALUES (2619, 'test01', 19, 11, 0, 1016313, 1016313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:23');
INSERT INTO `userscoresnapshotledger` VALUES (2620, 'test01', 19, 11, 0, 1016213, 1016213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:23');
INSERT INTO `userscoresnapshotledger` VALUES (2621, 'test01', 19, 11, 0, 1016113, 1016113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:23');
INSERT INTO `userscoresnapshotledger` VALUES (2622, 'test01', 19, 11, 0, 1016013, 1016013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:23');
INSERT INTO `userscoresnapshotledger` VALUES (2623, 'test01', 19, 11, 0, 1015913, 1015913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:23');
INSERT INTO `userscoresnapshotledger` VALUES (2624, 'test01', 19, 11, 0, 1015813, 1015813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:24');
INSERT INTO `userscoresnapshotledger` VALUES (2625, 'test01', 19, 11, 0, 1015713, 1015713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:24');
INSERT INTO `userscoresnapshotledger` VALUES (2626, 'test01', 19, 11, 0, 1016113, 1016113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:24');
INSERT INTO `userscoresnapshotledger` VALUES (2627, 'test01', 19, 11, 0, 1016013, 1016013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:24');
INSERT INTO `userscoresnapshotledger` VALUES (2628, 'test01', 19, 11, 0, 1015913, 1015913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:24');
INSERT INTO `userscoresnapshotledger` VALUES (2629, 'test01', 19, 11, 0, 1018413, 1018413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:24');
INSERT INTO `userscoresnapshotledger` VALUES (2630, 'test01', 19, 11, 0, 1018313, 1018313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:24');
INSERT INTO `userscoresnapshotledger` VALUES (2631, 'test01', 19, 11, 0, 1018213, 1018213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:25');
INSERT INTO `userscoresnapshotledger` VALUES (2632, 'test01', 19, 11, 0, 1018113, 1018113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:25');
INSERT INTO `userscoresnapshotledger` VALUES (2633, 'test01', 19, 11, 0, 1018013, 1018013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:25');
INSERT INTO `userscoresnapshotledger` VALUES (2634, 'test01', 19, 11, 0, 1017913, 1017913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:25');
INSERT INTO `userscoresnapshotledger` VALUES (2635, 'test01', 19, 11, 0, 1017813, 1017813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:25');
INSERT INTO `userscoresnapshotledger` VALUES (2636, 'test01', 19, 11, 0, 1017713, 1017713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:26');
INSERT INTO `userscoresnapshotledger` VALUES (2637, 'test01', 19, 11, 0, 1017613, 1017613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:26');
INSERT INTO `userscoresnapshotledger` VALUES (2638, 'test01', 19, 11, 0, 1017513, 1017513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:26');
INSERT INTO `userscoresnapshotledger` VALUES (2639, 'test01', 19, 11, 0, 1017413, 1017413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:26');
INSERT INTO `userscoresnapshotledger` VALUES (2640, 'test01', 19, 11, 0, 1017613, 1017613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:26');
INSERT INTO `userscoresnapshotledger` VALUES (2641, 'test01', 19, 11, 0, 1017513, 1017513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:26');
INSERT INTO `userscoresnapshotledger` VALUES (2642, 'test01', 19, 11, 0, 1017413, 1017413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:27');
INSERT INTO `userscoresnapshotledger` VALUES (2643, 'test01', 19, 11, 0, 1017313, 1017313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:27');
INSERT INTO `userscoresnapshotledger` VALUES (2644, 'test01', 19, 11, 0, 1017213, 1017213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:27');
INSERT INTO `userscoresnapshotledger` VALUES (2645, 'test01', 19, 11, 0, 1017113, 1017113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:27');
INSERT INTO `userscoresnapshotledger` VALUES (2646, 'test01', 19, 11, 0, 1017013, 1017013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:27');
INSERT INTO `userscoresnapshotledger` VALUES (2647, 'test01', 19, 11, 0, 1016913, 1016913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:28');
INSERT INTO `userscoresnapshotledger` VALUES (2648, 'test01', 19, 11, 0, 1016813, 1016813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:28');
INSERT INTO `userscoresnapshotledger` VALUES (2649, 'test01', 19, 11, 0, 1016713, 1016713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:28');
INSERT INTO `userscoresnapshotledger` VALUES (2650, 'test01', 19, 11, 0, 1016613, 1016613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:28');
INSERT INTO `userscoresnapshotledger` VALUES (2651, 'test01', 19, 11, 0, 1016513, 1016513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:28');
INSERT INTO `userscoresnapshotledger` VALUES (2652, 'test01', 19, 11, 0, 1016413, 1016413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:29');
INSERT INTO `userscoresnapshotledger` VALUES (2653, 'test01', 19, 11, 0, 1016313, 1016313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:29');
INSERT INTO `userscoresnapshotledger` VALUES (2654, 'test01', 19, 11, 0, 1016213, 1016213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:29');
INSERT INTO `userscoresnapshotledger` VALUES (2655, 'test01', 19, 11, 0, 1016113, 1016113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:29');
INSERT INTO `userscoresnapshotledger` VALUES (2656, 'test01', 19, 11, 0, 1016013, 1016013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:29');
INSERT INTO `userscoresnapshotledger` VALUES (2657, 'test01', 19, 11, 0, 1015913, 1015913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:30');
INSERT INTO `userscoresnapshotledger` VALUES (2658, 'test01', 19, 11, 0, 1015813, 1015813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:30');
INSERT INTO `userscoresnapshotledger` VALUES (2659, 'test01', 19, 11, 0, 1015713, 1015713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:30');
INSERT INTO `userscoresnapshotledger` VALUES (2660, 'test01', 19, 11, 0, 1015613, 1015613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:30');
INSERT INTO `userscoresnapshotledger` VALUES (2661, 'test01', 19, 11, 0, 1015513, 1015513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:30');
INSERT INTO `userscoresnapshotledger` VALUES (2662, 'test01', 19, 11, 0, 1015413, 1015413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:31');
INSERT INTO `userscoresnapshotledger` VALUES (2663, 'test01', 19, 11, 0, 1015613, 1015613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:31');
INSERT INTO `userscoresnapshotledger` VALUES (2664, 'test01', 19, 11, 0, 1015513, 1015513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:31');
INSERT INTO `userscoresnapshotledger` VALUES (2665, 'test01', 19, 11, 0, 1015413, 1015413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:31');
INSERT INTO `userscoresnapshotledger` VALUES (2666, 'test01', 19, 11, 0, 1015313, 1015313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:31');
INSERT INTO `userscoresnapshotledger` VALUES (2667, 'test01', 19, 11, 0, 1015213, 1015213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:31');
INSERT INTO `userscoresnapshotledger` VALUES (2668, 'test01', 19, 11, 0, 1015113, 1015113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:32');
INSERT INTO `userscoresnapshotledger` VALUES (2669, 'test01', 19, 11, 0, 1015013, 1015013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:32');
INSERT INTO `userscoresnapshotledger` VALUES (2670, 'test01', 19, 11, 0, 1014913, 1014913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:32');
INSERT INTO `userscoresnapshotledger` VALUES (2671, 'test01', 19, 11, 0, 1014813, 1014813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:32');
INSERT INTO `userscoresnapshotledger` VALUES (2672, 'test01', 19, 11, 0, 1014713, 1014713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:32');
INSERT INTO `userscoresnapshotledger` VALUES (2673, 'test01', 19, 11, 0, 1014613, 1014613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:33');
INSERT INTO `userscoresnapshotledger` VALUES (2674, 'test01', 19, 11, 0, 1014513, 1014513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:33');
INSERT INTO `userscoresnapshotledger` VALUES (2675, 'test01', 19, 11, 0, 1014413, 1014413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:33');
INSERT INTO `userscoresnapshotledger` VALUES (2676, 'test01', 19, 11, 0, 1014313, 1014313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:33');
INSERT INTO `userscoresnapshotledger` VALUES (2677, 'test01', 19, 11, 0, 1014213, 1014213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:33');
INSERT INTO `userscoresnapshotledger` VALUES (2678, 'test01', 19, 11, 0, 1014113, 1014113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:34');
INSERT INTO `userscoresnapshotledger` VALUES (2679, 'test01', 19, 11, 0, 1014013, 1014013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:34');
INSERT INTO `userscoresnapshotledger` VALUES (2680, 'test01', 19, 11, 0, 1013913, 1013913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:34');
INSERT INTO `userscoresnapshotledger` VALUES (2681, 'test01', 19, 11, 0, 1013813, 1013813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:34');
INSERT INTO `userscoresnapshotledger` VALUES (2682, 'test01', 19, 11, 0, 1013713, 1013713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:34');
INSERT INTO `userscoresnapshotledger` VALUES (2683, 'test01', 19, 11, 0, 1013613, 1013613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:35');
INSERT INTO `userscoresnapshotledger` VALUES (2684, 'test01', 19, 11, 0, 1013513, 1013513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:35');
INSERT INTO `userscoresnapshotledger` VALUES (2685, 'test01', 19, 11, 0, 1013413, 1013413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:35');
INSERT INTO `userscoresnapshotledger` VALUES (2686, 'test01', 19, 11, 0, 1013313, 1013313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:35');
INSERT INTO `userscoresnapshotledger` VALUES (2687, 'test01', 19, 11, 0, 1013213, 1013213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:35');
INSERT INTO `userscoresnapshotledger` VALUES (2688, 'test01', 19, 11, 0, 1013113, 1013113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:36');
INSERT INTO `userscoresnapshotledger` VALUES (2689, 'test01', 19, 11, 0, 1013013, 1013013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:36');
INSERT INTO `userscoresnapshotledger` VALUES (2690, 'test01', 19, 11, 0, 1012913, 1012913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:36');
INSERT INTO `userscoresnapshotledger` VALUES (2691, 'test01', 19, 11, 0, 1012813, 1012813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:36');
INSERT INTO `userscoresnapshotledger` VALUES (2692, 'test01', 19, 11, 0, 1012713, 1012713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:36');
INSERT INTO `userscoresnapshotledger` VALUES (2693, 'test01', 19, 11, 0, 1012613, 1012613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:37');
INSERT INTO `userscoresnapshotledger` VALUES (2694, 'test01', 19, 11, 0, 1012513, 1012513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:37');
INSERT INTO `userscoresnapshotledger` VALUES (2695, 'test01', 19, 11, 0, 1012413, 1012413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:37');
INSERT INTO `userscoresnapshotledger` VALUES (2696, 'test01', 19, 11, 0, 1012313, 1012313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:37');
INSERT INTO `userscoresnapshotledger` VALUES (2697, 'test01', 19, 11, 0, 1012213, 1012213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:37');
INSERT INTO `userscoresnapshotledger` VALUES (2698, 'test01', 19, 11, 0, 1012113, 1012113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:38');
INSERT INTO `userscoresnapshotledger` VALUES (2699, 'test01', 19, 11, 0, 1012013, 1012013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:38');
INSERT INTO `userscoresnapshotledger` VALUES (2700, 'test01', 19, 11, 0, 1011913, 1011913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:38');
INSERT INTO `userscoresnapshotledger` VALUES (2701, 'test01', 19, 11, 0, 1011813, 1011813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:38');
INSERT INTO `userscoresnapshotledger` VALUES (2702, 'test01', 19, 11, 0, 1011713, 1011713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:38');
INSERT INTO `userscoresnapshotledger` VALUES (2703, 'test01', 19, 11, 0, 1011613, 1011613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:39');
INSERT INTO `userscoresnapshotledger` VALUES (2704, 'test01', 19, 11, 0, 1011513, 1011513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:39');
INSERT INTO `userscoresnapshotledger` VALUES (2705, 'test01', 19, 11, 0, 1011413, 1011413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:39');
INSERT INTO `userscoresnapshotledger` VALUES (2706, 'test01', 19, 11, 0, 1011313, 1011313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:39');
INSERT INTO `userscoresnapshotledger` VALUES (2707, 'test01', 19, 11, 0, 1011213, 1011213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:39');
INSERT INTO `userscoresnapshotledger` VALUES (2708, 'test01', 19, 11, 0, 1011113, 1011113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:40');
INSERT INTO `userscoresnapshotledger` VALUES (2709, 'test01', 19, 11, 0, 1011013, 1011013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:40');
INSERT INTO `userscoresnapshotledger` VALUES (2710, 'test01', 19, 11, 0, 1010913, 1010913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:40');
INSERT INTO `userscoresnapshotledger` VALUES (2711, 'test01', 19, 11, 0, 1010813, 1010813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:40');
INSERT INTO `userscoresnapshotledger` VALUES (2712, 'test01', 19, 11, 0, 1010713, 1010713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:40');
INSERT INTO `userscoresnapshotledger` VALUES (2713, 'test01', 19, 11, 0, 1010613, 1010613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:41');
INSERT INTO `userscoresnapshotledger` VALUES (2714, 'test01', 19, 11, 0, 1010513, 1010513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:41');
INSERT INTO `userscoresnapshotledger` VALUES (2715, 'test01', 19, 11, 0, 1010413, 1010413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:41');
INSERT INTO `userscoresnapshotledger` VALUES (2716, 'test01', 19, 11, 0, 1010313, 1010313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:41');
INSERT INTO `userscoresnapshotledger` VALUES (2717, 'test01', 19, 11, 0, 1010213, 1010213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:41');
INSERT INTO `userscoresnapshotledger` VALUES (2718, 'test01', 19, 11, 0, 1010113, 1010113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:42');
INSERT INTO `userscoresnapshotledger` VALUES (2719, 'test01', 19, 11, 0, 1010013, 1010013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:42');
INSERT INTO `userscoresnapshotledger` VALUES (2720, 'test01', 19, 11, 0, 1009913, 1009913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:42');
INSERT INTO `userscoresnapshotledger` VALUES (2721, 'test01', 19, 11, 0, 1009813, 1009813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:42');
INSERT INTO `userscoresnapshotledger` VALUES (2722, 'test01', 19, 11, 0, 1009713, 1009713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:42');
INSERT INTO `userscoresnapshotledger` VALUES (2723, 'test01', 19, 11, 0, 1009613, 1009613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:43');
INSERT INTO `userscoresnapshotledger` VALUES (2724, 'test01', 19, 11, 0, 1009513, 1009513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:43');
INSERT INTO `userscoresnapshotledger` VALUES (2725, 'test01', 19, 11, 0, 1009413, 1009413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:43');
INSERT INTO `userscoresnapshotledger` VALUES (2726, 'test01', 19, 11, 0, 1009313, 1009313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:43');
INSERT INTO `userscoresnapshotledger` VALUES (2727, 'test01', 19, 11, 0, 1009213, 1009213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:43');
INSERT INTO `userscoresnapshotledger` VALUES (2728, 'test01', 19, 11, 0, 1009113, 1009113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:44');
INSERT INTO `userscoresnapshotledger` VALUES (2729, 'test01', 19, 11, 0, 1009013, 1009013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:44');
INSERT INTO `userscoresnapshotledger` VALUES (2730, 'test01', 19, 11, 0, 1008913, 1008913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:44');
INSERT INTO `userscoresnapshotledger` VALUES (2731, 'test01', 19, 11, 0, 1008813, 1008813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:44');
INSERT INTO `userscoresnapshotledger` VALUES (2732, 'test01', 19, 11, 0, 1008713, 1008713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:44');
INSERT INTO `userscoresnapshotledger` VALUES (2733, 'test01', 19, 11, 0, 1008613, 1008613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:45');
INSERT INTO `userscoresnapshotledger` VALUES (2734, 'test01', 19, 11, 0, 1008513, 1008513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:45');
INSERT INTO `userscoresnapshotledger` VALUES (2735, 'test01', 19, 11, 0, 1008413, 1008413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:45');
INSERT INTO `userscoresnapshotledger` VALUES (2736, 'test01', 19, 11, 0, 1008313, 1008313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:45');
INSERT INTO `userscoresnapshotledger` VALUES (2737, 'test01', 19, 11, 0, 1008213, 1008213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:45');
INSERT INTO `userscoresnapshotledger` VALUES (2738, 'test01', 19, 11, 0, 1008113, 1008113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:46');
INSERT INTO `userscoresnapshotledger` VALUES (2739, 'test01', 19, 11, 0, 1008013, 1008013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:46');
INSERT INTO `userscoresnapshotledger` VALUES (2740, 'test01', 19, 11, 0, 1007913, 1007913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:46');
INSERT INTO `userscoresnapshotledger` VALUES (2741, 'test01', 19, 11, 0, 1007813, 1007813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:46');
INSERT INTO `userscoresnapshotledger` VALUES (2742, 'test01', 19, 11, 0, 1007713, 1007713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:46');
INSERT INTO `userscoresnapshotledger` VALUES (2743, 'test01', 19, 11, 0, 1007613, 1007613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:47');
INSERT INTO `userscoresnapshotledger` VALUES (2744, 'test01', 19, 11, 0, 1007513, 1007513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:47');
INSERT INTO `userscoresnapshotledger` VALUES (2745, 'test01', 19, 11, 0, 1007413, 1007413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:47');
INSERT INTO `userscoresnapshotledger` VALUES (2746, 'test01', 19, 11, 0, 1007313, 1007313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:47');
INSERT INTO `userscoresnapshotledger` VALUES (2747, 'test01', 19, 11, 0, 1007213, 1007213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:47');
INSERT INTO `userscoresnapshotledger` VALUES (2748, 'test01', 19, 11, 0, 1007113, 1007113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:48');
INSERT INTO `userscoresnapshotledger` VALUES (2749, 'test01', 19, 11, 0, 1007013, 1007013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:48');
INSERT INTO `userscoresnapshotledger` VALUES (2750, 'test01', 19, 11, 0, 1006913, 1006913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:48');
INSERT INTO `userscoresnapshotledger` VALUES (2751, 'test01', 19, 11, 0, 1007913, 1007913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:48');
INSERT INTO `userscoresnapshotledger` VALUES (2752, 'test01', 19, 11, 0, 1007813, 1007813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:48');
INSERT INTO `userscoresnapshotledger` VALUES (2753, 'test01', 19, 11, 0, 1007713, 1007713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:48');
INSERT INTO `userscoresnapshotledger` VALUES (2754, 'test01', 19, 11, 0, 1007613, 1007613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:49');
INSERT INTO `userscoresnapshotledger` VALUES (2755, 'test01', 19, 11, 0, 1007513, 1007513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:49');
INSERT INTO `userscoresnapshotledger` VALUES (2756, 'test01', 19, 11, 0, 1007413, 1007413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:49');
INSERT INTO `userscoresnapshotledger` VALUES (2757, 'test01', 19, 11, 0, 1007313, 1007313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:49');
INSERT INTO `userscoresnapshotledger` VALUES (2758, 'test01', 19, 11, 0, 1007213, 1007213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:49');
INSERT INTO `userscoresnapshotledger` VALUES (2759, 'test01', 19, 11, 0, 1007113, 1007113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:50');
INSERT INTO `userscoresnapshotledger` VALUES (2760, 'test01', 19, 11, 0, 1007013, 1007013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:50');
INSERT INTO `userscoresnapshotledger` VALUES (2761, 'test01', 19, 11, 0, 1006913, 1006913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:50');
INSERT INTO `userscoresnapshotledger` VALUES (2762, 'test01', 19, 11, 0, 1006813, 1006813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:50');
INSERT INTO `userscoresnapshotledger` VALUES (2763, 'test01', 19, 11, 0, 1006713, 1006713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:50');
INSERT INTO `userscoresnapshotledger` VALUES (2764, 'test01', 19, 11, 0, 1006613, 1006613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:51');
INSERT INTO `userscoresnapshotledger` VALUES (2765, 'test01', 19, 11, 0, 1006513, 1006513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:51');
INSERT INTO `userscoresnapshotledger` VALUES (2766, 'test01', 19, 11, 0, 1009013, 1009013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:51');
INSERT INTO `userscoresnapshotledger` VALUES (2767, 'test01', 19, 11, 0, 1008913, 1008913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:51');
INSERT INTO `userscoresnapshotledger` VALUES (2768, 'test01', 19, 11, 0, 1008813, 1008813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:51');
INSERT INTO `userscoresnapshotledger` VALUES (2769, 'test01', 19, 11, 0, 1008713, 1008713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:51');
INSERT INTO `userscoresnapshotledger` VALUES (2770, 'test01', 19, 11, 0, 1008613, 1008613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:52');
INSERT INTO `userscoresnapshotledger` VALUES (2771, 'test01', 19, 11, 0, 1008513, 1008513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:52');
INSERT INTO `userscoresnapshotledger` VALUES (2772, 'test01', 19, 11, 0, 1008413, 1008413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:52');
INSERT INTO `userscoresnapshotledger` VALUES (2773, 'test01', 19, 11, 0, 1008313, 1008313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:52');
INSERT INTO `userscoresnapshotledger` VALUES (2774, 'test01', 19, 11, 0, 1008213, 1008213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:52');
INSERT INTO `userscoresnapshotledger` VALUES (2775, 'test01', 19, 11, 0, 1008113, 1008113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:53');
INSERT INTO `userscoresnapshotledger` VALUES (2776, 'test01', 19, 11, 0, 1008013, 1008013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:53');
INSERT INTO `userscoresnapshotledger` VALUES (2777, 'test01', 19, 11, 0, 1007913, 1007913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:53');
INSERT INTO `userscoresnapshotledger` VALUES (2778, 'test01', 19, 11, 0, 1007813, 1007813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:53');
INSERT INTO `userscoresnapshotledger` VALUES (2779, 'test01', 19, 11, 0, 1009013, 1009013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:53');
INSERT INTO `userscoresnapshotledger` VALUES (2780, 'test01', 19, 11, 0, 1008913, 1008913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:53');
INSERT INTO `userscoresnapshotledger` VALUES (2781, 'test01', 19, 11, 0, 1008813, 1008813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:54');
INSERT INTO `userscoresnapshotledger` VALUES (2782, 'test01', 19, 11, 0, 1008713, 1008713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:54');
INSERT INTO `userscoresnapshotledger` VALUES (2783, 'test01', 19, 11, 0, 1008613, 1008613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:54');
INSERT INTO `userscoresnapshotledger` VALUES (2784, 'test01', 19, 11, 0, 1008513, 1008513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:54');
INSERT INTO `userscoresnapshotledger` VALUES (2785, 'test01', 19, 11, 0, 1008413, 1008413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:54');
INSERT INTO `userscoresnapshotledger` VALUES (2786, 'test01', 19, 11, 0, 1008313, 1008313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:54');
INSERT INTO `userscoresnapshotledger` VALUES (2787, 'test01', 19, 11, 0, 1008213, 1008213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:55');
INSERT INTO `userscoresnapshotledger` VALUES (2788, 'test01', 19, 11, 0, 1008113, 1008113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:55');
INSERT INTO `userscoresnapshotledger` VALUES (2789, 'test01', 19, 11, 0, 1008013, 1008013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:55');
INSERT INTO `userscoresnapshotledger` VALUES (2790, 'test01', 19, 11, 0, 1007913, 1007913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:55');
INSERT INTO `userscoresnapshotledger` VALUES (2791, 'test01', 19, 11, 0, 1007813, 1007813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:55');
INSERT INTO `userscoresnapshotledger` VALUES (2792, 'test01', 19, 11, 0, 1007713, 1007713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:56');
INSERT INTO `userscoresnapshotledger` VALUES (2793, 'test01', 19, 11, 0, 1007613, 1007613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:56');
INSERT INTO `userscoresnapshotledger` VALUES (2794, 'test01', 19, 11, 0, 1007513, 1007513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:56');
INSERT INTO `userscoresnapshotledger` VALUES (2795, 'test01', 19, 11, 0, 1007413, 1007413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:56');
INSERT INTO `userscoresnapshotledger` VALUES (2796, 'test01', 19, 11, 0, 1007313, 1007313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:56');
INSERT INTO `userscoresnapshotledger` VALUES (2797, 'test01', 19, 11, 0, 1007213, 1007213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:57');
INSERT INTO `userscoresnapshotledger` VALUES (2798, 'test01', 19, 11, 0, 1007113, 1007113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:57');
INSERT INTO `userscoresnapshotledger` VALUES (2799, 'test01', 19, 11, 0, 1007013, 1007013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:57');
INSERT INTO `userscoresnapshotledger` VALUES (2800, 'test01', 19, 11, 0, 1006913, 1006913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:57');
INSERT INTO `userscoresnapshotledger` VALUES (2801, 'test01', 19, 11, 0, 1006813, 1006813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:57');
INSERT INTO `userscoresnapshotledger` VALUES (2802, 'test01', 19, 11, 0, 1006713, 1006713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:58');
INSERT INTO `userscoresnapshotledger` VALUES (2803, 'test01', 19, 11, 0, 1006613, 1006613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:58');
INSERT INTO `userscoresnapshotledger` VALUES (2804, 'test01', 19, 11, 0, 1006513, 1006513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:58');
INSERT INTO `userscoresnapshotledger` VALUES (2805, 'test01', 19, 11, 0, 1006413, 1006413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:58');
INSERT INTO `userscoresnapshotledger` VALUES (2806, 'test01', 19, 11, 0, 1006313, 1006313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:58');
INSERT INTO `userscoresnapshotledger` VALUES (2807, 'test01', 19, 11, 0, 1006213, 1006213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:59');
INSERT INTO `userscoresnapshotledger` VALUES (2808, 'test01', 19, 11, 0, 1006113, 1006113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:59');
INSERT INTO `userscoresnapshotledger` VALUES (2809, 'test01', 19, 11, 0, 1006013, 1006013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:59');
INSERT INTO `userscoresnapshotledger` VALUES (2810, 'test01', 19, 11, 0, 1005913, 1005913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:59');
INSERT INTO `userscoresnapshotledger` VALUES (2811, 'test01', 19, 11, 0, 1005813, 1005813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:48:59');
INSERT INTO `userscoresnapshotledger` VALUES (2812, 'test01', 19, 11, 0, 1005713, 1005713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:00');
INSERT INTO `userscoresnapshotledger` VALUES (2813, 'test01', 19, 11, 0, 1005613, 1005613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:00');
INSERT INTO `userscoresnapshotledger` VALUES (2814, 'test01', 19, 11, 0, 1005513, 1005513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:00');
INSERT INTO `userscoresnapshotledger` VALUES (2815, 'test01', 19, 11, 0, 1005413, 1005413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:00');
INSERT INTO `userscoresnapshotledger` VALUES (2816, 'test01', 19, 11, 0, 1005313, 1005313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:00');
INSERT INTO `userscoresnapshotledger` VALUES (2817, 'test01', 19, 11, 0, 1005213, 1005213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:01');
INSERT INTO `userscoresnapshotledger` VALUES (2818, 'test01', 19, 11, 0, 1005113, 1005113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:01');
INSERT INTO `userscoresnapshotledger` VALUES (2819, 'test01', 19, 11, 0, 1005013, 1005013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:01');
INSERT INTO `userscoresnapshotledger` VALUES (2820, 'test01', 19, 11, 0, 1004913, 1004913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:01');
INSERT INTO `userscoresnapshotledger` VALUES (2821, 'test01', 19, 11, 0, 1004813, 1004813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:01');
INSERT INTO `userscoresnapshotledger` VALUES (2822, 'test01', 19, 11, 0, 1004713, 1004713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:02');
INSERT INTO `userscoresnapshotledger` VALUES (2823, 'test01', 19, 11, 0, 1004613, 1004613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:02');
INSERT INTO `userscoresnapshotledger` VALUES (2824, 'test01', 19, 11, 0, 1004513, 1004513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:02');
INSERT INTO `userscoresnapshotledger` VALUES (2825, 'test01', 19, 11, 0, 1004413, 1004413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:02');
INSERT INTO `userscoresnapshotledger` VALUES (2826, 'test01', 19, 11, 0, 1004313, 1004313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:02');
INSERT INTO `userscoresnapshotledger` VALUES (2827, 'test01', 19, 11, 0, 1004213, 1004213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:03');
INSERT INTO `userscoresnapshotledger` VALUES (2828, 'test01', 19, 11, 0, 1004113, 1004113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:03');
INSERT INTO `userscoresnapshotledger` VALUES (2829, 'test01', 19, 11, 0, 1004013, 1004013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:03');
INSERT INTO `userscoresnapshotledger` VALUES (2830, 'test01', 19, 11, 0, 1003913, 1003913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:03');
INSERT INTO `userscoresnapshotledger` VALUES (2831, 'test01', 19, 11, 0, 1003813, 1003813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:03');
INSERT INTO `userscoresnapshotledger` VALUES (2832, 'test01', 19, 11, 0, 1003713, 1003713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:04');
INSERT INTO `userscoresnapshotledger` VALUES (2833, 'test01', 19, 11, 0, 1003613, 1003613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:04');
INSERT INTO `userscoresnapshotledger` VALUES (2834, 'test01', 19, 11, 0, 1004513, 1004513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:04');
INSERT INTO `userscoresnapshotledger` VALUES (2835, 'test01', 19, 11, 0, 1004413, 1004413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:04');
INSERT INTO `userscoresnapshotledger` VALUES (2836, 'test01', 19, 11, 0, 1004313, 1004313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:04');
INSERT INTO `userscoresnapshotledger` VALUES (2837, 'test01', 19, 11, 0, 1004213, 1004213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:04');
INSERT INTO `userscoresnapshotledger` VALUES (2838, 'test01', 19, 11, 0, 1004113, 1004113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:05');
INSERT INTO `userscoresnapshotledger` VALUES (2839, 'test01', 19, 11, 0, 1004013, 1004013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:05');
INSERT INTO `userscoresnapshotledger` VALUES (2840, 'test01', 19, 11, 0, 1003913, 1003913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:05');
INSERT INTO `userscoresnapshotledger` VALUES (2841, 'test01', 19, 11, 0, 1003813, 1003813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:05');
INSERT INTO `userscoresnapshotledger` VALUES (2842, 'test01', 19, 11, 0, 1003713, 1003713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:05');
INSERT INTO `userscoresnapshotledger` VALUES (2843, 'test01', 19, 11, 0, 1003613, 1003613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:06');
INSERT INTO `userscoresnapshotledger` VALUES (2844, 'test01', 19, 11, 0, 1003513, 1003513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:06');
INSERT INTO `userscoresnapshotledger` VALUES (2845, 'test01', 19, 11, 0, 1003413, 1003413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:06');
INSERT INTO `userscoresnapshotledger` VALUES (2846, 'test01', 19, 11, 0, 1003313, 1003313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:06');
INSERT INTO `userscoresnapshotledger` VALUES (2847, 'test01', 19, 11, 0, 1003213, 1003213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:06');
INSERT INTO `userscoresnapshotledger` VALUES (2848, 'test01', 19, 11, 0, 1003113, 1003113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:07');
INSERT INTO `userscoresnapshotledger` VALUES (2849, 'test01', 19, 11, 0, 1003013, 1003013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:07');
INSERT INTO `userscoresnapshotledger` VALUES (2850, 'test01', 19, 11, 0, 1020413, 1020413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:07');
INSERT INTO `userscoresnapshotledger` VALUES (2851, 'test01', 19, 11, 0, 1020313, 1020313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:07');
INSERT INTO `userscoresnapshotledger` VALUES (2852, 'test01', 19, 11, 0, 1020213, 1020213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:07');
INSERT INTO `userscoresnapshotledger` VALUES (2853, 'test01', 19, 11, 0, 1020813, 1020813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:07');
INSERT INTO `userscoresnapshotledger` VALUES (2854, 'test01', 19, 11, 0, 1020713, 1020713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:07');
INSERT INTO `userscoresnapshotledger` VALUES (2855, 'test01', 19, 11, 0, 1020613, 1020613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:08');
INSERT INTO `userscoresnapshotledger` VALUES (2856, 'test01', 19, 11, 0, 1020513, 1020513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:08');
INSERT INTO `userscoresnapshotledger` VALUES (2857, 'test01', 19, 11, 0, 1020413, 1020413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:08');
INSERT INTO `userscoresnapshotledger` VALUES (2858, 'test01', 19, 11, 0, 1020313, 1020313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:08');
INSERT INTO `userscoresnapshotledger` VALUES (2859, 'test01', 19, 11, 0, 1020213, 1020213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:08');
INSERT INTO `userscoresnapshotledger` VALUES (2860, 'test01', 19, 11, 0, 1020113, 1020113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:09');
INSERT INTO `userscoresnapshotledger` VALUES (2861, 'test01', 19, 11, 0, 1020013, 1020013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:09');
INSERT INTO `userscoresnapshotledger` VALUES (2862, 'test01', 19, 11, 0, 1019913, 1019913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:09');
INSERT INTO `userscoresnapshotledger` VALUES (2863, 'test01', 19, 11, 0, 1019813, 1019813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:09');
INSERT INTO `userscoresnapshotledger` VALUES (2864, 'test01', 19, 11, 0, 1019713, 1019713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:09');
INSERT INTO `userscoresnapshotledger` VALUES (2865, 'test01', 19, 11, 0, 1019613, 1019613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:10');
INSERT INTO `userscoresnapshotledger` VALUES (2866, 'test01', 19, 11, 0, 1019513, 1019513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:10');
INSERT INTO `userscoresnapshotledger` VALUES (2867, 'test01', 19, 11, 0, 1019413, 1019413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:10');
INSERT INTO `userscoresnapshotledger` VALUES (2868, 'test01', 19, 11, 0, 1019313, 1019313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:10');
INSERT INTO `userscoresnapshotledger` VALUES (2869, 'test01', 19, 11, 0, 1019213, 1019213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:10');
INSERT INTO `userscoresnapshotledger` VALUES (2870, 'test01', 19, 11, 0, 1019113, 1019113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:11');
INSERT INTO `userscoresnapshotledger` VALUES (2871, 'test01', 19, 11, 0, 1019013, 1019013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:11');
INSERT INTO `userscoresnapshotledger` VALUES (2872, 'test01', 19, 11, 0, 1018913, 1018913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:11');
INSERT INTO `userscoresnapshotledger` VALUES (2873, 'test01', 19, 11, 0, 1018813, 1018813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:11');
INSERT INTO `userscoresnapshotledger` VALUES (2874, 'test01', 19, 11, 0, 1018713, 1018713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:11');
INSERT INTO `userscoresnapshotledger` VALUES (2875, 'test01', 19, 11, 0, 1018613, 1018613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:12');
INSERT INTO `userscoresnapshotledger` VALUES (2876, 'test01', 19, 11, 0, 1018513, 1018513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:12');
INSERT INTO `userscoresnapshotledger` VALUES (2877, 'test01', 19, 11, 0, 1018413, 1018413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:12');
INSERT INTO `userscoresnapshotledger` VALUES (2878, 'test01', 19, 11, 0, 1018313, 1018313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:12');
INSERT INTO `userscoresnapshotledger` VALUES (2879, 'test01', 19, 11, 0, 1018213, 1018213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:12');
INSERT INTO `userscoresnapshotledger` VALUES (2880, 'test01', 19, 11, 0, 1018113, 1018113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:13');
INSERT INTO `userscoresnapshotledger` VALUES (2881, 'test01', 19, 11, 0, 1018013, 1018013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:13');
INSERT INTO `userscoresnapshotledger` VALUES (2882, 'test01', 19, 11, 0, 1017913, 1017913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:13');
INSERT INTO `userscoresnapshotledger` VALUES (2883, 'test01', 19, 11, 0, 1017813, 1017813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:13');
INSERT INTO `userscoresnapshotledger` VALUES (2884, 'test01', 19, 11, 0, 1017713, 1017713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:13');
INSERT INTO `userscoresnapshotledger` VALUES (2885, 'test01', 19, 11, 0, 1017613, 1017613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:14');
INSERT INTO `userscoresnapshotledger` VALUES (2886, 'test01', 19, 11, 0, 1017513, 1017513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:14');
INSERT INTO `userscoresnapshotledger` VALUES (2887, 'test01', 19, 11, 0, 1017413, 1017413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:14');
INSERT INTO `userscoresnapshotledger` VALUES (2888, 'test01', 19, 11, 0, 1017313, 1017313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:14');
INSERT INTO `userscoresnapshotledger` VALUES (2889, 'test01', 19, 11, 0, 1017213, 1017213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:15');
INSERT INTO `userscoresnapshotledger` VALUES (2890, 'test01', 19, 11, 0, 1017113, 1017113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:15');
INSERT INTO `userscoresnapshotledger` VALUES (2891, 'test01', 19, 11, 0, 1017013, 1017013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:15');
INSERT INTO `userscoresnapshotledger` VALUES (2892, 'test01', 19, 11, 0, 1016913, 1016913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:15');
INSERT INTO `userscoresnapshotledger` VALUES (2893, 'test01', 19, 11, 0, 1016813, 1016813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:15');
INSERT INTO `userscoresnapshotledger` VALUES (2894, 'test01', 19, 11, 0, 1016713, 1016713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:15');
INSERT INTO `userscoresnapshotledger` VALUES (2895, 'test01', 19, 11, 0, 1016613, 1016613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:16');
INSERT INTO `userscoresnapshotledger` VALUES (2896, 'test01', 19, 11, 0, 1016513, 1016513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:16');
INSERT INTO `userscoresnapshotledger` VALUES (2897, 'test01', 19, 11, 0, 1016413, 1016413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:16');
INSERT INTO `userscoresnapshotledger` VALUES (2898, 'test01', 19, 11, 0, 1016313, 1016313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:16');
INSERT INTO `userscoresnapshotledger` VALUES (2899, 'test01', 19, 11, 0, 1016213, 1016213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:16');
INSERT INTO `userscoresnapshotledger` VALUES (2900, 'test01', 19, 11, 0, 1016113, 1016113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:17');
INSERT INTO `userscoresnapshotledger` VALUES (2901, 'test01', 19, 11, 0, 1018613, 1018613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:17');
INSERT INTO `userscoresnapshotledger` VALUES (2902, 'test01', 19, 11, 0, 1018513, 1018513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:17');
INSERT INTO `userscoresnapshotledger` VALUES (2903, 'test01', 19, 11, 0, 1018413, 1018413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:17');
INSERT INTO `userscoresnapshotledger` VALUES (2904, 'test01', 19, 11, 0, 1018313, 1018313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:17');
INSERT INTO `userscoresnapshotledger` VALUES (2905, 'test01', 19, 11, 0, 1018213, 1018213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:17');
INSERT INTO `userscoresnapshotledger` VALUES (2906, 'test01', 19, 11, 0, 1018113, 1018113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:18');
INSERT INTO `userscoresnapshotledger` VALUES (2907, 'test01', 19, 11, 0, 1018013, 1018013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:18');
INSERT INTO `userscoresnapshotledger` VALUES (2908, 'test01', 19, 11, 0, 1017913, 1017913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:18');
INSERT INTO `userscoresnapshotledger` VALUES (2909, 'test01', 19, 11, 0, 1017813, 1017813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:18');
INSERT INTO `userscoresnapshotledger` VALUES (2910, 'test01', 19, 11, 0, 1017713, 1017713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:18');
INSERT INTO `userscoresnapshotledger` VALUES (2911, 'test01', 19, 11, 0, 1017613, 1017613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:19');
INSERT INTO `userscoresnapshotledger` VALUES (2912, 'test01', 19, 11, 0, 1017513, 1017513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:19');
INSERT INTO `userscoresnapshotledger` VALUES (2913, 'test01', 19, 11, 0, 1017413, 1017413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:19');
INSERT INTO `userscoresnapshotledger` VALUES (2914, 'test01', 19, 11, 0, 1017313, 1017313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:19');
INSERT INTO `userscoresnapshotledger` VALUES (2915, 'test01', 19, 11, 0, 1017213, 1017213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:19');
INSERT INTO `userscoresnapshotledger` VALUES (2916, 'test01', 19, 11, 0, 1017113, 1017113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:20');
INSERT INTO `userscoresnapshotledger` VALUES (2917, 'test01', 19, 11, 0, 1017013, 1017013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:20');
INSERT INTO `userscoresnapshotledger` VALUES (2918, 'test01', 19, 11, 0, 1016913, 1016913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:20');
INSERT INTO `userscoresnapshotledger` VALUES (2919, 'test01', 19, 11, 0, 1016813, 1016813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:20');
INSERT INTO `userscoresnapshotledger` VALUES (2920, 'test01', 19, 11, 0, 1016713, 1016713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:20');
INSERT INTO `userscoresnapshotledger` VALUES (2921, 'test01', 19, 11, 0, 1016613, 1016613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:21');
INSERT INTO `userscoresnapshotledger` VALUES (2922, 'test01', 19, 11, 0, 1016513, 1016513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:21');
INSERT INTO `userscoresnapshotledger` VALUES (2923, 'test01', 19, 11, 0, 1016413, 1016413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:21');
INSERT INTO `userscoresnapshotledger` VALUES (2924, 'test01', 19, 11, 0, 1016313, 1016313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:21');
INSERT INTO `userscoresnapshotledger` VALUES (2925, 'test01', 19, 11, 0, 1022313, 1022313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:21');
INSERT INTO `userscoresnapshotledger` VALUES (2926, 'test01', 19, 11, 0, 1022213, 1022213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:21');
INSERT INTO `userscoresnapshotledger` VALUES (2927, 'test01', 19, 11, 0, 1022113, 1022113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:22');
INSERT INTO `userscoresnapshotledger` VALUES (2928, 'test01', 19, 11, 0, 1022013, 1022013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:22');
INSERT INTO `userscoresnapshotledger` VALUES (2929, 'test01', 19, 11, 0, 1021913, 1021913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:22');
INSERT INTO `userscoresnapshotledger` VALUES (2930, 'test01', 19, 11, 0, 1021813, 1021813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:22');
INSERT INTO `userscoresnapshotledger` VALUES (2931, 'test01', 19, 11, 0, 1021713, 1021713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:22');
INSERT INTO `userscoresnapshotledger` VALUES (2932, 'test01', 19, 11, 0, 1021613, 1021613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:23');
INSERT INTO `userscoresnapshotledger` VALUES (2933, 'test01', 19, 11, 0, 1021513, 1021513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:23');
INSERT INTO `userscoresnapshotledger` VALUES (2934, 'test01', 19, 11, 0, 1021413, 1021413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:23');
INSERT INTO `userscoresnapshotledger` VALUES (2935, 'test01', 19, 11, 0, 1021313, 1021313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:23');
INSERT INTO `userscoresnapshotledger` VALUES (2936, 'test01', 19, 11, 0, 1021213, 1021213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:23');
INSERT INTO `userscoresnapshotledger` VALUES (2937, 'test01', 19, 11, 0, 1021113, 1021113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:24');
INSERT INTO `userscoresnapshotledger` VALUES (2938, 'test01', 19, 11, 0, 1021013, 1021013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:24');
INSERT INTO `userscoresnapshotledger` VALUES (2939, 'test01', 19, 11, 0, 1020913, 1020913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:24');
INSERT INTO `userscoresnapshotledger` VALUES (2940, 'test01', 19, 11, 0, 1020813, 1020813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:24');
INSERT INTO `userscoresnapshotledger` VALUES (2941, 'test01', 19, 11, 0, 1020713, 1020713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:24');
INSERT INTO `userscoresnapshotledger` VALUES (2942, 'test01', 19, 11, 0, 1020613, 1020613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:25');
INSERT INTO `userscoresnapshotledger` VALUES (2943, 'test01', 19, 11, 0, 1020513, 1020513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:25');
INSERT INTO `userscoresnapshotledger` VALUES (2944, 'test01', 19, 11, 0, 1020413, 1020413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:25');
INSERT INTO `userscoresnapshotledger` VALUES (2945, 'test01', 19, 11, 0, 1020313, 1020313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:25');
INSERT INTO `userscoresnapshotledger` VALUES (2946, 'test01', 19, 11, 0, 1020213, 1020213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:25');
INSERT INTO `userscoresnapshotledger` VALUES (2947, 'test01', 19, 11, 0, 1020113, 1020113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:26');
INSERT INTO `userscoresnapshotledger` VALUES (2948, 'test01', 19, 11, 0, 1020013, 1020013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:26');
INSERT INTO `userscoresnapshotledger` VALUES (2949, 'test01', 19, 11, 0, 1019913, 1019913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:26');
INSERT INTO `userscoresnapshotledger` VALUES (2950, 'test01', 19, 11, 0, 1019813, 1019813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:26');
INSERT INTO `userscoresnapshotledger` VALUES (2951, 'test01', 19, 11, 0, 1019713, 1019713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:26');
INSERT INTO `userscoresnapshotledger` VALUES (2952, 'test01', 19, 11, 0, 1019613, 1019613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:27');
INSERT INTO `userscoresnapshotledger` VALUES (2953, 'test01', 19, 11, 0, 1019513, 1019513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:27');
INSERT INTO `userscoresnapshotledger` VALUES (2954, 'test01', 19, 11, 0, 1023513, 1023513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:27');
INSERT INTO `userscoresnapshotledger` VALUES (2955, 'test01', 19, 11, 0, 1023413, 1023413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:27');
INSERT INTO `userscoresnapshotledger` VALUES (2956, 'test01', 19, 11, 0, 1023313, 1023313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:27');
INSERT INTO `userscoresnapshotledger` VALUES (2957, 'test01', 19, 11, 0, 1023213, 1023213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:27');
INSERT INTO `userscoresnapshotledger` VALUES (2958, 'test01', 19, 11, 0, 1023113, 1023113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:28');
INSERT INTO `userscoresnapshotledger` VALUES (2959, 'test01', 19, 11, 0, 1023013, 1023013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:28');
INSERT INTO `userscoresnapshotledger` VALUES (2960, 'test01', 19, 11, 0, 1022913, 1022913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:28');
INSERT INTO `userscoresnapshotledger` VALUES (2961, 'test01', 19, 11, 0, 1022813, 1022813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:28');
INSERT INTO `userscoresnapshotledger` VALUES (2962, 'test01', 19, 11, 0, 1022713, 1022713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:28');
INSERT INTO `userscoresnapshotledger` VALUES (2963, 'test01', 19, 11, 0, 1022613, 1022613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:29');
INSERT INTO `userscoresnapshotledger` VALUES (2964, 'test01', 19, 11, 0, 1022513, 1022513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:29');
INSERT INTO `userscoresnapshotledger` VALUES (2965, 'test01', 19, 11, 0, 1022413, 1022413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:29');
INSERT INTO `userscoresnapshotledger` VALUES (2966, 'test01', 19, 11, 0, 1022313, 1022313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:29');
INSERT INTO `userscoresnapshotledger` VALUES (2967, 'test01', 19, 11, 0, 1022213, 1022213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:29');
INSERT INTO `userscoresnapshotledger` VALUES (2968, 'test01', 19, 11, 0, 1022113, 1022113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:30');
INSERT INTO `userscoresnapshotledger` VALUES (2969, 'test01', 19, 11, 0, 1022013, 1022013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:30');
INSERT INTO `userscoresnapshotledger` VALUES (2970, 'test01', 19, 11, 0, 1021913, 1021913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:30');
INSERT INTO `userscoresnapshotledger` VALUES (2971, 'test01', 19, 11, 0, 1021813, 1021813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:30');
INSERT INTO `userscoresnapshotledger` VALUES (2972, 'test01', 19, 11, 0, 1021713, 1021713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:31');
INSERT INTO `userscoresnapshotledger` VALUES (2973, 'test01', 19, 11, 0, 1021613, 1021613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:31');
INSERT INTO `userscoresnapshotledger` VALUES (2974, 'test01', 19, 11, 0, 1021513, 1021513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:31');
INSERT INTO `userscoresnapshotledger` VALUES (2975, 'test01', 19, 11, 0, 1021413, 1021413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:31');
INSERT INTO `userscoresnapshotledger` VALUES (2976, 'test01', 19, 11, 0, 1021313, 1021313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:31');
INSERT INTO `userscoresnapshotledger` VALUES (2977, 'test01', 19, 11, 0, 1021213, 1021213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:31');
INSERT INTO `userscoresnapshotledger` VALUES (2978, 'test01', 19, 11, 0, 1021113, 1021113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:32');
INSERT INTO `userscoresnapshotledger` VALUES (2979, 'test01', 19, 11, 0, 1021013, 1021013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:32');
INSERT INTO `userscoresnapshotledger` VALUES (2980, 'test01', 19, 11, 0, 1020913, 1020913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:32');
INSERT INTO `userscoresnapshotledger` VALUES (2981, 'test01', 19, 11, 0, 1020813, 1020813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:32');
INSERT INTO `userscoresnapshotledger` VALUES (2982, 'test01', 19, 11, 0, 1020713, 1020713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:32');
INSERT INTO `userscoresnapshotledger` VALUES (2983, 'test01', 19, 11, 0, 1020613, 1020613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:33');
INSERT INTO `userscoresnapshotledger` VALUES (2984, 'test01', 19, 11, 0, 1020513, 1020513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:33');
INSERT INTO `userscoresnapshotledger` VALUES (2985, 'test01', 19, 11, 0, 1020413, 1020413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:33');
INSERT INTO `userscoresnapshotledger` VALUES (2986, 'test01', 19, 11, 0, 1020313, 1020313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:33');
INSERT INTO `userscoresnapshotledger` VALUES (2987, 'test01', 19, 11, 0, 1020213, 1020213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:33');
INSERT INTO `userscoresnapshotledger` VALUES (2988, 'test01', 19, 11, 0, 1020113, 1020113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:34');
INSERT INTO `userscoresnapshotledger` VALUES (2989, 'test01', 19, 11, 0, 1020013, 1020013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:34');
INSERT INTO `userscoresnapshotledger` VALUES (2990, 'test01', 19, 11, 0, 1019913, 1019913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:34');
INSERT INTO `userscoresnapshotledger` VALUES (2991, 'test01', 19, 11, 0, 1019813, 1019813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:34');
INSERT INTO `userscoresnapshotledger` VALUES (2992, 'test01', 19, 11, 0, 1019713, 1019713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:34');
INSERT INTO `userscoresnapshotledger` VALUES (2993, 'test01', 19, 11, 0, 1019613, 1019613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:35');
INSERT INTO `userscoresnapshotledger` VALUES (2994, 'test01', 19, 11, 0, 1019513, 1019513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:35');
INSERT INTO `userscoresnapshotledger` VALUES (2995, 'test01', 19, 11, 0, 1019413, 1019413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:35');
INSERT INTO `userscoresnapshotledger` VALUES (2996, 'test01', 19, 11, 0, 1019313, 1019313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:35');
INSERT INTO `userscoresnapshotledger` VALUES (2997, 'test01', 19, 11, 0, 1019213, 1019213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:35');
INSERT INTO `userscoresnapshotledger` VALUES (2998, 'test01', 19, 11, 0, 1019113, 1019113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:36');
INSERT INTO `userscoresnapshotledger` VALUES (2999, 'test01', 19, 11, 0, 1019013, 1019013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:36');
INSERT INTO `userscoresnapshotledger` VALUES (3000, 'test01', 19, 11, 0, 1018913, 1018913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:36');
INSERT INTO `userscoresnapshotledger` VALUES (3001, 'test01', 19, 11, 0, 1018813, 1018813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:36');
INSERT INTO `userscoresnapshotledger` VALUES (3002, 'test01', 19, 11, 0, 1018713, 1018713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:36');
INSERT INTO `userscoresnapshotledger` VALUES (3003, 'test01', 19, 11, 0, 1018613, 1018613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:37');
INSERT INTO `userscoresnapshotledger` VALUES (3004, 'test01', 19, 11, 0, 1018513, 1018513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:37');
INSERT INTO `userscoresnapshotledger` VALUES (3005, 'test01', 19, 11, 0, 1018413, 1018413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:37');
INSERT INTO `userscoresnapshotledger` VALUES (3006, 'test01', 19, 11, 0, 1018313, 1018313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:37');
INSERT INTO `userscoresnapshotledger` VALUES (3007, 'test01', 19, 11, 0, 1018213, 1018213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:37');
INSERT INTO `userscoresnapshotledger` VALUES (3008, 'test01', 19, 11, 0, 1018113, 1018113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:38');
INSERT INTO `userscoresnapshotledger` VALUES (3009, 'test01', 19, 11, 0, 1018013, 1018013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:38');
INSERT INTO `userscoresnapshotledger` VALUES (3010, 'test01', 19, 11, 0, 1024013, 1024013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:38');
INSERT INTO `userscoresnapshotledger` VALUES (3011, 'test01', 19, 11, 0, 1023913, 1023913, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:38');
INSERT INTO `userscoresnapshotledger` VALUES (3012, 'test01', 19, 11, 0, 1023813, 1023813, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:38');
INSERT INTO `userscoresnapshotledger` VALUES (3013, 'test01', 19, 11, 0, 1023713, 1023713, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:38');
INSERT INTO `userscoresnapshotledger` VALUES (3014, 'test01', 19, 11, 0, 1023613, 1023613, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:39');
INSERT INTO `userscoresnapshotledger` VALUES (3015, 'test01', 19, 11, 0, 1023513, 1023513, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:39');
INSERT INTO `userscoresnapshotledger` VALUES (3016, 'test01', 19, 11, 0, 1023413, 1023413, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:39');
INSERT INTO `userscoresnapshotledger` VALUES (3017, 'test01', 19, 11, 0, 1023313, 1023313, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:39');
INSERT INTO `userscoresnapshotledger` VALUES (3018, 'test01', 19, 11, 0, 1023213, 1023213, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:39');
INSERT INTO `userscoresnapshotledger` VALUES (3019, 'test01', 19, 11, 0, 1023113, 1023113, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:40');
INSERT INTO `userscoresnapshotledger` VALUES (3020, 'test01', 19, 11, 0, 1023013, 1023013, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:40');
INSERT INTO `userscoresnapshotledger` VALUES (3021, 'test01', 19, 11, 1023013, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:40');
INSERT INTO `userscoresnapshotledger` VALUES (3022, 'test01', 19, 11, 1023013, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:49:41');
INSERT INTO `userscoresnapshotledger` VALUES (3023, 'test01', 19, 11, 1023013, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:50:05');
INSERT INTO `userscoresnapshotledger` VALUES (3024, 'test01', 53, 1, 1023013, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-07 18:52:25');
INSERT INTO `userscoresnapshotledger` VALUES (3025, 'test01', 53, 3, 1023013, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 10:26:31');
INSERT INTO `userscoresnapshotledger` VALUES (3026, 'test01', 54, 0, 1023013, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 10:26:31');
INSERT INTO `userscoresnapshotledger` VALUES (3027, 'test002', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 10:45:10');
INSERT INTO `userscoresnapshotledger` VALUES (3028, 'test002', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 11:24:58');
INSERT INTO `userscoresnapshotledger` VALUES (3029, 'test002', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 11:26:43');
INSERT INTO `userscoresnapshotledger` VALUES (3030, 'test002', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 11:27:28');
INSERT INTO `userscoresnapshotledger` VALUES (3031, 'test002', 29, 19, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:27:34');
INSERT INTO `userscoresnapshotledger` VALUES (3032, 'test002', 29, 19, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:27:40');
INSERT INTO `userscoresnapshotledger` VALUES (3033, 'test002', 29, 19, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:27:41');
INSERT INTO `userscoresnapshotledger` VALUES (3034, 'test002', 29, 19, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:27:44');
INSERT INTO `userscoresnapshotledger` VALUES (3035, 'test002', 29, 19, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:27:45');
INSERT INTO `userscoresnapshotledger` VALUES (3036, 'test002', 29, 19, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:27:48');
INSERT INTO `userscoresnapshotledger` VALUES (3037, 'test002', 29, 19, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:27:59');
INSERT INTO `userscoresnapshotledger` VALUES (3038, 'test002', 29, 19, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:28:06');
INSERT INTO `userscoresnapshotledger` VALUES (3039, 'test002', 29, 19, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:28:08');
INSERT INTO `userscoresnapshotledger` VALUES (3040, 'test002', 29, 19, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:28:13');
INSERT INTO `userscoresnapshotledger` VALUES (3041, 'test002', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 11:35:53');
INSERT INTO `userscoresnapshotledger` VALUES (3042, 'test002', 47, 20, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:36:01');
INSERT INTO `userscoresnapshotledger` VALUES (3043, 'test002', 47, 20, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:36:04');
INSERT INTO `userscoresnapshotledger` VALUES (3044, 'test002', 47, 20, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:36:11');
INSERT INTO `userscoresnapshotledger` VALUES (3045, 'test002', 47, 20, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:36:13');
INSERT INTO `userscoresnapshotledger` VALUES (3046, 'test002', 47, 20, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:36:18');
INSERT INTO `userscoresnapshotledger` VALUES (3047, 'test002', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 11:37:11');
INSERT INTO `userscoresnapshotledger` VALUES (3048, 'test01', 53, 11, 1023013, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:45:11');
INSERT INTO `userscoresnapshotledger` VALUES (3049, 'test01', 54, 0, 1023013, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 11:45:11');
INSERT INTO `userscoresnapshotledger` VALUES (3050, 'test01', 54, 0, 1023013, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 11:48:09');
INSERT INTO `userscoresnapshotledger` VALUES (3051, 'test01', 54, 0, 1023013, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 11:48:13');
INSERT INTO `userscoresnapshotledger` VALUES (3052, 'test01', 54, 0, 1023013, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 11:48:16');
INSERT INTO `userscoresnapshotledger` VALUES (3053, 'test01', 54, 0, 1023013, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 11:48:19');
INSERT INTO `userscoresnapshotledger` VALUES (3054, 'test01', 54, 0, 1023013, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 11:48:21');
INSERT INTO `userscoresnapshotledger` VALUES (3055, 'test01', 54, 0, 1023013, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 11:48:27');
INSERT INTO `userscoresnapshotledger` VALUES (3056, 'test01', 54, 0, 1023013, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 11:48:34');
INSERT INTO `userscoresnapshotledger` VALUES (3057, 'test01', 54, 0, 1023013, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 11:48:37');
INSERT INTO `userscoresnapshotledger` VALUES (3058, 'test01', 6, 34, 0, 1023013, 1023013, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:48:44');
INSERT INTO `userscoresnapshotledger` VALUES (3059, 'test01', 6, 34, 0, 1022913, 1022913, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:48:52');
INSERT INTO `userscoresnapshotledger` VALUES (3060, 'test01', 6, 34, 0, 1022813, 1022813, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:48:56');
INSERT INTO `userscoresnapshotledger` VALUES (3061, 'test01', 6, 34, 0, 1022713, 1022713, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:48:56');
INSERT INTO `userscoresnapshotledger` VALUES (3062, 'test01', 6, 34, 0, 1022613, 1022613, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:48:57');
INSERT INTO `userscoresnapshotledger` VALUES (3063, 'test01', 6, 34, 0, 1022513, 1022513, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:48:57');
INSERT INTO `userscoresnapshotledger` VALUES (3064, 'test01', 6, 34, 0, 1022413, 1022413, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:48:57');
INSERT INTO `userscoresnapshotledger` VALUES (3065, 'test01', 6, 34, 0, 1022313, 1022313, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:48:57');
INSERT INTO `userscoresnapshotledger` VALUES (3066, 'test01', 6, 34, 0, 1022213, 1022213, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:48:58');
INSERT INTO `userscoresnapshotledger` VALUES (3067, 'test01', 6, 34, 0, 1022113, 1022113, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:48:59');
INSERT INTO `userscoresnapshotledger` VALUES (3068, 'test01', 6, 34, 0, 1022013, 1022013, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:48:59');
INSERT INTO `userscoresnapshotledger` VALUES (3069, 'test01', 6, 34, 0, 1021913, 1021913, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:00');
INSERT INTO `userscoresnapshotledger` VALUES (3070, 'test01', 6, 34, 0, 1021813, 1021813, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:00');
INSERT INTO `userscoresnapshotledger` VALUES (3071, 'test01', 6, 34, 0, 1021713, 1021713, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:00');
INSERT INTO `userscoresnapshotledger` VALUES (3072, 'test01', 6, 34, 0, 1021613, 1021613, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:00');
INSERT INTO `userscoresnapshotledger` VALUES (3073, 'test01', 6, 34, 0, 1021513, 1021513, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:00');
INSERT INTO `userscoresnapshotledger` VALUES (3074, 'test01', 6, 34, 0, 1021413, 1021413, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:01');
INSERT INTO `userscoresnapshotledger` VALUES (3075, 'test01', 6, 34, 0, 1021313, 1021313, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:01');
INSERT INTO `userscoresnapshotledger` VALUES (3076, 'test01', 6, 34, 0, 1021213, 1021213, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:01');
INSERT INTO `userscoresnapshotledger` VALUES (3077, 'test01', 6, 34, 0, 1021113, 1021113, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:01');
INSERT INTO `userscoresnapshotledger` VALUES (3078, 'test01', 6, 34, 0, 1021013, 1021013, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:01');
INSERT INTO `userscoresnapshotledger` VALUES (3079, 'test01', 6, 34, 0, 1020913, 1020913, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:01');
INSERT INTO `userscoresnapshotledger` VALUES (3080, 'test01', 6, 34, 0, 1020813, 1020813, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:02');
INSERT INTO `userscoresnapshotledger` VALUES (3081, 'test01', 6, 34, 0, 1020713, 1020713, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:02');
INSERT INTO `userscoresnapshotledger` VALUES (3082, 'test01', 6, 34, 0, 1020613, 1020613, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:02');
INSERT INTO `userscoresnapshotledger` VALUES (3083, 'test01', 6, 34, 0, 1020513, 1020513, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:02');
INSERT INTO `userscoresnapshotledger` VALUES (3084, 'test01', 6, 34, 0, 1020413, 1020413, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:02');
INSERT INTO `userscoresnapshotledger` VALUES (3085, 'test01', 6, 34, 0, 1020313, 1020313, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:02');
INSERT INTO `userscoresnapshotledger` VALUES (3086, 'test01', 6, 34, 0, 1020213, 1020213, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:02');
INSERT INTO `userscoresnapshotledger` VALUES (3087, 'test01', 6, 34, 0, 1020113, 1020113, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:02');
INSERT INTO `userscoresnapshotledger` VALUES (3088, 'test01', 6, 34, 0, 1020013, 1020013, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:02');
INSERT INTO `userscoresnapshotledger` VALUES (3089, 'test01', 6, 34, 0, 1019913, 1019913, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:03');
INSERT INTO `userscoresnapshotledger` VALUES (3090, 'test01', 6, 34, 0, 1019813, 1019813, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:03');
INSERT INTO `userscoresnapshotledger` VALUES (3091, 'test01', 6, 34, 0, 1019713, 1019713, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:03');
INSERT INTO `userscoresnapshotledger` VALUES (3092, 'test01', 6, 34, 0, 1019613, 1019613, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:03');
INSERT INTO `userscoresnapshotledger` VALUES (3093, 'test01', 6, 34, 0, 1019513, 1019513, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:03');
INSERT INTO `userscoresnapshotledger` VALUES (3094, 'test01', 6, 34, 0, 1019413, 1019413, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:03');
INSERT INTO `userscoresnapshotledger` VALUES (3095, 'test01', 6, 34, 0, 1019313, 1019313, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:03');
INSERT INTO `userscoresnapshotledger` VALUES (3096, 'test01', 6, 34, 0, 1019213, 1019213, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:03');
INSERT INTO `userscoresnapshotledger` VALUES (3097, 'test01', 6, 34, 0, 1019113, 1019113, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:03');
INSERT INTO `userscoresnapshotledger` VALUES (3098, 'test01', 6, 34, 0, 1019013, 1019013, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:04');
INSERT INTO `userscoresnapshotledger` VALUES (3099, 'test01', 6, 34, 0, 1018913, 1018913, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:04');
INSERT INTO `userscoresnapshotledger` VALUES (3100, 'test01', 6, 34, 0, 1018813, 1018813, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:04');
INSERT INTO `userscoresnapshotledger` VALUES (3101, 'test01', 6, 34, 0, 1018713, 1018713, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:04');
INSERT INTO `userscoresnapshotledger` VALUES (3102, 'test01', 6, 34, 0, 1018613, 1018613, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:04');
INSERT INTO `userscoresnapshotledger` VALUES (3103, 'test01', 6, 34, 0, 1018513, 1018513, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:04');
INSERT INTO `userscoresnapshotledger` VALUES (3104, 'test01', 6, 34, 0, 1018413, 1018413, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:04');
INSERT INTO `userscoresnapshotledger` VALUES (3105, 'test01', 6, 34, 0, 1018313, 1018313, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:04');
INSERT INTO `userscoresnapshotledger` VALUES (3106, 'test01', 6, 34, 0, 1018213, 1018213, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:04');
INSERT INTO `userscoresnapshotledger` VALUES (3107, 'test01', 6, 34, 0, 1018113, 1018113, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:04');
INSERT INTO `userscoresnapshotledger` VALUES (3108, 'test01', 6, 34, 0, 1018013, 1018013, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:04');
INSERT INTO `userscoresnapshotledger` VALUES (3109, 'test01', 6, 34, 0, 1017913, 1017913, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:05');
INSERT INTO `userscoresnapshotledger` VALUES (3110, 'test01', 6, 34, 0, 1017813, 1017813, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:05');
INSERT INTO `userscoresnapshotledger` VALUES (3111, 'test01', 6, 34, 0, 1017713, 1017713, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:05');
INSERT INTO `userscoresnapshotledger` VALUES (3112, 'test01', 6, 34, 0, 1017613, 1017613, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:05');
INSERT INTO `userscoresnapshotledger` VALUES (3113, 'test01', 6, 34, 0, 1017513, 1017513, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:05');
INSERT INTO `userscoresnapshotledger` VALUES (3114, 'test01', 6, 34, 0, 1017413, 1017413, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:05');
INSERT INTO `userscoresnapshotledger` VALUES (3115, 'test01', 6, 34, 0, 1017313, 1017313, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:05');
INSERT INTO `userscoresnapshotledger` VALUES (3116, 'test01', 6, 34, 0, 1017213, 1017213, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:05');
INSERT INTO `userscoresnapshotledger` VALUES (3117, 'test01', 6, 34, 0, 1017113, 1017113, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:05');
INSERT INTO `userscoresnapshotledger` VALUES (3118, 'test01', 6, 34, 0, 1017013, 1017013, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:05');
INSERT INTO `userscoresnapshotledger` VALUES (3119, 'test01', 6, 34, 0, 1016913, 1016913, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:06');
INSERT INTO `userscoresnapshotledger` VALUES (3120, 'test01', 6, 34, 0, 1016813, 1016813, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:06');
INSERT INTO `userscoresnapshotledger` VALUES (3121, 'test01', 6, 34, 0, 1016713, 1016713, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:06');
INSERT INTO `userscoresnapshotledger` VALUES (3122, 'test01', 6, 34, 0, 1016613, 1016613, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:06');
INSERT INTO `userscoresnapshotledger` VALUES (3123, 'test01', 6, 34, 0, 1016513, 1016513, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:06');
INSERT INTO `userscoresnapshotledger` VALUES (3124, 'test01', 6, 34, 0, 1016413, 1016413, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:07');
INSERT INTO `userscoresnapshotledger` VALUES (3125, 'test01', 6, 34, 0, 1016313, 1016313, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:07');
INSERT INTO `userscoresnapshotledger` VALUES (3126, 'test01', 6, 34, 0, 1016213, 1016213, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:07');
INSERT INTO `userscoresnapshotledger` VALUES (3127, 'test01', 6, 34, 0, 1016113, 1016113, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:07');
INSERT INTO `userscoresnapshotledger` VALUES (3128, 'test01', 6, 34, 0, 1016013, 1016013, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:07');
INSERT INTO `userscoresnapshotledger` VALUES (3129, 'test01', 6, 34, 0, 1015913, 1015913, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:08');
INSERT INTO `userscoresnapshotledger` VALUES (3130, 'test01', 6, 34, 0, 1015813, 1015813, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:08');
INSERT INTO `userscoresnapshotledger` VALUES (3131, 'test01', 6, 34, 0, 1015713, 1015713, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:08');
INSERT INTO `userscoresnapshotledger` VALUES (3132, 'test01', 6, 34, 0, 1015613, 1015613, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:08');
INSERT INTO `userscoresnapshotledger` VALUES (3133, 'test01', 6, 34, 0, 1015513, 1015513, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:08');
INSERT INTO `userscoresnapshotledger` VALUES (3134, 'test01', 6, 34, 0, 1015413, 1015413, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:09');
INSERT INTO `userscoresnapshotledger` VALUES (3135, 'test01', 6, 34, 0, 1015313, 1015313, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:09');
INSERT INTO `userscoresnapshotledger` VALUES (3136, 'test01', 6, 34, 0, 1015213, 1015213, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:09');
INSERT INTO `userscoresnapshotledger` VALUES (3137, 'test01', 6, 34, 1015213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:09');
INSERT INTO `userscoresnapshotledger` VALUES (3138, 'test01', 6, 34, 1015213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:10');
INSERT INTO `userscoresnapshotledger` VALUES (3139, 'test01', 54, 0, 1015213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 11:49:17');
INSERT INTO `userscoresnapshotledger` VALUES (3140, 'test01', 6, 35, 0, 1015213, 1015213, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:28');
INSERT INTO `userscoresnapshotledger` VALUES (3141, 'test01', 6, 35, 0, 1015113, 1015113, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:29');
INSERT INTO `userscoresnapshotledger` VALUES (3142, 'test01', 6, 35, 0, 1015013, 1015013, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:30');
INSERT INTO `userscoresnapshotledger` VALUES (3143, 'test01', 6, 35, 0, 1014913, 1014913, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:31');
INSERT INTO `userscoresnapshotledger` VALUES (3144, 'test01', 6, 35, 0, 1014813, 1014813, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:31');
INSERT INTO `userscoresnapshotledger` VALUES (3145, 'test01', 6, 35, 0, 1014713, 1014713, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:31');
INSERT INTO `userscoresnapshotledger` VALUES (3146, 'test01', 6, 35, 0, 1014613, 1014613, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:32');
INSERT INTO `userscoresnapshotledger` VALUES (3147, 'test01', 6, 35, 0, 1014513, 1014513, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:34');
INSERT INTO `userscoresnapshotledger` VALUES (3148, 'test01', 6, 35, 0, 1014413, 1014413, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:34');
INSERT INTO `userscoresnapshotledger` VALUES (3149, 'test01', 6, 35, 0, 1014313, 1014313, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:34');
INSERT INTO `userscoresnapshotledger` VALUES (3150, 'test01', 6, 35, 0, 1014213, 1014213, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:35');
INSERT INTO `userscoresnapshotledger` VALUES (3151, 'test01', 6, 35, 0, 1014413, 1014413, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:35');
INSERT INTO `userscoresnapshotledger` VALUES (3152, 'test01', 6, 35, 0, 1014313, 1014313, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:35');
INSERT INTO `userscoresnapshotledger` VALUES (3153, 'test01', 6, 35, 0, 1014213, 1014213, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:35');
INSERT INTO `userscoresnapshotledger` VALUES (3154, 'test01', 6, 35, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:37');
INSERT INTO `userscoresnapshotledger` VALUES (3155, 'test01', 6, 35, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 11:49:38');
INSERT INTO `userscoresnapshotledger` VALUES (3156, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 11:49:50');
INSERT INTO `userscoresnapshotledger` VALUES (3157, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 11:49:58');
INSERT INTO `userscoresnapshotledger` VALUES (3158, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 11:51:22');
INSERT INTO `userscoresnapshotledger` VALUES (3159, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 11:53:02');
INSERT INTO `userscoresnapshotledger` VALUES (3160, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 11:53:07');
INSERT INTO `userscoresnapshotledger` VALUES (3161, 'test01', 53, 48, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 13:37:30');
INSERT INTO `userscoresnapshotledger` VALUES (3162, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 13:37:30');
INSERT INTO `userscoresnapshotledger` VALUES (3163, 'test002', 19, 47, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 13:51:24');
INSERT INTO `userscoresnapshotledger` VALUES (3164, 'test002', 19, 47, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 13:51:35');
INSERT INTO `userscoresnapshotledger` VALUES (3165, 'test002', 19, 47, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 13:51:35');
INSERT INTO `userscoresnapshotledger` VALUES (3166, 'test002', 19, 47, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 13:51:36');
INSERT INTO `userscoresnapshotledger` VALUES (3167, 'test002', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 13:51:38');
INSERT INTO `userscoresnapshotledger` VALUES (3168, 'test01', 53, 50, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 13:56:37');
INSERT INTO `userscoresnapshotledger` VALUES (3169, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 13:56:37');
INSERT INTO `userscoresnapshotledger` VALUES (3170, 'test002', 0, 49, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 13:58:15');
INSERT INTO `userscoresnapshotledger` VALUES (3171, 'test01', 53, 56, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 13:58:15');
INSERT INTO `userscoresnapshotledger` VALUES (3172, 'test01', 53, 2, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 13:59:09');
INSERT INTO `userscoresnapshotledger` VALUES (3173, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 13:59:09');
INSERT INTO `userscoresnapshotledger` VALUES (3174, 'test01', 0, 15, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 14:05:45');
INSERT INTO `userscoresnapshotledger` VALUES (3175, 'test002', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 14:10:28');
INSERT INTO `userscoresnapshotledger` VALUES (3176, 'test002', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 14:11:05');
INSERT INTO `userscoresnapshotledger` VALUES (3177, 'test002', 19, 3, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 14:21:16');
INSERT INTO `userscoresnapshotledger` VALUES (3178, 'test002', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:GAME_LOST', '2026-07-08 14:22:14');
INSERT INTO `userscoresnapshotledger` VALUES (3179, 'test002', 0, 3, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 14:22:14');
INSERT INTO `userscoresnapshotledger` VALUES (3180, 'test01', 0, 11, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 14:22:14');
INSERT INTO `userscoresnapshotledger` VALUES (3181, 'test002', 0, 6, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 14:29:19');
INSERT INTO `userscoresnapshotledger` VALUES (3182, 'test01', 53, 3, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 14:29:19');
INSERT INTO `userscoresnapshotledger` VALUES (3183, 'test01', 0, 5, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 14:36:06');
INSERT INTO `userscoresnapshotledger` VALUES (3184, 'test01', 0, 5, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 14:42:06');
INSERT INTO `userscoresnapshotledger` VALUES (3185, 'test01', 0, 6, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 14:51:47');
INSERT INTO `userscoresnapshotledger` VALUES (3186, 'test01', 0, 3, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 15:05:37');
INSERT INTO `userscoresnapshotledger` VALUES (3187, 'test002', 0, 18, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 16:25:23');
INSERT INTO `userscoresnapshotledger` VALUES (3188, 'test01', 0, 19, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 16:25:23');
INSERT INTO `userscoresnapshotledger` VALUES (3189, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 16:57:45');
INSERT INTO `userscoresnapshotledger` VALUES (3190, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 16:57:59');
INSERT INTO `userscoresnapshotledger` VALUES (3191, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 16:58:20');
INSERT INTO `userscoresnapshotledger` VALUES (3192, 'test01', 44, 23, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 16:58:47');
INSERT INTO `userscoresnapshotledger` VALUES (3193, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 16:58:58');
INSERT INTO `userscoresnapshotledger` VALUES (3194, 'test01', 0, 29, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 16:59:49');
INSERT INTO `userscoresnapshotledger` VALUES (3195, 'test002', 19, 2, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:17:54');
INSERT INTO `userscoresnapshotledger` VALUES (3196, 'test002', 19, 2, 0, 100000, 100000, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:35');
INSERT INTO `userscoresnapshotledger` VALUES (3197, 'test002', 19, 2, 0, 99995, 99995, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:36');
INSERT INTO `userscoresnapshotledger` VALUES (3198, 'test002', 19, 2, 0, 99990, 99990, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:36');
INSERT INTO `userscoresnapshotledger` VALUES (3199, 'test002', 19, 2, 0, 99985, 99985, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:37');
INSERT INTO `userscoresnapshotledger` VALUES (3200, 'test002', 19, 2, 0, 99980, 99980, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:37');
INSERT INTO `userscoresnapshotledger` VALUES (3201, 'test002', 19, 2, 0, 99975, 99975, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:37');
INSERT INTO `userscoresnapshotledger` VALUES (3202, 'test002', 19, 2, 0, 99970, 99970, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:37');
INSERT INTO `userscoresnapshotledger` VALUES (3203, 'test002', 19, 2, 0, 99965, 99965, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:37');
INSERT INTO `userscoresnapshotledger` VALUES (3204, 'test002', 19, 2, 0, 99960, 99960, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:38');
INSERT INTO `userscoresnapshotledger` VALUES (3205, 'test002', 19, 2, 0, 99955, 99955, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:38');
INSERT INTO `userscoresnapshotledger` VALUES (3206, 'test002', 19, 2, 0, 99950, 99950, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:38');
INSERT INTO `userscoresnapshotledger` VALUES (3207, 'test002', 19, 2, 0, 99945, 99945, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:38');
INSERT INTO `userscoresnapshotledger` VALUES (3208, 'test002', 19, 2, 0, 99940, 99940, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:39');
INSERT INTO `userscoresnapshotledger` VALUES (3209, 'test002', 19, 2, 0, 99935, 99935, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:39');
INSERT INTO `userscoresnapshotledger` VALUES (3210, 'test002', 19, 2, 0, 99930, 99930, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:39');
INSERT INTO `userscoresnapshotledger` VALUES (3211, 'test002', 19, 2, 0, 99925, 99925, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:39');
INSERT INTO `userscoresnapshotledger` VALUES (3212, 'test002', 19, 2, 0, 99920, 99920, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:39');
INSERT INTO `userscoresnapshotledger` VALUES (3213, 'test002', 19, 2, 0, 99915, 99915, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:40');
INSERT INTO `userscoresnapshotledger` VALUES (3214, 'test002', 19, 2, 0, 99910, 99910, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:40');
INSERT INTO `userscoresnapshotledger` VALUES (3215, 'test002', 19, 2, 0, 99905, 99905, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:40');
INSERT INTO `userscoresnapshotledger` VALUES (3216, 'test002', 19, 2, 0, 99900, 99900, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:40');
INSERT INTO `userscoresnapshotledger` VALUES (3217, 'test002', 19, 2, 0, 99895, 99895, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:41');
INSERT INTO `userscoresnapshotledger` VALUES (3218, 'test002', 19, 2, 0, 99890, 99890, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:41');
INSERT INTO `userscoresnapshotledger` VALUES (3219, 'test002', 19, 2, 0, 99940, 99940, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:41');
INSERT INTO `userscoresnapshotledger` VALUES (3220, 'test002', 19, 2, 0, 99935, 99935, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:41');
INSERT INTO `userscoresnapshotledger` VALUES (3221, 'test002', 19, 2, 0, 99930, 99930, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:42');
INSERT INTO `userscoresnapshotledger` VALUES (3222, 'test002', 19, 2, 0, 99925, 99925, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:42');
INSERT INTO `userscoresnapshotledger` VALUES (3223, 'test002', 19, 2, 0, 99920, 99920, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:42');
INSERT INTO `userscoresnapshotledger` VALUES (3224, 'test002', 19, 2, 0, 99915, 99915, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:42');
INSERT INTO `userscoresnapshotledger` VALUES (3225, 'test002', 19, 2, 0, 99910, 99910, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:42');
INSERT INTO `userscoresnapshotledger` VALUES (3226, 'test002', 19, 2, 0, 99905, 99905, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:43');
INSERT INTO `userscoresnapshotledger` VALUES (3227, 'test002', 19, 2, 0, 99900, 99900, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:43');
INSERT INTO `userscoresnapshotledger` VALUES (3228, 'test002', 19, 2, 0, 99895, 99895, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:43');
INSERT INTO `userscoresnapshotledger` VALUES (3229, 'test002', 19, 2, 0, 99890, 99890, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:43');
INSERT INTO `userscoresnapshotledger` VALUES (3230, 'test002', 19, 2, 0, 99885, 99885, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:44');
INSERT INTO `userscoresnapshotledger` VALUES (3231, 'test002', 19, 2, 0, 99880, 99880, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:44');
INSERT INTO `userscoresnapshotledger` VALUES (3232, 'test002', 19, 2, 0, 99875, 99875, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:44');
INSERT INTO `userscoresnapshotledger` VALUES (3233, 'test002', 19, 2, 0, 99870, 99870, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:44');
INSERT INTO `userscoresnapshotledger` VALUES (3234, 'test002', 19, 2, 0, 99865, 99865, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:44');
INSERT INTO `userscoresnapshotledger` VALUES (3235, 'test002', 19, 2, 0, 100735, 100735, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:45');
INSERT INTO `userscoresnapshotledger` VALUES (3236, 'test002', 19, 2, 0, 100730, 100730, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:45');
INSERT INTO `userscoresnapshotledger` VALUES (3237, 'test002', 19, 2, 0, 100725, 100725, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:45');
INSERT INTO `userscoresnapshotledger` VALUES (3238, 'test002', 19, 2, 0, 100720, 100720, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:45');
INSERT INTO `userscoresnapshotledger` VALUES (3239, 'test002', 19, 2, 0, 100715, 100715, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:45');
INSERT INTO `userscoresnapshotledger` VALUES (3240, 'test002', 19, 2, 0, 100710, 100710, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:46');
INSERT INTO `userscoresnapshotledger` VALUES (3241, 'test002', 19, 2, 0, 100705, 100705, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:46');
INSERT INTO `userscoresnapshotledger` VALUES (3242, 'test002', 19, 2, 0, 100700, 100700, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:46');
INSERT INTO `userscoresnapshotledger` VALUES (3243, 'test002', 19, 2, 0, 100695, 100695, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:46');
INSERT INTO `userscoresnapshotledger` VALUES (3244, 'test002', 19, 2, 0, 100690, 100690, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:46');
INSERT INTO `userscoresnapshotledger` VALUES (3245, 'test002', 19, 2, 0, 100685, 100685, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:47');
INSERT INTO `userscoresnapshotledger` VALUES (3246, 'test002', 19, 2, 0, 100680, 100680, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:47');
INSERT INTO `userscoresnapshotledger` VALUES (3247, 'test002', 19, 2, 0, 100675, 100675, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:47');
INSERT INTO `userscoresnapshotledger` VALUES (3248, 'test002', 19, 2, 0, 100670, 100670, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:47');
INSERT INTO `userscoresnapshotledger` VALUES (3249, 'test002', 19, 2, 0, 100665, 100665, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:48');
INSERT INTO `userscoresnapshotledger` VALUES (3250, 'test002', 19, 2, 0, 100715, 100715, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:48');
INSERT INTO `userscoresnapshotledger` VALUES (3251, 'test002', 19, 2, 0, 100710, 100710, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:48');
INSERT INTO `userscoresnapshotledger` VALUES (3252, 'test002', 19, 2, 0, 100705, 100705, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:48');
INSERT INTO `userscoresnapshotledger` VALUES (3253, 'test002', 19, 2, 0, 100700, 100700, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:48');
INSERT INTO `userscoresnapshotledger` VALUES (3254, 'test002', 19, 2, 0, 100695, 100695, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:49');
INSERT INTO `userscoresnapshotledger` VALUES (3255, 'test002', 19, 2, 0, 100690, 100690, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:49');
INSERT INTO `userscoresnapshotledger` VALUES (3256, 'test002', 19, 2, 0, 100685, 100685, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:49');
INSERT INTO `userscoresnapshotledger` VALUES (3257, 'test002', 19, 2, 0, 100680, 100680, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:49');
INSERT INTO `userscoresnapshotledger` VALUES (3258, 'test002', 19, 2, 0, 100675, 100675, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:49');
INSERT INTO `userscoresnapshotledger` VALUES (3259, 'test002', 19, 2, 0, 100670, 100670, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:50');
INSERT INTO `userscoresnapshotledger` VALUES (3260, 'test002', 19, 2, 0, 100665, 100665, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:50');
INSERT INTO `userscoresnapshotledger` VALUES (3261, 'test002', 19, 2, 0, 100660, 100660, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:50');
INSERT INTO `userscoresnapshotledger` VALUES (3262, 'test002', 19, 2, 0, 100655, 100655, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:50');
INSERT INTO `userscoresnapshotledger` VALUES (3263, 'test002', 19, 2, 0, 100650, 100650, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:51');
INSERT INTO `userscoresnapshotledger` VALUES (3264, 'test002', 19, 2, 0, 100645, 100645, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:51');
INSERT INTO `userscoresnapshotledger` VALUES (3265, 'test002', 19, 2, 0, 100640, 100640, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:51');
INSERT INTO `userscoresnapshotledger` VALUES (3266, 'test002', 19, 2, 0, 100635, 100635, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:51');
INSERT INTO `userscoresnapshotledger` VALUES (3267, 'test002', 19, 2, 0, 100630, 100630, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:51');
INSERT INTO `userscoresnapshotledger` VALUES (3268, 'test002', 19, 2, 0, 100625, 100625, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:52');
INSERT INTO `userscoresnapshotledger` VALUES (3269, 'test002', 19, 2, 0, 100620, 100620, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:52');
INSERT INTO `userscoresnapshotledger` VALUES (3270, 'test002', 19, 2, 0, 100615, 100615, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:52');
INSERT INTO `userscoresnapshotledger` VALUES (3271, 'test002', 19, 2, 0, 100610, 100610, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:52');
INSERT INTO `userscoresnapshotledger` VALUES (3272, 'test002', 19, 2, 0, 100605, 100605, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:53');
INSERT INTO `userscoresnapshotledger` VALUES (3273, 'test002', 19, 2, 0, 100600, 100600, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:53');
INSERT INTO `userscoresnapshotledger` VALUES (3274, 'test002', 19, 2, 0, 100595, 100595, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:53');
INSERT INTO `userscoresnapshotledger` VALUES (3275, 'test002', 19, 2, 0, 100590, 100590, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:53');
INSERT INTO `userscoresnapshotledger` VALUES (3276, 'test002', 19, 2, 0, 100585, 100585, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:53');
INSERT INTO `userscoresnapshotledger` VALUES (3277, 'test002', 19, 2, 0, 100580, 100580, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:54');
INSERT INTO `userscoresnapshotledger` VALUES (3278, 'test002', 19, 2, 0, 100730, 100730, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:54');
INSERT INTO `userscoresnapshotledger` VALUES (3279, 'test002', 19, 2, 0, 100725, 100725, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:54');
INSERT INTO `userscoresnapshotledger` VALUES (3280, 'test002', 19, 2, 0, 100720, 100720, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:54');
INSERT INTO `userscoresnapshotledger` VALUES (3281, 'test002', 19, 2, 0, 100715, 100715, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:54');
INSERT INTO `userscoresnapshotledger` VALUES (3282, 'test002', 19, 2, 0, 100710, 100710, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:55');
INSERT INTO `userscoresnapshotledger` VALUES (3283, 'test002', 19, 2, 0, 100705, 100705, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:55');
INSERT INTO `userscoresnapshotledger` VALUES (3284, 'test002', 19, 2, 0, 100700, 100700, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:55');
INSERT INTO `userscoresnapshotledger` VALUES (3285, 'test002', 19, 2, 0, 100695, 100695, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:55');
INSERT INTO `userscoresnapshotledger` VALUES (3286, 'test002', 19, 2, 0, 100690, 100690, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:55');
INSERT INTO `userscoresnapshotledger` VALUES (3287, 'test002', 19, 2, 0, 100685, 100685, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:56');
INSERT INTO `userscoresnapshotledger` VALUES (3288, 'test002', 19, 2, 0, 100680, 100680, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:56');
INSERT INTO `userscoresnapshotledger` VALUES (3289, 'test002', 19, 2, 0, 100675, 100675, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:56');
INSERT INTO `userscoresnapshotledger` VALUES (3290, 'test002', 19, 2, 0, 100670, 100670, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:56');
INSERT INTO `userscoresnapshotledger` VALUES (3291, 'test002', 19, 2, 0, 100665, 100665, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:57');
INSERT INTO `userscoresnapshotledger` VALUES (3292, 'test002', 19, 2, 0, 100660, 100660, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:57');
INSERT INTO `userscoresnapshotledger` VALUES (3293, 'test002', 19, 2, 0, 100655, 100655, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:57');
INSERT INTO `userscoresnapshotledger` VALUES (3294, 'test002', 19, 2, 0, 100650, 100650, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:57');
INSERT INTO `userscoresnapshotledger` VALUES (3295, 'test002', 19, 2, 0, 100645, 100645, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:58');
INSERT INTO `userscoresnapshotledger` VALUES (3296, 'test002', 19, 2, 0, 100640, 100640, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:58');
INSERT INTO `userscoresnapshotledger` VALUES (3297, 'test002', 19, 2, 0, 100635, 100635, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:58');
INSERT INTO `userscoresnapshotledger` VALUES (3298, 'test002', 19, 2, 0, 100630, 100630, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:58');
INSERT INTO `userscoresnapshotledger` VALUES (3299, 'test002', 19, 2, 0, 100625, 100625, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:58');
INSERT INTO `userscoresnapshotledger` VALUES (3300, 'test002', 19, 2, 0, 100620, 100620, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:59');
INSERT INTO `userscoresnapshotledger` VALUES (3301, 'test002', 19, 2, 0, 100615, 100615, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:59');
INSERT INTO `userscoresnapshotledger` VALUES (3302, 'test002', 19, 2, 0, 100610, 100610, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:59');
INSERT INTO `userscoresnapshotledger` VALUES (3303, 'test002', 19, 2, 0, 100605, 100605, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:18:59');
INSERT INTO `userscoresnapshotledger` VALUES (3304, 'test002', 19, 2, 0, 100600, 100600, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:00');
INSERT INTO `userscoresnapshotledger` VALUES (3305, 'test002', 19, 2, 0, 100595, 100595, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:00');
INSERT INTO `userscoresnapshotledger` VALUES (3306, 'test002', 19, 2, 0, 100590, 100590, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:00');
INSERT INTO `userscoresnapshotledger` VALUES (3307, 'test002', 19, 2, 0, 100585, 100585, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:00');
INSERT INTO `userscoresnapshotledger` VALUES (3308, 'test002', 19, 2, 0, 100580, 100580, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:00');
INSERT INTO `userscoresnapshotledger` VALUES (3309, 'test002', 19, 2, 0, 100575, 100575, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:01');
INSERT INTO `userscoresnapshotledger` VALUES (3310, 'test002', 19, 2, 0, 100570, 100570, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:01');
INSERT INTO `userscoresnapshotledger` VALUES (3311, 'test002', 19, 2, 0, 100565, 100565, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:01');
INSERT INTO `userscoresnapshotledger` VALUES (3312, 'test002', 19, 2, 0, 100560, 100560, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:01');
INSERT INTO `userscoresnapshotledger` VALUES (3313, 'test002', 19, 2, 0, 100555, 100555, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:02');
INSERT INTO `userscoresnapshotledger` VALUES (3314, 'test002', 19, 2, 0, 100550, 100550, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:02');
INSERT INTO `userscoresnapshotledger` VALUES (3315, 'test002', 19, 2, 0, 100545, 100545, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:02');
INSERT INTO `userscoresnapshotledger` VALUES (3316, 'test002', 19, 2, 0, 100540, 100540, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:02');
INSERT INTO `userscoresnapshotledger` VALUES (3317, 'test002', 19, 2, 0, 100535, 100535, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:02');
INSERT INTO `userscoresnapshotledger` VALUES (3318, 'test002', 19, 2, 0, 100530, 100530, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:03');
INSERT INTO `userscoresnapshotledger` VALUES (3319, 'test002', 19, 2, 0, 100525, 100525, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:03');
INSERT INTO `userscoresnapshotledger` VALUES (3320, 'test002', 19, 2, 0, 100520, 100520, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:03');
INSERT INTO `userscoresnapshotledger` VALUES (3321, 'test002', 19, 2, 0, 100515, 100515, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:03');
INSERT INTO `userscoresnapshotledger` VALUES (3322, 'test002', 19, 2, 0, 100510, 100510, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:04');
INSERT INTO `userscoresnapshotledger` VALUES (3323, 'test002', 19, 2, 0, 100505, 100505, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:04');
INSERT INTO `userscoresnapshotledger` VALUES (3324, 'test002', 19, 2, 0, 100500, 100500, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:04');
INSERT INTO `userscoresnapshotledger` VALUES (3325, 'test002', 19, 2, 0, 100495, 100495, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:04');
INSERT INTO `userscoresnapshotledger` VALUES (3326, 'test002', 19, 2, 0, 100490, 100490, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:04');
INSERT INTO `userscoresnapshotledger` VALUES (3327, 'test002', 19, 2, 0, 100485, 100485, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:05');
INSERT INTO `userscoresnapshotledger` VALUES (3328, 'test002', 19, 2, 0, 100480, 100480, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:05');
INSERT INTO `userscoresnapshotledger` VALUES (3329, 'test002', 19, 2, 0, 100475, 100475, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:05');
INSERT INTO `userscoresnapshotledger` VALUES (3330, 'test002', 19, 2, 0, 100470, 100470, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:05');
INSERT INTO `userscoresnapshotledger` VALUES (3331, 'test002', 19, 2, 0, 100465, 100465, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:06');
INSERT INTO `userscoresnapshotledger` VALUES (3332, 'test002', 19, 2, 0, 100460, 100460, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:06');
INSERT INTO `userscoresnapshotledger` VALUES (3333, 'test002', 19, 2, 0, 100455, 100455, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:06');
INSERT INTO `userscoresnapshotledger` VALUES (3334, 'test002', 19, 2, 0, 100450, 100450, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:06');
INSERT INTO `userscoresnapshotledger` VALUES (3335, 'test002', 19, 2, 0, 100445, 100445, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:07');
INSERT INTO `userscoresnapshotledger` VALUES (3336, 'test002', 19, 2, 0, 100440, 100440, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:07');
INSERT INTO `userscoresnapshotledger` VALUES (3337, 'test002', 19, 2, 0, 100435, 100435, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:07');
INSERT INTO `userscoresnapshotledger` VALUES (3338, 'test002', 19, 2, 0, 100430, 100430, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:07');
INSERT INTO `userscoresnapshotledger` VALUES (3339, 'test002', 19, 2, 0, 100425, 100425, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:07');
INSERT INTO `userscoresnapshotledger` VALUES (3340, 'test002', 19, 2, 0, 100420, 100420, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:08');
INSERT INTO `userscoresnapshotledger` VALUES (3341, 'test002', 19, 2, 0, 100415, 100415, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:08');
INSERT INTO `userscoresnapshotledger` VALUES (3342, 'test002', 19, 2, 0, 100410, 100410, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:08');
INSERT INTO `userscoresnapshotledger` VALUES (3343, 'test002', 19, 2, 0, 100405, 100405, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:08');
INSERT INTO `userscoresnapshotledger` VALUES (3344, 'test002', 19, 2, 0, 100400, 100400, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:09');
INSERT INTO `userscoresnapshotledger` VALUES (3345, 'test002', 19, 2, 0, 100395, 100395, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:09');
INSERT INTO `userscoresnapshotledger` VALUES (3346, 'test002', 19, 2, 0, 100390, 100390, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:09');
INSERT INTO `userscoresnapshotledger` VALUES (3347, 'test002', 19, 2, 0, 100385, 100385, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:09');
INSERT INTO `userscoresnapshotledger` VALUES (3348, 'test002', 19, 2, 0, 100380, 100380, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:09');
INSERT INTO `userscoresnapshotledger` VALUES (3349, 'test002', 19, 2, 0, 100375, 100375, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:10');
INSERT INTO `userscoresnapshotledger` VALUES (3350, 'test002', 19, 2, 0, 100370, 100370, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:10');
INSERT INTO `userscoresnapshotledger` VALUES (3351, 'test002', 19, 2, 0, 100365, 100365, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:10');
INSERT INTO `userscoresnapshotledger` VALUES (3352, 'test002', 19, 2, 0, 100360, 100360, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:10');
INSERT INTO `userscoresnapshotledger` VALUES (3353, 'test002', 19, 2, 0, 100355, 100355, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:11');
INSERT INTO `userscoresnapshotledger` VALUES (3354, 'test002', 19, 2, 0, 100350, 100350, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:11');
INSERT INTO `userscoresnapshotledger` VALUES (3355, 'test002', 19, 2, 0, 100345, 100345, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:11');
INSERT INTO `userscoresnapshotledger` VALUES (3356, 'test002', 19, 2, 0, 100340, 100340, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:11');
INSERT INTO `userscoresnapshotledger` VALUES (3357, 'test002', 19, 2, 0, 100335, 100335, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:11');
INSERT INTO `userscoresnapshotledger` VALUES (3358, 'test002', 19, 2, 0, 100330, 100330, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:12');
INSERT INTO `userscoresnapshotledger` VALUES (3359, 'test002', 19, 2, 0, 100325, 100325, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:12');
INSERT INTO `userscoresnapshotledger` VALUES (3360, 'test002', 19, 2, 0, 100320, 100320, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:12');
INSERT INTO `userscoresnapshotledger` VALUES (3361, 'test002', 19, 2, 0, 100315, 100315, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:12');
INSERT INTO `userscoresnapshotledger` VALUES (3362, 'test002', 19, 2, 0, 100310, 100310, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:13');
INSERT INTO `userscoresnapshotledger` VALUES (3363, 'test002', 19, 2, 0, 100305, 100305, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:13');
INSERT INTO `userscoresnapshotledger` VALUES (3364, 'test002', 19, 2, 0, 100300, 100300, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:13');
INSERT INTO `userscoresnapshotledger` VALUES (3365, 'test002', 19, 2, 0, 100295, 100295, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:13');
INSERT INTO `userscoresnapshotledger` VALUES (3366, 'test002', 19, 2, 0, 100290, 100290, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:14');
INSERT INTO `userscoresnapshotledger` VALUES (3367, 'test002', 19, 2, 0, 100380, 100380, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:14');
INSERT INTO `userscoresnapshotledger` VALUES (3368, 'test002', 19, 2, 0, 100375, 100375, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:14');
INSERT INTO `userscoresnapshotledger` VALUES (3369, 'test002', 19, 2, 0, 100370, 100370, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:14');
INSERT INTO `userscoresnapshotledger` VALUES (3370, 'test002', 19, 2, 0, 100365, 100365, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:14');
INSERT INTO `userscoresnapshotledger` VALUES (3371, 'test002', 19, 2, 0, 100360, 100360, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:14');
INSERT INTO `userscoresnapshotledger` VALUES (3372, 'test002', 19, 2, 0, 100355, 100355, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:15');
INSERT INTO `userscoresnapshotledger` VALUES (3373, 'test002', 19, 2, 0, 100350, 100350, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:15');
INSERT INTO `userscoresnapshotledger` VALUES (3374, 'test002', 19, 2, 0, 100345, 100345, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:15');
INSERT INTO `userscoresnapshotledger` VALUES (3375, 'test002', 19, 2, 0, 100340, 100340, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:15');
INSERT INTO `userscoresnapshotledger` VALUES (3376, 'test002', 19, 2, 0, 100335, 100335, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:16');
INSERT INTO `userscoresnapshotledger` VALUES (3377, 'test002', 19, 2, 0, 100330, 100330, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:16');
INSERT INTO `userscoresnapshotledger` VALUES (3378, 'test002', 19, 2, 0, 100325, 100325, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:16');
INSERT INTO `userscoresnapshotledger` VALUES (3379, 'test002', 19, 2, 0, 100320, 100320, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:16');
INSERT INTO `userscoresnapshotledger` VALUES (3380, 'test002', 19, 2, 0, 100315, 100315, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:16');
INSERT INTO `userscoresnapshotledger` VALUES (3381, 'test002', 19, 2, 0, 100310, 100310, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:17');
INSERT INTO `userscoresnapshotledger` VALUES (3382, 'test002', 19, 2, 0, 100305, 100305, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:17');
INSERT INTO `userscoresnapshotledger` VALUES (3383, 'test002', 19, 2, 0, 100300, 100300, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:17');
INSERT INTO `userscoresnapshotledger` VALUES (3384, 'test002', 19, 2, 0, 100295, 100295, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:17');
INSERT INTO `userscoresnapshotledger` VALUES (3385, 'test002', 19, 2, 0, 100290, 100290, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:18');
INSERT INTO `userscoresnapshotledger` VALUES (3386, 'test002', 19, 2, 0, 100190, 100190, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:21');
INSERT INTO `userscoresnapshotledger` VALUES (3387, 'test002', 19, 2, 0, 100090, 100090, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:21');
INSERT INTO `userscoresnapshotledger` VALUES (3388, 'test002', 19, 2, 0, 99990, 99990, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:21');
INSERT INTO `userscoresnapshotledger` VALUES (3389, 'test002', 19, 2, 0, 99890, 99890, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:21');
INSERT INTO `userscoresnapshotledger` VALUES (3390, 'test002', 19, 2, 0, 99790, 99790, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:22');
INSERT INTO `userscoresnapshotledger` VALUES (3391, 'test002', 19, 2, 0, 99690, 99690, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:22');
INSERT INTO `userscoresnapshotledger` VALUES (3392, 'test002', 19, 2, 0, 99590, 99590, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:22');
INSERT INTO `userscoresnapshotledger` VALUES (3393, 'test002', 19, 2, 0, 99490, 99490, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:22');
INSERT INTO `userscoresnapshotledger` VALUES (3394, 'test002', 19, 2, 0, 99390, 99390, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:23');
INSERT INTO `userscoresnapshotledger` VALUES (3395, 'test002', 19, 2, 0, 99290, 99290, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:23');
INSERT INTO `userscoresnapshotledger` VALUES (3396, 'test002', 19, 2, 0, 99190, 99190, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:23');
INSERT INTO `userscoresnapshotledger` VALUES (3397, 'test002', 19, 2, 0, 99090, 99090, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:23');
INSERT INTO `userscoresnapshotledger` VALUES (3398, 'test002', 19, 2, 0, 98990, 98990, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:24');
INSERT INTO `userscoresnapshotledger` VALUES (3399, 'test002', 19, 2, 0, 98890, 98890, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:24');
INSERT INTO `userscoresnapshotledger` VALUES (3400, 'test002', 19, 2, 0, 98790, 98790, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:24');
INSERT INTO `userscoresnapshotledger` VALUES (3401, 'test002', 19, 2, 0, 98690, 98690, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:24');
INSERT INTO `userscoresnapshotledger` VALUES (3402, 'test002', 19, 2, 0, 98590, 98590, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:24');
INSERT INTO `userscoresnapshotledger` VALUES (3403, 'test002', 19, 2, 0, 98490, 98490, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:25');
INSERT INTO `userscoresnapshotledger` VALUES (3404, 'test002', 19, 2, 0, 98390, 98390, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:25');
INSERT INTO `userscoresnapshotledger` VALUES (3405, 'test002', 19, 2, 0, 98290, 98290, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:25');
INSERT INTO `userscoresnapshotledger` VALUES (3406, 'test002', 19, 2, 0, 98190, 98190, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:25');
INSERT INTO `userscoresnapshotledger` VALUES (3407, 'test002', 19, 2, 0, 98090, 98090, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:25');
INSERT INTO `userscoresnapshotledger` VALUES (3408, 'test002', 19, 2, 0, 97990, 97990, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:26');
INSERT INTO `userscoresnapshotledger` VALUES (3409, 'test002', 19, 2, 0, 97890, 97890, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:26');
INSERT INTO `userscoresnapshotledger` VALUES (3410, 'test002', 19, 2, 0, 97790, 97790, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:26');
INSERT INTO `userscoresnapshotledger` VALUES (3411, 'test002', 19, 2, 0, 97690, 97690, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:26');
INSERT INTO `userscoresnapshotledger` VALUES (3412, 'test002', 19, 2, 0, 97590, 97590, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:27');
INSERT INTO `userscoresnapshotledger` VALUES (3413, 'test002', 19, 2, 0, 97490, 97490, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:27');
INSERT INTO `userscoresnapshotledger` VALUES (3414, 'test002', 19, 2, 0, 97390, 97390, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:27');
INSERT INTO `userscoresnapshotledger` VALUES (3415, 'test002', 19, 2, 0, 97290, 97290, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:27');
INSERT INTO `userscoresnapshotledger` VALUES (3416, 'test002', 19, 2, 0, 97190, 97190, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:28');
INSERT INTO `userscoresnapshotledger` VALUES (3417, 'test002', 19, 2, 0, 97090, 97090, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:28');
INSERT INTO `userscoresnapshotledger` VALUES (3418, 'test002', 19, 2, 0, 96990, 96990, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:28');
INSERT INTO `userscoresnapshotledger` VALUES (3419, 'test002', 19, 2, 0, 96890, 96890, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:28');
INSERT INTO `userscoresnapshotledger` VALUES (3420, 'test002', 19, 2, 0, 96790, 96790, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:28');
INSERT INTO `userscoresnapshotledger` VALUES (3421, 'test002', 19, 2, 0, 96690, 96690, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:29');
INSERT INTO `userscoresnapshotledger` VALUES (3422, 'test002', 19, 2, 0, 96590, 96590, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:29');
INSERT INTO `userscoresnapshotledger` VALUES (3423, 'test002', 19, 2, 0, 96490, 96490, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:29');
INSERT INTO `userscoresnapshotledger` VALUES (3424, 'test002', 19, 2, 0, 96390, 96390, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:29');
INSERT INTO `userscoresnapshotledger` VALUES (3425, 'test002', 19, 2, 0, 96290, 96290, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:30');
INSERT INTO `userscoresnapshotledger` VALUES (3426, 'test002', 19, 2, 0, 96190, 96190, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:30');
INSERT INTO `userscoresnapshotledger` VALUES (3427, 'test002', 19, 2, 0, 96090, 96090, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:30');
INSERT INTO `userscoresnapshotledger` VALUES (3428, 'test002', 19, 2, 0, 95990, 95990, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:30');
INSERT INTO `userscoresnapshotledger` VALUES (3429, 'test002', 19, 2, 0, 95890, 95890, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:30');
INSERT INTO `userscoresnapshotledger` VALUES (3430, 'test002', 19, 2, 0, 95790, 95790, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:31');
INSERT INTO `userscoresnapshotledger` VALUES (3431, 'test002', 19, 2, 0, 95690, 95690, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:31');
INSERT INTO `userscoresnapshotledger` VALUES (3432, 'test002', 19, 2, 0, 95590, 95590, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:31');
INSERT INTO `userscoresnapshotledger` VALUES (3433, 'test002', 19, 2, 0, 95490, 95490, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:31');
INSERT INTO `userscoresnapshotledger` VALUES (3434, 'test002', 19, 2, 0, 95390, 95390, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:32');
INSERT INTO `userscoresnapshotledger` VALUES (3435, 'test002', 19, 2, 0, 95290, 95290, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:32');
INSERT INTO `userscoresnapshotledger` VALUES (3436, 'test002', 19, 2, 0, 95190, 95190, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:32');
INSERT INTO `userscoresnapshotledger` VALUES (3437, 'test002', 19, 2, 0, 95090, 95090, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:32');
INSERT INTO `userscoresnapshotledger` VALUES (3438, 'test002', 19, 2, 0, 94990, 94990, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:32');
INSERT INTO `userscoresnapshotledger` VALUES (3439, 'test002', 19, 2, 0, 94890, 94890, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:33');
INSERT INTO `userscoresnapshotledger` VALUES (3440, 'test002', 19, 2, 0, 94790, 94790, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:33');
INSERT INTO `userscoresnapshotledger` VALUES (3441, 'test002', 19, 2, 0, 94690, 94690, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:33');
INSERT INTO `userscoresnapshotledger` VALUES (3442, 'test002', 19, 2, 0, 94590, 94590, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:33');
INSERT INTO `userscoresnapshotledger` VALUES (3443, 'test002', 19, 2, 0, 94490, 94490, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:34');
INSERT INTO `userscoresnapshotledger` VALUES (3444, 'test002', 19, 2, 0, 94390, 94390, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:34');
INSERT INTO `userscoresnapshotledger` VALUES (3445, 'test002', 19, 2, 0, 94290, 94290, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:34');
INSERT INTO `userscoresnapshotledger` VALUES (3446, 'test002', 19, 2, 0, 94190, 94190, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:34');
INSERT INTO `userscoresnapshotledger` VALUES (3447, 'test002', 19, 2, 0, 94090, 94090, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:35');
INSERT INTO `userscoresnapshotledger` VALUES (3448, 'test002', 19, 2, 0, 94390, 94390, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:35');
INSERT INTO `userscoresnapshotledger` VALUES (3449, 'test002', 19, 2, 0, 94290, 94290, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:35');
INSERT INTO `userscoresnapshotledger` VALUES (3450, 'test002', 19, 2, 0, 94190, 94190, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:35');
INSERT INTO `userscoresnapshotledger` VALUES (3451, 'test002', 19, 2, 0, 94090, 94090, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:35');
INSERT INTO `userscoresnapshotledger` VALUES (3452, 'test002', 19, 2, 0, 93990, 93990, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:35');
INSERT INTO `userscoresnapshotledger` VALUES (3453, 'test002', 19, 2, 0, 93890, 93890, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:36');
INSERT INTO `userscoresnapshotledger` VALUES (3454, 'test002', 19, 2, 0, 93790, 93790, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:36');
INSERT INTO `userscoresnapshotledger` VALUES (3455, 'test002', 19, 2, 0, 93690, 93690, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:36');
INSERT INTO `userscoresnapshotledger` VALUES (3456, 'test002', 19, 2, 0, 93590, 93590, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:36');
INSERT INTO `userscoresnapshotledger` VALUES (3457, 'test002', 19, 2, 0, 93490, 93490, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:37');
INSERT INTO `userscoresnapshotledger` VALUES (3458, 'test002', 19, 2, 0, 93390, 93390, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:37');
INSERT INTO `userscoresnapshotledger` VALUES (3459, 'test002', 19, 2, 0, 93290, 93290, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:37');
INSERT INTO `userscoresnapshotledger` VALUES (3460, 'test002', 19, 2, 0, 93190, 93190, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:38');
INSERT INTO `userscoresnapshotledger` VALUES (3461, 'test002', 19, 2, 0, 93090, 93090, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:38');
INSERT INTO `userscoresnapshotledger` VALUES (3462, 'test002', 19, 2, 0, 93290, 93290, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:39');
INSERT INTO `userscoresnapshotledger` VALUES (3463, 'test002', 19, 2, 0, 93190, 93190, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:39');
INSERT INTO `userscoresnapshotledger` VALUES (3464, 'test002', 19, 2, 0, 93090, 93090, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:39');
INSERT INTO `userscoresnapshotledger` VALUES (3465, 'test002', 19, 2, 0, 92990, 92990, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:39');
INSERT INTO `userscoresnapshotledger` VALUES (3466, 'test002', 19, 2, 0, 92890, 92890, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:39');
INSERT INTO `userscoresnapshotledger` VALUES (3467, 'test002', 19, 2, 0, 92790, 92790, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:39');
INSERT INTO `userscoresnapshotledger` VALUES (3468, 'test002', 19, 2, 0, 92690, 92690, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:40');
INSERT INTO `userscoresnapshotledger` VALUES (3469, 'test002', 19, 2, 0, 92590, 92590, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:40');
INSERT INTO `userscoresnapshotledger` VALUES (3470, 'test002', 19, 2, 0, 92490, 92490, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:40');
INSERT INTO `userscoresnapshotledger` VALUES (3471, 'test002', 19, 2, 0, 92390, 92390, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:40');
INSERT INTO `userscoresnapshotledger` VALUES (3472, 'test002', 19, 2, 0, 92290, 92290, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:40');
INSERT INTO `userscoresnapshotledger` VALUES (3473, 'test002', 19, 2, 0, 92190, 92190, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:41');
INSERT INTO `userscoresnapshotledger` VALUES (3474, 'test002', 19, 2, 0, 92090, 92090, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:41');
INSERT INTO `userscoresnapshotledger` VALUES (3475, 'test002', 19, 2, 0, 91990, 91990, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:41');
INSERT INTO `userscoresnapshotledger` VALUES (3476, 'test002', 19, 2, 0, 91890, 91890, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:41');
INSERT INTO `userscoresnapshotledger` VALUES (3477, 'test002', 19, 2, 0, 91790, 91790, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:41');
INSERT INTO `userscoresnapshotledger` VALUES (3478, 'test002', 19, 2, 0, 91690, 91690, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:42');
INSERT INTO `userscoresnapshotledger` VALUES (3479, 'test002', 19, 2, 0, 91590, 91590, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:42');
INSERT INTO `userscoresnapshotledger` VALUES (3480, 'test002', 19, 2, 0, 91490, 91490, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:42');
INSERT INTO `userscoresnapshotledger` VALUES (3481, 'test002', 19, 2, 0, 91390, 91390, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:42');
INSERT INTO `userscoresnapshotledger` VALUES (3482, 'test002', 19, 2, 0, 91290, 91290, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:42');
INSERT INTO `userscoresnapshotledger` VALUES (3483, 'test002', 19, 2, 0, 91190, 91190, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:43');
INSERT INTO `userscoresnapshotledger` VALUES (3484, 'test002', 19, 2, 0, 91090, 91090, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:43');
INSERT INTO `userscoresnapshotledger` VALUES (3485, 'test002', 19, 2, 0, 90990, 90990, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:43');
INSERT INTO `userscoresnapshotledger` VALUES (3486, 'test002', 19, 2, 0, 90890, 90890, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:43');
INSERT INTO `userscoresnapshotledger` VALUES (3487, 'test002', 19, 2, 0, 90790, 90790, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:43');
INSERT INTO `userscoresnapshotledger` VALUES (3488, 'test002', 19, 2, 0, 90690, 90690, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:44');
INSERT INTO `userscoresnapshotledger` VALUES (3489, 'test002', 19, 2, 0, 90590, 90590, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:44');
INSERT INTO `userscoresnapshotledger` VALUES (3490, 'test002', 19, 2, 0, 90490, 90490, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:44');
INSERT INTO `userscoresnapshotledger` VALUES (3491, 'test002', 19, 2, 0, 90390, 90390, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:44');
INSERT INTO `userscoresnapshotledger` VALUES (3492, 'test002', 19, 2, 90390, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:44');
INSERT INTO `userscoresnapshotledger` VALUES (3493, 'test002', 19, 2, 90390, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:19:45');
INSERT INTO `userscoresnapshotledger` VALUES (3494, 'test002', 54, 0, 90390, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 17:19:47');
INSERT INTO `userscoresnapshotledger` VALUES (3495, 'test002', 54, 0, 90390, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 17:20:06');
INSERT INTO `userscoresnapshotledger` VALUES (3496, 'test002', 54, 0, 90390, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 17:20:12');
INSERT INTO `userscoresnapshotledger` VALUES (3497, 'test002', 54, 0, 90390, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 17:20:17');
INSERT INTO `userscoresnapshotledger` VALUES (3498, 'test002', 54, 0, 90390, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 17:20:21');
INSERT INTO `userscoresnapshotledger` VALUES (3499, 'test002', 54, 0, 90390, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 17:20:27');
INSERT INTO `userscoresnapshotledger` VALUES (3500, 'test002', 54, 0, 90390, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 17:21:08');
INSERT INTO `userscoresnapshotledger` VALUES (3501, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 17:22:56');
INSERT INTO `userscoresnapshotledger` VALUES (3502, 'test002', 0, 22, 90390, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:23:39');
INSERT INTO `userscoresnapshotledger` VALUES (3503, 'test01', 53, 31, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:23:39');
INSERT INTO `userscoresnapshotledger` VALUES (3504, 'test01', 0, 10, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:38:56');
INSERT INTO `userscoresnapshotledger` VALUES (3505, 'test01', 53, 14, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:51:52');
INSERT INTO `userscoresnapshotledger` VALUES (3506, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 17:51:52');
INSERT INTO `userscoresnapshotledger` VALUES (3507, 'test01', 53, 16, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 17:57:19');
INSERT INTO `userscoresnapshotledger` VALUES (3508, 'test01', 0, 23, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 19:10:18');
INSERT INTO `userscoresnapshotledger` VALUES (3509, 'test01', 53, 4, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 19:11:09');
INSERT INTO `userscoresnapshotledger` VALUES (3510, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 19:11:09');
INSERT INTO `userscoresnapshotledger` VALUES (3511, 'test01', 53, 7, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 19:17:52');
INSERT INTO `userscoresnapshotledger` VALUES (3512, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 19:17:52');
INSERT INTO `userscoresnapshotledger` VALUES (3513, 'test01', 53, 10, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 19:18:03');
INSERT INTO `userscoresnapshotledger` VALUES (3514, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 19:18:03');
INSERT INTO `userscoresnapshotledger` VALUES (3515, 'test01', 0, 10, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 19:23:25');
INSERT INTO `userscoresnapshotledger` VALUES (3516, 'test01', 53, 3, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 19:24:18');
INSERT INTO `userscoresnapshotledger` VALUES (3517, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 19:24:19');
INSERT INTO `userscoresnapshotledger` VALUES (3518, 'test01', 53, 6, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 19:25:20');
INSERT INTO `userscoresnapshotledger` VALUES (3519, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 19:25:20');
INSERT INTO `userscoresnapshotledger` VALUES (3520, 'test01', 0, 8, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 19:27:05');
INSERT INTO `userscoresnapshotledger` VALUES (3521, 'test01', 53, 2, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 19:27:54');
INSERT INTO `userscoresnapshotledger` VALUES (3522, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 19:27:54');
INSERT INTO `userscoresnapshotledger` VALUES (3523, 'test01', 0, 2, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 19:29:58');
INSERT INTO `userscoresnapshotledger` VALUES (3524, 'test01', 53, 3, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 19:30:32');
INSERT INTO `userscoresnapshotledger` VALUES (3525, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-08 19:30:33');
INSERT INTO `userscoresnapshotledger` VALUES (3526, 'test01', 53, 9, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 19:45:09');
INSERT INTO `userscoresnapshotledger` VALUES (3527, 'test01', 0, 13, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 19:53:41');
INSERT INTO `userscoresnapshotledger` VALUES (3528, 'test01', 0, 7, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-08 19:59:13');
INSERT INTO `userscoresnapshotledger` VALUES (3529, 'test01', 53, 3, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 10:21:06');
INSERT INTO `userscoresnapshotledger` VALUES (3530, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 10:21:06');
INSERT INTO `userscoresnapshotledger` VALUES (3531, 'test002', 0, 26, 90390, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 11:36:31');
INSERT INTO `userscoresnapshotledger` VALUES (3532, 'test01', 0, 11, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 11:36:31');
INSERT INTO `userscoresnapshotledger` VALUES (3533, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 11:58:40');
INSERT INTO `userscoresnapshotledger` VALUES (3534, 'test01', 6, 4, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 12:03:21');
INSERT INTO `userscoresnapshotledger` VALUES (3535, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 12:04:46');
INSERT INTO `userscoresnapshotledger` VALUES (3536, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 12:05:48');
INSERT INTO `userscoresnapshotledger` VALUES (3537, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 12:15:17');
INSERT INTO `userscoresnapshotledger` VALUES (3538, 'test01', 0, 3, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 13:39:47');
INSERT INTO `userscoresnapshotledger` VALUES (3539, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 13:41:40');
INSERT INTO `userscoresnapshotledger` VALUES (3540, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 13:43:45');
INSERT INTO `userscoresnapshotledger` VALUES (3541, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 13:43:58');
INSERT INTO `userscoresnapshotledger` VALUES (3542, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 13:44:07');
INSERT INTO `userscoresnapshotledger` VALUES (3543, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 13:47:12');
INSERT INTO `userscoresnapshotledger` VALUES (3544, 'test002', 54, 0, 90390, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 14:05:53');
INSERT INTO `userscoresnapshotledger` VALUES (3545, 'test002', 54, 0, 90390, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 14:05:55');
INSERT INTO `userscoresnapshotledger` VALUES (3546, 'test002', 54, 0, 90390, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 14:06:36');
INSERT INTO `userscoresnapshotledger` VALUES (3547, 'test002', 0, 31, 90390, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:11:15');
INSERT INTO `userscoresnapshotledger` VALUES (3548, 'test01', 0, 24, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:11:16');
INSERT INTO `userscoresnapshotledger` VALUES (3549, 'test002', 54, 0, 90390, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 14:18:55');
INSERT INTO `userscoresnapshotledger` VALUES (3550, 'test002', 49, 6, 0, 90390, 90390, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:37:29');
INSERT INTO `userscoresnapshotledger` VALUES (3551, 'test002', 49, 6, 0, 90290, 90290, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:37:33');
INSERT INTO `userscoresnapshotledger` VALUES (3552, 'test002', 49, 6, 0, 90190, 90190, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:37:34');
INSERT INTO `userscoresnapshotledger` VALUES (3553, 'test002', 49, 6, 0, 90090, 90090, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:37:35');
INSERT INTO `userscoresnapshotledger` VALUES (3554, 'test002', 49, 6, 0, 89990, 89990, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:37:35');
INSERT INTO `userscoresnapshotledger` VALUES (3555, 'test002', 49, 6, 0, 89890, 89890, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:37:35');
INSERT INTO `userscoresnapshotledger` VALUES (3556, 'test002', 49, 6, 0, 89790, 89790, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:37:35');
INSERT INTO `userscoresnapshotledger` VALUES (3557, 'test002', 49, 6, 0, 89690, 89690, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:37:36');
INSERT INTO `userscoresnapshotledger` VALUES (3558, 'test002', 49, 6, 0, 89590, 89590, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:37:36');
INSERT INTO `userscoresnapshotledger` VALUES (3559, 'test002', 49, 6, 0, 89490, 89490, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:37:36');
INSERT INTO `userscoresnapshotledger` VALUES (3560, 'test002', 49, 6, 0, 89390, 89390, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:37:36');
INSERT INTO `userscoresnapshotledger` VALUES (3561, 'test002', 49, 6, 0, 89290, 89290, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:37:37');
INSERT INTO `userscoresnapshotledger` VALUES (3562, 'test002', 49, 6, 0, 89190, 89190, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:37:37');
INSERT INTO `userscoresnapshotledger` VALUES (3563, 'test002', 49, 6, 0, 89090, 89090, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:37:37');
INSERT INTO `userscoresnapshotledger` VALUES (3564, 'test002', 49, 6, 0, 88990, 88990, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:37:37');
INSERT INTO `userscoresnapshotledger` VALUES (3565, 'test002', 49, 6, 0, 88890, 88890, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:37:38');
INSERT INTO `userscoresnapshotledger` VALUES (3566, 'test002', 49, 6, 0, 88790, 88790, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:37:38');
INSERT INTO `userscoresnapshotledger` VALUES (3567, 'test002', 49, 6, 0, 88690, 88690, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:37:38');
INSERT INTO `userscoresnapshotledger` VALUES (3568, 'test002', 49, 6, 0, 88590, 88590, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:37:38');
INSERT INTO `userscoresnapshotledger` VALUES (3569, 'test002', 49, 6, 0, 88490, 88490, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:37:38');
INSERT INTO `userscoresnapshotledger` VALUES (3570, 'test002', 49, 6, 0, 88390, 88390, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:37:39');
INSERT INTO `userscoresnapshotledger` VALUES (3571, 'test002', 49, 6, 0, 88290, 88290, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:37:39');
INSERT INTO `userscoresnapshotledger` VALUES (3572, 'test002', 49, 6, 88290, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:37:47');
INSERT INTO `userscoresnapshotledger` VALUES (3573, 'test002', 49, 6, 88290, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 14:37:49');
INSERT INTO `userscoresnapshotledger` VALUES (3574, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 14:37:52');
INSERT INTO `userscoresnapshotledger` VALUES (3575, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 14:37:58');
INSERT INTO `userscoresnapshotledger` VALUES (3576, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 14:38:01');
INSERT INTO `userscoresnapshotledger` VALUES (3577, 'test002', 0, 12, 88290, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 15:22:49');
INSERT INTO `userscoresnapshotledger` VALUES (3578, 'test01', 53, 2, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 15:23:11');
INSERT INTO `userscoresnapshotledger` VALUES (3579, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 15:23:11');
INSERT INTO `userscoresnapshotledger` VALUES (3580, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 16:38:32');
INSERT INTO `userscoresnapshotledger` VALUES (3581, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 16:38:34');
INSERT INTO `userscoresnapshotledger` VALUES (3582, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 16:38:37');
INSERT INTO `userscoresnapshotledger` VALUES (3583, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 16:38:41');
INSERT INTO `userscoresnapshotledger` VALUES (3584, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 16:38:44');
INSERT INTO `userscoresnapshotledger` VALUES (3585, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 16:38:46');
INSERT INTO `userscoresnapshotledger` VALUES (3586, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 16:38:48');
INSERT INTO `userscoresnapshotledger` VALUES (3587, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 16:38:52');
INSERT INTO `userscoresnapshotledger` VALUES (3588, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 16:39:00');
INSERT INTO `userscoresnapshotledger` VALUES (3589, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 16:39:03');
INSERT INTO `userscoresnapshotledger` VALUES (3590, 'test002', 0, 28, 88290, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 16:39:50');
INSERT INTO `userscoresnapshotledger` VALUES (3591, 'test01', 0, 2, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 16:39:50');
INSERT INTO `userscoresnapshotledger` VALUES (3592, 'test01', 53, 4, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 16:47:03');
INSERT INTO `userscoresnapshotledger` VALUES (3593, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 16:47:04');
INSERT INTO `userscoresnapshotledger` VALUES (3594, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 16:56:49');
INSERT INTO `userscoresnapshotledger` VALUES (3595, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 16:57:10');
INSERT INTO `userscoresnapshotledger` VALUES (3596, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 16:57:22');
INSERT INTO `userscoresnapshotledger` VALUES (3597, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 16:57:33');
INSERT INTO `userscoresnapshotledger` VALUES (3598, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 16:57:43');
INSERT INTO `userscoresnapshotledger` VALUES (3599, 'test002', 0, 2, 88290, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 16:58:17');
INSERT INTO `userscoresnapshotledger` VALUES (3600, 'test01', 0, 15, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 16:58:17');
INSERT INTO `userscoresnapshotledger` VALUES (3601, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 17:05:28');
INSERT INTO `userscoresnapshotledger` VALUES (3602, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 17:05:35');
INSERT INTO `userscoresnapshotledger` VALUES (3603, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 17:05:47');
INSERT INTO `userscoresnapshotledger` VALUES (3604, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 17:05:54');
INSERT INTO `userscoresnapshotledger` VALUES (3605, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 17:05:58');
INSERT INTO `userscoresnapshotledger` VALUES (3606, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 17:06:03');
INSERT INTO `userscoresnapshotledger` VALUES (3607, 'test01', 0, 15, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 17:11:42');
INSERT INTO `userscoresnapshotledger` VALUES (3608, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 17:40:04');
INSERT INTO `userscoresnapshotledger` VALUES (3609, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 17:40:09');
INSERT INTO `userscoresnapshotledger` VALUES (3610, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 17:40:17');
INSERT INTO `userscoresnapshotledger` VALUES (3611, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 17:40:47');
INSERT INTO `userscoresnapshotledger` VALUES (3612, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 17:41:16');
INSERT INTO `userscoresnapshotledger` VALUES (3613, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 17:41:22');
INSERT INTO `userscoresnapshotledger` VALUES (3614, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 17:41:30');
INSERT INTO `userscoresnapshotledger` VALUES (3615, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 17:41:35');
INSERT INTO `userscoresnapshotledger` VALUES (3616, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 17:41:42');
INSERT INTO `userscoresnapshotledger` VALUES (3617, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 17:43:23');
INSERT INTO `userscoresnapshotledger` VALUES (3618, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 17:44:48');
INSERT INTO `userscoresnapshotledger` VALUES (3619, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 17:44:54');
INSERT INTO `userscoresnapshotledger` VALUES (3620, 'test01', 0, 27, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 17:57:44');
INSERT INTO `userscoresnapshotledger` VALUES (3621, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 18:07:42');
INSERT INTO `userscoresnapshotledger` VALUES (3622, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 18:07:46');
INSERT INTO `userscoresnapshotledger` VALUES (3623, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 18:07:48');
INSERT INTO `userscoresnapshotledger` VALUES (3624, 'test01', 53, 12, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 18:24:23');
INSERT INTO `userscoresnapshotledger` VALUES (3625, 'test01', 53, 14, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 18:30:38');
INSERT INTO `userscoresnapshotledger` VALUES (3626, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 18:30:38');
INSERT INTO `userscoresnapshotledger` VALUES (3627, 'test01', 53, 16, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 18:37:52');
INSERT INTO `userscoresnapshotledger` VALUES (3628, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 18:45:18');
INSERT INTO `userscoresnapshotledger` VALUES (3629, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 18:46:32');
INSERT INTO `userscoresnapshotledger` VALUES (3630, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 18:46:42');
INSERT INTO `userscoresnapshotledger` VALUES (3631, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 18:46:47');
INSERT INTO `userscoresnapshotledger` VALUES (3632, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 18:46:51');
INSERT INTO `userscoresnapshotledger` VALUES (3633, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 18:46:56');
INSERT INTO `userscoresnapshotledger` VALUES (3634, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 18:47:01');
INSERT INTO `userscoresnapshotledger` VALUES (3635, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 18:47:11');
INSERT INTO `userscoresnapshotledger` VALUES (3636, 'test01', 54, 0, 1014213, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 18:47:19');
INSERT INTO `userscoresnapshotledger` VALUES (3637, 'test002', 0, 19, 88290, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 19:03:33');
INSERT INTO `userscoresnapshotledger` VALUES (3638, 'test01', 0, 35, 1014213, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 19:03:33');
INSERT INTO `userscoresnapshotledger` VALUES (3639, 'test01', 53, 2, 1014123, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 19:07:55');
INSERT INTO `userscoresnapshotledger` VALUES (3640, 'test01', 53, 2, 1014033, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 19:08:05');
INSERT INTO `userscoresnapshotledger` VALUES (3641, 'test01', 53, 2, 1013943, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 19:08:30');
INSERT INTO `userscoresnapshotledger` VALUES (3642, 'test01', 53, 2, 1013943, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 19:15:47');
INSERT INTO `userscoresnapshotledger` VALUES (3643, 'test01', 53, 4, 1013942, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 19:16:33');
INSERT INTO `userscoresnapshotledger` VALUES (3644, 'test01', 53, 4, 1013933, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 19:16:35');
INSERT INTO `userscoresnapshotledger` VALUES (3645, 'test01', 53, 4, 1013929, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 19:16:36');
INSERT INTO `userscoresnapshotledger` VALUES (3646, 'test01', 53, 4, 1013920, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 19:16:36');
INSERT INTO `userscoresnapshotledger` VALUES (3647, 'test01', 53, 4, 1013911, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 19:16:37');
INSERT INTO `userscoresnapshotledger` VALUES (3648, 'test01', 53, 4, 1013904, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 19:16:37');
INSERT INTO `userscoresnapshotledger` VALUES (3649, 'test01', 53, 4, 1013895, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 19:16:38');
INSERT INTO `userscoresnapshotledger` VALUES (3650, 'test01', 53, 4, 1013886, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 19:16:38');
INSERT INTO `userscoresnapshotledger` VALUES (3651, 'test01', 53, 4, 1013877, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 19:16:38');
INSERT INTO `userscoresnapshotledger` VALUES (3652, 'test01', 53, 4, 1013868, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 19:16:39');
INSERT INTO `userscoresnapshotledger` VALUES (3653, 'test01', 53, 4, 1013861, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 19:16:39');
INSERT INTO `userscoresnapshotledger` VALUES (3654, 'test01', 53, 4, 1013852, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 19:16:40');
INSERT INTO `userscoresnapshotledger` VALUES (3655, 'test01', 53, 4, 1013852, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 19:17:23');
INSERT INTO `userscoresnapshotledger` VALUES (3656, 'test01', 54, 0, 1013852, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 19:17:23');
INSERT INTO `userscoresnapshotledger` VALUES (3657, 'test01', 53, 6, 1013852, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 19:43:47');
INSERT INTO `userscoresnapshotledger` VALUES (3658, 'test01', 54, 0, 1013852, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 19:43:47');
INSERT INTO `userscoresnapshotledger` VALUES (3659, 'test01', 53, 9, 1013843, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 19:48:24');
INSERT INTO `userscoresnapshotledger` VALUES (3660, 'test01', 53, 9, 1013834, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 19:48:24');
INSERT INTO `userscoresnapshotledger` VALUES (3661, 'test01', 53, 9, 1013825, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 19:48:25');
INSERT INTO `userscoresnapshotledger` VALUES (3662, 'test01', 53, 9, 1013825, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:10:03');
INSERT INTO `userscoresnapshotledger` VALUES (3663, 'test01', 54, 0, 1013825, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 20:10:03');
INSERT INTO `userscoresnapshotledger` VALUES (3664, 'test01', 53, 11, 1013818, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:18:45');
INSERT INTO `userscoresnapshotledger` VALUES (3665, 'test01', 53, 11, 1013811, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:18:49');
INSERT INTO `userscoresnapshotledger` VALUES (3666, 'test01', 53, 11, 1013807, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:19:33');
INSERT INTO `userscoresnapshotledger` VALUES (3667, 'test01', 53, 11, 1013808, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:21:59');
INSERT INTO `userscoresnapshotledger` VALUES (3668, 'test01', 53, 11, 1013808, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:25:43');
INSERT INTO `userscoresnapshotledger` VALUES (3669, 'test01', 54, 0, 1013808, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 20:25:43');
INSERT INTO `userscoresnapshotledger` VALUES (3670, 'test01', 53, 13, 1013806, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:27:56');
INSERT INTO `userscoresnapshotledger` VALUES (3671, 'test01', 53, 13, 1013807, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:28:00');
INSERT INTO `userscoresnapshotledger` VALUES (3672, 'test01', 53, 13, 1013800, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:28:04');
INSERT INTO `userscoresnapshotledger` VALUES (3673, 'test01', 53, 13, 1013799, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:28:11');
INSERT INTO `userscoresnapshotledger` VALUES (3674, 'test01', 53, 13, 1013798, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:28:13');
INSERT INTO `userscoresnapshotledger` VALUES (3675, 'test01', 53, 13, 1013797, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:28:17');
INSERT INTO `userscoresnapshotledger` VALUES (3676, 'test01', 53, 13, 1013797, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:31:32');
INSERT INTO `userscoresnapshotledger` VALUES (3677, 'test01', 54, 0, 1013797, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 20:31:32');
INSERT INTO `userscoresnapshotledger` VALUES (3678, 'test01', 53, 15, 1013197, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:33:39');
INSERT INTO `userscoresnapshotledger` VALUES (3679, 'test01', 53, 15, 1012397, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:33:47');
INSERT INTO `userscoresnapshotledger` VALUES (3680, 'test01', 53, 15, 1012397, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:37:53');
INSERT INTO `userscoresnapshotledger` VALUES (3681, 'test01', 54, 0, 1012397, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 20:37:54');
INSERT INTO `userscoresnapshotledger` VALUES (3682, 'test01', 53, 17, 1012396, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:39:41');
INSERT INTO `userscoresnapshotledger` VALUES (3683, 'test01', 53, 17, 1012371, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:40:02');
INSERT INTO `userscoresnapshotledger` VALUES (3684, 'test01', 53, 17, 1012346, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:40:03');
INSERT INTO `userscoresnapshotledger` VALUES (3685, 'test01', 53, 17, 1012321, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:40:06');
INSERT INTO `userscoresnapshotledger` VALUES (3686, 'test01', 53, 17, 1012296, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:40:09');
INSERT INTO `userscoresnapshotledger` VALUES (3687, 'test01', 53, 17, 1012281, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:41:42');
INSERT INTO `userscoresnapshotledger` VALUES (3688, 'test01', 53, 17, 1012266, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:41:45');
INSERT INTO `userscoresnapshotledger` VALUES (3689, 'test01', 53, 17, 1012246, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:41:49');
INSERT INTO `userscoresnapshotledger` VALUES (3690, 'test01', 53, 17, 1012246, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:41:49');
INSERT INTO `userscoresnapshotledger` VALUES (3691, 'test01', 54, 0, 1012246, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 20:41:49');
INSERT INTO `userscoresnapshotledger` VALUES (3692, 'test01', 53, 19, 1012206, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:43:53');
INSERT INTO `userscoresnapshotledger` VALUES (3693, 'test01', 53, 19, 1012166, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:43:56');
INSERT INTO `userscoresnapshotledger` VALUES (3694, 'test01', 53, 19, 1012126, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:44:00');
INSERT INTO `userscoresnapshotledger` VALUES (3695, 'test01', 53, 19, 1012126, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:45:11');
INSERT INTO `userscoresnapshotledger` VALUES (3696, 'test01', 54, 0, 1012126, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-09 20:45:11');
INSERT INTO `userscoresnapshotledger` VALUES (3697, 'test01', 53, 21, 1012117, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:47:33');
INSERT INTO `userscoresnapshotledger` VALUES (3698, 'test01', 53, 21, 1012109, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:52:09');
INSERT INTO `userscoresnapshotledger` VALUES (3699, 'test01', 53, 21, 1012019, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:52:21');
INSERT INTO `userscoresnapshotledger` VALUES (3700, 'test01', 53, 21, 1011929, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:52:23');
INSERT INTO `userscoresnapshotledger` VALUES (3701, 'test01', 53, 21, 1011839, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:52:26');
INSERT INTO `userscoresnapshotledger` VALUES (3702, 'test01', 53, 21, 1011749, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:54:05');
INSERT INTO `userscoresnapshotledger` VALUES (3703, 'test01', 53, 21, 1011659, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:54:07');
INSERT INTO `userscoresnapshotledger` VALUES (3704, 'test01', 53, 21, 1011569, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:54:11');
INSERT INTO `userscoresnapshotledger` VALUES (3705, 'test01', 53, 21, 1011479, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:58:29');
INSERT INTO `userscoresnapshotledger` VALUES (3706, 'test01', 53, 21, 1011489, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:58:31');
INSERT INTO `userscoresnapshotledger` VALUES (3707, 'test01', 53, 21, 1011399, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:58:33');
INSERT INTO `userscoresnapshotledger` VALUES (3708, 'test01', 53, 21, 1011309, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:58:35');
INSERT INTO `userscoresnapshotledger` VALUES (3709, 'test01', 53, 21, 1011219, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:58:38');
INSERT INTO `userscoresnapshotledger` VALUES (3710, 'test01', 53, 21, 1011129, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:58:40');
INSERT INTO `userscoresnapshotledger` VALUES (3711, 'test01', 53, 21, 1011039, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:58:42');
INSERT INTO `userscoresnapshotledger` VALUES (3712, 'test01', 53, 21, 1010949, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:58:44');
INSERT INTO `userscoresnapshotledger` VALUES (3713, 'test01', 53, 21, 1010859, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 20:58:46');
INSERT INTO `userscoresnapshotledger` VALUES (3714, 'test01', 53, 21, 1010769, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 21:00:34');
INSERT INTO `userscoresnapshotledger` VALUES (3715, 'test01', 53, 21, 1010679, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 21:00:36');
INSERT INTO `userscoresnapshotledger` VALUES (3716, 'test01', 53, 21, 1010629, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 21:00:38');
INSERT INTO `userscoresnapshotledger` VALUES (3717, 'test01', 53, 21, 1010539, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 21:00:40');
INSERT INTO `userscoresnapshotledger` VALUES (3718, 'test01', 53, 21, 1010449, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 21:00:42');
INSERT INTO `userscoresnapshotledger` VALUES (3719, 'test01', 53, 21, 1010389, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 21:00:43');
INSERT INTO `userscoresnapshotledger` VALUES (3720, 'test01', 53, 21, 1010299, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 21:00:47');
INSERT INTO `userscoresnapshotledger` VALUES (3721, 'test01', 53, 21, 1010199, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 21:00:57');
INSERT INTO `userscoresnapshotledger` VALUES (3722, 'test01', 53, 21, 1010199, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-09 21:32:53');
INSERT INTO `userscoresnapshotledger` VALUES (3723, 'test01', 0, 21, 1010199, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 09:35:42');
INSERT INTO `userscoresnapshotledger` VALUES (3724, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 09:49:11');
INSERT INTO `userscoresnapshotledger` VALUES (3725, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 09:49:27');
INSERT INTO `userscoresnapshotledger` VALUES (3726, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 09:49:31');
INSERT INTO `userscoresnapshotledger` VALUES (3727, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 09:49:34');
INSERT INTO `userscoresnapshotledger` VALUES (3728, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 09:50:33');
INSERT INTO `userscoresnapshotledger` VALUES (3729, 'test01', 54, 0, 1010199, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 09:54:41');
INSERT INTO `userscoresnapshotledger` VALUES (3730, 'test01', 53, 20, 1010198, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 09:54:53');
INSERT INTO `userscoresnapshotledger` VALUES (3731, 'test01', 53, 20, 1010197, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 09:54:55');
INSERT INTO `userscoresnapshotledger` VALUES (3732, 'test01', 53, 20, 1010193, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 09:55:01');
INSERT INTO `userscoresnapshotledger` VALUES (3733, 'test01', 53, 20, 1010194, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 09:55:03');
INSERT INTO `userscoresnapshotledger` VALUES (3734, 'test01', 53, 20, 1010189, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 09:55:05');
INSERT INTO `userscoresnapshotledger` VALUES (3735, 'test01', 53, 20, 1010180, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 09:55:07');
INSERT INTO `userscoresnapshotledger` VALUES (3736, 'test01', 53, 20, 1010180, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 09:55:10');
INSERT INTO `userscoresnapshotledger` VALUES (3737, 'test01', 53, 25, 1009930, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 10:30:44');
INSERT INTO `userscoresnapshotledger` VALUES (3738, 'test01', 53, 25, 1009930, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 10:30:46');
INSERT INTO `userscoresnapshotledger` VALUES (3739, 'test01', 53, 27, 1009927, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 10:34:13');
INSERT INTO `userscoresnapshotledger` VALUES (3740, 'test01', 53, 27, 1009918, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 10:34:28');
INSERT INTO `userscoresnapshotledger` VALUES (3741, 'test01', 53, 27, 1009917, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 10:34:32');
INSERT INTO `userscoresnapshotledger` VALUES (3742, 'test01', 53, 27, 1009914, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 10:34:35');
INSERT INTO `userscoresnapshotledger` VALUES (3743, 'test01', 53, 27, 1009911, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 10:34:39');
INSERT INTO `userscoresnapshotledger` VALUES (3744, 'test01', 53, 27, 1009911, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 10:35:07');
INSERT INTO `userscoresnapshotledger` VALUES (3745, 'test002', 0, 16, 88290, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 10:52:23');
INSERT INTO `userscoresnapshotledger` VALUES (3746, 'test01', 0, 28, 1009911, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 10:52:23');
INSERT INTO `userscoresnapshotledger` VALUES (3747, 'test01', 40, 8, 1009911, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 11:11:53');
INSERT INTO `userscoresnapshotledger` VALUES (3748, 'test01', 54, 0, 1009911, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 11:11:53');
INSERT INTO `userscoresnapshotledger` VALUES (3749, 'test01', 0, 8, 1009911, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 11:43:16');
INSERT INTO `userscoresnapshotledger` VALUES (3750, 'test01', 0, 5, 1009911, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 12:03:41');
INSERT INTO `userscoresnapshotledger` VALUES (3751, 'test01', 40, 8, 1009911, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 13:12:23');
INSERT INTO `userscoresnapshotledger` VALUES (3752, 'test01', 54, 0, 1009911, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 13:12:23');
INSERT INTO `userscoresnapshotledger` VALUES (3753, 'test01', 49, 20, 0, 1009911, 1009911, 0, 'SNAPSHOT_SAVE', '2026-07-10 13:43:45');
INSERT INTO `userscoresnapshotledger` VALUES (3754, 'test01', 49, 20, 1009911, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 13:44:04');
INSERT INTO `userscoresnapshotledger` VALUES (3755, 'test01', 49, 20, 1009911, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 13:44:06');
INSERT INTO `userscoresnapshotledger` VALUES (3756, 'test01', 49, 20, 1009911, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 13:44:06');
INSERT INTO `userscoresnapshotledger` VALUES (3757, 'test01', 54, 0, 1009911, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 13:44:09');
INSERT INTO `userscoresnapshotledger` VALUES (3758, 'test01', 54, 0, 1009911, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 13:44:12');
INSERT INTO `userscoresnapshotledger` VALUES (3759, 'test01', 54, 0, 1009911, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 13:44:17');
INSERT INTO `userscoresnapshotledger` VALUES (3760, 'test01', 54, 0, 1009911, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 13:44:21');
INSERT INTO `userscoresnapshotledger` VALUES (3761, 'test01', 54, 0, 1009911, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 13:44:25');
INSERT INTO `userscoresnapshotledger` VALUES (3762, 'test01', 54, 0, 1009911, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 13:44:39');
INSERT INTO `userscoresnapshotledger` VALUES (3763, 'test01', 0, 33, 1009911, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 13:45:13');
INSERT INTO `userscoresnapshotledger` VALUES (3764, 'test01', 40, 2, 1009911, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 13:56:41');
INSERT INTO `userscoresnapshotledger` VALUES (3765, 'test01', 54, 0, 1009911, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 13:56:41');
INSERT INTO `userscoresnapshotledger` VALUES (3766, 'test01', 40, 3, 1009911, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 14:04:22');
INSERT INTO `userscoresnapshotledger` VALUES (3767, 'test01', 40, 5, 1009911, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 14:04:44');
INSERT INTO `userscoresnapshotledger` VALUES (3768, 'test01', 54, 0, 1009911, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 14:04:44');
INSERT INTO `userscoresnapshotledger` VALUES (3769, 'test01', 40, 6, 1009908, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 14:04:49');
INSERT INTO `userscoresnapshotledger` VALUES (3770, 'test01', 40, 21, 1009908, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 14:21:09');
INSERT INTO `userscoresnapshotledger` VALUES (3771, 'test01', 54, 0, 1009908, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 14:21:09');
INSERT INTO `userscoresnapshotledger` VALUES (3772, 'test01', 40, 24, 1009908, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 14:21:22');
INSERT INTO `userscoresnapshotledger` VALUES (3773, 'test01', 54, 0, 1009908, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 14:21:22');
INSERT INTO `userscoresnapshotledger` VALUES (3774, 'test03', 53, 28, 310930, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 14:26:56');
INSERT INTO `userscoresnapshotledger` VALUES (3775, 'test03', 54, 0, 310930, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 14:26:56');
INSERT INTO `userscoresnapshotledger` VALUES (3776, 'test01', 40, 25, 1009908, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 14:27:35');
INSERT INTO `userscoresnapshotledger` VALUES (3777, 'test01', 53, 36, 1009908, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 14:27:50');
INSERT INTO `userscoresnapshotledger` VALUES (3778, 'test01', 40, 42, 1009908, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 14:32:03');
INSERT INTO `userscoresnapshotledger` VALUES (3779, 'test01', 54, 0, 1009908, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 14:32:03');
INSERT INTO `userscoresnapshotledger` VALUES (3780, 'test01', 40, 43, 1009908, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 14:46:01');
INSERT INTO `userscoresnapshotledger` VALUES (3781, 'test01', 53, 45, 1009908, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 14:46:12');
INSERT INTO `userscoresnapshotledger` VALUES (3782, 'test01', 0, 52, 1009908, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 14:59:29');
INSERT INTO `userscoresnapshotledger` VALUES (3783, 'test03', 0, 61, 310930, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 14:59:29');
INSERT INTO `userscoresnapshotledger` VALUES (3784, 'test01', 53, 2, 1009908, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:14:14');
INSERT INTO `userscoresnapshotledger` VALUES (3785, 'test01', 40, 13, 1009908, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:18:12');
INSERT INTO `userscoresnapshotledger` VALUES (3786, 'test01', 54, 0, 1009908, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 15:18:12');
INSERT INTO `userscoresnapshotledger` VALUES (3787, 'test01', 40, 14, 1010024, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:18:26');
INSERT INTO `userscoresnapshotledger` VALUES (3788, 'test01', 40, 14, 1010081, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:18:55');
INSERT INTO `userscoresnapshotledger` VALUES (3789, 'test01', 40, 14, 1011041, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:19:19');
INSERT INTO `userscoresnapshotledger` VALUES (3790, 'test01', 40, 14, 1011031, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:20:00');
INSERT INTO `userscoresnapshotledger` VALUES (3791, 'test01', 40, 14, 1011031, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:20:38');
INSERT INTO `userscoresnapshotledger` VALUES (3792, 'test01', 40, 16, 1011031, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:20:50');
INSERT INTO `userscoresnapshotledger` VALUES (3793, 'test01', 54, 0, 1011031, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 15:20:50');
INSERT INTO `userscoresnapshotledger` VALUES (3794, 'test01', 40, 17, 1011030, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:20:58');
INSERT INTO `userscoresnapshotledger` VALUES (3795, 'test01', 40, 17, 1011030, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:21:28');
INSERT INTO `userscoresnapshotledger` VALUES (3796, 'test01', 40, 19, 1011030, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:21:35');
INSERT INTO `userscoresnapshotledger` VALUES (3797, 'test01', 54, 0, 1011030, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 15:21:35');
INSERT INTO `userscoresnapshotledger` VALUES (3798, 'test01', 40, 20, 1011026, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:21:49');
INSERT INTO `userscoresnapshotledger` VALUES (3799, 'test01', 40, 20, 1011026, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:23:34');
INSERT INTO `userscoresnapshotledger` VALUES (3800, 'test01', 40, 23, 1011026, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:23:44');
INSERT INTO `userscoresnapshotledger` VALUES (3801, 'test01', 54, 0, 1011026, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 15:23:44');
INSERT INTO `userscoresnapshotledger` VALUES (3802, 'test01', 40, 24, 1011034, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:23:49');
INSERT INTO `userscoresnapshotledger` VALUES (3803, 'test01', 40, 24, 1011058, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:24:00');
INSERT INTO `userscoresnapshotledger` VALUES (3804, 'test01', 40, 24, 1011055, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:24:11');
INSERT INTO `userscoresnapshotledger` VALUES (3805, 'test01', 40, 24, 1011167, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:24:26');
INSERT INTO `userscoresnapshotledger` VALUES (3806, 'test01', 40, 24, 1011164, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:24:49');
INSERT INTO `userscoresnapshotledger` VALUES (3807, 'test01', 40, 24, 1011158, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:27:45');
INSERT INTO `userscoresnapshotledger` VALUES (3808, 'test01', 40, 24, 1013468, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:28:39');
INSERT INTO `userscoresnapshotledger` VALUES (3809, 'test01', 40, 24, 1013532, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:30:07');
INSERT INTO `userscoresnapshotledger` VALUES (3810, 'test01', 40, 24, 1013554, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:30:15');
INSERT INTO `userscoresnapshotledger` VALUES (3811, 'test01', 40, 24, 1013554, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:30:33');
INSERT INTO `userscoresnapshotledger` VALUES (3812, 'test01', 40, 32, 1013554, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:31:27');
INSERT INTO `userscoresnapshotledger` VALUES (3813, 'test01', 54, 0, 1013554, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 15:31:27');
INSERT INTO `userscoresnapshotledger` VALUES (3814, 'test01', 53, 52, 1013551, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:43:53');
INSERT INTO `userscoresnapshotledger` VALUES (3815, 'test01', 53, 52, 1013481, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:44:01');
INSERT INTO `userscoresnapshotledger` VALUES (3816, 'test01', 53, 52, 1013481, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:44:03');
INSERT INTO `userscoresnapshotledger` VALUES (3817, 'test01', 40, 54, 1013481, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:44:08');
INSERT INTO `userscoresnapshotledger` VALUES (3818, 'test01', 54, 0, 1013481, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 15:44:08');
INSERT INTO `userscoresnapshotledger` VALUES (3819, 'test01', 40, 55, 1018281, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:44:13');
INSERT INTO `userscoresnapshotledger` VALUES (3820, 'test01', 40, 55, 1022281, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:44:23');
INSERT INTO `userscoresnapshotledger` VALUES (3821, 'test01', 40, 55, 1022281, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:44:31');
INSERT INTO `userscoresnapshotledger` VALUES (3822, 'test01', 0, 58, 1022281, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:48:59');
INSERT INTO `userscoresnapshotledger` VALUES (3823, 'test03', 0, 48, 310930, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 15:48:59');
INSERT INTO `userscoresnapshotledger` VALUES (3824, 'test01', 40, 15, 1022281, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 16:32:51');
INSERT INTO `userscoresnapshotledger` VALUES (3825, 'test01', 54, 0, 1022281, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 16:32:51');
INSERT INTO `userscoresnapshotledger` VALUES (3826, 'test01', 40, 16, 1022281, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 16:32:55');
INSERT INTO `userscoresnapshotledger` VALUES (3827, 'test01', 40, 18, 1022281, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 16:33:37');
INSERT INTO `userscoresnapshotledger` VALUES (3828, 'test01', 54, 0, 1022281, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 16:33:37');
INSERT INTO `userscoresnapshotledger` VALUES (3829, 'test01', 0, 20, 1022281, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 16:36:55');
INSERT INTO `userscoresnapshotledger` VALUES (3830, 'test01', 19, 9, 1022281, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 16:48:04');
INSERT INTO `userscoresnapshotledger` VALUES (3831, 'test01', 0, 7, 1022281, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 17:13:24');
INSERT INTO `userscoresnapshotledger` VALUES (3832, 'test01', 0, 1, 1022281, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 17:16:54');
INSERT INTO `userscoresnapshotledger` VALUES (3833, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 17:32:49');
INSERT INTO `userscoresnapshotledger` VALUES (3834, 'test01', 54, 0, 1022281, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 17:36:22');
INSERT INTO `userscoresnapshotledger` VALUES (3835, 'test01', 54, 0, 1022281, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 17:37:09');
INSERT INTO `userscoresnapshotledger` VALUES (3836, 'test002', 0, 6, 88290, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 17:52:41');
INSERT INTO `userscoresnapshotledger` VALUES (3837, 'test01', 0, 25, 1022281, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 17:52:41');
INSERT INTO `userscoresnapshotledger` VALUES (3838, 'test01', 16, 2, 1022281, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 18:38:53');
INSERT INTO `userscoresnapshotledger` VALUES (3839, 'test01', 54, 0, 1022281, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 18:38:53');
INSERT INTO `userscoresnapshotledger` VALUES (3840, 'test01', 16, 6, 1022281, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 18:46:33');
INSERT INTO `userscoresnapshotledger` VALUES (3841, 'test01', 54, 0, 1022281, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 18:46:33');
INSERT INTO `userscoresnapshotledger` VALUES (3842, 'test01', 16, 8, 1022281, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 18:52:33');
INSERT INTO `userscoresnapshotledger` VALUES (3843, 'test01', 54, 0, 1022281, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 18:52:33');
INSERT INTO `userscoresnapshotledger` VALUES (3844, 'test01', 16, 10, 1022281, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 19:00:41');
INSERT INTO `userscoresnapshotledger` VALUES (3845, 'test01', 54, 0, 1022281, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 19:00:42');
INSERT INTO `userscoresnapshotledger` VALUES (3846, 'test01', 16, 14, 1022281, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 19:07:41');
INSERT INTO `userscoresnapshotledger` VALUES (3847, 'test01', 54, 0, 1022281, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 19:07:41');
INSERT INTO `userscoresnapshotledger` VALUES (3848, 'test002', 0, 4, 88290, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 19:12:50');
INSERT INTO `userscoresnapshotledger` VALUES (3849, 'test01', 16, 16, 1022281, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 19:12:50');
INSERT INTO `userscoresnapshotledger` VALUES (3850, 'test01', 16, 2, 1022233, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 19:47:46');
INSERT INTO `userscoresnapshotledger` VALUES (3851, 'test01', 16, 2, 1022233, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 19:48:00');
INSERT INTO `userscoresnapshotledger` VALUES (3852, 'test01', 16, 2, 1022233, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 19:48:00');
INSERT INTO `userscoresnapshotledger` VALUES (3853, 'test01', 54, 0, 1022233, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 19:48:00');
INSERT INTO `userscoresnapshotledger` VALUES (3854, 'test01', 0, 14, 1022233, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 20:30:59');
INSERT INTO `userscoresnapshotledger` VALUES (3855, 'test01', 54, 0, 1022233, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 20:34:47');
INSERT INTO `userscoresnapshotledger` VALUES (3856, 'test01', 54, 0, 1022233, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 20:34:51');
INSERT INTO `userscoresnapshotledger` VALUES (3857, 'test01', 54, 0, 1022233, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 20:39:07');
INSERT INTO `userscoresnapshotledger` VALUES (3858, 'test01', 47, 8, 1022233, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 20:39:20');
INSERT INTO `userscoresnapshotledger` VALUES (3859, 'test01', 47, 10, 1022233, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 20:39:26');
INSERT INTO `userscoresnapshotledger` VALUES (3860, 'test01', 29, 12, 1022233, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 20:39:36');
INSERT INTO `userscoresnapshotledger` VALUES (3861, 'test01', 0, 13, 1022233, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 21:26:51');
INSERT INTO `userscoresnapshotledger` VALUES (3862, 'test01', 5, 2, 0, 1022233, 1022233, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:11:53');
INSERT INTO `userscoresnapshotledger` VALUES (3863, 'test01', 5, 2, 0, 1022223, 1022223, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:11:54');
INSERT INTO `userscoresnapshotledger` VALUES (3864, 'test01', 5, 2, 1022223, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:11:57');
INSERT INTO `userscoresnapshotledger` VALUES (3865, 'test01', 54, 0, 1022223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 22:11:58');
INSERT INTO `userscoresnapshotledger` VALUES (3866, 'test01', 54, 0, 1022223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 22:12:04');
INSERT INTO `userscoresnapshotledger` VALUES (3867, 'test01', 54, 0, 1022223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 22:12:10');
INSERT INTO `userscoresnapshotledger` VALUES (3868, 'test01', 2, 11, 1022223, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:12:40');
INSERT INTO `userscoresnapshotledger` VALUES (3869, 'test01', 54, 0, 1022223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 22:12:47');
INSERT INTO `userscoresnapshotledger` VALUES (3870, 'test01', 29, 15, 1022223, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:12:55');
INSERT INTO `userscoresnapshotledger` VALUES (3871, 'test01', 54, 0, 1022223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 22:13:48');
INSERT INTO `userscoresnapshotledger` VALUES (3872, 'test01', 54, 0, 1022223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 22:13:58');
INSERT INTO `userscoresnapshotledger` VALUES (3873, 'test01', 54, 0, 1022223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 22:14:37');
INSERT INTO `userscoresnapshotledger` VALUES (3874, 'test01', 54, 0, 1022223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 22:14:43');
INSERT INTO `userscoresnapshotledger` VALUES (3875, 'test01', 0, 24, 1022223, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:15:13');
INSERT INTO `userscoresnapshotledger` VALUES (3876, 'test01', 53, 5, 1022223, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:16:02');
INSERT INTO `userscoresnapshotledger` VALUES (3877, 'test01', 54, 0, 1022223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 22:16:12');
INSERT INTO `userscoresnapshotledger` VALUES (3878, 'test01', 54, 0, 1022223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 22:16:15');
INSERT INTO `userscoresnapshotledger` VALUES (3879, 'test01', 54, 0, 1022223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 22:16:20');
INSERT INTO `userscoresnapshotledger` VALUES (3880, 'test01', 54, 0, 1022223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 22:16:27');
INSERT INTO `userscoresnapshotledger` VALUES (3881, 'test01', 54, 0, 1022223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 22:16:33');
INSERT INTO `userscoresnapshotledger` VALUES (3882, 'test01', 54, 0, 1022223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 22:16:38');
INSERT INTO `userscoresnapshotledger` VALUES (3883, 'test01', 54, 0, 1022223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 22:16:45');
INSERT INTO `userscoresnapshotledger` VALUES (3884, 'test01', 54, 0, 1022223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 22:16:56');
INSERT INTO `userscoresnapshotledger` VALUES (3885, 'test01', 0, 24, 1022223, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:19:57');
INSERT INTO `userscoresnapshotledger` VALUES (3886, 'test01', 54, 0, 1022223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 22:32:32');
INSERT INTO `userscoresnapshotledger` VALUES (3887, 'test01', 54, 0, 1022223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 22:32:39');
INSERT INTO `userscoresnapshotledger` VALUES (3888, 'test01', 54, 0, 1022223, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 22:32:47');
INSERT INTO `userscoresnapshotledger` VALUES (3889, 'test01', 49, 11, 0, 1022223, 1022223, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:32:50');
INSERT INTO `userscoresnapshotledger` VALUES (3890, 'test01', 49, 11, 0, 1022123, 1022123, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:32:53');
INSERT INTO `userscoresnapshotledger` VALUES (3891, 'test01', 49, 11, 0, 1022023, 1022023, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:32:54');
INSERT INTO `userscoresnapshotledger` VALUES (3892, 'test01', 49, 11, 0, 1021923, 1021923, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:32:58');
INSERT INTO `userscoresnapshotledger` VALUES (3893, 'test01', 49, 11, 1021923, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:33:15');
INSERT INTO `userscoresnapshotledger` VALUES (3894, 'test01', 49, 11, 1021923, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:33:16');
INSERT INTO `userscoresnapshotledger` VALUES (3895, 'test01', 54, 0, 1021923, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 22:33:17');
INSERT INTO `userscoresnapshotledger` VALUES (3896, 'test01', 54, 0, 1021923, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 22:33:25');
INSERT INTO `userscoresnapshotledger` VALUES (3897, 'test01', 54, 0, 1021923, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 22:33:29');
INSERT INTO `userscoresnapshotledger` VALUES (3898, 'test01', 54, 0, 1021923, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 22:33:32');
INSERT INTO `userscoresnapshotledger` VALUES (3899, 'test01', 19, 21, 0, 1021923, 1021923, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:33:43');
INSERT INTO `userscoresnapshotledger` VALUES (3900, 'test01', 19, 21, 0, 1021823, 1021823, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:33:46');
INSERT INTO `userscoresnapshotledger` VALUES (3901, 'test01', 19, 21, 0, 1021723, 1021723, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:33:47');
INSERT INTO `userscoresnapshotledger` VALUES (3902, 'test01', 19, 21, 0, 1021623, 1021623, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:33:47');
INSERT INTO `userscoresnapshotledger` VALUES (3903, 'test01', 19, 21, 0, 1021523, 1021523, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:33:47');
INSERT INTO `userscoresnapshotledger` VALUES (3904, 'test01', 19, 21, 0, 1021423, 1021423, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:33:47');
INSERT INTO `userscoresnapshotledger` VALUES (3905, 'test01', 19, 21, 0, 1021323, 1021323, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:33:48');
INSERT INTO `userscoresnapshotledger` VALUES (3906, 'test01', 19, 21, 0, 1021223, 1021223, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:33:48');
INSERT INTO `userscoresnapshotledger` VALUES (3907, 'test01', 19, 21, 0, 1021123, 1021123, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:33:48');
INSERT INTO `userscoresnapshotledger` VALUES (3908, 'test01', 19, 21, 0, 1021023, 1021023, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:33:48');
INSERT INTO `userscoresnapshotledger` VALUES (3909, 'test01', 19, 21, 0, 1020923, 1020923, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:33:49');
INSERT INTO `userscoresnapshotledger` VALUES (3910, 'test01', 19, 21, 0, 1020823, 1020823, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:33:49');
INSERT INTO `userscoresnapshotledger` VALUES (3911, 'test01', 19, 21, 0, 1020723, 1020723, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:33:49');
INSERT INTO `userscoresnapshotledger` VALUES (3912, 'test01', 19, 21, 1020723, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:33:51');
INSERT INTO `userscoresnapshotledger` VALUES (3913, 'test01', 0, 21, 1020723, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:34:01');
INSERT INTO `userscoresnapshotledger` VALUES (3914, 'test01', 54, 0, 1020723, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-10 22:36:53');
INSERT INTO `userscoresnapshotledger` VALUES (3915, 'test01', 0, 15, 1020723, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-10 22:45:13');
INSERT INTO `userscoresnapshotledger` VALUES (3916, 'test01', 53, 4, 1020717, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:25:55');
INSERT INTO `userscoresnapshotledger` VALUES (3917, 'test01', 53, 4, 1020711, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:25:57');
INSERT INTO `userscoresnapshotledger` VALUES (3918, 'test01', 53, 4, 1020705, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:25:59');
INSERT INTO `userscoresnapshotledger` VALUES (3919, 'test01', 53, 4, 1020699, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:26:01');
INSERT INTO `userscoresnapshotledger` VALUES (3920, 'test01', 53, 4, 1020693, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:26:03');
INSERT INTO `userscoresnapshotledger` VALUES (3921, 'test01', 53, 4, 1020693, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:26:05');
INSERT INTO `userscoresnapshotledger` VALUES (3922, 'test01', 40, 6, 1020693, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:26:10');
INSERT INTO `userscoresnapshotledger` VALUES (3923, 'test01', 54, 0, 1020693, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 11:26:10');
INSERT INTO `userscoresnapshotledger` VALUES (3924, 'test01', 40, 7, 1020759, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:26:19');
INSERT INTO `userscoresnapshotledger` VALUES (3925, 'test01', 40, 7, 1020759, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:26:55');
INSERT INTO `userscoresnapshotledger` VALUES (3926, 'test01', 16, 9, 1020787, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:27:08');
INSERT INTO `userscoresnapshotledger` VALUES (3927, 'test01', 16, 9, 1020787, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:27:21');
INSERT INTO `userscoresnapshotledger` VALUES (3928, 'test01', 16, 9, 1020811, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:27:33');
INSERT INTO `userscoresnapshotledger` VALUES (3929, 'test01', 16, 9, 1020763, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:27:35');
INSERT INTO `userscoresnapshotledger` VALUES (3930, 'test01', 16, 9, 1020755, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:28:28');
INSERT INTO `userscoresnapshotledger` VALUES (3931, 'test01', 16, 9, 1020755, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:28:48');
INSERT INTO `userscoresnapshotledger` VALUES (3932, 'test01', 16, 9, 1020755, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:28:48');
INSERT INTO `userscoresnapshotledger` VALUES (3933, 'test01', 54, 0, 1020755, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 11:28:48');
INSERT INTO `userscoresnapshotledger` VALUES (3934, 'test01', 49, 12, 0, 1020755, 1020755, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:36:48');
INSERT INTO `userscoresnapshotledger` VALUES (3935, 'test01', 49, 12, 0, 1020655, 1020655, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:19');
INSERT INTO `userscoresnapshotledger` VALUES (3936, 'test01', 49, 12, 0, 1020555, 1020555, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:20');
INSERT INTO `userscoresnapshotledger` VALUES (3937, 'test01', 49, 12, 0, 1020455, 1020455, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:20');
INSERT INTO `userscoresnapshotledger` VALUES (3938, 'test01', 49, 12, 0, 1020355, 1020355, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:21');
INSERT INTO `userscoresnapshotledger` VALUES (3939, 'test01', 49, 12, 0, 1020255, 1020255, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:21');
INSERT INTO `userscoresnapshotledger` VALUES (3940, 'test01', 49, 12, 0, 1020155, 1020155, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:21');
INSERT INTO `userscoresnapshotledger` VALUES (3941, 'test01', 49, 12, 0, 1020055, 1020055, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:22');
INSERT INTO `userscoresnapshotledger` VALUES (3942, 'test01', 49, 12, 0, 1019955, 1019955, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:22');
INSERT INTO `userscoresnapshotledger` VALUES (3943, 'test01', 49, 12, 0, 1019855, 1019855, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:22');
INSERT INTO `userscoresnapshotledger` VALUES (3944, 'test01', 49, 12, 0, 1019755, 1019755, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:22');
INSERT INTO `userscoresnapshotledger` VALUES (3945, 'test01', 49, 12, 0, 1019655, 1019655, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:22');
INSERT INTO `userscoresnapshotledger` VALUES (3946, 'test01', 49, 12, 0, 1019555, 1019555, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:23');
INSERT INTO `userscoresnapshotledger` VALUES (3947, 'test01', 49, 12, 0, 1019455, 1019455, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:28');
INSERT INTO `userscoresnapshotledger` VALUES (3948, 'test01', 49, 12, 0, 1019355, 1019355, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:28');
INSERT INTO `userscoresnapshotledger` VALUES (3949, 'test01', 49, 12, 0, 1019255, 1019255, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:28');
INSERT INTO `userscoresnapshotledger` VALUES (3950, 'test01', 49, 12, 0, 1019155, 1019155, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:28');
INSERT INTO `userscoresnapshotledger` VALUES (3951, 'test01', 49, 12, 0, 1019055, 1019055, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:28');
INSERT INTO `userscoresnapshotledger` VALUES (3952, 'test01', 49, 12, 0, 1018955, 1018955, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:29');
INSERT INTO `userscoresnapshotledger` VALUES (3953, 'test01', 49, 12, 0, 1018855, 1018855, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:29');
INSERT INTO `userscoresnapshotledger` VALUES (3954, 'test01', 49, 12, 0, 1018755, 1018755, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:29');
INSERT INTO `userscoresnapshotledger` VALUES (3955, 'test01', 49, 12, 0, 1018955, 1018955, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:29');
INSERT INTO `userscoresnapshotledger` VALUES (3956, 'test01', 49, 12, 0, 1018855, 1018855, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:29');
INSERT INTO `userscoresnapshotledger` VALUES (3957, 'test01', 49, 12, 0, 1018755, 1018755, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:31');
INSERT INTO `userscoresnapshotledger` VALUES (3958, 'test01', 49, 12, 0, 1018655, 1018655, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:31');
INSERT INTO `userscoresnapshotledger` VALUES (3959, 'test01', 49, 12, 0, 1018555, 1018555, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:31');
INSERT INTO `userscoresnapshotledger` VALUES (3960, 'test01', 49, 12, 0, 1018455, 1018455, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:34');
INSERT INTO `userscoresnapshotledger` VALUES (3961, 'test01', 49, 12, 0, 1018355, 1018355, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:34');
INSERT INTO `userscoresnapshotledger` VALUES (3962, 'test01', 49, 12, 0, 1018255, 1018255, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:35');
INSERT INTO `userscoresnapshotledger` VALUES (3963, 'test01', 49, 12, 0, 1018155, 1018155, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:35');
INSERT INTO `userscoresnapshotledger` VALUES (3964, 'test01', 49, 12, 0, 1018055, 1018055, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:35');
INSERT INTO `userscoresnapshotledger` VALUES (3965, 'test01', 49, 12, 0, 1017955, 1017955, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:38');
INSERT INTO `userscoresnapshotledger` VALUES (3966, 'test01', 49, 12, 0, 1017855, 1017855, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:39');
INSERT INTO `userscoresnapshotledger` VALUES (3967, 'test01', 49, 12, 0, 1017755, 1017755, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:39');
INSERT INTO `userscoresnapshotledger` VALUES (3968, 'test01', 49, 12, 0, 1017655, 1017655, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:39');
INSERT INTO `userscoresnapshotledger` VALUES (3969, 'test01', 49, 12, 0, 1017555, 1017555, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:40');
INSERT INTO `userscoresnapshotledger` VALUES (3970, 'test01', 49, 12, 0, 1017455, 1017455, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:40');
INSERT INTO `userscoresnapshotledger` VALUES (3971, 'test01', 49, 12, 0, 1017355, 1017355, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:40');
INSERT INTO `userscoresnapshotledger` VALUES (3972, 'test01', 49, 12, 0, 1017255, 1017255, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:40');
INSERT INTO `userscoresnapshotledger` VALUES (3973, 'test01', 49, 12, 0, 1017155, 1017155, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:40');
INSERT INTO `userscoresnapshotledger` VALUES (3974, 'test01', 49, 12, 0, 1017055, 1017055, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:40');
INSERT INTO `userscoresnapshotledger` VALUES (3975, 'test01', 49, 12, 0, 1016955, 1016955, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:40');
INSERT INTO `userscoresnapshotledger` VALUES (3976, 'test01', 49, 12, 0, 1016855, 1016855, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:40');
INSERT INTO `userscoresnapshotledger` VALUES (3977, 'test01', 49, 12, 0, 1016755, 1016755, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:40');
INSERT INTO `userscoresnapshotledger` VALUES (3978, 'test01', 49, 12, 0, 1016655, 1016655, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:40');
INSERT INTO `userscoresnapshotledger` VALUES (3979, 'test01', 49, 12, 0, 1016555, 1016555, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:40');
INSERT INTO `userscoresnapshotledger` VALUES (3980, 'test01', 49, 12, 0, 1016455, 1016455, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:41');
INSERT INTO `userscoresnapshotledger` VALUES (3981, 'test01', 49, 12, 0, 1016355, 1016355, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:41');
INSERT INTO `userscoresnapshotledger` VALUES (3982, 'test01', 49, 12, 0, 1016255, 1016255, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:41');
INSERT INTO `userscoresnapshotledger` VALUES (3983, 'test01', 49, 12, 0, 1019255, 1019255, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:41');
INSERT INTO `userscoresnapshotledger` VALUES (3984, 'test01', 49, 12, 0, 1019155, 1019155, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:41');
INSERT INTO `userscoresnapshotledger` VALUES (3985, 'test01', 49, 12, 0, 1019055, 1019055, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:41');
INSERT INTO `userscoresnapshotledger` VALUES (3986, 'test01', 49, 12, 0, 1018955, 1018955, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:41');
INSERT INTO `userscoresnapshotledger` VALUES (3987, 'test01', 49, 12, 1018955, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:37:44');
INSERT INTO `userscoresnapshotledger` VALUES (3988, 'test01', 16, 14, 1018957, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:38:32');
INSERT INTO `userscoresnapshotledger` VALUES (3989, 'test01', 16, 14, 1018981, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:38:39');
INSERT INTO `userscoresnapshotledger` VALUES (3990, 'test01', 16, 14, 1018963, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:38:47');
INSERT INTO `userscoresnapshotledger` VALUES (3991, 'test01', 16, 14, 1018963, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:40:09');
INSERT INTO `userscoresnapshotledger` VALUES (3992, 'test01', 16, 14, 1018963, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:40:09');
INSERT INTO `userscoresnapshotledger` VALUES (3993, 'test01', 54, 0, 1018963, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 11:40:09');
INSERT INTO `userscoresnapshotledger` VALUES (3994, 'test002', 0, 15, 88290, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:57:26');
INSERT INTO `userscoresnapshotledger` VALUES (3995, 'test01', 0, 14, 1018963, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 11:57:26');
INSERT INTO `userscoresnapshotledger` VALUES (3996, 'test01', 54, 0, 1018963, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 14:01:41');
INSERT INTO `userscoresnapshotledger` VALUES (3997, 'test01', 40, 14, 1018963, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 14:03:12');
INSERT INTO `userscoresnapshotledger` VALUES (3998, 'test01', 54, 0, 1018963, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 14:03:12');
INSERT INTO `userscoresnapshotledger` VALUES (3999, 'test01', 40, 15, 1018963, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 14:03:16');
INSERT INTO `userscoresnapshotledger` VALUES (4000, 'test01', 16, 19, 1018963, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 14:04:07');
INSERT INTO `userscoresnapshotledger` VALUES (4001, 'test01', 54, 0, 1018963, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 14:04:07');
INSERT INTO `userscoresnapshotledger` VALUES (4002, 'test01', 16, 21, 1018993, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 14:04:29');
INSERT INTO `userscoresnapshotledger` VALUES (4003, 'test01', 16, 21, 1018995, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 14:04:37');
INSERT INTO `userscoresnapshotledger` VALUES (4004, 'test01', 16, 21, 1018995, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 14:04:44');
INSERT INTO `userscoresnapshotledger` VALUES (4005, 'test01', 16, 21, 1018995, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 14:04:44');
INSERT INTO `userscoresnapshotledger` VALUES (4006, 'test01', 54, 0, 1018995, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 14:04:44');
INSERT INTO `userscoresnapshotledger` VALUES (4007, 'test01', 40, 26, 1018995, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 14:09:55');
INSERT INTO `userscoresnapshotledger` VALUES (4008, 'test01', 54, 0, 1018995, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 14:09:55');
INSERT INTO `userscoresnapshotledger` VALUES (4009, 'test01', 40, 27, 1018995, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 14:09:57');
INSERT INTO `userscoresnapshotledger` VALUES (4010, 'test01', 16, 29, 1018979, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 14:10:09');
INSERT INTO `userscoresnapshotledger` VALUES (4011, 'test01', 16, 29, 1018979, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 14:10:26');
INSERT INTO `userscoresnapshotledger` VALUES (4012, 'test01', 16, 29, 1018979, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 14:10:26');
INSERT INTO `userscoresnapshotledger` VALUES (4013, 'test01', 54, 0, 1018979, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 14:10:26');
INSERT INTO `userscoresnapshotledger` VALUES (4014, 'test002', 0, 1, 88290, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 14:21:49');
INSERT INTO `userscoresnapshotledger` VALUES (4015, 'test01', 0, 33, 1018979, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 14:21:49');
INSERT INTO `userscoresnapshotledger` VALUES (4016, 'test01', 0, 1, 1018979, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 15:07:42');
INSERT INTO `userscoresnapshotledger` VALUES (4017, 'test01', 16, 2, 1018979, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 16:06:04');
INSERT INTO `userscoresnapshotledger` VALUES (4018, 'test01', 54, 0, 1018979, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 16:06:04');
INSERT INTO `userscoresnapshotledger` VALUES (4019, 'test01', 53, 7, 1018979, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 16:08:00');
INSERT INTO `userscoresnapshotledger` VALUES (4020, 'test01', 54, 0, 1018979, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 16:08:00');
INSERT INTO `userscoresnapshotledger` VALUES (4021, 'test01', 0, 17, 1018979, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 16:13:00');
INSERT INTO `userscoresnapshotledger` VALUES (4022, 'test01', 0, 4, 1018979, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 16:26:24');
INSERT INTO `userscoresnapshotledger` VALUES (4023, 'test01', 16, 11, 1018939, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 16:29:05');
INSERT INTO `userscoresnapshotledger` VALUES (4024, 'test01', 16, 11, 1018939, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 16:29:22');
INSERT INTO `userscoresnapshotledger` VALUES (4025, 'test01', 16, 11, 1018939, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 16:29:22');
INSERT INTO `userscoresnapshotledger` VALUES (4026, 'test01', 54, 0, 1018939, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 16:29:22');
INSERT INTO `userscoresnapshotledger` VALUES (4027, 'test01', 16, 13, 1018939, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 16:29:34');
INSERT INTO `userscoresnapshotledger` VALUES (4028, 'test01', 54, 0, 1018939, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 16:29:34');
INSERT INTO `userscoresnapshotledger` VALUES (4029, 'test01', 16, 15, 1018927, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 16:29:51');
INSERT INTO `userscoresnapshotledger` VALUES (4030, 'test01', 16, 15, 1018975, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 16:29:58');
INSERT INTO `userscoresnapshotledger` VALUES (4031, 'test01', 16, 15, 1018975, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 16:30:45');
INSERT INTO `userscoresnapshotledger` VALUES (4032, 'test01', 16, 15, 1018975, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 16:30:45');
INSERT INTO `userscoresnapshotledger` VALUES (4033, 'test01', 54, 0, 1018975, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 16:30:45');
INSERT INTO `userscoresnapshotledger` VALUES (4034, 'test01', 53, 18, 1018966, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 16:31:26');
INSERT INTO `userscoresnapshotledger` VALUES (4035, 'test01', 53, 18, 1018966, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 16:31:29');
INSERT INTO `userscoresnapshotledger` VALUES (4036, 'test01', 16, 20, 1018958, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 16:31:36');
INSERT INTO `userscoresnapshotledger` VALUES (4037, 'test01', 16, 20, 1018958, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 16:31:50');
INSERT INTO `userscoresnapshotledger` VALUES (4038, 'test01', 16, 20, 1018958, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 16:31:50');
INSERT INTO `userscoresnapshotledger` VALUES (4039, 'test01', 54, 0, 1018958, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 16:31:50');
INSERT INTO `userscoresnapshotledger` VALUES (4040, 'test01', 40, 22, 1018958, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 16:31:58');
INSERT INTO `userscoresnapshotledger` VALUES (4041, 'test01', 54, 0, 1018958, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 16:31:58');
INSERT INTO `userscoresnapshotledger` VALUES (4042, 'test01', 40, 23, 1018990, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 16:32:04');
INSERT INTO `userscoresnapshotledger` VALUES (4043, 'test01', 40, 23, 1018990, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 16:32:07');
INSERT INTO `userscoresnapshotledger` VALUES (4044, 'test01', 53, 3, 1018990, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 16:47:13');
INSERT INTO `userscoresnapshotledger` VALUES (4045, 'test01', 54, 0, 1018990, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 16:47:13');
INSERT INTO `userscoresnapshotledger` VALUES (4046, 'test01', 16, 11, 1018990, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 16:48:12');
INSERT INTO `userscoresnapshotledger` VALUES (4047, 'test01', 54, 0, 1018990, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 16:48:13');
INSERT INTO `userscoresnapshotledger` VALUES (4048, 'test01', 0, 15, 1018990, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 17:17:06');
INSERT INTO `userscoresnapshotledger` VALUES (4049, 'test01', 16, 4, 1018990, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 17:26:11');
INSERT INTO `userscoresnapshotledger` VALUES (4050, 'test01', 54, 0, 1018990, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 17:26:11');
INSERT INTO `userscoresnapshotledger` VALUES (4051, 'test01', 53, 7, 1018981, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 17:55:47');
INSERT INTO `userscoresnapshotledger` VALUES (4052, 'test01', 53, 7, 1018921, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 17:55:50');
INSERT INTO `userscoresnapshotledger` VALUES (4053, 'test01', 53, 7, 1018921, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 17:55:52');
INSERT INTO `userscoresnapshotledger` VALUES (4054, 'test01', 40, 9, 1018921, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 17:55:58');
INSERT INTO `userscoresnapshotledger` VALUES (4055, 'test01', 54, 0, 1018921, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 17:55:58');
INSERT INTO `userscoresnapshotledger` VALUES (4056, 'test01', 40, 10, 1019033, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 17:56:00');
INSERT INTO `userscoresnapshotledger` VALUES (4057, 'test01', 40, 10, 1019065, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 17:56:11');
INSERT INTO `userscoresnapshotledger` VALUES (4058, 'test01', 40, 10, 1019065, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 17:56:29');
INSERT INTO `userscoresnapshotledger` VALUES (4059, 'test01', 16, 12, 1019071, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 17:56:38');
INSERT INTO `userscoresnapshotledger` VALUES (4060, 'test01', 16, 12, 1019031, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 17:56:47');
INSERT INTO `userscoresnapshotledger` VALUES (4061, 'test01', 16, 12, 1019031, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 17:56:54');
INSERT INTO `userscoresnapshotledger` VALUES (4062, 'test01', 16, 12, 1019031, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 17:56:54');
INSERT INTO `userscoresnapshotledger` VALUES (4063, 'test01', 54, 0, 1019031, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 17:56:54');
INSERT INTO `userscoresnapshotledger` VALUES (4064, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:05:53');
INSERT INTO `userscoresnapshotledger` VALUES (4065, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:05:58');
INSERT INTO `userscoresnapshotledger` VALUES (4066, 'test01', 54, 0, 1019031, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:06:56');
INSERT INTO `userscoresnapshotledger` VALUES (4067, 'test01', 54, 0, 1019031, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:07:02');
INSERT INTO `userscoresnapshotledger` VALUES (4068, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:08:37');
INSERT INTO `userscoresnapshotledger` VALUES (4069, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:08:41');
INSERT INTO `userscoresnapshotledger` VALUES (4070, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:08:44');
INSERT INTO `userscoresnapshotledger` VALUES (4071, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:08:48');
INSERT INTO `userscoresnapshotledger` VALUES (4072, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:08:58');
INSERT INTO `userscoresnapshotledger` VALUES (4073, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:09:02');
INSERT INTO `userscoresnapshotledger` VALUES (4074, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:09:05');
INSERT INTO `userscoresnapshotledger` VALUES (4075, 'test01', 54, 0, 1019031, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:09:26');
INSERT INTO `userscoresnapshotledger` VALUES (4076, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:09:51');
INSERT INTO `userscoresnapshotledger` VALUES (4077, 'test002', 54, 0, 88290, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:10:00');
INSERT INTO `userscoresnapshotledger` VALUES (4078, 'test01', 49, 50, 0, 1019031, 1019031, 0, 'SNAPSHOT_SAVE', '2026-07-13 18:10:23');
INSERT INTO `userscoresnapshotledger` VALUES (4079, 'test01', 49, 50, 0, 1018931, 1018931, 0, 'SNAPSHOT_SAVE', '2026-07-13 18:10:29');
INSERT INTO `userscoresnapshotledger` VALUES (4080, 'test01', 49, 50, 0, 1018831, 1018831, 0, 'SNAPSHOT_SAVE', '2026-07-13 18:10:29');
INSERT INTO `userscoresnapshotledger` VALUES (4081, 'test01', 49, 50, 0, 1018731, 1018731, 0, 'SNAPSHOT_SAVE', '2026-07-13 18:10:29');
INSERT INTO `userscoresnapshotledger` VALUES (4082, 'test01', 49, 50, 0, 1018631, 1018631, 0, 'SNAPSHOT_SAVE', '2026-07-13 18:10:29');
INSERT INTO `userscoresnapshotledger` VALUES (4083, 'test01', 49, 50, 0, 1018531, 1018531, 0, 'SNAPSHOT_SAVE', '2026-07-13 18:10:30');
INSERT INTO `userscoresnapshotledger` VALUES (4084, 'test01', 49, 50, 1018531, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 18:10:33');
INSERT INTO `userscoresnapshotledger` VALUES (4085, 'test01', 49, 50, 1018531, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 18:10:34');
INSERT INTO `userscoresnapshotledger` VALUES (4086, 'test01', 49, 50, 1018531, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 18:10:34');
INSERT INTO `userscoresnapshotledger` VALUES (4087, 'test01', 54, 0, 1018531, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:10:35');
INSERT INTO `userscoresnapshotledger` VALUES (4088, 'test01', 54, 0, 1018531, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:10:51');
INSERT INTO `userscoresnapshotledger` VALUES (4089, 'test01', 54, 0, 1018531, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:11:31');
INSERT INTO `userscoresnapshotledger` VALUES (4090, 'test01', 49, 57, 0, 1018531, 1018531, 0, 'SNAPSHOT_SAVE', '2026-07-13 18:11:35');
INSERT INTO `userscoresnapshotledger` VALUES (4091, 'test01', 49, 57, 1018531, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 18:11:39');
INSERT INTO `userscoresnapshotledger` VALUES (4092, 'test01', 49, 57, 1018531, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 18:11:40');
INSERT INTO `userscoresnapshotledger` VALUES (4093, 'test01', 49, 57, 1018531, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 18:11:40');
INSERT INTO `userscoresnapshotledger` VALUES (4094, 'test01', 54, 0, 1018531, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:11:41');
INSERT INTO `userscoresnapshotledger` VALUES (4095, 'test01', 54, 0, 1018531, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:11:46');
INSERT INTO `userscoresnapshotledger` VALUES (4096, 'test01', 54, 0, 1018531, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:11:54');
INSERT INTO `userscoresnapshotledger` VALUES (4097, 'test01', 54, 0, 1018531, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:12:06');
INSERT INTO `userscoresnapshotledger` VALUES (4098, 'test01', 54, 0, 1018531, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:12:11');
INSERT INTO `userscoresnapshotledger` VALUES (4099, 'test01', 54, 0, 1018531, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:12:17');
INSERT INTO `userscoresnapshotledger` VALUES (4100, 'test01', 54, 0, 1018531, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:12:25');
INSERT INTO `userscoresnapshotledger` VALUES (4101, 'test01', 54, 0, 1018531, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:12:30');
INSERT INTO `userscoresnapshotledger` VALUES (4102, 'test01', 54, 0, 1018531, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-13 18:12:34');
INSERT INTO `userscoresnapshotledger` VALUES (4103, 'test002', 0, 49, 88290, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 18:57:44');
INSERT INTO `userscoresnapshotledger` VALUES (4104, 'test01', 0, 77, 1018531, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-13 18:57:44');
INSERT INTO `userscoresnapshotledger` VALUES (4105, 'test002', 19, 2, 0, 88290, 88290, 0, 'SNAPSHOT_SAVE', '2026-07-14 10:40:22');
INSERT INTO `userscoresnapshotledger` VALUES (4106, 'test002', 19, 2, 0, 88190, 88190, 0, 'SNAPSHOT_SAVE', '2026-07-14 10:40:27');
INSERT INTO `userscoresnapshotledger` VALUES (4107, 'test002', 19, 2, 0, 88090, 88090, 0, 'SNAPSHOT_SAVE', '2026-07-14 10:40:28');
INSERT INTO `userscoresnapshotledger` VALUES (4108, 'test002', 19, 2, 0, 87990, 87990, 0, 'SNAPSHOT_SAVE', '2026-07-14 10:40:28');
INSERT INTO `userscoresnapshotledger` VALUES (4109, 'test002', 19, 2, 87990, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 10:43:30');
INSERT INTO `userscoresnapshotledger` VALUES (4110, 'test002', 19, 3, 87990, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 10:43:55');
INSERT INTO `userscoresnapshotledger` VALUES (4111, 'test01', 47, 2, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 14:05:01');
INSERT INTO `userscoresnapshotledger` VALUES (4112, 'test01', 47, 2, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 14:05:14');
INSERT INTO `userscoresnapshotledger` VALUES (4113, 'test01', 47, 2, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 14:05:33');
INSERT INTO `userscoresnapshotledger` VALUES (4114, 'test01', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 14:05:38');
INSERT INTO `userscoresnapshotledger` VALUES (4115, 'test01', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 14:15:23');
INSERT INTO `userscoresnapshotledger` VALUES (4116, 'test01', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 14:15:41');
INSERT INTO `userscoresnapshotledger` VALUES (4117, 'test01', 0, 8, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 14:20:38');
INSERT INTO `userscoresnapshotledger` VALUES (4118, 'test01', 47, 2, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 14:41:19');
INSERT INTO `userscoresnapshotledger` VALUES (4119, 'test01', 47, 2, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 14:41:26');
INSERT INTO `userscoresnapshotledger` VALUES (4120, 'test01', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 14:41:55');
INSERT INTO `userscoresnapshotledger` VALUES (4121, 'test01', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 14:45:10');
INSERT INTO `userscoresnapshotledger` VALUES (4122, 'test01', 0, 11, 455564, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 14:58:50');
INSERT INTO `userscoresnapshotledger` VALUES (4123, 'test01', 54, 0, 455564, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 15:42:50');
INSERT INTO `userscoresnapshotledger` VALUES (4124, 'test01', 54, 0, 455564, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 15:43:07');
INSERT INTO `userscoresnapshotledger` VALUES (4125, 'test01', 54, 0, 455564, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 15:43:23');
INSERT INTO `userscoresnapshotledger` VALUES (4126, 'test01', 54, 0, 455564, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 15:43:36');
INSERT INTO `userscoresnapshotledger` VALUES (4127, 'test002', 54, 0, 87990, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 15:45:27');
INSERT INTO `userscoresnapshotledger` VALUES (4128, 'test002', 54, 0, 87990, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 15:45:39');
INSERT INTO `userscoresnapshotledger` VALUES (4129, 'test002', 54, 0, 87990, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 15:45:43');
INSERT INTO `userscoresnapshotledger` VALUES (4130, 'test002', 54, 0, 87990, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 15:45:46');
INSERT INTO `userscoresnapshotledger` VALUES (4131, 'test002', 54, 0, 87990, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 15:45:49');
INSERT INTO `userscoresnapshotledger` VALUES (4132, 'test002', 54, 0, 87990, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 15:47:37');
INSERT INTO `userscoresnapshotledger` VALUES (4133, 'test002', 0, 23, 87990, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 15:49:21');
INSERT INTO `userscoresnapshotledger` VALUES (4134, 'test01', 0, 9, 455564, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 15:49:21');
INSERT INTO `userscoresnapshotledger` VALUES (4135, 'test002', 53, 3, 87990, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:10:46');
INSERT INTO `userscoresnapshotledger` VALUES (4136, 'test002', 54, 0, 87990, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:10:54');
INSERT INTO `userscoresnapshotledger` VALUES (4137, 'test002', 54, 0, 87990, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:10:57');
INSERT INTO `userscoresnapshotledger` VALUES (4138, 'test002', 54, 0, 87990, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:11:00');
INSERT INTO `userscoresnapshotledger` VALUES (4139, 'test002', 54, 0, 87990, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:11:04');
INSERT INTO `userscoresnapshotledger` VALUES (4140, 'test002', 54, 0, 87990, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:11:08');
INSERT INTO `userscoresnapshotledger` VALUES (4141, 'test002', 54, 0, 87990, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:11:48');
INSERT INTO `userscoresnapshotledger` VALUES (4142, 'test01', 54, 0, 455564, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:12:34');
INSERT INTO `userscoresnapshotledger` VALUES (4143, 'test01', 54, 0, 455564, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:12:38');
INSERT INTO `userscoresnapshotledger` VALUES (4144, 'test01', 54, 0, 455564, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:12:41');
INSERT INTO `userscoresnapshotledger` VALUES (4145, 'test01', 54, 0, 455564, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:12:53');
INSERT INTO `userscoresnapshotledger` VALUES (4146, 'test01', 6, 26, 0, 455564, 455564, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:12:57');
INSERT INTO `userscoresnapshotledger` VALUES (4147, 'test01', 6, 26, 0, 455464, 455464, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:00');
INSERT INTO `userscoresnapshotledger` VALUES (4148, 'test01', 6, 26, 0, 455364, 455364, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:01');
INSERT INTO `userscoresnapshotledger` VALUES (4149, 'test01', 6, 26, 0, 455264, 455264, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:02');
INSERT INTO `userscoresnapshotledger` VALUES (4150, 'test01', 6, 26, 0, 455164, 455164, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:02');
INSERT INTO `userscoresnapshotledger` VALUES (4151, 'test01', 6, 26, 0, 455064, 455064, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:04');
INSERT INTO `userscoresnapshotledger` VALUES (4152, 'test01', 6, 26, 0, 454964, 454964, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:05');
INSERT INTO `userscoresnapshotledger` VALUES (4153, 'test01', 6, 26, 0, 454864, 454864, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:08');
INSERT INTO `userscoresnapshotledger` VALUES (4154, 'test01', 6, 26, 0, 454764, 454764, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:08');
INSERT INTO `userscoresnapshotledger` VALUES (4155, 'test01', 6, 26, 0, 454664, 454664, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:09');
INSERT INTO `userscoresnapshotledger` VALUES (4156, 'test01', 6, 26, 0, 454564, 454564, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:09');
INSERT INTO `userscoresnapshotledger` VALUES (4157, 'test01', 6, 26, 0, 454464, 454464, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:09');
INSERT INTO `userscoresnapshotledger` VALUES (4158, 'test01', 6, 26, 0, 454364, 454364, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:09');
INSERT INTO `userscoresnapshotledger` VALUES (4159, 'test01', 6, 26, 0, 454264, 454264, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:09');
INSERT INTO `userscoresnapshotledger` VALUES (4160, 'test01', 6, 26, 0, 454164, 454164, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:10');
INSERT INTO `userscoresnapshotledger` VALUES (4161, 'test01', 6, 26, 0, 454064, 454064, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:10');
INSERT INTO `userscoresnapshotledger` VALUES (4162, 'test01', 6, 26, 0, 453964, 453964, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:10');
INSERT INTO `userscoresnapshotledger` VALUES (4163, 'test01', 6, 26, 0, 453864, 453864, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:10');
INSERT INTO `userscoresnapshotledger` VALUES (4164, 'test01', 6, 26, 0, 453764, 453764, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:10');
INSERT INTO `userscoresnapshotledger` VALUES (4165, 'test01', 6, 26, 0, 453664, 453664, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:10');
INSERT INTO `userscoresnapshotledger` VALUES (4166, 'test01', 6, 26, 0, 453564, 453564, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:11');
INSERT INTO `userscoresnapshotledger` VALUES (4167, 'test01', 6, 26, 0, 453464, 453464, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:11');
INSERT INTO `userscoresnapshotledger` VALUES (4168, 'test01', 6, 26, 0, 453364, 453364, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:11');
INSERT INTO `userscoresnapshotledger` VALUES (4169, 'test01', 6, 26, 0, 453264, 453264, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:11');
INSERT INTO `userscoresnapshotledger` VALUES (4170, 'test01', 6, 26, 0, 453164, 453164, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:12');
INSERT INTO `userscoresnapshotledger` VALUES (4171, 'test01', 6, 26, 0, 453064, 453064, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:12');
INSERT INTO `userscoresnapshotledger` VALUES (4172, 'test01', 6, 26, 0, 452964, 452964, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:12');
INSERT INTO `userscoresnapshotledger` VALUES (4173, 'test01', 6, 26, 0, 452864, 452864, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:13');
INSERT INTO `userscoresnapshotledger` VALUES (4174, 'test01', 6, 26, 0, 452764, 452764, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:13');
INSERT INTO `userscoresnapshotledger` VALUES (4175, 'test01', 6, 26, 0, 452664, 452664, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:13');
INSERT INTO `userscoresnapshotledger` VALUES (4176, 'test01', 6, 26, 0, 452564, 452564, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:13');
INSERT INTO `userscoresnapshotledger` VALUES (4177, 'test01', 6, 26, 0, 452464, 452464, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:13');
INSERT INTO `userscoresnapshotledger` VALUES (4178, 'test01', 6, 26, 0, 452364, 452364, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:13');
INSERT INTO `userscoresnapshotledger` VALUES (4179, 'test01', 6, 26, 0, 452264, 452264, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:14');
INSERT INTO `userscoresnapshotledger` VALUES (4180, 'test01', 6, 26, 0, 452164, 452164, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:16');
INSERT INTO `userscoresnapshotledger` VALUES (4181, 'test01', 6, 26, 0, 452064, 452064, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:17');
INSERT INTO `userscoresnapshotledger` VALUES (4182, 'test01', 6, 26, 0, 451964, 451964, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:17');
INSERT INTO `userscoresnapshotledger` VALUES (4183, 'test01', 6, 26, 0, 451864, 451864, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:17');
INSERT INTO `userscoresnapshotledger` VALUES (4184, 'test01', 6, 26, 0, 451764, 451764, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:17');
INSERT INTO `userscoresnapshotledger` VALUES (4185, 'test01', 6, 26, 0, 451664, 451664, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:18');
INSERT INTO `userscoresnapshotledger` VALUES (4186, 'test01', 6, 26, 0, 451564, 451564, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:18');
INSERT INTO `userscoresnapshotledger` VALUES (4187, 'test01', 6, 26, 0, 451464, 451464, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:18');
INSERT INTO `userscoresnapshotledger` VALUES (4188, 'test01', 6, 26, 0, 451364, 451364, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:18');
INSERT INTO `userscoresnapshotledger` VALUES (4189, 'test01', 6, 26, 0, 451264, 451264, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:18');
INSERT INTO `userscoresnapshotledger` VALUES (4190, 'test01', 6, 26, 0, 451164, 451164, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:19');
INSERT INTO `userscoresnapshotledger` VALUES (4191, 'test01', 6, 26, 0, 451064, 451064, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:19');
INSERT INTO `userscoresnapshotledger` VALUES (4192, 'test01', 6, 26, 0, 450964, 450964, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:19');
INSERT INTO `userscoresnapshotledger` VALUES (4193, 'test01', 6, 26, 0, 450864, 450864, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:19');
INSERT INTO `userscoresnapshotledger` VALUES (4194, 'test01', 6, 26, 0, 450764, 450764, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:19');
INSERT INTO `userscoresnapshotledger` VALUES (4195, 'test01', 6, 26, 0, 450664, 450664, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:20');
INSERT INTO `userscoresnapshotledger` VALUES (4196, 'test01', 6, 26, 0, 450564, 450564, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:20');
INSERT INTO `userscoresnapshotledger` VALUES (4197, 'test01', 6, 26, 0, 450464, 450464, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:20');
INSERT INTO `userscoresnapshotledger` VALUES (4198, 'test01', 6, 26, 0, 450364, 450364, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:20');
INSERT INTO `userscoresnapshotledger` VALUES (4199, 'test01', 6, 26, 0, 450264, 450264, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:20');
INSERT INTO `userscoresnapshotledger` VALUES (4200, 'test01', 6, 26, 0, 450164, 450164, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:21');
INSERT INTO `userscoresnapshotledger` VALUES (4201, 'test01', 6, 26, 0, 450064, 450064, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:21');
INSERT INTO `userscoresnapshotledger` VALUES (4202, 'test01', 6, 26, 0, 449964, 449964, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:21');
INSERT INTO `userscoresnapshotledger` VALUES (4203, 'test01', 6, 26, 0, 449864, 449864, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:21');
INSERT INTO `userscoresnapshotledger` VALUES (4204, 'test01', 6, 26, 0, 449764, 449764, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:21');
INSERT INTO `userscoresnapshotledger` VALUES (4205, 'test01', 6, 26, 0, 449664, 449664, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:22');
INSERT INTO `userscoresnapshotledger` VALUES (4206, 'test01', 6, 26, 0, 449564, 449564, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:22');
INSERT INTO `userscoresnapshotledger` VALUES (4207, 'test01', 6, 26, 0, 449464, 449464, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:22');
INSERT INTO `userscoresnapshotledger` VALUES (4208, 'test01', 6, 26, 0, 449364, 449364, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:22');
INSERT INTO `userscoresnapshotledger` VALUES (4209, 'test01', 6, 26, 0, 449264, 449264, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:22');
INSERT INTO `userscoresnapshotledger` VALUES (4210, 'test01', 6, 26, 0, 449164, 449164, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:23');
INSERT INTO `userscoresnapshotledger` VALUES (4211, 'test01', 6, 26, 0, 449064, 449064, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:23');
INSERT INTO `userscoresnapshotledger` VALUES (4212, 'test01', 6, 26, 0, 448964, 448964, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:24');
INSERT INTO `userscoresnapshotledger` VALUES (4213, 'test01', 6, 26, 0, 448864, 448864, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:25');
INSERT INTO `userscoresnapshotledger` VALUES (4214, 'test01', 6, 26, 0, 448764, 448764, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:25');
INSERT INTO `userscoresnapshotledger` VALUES (4215, 'test01', 6, 26, 0, 448664, 448664, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:26');
INSERT INTO `userscoresnapshotledger` VALUES (4216, 'test01', 6, 26, 0, 448564, 448564, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:26');
INSERT INTO `userscoresnapshotledger` VALUES (4217, 'test01', 6, 26, 0, 448464, 448464, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:26');
INSERT INTO `userscoresnapshotledger` VALUES (4218, 'test01', 6, 26, 0, 448364, 448364, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:26');
INSERT INTO `userscoresnapshotledger` VALUES (4219, 'test01', 6, 26, 0, 448264, 448264, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:27');
INSERT INTO `userscoresnapshotledger` VALUES (4220, 'test01', 6, 26, 0, 448164, 448164, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:27');
INSERT INTO `userscoresnapshotledger` VALUES (4221, 'test01', 6, 26, 0, 448064, 448064, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:27');
INSERT INTO `userscoresnapshotledger` VALUES (4222, 'test01', 6, 26, 0, 447964, 447964, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:27');
INSERT INTO `userscoresnapshotledger` VALUES (4223, 'test01', 6, 26, 0, 447864, 447864, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:27');
INSERT INTO `userscoresnapshotledger` VALUES (4224, 'test01', 6, 26, 0, 447764, 447764, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:28');
INSERT INTO `userscoresnapshotledger` VALUES (4225, 'test01', 6, 26, 0, 447664, 447664, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:28');
INSERT INTO `userscoresnapshotledger` VALUES (4226, 'test01', 6, 26, 0, 447564, 447564, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:28');
INSERT INTO `userscoresnapshotledger` VALUES (4227, 'test01', 6, 26, 0, 447464, 447464, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:28');
INSERT INTO `userscoresnapshotledger` VALUES (4228, 'test01', 6, 26, 0, 447364, 447364, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:28');
INSERT INTO `userscoresnapshotledger` VALUES (4229, 'test01', 6, 26, 0, 447264, 447264, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:29');
INSERT INTO `userscoresnapshotledger` VALUES (4230, 'test01', 6, 26, 0, 447164, 447164, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:29');
INSERT INTO `userscoresnapshotledger` VALUES (4231, 'test01', 6, 26, 0, 447064, 447064, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:29');
INSERT INTO `userscoresnapshotledger` VALUES (4232, 'test01', 6, 26, 0, 446964, 446964, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:29');
INSERT INTO `userscoresnapshotledger` VALUES (4233, 'test01', 6, 26, 0, 446864, 446864, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:29');
INSERT INTO `userscoresnapshotledger` VALUES (4234, 'test01', 6, 26, 0, 446764, 446764, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:30');
INSERT INTO `userscoresnapshotledger` VALUES (4235, 'test01', 6, 26, 0, 446664, 446664, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:31');
INSERT INTO `userscoresnapshotledger` VALUES (4236, 'test01', 6, 26, 0, 446564, 446564, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:31');
INSERT INTO `userscoresnapshotledger` VALUES (4237, 'test01', 6, 26, 0, 446464, 446464, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:31');
INSERT INTO `userscoresnapshotledger` VALUES (4238, 'test01', 6, 26, 0, 446364, 446364, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:32');
INSERT INTO `userscoresnapshotledger` VALUES (4239, 'test01', 6, 26, 0, 446264, 446264, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:32');
INSERT INTO `userscoresnapshotledger` VALUES (4240, 'test01', 6, 26, 0, 446164, 446164, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:32');
INSERT INTO `userscoresnapshotledger` VALUES (4241, 'test01', 6, 26, 0, 446064, 446064, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:32');
INSERT INTO `userscoresnapshotledger` VALUES (4242, 'test01', 6, 26, 0, 445964, 445964, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:33');
INSERT INTO `userscoresnapshotledger` VALUES (4243, 'test01', 6, 26, 0, 445864, 445864, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:33');
INSERT INTO `userscoresnapshotledger` VALUES (4244, 'test01', 6, 26, 445864, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:40');
INSERT INTO `userscoresnapshotledger` VALUES (4245, 'test01', 6, 26, 445864, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:41');
INSERT INTO `userscoresnapshotledger` VALUES (4246, 'test01', 6, 26, 445864, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:13:41');
INSERT INTO `userscoresnapshotledger` VALUES (4247, 'test01', 54, 0, 445864, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:13:42');
INSERT INTO `userscoresnapshotledger` VALUES (4248, 'test01', 54, 0, 445864, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:13:51');
INSERT INTO `userscoresnapshotledger` VALUES (4249, 'test01', 54, 0, 445864, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:13:54');
INSERT INTO `userscoresnapshotledger` VALUES (4250, 'test01', 47, 35, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:14:52');
INSERT INTO `userscoresnapshotledger` VALUES (4251, 'test01', 47, 35, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:14:54');
INSERT INTO `userscoresnapshotledger` VALUES (4252, 'test01', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:14:56');
INSERT INTO `userscoresnapshotledger` VALUES (4253, 'test01', 29, 38, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:15:16');
INSERT INTO `userscoresnapshotledger` VALUES (4254, 'test01', 29, 38, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:15:18');
INSERT INTO `userscoresnapshotledger` VALUES (4255, 'test01', 29, 39, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:15:19');
INSERT INTO `userscoresnapshotledger` VALUES (4256, 'test01', 29, 39, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:15:21');
INSERT INTO `userscoresnapshotledger` VALUES (4257, 'test01', 54, 0, 1415552, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:15:22');
INSERT INTO `userscoresnapshotledger` VALUES (4258, 'test01', 54, 0, 1415552, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:15:32');
INSERT INTO `userscoresnapshotledger` VALUES (4259, 'test01', 2, 44, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:15:37');
INSERT INTO `userscoresnapshotledger` VALUES (4260, 'test01', 2, 44, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:15:50');
INSERT INTO `userscoresnapshotledger` VALUES (4261, 'test01', 2, 44, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:15:51');
INSERT INTO `userscoresnapshotledger` VALUES (4262, 'test01', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:15:53');
INSERT INTO `userscoresnapshotledger` VALUES (4263, 'test01', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:15:59');
INSERT INTO `userscoresnapshotledger` VALUES (4264, 'test01', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:17:34');
INSERT INTO `userscoresnapshotledger` VALUES (4265, 'test002', 54, 0, 87990, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:17:37');
INSERT INTO `userscoresnapshotledger` VALUES (4266, 'test002', 54, 0, 87990, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:17:48');
INSERT INTO `userscoresnapshotledger` VALUES (4267, 'test01', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:17:52');
INSERT INTO `userscoresnapshotledger` VALUES (4268, 'test002', 2, 56, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:17:53');
INSERT INTO `userscoresnapshotledger` VALUES (4269, 'test002', 2, 56, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:17:58');
INSERT INTO `userscoresnapshotledger` VALUES (4270, 'test002', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:18:01');
INSERT INTO `userscoresnapshotledger` VALUES (4271, 'test002', 0, 59, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:18:19');
INSERT INTO `userscoresnapshotledger` VALUES (4272, 'test01', 0, 57, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:18:19');
INSERT INTO `userscoresnapshotledger` VALUES (4273, 'test01', 40, 11, 65621, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:40:27');
INSERT INTO `userscoresnapshotledger` VALUES (4274, 'test01', 53, 13, 65621, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:40:32');
INSERT INTO `userscoresnapshotledger` VALUES (4275, 'test01', 16, 14, 65621, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:49:44');
INSERT INTO `userscoresnapshotledger` VALUES (4276, 'test002', 16, 3, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:51:25');
INSERT INTO `userscoresnapshotledger` VALUES (4277, 'test002', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:51:26');
INSERT INTO `userscoresnapshotledger` VALUES (4278, 'test002', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:51:38');
INSERT INTO `userscoresnapshotledger` VALUES (4279, 'test002', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:51:41');
INSERT INTO `userscoresnapshotledger` VALUES (4280, 'test002', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:51:44');
INSERT INTO `userscoresnapshotledger` VALUES (4281, 'test002', 16, 13, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:51:47');
INSERT INTO `userscoresnapshotledger` VALUES (4282, 'test002', 40, 15, 0, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:51:50');
INSERT INTO `userscoresnapshotledger` VALUES (4283, 'test002', 54, 0, 0, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:51:53');
INSERT INTO `userscoresnapshotledger` VALUES (4284, 'test01', 16, 20, 65621, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:53:42');
INSERT INTO `userscoresnapshotledger` VALUES (4285, 'test002', 5, 21, 454564, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:56:01');
INSERT INTO `userscoresnapshotledger` VALUES (4286, 'test002', 14, 23, 454564, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:56:07');
INSERT INTO `userscoresnapshotledger` VALUES (4287, 'test01', 5, 25, 0, 65621, 65621, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:56:23');
INSERT INTO `userscoresnapshotledger` VALUES (4288, 'test01', 5, 25, 0, 65611, 65611, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:56:25');
INSERT INTO `userscoresnapshotledger` VALUES (4289, 'test01', 5, 25, 0, 65591, 65591, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:56:34');
INSERT INTO `userscoresnapshotledger` VALUES (4290, 'test01', 5, 25, 65591, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 17:56:40');
INSERT INTO `userscoresnapshotledger` VALUES (4291, 'test01', 54, 0, 65591, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-14 17:56:42');
INSERT INTO `userscoresnapshotledger` VALUES (4292, 'test002', 0, 24, 454564, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 18:28:06');
INSERT INTO `userscoresnapshotledger` VALUES (4293, 'test01', 0, 27, 65591, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-14 18:28:06');
INSERT INTO `userscoresnapshotledger` VALUES (4294, 'test01', 3, 2, 0, 65591, 65591, 0, 'SNAPSHOT_SAVE', '2026-07-15 14:05:04');
INSERT INTO `userscoresnapshotledger` VALUES (4295, 'test01', 3, 2, 0, 65491, 65491, 0, 'SNAPSHOT_SAVE', '2026-07-15 14:05:12');
INSERT INTO `userscoresnapshotledger` VALUES (4296, 'test01', 3, 2, 0, 65391, 65391, 0, 'SNAPSHOT_SAVE', '2026-07-15 14:05:12');
INSERT INTO `userscoresnapshotledger` VALUES (4297, 'test01', 3, 2, 0, 65291, 65291, 0, 'SNAPSHOT_SAVE', '2026-07-15 14:05:13');
INSERT INTO `userscoresnapshotledger` VALUES (4298, 'test01', 3, 2, 0, 65191, 65191, 0, 'SNAPSHOT_SAVE', '2026-07-15 14:05:14');
INSERT INTO `userscoresnapshotledger` VALUES (4299, 'test01', 3, 2, 0, 65091, 65091, 0, 'SNAPSHOT_SAVE', '2026-07-15 14:05:14');
INSERT INTO `userscoresnapshotledger` VALUES (4300, 'test01', 3, 2, 0, 64991, 64991, 0, 'SNAPSHOT_SAVE', '2026-07-15 14:05:15');
INSERT INTO `userscoresnapshotledger` VALUES (4301, 'test01', 3, 2, 0, 64891, 64891, 0, 'SNAPSHOT_SAVE', '2026-07-15 14:05:18');
INSERT INTO `userscoresnapshotledger` VALUES (4302, 'test01', 3, 2, 0, 64791, 64791, 0, 'SNAPSHOT_SAVE', '2026-07-15 14:05:18');
INSERT INTO `userscoresnapshotledger` VALUES (4303, 'test01', 3, 2, 0, 64691, 64691, 0, 'SNAPSHOT_SAVE', '2026-07-15 14:05:19');
INSERT INTO `userscoresnapshotledger` VALUES (4304, 'test01', 3, 2, 0, 65191, 65191, 0, 'SNAPSHOT_SAVE', '2026-07-15 14:05:20');
INSERT INTO `userscoresnapshotledger` VALUES (4305, 'test01', 3, 2, 0, 65091, 65091, 0, 'SNAPSHOT_SAVE', '2026-07-15 14:05:20');
INSERT INTO `userscoresnapshotledger` VALUES (4306, 'test01', 3, 2, 0, 64991, 64991, 0, 'SNAPSHOT_SAVE', '2026-07-15 14:05:20');
INSERT INTO `userscoresnapshotledger` VALUES (4307, 'test01', 3, 2, 0, 64891, 64891, 0, 'SNAPSHOT_SAVE', '2026-07-15 14:05:21');
INSERT INTO `userscoresnapshotledger` VALUES (4308, 'test01', 3, 2, 0, 64791, 64791, 0, 'SNAPSHOT_SAVE', '2026-07-15 14:05:21');
INSERT INTO `userscoresnapshotledger` VALUES (4309, 'test01', 3, 2, 0, 64691, 64691, 0, 'SNAPSHOT_SAVE', '2026-07-15 14:05:22');
INSERT INTO `userscoresnapshotledger` VALUES (4310, 'test01', 3, 2, 0, 64591, 64591, 0, 'SNAPSHOT_SAVE', '2026-07-15 14:05:22');
INSERT INTO `userscoresnapshotledger` VALUES (4311, 'test01', 3, 2, 0, 64491, 64491, 0, 'SNAPSHOT_SAVE', '2026-07-15 14:05:22');
INSERT INTO `userscoresnapshotledger` VALUES (4312, 'test01', 3, 2, 0, 64391, 64391, 0, 'SNAPSHOT_SAVE', '2026-07-15 14:05:23');
INSERT INTO `userscoresnapshotledger` VALUES (4313, 'test01', 3, 2, 0, 64291, 64291, 0, 'SNAPSHOT_SAVE', '2026-07-15 14:05:23');
INSERT INTO `userscoresnapshotledger` VALUES (4314, 'test01', 3, 2, 0, 64191, 64191, 0, 'SNAPSHOT_SAVE', '2026-07-15 14:05:24');
INSERT INTO `userscoresnapshotledger` VALUES (4315, 'test01', 3, 2, 64191, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 14:05:57');
INSERT INTO `userscoresnapshotledger` VALUES (4316, 'test01', 3, 2, 64191, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 14:06:01');
INSERT INTO `userscoresnapshotledger` VALUES (4317, 'test01', 54, 0, 64191, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 14:06:03');
INSERT INTO `userscoresnapshotledger` VALUES (4318, 'test01', 54, 0, 64191, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 14:06:13');
INSERT INTO `userscoresnapshotledger` VALUES (4319, 'test01', 0, 7, 64191, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 14:14:15');
INSERT INTO `userscoresnapshotledger` VALUES (4320, 'test01', 3, 2, 0, 64191, 64191, 0, 'SNAPSHOT_SAVE', '2026-07-15 16:35:54');
INSERT INTO `userscoresnapshotledger` VALUES (4321, 'test01', 3, 2, 64191, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 16:36:00');
INSERT INTO `userscoresnapshotledger` VALUES (4322, 'test01', 3, 2, 64191, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 16:36:01');
INSERT INTO `userscoresnapshotledger` VALUES (4323, 'test01', 3, 2, 64191, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 16:36:01');
INSERT INTO `userscoresnapshotledger` VALUES (4324, 'test01', 54, 0, 64191, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 16:36:02');
INSERT INTO `userscoresnapshotledger` VALUES (4325, 'test01', 2, 5, 0, 64191, 64191, 0, 'SNAPSHOT_SAVE', '2026-07-15 16:36:12');
INSERT INTO `userscoresnapshotledger` VALUES (4326, 'test01', 2, 5, 0, 64191, 64191, 0, 'SNAPSHOT_SAVE', '2026-07-15 16:36:26');
INSERT INTO `userscoresnapshotledger` VALUES (4327, 'test01', 2, 5, 64191, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 16:36:28');
INSERT INTO `userscoresnapshotledger` VALUES (4328, 'test01', 54, 0, 64191, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 16:36:29');
INSERT INTO `userscoresnapshotledger` VALUES (4329, 'test01', 54, 0, 64191, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 16:36:42');
INSERT INTO `userscoresnapshotledger` VALUES (4330, 'test01', 29, 10, 0, 64191, 64191, 0, 'SNAPSHOT_SAVE', '2026-07-15 16:36:50');
INSERT INTO `userscoresnapshotledger` VALUES (4331, 'test01', 29, 10, 0, 64191, 64191, 0, 'SNAPSHOT_SAVE', '2026-07-15 16:37:04');
INSERT INTO `userscoresnapshotledger` VALUES (4332, 'test01', 29, 10, 64191, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 16:37:19');
INSERT INTO `userscoresnapshotledger` VALUES (4333, 'test01', 54, 0, 64191, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 16:37:20');
INSERT INTO `userscoresnapshotledger` VALUES (4334, 'test01', 53, 14, 64191, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 16:37:58');
INSERT INTO `userscoresnapshotledger` VALUES (4335, 'test01', 54, 0, 64191, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 16:39:04');
INSERT INTO `userscoresnapshotledger` VALUES (4336, 'test01', 54, 0, 64191, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 16:39:12');
INSERT INTO `userscoresnapshotledger` VALUES (4337, 'test01', 54, 0, 64191, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 16:40:09');
INSERT INTO `userscoresnapshotledger` VALUES (4338, 'test01', 54, 0, 64191, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 16:40:16');
INSERT INTO `userscoresnapshotledger` VALUES (4339, 'test01', 19, 23, 0, 64191, 64191, 0, 'SNAPSHOT_SAVE', '2026-07-15 16:40:23');
INSERT INTO `userscoresnapshotledger` VALUES (4340, 'test01', 19, 23, 0, 63591, 63591, 0, 'SNAPSHOT_SAVE', '2026-07-15 16:42:25');
INSERT INTO `userscoresnapshotledger` VALUES (4341, 'test01', 19, 23, 63591, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 16:42:27');
INSERT INTO `userscoresnapshotledger` VALUES (4342, 'test01', 19, 23, 63591, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 16:42:28');
INSERT INTO `userscoresnapshotledger` VALUES (4343, 'test01', 19, 23, 63591, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 16:42:28');
INSERT INTO `userscoresnapshotledger` VALUES (4344, 'test01', 54, 0, 63591, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 16:42:30');
INSERT INTO `userscoresnapshotledger` VALUES (4345, 'test01', 54, 0, 63591, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 16:42:49');
INSERT INTO `userscoresnapshotledger` VALUES (4346, 'test01', 40, 29, 63591, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 16:43:41');
INSERT INTO `userscoresnapshotledger` VALUES (4347, 'test01', 54, 0, 63591, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 16:43:49');
INSERT INTO `userscoresnapshotledger` VALUES (4348, 'test01', 54, 0, 63591, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 16:44:42');
INSERT INTO `userscoresnapshotledger` VALUES (4349, 'test01', 54, 0, 63591, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 17:04:42');
INSERT INTO `userscoresnapshotledger` VALUES (4350, 'test01', 54, 0, 63591, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 17:11:23');
INSERT INTO `userscoresnapshotledger` VALUES (4351, 'test01', 54, 0, 63591, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 17:11:55');
INSERT INTO `userscoresnapshotledger` VALUES (4352, 'test01', 0, 39, 63591, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 17:21:24');
INSERT INTO `userscoresnapshotledger` VALUES (4353, 'test01', 40, 2, 63591, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 17:36:47');
INSERT INTO `userscoresnapshotledger` VALUES (4354, 'test01', 54, 0, 63591, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 17:36:48');
INSERT INTO `userscoresnapshotledger` VALUES (4355, 'test01', 40, 3, 63591, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 17:36:50');
INSERT INTO `userscoresnapshotledger` VALUES (4356, 'test01', 16, 5, 63607, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 17:36:58');
INSERT INTO `userscoresnapshotledger` VALUES (4357, 'test01', 16, 5, 63575, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 17:37:04');
INSERT INTO `userscoresnapshotledger` VALUES (4358, 'test01', 16, 5, 63611, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 17:37:10');
INSERT INTO `userscoresnapshotledger` VALUES (4359, 'test01', 16, 5, 63619, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 17:37:16');
INSERT INTO `userscoresnapshotledger` VALUES (4360, 'test01', 16, 5, 63603, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 17:37:22');
INSERT INTO `userscoresnapshotledger` VALUES (4361, 'test01', 16, 5, 63607, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 17:37:27');
INSERT INTO `userscoresnapshotledger` VALUES (4362, 'test01', 16, 5, 63615, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 17:37:34');
INSERT INTO `userscoresnapshotledger` VALUES (4363, 'test01', 16, 5, 63641, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 17:37:40');
INSERT INTO `userscoresnapshotledger` VALUES (4364, 'test01', 16, 5, 63641, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 17:37:48');
INSERT INTO `userscoresnapshotledger` VALUES (4365, 'test01', 16, 5, 63641, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 17:37:48');
INSERT INTO `userscoresnapshotledger` VALUES (4366, 'test01', 54, 0, 63641, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 17:37:49');
INSERT INTO `userscoresnapshotledger` VALUES (4367, 'test01', 40, 8, 63641, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 18:02:27');
INSERT INTO `userscoresnapshotledger` VALUES (4368, 'test01', 54, 0, 63641, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 18:02:27');
INSERT INTO `userscoresnapshotledger` VALUES (4369, 'test01', 40, 9, 63640, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 18:02:28');
INSERT INTO `userscoresnapshotledger` VALUES (4370, 'test01', 40, 9, 63636, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 18:02:38');
INSERT INTO `userscoresnapshotledger` VALUES (4371, 'test01', 40, 9, 63627, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 18:02:45');
INSERT INTO `userscoresnapshotledger` VALUES (4372, 'test01', 40, 9, 63621, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 18:02:55');
INSERT INTO `userscoresnapshotledger` VALUES (4373, 'test01', 40, 9, 63675, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 18:03:04');
INSERT INTO `userscoresnapshotledger` VALUES (4374, 'test01', 40, 9, 63675, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 18:14:45');
INSERT INTO `userscoresnapshotledger` VALUES (4375, 'test01', 40, 11, 63675, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 18:14:59');
INSERT INTO `userscoresnapshotledger` VALUES (4376, 'test01', 54, 0, 63675, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 18:14:59');
INSERT INTO `userscoresnapshotledger` VALUES (4377, 'test01', 40, 12, 63669, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 18:15:02');
INSERT INTO `userscoresnapshotledger` VALUES (4378, 'test01', 40, 12, 63669, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 18:16:06');
INSERT INTO `userscoresnapshotledger` VALUES (4379, 'test01', 2, 2, 0, 63669, 63669, 0, 'SNAPSHOT_SAVE', '2026-07-15 18:25:56');
INSERT INTO `userscoresnapshotledger` VALUES (4380, 'test01', 2, 2, 0, 63665, 63665, 0, 'SNAPSHOT_SAVE', '2026-07-15 18:26:08');
INSERT INTO `userscoresnapshotledger` VALUES (4381, 'test01', 2, 2, 63665, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 18:26:10');
INSERT INTO `userscoresnapshotledger` VALUES (4382, 'test01', 54, 0, 63665, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 18:26:15');
INSERT INTO `userscoresnapshotledger` VALUES (4383, 'test01', 29, 6, 0, 63665, 63665, 0, 'SNAPSHOT_SAVE', '2026-07-15 18:26:23');
INSERT INTO `userscoresnapshotledger` VALUES (4384, 'test01', 29, 6, 63665, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 18:26:27');
INSERT INTO `userscoresnapshotledger` VALUES (4385, 'test01', 54, 0, 63665, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 18:26:29');
INSERT INTO `userscoresnapshotledger` VALUES (4386, 'test01', 54, 0, 63665, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 18:26:46');
INSERT INTO `userscoresnapshotledger` VALUES (4387, 'test01', 47, 11, 0, 63665, 63665, 0, 'SNAPSHOT_SAVE', '2026-07-15 18:26:56');
INSERT INTO `userscoresnapshotledger` VALUES (4388, 'test01', 47, 11, 63665, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 18:27:01');
INSERT INTO `userscoresnapshotledger` VALUES (4389, 'test01', 54, 0, 63665, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 18:27:02');
INSERT INTO `userscoresnapshotledger` VALUES (4390, 'test01', 54, 0, 63665, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 18:27:10');
INSERT INTO `userscoresnapshotledger` VALUES (4391, 'test01', 54, 0, 63665, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-15 18:27:24');
INSERT INTO `userscoresnapshotledger` VALUES (4392, 'test01', 0, 17, 63665, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 18:30:13');
INSERT INTO `userscoresnapshotledger` VALUES (4393, 'test01', 2, 2, 0, 63665, 63665, 0, 'SNAPSHOT_SAVE', '2026-07-15 19:11:45');
INSERT INTO `userscoresnapshotledger` VALUES (4394, 'test01', 2, 2, 0, 63665, 63665, 0, 'SNAPSHOT_SAVE', '2026-07-15 19:11:59');
INSERT INTO `userscoresnapshotledger` VALUES (4395, 'test01', 2, 2, 63665, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 19:12:04');
INSERT INTO `userscoresnapshotledger` VALUES (4396, 'test01', 2, 5, 0, 63665, 63665, 0, 'SNAPSHOT_SAVE', '2026-07-15 19:12:34');
INSERT INTO `userscoresnapshotledger` VALUES (4397, 'test01', 2, 5, 0, 63665, 63665, 0, 'SNAPSHOT_SAVE', '2026-07-15 19:12:48');
INSERT INTO `userscoresnapshotledger` VALUES (4398, 'test01', 2, 5, 63665, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 19:13:13');
INSERT INTO `userscoresnapshotledger` VALUES (4399, 'test01', 0, 5, 63665, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 19:13:39');
INSERT INTO `userscoresnapshotledger` VALUES (4400, 'test01', 2, 2, 0, 63665, 63665, 0, 'SNAPSHOT_SAVE', '2026-07-15 20:01:15');
INSERT INTO `userscoresnapshotledger` VALUES (4401, 'test01', 2, 2, 63665, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 20:01:27');
INSERT INTO `userscoresnapshotledger` VALUES (4402, 'test01', 5, 4, 0, 63665, 63665, 0, 'SNAPSHOT_SAVE', '2026-07-15 20:02:05');
INSERT INTO `userscoresnapshotledger` VALUES (4403, 'test01', 5, 4, 63665, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 20:02:18');
INSERT INTO `userscoresnapshotledger` VALUES (4404, 'test01', 5, 6, 0, 63665, 63665, 0, 'SNAPSHOT_SAVE', '2026-07-15 20:02:40');
INSERT INTO `userscoresnapshotledger` VALUES (4405, 'test01', 5, 6, 63665, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 20:02:59');
INSERT INTO `userscoresnapshotledger` VALUES (4406, 'test01', 15, 8, 0, 63665, 63665, 0, 'SNAPSHOT_SAVE', '2026-07-15 20:03:12');
INSERT INTO `userscoresnapshotledger` VALUES (4407, 'test01', 15, 8, 63665, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 20:03:53');
INSERT INTO `userscoresnapshotledger` VALUES (4408, 'test01', 2, 10, 0, 63665, 63665, 0, 'SNAPSHOT_SAVE', '2026-07-15 20:10:09');
INSERT INTO `userscoresnapshotledger` VALUES (4409, 'test01', 2, 10, 0, 63665, 63665, 0, 'SNAPSHOT_SAVE', '2026-07-15 20:10:23');
INSERT INTO `userscoresnapshotledger` VALUES (4410, 'test01', 2, 10, 63665, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 20:10:49');
INSERT INTO `userscoresnapshotledger` VALUES (4411, 'test01', 0, 10, 63665, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 20:19:46');
INSERT INTO `userscoresnapshotledger` VALUES (4412, 'test01', 2, 2, 0, 63665, 63665, 0, 'SNAPSHOT_SAVE', '2026-07-15 20:28:17');
INSERT INTO `userscoresnapshotledger` VALUES (4413, 'test01', 2, 2, 0, 63674, 63674, 0, 'SNAPSHOT_SAVE', '2026-07-15 20:28:29');
INSERT INTO `userscoresnapshotledger` VALUES (4414, 'test01', 2, 2, 63674, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 20:28:31');
INSERT INTO `userscoresnapshotledger` VALUES (4415, 'test01', 0, 2, 63674, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-15 20:29:08');
INSERT INTO `userscoresnapshotledger` VALUES (4416, 'test01', 2, 2, 0, 63674, 63674, 0, 'SNAPSHOT_SAVE', '2026-07-16 09:49:43');
INSERT INTO `userscoresnapshotledger` VALUES (4417, 'test01', 2, 2, 0, 63699, 63699, 0, 'SNAPSHOT_SAVE', '2026-07-16 09:49:57');
INSERT INTO `userscoresnapshotledger` VALUES (4418, 'test01', 2, 2, 0, 63699, 63699, 0, 'SNAPSHOT_SAVE', '2026-07-16 09:50:18');
INSERT INTO `userscoresnapshotledger` VALUES (4419, 'test01', 2, 2, 0, 63699, 63699, 0, 'SNAPSHOT_SAVE', '2026-07-16 09:50:41');
INSERT INTO `userscoresnapshotledger` VALUES (4420, 'test01', 2, 2, 63699, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 09:50:44');
INSERT INTO `userscoresnapshotledger` VALUES (4421, 'test01', 0, 3, 63699, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 09:53:34');
INSERT INTO `userscoresnapshotledger` VALUES (4422, 'test01', 2, 2, 0, 63699, 63699, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:12:44');
INSERT INTO `userscoresnapshotledger` VALUES (4423, 'test01', 2, 2, 0, 63667, 63667, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:12:56');
INSERT INTO `userscoresnapshotledger` VALUES (4424, 'test01', 2, 2, 0, 63667, 63667, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:13:18');
INSERT INTO `userscoresnapshotledger` VALUES (4425, 'test01', 2, 2, 0, 63667, 63667, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:13:39');
INSERT INTO `userscoresnapshotledger` VALUES (4426, 'test01', 2, 2, 0, 63667, 63667, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:14:00');
INSERT INTO `userscoresnapshotledger` VALUES (4427, 'test01', 2, 2, 63667, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:14:15');
INSERT INTO `userscoresnapshotledger` VALUES (4428, 'test01', 2, 4, 0, 63667, 63667, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:14:21');
INSERT INTO `userscoresnapshotledger` VALUES (4429, 'test01', 2, 4, 63667, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:14:33');
INSERT INTO `userscoresnapshotledger` VALUES (4430, 'test01', 10, 6, 0, 63667, 63667, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:14:41');
INSERT INTO `userscoresnapshotledger` VALUES (4431, 'test01', 10, 6, 0, 63667, 63667, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:14:55');
INSERT INTO `userscoresnapshotledger` VALUES (4432, 'test01', 10, 6, 0, 63667, 63667, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:15:47');
INSERT INTO `userscoresnapshotledger` VALUES (4433, 'test01', 10, 6, 0, 63667, 63667, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:16:38');
INSERT INTO `userscoresnapshotledger` VALUES (4434, 'test01', 10, 6, 63667, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:16:50');
INSERT INTO `userscoresnapshotledger` VALUES (4435, 'test01', 29, 8, 0, 63667, 63667, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:19:14');
INSERT INTO `userscoresnapshotledger` VALUES (4436, 'test01', 29, 8, 63667, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:19:24');
INSERT INTO `userscoresnapshotledger` VALUES (4437, 'test01', 29, 10, 0, 63667, 63667, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:19:42');
INSERT INTO `userscoresnapshotledger` VALUES (4438, 'test01', 29, 10, 63667, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:19:52');
INSERT INTO `userscoresnapshotledger` VALUES (4439, 'test01', 3, 12, 0, 63667, 63667, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:23:27');
INSERT INTO `userscoresnapshotledger` VALUES (4440, 'test01', 3, 12, 63667, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:23:41');
INSERT INTO `userscoresnapshotledger` VALUES (4441, 'test01', 3, 12, 63667, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:23:42');
INSERT INTO `userscoresnapshotledger` VALUES (4442, 'test01', 54, 0, 63667, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-16 10:29:24');
INSERT INTO `userscoresnapshotledger` VALUES (4443, 'test01', 3, 16, 0, 63667, 63667, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:23');
INSERT INTO `userscoresnapshotledger` VALUES (4444, 'test01', 3, 16, 0, 63597, 63597, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:50');
INSERT INTO `userscoresnapshotledger` VALUES (4445, 'test01', 3, 16, 0, 63527, 63527, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:50');
INSERT INTO `userscoresnapshotledger` VALUES (4446, 'test01', 3, 16, 0, 63457, 63457, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:51');
INSERT INTO `userscoresnapshotledger` VALUES (4447, 'test01', 3, 16, 0, 63387, 63387, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:51');
INSERT INTO `userscoresnapshotledger` VALUES (4448, 'test01', 3, 16, 0, 63317, 63317, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:51');
INSERT INTO `userscoresnapshotledger` VALUES (4449, 'test01', 3, 16, 0, 63247, 63247, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:52');
INSERT INTO `userscoresnapshotledger` VALUES (4450, 'test01', 3, 16, 0, 63457, 63457, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:52');
INSERT INTO `userscoresnapshotledger` VALUES (4451, 'test01', 3, 16, 0, 63387, 63387, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:52');
INSERT INTO `userscoresnapshotledger` VALUES (4452, 'test01', 3, 16, 0, 63317, 63317, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:53');
INSERT INTO `userscoresnapshotledger` VALUES (4453, 'test01', 3, 16, 0, 63877, 63877, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:53');
INSERT INTO `userscoresnapshotledger` VALUES (4454, 'test01', 3, 16, 0, 63807, 63807, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:53');
INSERT INTO `userscoresnapshotledger` VALUES (4455, 'test01', 3, 16, 0, 63737, 63737, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:54');
INSERT INTO `userscoresnapshotledger` VALUES (4456, 'test01', 3, 16, 0, 63667, 63667, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:54');
INSERT INTO `userscoresnapshotledger` VALUES (4457, 'test01', 3, 16, 0, 63597, 63597, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:54');
INSERT INTO `userscoresnapshotledger` VALUES (4458, 'test01', 3, 16, 0, 63527, 63527, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:55');
INSERT INTO `userscoresnapshotledger` VALUES (4459, 'test01', 3, 16, 0, 63457, 63457, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:55');
INSERT INTO `userscoresnapshotledger` VALUES (4460, 'test01', 3, 16, 0, 63387, 63387, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:55');
INSERT INTO `userscoresnapshotledger` VALUES (4461, 'test01', 3, 16, 0, 63317, 63317, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:56');
INSERT INTO `userscoresnapshotledger` VALUES (4462, 'test01', 3, 16, 0, 63247, 63247, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:56');
INSERT INTO `userscoresnapshotledger` VALUES (4463, 'test01', 3, 16, 0, 63177, 63177, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:56');
INSERT INTO `userscoresnapshotledger` VALUES (4464, 'test01', 3, 16, 0, 63107, 63107, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:57');
INSERT INTO `userscoresnapshotledger` VALUES (4465, 'test01', 3, 16, 0, 63037, 63037, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:57');
INSERT INTO `userscoresnapshotledger` VALUES (4466, 'test01', 3, 16, 0, 62967, 62967, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:57');
INSERT INTO `userscoresnapshotledger` VALUES (4467, 'test01', 3, 16, 0, 62897, 62897, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:57');
INSERT INTO `userscoresnapshotledger` VALUES (4468, 'test01', 3, 16, 0, 62827, 62827, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:57');
INSERT INTO `userscoresnapshotledger` VALUES (4469, 'test01', 3, 16, 0, 62757, 62757, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:34:59');
INSERT INTO `userscoresnapshotledger` VALUES (4470, 'test01', 3, 16, 0, 62687, 62687, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:35:00');
INSERT INTO `userscoresnapshotledger` VALUES (4471, 'test01', 3, 16, 0, 62617, 62617, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:35:00');
INSERT INTO `userscoresnapshotledger` VALUES (4472, 'test01', 3, 16, 0, 62547, 62547, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:35:00');
INSERT INTO `userscoresnapshotledger` VALUES (4473, 'test01', 3, 16, 0, 62477, 62477, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:35:00');
INSERT INTO `userscoresnapshotledger` VALUES (4474, 'test01', 3, 16, 0, 62407, 62407, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:35:01');
INSERT INTO `userscoresnapshotledger` VALUES (4475, 'test01', 3, 16, 0, 62337, 62337, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:35:01');
INSERT INTO `userscoresnapshotledger` VALUES (4476, 'test01', 3, 16, 0, 62267, 62267, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:35:01');
INSERT INTO `userscoresnapshotledger` VALUES (4477, 'test01', 3, 16, 0, 62197, 62197, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:35:01');
INSERT INTO `userscoresnapshotledger` VALUES (4478, 'test01', 3, 16, 0, 62127, 62127, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:35:01');
INSERT INTO `userscoresnapshotledger` VALUES (4479, 'test01', 3, 16, 0, 62057, 62057, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:35:08');
INSERT INTO `userscoresnapshotledger` VALUES (4480, 'test01', 3, 16, 0, 61987, 61987, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:35:09');
INSERT INTO `userscoresnapshotledger` VALUES (4481, 'test01', 3, 16, 61987, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:35:32');
INSERT INTO `userscoresnapshotledger` VALUES (4482, 'test002', 54, 0, 454564, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-16 10:40:04');
INSERT INTO `userscoresnapshotledger` VALUES (4483, 'test002', 54, 0, 454564, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-16 10:40:15');
INSERT INTO `userscoresnapshotledger` VALUES (4484, 'test01', 54, 0, 61987, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-16 10:40:16');
INSERT INTO `userscoresnapshotledger` VALUES (4485, 'test002', 54, 0, 454564, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-16 10:40:22');
INSERT INTO `userscoresnapshotledger` VALUES (4486, 'test002', 54, 0, 454564, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-16 10:40:33');
INSERT INTO `userscoresnapshotledger` VALUES (4487, 'test01', 54, 0, 61987, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-16 10:41:59');
INSERT INTO `userscoresnapshotledger` VALUES (4488, 'test01', 54, 0, 61987, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-16 10:42:09');
INSERT INTO `userscoresnapshotledger` VALUES (4489, 'test01', 54, 0, 61987, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-16 10:46:00');
INSERT INTO `userscoresnapshotledger` VALUES (4490, 'test01', 44, 41, 0, 61987, 61987, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:51:14');
INSERT INTO `userscoresnapshotledger` VALUES (4491, 'test01', 44, 41, 61987, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:51:17');
INSERT INTO `userscoresnapshotledger` VALUES (4492, 'test01', 2, 43, 0, 61987, 61987, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:51:57');
INSERT INTO `userscoresnapshotledger` VALUES (4493, 'test01', 2, 43, 61987, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:52:04');
INSERT INTO `userscoresnapshotledger` VALUES (4494, 'test01', 47, 46, 0, 61987, 61987, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:53:58');
INSERT INTO `userscoresnapshotledger` VALUES (4495, 'test01', 47, 46, 61987, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:54:03');
INSERT INTO `userscoresnapshotledger` VALUES (4496, 'test01', 19, 49, 0, 61987, 61987, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:57:02');
INSERT INTO `userscoresnapshotledger` VALUES (4497, 'test01', 19, 49, 0, 61887, 61887, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:57:21');
INSERT INTO `userscoresnapshotledger` VALUES (4498, 'test01', 19, 49, 0, 61787, 61787, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:57:22');
INSERT INTO `userscoresnapshotledger` VALUES (4499, 'test01', 19, 49, 0, 65787, 65787, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:57:22');
INSERT INTO `userscoresnapshotledger` VALUES (4500, 'test01', 19, 49, 0, 65687, 65687, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:57:22');
INSERT INTO `userscoresnapshotledger` VALUES (4501, 'test01', 19, 49, 0, 65587, 65587, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:57:23');
INSERT INTO `userscoresnapshotledger` VALUES (4502, 'test01', 19, 49, 0, 65487, 65487, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:57:23');
INSERT INTO `userscoresnapshotledger` VALUES (4503, 'test01', 19, 49, 0, 65387, 65387, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:57:24');
INSERT INTO `userscoresnapshotledger` VALUES (4504, 'test01', 19, 49, 0, 65287, 65287, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:57:25');
INSERT INTO `userscoresnapshotledger` VALUES (4505, 'test01', 19, 49, 65287, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:57:26');
INSERT INTO `userscoresnapshotledger` VALUES (4506, 'test01', 19, 51, 0, 65287, 65287, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:57:37');
INSERT INTO `userscoresnapshotledger` VALUES (4507, 'test01', 19, 51, 65287, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:57:43');
INSERT INTO `userscoresnapshotledger` VALUES (4508, 'test01', 19, 51, 65287, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 10:57:44');
INSERT INTO `userscoresnapshotledger` VALUES (4509, 'test01', 10, 54, 0, 65287, 65287, 0, 'SNAPSHOT_SAVE', '2026-07-16 11:01:07');
INSERT INTO `userscoresnapshotledger` VALUES (4510, 'test01', 10, 54, 0, 65287, 65287, 0, 'SNAPSHOT_SAVE', '2026-07-16 11:01:21');
INSERT INTO `userscoresnapshotledger` VALUES (4511, 'test01', 10, 54, 65287, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 11:01:26');
INSERT INTO `userscoresnapshotledger` VALUES (4512, 'test01', 54, 0, 65287, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-16 11:01:35');
INSERT INTO `userscoresnapshotledger` VALUES (4513, 'test01', 10, 58, 0, 65287, 65287, 0, 'SNAPSHOT_SAVE', '2026-07-16 11:01:40');
INSERT INTO `userscoresnapshotledger` VALUES (4514, 'test01', 10, 58, 65287, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 11:01:48');
INSERT INTO `userscoresnapshotledger` VALUES (4515, 'test01', 54, 0, 65287, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-16 11:02:56');
INSERT INTO `userscoresnapshotledger` VALUES (4516, 'test01', 10, 62, 0, 65287, 65287, 0, 'SNAPSHOT_SAVE', '2026-07-16 11:03:04');
INSERT INTO `userscoresnapshotledger` VALUES (4517, 'test01', 10, 62, 0, 65287, 65287, 0, 'SNAPSHOT_SAVE', '2026-07-16 11:03:16');
INSERT INTO `userscoresnapshotledger` VALUES (4518, 'test01', 10, 62, 65287, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 11:03:43');
INSERT INTO `userscoresnapshotledger` VALUES (4519, 'test01', 5, 64, 0, 65287, 65287, 0, 'SNAPSHOT_SAVE', '2026-07-16 11:45:28');
INSERT INTO `userscoresnapshotledger` VALUES (4520, 'test01', 5, 64, 0, 65277, 65277, 0, 'SNAPSHOT_SAVE', '2026-07-16 11:45:32');
INSERT INTO `userscoresnapshotledger` VALUES (4521, 'test01', 5, 64, 0, 65277, 65277, 0, 'SNAPSHOT_SAVE', '2026-07-16 11:45:37');
INSERT INTO `userscoresnapshotledger` VALUES (4522, 'test01', 5, 64, 0, 65357, 65357, 0, 'SNAPSHOT_SAVE', '2026-07-16 11:45:43');
INSERT INTO `userscoresnapshotledger` VALUES (4523, 'test01', 5, 64, 65357, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 11:45:45');
INSERT INTO `userscoresnapshotledger` VALUES (4524, 'test01', 54, 0, 65357, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-16 11:46:00');
INSERT INTO `userscoresnapshotledger` VALUES (4525, 'test01', 3, 68, 0, 65357, 65357, 0, 'SNAPSHOT_SAVE', '2026-07-16 11:46:05');
INSERT INTO `userscoresnapshotledger` VALUES (4526, 'test01', 3, 68, 0, 65347, 65347, 0, 'SNAPSHOT_SAVE', '2026-07-16 11:46:07');
INSERT INTO `userscoresnapshotledger` VALUES (4527, 'test01', 3, 68, 0, 65337, 65337, 0, 'SNAPSHOT_SAVE', '2026-07-16 11:46:08');
INSERT INTO `userscoresnapshotledger` VALUES (4528, 'test01', 3, 68, 0, 65327, 65327, 0, 'SNAPSHOT_SAVE', '2026-07-16 11:46:08');
INSERT INTO `userscoresnapshotledger` VALUES (4529, 'test01', 3, 68, 0, 65317, 65317, 0, 'SNAPSHOT_SAVE', '2026-07-16 11:46:08');
INSERT INTO `userscoresnapshotledger` VALUES (4530, 'test01', 3, 68, 0, 65307, 65307, 0, 'SNAPSHOT_SAVE', '2026-07-16 11:46:08');
INSERT INTO `userscoresnapshotledger` VALUES (4531, 'test01', 3, 68, 65307, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 11:46:12');
INSERT INTO `userscoresnapshotledger` VALUES (4532, 'test01', 3, 68, 65307, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 11:46:13');
INSERT INTO `userscoresnapshotledger` VALUES (4533, 'test01', 3, 68, 65307, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 11:46:13');
INSERT INTO `userscoresnapshotledger` VALUES (4534, 'test01', 54, 0, 65307, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-16 13:10:39');
INSERT INTO `userscoresnapshotledger` VALUES (4535, 'test01', 54, 0, 65307, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-16 13:10:42');
INSERT INTO `userscoresnapshotledger` VALUES (4536, 'test01', 54, 0, 65307, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-16 13:10:47');
INSERT INTO `userscoresnapshotledger` VALUES (4537, 'test002', 0, 35, 454564, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 13:56:45');
INSERT INTO `userscoresnapshotledger` VALUES (4538, 'test01', 0, 76, 65307, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 13:56:45');
INSERT INTO `userscoresnapshotledger` VALUES (4539, 'test01', 19, 2, 0, 65307, 65307, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:34');
INSERT INTO `userscoresnapshotledger` VALUES (4540, 'test01', 19, 2, 0, 64907, 64907, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:46');
INSERT INTO `userscoresnapshotledger` VALUES (4541, 'test01', 19, 2, 0, 64507, 64507, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:46');
INSERT INTO `userscoresnapshotledger` VALUES (4542, 'test01', 19, 2, 0, 64107, 64107, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:47');
INSERT INTO `userscoresnapshotledger` VALUES (4543, 'test01', 19, 2, 0, 63707, 63707, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:47');
INSERT INTO `userscoresnapshotledger` VALUES (4544, 'test01', 19, 2, 0, 63307, 63307, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:47');
INSERT INTO `userscoresnapshotledger` VALUES (4545, 'test01', 19, 2, 0, 62907, 62907, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:47');
INSERT INTO `userscoresnapshotledger` VALUES (4546, 'test01', 19, 2, 0, 62507, 62507, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:47');
INSERT INTO `userscoresnapshotledger` VALUES (4547, 'test01', 19, 2, 0, 62107, 62107, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:48');
INSERT INTO `userscoresnapshotledger` VALUES (4548, 'test01', 19, 2, 0, 61707, 61707, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:48');
INSERT INTO `userscoresnapshotledger` VALUES (4549, 'test01', 19, 2, 0, 61307, 61307, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:48');
INSERT INTO `userscoresnapshotledger` VALUES (4550, 'test01', 19, 2, 0, 60907, 60907, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:48');
INSERT INTO `userscoresnapshotledger` VALUES (4551, 'test01', 19, 2, 0, 60507, 60507, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:48');
INSERT INTO `userscoresnapshotledger` VALUES (4552, 'test01', 19, 2, 0, 60107, 60107, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:49');
INSERT INTO `userscoresnapshotledger` VALUES (4553, 'test01', 19, 2, 0, 59707, 59707, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:49');
INSERT INTO `userscoresnapshotledger` VALUES (4554, 'test01', 19, 2, 0, 59307, 59307, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:49');
INSERT INTO `userscoresnapshotledger` VALUES (4555, 'test01', 19, 2, 0, 58907, 58907, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:49');
INSERT INTO `userscoresnapshotledger` VALUES (4556, 'test01', 19, 2, 0, 58507, 58507, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:49');
INSERT INTO `userscoresnapshotledger` VALUES (4557, 'test01', 19, 2, 0, 58107, 58107, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:53');
INSERT INTO `userscoresnapshotledger` VALUES (4558, 'test01', 19, 2, 0, 57707, 57707, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:53');
INSERT INTO `userscoresnapshotledger` VALUES (4559, 'test01', 19, 2, 0, 57307, 57307, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:54');
INSERT INTO `userscoresnapshotledger` VALUES (4560, 'test01', 19, 2, 0, 56907, 56907, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:54');
INSERT INTO `userscoresnapshotledger` VALUES (4561, 'test01', 19, 2, 0, 56507, 56507, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:54');
INSERT INTO `userscoresnapshotledger` VALUES (4562, 'test01', 19, 2, 0, 56107, 56107, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:55');
INSERT INTO `userscoresnapshotledger` VALUES (4563, 'test01', 19, 2, 0, 55707, 55707, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:55');
INSERT INTO `userscoresnapshotledger` VALUES (4564, 'test01', 19, 2, 0, 55307, 55307, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:55');
INSERT INTO `userscoresnapshotledger` VALUES (4565, 'test01', 19, 2, 0, 54907, 54907, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:56');
INSERT INTO `userscoresnapshotledger` VALUES (4566, 'test01', 19, 2, 0, 54507, 54507, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:56');
INSERT INTO `userscoresnapshotledger` VALUES (4567, 'test01', 19, 2, 0, 54107, 54107, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:56');
INSERT INTO `userscoresnapshotledger` VALUES (4568, 'test01', 19, 2, 0, 53707, 53707, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:56');
INSERT INTO `userscoresnapshotledger` VALUES (4569, 'test01', 19, 2, 53707, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:56');
INSERT INTO `userscoresnapshotledger` VALUES (4570, 'test01', 19, 2, 53707, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:10:57');
INSERT INTO `userscoresnapshotledger` VALUES (4571, 'test01', 3, 4, 0, 53707, 53707, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:11:05');
INSERT INTO `userscoresnapshotledger` VALUES (4572, 'test01', 3, 4, 0, 53697, 53697, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:11:07');
INSERT INTO `userscoresnapshotledger` VALUES (4573, 'test01', 3, 4, 0, 53687, 53687, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:11:07');
INSERT INTO `userscoresnapshotledger` VALUES (4574, 'test01', 3, 4, 0, 53677, 53677, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:11:08');
INSERT INTO `userscoresnapshotledger` VALUES (4575, 'test01', 3, 4, 0, 53667, 53667, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:11:08');
INSERT INTO `userscoresnapshotledger` VALUES (4576, 'test01', 3, 4, 0, 53657, 53657, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:11:08');
INSERT INTO `userscoresnapshotledger` VALUES (4577, 'test01', 3, 4, 53657, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:11:20');
INSERT INTO `userscoresnapshotledger` VALUES (4578, 'test01', 3, 4, 53657, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:11:21');
INSERT INTO `userscoresnapshotledger` VALUES (4579, 'test01', 54, 0, 53657, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-16 14:11:33');
INSERT INTO `userscoresnapshotledger` VALUES (4580, 'test01', 54, 0, 53657, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-16 14:11:44');
INSERT INTO `userscoresnapshotledger` VALUES (4581, 'test01', 54, 0, 53657, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-16 14:12:26');
INSERT INTO `userscoresnapshotledger` VALUES (4582, 'test01', 3, 13, 0, 53657, 53657, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:12:50');
INSERT INTO `userscoresnapshotledger` VALUES (4583, 'test01', 3, 13, 0, 53647, 53647, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:12:52');
INSERT INTO `userscoresnapshotledger` VALUES (4584, 'test01', 3, 13, 0, 53637, 53637, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:12:53');
INSERT INTO `userscoresnapshotledger` VALUES (4585, 'test01', 3, 13, 0, 53627, 53627, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:12:53');
INSERT INTO `userscoresnapshotledger` VALUES (4586, 'test01', 3, 13, 0, 53617, 53617, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:12:53');
INSERT INTO `userscoresnapshotledger` VALUES (4587, 'test01', 3, 13, 0, 53607, 53607, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:12:53');
INSERT INTO `userscoresnapshotledger` VALUES (4588, 'test01', 3, 13, 0, 53597, 53597, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:12:53');
INSERT INTO `userscoresnapshotledger` VALUES (4589, 'test01', 3, 13, 0, 53587, 53587, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:12:54');
INSERT INTO `userscoresnapshotledger` VALUES (4590, 'test01', 3, 13, 0, 53577, 53577, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:12:54');
INSERT INTO `userscoresnapshotledger` VALUES (4591, 'test01', 3, 13, 0, 53567, 53567, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:12:55');
INSERT INTO `userscoresnapshotledger` VALUES (4592, 'test01', 3, 13, 0, 53557, 53557, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:12:55');
INSERT INTO `userscoresnapshotledger` VALUES (4593, 'test01', 3, 13, 0, 53547, 53547, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:12:55');
INSERT INTO `userscoresnapshotledger` VALUES (4594, 'test01', 3, 13, 0, 53537, 53537, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:12:55');
INSERT INTO `userscoresnapshotledger` VALUES (4595, 'test01', 3, 13, 0, 53567, 53567, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:12:55');
INSERT INTO `userscoresnapshotledger` VALUES (4596, 'test01', 3, 13, 53567, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:12:59');
INSERT INTO `userscoresnapshotledger` VALUES (4597, 'test01', 3, 13, 53567, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:13:00');
INSERT INTO `userscoresnapshotledger` VALUES (4598, 'test01', 3, 15, 0, 53567, 53567, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:13:41');
INSERT INTO `userscoresnapshotledger` VALUES (4599, 'test01', 3, 15, 0, 53557, 53557, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:10');
INSERT INTO `userscoresnapshotledger` VALUES (4600, 'test01', 3, 15, 0, 53547, 53547, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:11');
INSERT INTO `userscoresnapshotledger` VALUES (4601, 'test01', 3, 15, 0, 53537, 53537, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:11');
INSERT INTO `userscoresnapshotledger` VALUES (4602, 'test01', 3, 15, 0, 53527, 53527, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:12');
INSERT INTO `userscoresnapshotledger` VALUES (4603, 'test01', 3, 15, 0, 53517, 53517, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:12');
INSERT INTO `userscoresnapshotledger` VALUES (4604, 'test01', 3, 15, 0, 53507, 53507, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:13');
INSERT INTO `userscoresnapshotledger` VALUES (4605, 'test01', 3, 15, 0, 53537, 53537, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:13');
INSERT INTO `userscoresnapshotledger` VALUES (4606, 'test01', 3, 15, 0, 53527, 53527, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:13');
INSERT INTO `userscoresnapshotledger` VALUES (4607, 'test01', 3, 15, 0, 53517, 53517, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:14');
INSERT INTO `userscoresnapshotledger` VALUES (4608, 'test01', 3, 15, 0, 53507, 53507, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:47');
INSERT INTO `userscoresnapshotledger` VALUES (4609, 'test01', 3, 15, 0, 53497, 53497, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:47');
INSERT INTO `userscoresnapshotledger` VALUES (4610, 'test01', 3, 15, 0, 53487, 53487, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:48');
INSERT INTO `userscoresnapshotledger` VALUES (4611, 'test01', 3, 15, 0, 53477, 53477, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:48');
INSERT INTO `userscoresnapshotledger` VALUES (4612, 'test01', 3, 15, 0, 53467, 53467, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:49');
INSERT INTO `userscoresnapshotledger` VALUES (4613, 'test01', 3, 15, 0, 53457, 53457, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:49');
INSERT INTO `userscoresnapshotledger` VALUES (4614, 'test01', 3, 15, 0, 53447, 53447, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:50');
INSERT INTO `userscoresnapshotledger` VALUES (4615, 'test01', 3, 15, 0, 53437, 53437, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:50');
INSERT INTO `userscoresnapshotledger` VALUES (4616, 'test01', 3, 15, 0, 53427, 53427, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:50');
INSERT INTO `userscoresnapshotledger` VALUES (4617, 'test01', 3, 15, 0, 53417, 53417, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:50');
INSERT INTO `userscoresnapshotledger` VALUES (4618, 'test01', 3, 15, 0, 53407, 53407, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:51');
INSERT INTO `userscoresnapshotledger` VALUES (4619, 'test01', 3, 15, 0, 53397, 53397, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:53');
INSERT INTO `userscoresnapshotledger` VALUES (4620, 'test01', 3, 15, 0, 53387, 53387, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:53');
INSERT INTO `userscoresnapshotledger` VALUES (4621, 'test01', 3, 15, 0, 53377, 53377, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:53');
INSERT INTO `userscoresnapshotledger` VALUES (4622, 'test01', 3, 15, 0, 53367, 53367, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:54');
INSERT INTO `userscoresnapshotledger` VALUES (4623, 'test01', 3, 15, 0, 53357, 53357, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:54');
INSERT INTO `userscoresnapshotledger` VALUES (4624, 'test01', 3, 15, 0, 53347, 53347, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:57');
INSERT INTO `userscoresnapshotledger` VALUES (4625, 'test01', 3, 15, 0, 53337, 53337, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:14:59');
INSERT INTO `userscoresnapshotledger` VALUES (4626, 'test01', 3, 15, 0, 53327, 53327, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:15:01');
INSERT INTO `userscoresnapshotledger` VALUES (4627, 'test01', 3, 15, 53327, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:16:21');
INSERT INTO `userscoresnapshotledger` VALUES (4628, 'test01', 3, 15, 53327, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:16:22');
INSERT INTO `userscoresnapshotledger` VALUES (4629, 'test01', 54, 0, 53327, 0, 0, 0, 'SNAPSHOT_RECOVER:LOGOUT_TO_HALL', '2026-07-16 14:17:41');
INSERT INTO `userscoresnapshotledger` VALUES (4630, 'test01', 3, 19, 0, 53327, 53327, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:20:22');
INSERT INTO `userscoresnapshotledger` VALUES (4631, 'test01', 3, 19, 0, 53317, 53317, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:20:25');
INSERT INTO `userscoresnapshotledger` VALUES (4632, 'test01', 3, 19, 0, 53307, 53307, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:20:32');
INSERT INTO `userscoresnapshotledger` VALUES (4633, 'test01', 3, 19, 0, 53297, 53297, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:20:47');
INSERT INTO `userscoresnapshotledger` VALUES (4634, 'test01', 54, 0, 53297, 0, 0, 53297, 'SNAPSHOT_RECOVER:GAME_LOST', '2026-07-16 14:21:43');
INSERT INTO `userscoresnapshotledger` VALUES (4635, 'test01', 3, 19, 0, 53287, 53287, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:21:54');
INSERT INTO `userscoresnapshotledger` VALUES (4636, 'test01', 3, 19, 0, 53277, 53277, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:21:57');
INSERT INTO `userscoresnapshotledger` VALUES (4637, 'test01', 3, 19, 53277, 0, 0, 0, 'SNAPSHOT_SAVE', '2026-07-16 14:24:58');

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
