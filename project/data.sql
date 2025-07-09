DO $$
BEGIN
    -- Tắt ràng buộc khóa ngoại tạm thời (nếu cần)
    -- EXECUTE 'SET session_replication_role = replica';

    -- Xóa dữ liệu theo thứ tự phụ thuộc
    DELETE FROM session_items;
    DELETE FROM session_boss_kill;
    DELETE FROM session_monster_kill;
    DELETE FROM session_character;
    DELETE FROM character_on_game;
    DELETE FROM game_sessions;
    DELETE FROM achievements;
    DELETE FROM items;
    DELETE FROM monsters;
    DELETE FROM characters;
    DELETE FROM players;
    DELETE FROM admins;

    -- Bật lại ràng buộc (nếu đã tắt)
    -- EXECUTE 'SET session_replication_role = DEFAULT';
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT event_object_table, trigger_name
        FROM information_schema.triggers
        WHERE trigger_schema = 'public'
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS %I ON %I;', r.trigger_name, r.event_object_table);
    END LOOP;
END $$;


CREATE TABLE IF NOT EXISTS players (
    player_id int PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    time_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    highest_score INT DEFAULT 0
);
INSERT INTO Players (player_id, username, email, password, time_created) VALUES
(1, 'player01', 'player01@example.com', 'pass01', '2024-06-01 10:00:00'),
(2, 'player02', 'player02@example.com', 'pass02', '2024-06-01 10:01:00'),
(3, 'player03', 'player03@example.com', 'pass03', '2024-06-01 10:02:00'),
(4, 'player04', 'player04@example.com', 'pass04', '2024-06-01 10:03:00'),
(5, 'player05', 'player05@example.com', 'pass05', '2024-06-01 10:04:00'),
(6, 'player06', 'player06@example.com', 'pass06', '2024-06-01 10:05:00'),
(7, 'player07', 'player07@example.com', 'pass07', '2024-06-01 10:06:00'),
(8, 'player08', 'player08@example.com', 'pass08', '2024-06-01 10:07:00'),
(9, 'player09', 'player09@example.com', 'pass09', '2024-06-01 10:08:00'),
(10, 'player10', 'player10@example.com', 'pass10', '2024-06-01 10:09:00'),
(11, 'player11', 'player11@example.com', 'pass11', '2024-06-01 10:10:00'),
(12, 'player12', 'player12@example.com', 'pass12', '2024-06-01 10:11:00'),
(13, 'player13', 'player13@example.com', 'pass13', '2024-06-01 10:12:00'),
(14, 'player14', 'player14@example.com', 'pass14', '2024-06-01 10:13:00'),
(15, 'player15', 'player15@example.com', 'pass15', '2024-06-01 10:14:00'),
(16, 'player16', 'player16@example.com', 'pass16', '2024-06-01 10:15:00'),
(17, 'player17', 'player17@example.com', 'pass17', '2024-06-01 10:16:00'),
(18, 'player18', 'player18@example.com', 'pass18', '2024-06-01 10:17:00'),
(19, 'player19', 'player19@example.com', 'pass19', '2024-06-01 10:18:00'),
(20, 'player20', 'player20@example.com', 'pass20', '2024-06-01 10:19:00'),
(21, 'player21', 'player21@example.com', 'pass21', '2024-06-01 10:20:00'),
(22, 'player22', 'player22@example.com', 'pass22', '2024-06-01 10:21:00'),
(23, 'player23', 'player23@example.com', 'pass23', '2024-06-01 10:22:00'),
(24, 'player24', 'player24@example.com', 'pass24', '2024-06-01 10:23:00'),
(25, 'player25', 'player25@example.com', 'pass25', '2024-06-01 10:24:00'),
(26, 'player26', 'player26@example.com', 'pass26', '2024-06-01 10:25:00'),
(27, 'player27', 'player27@example.com', 'pass27', '2024-06-01 10:26:00'),
(28, 'player28', 'player28@example.com', 'pass28', '2024-06-01 10:27:00'),
(29, 'player29', 'player29@example.com', 'pass29', '2024-06-01 10:28:00'),
(30, 'player30', 'player30@example.com', 'pass30', '2024-06-01 10:29:00');

