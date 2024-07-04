<?php
require_once 'config.php';
session_start();

// Unset all session variables
$_SESSION = [];

// Destroy the session
session_destroy();

// Redirect to the login page or homepage
header('Location: login.php');
exit;
?>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Déconnexion - Vision Week</title>
    <link rel="stylesheet" href="assets/styles.css">
</head>
<body>
    <?php if (file_exists('header.php')) include 'header.php'; ?>
    <?php if (file_exists('navigation.php')) include 'navigation.php'; ?>

    <main class="container">
        <h1>Déconnexion</h1>
        <p>Vous avez été déconnecté avec succès.</p>
        <button onclick="openDesignThinkingQuiz()">Take the Design Thinking Quiz</button>
    </main>

    <?php if (file_exists('footer.php')) include 'footer.php'; ?>
    <script src="/conception/receuil-des-besoins/design_thinking.js"></script>
</body>
</html>