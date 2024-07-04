<?php
// Parse the JawsDB connection information
$jawsdb_url = parse_url(getenv("JAWSDB_URL"));
$jawsdb_server = $jawsdb_url["host"];
$jawsdb_username = $jawsdb_url["user"];
$jawsdb_password = $jawsdb_url["pass"];
$jawsdb_db = substr($jawsdb_url["path"], 1);

// Connect to the database
$conn = new mysqli($jawsdb_server, $jawsdb_username, $jawsdb_password, $jawsdb_db);

// Check the connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Serve the Flutter web build
include_once("index.html");
?>
