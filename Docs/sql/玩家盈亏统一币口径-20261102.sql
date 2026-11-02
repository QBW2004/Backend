-- Apply before deploying the paired backend, center and game-server update.
-- Existing WINLOSS values are preserved here; historical corrections are separate.
ALTER TABLE user_daily_winloss MODIFY COLUMN WINLOSS DECIMAL(28,8) NOT NULL DEFAULT 0;

CREATE TABLE IF NOT EXISTS user_winloss_ledger (
    EventID VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    UserID VARCHAR(50) NOT NULL,
    DAY DATE NOT NULL,
    LoginSession BIGINT UNSIGNED NOT NULL,
    GameID INT UNSIGNED NOT NULL,
    RawDelta BIGINT NOT NULL,
    UnitsPerCoin INT UNSIGNED NOT NULL,
    CoinDelta DECIMAL(28,8) NOT NULL,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (EventID),
    KEY idx_uwl_user_day (UserID, DAY),
    KEY idx_uwl_day (DAY)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
