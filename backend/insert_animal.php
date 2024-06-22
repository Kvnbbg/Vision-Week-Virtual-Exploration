<?php
// Connect to your SQLite database
$database_path = __DIR__ . "/sql/zoo.sqlite"; // Adjust the filename and extension as needed

// Create connection
$conn = new SQLite3($database_path);

// Check connection
if (!$conn) {
    die("Connection failed: " . SQLite3::lastErrorMsg());
}

// Retrieve values from form submission
$name = $_POST['name'];
$type = $_POST['type'];
$country_id = $_POST['country_id'];

// SQL query to insert new animal into Animals table
$sql = "INSERT INTO Animals (name, type, country_id) VALUES ('$name', '$type', $country_id)";

if ($conn->query($sql)) {
    echo "New record created successfully";
} else {
    echo "Error: " . $sql . "<br>" . $conn->lastErrorMsg();
}

// Close connection
$conn->close();
?>
