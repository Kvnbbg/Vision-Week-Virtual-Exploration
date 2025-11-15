<?php

declare(strict_types=1);

namespace Tests\Unit\Security;

use App\Security\AuthorizationException;
use App\Security\FirebaseKeyProvider;
use App\Security\FirebaseTokenValidator;
use PHPUnit\Framework\TestCase;

class FirebaseTokenValidatorTest extends TestCase
{
    private string $privateKey;
    private string $publicCertificate;
    private string $keyId;
    private string $projectId;

    protected function setUp(): void
    {
        $resource = openssl_pkey_new([
            'private_key_bits' => 2048,
            'private_key_type' => OPENSSL_KEYTYPE_RSA,
        ]);

        self::assertNotFalse($resource);
        if (PHP_VERSION_ID >= 80000) {
            self::assertInstanceOf(\OpenSSLAsymmetricKey::class, $resource);
        }

        openssl_pkey_export($resource, $this->privateKey);
        $details = openssl_pkey_get_details($resource);

        self::assertIsArray($details);

        $this->publicCertificate = $details['key'];
        $this->keyId = 'test-key';
        $this->projectId = 'test-project';
    }

    public function testValidTokenPassesVerification(): void
    {
        $jwt = $this->createToken();

        $provider = new FirebaseKeyProvider(json_encode([$this->keyId => $this->publicCertificate]));
        $validator = new FirebaseTokenValidator($this->projectId, $provider);

        $claims = $validator->assertValidAuthorization('Bearer ' . $jwt);

        self::assertSame('user-123', $claims['sub']);
    }

    public function testInvalidSignatureThrowsException(): void
    {
        $jwt = $this->createToken();
        $tampered = substr($jwt, 0, -2) . 'aa';

        $provider = new FirebaseKeyProvider(json_encode([$this->keyId => $this->publicCertificate]));
        $validator = new FirebaseTokenValidator($this->projectId, $provider);

        $this->expectException(AuthorizationException::class);
        $validator->assertValidAuthorization('Bearer ' . $tampered);
    }

    public function testAdminTokenBypassesVerification(): void
    {
        $adminToken = 'secret-admin-token';
        $provider = new FirebaseKeyProvider(json_encode([$this->keyId => $this->publicCertificate]));
        $validator = new FirebaseTokenValidator($this->projectId, $provider, $adminToken);

        $claims = $validator->assertValidAuthorization(null, $adminToken);

        self::assertSame(['admin' => true], $claims);
    }

    private function createToken(): string
    {
        $header = ['alg' => 'RS256', 'kid' => $this->keyId, 'typ' => 'JWT'];
        $now = time();
        $payload = [
            'aud' => $this->projectId,
            'iss' => 'https://securetoken.google.com/' . $this->projectId,
            'sub' => 'user-123',
            'exp' => $now + 3600,
            'iat' => $now,
        ];

        $encodedHeader = $this->base64UrlEncode(json_encode($header, JSON_THROW_ON_ERROR));
        $encodedPayload = $this->base64UrlEncode(json_encode($payload, JSON_THROW_ON_ERROR));
        $signatureInput = $encodedHeader . '.' . $encodedPayload;

        $signature = '';
        openssl_sign($signatureInput, $signature, $this->privateKey, OPENSSL_ALGO_SHA256);

        return $signatureInput . '.' . $this->base64UrlEncode($signature);
    }

    private function base64UrlEncode(string $value): string
    {
        return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
    }
}
