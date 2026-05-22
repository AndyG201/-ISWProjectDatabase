-- =========================
-- BASE TABLES
-- =========================

CREATE TABLE ROLE (
  idRole        SERIAL PRIMARY KEY,
  roleName      VARCHAR(50) NOT NULL
);

CREATE TABLE "USER" (
  idUser        SERIAL PRIMARY KEY,
  firstName     VARCHAR(100) NOT NULL,
  lastName      VARCHAR(100) NOT NULL,
  identification INT NOT NULL,
  email         VARCHAR(100) UNIQUE NOT NULL,
  password      VARCHAR(255) NOT NULL,
  createdAt     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  idRole        INT DEFAULT 2, -- Default to fan role
  verified      BOOLEAN DEFAULT FALSE,
  verificationCode VARCHAR(6),
  accountStatus VARCHAR(20) DEFAULT 'activo',

  CONSTRAINT fkUserRole
  FOREIGN KEY (idRole)
  REFERENCES ROLE(idRole)
);

-- =========================
-- LOCATION
-- =========================

CREATE TABLE COUNTRY (
  idCountry     SERIAL PRIMARY KEY,
  countryName   VARCHAR(100) NOT NULL
);

CREATE TABLE CITY (
  idCity        SERIAL PRIMARY KEY,
  cityName      VARCHAR(100) NOT NULL,
  idCountry     INT,

  CONSTRAINT fkCityCountry
  FOREIGN KEY (idCountry)
  REFERENCES COUNTRY(idCountry)
);

CREATE TABLE STADIUM (
  idStadium     SERIAL PRIMARY KEY,
  stadiumName   VARCHAR(100) NOT NULL,
  capacity      INT NOT NULL,
  idCity        INT,

  CONSTRAINT fkStadiumCity
  FOREIGN KEY (idCity)
  REFERENCES CITY(idCity)
);

-- =========================
-- FOOTBALL
-- =========================

CREATE TABLE TEAM (
  idTeam        SERIAL PRIMARY KEY,
  teamName      VARCHAR(100) NOT NULL,
  flagUrl       TEXT NOT NULL
);

CREATE TABLE MATCH (
  idMatch       SERIAL PRIMARY KEY,
  matchDate     TIMESTAMP NOT NULL,
  idStadium     INT,
  home_team_id  INT,
  away_team_id  INT,
  home_goals    INT DEFAULT 0,
  away_goals    INT DEFAULT 0,
  status        VARCHAR(50) DEFAULT 'SCHEDULED',

  CONSTRAINT fkMatchStadium
  FOREIGN KEY (idStadium)
  REFERENCES STADIUM(idStadium),
  
  FOREIGN KEY (home_team_id) REFERENCES TEAM(idTeam),
  FOREIGN KEY (away_team_id) REFERENCES TEAM(idTeam)
);

CREATE TABLE MATCH_TEAM (
  id_match INT,
  id_team INT,
  PRIMARY KEY (id_match, id_team),
  FOREIGN KEY (id_match) REFERENCES MATCH(idMatch),
  FOREIGN KEY (id_team) REFERENCES TEAM(idTeam)
);

CREATE TABLE MATCH_EVENT (
  id_event SERIAL PRIMARY KEY,
  event_type VARCHAR(50),
  minute INT,
  description TEXT,
  id_match INT,
  FOREIGN KEY (id_match) REFERENCES MATCH(idMatch)
);

-- =========================
-- TICKETS
-- =========================

CREATE TABLE TICKET (
  id_ticket SERIAL PRIMARY KEY,
  status VARCHAR(50) DEFAULT 'Disponible',
  price NUMERIC(10,2),
  reserved_at TIMESTAMP,
  expiration_date TIMESTAMP,
  paid_at TIMESTAMP,
  correlation_id VARCHAR(36),
  id_match INT,
  id_user INT,
  FOREIGN KEY (id_match) REFERENCES MATCH(idMatch),
  FOREIGN KEY (id_user) REFERENCES "USER"(idUser)
);

CREATE TABLE TICKET_HISTORY (
  id_history SERIAL PRIMARY KEY,
  status VARCHAR(50),
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  reason TEXT,
  id_ticket INT,
  FOREIGN KEY (id_ticket) REFERENCES TICKET(id_ticket)
);

-- =========================
-- PAYMENTS
-- =========================

