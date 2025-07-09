-- MySQL Schema for Basic Messaging Features
-- Vision Week Virtual Exploration

-- Make sure to replace `your_database_name` with your actual database name
-- and ensure a `users` table with a compatible `id` field exists.

-- Table for storing direct messages between users
CREATE TABLE IF NOT EXISTS `direct_messages` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `sender_id` BIGINT UNSIGNED NOT NULL,
    `receiver_id` BIGINT UNSIGNED NOT NULL,
    `message_content` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
    `timestamp` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `read_status` BOOLEAN NOT NULL DEFAULT 0, -- 0 for unread, 1 for read
    PRIMARY KEY (`id`),
    INDEX `idx_sender_id` (`sender_id`),
    INDEX `idx_receiver_id` (`receiver_id`),
    INDEX `idx_timestamp` (`timestamp`),
    -- Assuming a `users` table exists with `id` as its primary key
    -- Replace `users` and `id` if your users table is named differently
    CONSTRAINT `fk_dm_sender` FOREIGN KEY (`sender_id`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_dm_receiver` FOREIGN KEY (`receiver_id`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table for tracking user presence/status
CREATE TABLE IF NOT EXISTS `user_presence` (
    `user_id` BIGINT UNSIGNED NOT NULL,
    `status` ENUM('online', 'offline', 'away') NOT NULL DEFAULT 'offline',
    `last_seen` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`user_id`),
    -- Assuming a `users` table exists with `id` as its primary key
    CONSTRAINT `fk_up_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Note on users table:
-- The above schema assumes you have a `users` table, for example:
/*
CREATE TABLE IF NOT EXISTS `users` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `username` VARCHAR(255) NOT NULL UNIQUE,
    `email` VARCHAR(255) NOT NULL UNIQUE,
    `password_hash` VARCHAR(255) NOT NULL, -- Assuming hashed passwords
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
*/

-- Consider adding triggers or application logic to update `user_presence.last_seen`
-- when a user sends a message or performs other actions, not just on status change.