DROP TABLE Game_sessions CASCADE;
CREATE TABLE IF NOT EXISTS Game_sessions (
    session_id int PRIMARY KEY,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    final_score INT,
    boss_killed BOOLEAN,
    player_id INT REFERENCES Players(player_id) ON DELETE CASCADE
);

INSERT INTO game_sessions (session_id, start_time, player_id) VALUES
(1, '2024-06-01 10:10:00', 1),
(2, '2024-06-01 10:11:00', 2),
(3, '2024-06-01 10:12:00', 3),
(4, '2024-06-01 10:13:00', 4),
(5, '2024-06-01 10:14:00', 5),
(6, '2024-06-01 10:15:00', 6),
(7, '2024-06-01 10:16:00', 7),
(8, '2024-06-01 10:17:00', 8),
(9, '2024-06-01 10:18:00', 9),
(10, '2024-06-01 10:19:00', 10),
(11, '2024-06-01 10:20:00', 11),
(12, '2024-06-01 10:21:00', 12),
(13, '2024-06-01 10:22:00', 13),
(14, '2024-06-01 10:23:00', 14),
(15, '2024-06-01 10:24:00', 15),
(16, '2024-06-01 10:25:00', 16),
(17, '2024-06-01 10:26:00', 17),
(18, '2024-06-01 10:27:00', 18),
(19, '2024-06-01 10:28:00', 19),
(20, '2024-06-01 10:29:00', 20),
(21, '2024-06-01 10:30:00', 21),
(22, '2024-06-01 10:31:00', 22),
(23, '2024-06-01 10:32:00', 23),
(24, '2024-06-01 10:33:00', 24),
(25, '2024-06-01 10:34:00', 25),
(26, '2024-06-01 10:35:00', 26),
(27, '2024-06-01 10:36:00', 27),
(28, '2024-06-01 10:37:00', 28),
(29, '2024-06-01 10:38:00', 29),
(30, '2024-06-01 10:39:00', 30);