CREATE TABLE PAYMENT (
  id_payment SERIAL PRIMARY KEY,
  status VARCHAR(50),
  amount NUMERIC(10,2),
  payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  provider VARCHAR(100),
  stripe_intent_id VARCHAR(100),
  id_user INT,
  FOREIGN KEY (id_user) REFERENCES "USER"(idUser)
);

CREATE TABLE TRANSFER (
  id_transfer SERIAL PRIMARY KEY,
  transfer_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  correlation_id VARCHAR(36),
  from_user_id INT,
  to_user_id INT,
  ticket_id INT,
  id_payment INT,
  FOREIGN KEY (from_user_id) REFERENCES "USER"(idUser),
  FOREIGN KEY (to_user_id) REFERENCES "USER"(idUser),
  FOREIGN KEY (ticket_id) REFERENCES TICKET(id_ticket),
  FOREIGN KEY (id_payment) REFERENCES PAYMENT(id_payment)
);

-- =========================
-- WALLET
-- =========================

CREATE TABLE WALLET (
  id_wallet SERIAL PRIMARY KEY,
  balance NUMERIC(10,2) DEFAULT 0,
  id_user INT UNIQUE,
  FOREIGN KEY (id_user) REFERENCES "USER"(idUser)
);

CREATE TABLE WALLET_TRANSACTION (
  id_transaction SERIAL PRIMARY KEY,
  transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  type VARCHAR(50),
  amount NUMERIC(10,2),
  reason TEXT,
  id_wallet INT,
  FOREIGN KEY (id_wallet) REFERENCES WALLET(id_wallet)
);

-- =========================
-- POOL / PREDICTIONS
-- =========================

CREATE TABLE POOL_GROUP (
  id_group SERIAL PRIMARY KEY,
  name VARCHAR(100),
  invitation_code VARCHAR(50)
);

CREATE TABLE USER_GROUP (
  id_user INT,
  id_group INT,
  is_admin BOOLEAN,
  PRIMARY KEY (id_user, id_group),
  FOREIGN KEY (id_user) REFERENCES "USER"(idUser),
  FOREIGN KEY (id_group) REFERENCES POOL_GROUP(id_group)
);

CREATE TABLE PREDICTION (
  id_prediction SERIAL PRIMARY KEY,
  home_goals INT,
  away_goals INT,
  id_user INT,
  id_match INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  version_id INT DEFAULT 1,
  FOREIGN KEY (id_user) REFERENCES "USER"(idUser),
  FOREIGN KEY (id_match) REFERENCES MATCH(idMatch)
);

-- =========================
-- ALBUM (STICKERS)
-- =========================

CREATE TABLE RARYTY_CAT (
  rarety_cat_id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE STICKER (
  id_sticker SERIAL PRIMARY KEY,
  name VARCHAR(100),
  category VARCHAR(50),
  rarity VARCHAR(50),
  team VARCHAR(100),
  panini_code VARCHAR(50),
  rarety_cat_id INT,
  FOREIGN KEY (rarety_cat_id) REFERENCES RARYTY_CAT(rarety_cat_id)
);

CREATE TABLE ALBUM (
  id_album SERIAL PRIMARY KEY,
  id_user INT UNIQUE,
  pack_balance INT DEFAULT 0,
  coins INT DEFAULT 0,
  last_reward_date DATE,
  FOREIGN KEY (id_user) REFERENCES "USER"(idUser)
);

CREATE TABLE PACK (
  id_pack SERIAL PRIMARY KEY,
  id_user INT,
  opened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_user) REFERENCES "USER"(idUser)
);

CREATE TABLE PACK_STICKER (
  id SERIAL PRIMARY KEY,
  id_pack INT,
  id_sticker INT,
  FOREIGN KEY (id_pack) REFERENCES PACK(id_pack),
  FOREIGN KEY (id_sticker) REFERENCES STICKER(id_sticker)
);

CREATE TABLE ALBUM_STICKER (
  id SERIAL PRIMARY KEY,
  id_album INT,
  id_sticker INT,
  FOREIGN KEY (id_album) REFERENCES ALBUM(id_album),
  FOREIGN KEY (id_sticker) REFERENCES STICKER(id_sticker)
);

-- =========================
-- PROMO CODES
-- =========================

