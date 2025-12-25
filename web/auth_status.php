<?php

declare(strict_types=1);

session_start();
require_once __DIR__ . '/db.php';

header('Content-Type: application/json');

$csrfToken = ensure_csrf_token();

if (!empty($_SESSION['user'])) {
    $user = $_SESSION['user'];
    echo json_encode([
        'authenticated' => true,
        'user' => [
            'fullName' => $user['full_name'],
            'email' => $user['email'],
        ],
        'csrfToken' => $csrfToken,
    ]);
    exit;
}

echo json_encode([
    'authenticated' => false,
    'user' => null,
    'csrfToken' => $csrfToken,
]);
