-- MySQL 5.7+。先执行本脚本，再成套发布后台、中心服及带送奖事件尾段的子游戏。
-- 不回填历史控制，不改玩家余额；新奖池初始为 0，充值从操作员自己的 admin.COINS 转入。
CREATE TABLE IF NOT EXISTS agentprizepool (
 AgentID varchar(50) NOT NULL,
 Balance decimal(28,8) NOT NULL DEFAULT 0,
 PRIMARY KEY (AgentID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE IF NOT EXISTS agentprizecontrol (
 ControlId int NOT NULL,
 AgentID varchar(50) NOT NULL,
 UserID varchar(50) NOT NULL,
 ControlMode int NOT NULL,
 BookedDiamonds decimal(28,8) NOT NULL DEFAULT 0,
 NetDiamonds decimal(28,8) NOT NULL DEFAULT 0,
 CardDiamonds decimal(28,8) NOT NULL DEFAULT 0,
 AwardDiamonds decimal(28,8) NOT NULL DEFAULT 0,
 ActualGameId int NOT NULL DEFAULT 0,
 ActualTableId bigint DEFAULT NULL,
 ActualCardType varchar(100) DEFAULT NULL,
 AwardTime datetime(6) DEFAULT NULL,
 ProgressTime datetime(6) DEFAULT NULL,
 Revision bigint NOT NULL DEFAULT 0,
 PRIMARY KEY (ControlId),
 KEY IX_agentprizecontrol_owner (AgentID,ControlId),
 KEY IX_agentprizecontrol_user (UserID,ControlMode,ControlId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE IF NOT EXISTS agentprizeledger (
 ID bigint NOT NULL AUTO_INCREMENT,
 EventId varchar(96) NOT NULL,
 AgentID varchar(50) NOT NULL,
 ControlId int DEFAULT NULL,
 Kind int NOT NULL COMMENT '1充值/2提取/3控牌支出/4放水净收益调整/5控牌与放水重叠调整',
 ChangeDiamonds decimal(28,8) NOT NULL,
 BalanceAfter decimal(28,8) NOT NULL,
 UserID varchar(50) DEFAULT NULL,
 GameId int NOT NULL DEFAULT 0,
 TableId bigint DEFAULT NULL,
 CardType varchar(100) DEFAULT NULL,
 RecTime datetime(6) NOT NULL,
 PRIMARY KEY (ID),
 UNIQUE KEY UX_agentprizeledger_event (EventId),
 KEY IX_agentprizeledger_owner_time (AgentID,RecTime,ID),
 KEY IX_agentprizeledger_control (ControlId,ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
-- 放水单独接收实际原始增量与兑换比，保留八位小数，不使用整数目标进度冒充实际支出。
DROP TRIGGER IF EXISTS trg_agentprize_release_progress;
DROP PROCEDURE IF EXISTS agentprize_release_delta;
DELIMITER $$
CREATE PROCEDURE agentprize_release_delta(IN pEvent varchar(96), IN pControl int, IN pUser varchar(50),
 IN pGame int, IN pTable bigint, IN pUnits bigint, IN pRate bigint, IN pTime datetime(6))
proc: BEGIN
 DECLARE vAgent varchar(50);
 DECLARE vBalance decimal(28,8);
 DECLARE vBooked decimal(28,8);
 DECLARE vNet decimal(28,8);
 DECLARE vCards decimal(28,8);
 DECLARE vNew decimal(28,8);
 SET vAgent=NULL;
 SELECT AgentID INTO vAgent FROM agentprizecontrol WHERE ControlId=pControl AND UserID=pUser AND ControlMode=5;
 IF vAgent IS NULL OR pRate<=0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid funded release delta'; END IF;
 SELECT Balance INTO vBalance FROM agentprizepool WHERE AgentID=vAgent FOR UPDATE;
 IF EXISTS(SELECT 1 FROM agentprizeledger WHERE EventId=pEvent) THEN LEAVE proc; END IF;
 SELECT BookedDiamonds,NetDiamonds,CardDiamonds INTO vBooked,vNet,vCards FROM agentprizecontrol WHERE ControlId=pControl FOR UPDATE;
 SET vNet=vNet+CAST(pUnits AS DECIMAL(28,8))/pRate;
 SET vNew=GREATEST(0,vNet-vCards);
 UPDATE agentprizepool SET Balance=Balance-(vNew-vBooked) WHERE AgentID=vAgent;
 UPDATE agentprizecontrol SET BookedDiamonds=vNew,NetDiamonds=vNet,AwardDiamonds=GREATEST(0,vNet),
  ActualGameId=pGame,ActualTableId=pTable,ProgressTime=pTime,AwardTime=IF(pUnits>0,pTime,AwardTime) WHERE ControlId=pControl;
 INSERT INTO agentprizeledger(EventId,AgentID,ControlId,Kind,ChangeDiamonds,BalanceAfter,UserID,GameId,TableId,RecTime)
  VALUES(pEvent,vAgent,pControl,4,vBooked-vNew,vBalance-(vNew-vBooked),pUser,pGame,pTable,pTime);
END$$
DELIMITER ;

-- 由中心服在中奖明细的同一事务中调用。事件号和控制编号来自子游戏原始报文。
DROP PROCEDURE IF EXISTS agentprize_record_award;
DELIMITER $$
CREATE PROCEDURE agentprize_record_award(IN pEvent varchar(96), IN pControl int, IN pUser varchar(50),
 IN pGame int, IN pTable bigint, IN pType varchar(100), IN pUnits bigint, IN pRate bigint, IN pTime datetime(6))
proc: BEGIN
 DECLARE vAgent varchar(50);
 DECLARE vBalance decimal(28,8);
 DECLARE vAmount decimal(28,8);
 DECLARE vRelease int DEFAULT NULL;
 DECLARE vReleaseAgent varchar(50);
 DECLARE vBooked decimal(28,8);
 DECLARE vNet decimal(28,8);
 DECLARE vCards decimal(28,8);
 DECLARE vNew decimal(28,8);
 DECLARE vRevision bigint;
 SET vAgent=NULL;
 SELECT p.AgentID INTO vAgent FROM agentprizecontrol p JOIN usercontrolstatus c ON c.ID=p.ControlId
  WHERE p.ControlId=pControl AND p.UserID=pUser AND p.ControlMode=6
   AND pGame=CASE c.GameId WHEN 5 THEN 15 WHEN 7 THEN 37 WHEN 8 THEN 25 WHEN 12 THEN 14
    WHEN 13 THEN 44 WHEN 14 THEN 5 WHEN 15 THEN 53 WHEN 16 THEN 16 WHEN 17 THEN 40 WHEN 19 THEN 54 WHEN 20 THEN 55 ELSE -1 END;
 IF vAgent IS NULL OR pRate<=0 OR pUnits<0 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid funded control award';
 END IF;
 SELECT Balance INTO vBalance FROM agentprizepool WHERE AgentID=vAgent FOR UPDATE;
 IF EXISTS(SELECT 1 FROM agentprizeledger WHERE EventId=pEvent) THEN LEAVE proc; END IF;
 SET vAmount=CAST(pUnits AS DECIMAL(28,8))/pRate;
 UPDATE agentprizepool SET Balance=Balance-vAmount WHERE AgentID=vAgent;
 INSERT INTO agentprizeledger(EventId,AgentID,ControlId,Kind,ChangeDiamonds,BalanceAfter,UserID,GameId,TableId,CardType,RecTime)
  VALUES(pEvent,vAgent,pControl,3,-vAmount,vBalance-vAmount,pUser,pGame,pTable,pType,pTime);
 UPDATE agentprizecontrol SET BookedDiamonds=BookedDiamonds+vAmount,AwardDiamonds=AwardDiamonds+vAmount,
  ActualGameId=pGame,ActualTableId=pTable,ActualCardType=pType,AwardTime=pTime WHERE ControlId=pControl;

 -- 同一玩家并行放水的净收益已包含控牌奖金，按事件实际发生时间排除重叠部分。
 SELECT MAX(c.ID) INTO vRelease FROM usercontrolstatus c JOIN agentprizecontrol p ON p.ControlId=c.ID
  WHERE c.UserID=pUser AND c.GameType=9 AND c.ControlMode=5 AND c.CreatedTime<=pTime
    AND (c.ExpiredTime IS NULL OR c.ExpiredTime>=pTime);
 IF vRelease IS NOT NULL THEN
  SELECT p.AgentID,p.BookedDiamonds,p.NetDiamonds,p.Revision INTO vReleaseAgent,vBooked,vNet,vRevision
   FROM agentprizecontrol p JOIN usercontrolstatus c ON c.ID=p.ControlId WHERE p.ControlId=vRelease FOR UPDATE;
  SELECT IFNULL(SUM(-l.ChangeDiamonds),0) INTO vCards FROM agentprizeledger l JOIN usercontrolstatus c ON c.ID=vRelease
   WHERE l.Kind=3 AND l.UserID=pUser AND l.RecTime>=c.CreatedTime AND (c.ExpiredTime IS NULL OR l.RecTime<=c.ExpiredTime);
  SET vNew=GREATEST(0,vNet-vCards);
  UPDATE agentprizepool SET Balance=Balance+(vBooked-vNew) WHERE AgentID=vReleaseAgent;
  UPDATE agentprizecontrol SET CardDiamonds=vCards,BookedDiamonds=vNew,Revision=Revision+1 WHERE ControlId=vRelease;
  IF vBooked<>vNew THEN
   INSERT INTO agentprizeledger(EventId,AgentID,ControlId,Kind,ChangeDiamonds,BalanceAfter,UserID,GameId,RecTime)
    SELECT CONCAT('overlap:',vRelease,':',vRevision+1),vReleaseAgent,vRelease,5,vBooked-vNew,Balance,pUser,pGame,pTime
     FROM agentprizepool WHERE AgentID=vReleaseAgent;
  END IF;
 END IF;
END$$
DELIMITER ;