-- Bảng Monster
CREATE TABLE IF NOT EXISTS monsters (
    monster_id int PRIMARY KEY,
    name VARCHAR(100),
    hp INT,
    point INT,
    damage INT,
    type VARCHAR(50),
    speed VARCHAR(20)
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

-- Bảng Session_boss_kill
CREATE TABLE IF NOT EXISTS Session_boss_kill (
    session_id INT REFERENCES Game_sessions(session_id) ON DELETE CASCADE,
    monster_id INT REFERENCES Monster(monster_id),
    kill_time int,
    points_earned INT,
    PRIMARY KEY (session_id, monster_id)
);

CREATE OR REPLACE FUNCTION trg_on_boss_kill_insert()
RETURNS TRIGGER AS $$
DECLARE
    session_start TIMESTAMP;
    seconds INT := NEW.kill_time;
BEGIN
    -- Nếu không phải là boss thì không làm gì
    IF NEW.monster_id != 3 THEN
        RETURN NEW;
    END IF;

    -- Tính điểm dựa vào kill_time
    IF seconds BETWEEN 300 AND 359 THEN
        NEW.points_earned := 1500;
    ELSIF seconds BETWEEN 360 AND 419 THEN
        NEW.points_earned := 1250;
    ELSIF seconds BETWEEN 420 AND 479 THEN
        NEW.points_earned := 1000;
    ELSIF seconds BETWEEN 480 AND 539 THEN
        NEW.points_earned := 750;
    ELSIF seconds BETWEEN 540 AND 599 THEN
        NEW.points_earned := 500;
    ELSE
        NEW.points_earned := 0;
    END IF;

    -- Lấy start_time để tính end_time
    SELECT start_time INTO session_start
    FROM Game_sessions
    WHERE session_id = NEW.session_id;

    -- Cập nhật Game_sessions
    UPDATE Game_sessions
    SET
        boss_killed = TRUE,
        end_time = session_start + (seconds || ' seconds')::interval
    WHERE session_id = NEW.session_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_on_boss_kill_insert
BEFORE INSERT ON Session_boss_kill
FOR EACH ROW
EXECUTE FUNCTION trg_on_boss_kill_insert();






-- Bảng Session_monster_kill
CREATE TABLE IF NOT EXISTS Session_monster_kill (
    session_id INT REFERENCES Game_sessions(session_id) ON DELETE CASCADE,
    monster_id INT REFERENCES Monster(monster_id),
    kill_count INT,
    points_earned INT,
    PRIMARY KEY (session_id, monster_id)
);

CREATE OR REPLACE FUNCTION calc_monster_kill_points()
RETURNS TRIGGER AS $$
DECLARE
    monster_point INT;
BEGIN
    -- Lấy điểm của quái từ bảng Monster
    SELECT point INTO monster_point
    FROM Monsters
    WHERE monster_id = NEW.monster_id;

    -- Tính điểm = số quái giết × điểm mỗi quái
    NEW.points_earned := NEW.kill_count * monster_point;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calc_monster_kill_points
BEFORE INSERT OR UPDATE ON Session_monster_kill
FOR EACH ROW
EXECUTE FUNCTION calc_monster_kill_points();



CREATE OR REPLACE FUNCTION update_final_score()
RETURNS TRIGGER AS $$
DECLARE
    sid INT;
    mons_score INT := 0;
    boss_score INT := 0;
BEGIN
    sid := COALESCE(NEW.session_id, OLD.session_id);

    -- Tính điểm quái phụ
    SELECT COALESCE(SUM(points_earned), 0)
    INTO mons_score
    FROM session_monster_kill
    WHERE session_id = sid;

    -- Tính điểm boss (nếu có dòng)
    SELECT COALESCE((
        SELECT points_earned FROM session_boss_kill WHERE session_id = sid LIMIT 1
    ), 0)
    INTO boss_score;

    -- Cập nhật final_score
    UPDATE game_sessions
    SET final_score = mons_score + boss_score
    WHERE session_id = sid;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_update_score_from_monster
AFTER INSERT OR UPDATE OR DELETE ON session_monster_kill
FOR EACH ROW EXECUTE FUNCTION update_final_score();

CREATE TRIGGER trg_update_score_from_boss
AFTER INSERT OR UPDATE OR DELETE ON session_boss_kill
FOR EACH ROW EXECUTE FUNCTION update_final_score();

UPDATE session_monster_kill SET kill_count = kill_count WHERE session_id IS NOT NULL;
UPDATE session_boss_kill SET kill_time = kill_time WHERE session_id IS NOT NULL;
SELECT session_id, final_score FROM game_sessions ORDER BY session_id;

UPDATE session_monster_kill SET kill_count = kill_count WHERE session_id IS NOT NULL;
UPDATE session_boss_kill SET kill_time = kill_time WHERE session_id IS NOT NULL;

INSERT INTO session_boss_kill (session_id, monster_id, kill_time) VALUES
(1, 3, 360),
(3, 3, 330),
(5, 3, 480),
(7, 3, 420),
(9, 3, 315),
(11, 3, 540),
(13, 3, 450),
(15, 3, 390),
(17, 3, 300),
(19, 3, 365);

INSERT INTO session_monster_kill (session_id, monster_id, kill_count) VALUES
(1, 1, 5),
(2, 2, 2),
(3, 1, 10),
(4, 1, 4),
(5, 2, 3),
(6, 1, 6),
(7, 2, 1),
(8, 1, 7),
(9, 2, 2),
(10, 1, 3),
(11, 2, 4),
(12, 1, 9),
(13, 2, 2),
(14, 1, 8),
(15, 2, 1),
(16, 1, 6),
(17, 2, 3),
(18, 1, 7),
(19, 2, 2),
(20, 1, 4),
(21, 2, 1),
(22, 1, 10),
(23, 2, 2),
(24, 1, 5),
(25, 2, 3),
(26, 1, 6),
(27, 2, 1),
(28, 1, 8),
(29, 2, 2),
(30, 1, 9);

-- Bảng nhân vật
CREATE TABLE IF NOT EXISTS  characters (
    character_id INT PRIMARY KEY,
    max_hp INT NOT NULL DEFAULT 100,
    max_item_slots INT NOT NULL DEFAULT 2
);


-- Chèn dữ liệu mẫu cho nhân vật
INSERT INTO characters (character_id, max_hp, max_item_slots) VALUES
(1, 120, 2),
(2, 100, 2),
(3, 150, 2),
(4, 90, 2),
(5, 110, 2),
(6, 95, 2),
(7, 130, 2),
(8, 105, 2),
(9, 100, 2),
(10, 140, 2),
(11, 115, 2),
(12, 125, 2),
(13, 85, 2),
(14, 150, 2),
(15, 135, 2),
(16, 100, 2),
(17, 110, 2),
(18, 95, 2),
(19, 120, 2),
(20, 100, 2);


CREATE TABLE IF NOT EXISTS session_character (
    session_id INT REFERENCES game_sessions(session_id) ON DELETE CASCADE,
    character_id INT REFERENCES characters(character_id),
    time_death int,
	PRIMARY KEY (session_id, character_id)
); 

CREATE OR REPLACE FUNCTION update_end_time_from_character_seconds()
RETURNS TRIGGER AS $$
DECLARE
    sid INT;
    max_death_secs INT;
    start_time_var TIMESTAMP;
    current_end_time TIMESTAMP;
    boss_killed_flag BOOLEAN;
BEGIN
    -- Xác định session_id
    IF TG_OP = 'DELETE' THEN
        sid := OLD.session_id;
    ELSE
        sid := NEW.session_id;
    END IF;

    -- Lấy thông tin phiên chơi
    SELECT start_time, end_time, boss_killed
    INTO start_time_var, current_end_time, boss_killed_flag
    FROM game_sessions
    WHERE session_id = sid;

    -- Nếu end_time chưa được đặt và chưa giết boss
    IF current_end_time IS NULL AND (boss_killed_flag IS FALSE OR boss_killed_flag IS NULL) THEN

        -- Lấy thời gian chết lớn nhất (nếu có)
        SELECT MAX(time_death) INTO max_death_secs
        FROM session_character
        WHERE session_id = sid;

        IF max_death_secs IS NOT NULL THEN
            UPDATE game_sessions
            SET end_time = start_time_var + (max_death_secs || ' seconds')::interval
            WHERE session_id = sid;
        ELSE
            UPDATE game_sessions
            SET end_time = start_time_var + INTERVAL '10 minutes'
            WHERE session_id = sid;
        END IF;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;







CREATE TRIGGER trg_endtime_from_character_seconds
AFTER INSERT OR UPDATE OR DELETE ON session_character
FOR EACH ROW
EXECUTE FUNCTION update_end_time_from_character_seconds();

INSERT INTO session_character (session_id, character_id, time_death) VALUES
(2, 1, 520),
(4, 2, 590),
(6, 3, 600),
(8, 1, 585),
(10, 5, 599),
(12, 1, 601),
(14, 7, 580),
(16, 9, 610),
(18, 2, 540),
(20, 1, 570),
(22, 3, 600),
(24, 4, 600),
(26, 5, 600),
(28, 6, 600),
(30, 7, 600);


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


CREATE TABLE IF NOT EXISTS session_items (
    session_id INT NOT NULL REFERENCES game_sessions(session_id) ON DELETE CASCADE,
    item_id INT NOT NULL REFERENCES items(item_id) ON DELETE CASCADE,
    damage INT,
    PRIMARY KEY (session_id, item_id)
);

INSERT INTO session_items (session_id, item_id)
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
        (10, 15), (10, 1);


 CREATE TABLE IF NOT EXISTS character_on_game (
    session_id INT REFERENCES game_sessions(session_id) ON DELETE CASCADE,
    character_id INT REFERENCES characters(character_id),
    PRIMARY KEY (session_id, character_id)
);

INSERT INTO character_on_game (session_id, character_id) VALUES
(1, 2),
(2, 1),
(3, 4),
(4, 2),
(5, 6),
(6, 3),
(7, 8),
(8, 1),
(9, 3),
(10, 5),
(11, 2),
(12, 1),
(13, 1),
(14, 7),
(15, 5),
(16, 9),
(17, 7),
(18, 2),
(19, 6),
(20, 1),
(21, 4),
(22, 3),
(23, 2),
(24, 4),
(25, 5),
(26, 5),
(27, 6),
(28, 6),
(29, 7),
(30, 7);

CREATE TABLE IF NOT EXISTS leaderboard (
    leaderboard_id SERIAL PRIMARY KEY,
    player_id INT UNIQUE REFERENCES players(player_id),
    rank INT,
    highest_score INT,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);		

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



