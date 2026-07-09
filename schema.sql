-- 1. Таблица admins
CREATE TABLE IF NOT EXISTS admins (
  ckey VARCHAR(100) PRIMARY KEY NOT NULL,
  `rank` INTEGER NOT NULL
);

REPLACE INTO admins (ckey, `rank`) VALUES ('headswe', 6);

-- 2. Таблица backpack
CREATE TABLE IF NOT EXISTS backpack (
  ckey VARCHAR(100) NOT NULL,
  `type` TEXT NOT NULL
);

-- 3. Таблица bans
CREATE TABLE IF NOT EXISTS bans (
  ckey       VARCHAR(100) NOT NULL,
  computerid VARCHAR(255) NOT NULL,
  ips        VARCHAR(255) NOT NULL,
  reason     TEXT NOT NULL,
  bannedby   VARCHAR(100) NOT NULL,
  temp       INTEGER NOT NULL, -- 0 = permabanned
  minute     INTEGER NOT NULL DEFAULT 0,
  timebanned TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 4. Таблица books
CREATE TABLE IF NOT EXISTS books (
  id     INT AUTO_INCREMENT PRIMARY KEY,
  ckey   VARCHAR(100) NOT NULL,
  title  VARCHAR(255) NOT NULL,
  author VARCHAR(255) NOT NULL,
  `text`   TEXT NOT NULL,
  cat    INTEGER NOT NULL DEFAULT 1
);

-- 5. Таблица changelog
CREATE TABLE IF NOT EXISTS changelog (
  id      INT AUTO_INCREMENT PRIMARY KEY,
  bywho   VARCHAR(100) NOT NULL,
  changes TEXT NOT NULL,
  `date`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 6. Таблица config
CREATE TABLE IF NOT EXISTS config (
  motd TEXT NOT NULL
);

-- 7. Таблица crban
CREATE TABLE IF NOT EXISTS crban (
  ckey       VARCHAR(100) PRIMARY KEY NOT NULL,
  ips        VARCHAR(255) NOT NULL,
  reason     TEXT NOT NULL,
  bannedby   VARCHAR(100) NOT NULL,
  `time`       DATETIME NOT NULL,
  unban_time DATETIME DEFAULT NULL
);
CREATE INDEX crban_bannedby ON crban (bannedby);

-- 8. Таблица crban_past
CREATE TABLE IF NOT EXISTS crban_past (
  CKey      VARCHAR(100) NOT NULL,
  Banner    VARCHAR(100) NOT NULL,
  BanReason TEXT NOT NULL,
  BanTime   DATETIME NOT NULL,
  UnbanTime DATETIME DEFAULT NULL,
  Unbanned  DATETIME DEFAULT NULL,
  Unbanner  VARCHAR(100) DEFAULT NULL
);
CREATE INDEX crban_past_ckey ON crban_past (CKey);
CREATE INDEX crban_past_banner ON crban_past (Banner);

-- 9. Таблица currentplayers
CREATE TABLE IF NOT EXISTS currentplayers (
  `name`    VARCHAR(100) PRIMARY KEY NOT NULL,
  playing INTEGER NOT NULL DEFAULT 1
);

-- 10. Таблица deathlog
CREATE TABLE IF NOT EXISTS deathlog (
  ckey         VARCHAR(100) NOT NULL,
  location     VARCHAR(255) NOT NULL,
  lastattacker VARCHAR(100) NOT NULL,
  ToD          VARCHAR(100) NOT NULL,
  health       VARCHAR(100) NOT NULL,
  lasthit      VARCHAR(100) NOT NULL
);

-- 11. Таблица invites
CREATE TABLE IF NOT EXISTS invites (
  ckey VARCHAR(100) NOT NULL
);

-- 12. Таблица jobban
CREATE TABLE IF NOT EXISTS jobban (
  ckey VARCHAR(100) NOT NULL,
  `rank` VARCHAR(100) NOT NULL,
  UNIQUE (ckey, `rank`)
);
CREATE INDEX jobban_ckey ON jobban (ckey);

-- 13. Таблица jobbanlog
CREATE TABLE IF NOT EXISTS jobbanlog (
  ckey       VARCHAR(100) NOT NULL,
  targetckey VARCHAR(100) NOT NULL,
  `rank`       VARCHAR(100) NOT NULL,
  `when`       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  why        TEXT NOT NULL
);
CREATE INDEX jobbanlog_ckey ON jobbanlog (ckey);

-- 14. Таблица medals
CREATE TABLE IF NOT EXISTS medals (
  ckey      VARCHAR(100) NOT NULL,
  medal     VARCHAR(100) NOT NULL,
  medaldesc TEXT NOT NULL,
  medaldiff VARCHAR(50) NOT NULL,
  UNIQUE (ckey, medal)
);
CREATE INDEX medals_ckey ON medals (ckey);

-- Используем INSERT IGNORE вместо ON CONFLICT IGNORE
INSERT IGNORE INTO medals (ckey, medal, medaldesc, medaldiff) VALUES
	('headswe', 'First Timer', 'Welcome!', 'easy'),
	('headswe', 'Downsizing', 'You are no longer a profitable asset.', 'easy'),
	('headswe', 'Broke Yarrr Bones!', 'Break a bone.', 'easy'),
	('wingman89', 'First Timer', 'Welcome!', 'easy'),
	('zuhayr', 'First Timer', 'Welcome!', 'easy');

-- 15. Таблица players
CREATE TABLE IF NOT EXISTS players (
  `id`                  INT AUTO_INCREMENT PRIMARY KEY, -- Заменил 'index', так как это зарезервированное слово
  ckey                  VARCHAR(100) NOT NULL,
  slot                  INTEGER NOT NULL,
  slotname              VARCHAR(255) NOT NULL,
  real_name             VARCHAR(255) NOT NULL,
  gender                VARCHAR(20) NOT NULL,
  age                   INTEGER NOT NULL,
  occupation1           VARCHAR(100) NOT NULL,
  occupation2           VARCHAR(100) NOT NULL,
  occupation3           VARCHAR(100) NOT NULL,
  hair_color            VARCHAR(20) NOT NULL,
  facial_color          VARCHAR(20) NOT NULL,
  skin_tone             INTEGER NOT NULL,
  hairstyle             VARCHAR(100) NOT NULL,
  facialstyle           VARCHAR(100) NOT NULL,
  eyecolor              VARCHAR(20) NOT NULL,
  bloodtype             VARCHAR(5) NOT NULL,
  be_syndicate          INTEGER NOT NULL,
  be_nuke_agent         INTEGER NOT NULL,
  be_takeover_agent     INTEGER NOT NULL,
  underwear             INTEGER NOT NULL,
  name_is_always_random INTEGER NOT NULL,
  bios                  TEXT NOT NULL,
  disabilities          INTEGER NOT NULL
);

-- 16. Таблица ranks
CREATE TABLE IF NOT EXISTS ranks (
  `Rank` INTEGER NOT NULL,
  `Desc` TEXT NOT NULL
);

INSERT INTO ranks (`Rank`, `Desc`) VALUES
	(6, 'Host'),
	(5, 'Coder'),
	(4, 'Super Administrator'),
	(3, 'Primary Administrator'),
	(2, 'Administrator'),
	(1, 'Secondary Administrator');

-- 17. Таблица roundsjoined
CREATE TABLE IF NOT EXISTS roundsjoined (
  ckey VARCHAR(100) NOT NULL
);

-- 18. Таблица roundsurvived
CREATE TABLE IF NOT EXISTS roundsurvived (
  ckey VARCHAR(100) NOT NULL
);

-- 19. Таблица stats
CREATE TABLE IF NOT EXISTS stats (
  ckey         VARCHAR(100) PRIMARY KEY NOT NULL,
  deaths       INTEGER NOT NULL DEFAULT 0,
  roundsplayed INTEGER NOT NULL DEFAULT 0,
  suicides     INTEGER NOT NULL DEFAULT 0,
  traitorwin   INTEGER NOT NULL DEFAULT 0
);

-- 20. Таблица suggest
CREATE TABLE IF NOT EXISTS suggest (
  id       INT AUTO_INCREMENT PRIMARY KEY,
  userid   INTEGER NOT NULL,
  username VARCHAR(100) NOT NULL,
  title    VARCHAR(255) NOT NULL,
  `desc`     TEXT NOT NULL,
  link     VARCHAR(255) NOT NULL,
  votes    INTEGER NOT NULL DEFAULT 0
);

-- 21. Таблица traitorbuy
CREATE TABLE IF NOT EXISTS traitorbuy (
  `type` TEXT NOT NULL
);

-- 22. Таблица traitorlogs
CREATE TABLE IF NOT EXISTS traitorlogs (
  CKey        VARCHAR(100) NOT NULL,
  Objective   TEXT NOT NULL,
  Succeeded   INTEGER NOT NULL,
  Spawned     TEXT NOT NULL,
  Occupation  VARCHAR(100) NOT NULL,
  PlayerCount INTEGER NOT NULL
);
CREATE INDEX traitorlogs_ckey ON traitorlogs (CKey);
CREATE INDEX traitorlogs_succeeded ON traitorlogs (Succeeded);

-- 23. Таблица unbans
CREATE TABLE IF NOT EXISTS unbans (
  ckey       VARCHAR(100) NOT NULL,
  computerid VARCHAR(255) NOT NULL,
  ips        VARCHAR(255) NOT NULL,
  reason     TEXT NOT NULL,
  bannedby   VARCHAR(100) NOT NULL,
  temp       INTEGER NOT NULL,
  minutes    INTEGER NOT NULL,
  timebanned TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 24. Таблица voters
CREATE TABLE IF NOT EXISTS voters (
  username VARCHAR(100) PRIMARY KEY NOT NULL,
  votes    INTEGER NOT NULL
);

-- 25. Таблица web_log
CREATE TABLE IF NOT EXISTS web_log (
  `type`    VARCHAR(50) NOT NULL,
  message TEXT NOT NULL,
  bywho   VARCHAR(100) NOT NULL,
  `time`    DATETIME NOT NULL
);