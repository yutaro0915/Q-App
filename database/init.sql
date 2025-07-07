-- Q-App Database Initialization
-- This script creates the database schema for the Q-App application

-- Use the database
USE qapp_db;

-- Create users table
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    faculty ENUM('文学部', '教育学部', '法学部', '経済学部', '理学部', '医学部', '歯学部', '薬学部', '工学部', '芸術工学部', '農学部', '共創学部') NOT NULL,
    grade TINYINT NOT NULL CHECK (grade BETWEEN 1 AND 4),
    circle VARCHAR(100),
    email_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_faculty (faculty)
);

-- Create posts table
CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    category ENUM('授業', 'アルバイト', 'サークル', '雑談') NOT NULL,
    content TEXT NOT NULL,
    image_url VARCHAR(500),
    like_count INT DEFAULT 0,
    thread_count INT DEFAULT 0,
    is_anonymous BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_category (category),
    INDEX idx_created_at (created_at),
    INDEX idx_user_id (user_id),
    CONSTRAINT chk_content_length CHECK (CHAR_LENGTH(content) <= 140)
);

-- Create threads table
CREATE TABLE threads (
    thread_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    parent_thread_id INT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    like_count INT DEFAULT 0,
    depth_level INT DEFAULT 0,
    is_anonymous BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (parent_thread_id) REFERENCES threads(thread_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_post_id (post_id),
    INDEX idx_parent_thread_id (parent_thread_id),
    INDEX idx_created_at (created_at),
    CONSTRAINT chk_thread_content_length CHECK (CHAR_LENGTH(content) <= 500)
);

-- Create post_likes table
CREATE TABLE post_likes (
    like_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_post_like (post_id, user_id)
);

-- Create thread_likes table
CREATE TABLE thread_likes (
    like_id INT PRIMARY KEY AUTO_INCREMENT,
    thread_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (thread_id) REFERENCES threads(thread_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_thread_like (thread_id, user_id)
);

-- Create events table
CREATE TABLE events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,
    event_datetime DATETIME NOT NULL,
    location VARCHAR(200),
    external_url VARCHAR(500),
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_category (category),
    INDEX idx_event_datetime (event_datetime),
    INDEX idx_created_at (created_at)
);

-- Create email_verifications table
CREATE TABLE email_verifications (
    verification_id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) NOT NULL,
    verification_code VARCHAR(6) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_expires_at (expires_at)
);

-- Insert sample data for development
INSERT INTO users (username, email, password_hash, display_name, faculty, grade, circle, email_verified) VALUES
('testuser1', 'test1@s.kyushu-u.ac.jp', '$2b$12$dummyhash1', 'テストユーザー1', '工学部', 3, 'テニス部', TRUE),
('testuser2', 'test2@s.kyushu-u.ac.jp', '$2b$12$dummyhash2', 'テストユーザー2', '理学部', 2, 'サッカー部', TRUE),
('testuser3', 'test3@s.kyushu-u.ac.jp', '$2b$12$dummyhash3', 'テストユーザー3', '文学部', 4, '軽音部', TRUE);

-- Insert sample posts
INSERT INTO posts (user_id, category, content, like_count, is_anonymous) VALUES
(1, '授業', '線形代数の授業についての質問があります。どなたか教えてください！', 3, FALSE),
(2, 'サークル', '新歓イベントの告知です。皆さんお気軽にご参加ください！', 5, FALSE),
(3, 'アルバイト', '伊都キャンパス周辺でおすすめのアルバイトはありますか？', 2, TRUE),
(1, '雑談', '今日の天気が良いですね。お散歩日和です！', 1, FALSE);

-- Insert sample threads
INSERT INTO threads (post_id, user_id, content, like_count, depth_level, is_anonymous) VALUES
(1, 2, '線形代数でしたら、教科書の練習問題を解くのがおすすめです。', 2, 0, FALSE),
(1, 3, '私も苦手でした。先生の説明が分かりにくいですよね。', 1, 0, TRUE),
(2, 1, '参加したいです！詳細を教えてください。', 0, 0, FALSE);

-- Insert sample events
INSERT INTO events (user_id, title, description, category, event_datetime, location) VALUES
(2, 'テニス部新歓', '新入生歓迎会を開催します。初心者も大歓迎！', '新歓', '2024-04-15 18:00:00', '体育館'),
(1, 'プログラミング勉強会', 'Python基礎講座を開催します。', '勉強会', '2024-04-20 14:00:00', '工学部講義室'),
(3, 'サークル合同新歓', '複数のサークルが合同で開催する新歓イベントです。', '新歓', '2024-04-10 16:00:00', '学生会館');

-- Create triggers to update counters
DELIMITER //

CREATE TRIGGER update_post_like_count
AFTER INSERT ON post_likes
FOR EACH ROW
BEGIN
    UPDATE posts SET like_count = like_count + 1 WHERE post_id = NEW.post_id;
END//

CREATE TRIGGER update_post_like_count_delete
AFTER DELETE ON post_likes
FOR EACH ROW
BEGIN
    UPDATE posts SET like_count = like_count - 1 WHERE post_id = OLD.post_id;
END//

CREATE TRIGGER update_thread_like_count
AFTER INSERT ON thread_likes
FOR EACH ROW
BEGIN
    UPDATE threads SET like_count = like_count + 1 WHERE thread_id = NEW.thread_id;
END//

CREATE TRIGGER update_thread_like_count_delete
AFTER DELETE ON thread_likes
FOR EACH ROW
BEGIN
    UPDATE threads SET like_count = like_count - 1 WHERE thread_id = OLD.thread_id;
END//

CREATE TRIGGER update_post_thread_count
AFTER INSERT ON threads
FOR EACH ROW
BEGIN
    UPDATE posts SET thread_count = thread_count + 1 WHERE post_id = NEW.post_id;
END//

CREATE TRIGGER update_post_thread_count_delete
AFTER DELETE ON threads
FOR EACH ROW
BEGIN
    UPDATE posts SET thread_count = thread_count - 1 WHERE post_id = OLD.post_id;
END//

DELIMITER ;

-- Create indexes for performance
CREATE INDEX idx_posts_category_created_at ON posts(category, created_at DESC);
CREATE INDEX idx_events_category_datetime ON events(category, event_datetime);
CREATE INDEX idx_threads_post_parent ON threads(post_id, parent_thread_id);

-- Display created tables
SHOW TABLES;