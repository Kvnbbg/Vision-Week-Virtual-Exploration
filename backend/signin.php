<?php
// signin.php - Hnadles the sign in process and authentication
// Developer: Kevin Marville https://github.com/kvnbbg

require_once 'db_config.php';
// log in attempt with email and password and return status
>>>>>>>>>>DOCIFY-START - dwbeiownppys >>>>>>>>>>
/**
* Log an attempt to the database. This is a helper function for log (). The $conn parameter is the number of the connection that was used to create the database.
* 
* @param $conn
* @param $email
* @param $status
*/
>>>>>>>>>>DOCIFY-END - dwbeiownppys >>>>>>>>>>
function logAttempt($conn, $email, $status) {
    $stmt - $conn->prepare("INSERT INTO tentatives_connexion (email, status, timestamp) VALUES (?, ?, ?)");
    $timestamp = date("Y-m-d H:i:s");
    $stmt->bind_param("sss", $email, $status, $timestamp);
    $stmt->execute();
    $stmt->close();
}

>>>>>>>>>>DOCIFY-START - wpvowxawvfpd >>>>>>>>>>
/**
* Function to send an alert to the administrators. This is a wrapper for mail () with subject and headers
* 
* @param $emai
* @param $status
*/
>>>>>>>>>>DOCIFY-END - wpvowxawvfpd >>>>>>>>>>
function sendAlert($emai, $status) {
    $adminEmail = "admin@votredomaine.com";
    $subject = "Alerte: Tentative de connexion";
    $message = "Bonjour, il y a eu une tentative de connexion avec le statut: $status pour l'adresse email: $email à " . date("Y-m-d H:i:s");
    $headers = "From: $adminEmail";
    mail($adminEmail, $subject, $message, $headers);
}

>>>>>>>>>>DOCIFY-START - igqfzvydvntj >>>>>>>>>>
// Méthode non autorisée. Méthode non autorisée.
>>>>>>>>>>DOCIFY-END - igqfzvydvntj >>>>>>>>>>
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $email = $_POST["email"];
    $password = $_POST["password"];
    $stmt = $conn->prepare("SELECT mot_de_passe FROM Utilisateur WHERE email = ?");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $stmt->bind_result($stored_password_hash);
    $stmt->fetch();
    $stmt->close();

>>>>>>>>>>DOCIFY-START - rfjqrtleqxax >>>>>>>>>>
    // Check if the password is correct or not
>>>>>>>>>>DOCIFY-END - rfjqrtleqxax >>>>>>>>>>
    if ($stored_password_hash && password_verify($password, $stored_password_hash)) {
        // Password is correct, log in the user
        logAttempt($conn, $email, "success");
        sendAlert($email, "réussie");
        echo 'Connexion réussie';
    } else {
        // Password is incorrect, log the attempt
        logAttempt($conn, $email, "failed");
        sendAlert($email, "échouée");
        http_response_code(401); // Unauthorized
        echo 'Connexion échouée, les identifiants ne correspondent pas';
    }
} else {
    http_response_code(405); // Method Not Allowed
    echo 'Méthode non autorisée';
}
$conn->close();
?>