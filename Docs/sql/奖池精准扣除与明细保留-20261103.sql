-- MySQL 5.7+。在《代理送奖奖池-20261102.sql》之后执行，可重复执行（只重建两个存储过程）。
-- 2026-11-03 奖池精准扣除：
--   1) 送奖开奖：按子游戏上报的本手牌型得分（牌型倍率×押注，比倍爆机/赛跑活动/彩金不再计入，见服务端配套）扣除；
--      奖池余额不足时只扣到 0，不出现负数。AwardDiamonds 仍记玩家实际得到的牌型得分，BookedDiamonds 记实际扣除。
--   2) 放水：累计实际净收益扣除，但最多扣到放水目标（TargetCoins）为止；余额不足同样扣到 0。
--   3) 控牌与放水重叠返还沿用原口径（只按实际已扣的控牌支出排除重叠），重叠补扣同样不使余额为负。
-- 奖池明细 35 天保留由后台 B_PrizePool.CleanupLedger 按小时分批清理，本脚本不建 MySQL event。
-- 不改历史流水与余额；已为负的历史余额保持原样，此后不会继续往下扣。
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
 DECLARE vTarget decimal(28,8);
 DECLARE vDelta decimal(28,8);
 SET vAgent=NULL;
 SELECT AgentID INTO vAgent FROM agentprizecontrol WHERE ControlId=pControl AND UserID=pUser AND ControlMode=5;
 IF vAgent IS NULL OR pRate<=0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid funded release delta'; END IF;
 SELECT Balance INTO vBalance FROM agentprizepool WHERE AgentID=vAgent FOR UPDATE;
 IF EXISTS(SELECT 1 FROM agentprizeledger WHERE EventId=pEvent) THEN LEAVE proc; END IF;
 SELECT BookedDiamonds,NetDiamonds,CardDiamonds INTO vBooked,vNet,vCards FROM agentprizecontrol WHERE ControlId=pControl FOR UPDATE;
 SELECT IFNULL(MAX(TargetCoins),0) INTO vTarget FROM usercontrolstatus WHERE ID=pControl;
 SET vNet=vNet+CAST(pUnits AS DECIMAL(28,8))/pRate;
 -- 放水到达目标即按目标值精准扣除，超出目标的最后一手不再从奖池扣
 SET vNew=GREATEST(0,vNet-vCards);
 IF vTarget>0 THEN SET vNew=LEAST(vNew,vTarget); END IF;
 SET vDelta=vNew-vBooked;
 -- 只限制“继续扣款”方向：余额不足时扣到 0；返还方向不受限
 IF vDelta>0 THEN SET vDelta=LEAST(vDelta,GREATEST(vBalance,0)); END IF;
 SET vNew=vBooked+vDelta;
 UPDATE agentprizepool SET Balance=Balance-vDelta WHERE AgentID=vAgent;
 UPDATE agentprizecontrol SET BookedDiamonds=vNew,NetDiamonds=vNet,AwardDiamonds=GREATEST(0,vNet),
  ActualGameId=pGame,ActualTableId=pTable,ProgressTime=pTime,AwardTime=IF(pUnits>0,pTime,AwardTime) WHERE ControlId=pControl;
 INSERT INTO agentprizeledger(EventId,AgentID,ControlId,Kind,ChangeDiamonds,BalanceAfter,UserID,GameId,TableId,RecTime)
  VALUES(pEvent,vAgent,pControl,4,-vDelta,vBalance-vDelta,pUser,pGame,pTable,pTime);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS agentprize_record_award;
DELIMITER $$
CREATE PROCEDURE agentprize_record_award(IN pEvent varchar(96), IN pControl int, IN pUser varchar(50),
 IN pGame int, IN pTable bigint, IN pType varchar(100), IN pUnits bigint, IN pRate bigint, IN pTime datetime(6))
proc: BEGIN
 DECLARE vAgent varchar(50);
 DECLARE vBalance decimal(28,8);
 DECLARE vAmount decimal(28,8);
 DECLARE vPaid decimal(28,8);
 DECLARE vRelease int DEFAULT NULL;
 DECLARE vReleaseAgent varchar(50);
 DECLARE vBooked decimal(28,8);
 DECLARE vNet decimal(28,8);
 DECLARE vCards decimal(28,8);
 DECLARE vNew decimal(28,8);
 DECLARE vTarget decimal(28,8);
 DECLARE vReleaseBalance decimal(28,8);
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
 -- 送出得分大于奖池余额时扣到 0 为止，奖池不出现负数
 SET vPaid=LEAST(vAmount,GREATEST(vBalance,0));
 UPDATE agentprizepool SET Balance=Balance-vPaid WHERE AgentID=vAgent;
 INSERT INTO agentprizeledger(EventId,AgentID,ControlId,Kind,ChangeDiamonds,BalanceAfter,UserID,GameId,TableId,CardType,RecTime)
  VALUES(pEvent,vAgent,pControl,3,-vPaid,vBalance-vPaid,pUser,pGame,pTable,pType,pTime);
 UPDATE agentprizecontrol SET BookedDiamonds=BookedDiamonds+vPaid,AwardDiamonds=AwardDiamonds+vAmount,
  ActualGameId=pGame,ActualTableId=pTable,ActualCardType=pType,AwardTime=pTime WHERE ControlId=pControl;

 -- 同一玩家并行放水的净收益已包含控牌奖金，按事件实际发生时间排除重叠部分（按实际已扣的控牌支出）。
 SELECT MAX(c.ID) INTO vRelease FROM usercontrolstatus c JOIN agentprizecontrol p ON p.ControlId=c.ID
  WHERE c.UserID=pUser AND c.GameType=9 AND c.ControlMode=5 AND c.CreatedTime<=pTime
    AND (c.ExpiredTime IS NULL OR c.ExpiredTime>=pTime);
 IF vRelease IS NOT NULL THEN
  SELECT p.AgentID,p.BookedDiamonds,p.NetDiamonds,p.Revision,c.TargetCoins INTO vReleaseAgent,vBooked,vNet,vRevision,vTarget
   FROM agentprizecontrol p JOIN usercontrolstatus c ON c.ID=p.ControlId WHERE p.ControlId=vRelease FOR UPDATE;
  SELECT IFNULL(SUM(-l.ChangeDiamonds),0) INTO vCards FROM agentprizeledger l JOIN usercontrolstatus c ON c.ID=vRelease
   WHERE l.Kind=3 AND l.UserID=pUser AND l.RecTime>=c.CreatedTime AND (c.ExpiredTime IS NULL OR l.RecTime<=c.ExpiredTime);
  SET vNew=GREATEST(0,vNet-vCards);
  IF vTarget>0 THEN SET vNew=LEAST(vNew,vTarget); END IF;
  IF vNew>vBooked THEN
   SELECT Balance INTO vReleaseBalance FROM agentprizepool WHERE AgentID=vReleaseAgent FOR UPDATE;
   SET vNew=vBooked+LEAST(vNew-vBooked,GREATEST(vReleaseBalance,0));
  END IF;
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
