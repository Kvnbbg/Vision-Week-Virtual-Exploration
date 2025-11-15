<?php

declare(strict_types=1);

use App\Security\CsrfTokenManager;

$autoloadLoaded = false;
foreach ([__DIR__ . '/../vendor/autoload.php', __DIR__ . '/../autoload.php'] as $autoloadPath) {
    if (is_file($autoloadPath)) {
        require_once $autoloadPath;
        $autoloadLoaded = true;
        break;
    }
}

if (!$autoloadLoaded) {
    http_response_code(500);
    echo 'Autoloader not found';
    exit;
}

if (session_status() !== PHP_SESSION_ACTIVE) {
    session_start();
}

$csrfManager = new CsrfTokenManager();
$csrfToken = $csrfManager->getToken();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Insert New Animal</title>
</head>
<body>
    <h2>Insert New Animal into Animals Table</h2>
    <form action="../public/src/insert_animal.php" method="POST">
        <label for="name">Name:</label>
        <input type="text" id="name" name="name" required><br><br>

        <label for="type">Type:</label>
        <input type="text" id="type" name="type" required><br><br>

        <label for="country_id">Country ID:</label>
        <input type="number" id="country_id" name="country_id" required><br><br>

        <label for="id_token">Firebase ID or Admin Token:</label>
        <input type="text" id="id_token" name="id_token" placeholder="Paste your Firebase ID token" required><br><br>

        <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($csrfToken, ENT_QUOTES, 'UTF-8') ?>">

        <input type="submit" value="Insert">
    </form>
    <p style="max-width: 500px;">
        Ensure you are authenticated and provide a current Firebase ID token (or configured admin token). The server verifies the
        token before accepting the submission.
    </p>
</body>
</html>
