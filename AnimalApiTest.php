<?php

declare(strict_types=1);

namespace Tests\Integration;

use PHPUnit\Framework\TestCase;
use VisionWeek\Services\DatabaseService;
use VisionWeek\Controllers\AnimalController;
use VisionWeek\Models\Animal;

class AnimalApiTest extends TestCase
{
    private DatabaseService $db;
    private AnimalController $controller;
    private Animal $animalModel;

    protected function setUp(): void
    {
        // Setup test database connection
        $this->db = DatabaseService::getInstance([
            'host' => $_ENV['DB_HOST'] ?? 'localhost',
            'port' => $_ENV['DB_PORT'] ?? '5432',
            'database' => $_ENV['DB_DATABASE'] ?? 'vision_week_test',
            'username' => $_ENV['DB_USERNAME'] ?? 'postgres',
            'password' => $_ENV['DB_PASSWORD'] ?? 'postgres'
        ]);

        $this->animalModel = new Animal($this->db);
        $this->controller = new AnimalController($this->animalModel);

        // Clean up test data
        $this->cleanupTestData();
        
        // Setup test data
        $this->setupTestData();
    }

    private function setupTestData(): void
    {
        // Insert test categories
        $this->db->insert('categories', [
            'id' => 1,
            'name' => 'Mammals',
            'description' => 'Warm-blooded vertebrates'
        ]);

        $this->db->insert('categories', [
            'id' => 2,
            'name' => 'Birds',
            'description' => 'Feathered vertebrates'
        ]);

        // Insert test animals
        $this->db->insert('animals', [
            'id' => 1,
            'name' => 'African Lion',
            'scientific_name' => 'Panthera leo',
            'category_id' => 1,
            'description' => 'Large cat native to Africa',
            'habitat' => 'Savanna',
            'diet' => 'Carnivore',
            'conservation_status' => 'Vulnerable',
            'average_lifespan' => 15,
            'weight_range' => '120-250 kg',
            'height_range' => '0.9-1.2 m'
        ]);

        $this->db->insert('animals', [
            'id' => 2,
            'name' => 'Bengal Tiger',
            'scientific_name' => 'Panthera tigris',
            'category_id' => 1,
            'description' => 'Large cat native to India',
            'habitat' => 'Forest',
            'diet' => 'Carnivore',
            'conservation_status' => 'Endangered',
            'average_lifespan' => 12,
            'weight_range' => '140-300 kg',
            'height_range' => '0.9-1.1 m'
        ]);
    }

    private function cleanupTestData(): void
    {
        $this->db->execute('DELETE FROM animals WHERE id IN (1, 2, 3, 999)');
        $this->db->execute('DELETE FROM categories WHERE id IN (1, 2, 999)');
    }

    public function testGetAllAnimalsReturnsCorrectFormat(): void
    {
        $_GET = ['page' => '1', 'limit' => '10'];
        
        ob_start();
        $this->controller->getAll();
        $output = ob_get_clean();
        
        $response = json_decode($output, true);
        
        $this->assertIsArray($response);
        $this->assertArrayHasKey('success', $response);
        $this->assertArrayHasKey('data', $response);
        $this->assertArrayHasKey('pagination', $response);
        $this->assertTrue($response['success']);
        
        $this->assertArrayHasKey('animals', $response['data']);
        $this->assertArrayHasKey('total', $response['pagination']);
        $this->assertArrayHasKey('page', $response['pagination']);
        $this->assertArrayHasKey('limit', $response['pagination']);
        $this->assertArrayHasKey('pages', $response['pagination']);
    }

    public function testGetAnimalByIdReturnsCorrectAnimal(): void
    {
        $_GET = ['id' => '1'];
        
        ob_start();
        $this->controller->getById();
        $output = ob_get_clean();
        
        $response = json_decode($output, true);
        
        $this->assertIsArray($response);
        $this->assertTrue($response['success']);
        $this->assertArrayHasKey('data', $response);
        
        $animal = $response['data'];
        $this->assertEquals(1, $animal['id']);
        $this->assertEquals('African Lion', $animal['name']);
        $this->assertEquals('Panthera leo', $animal['scientific_name']);
        $this->assertEquals('Vulnerable', $animal['conservation_status']);
    }

