<?php
require 'db_config.php';

class UserService {
    function addUser($name, $age) {
        global $conn;
        $stmt = $conn->prepare("INSERT INTO users (name, age) VALUES (?, ?)");
        $stmt->bind_param("si", $name, $age);
        if ($stmt->execute()) {
            return "User added successfully";
        } else {
            return "Failed to add user";
        }
    }

    function getUsers() {
        global $conn;
        $result = $conn->query("SELECT * FROM users");
        $users = array();
        while ($row = $result->fetch_assoc()) {
            $users[] = $row;
        }
        return json_encode($users);
    }
}

$options = array('uri' => 'http://127.0.0.1/soap_server.php');
$server = new SoapServer(null, $options);
$server->setClass('UserService');
$server->handle();
?>
