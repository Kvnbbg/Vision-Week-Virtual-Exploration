<?php
// server/websocket_server.php

foreach ([dirname(__DIR__) . '/vendor/autoload.php', dirname(__DIR__) . '/autoload.php'] as $autoloadPath) {
    if (is_file($autoloadPath)) {
        require $autoloadPath;
        break;
    }
}

use App\Security\AuthorizationException;
use App\Security\FirebaseTokenValidator;
use Psr\Http\Message\RequestInterface;
use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;
use React\EventLoop\Factory as LoopFactory;
use React\Socket\Server as Reactor;
use Ratchet\Server\IoServer;
use Ratchet\Http\HttpServer;
use Ratchet\WebSocket\WsServer;

// Simple Chat class implementing MessageComponentInterface
class Chat implements MessageComponentInterface {
    protected $clients;

    public function __construct(private readonly FirebaseTokenValidator $tokenValidator) {
        $this->clients = new \SplObjectStorage; // Stores all connected clients
        echo "WebSocket Chat Server started.\n";
    }

    public function onOpen(ConnectionInterface $conn) {
        if (!$this->authorize($conn)) {
            $conn->send(json_encode(['error' => 'unauthorized']));
            $conn->close();
            return;
        }

        // Store the new connection to send messages to later
        $this->clients->attach($conn);
        echo "New connection! ({$conn->resourceId})\n";
    }

    public function onMessage(ConnectionInterface $from, $msg) {
        $numRecv = count($this->clients) - 1;
        echo sprintf('Connection %d sending message "%s" to %d other connection%s' . "\n",
            $from->resourceId, $msg, $numRecv, $numRecv == 1 ? '' : 's');

        // For this basic example, just echo back to the sender
        // In a real chat, you would process the message and send to other clients
        $from->send("Server received: " . $msg);

        // Example: Broadcasting to all other clients (not the sender)
        /*
        foreach ($this->clients as $client) {
            if ($from !== $client) {
                // The sender is not the receiver, send to each client connected
                $client->send("User {$from->resourceId}: {$msg}");
            }
        }
        */
    }

    public function onClose(ConnectionInterface $conn) {
        // The connection is closed, remove it, as we can no longer send it messages
        $this->clients->detach($conn);
        echo "Connection {$conn->resourceId} has disconnected\n";
    }

    public function onError(ConnectionInterface $conn, \Exception $e) {
        echo "An error has occurred: {$e->getMessage()}\n";
        $conn->close();
    }

    private function authorize(ConnectionInterface $conn): bool
    {
        $httpRequest = $conn->httpRequest ?? null;
        $authorization = null;
        $fallbackToken = null;

        if ($httpRequest instanceof RequestInterface) {
            $authorization = $httpRequest->getHeaderLine('Authorization');

            $queryString = $httpRequest->getUri()->getQuery();
            if (is_string($queryString)) {
                parse_str($queryString, $params);
                if (isset($params['token']) && is_string($params['token'])) {
                    $fallbackToken = $params['token'];
                }
            }
        }

        try {
            $this->tokenValidator->assertValidAuthorization($authorization, $fallbackToken);
            return true;
        } catch (AuthorizationException $exception) {
            echo "Unauthorized connection attempt: {$exception->getMessage()}\n";
            return false;
        } catch (\Throwable $exception) {
            echo "Token validation error: {$exception->getMessage()}\n";
            return false;
        }
    }
}

// --- Server Setup ---
$port = 8080; // Choose a port that doesn't conflict
echo "Starting server on port {$port}...\n";

$loop = LoopFactory::create();

$socket = new Reactor('0.0.0.0:' . $port, $loop);

$tokenValidator = FirebaseTokenValidator::fromEnvironment();

$server = new IoServer(
    new HttpServer(
        new WsServer(
            new Chat($tokenValidator)
        )
    ),
    $socket,
    $loop
);

$server->run();
?>