    public function testGetAnimalByIdReturns404ForNonExistent(): void
    {
        $_GET = ['id' => '999'];
        
        ob_start();
        $this->controller->getById();
        $output = ob_get_clean();
        
        $response = json_decode($output, true);
        
        $this->assertIsArray($response);
        $this->assertFalse($response['success']);
        $this->assertEquals(404, $response['error']['code']);
        $this->assertStringContainsString('not found', $response['error']['message']);
    }

    public function testCreateAnimalWithValidData(): void
    {
        $animalData = [
            'name' => 'Snow Leopard',
            'scientific_name' => 'Panthera uncia',
            'category_id' => 1,
            'description' => 'Large cat native to mountain ranges',
            'habitat' => 'Mountains',
            'diet' => 'Carnivore',
            'conservation_status' => 'Vulnerable',
            'average_lifespan' => 18,
            'weight_range' => '22-55 kg',
            'height_range' => '0.6 m'
        ];

        $_POST = $animalData;
        $_SERVER['REQUEST_METHOD'] = 'POST';
        
        ob_start();
        $this->controller->create();
        $output = ob_get_clean();
        
        $response = json_decode($output, true);
        
        $this->assertIsArray($response);
        $this->assertTrue($response['success']);
        $this->assertArrayHasKey('data', $response);
        
        $createdAnimal = $response['data'];
        $this->assertArrayHasKey('id', $createdAnimal);
        $this->assertArrayHasKey('uuid', $createdAnimal);
        $this->assertEquals('Snow Leopard', $createdAnimal['name']);
        $this->assertEquals('Panthera uncia', $createdAnimal['scientific_name']);
    }

    public function testCreateAnimalWithInvalidDataReturns400(): void
    {
        $invalidData = [
            'name' => '', // Empty name
            'scientific_name' => 'invalid name', // Invalid format
            'category_id' => 'not-a-number' // Invalid type
        ];

        $_POST = $invalidData;
        $_SERVER['REQUEST_METHOD'] = 'POST';
        
        ob_start();
        $this->controller->create();
        $output = ob_get_clean();
        
        $response = json_decode($output, true);
        
        $this->assertIsArray($response);
        $this->assertFalse($response['success']);
        $this->assertEquals(400, $response['error']['code']);
        $this->assertArrayHasKey('validation_errors', $response['error']);
    }

    public function testCreateDuplicateAnimalReturns409(): void
    {
        $duplicateData = [
            'name' => 'Another Lion',
            'scientific_name' => 'Panthera leo', // Duplicate scientific name
            'category_id' => 1
        ];

        $_POST = $duplicateData;
        $_SERVER['REQUEST_METHOD'] = 'POST';
        
        ob_start();
        $this->controller->create();
        $output = ob_get_clean();
        
        $response = json_decode($output, true);
        
        $this->assertIsArray($response);
        $this->assertFalse($response['success']);
        $this->assertEquals(409, $response['error']['code']);
        $this->assertStringContainsString('already exists', $response['error']['message']);
    }

    public function testUpdateAnimalWithValidData(): void
    {
        $updateData = [
            'description' => 'Updated description for African Lion',
            'conservation_status' => 'Endangered'
        ];

        $_POST = $updateData;
        $_GET = ['id' => '1'];
        $_SERVER['REQUEST_METHOD'] = 'PUT';
        
        ob_start();
        $this->controller->update();
        $output = ob_get_clean();
        
        $response = json_decode($output, true);
        
        $this->assertIsArray($response);
        $this->assertTrue($response['success']);
        
        // Verify the update was applied
        $updatedAnimal = $this->animalModel->findById(1);
        $this->assertEquals('Updated description for African Lion', $updatedAnimal['description']);
        $this->assertEquals('Endangered', $updatedAnimal['conservation_status']);
    }

    public function testDeleteAnimalSoftDelete(): void
    {
        $_GET = ['id' => '2'];
        $_SERVER['REQUEST_METHOD'] = 'DELETE';
        
        ob_start();
        $this->controller->delete();
        $output = ob_get_clean();
        
        $response = json_decode($output, true);
        
        $this->assertIsArray($response);
        $this->assertTrue($response['success']);
        
        // Verify the animal is soft deleted (not returned in normal queries)
        $deletedAnimal = $this->animalModel->findById(2);
        $this->assertNull($deletedAnimal);
    }

