<?php
// db_config.php - Database configuration
// Developer : Kevin Marville https://github.com/kvnbbg

// Load credentials from environment variables
// Fallback to defaults for local development if environment variables are not set.
$servername = getenv('DB_SERVERNAME') ?: 'localhost';
$username = getenv('DB_USERNAME') ?: 'root';
$password = getenv('DB_PASSWORD') ?: ''; // It's better to have a default password for local dev or ensure env var is always set.
$dbname = getenv('DB_NAME') ?: 'db_name_default'; // Changed default to avoid using a generic 'db_name'

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
  // Avoid echoing detailed error messages in production. Log them instead.
  // For now, keeping it simple for demonstration of credential change.
  // In a real app with Monolog setup, you would log this error.
  error_log("Database connection failed: " . $conn->connect_error); // Log to server error log
  die("Database connection failed. Please try again later."); // Generic message to user
}

// Removing the "Connected successfully" echo as it's not suitable for a config file included in an API.
// echo "Connected successfully";
?>
