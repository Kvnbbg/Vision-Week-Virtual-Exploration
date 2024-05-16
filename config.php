<?php
// config.php

// Environment configuration
define('ENVIRONMENT', 'development'); // Change to 'production' for live deployment

if (ENVIRONMENT === 'development') {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
} else {
    error_reporting(0);
    ini_set('display_errors', 0);
}

// Database configuration
define('DB_FILE', __DIR__ . '/sql/data.db'); // Ensure the path is correct
define('DB_USER', 'root'); // Change to your database username
define('DB_PASS', 'password'); // Change to your database password
define('DB_HOST', 'localhost'); // Change to your database host

// Function to get database connection
function getDatabaseConnection($dbFile) {
    try {
        $db = new PDO('sqlite:' . $dbFile);
        $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        return $db;
    } catch (PDOException $e) {
        error_log($e->getMessage());
        return null;
    }
}

// Function to fetch data from the database
function fetchFromDatabase($db, $query) {
    try {
        $stmt = $db->query($query);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        error_log($e->getMessage());
        return [];
    }
}
?>
