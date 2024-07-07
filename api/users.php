<?php
// ... database connection code ...

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = $_POST['username'];
    $password = $_POST['password'];

    // ... validate and process user data ...

    // Send a response back to Flutter
    header('Content-Type: application/json');
    echo json_encode(['success' => true, 'message' => 'User registered successfully']);
}
?>
