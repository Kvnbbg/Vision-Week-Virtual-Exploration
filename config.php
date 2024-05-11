<?php
// Database configuration parameters
// Config (consider using environment variables or a dedicated config file)
define('DB_HOST', 'localhost');
define('DB_USERNAME', 'kvnbbg');
define('DB_PASSWORD', 'password');
define('DB_NAME', 'zoo.db');

// Create connection
try {
  $conn = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME, DB_USERNAME, DB_PASSWORD);
  $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
  echo "Connection failed: " . $e->getMessage();
  die(); // Terminate script execution on failure
}

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>
