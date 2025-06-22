-- Xóa dữ liệu bảng phụ thuộc trước
DELETE FROM admins;
DELETE FROM session_monster_kills;
DELETE FROM character_equipment;
DELETE FROM game_sessions;
DELETE FROM achievements;
DELETE FROM characters;
DELETE FROM leaderboard;

-- Xóa dữ liệu bảng độc lập hoặc ít bị phụ thuộc hơn
DELETE FROM items;
DELETE FROM monsters;
DELETE FROM players;


DROP TABLE IF EXISTS character_equipment;

UPDATE game_sessions
SET final_score = NULL;

DROP TABLE IF EXISTS leaderboard;

DELETE FROM player_hp_events WHERE session_id IN (SELECT session_id FROM game_sessions);
DELETE FROM game_sessions;  -- Sau đó mới xóa được

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT trigger_name, event_object_table
        FROM information_schema.triggers
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS %I ON %I;', r.trigger_name, r.event_object_table);
    END LOOP;
END$$;

-- Dọn dẹp trigger nếu đã tồn tại
DROP TRIGGER IF EXISTS trg_before_insert_combined ON session_monster_kills;
DROP TRIGGER IF EXISTS trg_boss_kill ON session_monster_kills;
DROP TRIGGER IF EXISTS trg_boss_kill_update ON session_monster_kills;

-- Dọn dẹp function nếu cần
DROP FUNCTION IF EXISTS trg_calc_points_and_update_score() CASCADE;
DROP FUNCTION IF EXISTS trg_boss_kill_updates() CASCADE;
DROP FUNCTION IF EXISTS trg_update_end_time_when_boss_killed() CASCADE;




-- Bảng người chơi
CREATE TABLE IF NOT EXISTS  players (
    player_id INT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    highest_score INT DEFAULT 0,
    time_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    
);




-- Chèn dữ liệu mẫu cho người chơi
-- Chèn dữ liệu mẫu KHÔNG cần highest_score
INSERT INTO players (player_id, username, email, password, time_created) VALUES
(1, 'player_one', 'player1@example.com', 'pass1', '2025-06-01 08:00:00'),
(2, 'dragonSlayer', 'dragon@example.com', 'sword123', '2025-06-01 08:10:00'),
(3, 'heroicKnight', 'knight@example.com', 'armor456', '2025-06-01 08:20:00'),
(4, 'shadowNinja', 'ninja@example.com', 'stealth789', '2025-06-01 08:30:00'),
(5, 'spaceRider', 'space@example.com', 'rocketpass', '2025-06-01 08:40:00'),
(6, 'ghostHunter', 'ghost@example.com', 'trap123', '2025-06-01 08:50:00'),
(7, 'magicElf', 'elf@example.com', 'bowpass', '2025-06-01 09:00:00'),
(8, 'zombieSurvivor', 'zombie@example.com', 'brains!', '2025-06-01 09:10:00'),
(9, 'wizardKing', 'wizard@example.com', 'spellcast', '2025-06-01 09:20:00'),
(10, 'cyberSamurai', 'cyber@example.com', 'techno321', '2025-06-01 09:30:00'),
(11, 'lavaBeast', 'lava@example.com', 'fire999', '2025-06-01 09:40:00'),
(12, 'iceQueen', 'ice@example.com', 'cold456', '2025-06-01 09:50:00'),
(13, 'stormBringer', 'storm@example.com', 'thunder123', '2025-06-01 10:00:00'),
(14, 'desertFox', 'fox@example.com', 'sneaky321', '2025-06-01 10:10:00'),
(15, 'metalGiant', 'metal@example.com', 'ironman', '2025-06-01 10:20:00'),
(16, 'nightRider', 'nightrider@example.com', 'midnight', '2025-06-01 10:30:00'),
(17, 'forestGuardian', 'forest@example.com', 'treesafe', '2025-06-01 10:40:00'),
(18, 'firePhoenix', 'phoenix@example.com', 'riseup', '2025-06-01 10:50:00'),
(19, 'sandAssassin', 'sand@example.com', 'blade987', '2025-06-01 11:00:00'),
(20, 'skyGlider', 'sky@example.com', 'float321', '2025-06-01 11:10:00');



