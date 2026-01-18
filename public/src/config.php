<?php
declare(strict_types=1);

const USERS_DB_FILE = __DIR__ . '/../../storage/users.sqlite';

function getDatabaseConnection(string $dbPath): ?PDO
{
    $dbDirectory = dirname($dbPath);
    if (!is_dir($dbDirectory) && !mkdir($dbDirectory, 0755, true) && !is_dir($dbDirectory)) {
        error_log('Unable to create database directory: ' . $dbDirectory);
        return null;
    }

    try {
        $db = new PDO('sqlite:' . $dbPath);
        $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $db->exec(
            'CREATE TABLE IF NOT EXISTS Users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT NOT NULL UNIQUE,
                password TEXT NOT NULL,
                email TEXT NOT NULL UNIQUE,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
            )'
        );
        return $db;
    } catch (PDOException $exception) {
        error_log('SQLite connection error: ' . $exception->getMessage());
        return null;
    }
}
