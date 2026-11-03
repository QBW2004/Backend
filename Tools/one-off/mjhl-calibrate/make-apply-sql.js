// 生成线上 apply.sql：mjhl_agent_config 两行 + 历史两行 + parabetroom/pararoom 默认桌台口径对齐
const fs = require('fs');
const path = require('path');

const json = fs.readFileSync(path.join(__dirname, 'out', 'config.json'), 'utf8').trim();
const report = JSON.parse(fs.readFileSync(path.join(__dirname, 'out', 'report.json'), 'utf8'));
const hash = report.configHash;
const summary = report.simulated;
const lines = ['*', 'sucai', 'suqieradmin'];
const actor = 'atmadmin';

const esc = s => s.replace(/'/g, "''");

let sql = '';
sql += "-- 麻将胡了(54) 代理线参数 + 默认桌台房间级口径修正\n";
sql += "-- configJson/hash 由本地 RTP 调校产物原样嵌入：sha256(configJson)=" + hash + "\n";
sql += "-- RTP 实测 " + report.rtp.toFixed(4) + "% / " + report.samples + " 局（目标 80±1pp 内）\n";
sql += "START TRANSACTION;\n\n";
for (const line of lines) {
  sql += "INSERT INTO mjhl_agent_config (GameId,LineAgent,Revision,ConfigJson,ConfigHash,UpdatedBy,UpdatedAt) VALUES\n";
  sql += "(54,'" + esc(line) + "',1,'" + esc(json) + "','" + hash + "','" + actor + "',UTC_TIMESTAMP());\n";
}
sql += "\n";
for (const line of lines) {
  sql += "INSERT INTO mjhl_agent_config_history (GameId,LineAgent,Revision,ConfigJson,ConfigHash,UpdatedBy,UpdatedAt,SimulationSummary) VALUES\n";
  sql += "(54,'" + esc(line) + "',1,'" + esc(json) + "','" + hash + "','" + actor + "',UTC_TIMESTAMP(),'" + esc(summary) + "');\n";
}
sql += "\n";
sql += "-- 房间级回退参数对齐 1:1 兑换与 0.4~60 档位（整数列按 paralaba 口径存×10 单位；\n";
sql += "-- BetScores 为透传字符串，仅后台桌台页原样展示，存显示口径）\n";
sql += "UPDATE parabetroom SET BET_MIN=4,BET_MAX=600,BET_MIN_VICE=4,BET_MAX_VICE=600,\n";
sql += "  BET_MIN_DRAW=4,BET_MAX_DRAW=600,EX_COIN=1,COIN_SC=1,\n";
sql += "  BetScores='0.4,0.8,1.2,1.6,2,4,6,10,15,20,30,40,60',DefaultBetIndex=6\n";
sql += "WHERE ID=54000 AND GAME_ID=54;\n";
sql += "UPDATE pararoom SET BET_MIN=4,BET_MAX=600,EX_COIN=1,COIN_SC=1 WHERE ID=54000 AND GAME_ID=54;\n";
sql += "COMMIT;\n\n";
sql += "SELECT GameId,LineAgent,Revision,ConfigHash,UpdatedBy,UpdatedAt,LEFT(ConfigJson,80) j FROM mjhl_agent_config;\n";
sql += "SELECT GameId,LineAgent,Revision,LEFT(SimulationSummary,60) s FROM mjhl_agent_config_history;\n";
sql += "SELECT ID,BET_MIN,BET_MAX,EX_COIN,COIN_SC,BetScores,DefaultBetIndex FROM parabetroom WHERE GAME_ID=54;\n";
sql += "SELECT ID,BET_MIN,BET_MAX,EX_COIN,COIN_SC FROM pararoom WHERE GAME_ID=54;\n";

fs.writeFileSync(path.join(__dirname, 'apply.sql'), sql, 'utf8');
console.log('apply.sql written,', sql.length, 'bytes');
