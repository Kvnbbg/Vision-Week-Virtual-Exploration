<?php
define('ENVIRONMENT', 'development'); // Change to 'production' for live deployment

if (ENVIRONMENT === 'development') {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
} else {
    error_reporting(0);
    ini_set('display_errors', 0);
}

// Database configuration
define('DB_FILE', __DIR__ . '/sql//data.db'); // Ensure the path is correct
?>