CREATE TABLE PROMO_CODE (
  id SERIAL PRIMARY KEY,
  code VARCHAR(50) UNIQUE NOT NULL,
  reward_packs INT DEFAULT 0,
  reward_coins INT DEFAULT 0,
  max_uses INT,
  current_uses INT DEFAULT 0,
  expiry_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE PROMO_CODE_USAGE (
  id SERIAL PRIMARY KEY,
  promo_code_id INT,
  user_id INT,
  used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (promo_code_id) REFERENCES PROMO_CODE(id),
  FOREIGN KEY (user_id) REFERENCES "USER"(idUser)
);

-- =========================
-- TRADES
-- =========================

CREATE TABLE TRADE_PROPOSAL (
  id SERIAL PRIMARY KEY,
  proposer_id INT,
  receiver_id INT,
  offered_sticker_id INT,
  requested_sticker_id INT,
  status VARCHAR(50) DEFAULT 'PENDING_CONFIRMATION',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (proposer_id) REFERENCES "USER"(idUser),
  FOREIGN KEY (receiver_id) REFERENCES "USER"(idUser),
  FOREIGN KEY (offered_sticker_id) REFERENCES STICKER(id_sticker),
  FOREIGN KEY (requested_sticker_id) REFERENCES STICKER(id_sticker)
);

-- =========================
-- NOTIFICATIONS
-- =========================

CREATE TABLE NOTIFICATION (
  id_notification SERIAL PRIMARY KEY,
  message TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  channel VARCHAR(50)
);

CREATE TABLE USER_NOTIFICATION (
  id_user INT,
  id_notification INT,
  PRIMARY KEY (id_user, id_notification),
  FOREIGN KEY (id_user) REFERENCES "USER"(idUser),
  FOREIGN KEY (id_notification) REFERENCES NOTIFICATION(id_notification)
);

-- =========================
-- AUDIT
-- =========================

CREATE TABLE AUDIT_LOG (
  id_audit SERIAL PRIMARY KEY,
  correlation_id VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  payload TEXT,
  affected_entity VARCHAR(100),
  action VARCHAR(50),
  result VARCHAR(50)
);

-- =========================
-- SPORTS BETTING
-- =========================

CREATE TABLE sports_bet (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  match_id INT NOT NULL,
  home_name VARCHAR(100) NOT NULL,
  away_name VARCHAR(100) NOT NULL,
  bet_type VARCHAR(30) NOT NULL,
  bet_label VARCHAR(100) NOT NULL,
  odds DOUBLE PRECISION NOT NULL,
  stake INT NOT NULL,
  potential_win INT NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  settled_at TIMESTAMP,
  stripe_intent_id VARCHAR(255),
  FOREIGN KEY (user_id) REFERENCES "USER"(idUser)
);

-- =========================
-- COMMUNITY & SOCIAL FEED
-- =========================

CREATE TABLE post (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  group_id INT,
  content TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES "USER"(idUser),
  FOREIGN KEY (group_id) REFERENCES POOL_GROUP(id_group) ON DELETE CASCADE
);

CREATE TABLE post_image (
  id SERIAL PRIMARY KEY,
  post_id INT NOT NULL,
  image_data TEXT NOT NULL,
  position INT DEFAULT 0,
  FOREIGN KEY (post_id) REFERENCES post(id) ON DELETE CASCADE
);

CREATE TABLE post_like (
  post_id INT,
  user_id INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (post_id, user_id),
  FOREIGN KEY (post_id) REFERENCES post(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES "USER"(idUser)
);

CREATE TABLE post_comment (
  id SERIAL PRIMARY KEY,
  post_id INT NOT NULL,
  user_id INT NOT NULL,
  content TEXT NOT NULL,
  parent_id INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (post_id) REFERENCES post(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES "USER"(idUser),
  FOREIGN KEY (parent_id) REFERENCES post_comment(id) ON DELETE CASCADE
);

CREATE TABLE comment_like (
  comment_id INT,
  user_id INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (comment_id, user_id),
  FOREIGN KEY (comment_id) REFERENCES post_comment(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES "USER"(idUser)
);

-- =========================
-- EVENTS
-- =========================

CREATE TABLE event (
  event_id SERIAL PRIMARY KEY,
  type VARCHAR(50),
  description TEXT,
  audit_id INT,
  FOREIGN KEY (audit_id) REFERENCES AUDIT_LOG(id_audit)
);

-- =========================
-- INITIAL DATA
-- =========================

INSERT INTO ROLE (roleName) VALUES ('Admin'), ('Fan');
