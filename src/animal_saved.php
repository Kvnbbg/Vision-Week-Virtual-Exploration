<?php
// Database connection details
$servername = "your_database_host";
$username = "your_database_username";
$password = "your_database_password";
$dbname = "your_database_name";

try {
    // Create connection using PDO for better security and error handling
    $dsn = "mysql:host=$servername;dbname=$dbname;charset=utf8mb4";
    $options = [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
    ];
    $pdo = new PDO($dsn, $username, $password, $options);
    
    // SQL query to get the number of animals saved
    $sql = "SELECT COUNT(*) AS animals_saved FROM your_animals_table";
    $stmt = $pdo->query($sql);

    // Fetch the result
    $row = $stmt->fetch();

    // Output the data as JSON
    header('Content-Type: application/json');
    echo json_encode($row);

} catch (PDOException $e) {
    // Handle any errors
    error_log($e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Database error']);
}
?>
