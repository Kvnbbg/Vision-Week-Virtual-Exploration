-- users.sql - Database schema for user authentication in login.php

-- Table: Users
CREATE TABLE Users (
    -- Unique identifier for each user
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    -- Username for login
    username VARCHAR(255) UNIQUE NOT NULL,
    -- Password stored securely (e.g., hashed)
    password VARCHAR(255) NOT NULL,
    -- Email address for user
    email VARCHAR(255) UNIQUE NOT NULL,
    -- Optional field for user's first name
    first_name VARCHAR(255) DEFAULT NULL,
    -- Optional field for user's last name
    last_name VARCHAR(255) DEFAULT NULL,
    -- Date and time when the user account was created
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Date and time when the user account was last updated
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Index for efficient username lookups
CREATE INDEX username_index ON Users (username);

-- Index for efficient email lookups
CREATE INDEX email_index ON Users (email);
