<?php

declare(strict_types=1);

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;
use VisionWeek\Services\ValidationService;

class ValidationServiceTest extends TestCase
{
    private ValidationService $validationService;

    protected function setUp(): void
    {
        $this->validationService = new ValidationService();
    }

    public function testValidateEmailWithValidEmail(): void
    {
        $validEmails = [
            'test@example.com',
            'user.name@domain.co.uk',
            'user+tag@example.org',
            'user123@test-domain.com'
        ];

        foreach ($validEmails as $email) {
            $this->assertTrue(
                $this->validationService->validateEmail($email),
                "Email '$email' should be valid"
            );
        }
    }

    public function testValidateEmailWithInvalidEmail(): void
    {
        $invalidEmails = [
            'invalid-email',
            '@example.com',
            'user@',
            'user..name@example.com',
            'user@.com',
            'user@domain.',
            'user name@example.com',
            'user@domain..com'
        ];

        foreach ($invalidEmails as $email) {
            $this->assertFalse(
                $this->validationService->validateEmail($email),
                "Email '$email' should be invalid"
            );
        }
    }

    public function testSanitizeStringRemovesHtmlTags(): void
    {
        $input = '<script>alert("xss")</script>Hello <b>World</b>';
        $expected = 'alert("xss")Hello World';
        
        $result = $this->validationService->sanitizeString($input);
        
        $this->assertEquals($expected, $result);
    }

    public function testSanitizeStringTrimsWhitespace(): void
    {
        $input = '  Hello World  ';
        $expected = 'Hello World';
        
        $result = $this->validationService->sanitizeString($input);
        
        $this->assertEquals($expected, $result);
    }

    public function testValidatePasswordWithValidPassword(): void
    {
        $validPasswords = [
            'Password123!',
            'MySecure@Pass1',
            'Complex#Password2024',
            'Strong$Pass123'
        ];

        foreach ($validPasswords as $password) {
            $this->assertTrue(
                $this->validationService->validatePassword($password),
                "Password '$password' should be valid"
            );
        }
    }

    public function testValidatePasswordWithInvalidPassword(): void
    {
        $invalidPasswords = [
            'short',                    // Too short
            'password',                 // No uppercase, numbers, or special chars
            'PASSWORD123',              // No lowercase or special chars
            'Password',                 // No numbers or special chars
            'Password123',              // No special chars
            'password123!',             // No uppercase
            'PASSWORD123!',             // No lowercase
        ];

        foreach ($invalidPasswords as $password) {
            $this->assertFalse(
                $this->validationService->validatePassword($password),
                "Password '$password' should be invalid"
            );
        }
    }

    public function testValidateAnimalDataWithValidData(): void
    {
        $validData = [
            'name' => 'Lion',
            'scientific_name' => 'Panthera leo',
            'category_id' => 1,
            'description' => 'The lion is a large cat of the genus Panthera.',
            'habitat' => 'Savanna',
            'diet' => 'Carnivore',
            'conservation_status' => 'Vulnerable',
            'average_lifespan' => 15,
            'weight_range' => '120-250 kg',
            'height_range' => '0.9-1.2 m'
        ];

        $result = $this->validationService->validateAnimalData($validData);
        
        $this->assertTrue($result['valid']);
        $this->assertEmpty($result['errors']);
    }

    public function testValidateAnimalDataWithInvalidData(): void
    {
        $invalidData = [
            'name' => '',                           // Empty name
            'scientific_name' => 'Invalid Name',   // Invalid scientific name format
            'category_id' => 'not-a-number',      // Invalid category ID
            'description' => str_repeat('a', 2001), // Too long description
            'average_lifespan' => -5,              // Negative lifespan
        ];

        $result = $this->validationService->validateAnimalData($invalidData);
        
        $this->assertFalse($result['valid']);
        $this->assertNotEmpty($result['errors']);
        $this->assertArrayHasKey('name', $result['errors']);
        $this->assertArrayHasKey('scientific_name', $result['errors']);
        $this->assertArrayHasKey('category_id', $result['errors']);
        $this->assertArrayHasKey('description', $result['errors']);
        $this->assertArrayHasKey('average_lifespan', $result['errors']);
    }

