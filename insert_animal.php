<?php
// Connect to your database
$servername = "localhost";
$username = "username";
$password = "password";
$dbname = "your_database";

$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

// Retrieve values from form submission
$name = $_POST['name'];
$type = $_POST['type'];
$country_id = $_POST['country_id'];

// SQL query to insert new animal into Animals table
$sql = "INSERT INTO Animals (name, type, country_id) VALUES ('$name', '$type', $country_id)";

if ($conn->query($sql) === TRUE) {
  echo "New record created successfully";
} else {
  echo "Error: " . $sql . "<br>" . $conn->error;
}

$conn->close();
?>
