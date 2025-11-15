<?php

declare(strict_types=1);

namespace Tests\Unit\Security;

use App\Security\CsrfTokenManager;
use PHPUnit\Framework\TestCase;

class CsrfTokenManagerTest extends TestCase
{
    protected function setUp(): void
    {
        if (session_status() === PHP_SESSION_ACTIVE) {
            session_write_close();
        }

        session_id(bin2hex(random_bytes(8)));
        session_start();
    }

    protected function tearDown(): void
    {
        if (session_status() === PHP_SESSION_ACTIVE) {
            $_SESSION = [];
            session_write_close();
        }
    }

    public function testTokenGenerationAndValidation(): void
    {
        $manager = new CsrfTokenManager();
        $token = $manager->getToken();

        self::assertNotSame('', $token);
        self::assertTrue($manager->validate($token));
    }

    public function testValidationFailsForMismatchedToken(): void
    {
        $manager = new CsrfTokenManager();
        $manager->getToken();

        self::assertFalse($manager->validate('invalid-token'));
    }

    public function testTokenRotationChangesValue(): void
    {
        $manager = new CsrfTokenManager();
        $token = $manager->getToken();
        $newToken = $manager->rotateToken();

        self::assertNotSame($token, $newToken);
        self::assertTrue($manager->validate($newToken));
    }
}