CREATE TABLE leaderboard (
    leaderboard_id SERIAL PRIMARY KEY,
    player_id INT UNIQUE REFERENCES players(player_id),
    rank INT,
    highest_score INT,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng nhân vật
CREATE TABLE IF NOT EXISTS  characters (
    character_id INT PRIMARY KEY,
    max_hp INT NOT NULL DEFAULT 100,
    max_item_slots INT NOT NULL DEFAULT 2,
    player_id INT NOT NULL REFERENCES players(player_id)
);

-- Chèn dữ liệu mẫu cho nhân vật
INSERT INTO characters (character_id, max_hp, max_item_slots, player_id) VALUES
(1, 120, 2, 1),
(2, 100, 2, 2),
(3, 150, 2, 3),
(4, 90, 2, 4),
(5, 110, 2, 5),
(6, 95, 2, 6),
(7, 130, 2, 7),
(8, 105, 2, 8),
(9, 100, 2, 9),
(10, 140, 2, 10),
(11, 115, 2, 11),
(12, 125, 2, 12),
(13, 85, 2, 13),
(14, 150, 2, 14),
(15, 135, 2, 15),
(16, 100, 2, 16),
(17, 110, 2, 17),
(18, 95, 2, 18),
(19, 120, 2, 19),
(20, 100, 2, 20);




-- Bảng vũ khí
CREATE TABLE IF NOT EXISTS  items (
    item_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    type VARCHAR(50) NOT NULL,
    damage INT NOT NULL,
    rarity VARCHAR(20) NOT NULL
);

-- Chèn dữ liệu mẫu cho vũ khí
INSERT INTO items (item_id, name, type, damage, rarity) VALUES
(1, 'Shadow Blade', 'Sword', 50, 'Rare'),
(2, 'Phoenix Bow', 'Bow', 40, 'Epic'),
(3, 'Thunder Axe', 'Axe', 60, 'Legendary'),
(4, 'Dagger of Silence', 'Dagger', 30, 'Uncommon'),
(5, 'Frost Staff', 'Staff', 35, 'Rare'),
(6, 'Inferno Sword', 'Sword', 55, 'Epic'),
(7, 'Crystal Wand', 'Wand', 25, 'Common'),
(8, 'Steel Hammer', 'Hammer', 45, 'Uncommon'),
(9, 'Wind Spear', 'Spear', 40, 'Rare'),
(10, 'Golden Katana', 'Sword', 52, 'Legendary'),
(11, 'Bone Club', 'Club', 20, 'Common'),
(12, 'Poison Fang', 'Dagger', 32, 'Rare'),
(13, 'Dragon Fang Axe', 'Axe', 58, 'Epic'),
(14, 'Arcane Orb', 'Orb', 42, 'Rare'),
(15, 'Void Edge', 'Sword', 65, 'Legendary');


ALTER TABLE items
ALTER COLUMN item_id DROP IDENTITY IF EXISTS;

ALTER TABLE items
ALTER COLUMN item_id ADD GENERATED BY DEFAULT AS IDENTITY;

SELECT setval(
  pg_get_serial_sequence('items', 'item_id'),
  (SELECT MAX(item_id) FROM items)
);


-- Bảng quái vật
CREATE TABLE IF NOT EXISTS monsters (
    monster_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    hp INT NOT NULL,
    point INT NOT NULL,
    damage INT NOT NULL,
    type VARCHAR(20) NOT NULL,
    speed VARCHAR(20) NOT NULL
);

-- Chèn dữ liệu mẫu cho quái vật
INSERT INTO monsters (monster_id , name, hp, point, damage, type, speed) VALUES
(1 ,'Weak monster', 50, 10, 2, 'Normal', 'Fast'),
(2 ,'Strong monster', 400, 25, 10, 'Normal', 'Normal'),
(3 , 'Boss', 5000, 500, 999, 'Boss', 'Slow');

-- 1. Xóa IDENTITY cũ nếu có
ALTER TABLE monsters 
ALTER COLUMN monster_id DROP IDENTITY IF EXISTS;

-- 2. Gán lại thuộc tính IDENTITY để tự tăng
ALTER TABLE monsters 
ALTER COLUMN monster_id ADD GENERATED BY DEFAULT AS IDENTITY;

-- 3. Cập nhật giá trị sequence để tránh trùng lặp khóa
SELECT setval(
  pg_get_serial_sequence('monsters', 'monster_id'),
  (SELECT MAX(monster_id) FROM monsters)
);




-- Bảng thành tựu
CREATE TABLE IF NOT EXISTS achievements (
    achievement_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    condition_type VARCHAR(50) NOT NULL,
    condition_value INT NOT NULL
);


-- Chèn dữ liệu mẫu cho thành tựu
INSERT INTO achievements (achievement_id, name, description, condition_type, condition_value) VALUES
(1, 'First Blood', 'Defeat your first monster.', 'kills', 1),
(2, 'Monster Slayer', 'Defeat 100 monsters.', 'kills', 100),
(3, 'Treasure Hunter', 'Collect 50 items.', 'items_collected', 50),
(4, 'Champion', 'Win 10 game sessions.', 'wins', 10),
(5, 'Veteran Player', 'Play 100 sessions.', 'sessions_played', 100),
(6, 'Sharp Shooter', 'Achieve 10 headshots in a session.', 'headshots', 10),
(7, 'Invincible', 'Win 5 sessions in a row.', 'win_streak', 5),
(8, 'Explorer', 'Visit 20 different maps.', 'maps_visited', 20),
(9, 'Rich Guy', 'Earn 10,000 points.', 'points_earned', 10000),
(10, 'Collector', 'Own 20 unique items.', 'unique_items', 20),
(11, 'Speed Runner', 'Complete a session in under 5 minutes.', 'fast_sessions', 1),
(12, 'Perfect Game', 'Win a session without taking damage.', 'flawless_wins', 1);


-- 1. Xóa IDENTITY cũ nếu có
ALTER TABLE achievements 
ALTER COLUMN achievement_id DROP IDENTITY IF EXISTS;

-- 2. Gán lại thuộc tính IDENTITY để tự tăng
ALTER TABLE achievements 
ALTER COLUMN achievement_id ADD GENERATED BY DEFAULT AS IDENTITY;

-- 3. Cập nhật giá trị sequence để tránh trùng lặp khóa
SELECT setval(
  pg_get_serial_sequence('achievements', 'achievement_id'),
  (SELECT MAX(achievement_id) FROM achievements)
);




-- Bảng phiên chơi
CREATE TABLE IF NOT EXISTS game_sessions (
    session_id INT PRIMARY KEY,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    final_score INT,
    boss_killed BOOLEAN DEFAULT FALSE,
    boss_kill_time INT,
    player_id INT NOT NULL REFERENCES players(player_id),
    character_id INT NOT NULL REFERENCES characters(character_id)
);

-- Chèn dữ liệu mẫu cho phiên chơi
INSERT INTO game_sessions (session_id, start_time, player_id, character_id) VALUES
(1, '2025-06-01 10:00:00', 1, 1),
(2, '2025-06-01 11:00:00', 2, 2),
(3, '2025-06-02 14:30:00', 3, 3),
(4, '2025-06-03 16:00:00', 4, 4),
(5, '2025-06-03 17:00:00', 5, 5),
(6, '2025-06-04 09:10:00', 6, 6),
(7, '2025-06-05 12:00:00', 7, 7),
(8, '2025-06-05 13:00:00', 8, 8),
(9, '2025-06-06 15:00:00', 9, 9),
(10, '2025-06-07 18:00:00', 10, 10);





CREATE OR REPLACE FUNCTION update_highest_score()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE players
    SET highest_score = (
        SELECT MAX(final_score)
        FROM game_sessions
        WHERE player_id = NEW.player_id
    )
    WHERE player_id = NEW.player_id;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_highest_score ON game_sessions;

CREATE TRIGGER trg_update_highest_score
AFTER INSERT OR UPDATE OF final_score ON game_sessions
FOR EACH ROW
WHEN (NEW.final_score IS NOT NULL)
EXECUTE FUNCTION update_highest_score();



CREATE OR REPLACE FUNCTION refresh_leaderboard()
RETURNS VOID AS $$
BEGIN
    -- Xóa toàn bộ bảng để cập nhật lại từ đầu
    DELETE FROM leaderboard;

    -- Thêm lại tất cả người chơi có điểm > 0 và tính rank mới
    INSERT INTO leaderboard (player_id, rank, highest_score, last_updated)
    SELECT 
        p.player_id,
        ROW_NUMBER() OVER (ORDER BY p.highest_score DESC),
        p.highest_score,
        CURRENT_TIMESTAMP
    FROM players p
    WHERE p.highest_score > 0;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trg_refresh_leaderboard()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM refresh_leaderboard();
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auto_refresh_leaderboard
AFTER UPDATE OF highest_score ON players
FOR EACH ROW
WHEN (NEW.highest_score IS DISTINCT FROM OLD.highest_score)
EXECUTE FUNCTION trg_refresh_leaderboard();








--#################################################
-- Bảng quái vật bị tiêu diệt trong phiên chơi
CREATE TABLE IF NOT EXISTS session_monster_kills (
    session_id INT NOT NULL REFERENCES game_sessions(session_id),
    monster_id INT NOT NULL REFERENCES monsters(monster_id),
    kill_time INT NOT NULL, -- Thời gian tính từ start_time (giây)
    points_earned INT NOT NULL,
    PRIMARY KEY (session_id, monster_id, kill_time)
);


CREATE OR REPLACE FUNCTION trg_calc_points_and_update_score()
RETURNS TRIGGER AS $$
DECLARE
    monster_point INT;
BEGIN
    -- Lấy điểm của quái vật
    SELECT point INTO monster_point
    FROM monsters
    WHERE monster_id = NEW.monster_id;

    -- Gán vào NEW
    NEW.points_earned := monster_point;

    -- Cập nhật final_score (giả sử final_score ban đầu đã có)
    UPDATE game_sessions
    SET final_score = COALESCE(final_score, 0) + monster_point
    WHERE session_id = NEW.session_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_before_insert_combined
BEFORE INSERT ON session_monster_kills
FOR EACH ROW
EXECUTE FUNCTION trg_calc_points_and_update_score();


---------------------------------------------
CREATE OR REPLACE FUNCTION trg_boss_kill_updates()
RETURNS TRIGGER AS $$
DECLARE
    is_boss BOOLEAN;
    kill_timestamp TIMESTAMP;
BEGIN
    SELECT type = 'Boss' INTO is_boss
    FROM monsters WHERE monster_id = NEW.monster_id;

    IF is_boss THEN
        SELECT start_time + (NEW.kill_time || ' seconds')::interval
        INTO kill_timestamp
        FROM game_sessions WHERE session_id = NEW.session_id;

        UPDATE game_sessions
        SET end_time = kill_timestamp,
            boss_killed = TRUE,
            boss_kill_time = NEW.kill_time
        WHERE session_id = NEW.session_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_boss_kill
AFTER INSERT ON session_monster_kills
FOR EACH ROW
EXECUTE FUNCTION trg_boss_kill_updates();



CREATE OR REPLACE FUNCTION trg_update_end_time_when_boss_killed()
RETURNS TRIGGER AS $$
DECLARE
    is_boss BOOLEAN;
    kill_ts TIMESTAMP;
BEGIN
    -- Kiểm tra nếu là quái Boss
    SELECT (type = 'Boss') INTO is_boss
    FROM monsters
    WHERE monster_id = NEW.monster_id;

    -- Nếu là Boss thì cập nhật game_sessions
    IF is_boss THEN
        -- Tính thời gian giết boss dựa vào start_time
        SELECT start_time + (NEW.kill_time || ' seconds')::interval
        INTO kill_ts
        FROM game_sessions
        WHERE session_id = NEW.session_id;

        UPDATE game_sessions
        SET 
            boss_killed = TRUE,
            boss_kill_time = NEW.kill_time,
            end_time = kill_ts
        WHERE session_id = NEW.session_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_boss_kill_update ON session_monster_kills;

CREATE TRIGGER trg_boss_kill_update
AFTER INSERT ON session_monster_kills
FOR EACH ROW
EXECUTE FUNCTION trg_update_end_time_when_boss_killed();





-- Chèn dữ liệu mẫu cho quái vật bị tiêu diệt
INSERT INTO session_monster_kills (session_id, monster_id, kill_time) VALUES
(1, 1, 180),
(1, 3, 360),
(2, 1, 200),
(2, 2, 400),
(3, 3, 600),
(4, 1, 150),
(5, 2, 300),
(6, 1, 100),
(6, 2, 280),
(7, 3, 450),
(8, 1, 190),
(8, 1, 290),
(9, 2, 310),
(10, 3, 420);

DROP TABLE IF EXISTS player_hp_events;

CREATE TABLE IF NOT EXISTS player_hp_events (
    session_id INT REFERENCES game_sessions(session_id) ON DELETE CASCADE,
    character_id INT REFERENCES characters(character_id) ON DELETE CASCADE,
    event_time INT,  -- thời điểm trong phiên chơi (giây)
    new_hp INT CHECK (new_hp >= 0),
    PRIMARY KEY (session_id, character_id)
);

-- Hàm trigger để cập nhật end_time nếu người chơi chết
CREATE OR REPLACE FUNCTION trg_player_death()
RETURNS TRIGGER AS $$
DECLARE
    death_time TIMESTAMP;
BEGIN
    IF NEW.new_hp <= 0 THEN
        SELECT start_time + (NEW.event_time || ' seconds')::interval
        INTO death_time
        FROM game_sessions
        WHERE session_id = NEW.session_id;

        UPDATE game_sessions
        SET end_time = death_time
        WHERE session_id = NEW.session_id
        AND (end_time IS NULL OR death_time < end_time);  -- chỉ cập nhật nếu end_time chưa có hoặc sớm hơn
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_player_dies
AFTER INSERT ON player_hp_events
FOR EACH ROW
EXECUTE FUNCTION trg_player_death();


-- Thêm bản ghi giả định người chơi chết vào player_hp_events
INSERT INTO player_hp_events (session_id, character_id, event_time, new_hp)
SELECT gs.session_id, gs.character_id, (FLOOR(random() * 600) + 100)::INT, 0
FROM game_sessions gs
WHERE NOT EXISTS (
    SELECT 1 FROM session_monster_kills smk
    WHERE smk.session_id = gs.session_id
    AND smk.monster_id = 3  -- boss
);


CREATE TABLE IF NOT EXISTS session_achievements (
    session_id INT NOT NULL REFERENCES game_sessions(session_id) ON DELETE CASCADE,
    achievement_id INT NOT NULL REFERENCES achievements(achievement_id) ON DELETE CASCADE,
    PRIMARY KEY (session_id, achievement_id)
);

INSERT INTO session_achievements (session_id, achievement_id) VALUES
(1, 1),
(1, 2),
(2, 3),
(3, 1),
(4, 4),
(5, 2),
(6, 5),
(7, 3),
(8, 1),
(9, 4),
(10, 2);




-- Bảng trang bị của nhân vật
CREATE TABLE IF NOT EXISTS character_equipment (
    character_id INT NOT NULL REFERENCES characters(character_id),
    slot_number INT NOT NULL CHECK (slot_number BETWEEN 1 AND 2),
    item_id INT NOT NULL REFERENCES items(item_id),
    equipped_at TEXT NOT NULL,
    PRIMARY KEY (character_id, slot_number)
);



-- Chèn dữ liệu mẫu cho trang bị nhân vật
-- Character 1 được trang bị item 1 và item 2
INSERT INTO character_equipment (character_id, slot_number, item_id, equipped_at) VALUES
-- Character 1
(1, 1, 1, '2025-06-01 09:55:00'),
(1, 2, 2, '2025-06-01 09:55:00'),

-- Character 2
(2, 1, 3, '2025-06-01 10:55:00'),
(2, 2, 4, '2025-06-01 10:55:00'),

-- Character 3
(3, 1, 5, '2025-06-02 14:25:00'),
(3, 2, 6, '2025-06-02 14:25:00'),

-- Character 4
(4, 1, 7, '2025-06-03 15:55:00'),
(4, 2, 8, '2025-06-03 15:55:00'),

-- Character 5
(5, 1, 9, '2025-06-03 16:55:00'),
(5, 2, 10, '2025-06-03 16:55:00'),

-- Character 6
(6, 1, 11, '2025-06-04 09:05:00'),
(6, 2, 12, '2025-06-04 09:05:00'),

-- Character 7
(7, 1, 13, '2025-06-05 11:55:00'),
(7, 2, 14, '2025-06-05 11:55:00');











---------------------ADMIN------------------------------------

CREATE TABLE IF NOT EXISTS admins (
    admin_id INT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(200) NOT NULL
);

INSERT INTO admins (admin_id, username, email, password) VALUES
(1, 'kimphu', 'kimphu@example.com', '02'),
(2, 'admin2', 'admin2@example.com', 'adminpass2');

---------------------ADMIN--------------------



-- 1. Tạo bảng session_items (nếu chưa có)
CREATE TABLE IF NOT EXISTS session_items (
    session_id INT NOT NULL REFERENCES game_sessions(session_id) ON DELETE CASCADE,
    item_id INT NOT NULL REFERENCES items(item_id) ON DELETE CASCADE,
    damage INT,
    PRIMARY KEY (session_id, item_id)
);

INSERT INTO session_items (session_id, item_id, damage)
SELECT x.session_id, x.item_id, i.damage
FROM (
    VALUES 
        (1, 1), (1, 2),
        (2, 3), (2, 1),
        (3, 4), (3, 5),
        (4, 2), (4, 6),
        (5, 7), (5, 8),
        (6, 9), (6, 10),
        (7, 11), (7, 12),
        (8, 13), (8, 3),
        (9, 14), (9, 5),
        (10, 15), (10, 1)
) AS x(session_id, item_id)
JOIN items i ON i.item_id = x.item_id;



