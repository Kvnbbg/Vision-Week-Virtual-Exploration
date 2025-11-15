<?php

declare(strict_types=1);

use App\Repository\AnimalRepository;
use App\Security\AuthorizationException;
use App\Security\CsrfTokenManager;
use App\Security\FirebaseTokenValidator;

$autoloadLoaded = false;
foreach ([__DIR__ . '/../../vendor/autoload.php', __DIR__ . '/../../autoload.php'] as $autoloadPath) {
    if (is_file($autoloadPath)) {
        require_once $autoloadPath;
        $autoloadLoaded = true;
        break;
    }
}

if (!$autoloadLoaded) {
    http_response_code(500);
    echo json_encode(['error' => 'Autoloader not found']);
    exit;
}

if (session_status() !== PHP_SESSION_ACTIVE) {
    session_start();
}

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method Not Allowed']);
    exit;
}

$csrfManager = new CsrfTokenManager();

if (!$csrfManager->validate($_POST['csrf_token'] ?? null)) {
    http_response_code(403);
    echo json_encode(['error' => 'Invalid CSRF token']);
    exit;
}

try {
    $tokenValidator = FirebaseTokenValidator::fromEnvironment();
    $tokenValidator->assertValidAuthorization($_SERVER['HTTP_AUTHORIZATION'] ?? null, $_POST['id_token'] ?? null);
} catch (AuthorizationException $exception) {
    http_response_code(401);
    echo json_encode(['error' => 'Unauthorized', 'details' => $exception->getMessage()]);
    exit;
} catch (Throwable $exception) {
    http_response_code(500);
    echo json_encode(['error' => 'Token validation failure']);
    error_log($exception->getMessage());
    exit;
}

$name = isset($_POST['name']) ? trim((string) $_POST['name']) : '';
$type = isset($_POST['type']) ? trim((string) $_POST['type']) : '';
$countryId = filter_var($_POST['country_id'] ?? null, FILTER_VALIDATE_INT);

if ($name === '' || $type === '' || $countryId === false) {
    http_response_code(422);
    echo json_encode(['error' => 'Invalid payload supplied.']);
    exit;
}

$databasePath = __DIR__ . '/sql/zoo.sqlite';

try {
    $pdo = new PDO('sqlite:' . $databasePath, null, null, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);

    $repository = new AnimalRepository($pdo);
    $repository->insert($name, $type, (int) $countryId);

    $newToken = $csrfManager->rotateToken();

    http_response_code(201);
    echo json_encode([
        'status' => 'success',
        'message' => 'New record created successfully',
        'csrf_token' => $newToken,
    ]);
} catch (Throwable $exception) {
    http_response_code(500);
    echo json_encode(['error' => 'Database error']);
    error_log($exception->getMessage());
}
