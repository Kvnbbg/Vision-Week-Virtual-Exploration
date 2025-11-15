<?php

namespace App\Security;

use RuntimeException;

class FirebaseKeyProvider
{
    private const DEFAULT_CERT_URL = 'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com';

    private ?array $certificates = null;
    private ?int $loadedAt = null;

    public function __construct(
        private readonly ?string $certsJson = null,
        private readonly ?string $certsFile = null,
        private readonly ?string $certsUrl = null,
        private readonly ?int $cacheTtl = 3600
    ) {
    }

    public static function fromEnvironment(): self
    {
        $json = getenv('FIREBASE_CERTS_JSON') ?: null;
        $file = getenv('FIREBASE_CERTS_FILE') ?: null;
        $url = getenv('FIREBASE_CERTS_URL') ?: null;

        if ($url === null && $json === null && $file === null) {
            $url = self::DEFAULT_CERT_URL;
        }

        $ttl = getenv('FIREBASE_CERTS_TTL');
        $ttl = is_string($ttl) && ctype_digit($ttl) ? (int) $ttl : 3600;

        return new self($json, $file, $url, $ttl > 0 ? $ttl : null);
    }

    /**
     * @return array<string,string>
     */
    public function getCertificates(): array
    {
        if ($this->certificates !== null && $this->isCacheValid()) {
            return $this->certificates;
        }

        $this->certificates = $this->loadCertificates();
        $this->loadedAt = time();

        return $this->certificates;
    }

    public function getCertificate(string $keyId): ?string
    {
        $certificates = $this->getCertificates();

        if (array_key_exists($keyId, $certificates)) {
            return $certificates[$keyId];
        }

        // Attempt to refresh once when certificate not found.
        $this->certificates = null;
        $certificates = $this->getCertificates();

        return $certificates[$keyId] ?? null;
    }

    private function isCacheValid(): bool
    {
        if ($this->cacheTtl === null) {
            return $this->certificates !== null;
        }

        if ($this->loadedAt === null) {
            return false;
        }

        return (time() - $this->loadedAt) < $this->cacheTtl;
    }

    /**
     * @return array<string,string>
     */
    private function loadCertificates(): array
    {
        if ($this->certsJson !== null) {
            return $this->decodeCertificates($this->certsJson);
        }

        if ($this->certsFile !== null) {
            if (!is_file($this->certsFile)) {
                throw new RuntimeException('Firebase certificate file not found: ' . $this->certsFile);
            }

            $contents = file_get_contents($this->certsFile);
            if ($contents === false) {
                throw new RuntimeException('Unable to read Firebase certificate file: ' . $this->certsFile);
            }

            return $this->decodeCertificates($contents);
        }

        if ($this->certsUrl !== null) {
            $context = stream_context_create([
                'http' => [
                    'timeout' => 5,
                ],
            ]);
            $contents = @file_get_contents($this->certsUrl, false, $context);
            if ($contents === false) {
                throw new RuntimeException('Unable to download Firebase certificates from ' . $this->certsUrl);
            }

            return $this->decodeCertificates($contents);
        }

        throw new RuntimeException('No Firebase certificate source configured.');
    }

    /**
     * @return array<string,string>
     */
    private function decodeCertificates(string $json): array
    {
        $data = json_decode($json, true);
        if (!is_array($data)) {
            throw new RuntimeException('Invalid Firebase certificate payload.');
        }

        $certificates = [];
        foreach ($data as $keyId => $certificate) {
            if (!is_string($keyId) || !is_string($certificate)) {
                continue;
            }
            $certificates[$keyId] = $certificate;
        }

        if ($certificates === []) {
            throw new RuntimeException('No Firebase certificates available.');
        }

        return $certificates;
    }
}
