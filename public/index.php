<?php

use Slim\Factory\AppFactory;
use Monolog\Logger;
use Monolog\Handler\StreamHandler;
use Monolog\Processor\UidProcessor;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\Middleware\ErrorMiddleware;

foreach ([__DIR__ . '/../vendor/autoload.php', __DIR__ . '/../autoload.php'] as $autoloadPath) {
    if (is_file($autoloadPath)) {
        require $autoloadPath;
        break;
    }
}

// Instantiate the app
$app = AppFactory::create();

// --- Monolog Setup ---
$logger = new Logger('vision_week_app');
// Add a UidProcessor to assign a unique ID to each log record, useful for tracing
$logger->pushProcessor(new UidProcessor());
// Log to a file. In a production environment, consider more robust handlers.
// Ensure the 'logs' directory is writable by the web server.
$logDir = __DIR__ . '/../logs';
if (!is_dir($logDir)) {
    mkdir($logDir, 0775, true);
}
$logFile = $logDir . '/app.log';
$logTarget = is_dir($logDir) && is_writable($logDir) ? $logFile : 'php://stderr';
$logger->pushHandler(new StreamHandler($logTarget, Logger::DEBUG)); // Log all levels from DEBUG upwards

// --- Slim Error Handling ---
// Add Routing Middleware
$app->addRoutingMiddleware();

// Define Custom Error Handler
$customErrorHandler = function (
    Request $request,
    Throwable $exception,
    bool $displayErrorDetails,
    bool $logErrors,
    bool $logErrorDetails
) use ($logger, $app) {
    $logger->error($exception->getMessage(), ['exception' => $exception, 'trace' => $exception->getTraceAsString()]);

    $payload = ['error' => 'Internal Server Error'];
    if ($displayErrorDetails) {
        $payload['details'] = $exception->getMessage();
        $payload['trace'] = $exception->getTrace();
    }

    $response = $app->getResponseFactory()->createResponse();
    $response->getBody()->write(json_encode($payload, JSON_PRETTY_PRINT));

    return $response->withHeader('Content-Type', 'application/json')->withStatus(500);
};

// Add Error Handling Middleware
// The last boolean argument determines whether to display error details
// Set to false in production, true in development
$errorMiddleware = $app->addErrorMiddleware(true, true, true);
$errorMiddleware->setDefaultErrorHandler($customErrorHandler);


// --- Request Logging Middleware (Example) ---
$app->add(function (Request $request, $handler) use ($logger) {
    $response = $handler->handle($request);
    $logger->info(sprintf('%s %s - Status: %d', $request->getMethod(), $request->getUri()->getPath(), $response->getStatusCode()));
    return $response;
});


// --- Routes ---
$app->get('/', function (Request $request, Response $response, $args) {
    $response->getBody()->write("Hello, this is the PHP backend for Vision Week!");
    return $response;
});

// Example of using logger in a route
$app->get('/test-log', function (Request $request, Response $response, $args) use ($logger) {
    $logger->info("Test log route was called.");
    $response->getBody()->write("Logged a test message. Check your logs!");
    return $response;
});

$app->run();
