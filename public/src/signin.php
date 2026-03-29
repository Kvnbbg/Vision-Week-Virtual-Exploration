<?php
// signin.php - Handles sign-in process and authentication
// Developer: Kevin Marville https://github.com/kvnbbg

declare(strict_types=1);

require_once 'db_config.php';

/**
 * Log a sign-in attempt in the database.
 */
function logAttempt(mysqli $conn, string $email, string $status): void
{
    $stmt = $conn->prepare('INSERT INTO tentatives_connexion (email, status, timestamp) VALUES (?, ?, ?)');
    if (!$stmt) {
        return;
    }

    $timestamp = date('Y-m-d H:i:s');
    $stmt->bind_param('sss', $email, $status, $timestamp);
    $stmt->execute();
    $stmt->close();
}

/**
 * Send an alert email to administrators.
 */
function sendAlert(string $email, string $status): void
{
    $adminEmail = 'admin@votredomaine.com';
    $subject = 'Alerte: Tentative de connexion';
    $message = "Bonjour, il y a eu une tentative de connexion avec le statut: {$status} pour l'adresse email: {$email} à " . date('Y-m-d H:i:s');
    $headers = "From: {$adminEmail}";

    @mail($adminEmail, $subject, $message, $headers);
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = isset($_POST['email']) ? trim((string) $_POST['email']) : '';
    $password = isset($_POST['password']) ? (string) $_POST['password'] : '';

    if ($email === '' || $password === '') {
        http_response_code(400);
        echo 'Email et mot de passe requis';
        $conn->close();
        exit;
    }

    $stmt = $conn->prepare('SELECT mot_de_passe FROM Utilisateur WHERE email = ?');
    if (!$stmt) {
        http_response_code(500);
        echo 'Erreur interne';
        $conn->close();
        exit;
    }

    $stmt->bind_param('s', $email);
    $stmt->execute();
    $stmt->bind_result($storedPasswordHash);
    $stmt->fetch();
    $stmt->close();

    if (is_string($storedPasswordHash) && password_verify($password, $storedPasswordHash)) {
        logAttempt($conn, $email, 'success');
        sendAlert($email, 'réussie');
        echo 'Connexion réussie';
    } else {
        logAttempt($conn, $email, 'failed');
        sendAlert($email, 'échouée');
        http_response_code(401);
        echo 'Connexion échouée, les identifiants ne correspondent pas';
    }
} else {
    http_response_code(405);
    echo 'Méthode non autorisée';
}

$conn->close();