    public function testSearchAnimalsWithQuery(): void
    {
        $_GET = ['q' => 'lion', 'limit' => '10'];
        
        ob_start();
        $this->controller->search();
        $output = ob_get_clean();
        
        $response = json_decode($output, true);
        
        $this->assertIsArray($response);
        $this->assertTrue($response['success']);
        $this->assertArrayHasKey('data', $response);
        
        $results = $response['data']['results'];
        $this->assertIsArray($results);
        $this->assertGreaterThan(0, count($results));
        
        // Check that results contain the search term
        $found = false;
        foreach ($results as $animal) {
            if (stripos($animal['name'], 'lion') !== false) {
                $found = true;
                break;
            }
        }
        $this->assertTrue($found);
    }

    public function testGetAnimalsByCategory(): void
    {
        $_GET = ['category_id' => '1'];
        
        ob_start();
        $this->controller->getByCategory();
        $output = ob_get_clean();
        
        $response = json_decode($output, true);
        
        $this->assertIsArray($response);
        $this->assertTrue($response['success']);
        $this->assertArrayHasKey('data', $response);
        
        $animals = $response['data']['animals'];
        $this->assertIsArray($animals);
        
        // All animals should belong to category 1 (Mammals)
        foreach ($animals as $animal) {
            $this->assertEquals(1, $animal['category_id']);
        }
    }

    public function testGetAnimalsByConservationStatus(): void
    {
        $_GET = ['status' => 'Vulnerable'];
        
        ob_start();
        $this->controller->getByConservationStatus();
        $output = ob_get_clean();
        
        $response = json_decode($output, true);
        
        $this->assertIsArray($response);
        $this->assertTrue($response['success']);
        $this->assertArrayHasKey('data', $response);
        
        $animals = $response['data']['animals'];
        $this->assertIsArray($animals);
        
        // All animals should have 'Vulnerable' status
        foreach ($animals as $animal) {
            $this->assertEquals('Vulnerable', $animal['conservation_status']);
        }
    }

    public function testGetStatistics(): void
    {
        ob_start();
        $this->controller->getStatistics();
        $output = ob_get_clean();
        
        $response = json_decode($output, true);
        
        $this->assertIsArray($response);
        $this->assertTrue($response['success']);
        $this->assertArrayHasKey('data', $response);
        
        $stats = $response['data']['statistics'];
        $this->assertArrayHasKey('total_animals', $stats);
        $this->assertArrayHasKey('by_category', $stats);
        $this->assertArrayHasKey('by_conservation_status', $stats);
        
        $this->assertGreaterThanOrEqual(2, $stats['total_animals']);
    }

    public function testRateLimitingOnApiEndpoints(): void
    {
        // Simulate multiple rapid requests
        $requestCount = 0;
        $maxRequests = 10;
        
        for ($i = 0; $i < $maxRequests + 5; $i++) {
            $_GET = ['id' => '1'];
            $_SERVER['REMOTE_ADDR'] = '127.0.0.1';
            
            ob_start();
            $this->controller->getById();
            $output = ob_get_clean();
            
            $response = json_decode($output, true);
            
            if ($response['success']) {
                $requestCount++;
            } else {
                // Should get rate limited
                $this->assertEquals(429, $response['error']['code']);
                break;
            }
        }
        
        // Should have been rate limited before reaching max + 5
        $this->assertLessThan($maxRequests + 5, $requestCount);
    }

    public function testCorsHeadersAreSet(): void
    {
        $_GET = ['id' => '1'];
        
        ob_start();
        $this->controller->getById();
        $output = ob_get_clean();
        
        $headers = headers_list();
        
        $corsHeaders = array_filter($headers, function($header) {
            return strpos($header, 'Access-Control-') === 0;
        });
        
        $this->assertNotEmpty($corsHeaders);
    }

    public function testSecurityHeadersAreSet(): void
    {
        $_GET = ['id' => '1'];
        
        ob_start();
        $this->controller->getById();
        $output = ob_get_clean();
        
        $headers = headers_list();
        
        $securityHeaders = [
            'X-Content-Type-Options',
            'X-Frame-Options',
            'X-XSS-Protection'
        ];
        
        foreach ($securityHeaders as $headerName) {
            $found = false;
            foreach ($headers as $header) {
                if (strpos($header, $headerName) === 0) {
                    $found = true;
                    break;
                }
            }
            $this->assertTrue($found, "Security header $headerName not found");
        }
    }

    protected function tearDown(): void
    {
        $this->cleanupTestData();
        $this->db = null;
        $this->controller = null;
        $this->animalModel = null;
        
        // Clear superglobals
        $_GET = [];
        $_POST = [];
        $_SERVER = [];
    }
}

