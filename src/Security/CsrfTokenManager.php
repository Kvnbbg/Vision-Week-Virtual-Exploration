<?php

namespace App\Security;

use RuntimeException;

class CsrfTokenManager
{
    private const DEFAULT_SESSION_KEY = '_csrf_token';

    public function __construct(private readonly string $sessionKey = self::DEFAULT_SESSION_KEY)
    {
    }

    public function ensureSessionStarted(): void
    {
        if (session_status() !== PHP_SESSION_ACTIVE) {
            throw new RuntimeException('CSRF protection requires an active session.');
        }
    }

    public function getToken(): string
    {
        $this->ensureSessionStarted();

        if (!isset($_SESSION[$this->sessionKey]) || !is_string($_SESSION[$this->sessionKey])) {
            $_SESSION[$this->sessionKey] = bin2hex(random_bytes(32));
        }

        return $_SESSION[$this->sessionKey];
    }

    public function validate(?string $token): bool
    {
        $this->ensureSessionStarted();

        if (!is_string($token) || $token === '') {
            return false;
        }

        $storedToken = $_SESSION[$this->sessionKey] ?? '';

        return is_string($storedToken) && hash_equals($storedToken, $token);
    }

    public function rotateToken(): string
    {
        $this->ensureSessionStarted();

        $_SESSION[$this->sessionKey] = bin2hex(random_bytes(32));

        return $_SESSION[$this->sessionKey];
    }
}
