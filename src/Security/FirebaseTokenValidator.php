<?php

namespace App\Security;

use RuntimeException;

class FirebaseTokenValidator
{
    private const ISSUER_PREFIX = 'https://securetoken.google.com/';

    public function __construct(
        private readonly string $projectId,
        private readonly FirebaseKeyProvider $keyProvider,
        private readonly ?string $adminToken = null,
        private readonly int $leeway = 60
    ) {
        if ($this->projectId === '') {
            throw new RuntimeException('Firebase project ID must be configured.');
        }
    }

    public static function fromEnvironment(): self
    {
        $projectId = getenv('FIREBASE_PROJECT_ID') ?: '';
        $adminToken = getenv('ADMIN_API_TOKEN') ?: null;
        $keyProvider = FirebaseKeyProvider::fromEnvironment();

        return new self($projectId, $keyProvider, $adminToken);
    }

    /**
     * @param string|null $authorizationHeader Value from the Authorization header
     * @param string|null $fallbackToken Optional token provided outside the header (e.g., form field)
     *
     * @return array<string,mixed>
     *
     * @throws AuthorizationException
     */
    public function assertValidAuthorization(?string $authorizationHeader, ?string $fallbackToken = null): array
    {
        $token = $this->extractToken($authorizationHeader, $fallbackToken);

        if ($token === null) {
            throw new AuthorizationException('Missing bearer token.');
        }

        if ($this->adminToken !== null && hash_equals($this->adminToken, $token)) {
            return ['admin' => true];
        }

        return $this->verifyFirebaseToken($token);
    }

    private function extractToken(?string $authorizationHeader, ?string $fallbackToken = null): ?string
    {
        if (is_string($authorizationHeader) && $authorizationHeader !== '') {
            if (preg_match('/^Bearer\s+(.*)$/i', trim($authorizationHeader), $matches)) {
                $token = trim($matches[1]);
                if ($token !== '') {
                    return $token;
                }
            }
        }

        if (is_string($fallbackToken)) {
            $fallbackToken = trim($fallbackToken);
            if ($fallbackToken !== '') {
                return $fallbackToken;
            }
        }

        return null;
    }

    /**
     * @return array<string,mixed>
     */
    private function verifyFirebaseToken(string $jwt): array
    {
        $parts = explode('.', $jwt);
        if (count($parts) !== 3) {
            throw new AuthorizationException('Malformed JWT.');
        }

        [$encodedHeader, $encodedPayload, $encodedSignature] = $parts;

        $header = $this->decodeJsonSegment($encodedHeader);
        $payload = $this->decodeJsonSegment($encodedPayload);
        $signature = $this->decodeSignature($encodedSignature);

        if (($header['alg'] ?? null) !== 'RS256') {
            throw new AuthorizationException('Unsupported JWT algorithm.');
        }

        $keyId = $header['kid'] ?? null;
        if (!is_string($keyId) || $keyId === '') {
            throw new AuthorizationException('Missing key identifier.');
        }

        $certificate = $this->keyProvider->getCertificate($keyId);
        if ($certificate === null) {
            throw new AuthorizationException('Unable to resolve Firebase signing certificate.');
        }

        $publicKey = openssl_pkey_get_public($certificate);
        if ($publicKey === false) {
            throw new AuthorizationException('Invalid Firebase signing certificate.');
        }

        $dataToVerify = $encodedHeader . '.' . $encodedPayload;
        $verified = openssl_verify($dataToVerify, $signature, $publicKey, OPENSSL_ALGO_SHA256);
        openssl_free_key($publicKey);

        if ($verified !== 1) {
            throw new AuthorizationException('Invalid token signature.');
        }

        $this->assertValidClaims($payload);

        return $payload;
    }

    /**
     * @return array<string,mixed>
     */
    private function decodeJsonSegment(string $segment): array
    {
        $decoded = base64_decode(strtr($segment, '-_', '+/'), true);
        if ($decoded === false) {
            throw new AuthorizationException('Invalid token encoding.');
        }

        $data = json_decode($decoded, true);
        if (!is_array($data)) {
            throw new AuthorizationException('Invalid token payload.');
        }

        return $data;
    }

    private function decodeSignature(string $segment): string
    {
        $signature = base64_decode(strtr($segment, '-_', '+/'), true);
        if ($signature === false) {
            throw new AuthorizationException('Invalid token signature encoding.');
        }

        return $signature;
    }

    /**
     * @param array<string,mixed> $payload
     */
    private function assertValidClaims(array $payload): void
    {
        $now = time();
        $issuer = self::ISSUER_PREFIX . $this->projectId;

        $audience = $payload['aud'] ?? null;
        if ($audience !== $this->projectId) {
            throw new AuthorizationException('Invalid token audience.');
        }

        $tokenIssuer = $payload['iss'] ?? null;
        if ($tokenIssuer !== $issuer) {
            throw new AuthorizationException('Invalid token issuer.');
        }

        $subject = $payload['sub'] ?? null;
        if (!is_string($subject) || $subject === '') {
            throw new AuthorizationException('Invalid token subject.');
        }

        $expiration = $payload['exp'] ?? null;
        if (!is_int($expiration) || ($expiration + $this->leeway) < $now) {
            throw new AuthorizationException('Token expired.');
        }

        $notBefore = $payload['nbf'] ?? null;
        if (is_int($notBefore) && $notBefore - $this->leeway > $now) {
            throw new AuthorizationException('Token not yet valid.');
        }

        $issuedAt = $payload['iat'] ?? null;
        if (is_int($issuedAt) && $issuedAt - $this->leeway > $now) {
            throw new AuthorizationException('Token issued in the future.');
        }
    }
}
