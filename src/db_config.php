<?php
// db_config.php - Database configuration
// Developer : Kevin Marville https://github.com/kvnbbg

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "db_name";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully";
?>
