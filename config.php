<?php
/**
 * config.php
 * This file contains the configuration settings for the Vision Week application.
 * Adjust these settings as needed for your development and production environments.
 */

// Define the environment: 'development' or 'production'
define('ENVIRONMENT', 'development'); // Change to 'production' for live deployment

// Error reporting configuration
if (ENVIRONMENT === 'development') {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
} else {
    error_reporting(0);
    ini_set('display_errors', 0);
}

// Database configuration for SQLite
define('DB_FILE', __DIR__ . '/sql/data.db'); // Path to the main SQLite database file
define('USERS_DB_FILE', __DIR__ . '/sql/users.db'); // Path to the users SQLite database file
define('ZOO_DB_FILE', __DIR__ . '/sql/zoo.db'); // Path to the zoo SQLite database file

// Database configuration for MySQL (for future use)
define('DB_USER', 'root'); // Database username
define('DB_PASS', 'password'); // Database password
define('DB_HOST', 'localhost'); // Database host
define('DB_NAME', 'vision_week'); // Database name

/**
 * Get the SQLite database connection
 *
 * @param string $dbFile The SQLite database file
 * @return PDO|null The PDO instance or null on failure
 */
function getSQLiteConnection($dbFile) {
    try {
        $db = new PDO('sqlite:' . $dbFile);
        $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        return $db;
    } catch (PDOException $e) {
        error_log($e->getMessage());
        return null;
    }
}

/**
 * Get the MySQL database connection (for future use)
 *
 * @return PDO|null The PDO instance or null on failure
 */
function getMySQLConnection() {
    try {
        $dsn = 'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8';
        $db = new PDO($dsn, DB_USER, DB_PASS);
        $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        return $db;
    } catch (PDOException $e) {
        error_log($e->getMessage());
        return null;
    }
}

/**
 * Fetch data from the database
 *
 * @param PDO $db The PDO instance
 * @param string $query The SQL query
 * @return array The fetched data
 */
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
