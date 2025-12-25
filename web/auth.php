<?php

declare(strict_types=1);

session_start();
require_once __DIR__ . '/db.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo 'Method Not Allowed';
    exit;
}

$action = sanitize_text($_POST['action'] ?? '');
$redirect = sanitize_text($_POST['redirect'] ?? 'index.html');
$csrfToken = $_POST['csrf_token'] ?? '';

if (!validate_csrf_token($csrfToken)) {
    http_response_code(403);
    echo 'Invalid CSRF token.';
    exit;
}

$pdo = get_database();

function sanitize_redirect_path(string $path): string
{
    $allowed = [
        'index.html',
        'landing.html',
        'explore_home.html',
    ];

    if (in_array($path, $allowed, true)) {
        return $path;
    }

    return 'index.html';
}

$redirect = sanitize_redirect_path($redirect);

if ($action === 'register') {
    $fullName = sanitize_text($_POST['full_name'] ?? '');
    $email = filter_var($_POST['email'] ?? '', FILTER_VALIDATE_EMAIL);
    $password = $_POST['password'] ?? '';

    if ($fullName === '' || !$email || strlen($password) < 8) {
        http_response_code(400);
        echo 'Please provide valid registration details.';
        exit;
    }

    $passwordHash = password_hash($password, PASSWORD_DEFAULT);

    try {
        $statement = $pdo->prepare('INSERT INTO users (full_name, email, password_hash, created_at) VALUES (:full_name, :email, :password_hash, :created_at)');
        $statement->execute([
            ':full_name' => $fullName,
            ':email' => $email,
            ':password_hash' => $passwordHash,
            ':created_at' => gmdate('c'),
        ]);
    } catch (PDOException $exception) {
        if ($exception->getCode() === '23000') {
            http_response_code(409);
            echo 'An account with this email already exists.';
            exit;
        }
        throw $exception;
    }

    $_SESSION['user'] = [
        'full_name' => $fullName,
        'email' => $email,
    ];

    header('Location: ' . $redirect);
    exit;
}

if ($action === 'login') {
    $email = filter_var($_POST['email'] ?? '', FILTER_VALIDATE_EMAIL);
    $password = $_POST['password'] ?? '';

    if (!$email || strlen($password) < 8) {
        http_response_code(400);
        echo 'Please provide valid login details.';
        exit;
    }

    $statement = $pdo->prepare('SELECT full_name, email, password_hash FROM users WHERE email = :email');
    $statement->execute([':email' => $email]);
    $user = $statement->fetch();

    if (!$user || !password_verify($password, $user['password_hash'])) {
        http_response_code(401);
        echo 'Invalid email or password.';
        exit;
    }

    $_SESSION['user'] = [
        'full_name' => $user['full_name'],
        'email' => $user['email'],
    ];

    header('Location: ' . $redirect);
    exit;
}

if ($action === 'logout') {
    $_SESSION = [];
    if (ini_get('session.use_cookies')) {
        $params = session_get_cookie_params();
        setcookie(session_name(), '', time() - 42000, $params['path'], $params['domain'], $params['secure'], $params['httponly']);
    }
    session_destroy();

    header('Location: ' . $redirect);
    exit;
}

http_response_code(400);
echo 'Unknown action.';
