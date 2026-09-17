-- Read-only: is accountlog populated (login/enter-game log with IP)?
SELECT COUNT(*) AS accountlog_rows FROM accountlog;
SELECT * FROM accountlog ORDER BY ID DESC LIMIT 20;
SELECT COUNT(*) AS videogamecoinrecord_rows FROM videogamecoinrecord;