    public function testValidateScientificNameFormat(): void
    {
        $validNames = [
            'Panthera leo',
            'Homo sapiens',
            'Canis lupus',
            'Felis catus'
        ];

        foreach ($validNames as $name) {
            $this->assertTrue(
                $this->validationService->validateScientificName($name),
                "Scientific name '$name' should be valid"
            );
        }

        $invalidNames = [
            'panthera leo',     // Lowercase genus
            'Panthera Leo',     // Uppercase species
            'Panthera',         // Missing species
            'panthera',         // All lowercase
            'PANTHERA LEO',     // All uppercase
            'Panthera  leo',    // Double space
            'Panthera-leo',     // Hyphen instead of space
        ];

        foreach ($invalidNames as $name) {
            $this->assertFalse(
                $this->validationService->validateScientificName($name),
                "Scientific name '$name' should be invalid"
            );
        }
    }

    public function testSanitizeHtmlRemovesDangerousContent(): void
    {
        $dangerousInputs = [
            '<script>alert("xss")</script>',
            '<iframe src="javascript:alert(1)"></iframe>',
            '<img src="x" onerror="alert(1)">',
            '<a href="javascript:alert(1)">Click me</a>',
            '<div onclick="alert(1)">Click me</div>'
        ];

        foreach ($dangerousInputs as $input) {
            $result = $this->validationService->sanitizeHtml($input);
            
            $this->assertStringNotContainsString('<script', $result);
            $this->assertStringNotContainsString('javascript:', $result);
            $this->assertStringNotContainsString('onerror=', $result);
            $this->assertStringNotContainsString('onclick=', $result);
        }
    }

    public function testSanitizeHtmlKeepsAllowedTags(): void
    {
        $input = '<p>This is <strong>bold</strong> and <em>italic</em> text.</p>';
        $result = $this->validationService->sanitizeHtml($input);
        
        $this->assertStringContainsString('<p>', $result);
        $this->assertStringContainsString('<strong>', $result);
        $this->assertStringContainsString('<em>', $result);
        $this->assertStringContainsString('</p>', $result);
        $this->assertStringContainsString('</strong>', $result);
        $this->assertStringContainsString('</em>', $result);
    }

    public function testValidateImageUpload(): void
    {
        // Mock file upload data
        $validFile = [
            'name' => 'lion.jpg',
            'type' => 'image/jpeg',
            'size' => 1024 * 1024, // 1MB
            'tmp_name' => '/tmp/phpunit_test_file',
            'error' => UPLOAD_ERR_OK
        ];

        $result = $this->validationService->validateImageUpload($validFile);
        $this->assertTrue($result['valid']);

        // Test invalid file type
        $invalidFile = [
            'name' => 'script.php',
            'type' => 'application/php',
            'size' => 1024,
            'tmp_name' => '/tmp/phpunit_test_file',
            'error' => UPLOAD_ERR_OK
        ];

        $result = $this->validationService->validateImageUpload($invalidFile);
        $this->assertFalse($result['valid']);
        $this->assertArrayHasKey('type', $result['errors']);
    }

    public function testRateLimitValidation(): void
    {
        $identifier = 'test_user_123';
        $limit = 5;
        $window = 60; // 60 seconds

        // First 5 requests should pass
        for ($i = 0; $i < $limit; $i++) {
            $this->assertTrue(
                $this->validationService->checkRateLimit($identifier, $limit, $window)
            );
        }

        // 6th request should fail
        $this->assertFalse(
            $this->validationService->checkRateLimit($identifier, $limit, $window)
        );
    }

    public function testCsrfTokenGeneration(): void
    {
        $token1 = $this->validationService->generateCsrfToken();
        $token2 = $this->validationService->generateCsrfToken();

        $this->assertNotEmpty($token1);
        $this->assertNotEmpty($token2);
        $this->assertNotEquals($token1, $token2);
        $this->assertEquals(64, strlen($token1)); // 32 bytes = 64 hex chars
    }

    public function testCsrfTokenValidation(): void
    {
        $token = $this->validationService->generateCsrfToken();
        
        // Valid token should pass
        $this->assertTrue($this->validationService->validateCsrfToken($token));
        
        // Invalid token should fail
        $this->assertFalse($this->validationService->validateCsrfToken('invalid_token'));
        
        // Empty token should fail
        $this->assertFalse($this->validationService->validateCsrfToken(''));
    }

    protected function tearDown(): void
    {
        // Clean up any test data or reset state if needed
        $this->validationService = null;
    }
}

