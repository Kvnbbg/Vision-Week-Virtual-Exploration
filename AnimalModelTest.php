<?php

declare(strict_types=1);

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;
use VisionWeek\Models\Animal;
use VisionWeek\Services\DatabaseService;

class AnimalModelTest extends TestCase
{
    private Animal $animal;
    private $mockDb;

    protected function setUp(): void
    {
        // Mock the database service
        $this->mockDb = $this->createMock(DatabaseService::class);
        $this->animal = new Animal($this->mockDb);
    }

    public function testCreateAnimalWithValidData(): void
    {
        $animalData = [
            'name' => 'African Lion',
            'scientific_name' => 'Panthera leo',
            'category_id' => 1,
            'description' => 'The African lion is a large cat native to Africa.',
            'habitat' => 'Savanna and grasslands',
            'diet' => 'Carnivore',
            'conservation_status' => 'Vulnerable',
            'average_lifespan' => 15,
            'weight_range' => '120-250 kg',
            'height_range' => '0.9-1.2 m',
            'fun_facts' => ['Known as the "King of the Jungle"', 'Lives in prides'],
            'image_url' => 'https://example.com/lion.jpg'
        ];

        // Mock successful database insertion
        $this->mockDb->expects($this->once())
                    ->method('insert')
                    ->with('animals', $this->anything())
                    ->willReturn(['id' => 1, 'uuid' => 'test-uuid-123']);

        $result = $this->animal->create($animalData);

        $this->assertIsArray($result);
        $this->assertArrayHasKey('id', $result);
        $this->assertArrayHasKey('uuid', $result);
        $this->assertEquals(1, $result['id']);
    }

    public function testCreateAnimalWithDuplicateScientificName(): void
    {
        $animalData = [
            'name' => 'Lion',
            'scientific_name' => 'Panthera leo',
            'category_id' => 1
        ];

        // Mock database constraint violation
        $this->mockDb->expects($this->once())
                    ->method('insert')
                    ->willThrowException(new \PDOException('UNIQUE constraint failed'));

        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Animal with this scientific name already exists');

        $this->animal->create($animalData);
    }

    public function testFindByIdReturnsAnimal(): void
    {
        $expectedAnimal = [
            'id' => 1,
            'uuid' => 'test-uuid-123',
            'name' => 'Lion',
            'scientific_name' => 'Panthera leo',
            'category_id' => 1,
            'created_at' => '2024-01-01 12:00:00'
        ];

        $this->mockDb->expects($this->once())
                    ->method('findById')
                    ->with('animals', 1)
                    ->willReturn($expectedAnimal);

        $result = $this->animal->findById(1);

        $this->assertEquals($expectedAnimal, $result);
    }

    public function testFindByIdReturnsNullForNonExistent(): void
    {
        $this->mockDb->expects($this->once())
                    ->method('findById')
                    ->with('animals', 999)
                    ->willReturn(null);

        $result = $this->animal->findById(999);

        $this->assertNull($result);
    }

    public function testFindByScientificName(): void
    {
        $scientificName = 'Panthera leo';
        $expectedAnimal = [
            'id' => 1,
            'name' => 'Lion',
            'scientific_name' => $scientificName
        ];

        $this->mockDb->expects($this->once())
                    ->method('findBy')
                    ->with('animals', ['scientific_name' => $scientificName])
                    ->willReturn($expectedAnimal);

        $result = $this->animal->findByScientificName($scientificName);

        $this->assertEquals($expectedAnimal, $result);
    }

    public function testSearchAnimalsWithQuery(): void
    {
        $searchQuery = 'lion';
        $expectedResults = [
            [
                'id' => 1,
                'name' => 'African Lion',
                'scientific_name' => 'Panthera leo',
                'relevance_score' => 0.95
            ],
            [
                'id' => 2,
                'name' => 'Mountain Lion',
                'scientific_name' => 'Puma concolor',
                'relevance_score' => 0.75
            ]
        ];

        $this->mockDb->expects($this->once())
                    ->method('search')
                    ->with('animals', $searchQuery, $this->anything())
                    ->willReturn($expectedResults);

        $result = $this->animal->search($searchQuery);

        $this->assertIsArray($result);
        $this->assertCount(2, $result);
        $this->assertEquals($expectedResults, $result);
    }

    public function testGetAllWithPagination(): void
    {
        $page = 1;
        $limit = 10;
        $expectedAnimals = [
            ['id' => 1, 'name' => 'Lion'],
            ['id' => 2, 'name' => 'Tiger'],
            ['id' => 3, 'name' => 'Elephant']
        ];

        $this->mockDb->expects($this->once())
                    ->method('paginate')
                    ->with('animals', $page, $limit, $this->anything())
                    ->willReturn([
                        'data' => $expectedAnimals,
                        'total' => 25,
                        'page' => $page,
                        'limit' => $limit,
                        'pages' => 3
                    ]);

        $result = $this->animal->getAll($page, $limit);

        $this->assertIsArray($result);
        $this->assertArrayHasKey('data', $result);
        $this->assertArrayHasKey('total', $result);
        $this->assertArrayHasKey('pages', $result);
        $this->assertEquals($expectedAnimals, $result['data']);
        $this->assertEquals(25, $result['total']);
    }

    public function testUpdateAnimal(): void
    {
        $animalId = 1;
        $updateData = [
            'description' => 'Updated description',
            'conservation_status' => 'Endangered'
        ];

        $this->mockDb->expects($this->once())
                    ->method('update')
                    ->with('animals', $animalId, $this->anything())
                    ->willReturn(true);

        $result = $this->animal->update($animalId, $updateData);

        $this->assertTrue($result);
    }

    public function testDeleteAnimalSoftDelete(): void
    {
        $animalId = 1;

        $this->mockDb->expects($this->once())
                    ->method('softDelete')
                    ->with('animals', $animalId)
                    ->willReturn(true);

        $result = $this->animal->delete($animalId);

        $this->assertTrue($result);
    }

    public function testGetByCategory(): void
    {
        $categoryId = 1;
        $expectedAnimals = [
            ['id' => 1, 'name' => 'Lion', 'category_id' => 1],
            ['id' => 2, 'name' => 'Tiger', 'category_id' => 1]
        ];

        $this->mockDb->expects($this->once())
                    ->method('findAllBy')
                    ->with('animals', ['category_id' => $categoryId])
                    ->willReturn($expectedAnimals);

        $result = $this->animal->getByCategory($categoryId);

        $this->assertEquals($expectedAnimals, $result);
    }

    public function testGetByConservationStatus(): void
    {
        $status = 'Endangered';
        $expectedAnimals = [
            ['id' => 1, 'name' => 'Tiger', 'conservation_status' => 'Endangered'],
            ['id' => 2, 'name' => 'Rhino', 'conservation_status' => 'Endangered']
        ];

        $this->mockDb->expects($this->once())
                    ->method('findAllBy')
                    ->with('animals', ['conservation_status' => $status])
                    ->willReturn($expectedAnimals);

        $result = $this->animal->getByConservationStatus($status);

        $this->assertEquals($expectedAnimals, $result);
    }

    public function testValidateAnimalDataSuccess(): void
    {
        $validData = [
            'name' => 'Lion',
            'scientific_name' => 'Panthera leo',
            'category_id' => 1,
            'description' => 'A large cat',
            'habitat' => 'Savanna',
            'diet' => 'Carnivore',
            'conservation_status' => 'Vulnerable',
            'average_lifespan' => 15
        ];

        $result = $this->animal->validateData($validData);

        $this->assertTrue($result['valid']);
        $this->assertEmpty($result['errors']);
    }

    public function testValidateAnimalDataFailure(): void
    {
        $invalidData = [
            'name' => '', // Empty name
            'scientific_name' => 'invalid name', // Invalid format
            'category_id' => 'not-a-number', // Invalid type
            'average_lifespan' => -5 // Negative value
        ];

        $result = $this->animal->validateData($invalidData);

        $this->assertFalse($result['valid']);
        $this->assertNotEmpty($result['errors']);
        $this->assertArrayHasKey('name', $result['errors']);
        $this->assertArrayHasKey('scientific_name', $result['errors']);
        $this->assertArrayHasKey('category_id', $result['errors']);
        $this->assertArrayHasKey('average_lifespan', $result['errors']);
    }

    public function testBulkInsertAnimals(): void
    {
        $animalsData = [
            [
                'name' => 'Lion',
                'scientific_name' => 'Panthera leo',
                'category_id' => 1
            ],
            [
                'name' => 'Tiger',
                'scientific_name' => 'Panthera tigris',
                'category_id' => 1
            ]
        ];

        $this->mockDb->expects($this->once())
                    ->method('bulkInsert')
                    ->with('animals', $this->anything())
                    ->willReturn([
                        'inserted' => 2,
                        'failed' => 0,
                        'errors' => []
                    ]);

        $result = $this->animal->bulkInsert($animalsData);

        $this->assertEquals(2, $result['inserted']);
        $this->assertEquals(0, $result['failed']);
        $this->assertEmpty($result['errors']);
    }

    public function testGetStatistics(): void
    {
        $expectedStats = [
            'total_animals' => 150,
            'by_category' => [
                'Mammals' => 75,
                'Birds' => 45,
                'Reptiles' => 20,
                'Fish' => 10
            ],
            'by_conservation_status' => [
                'Least Concern' => 80,
                'Vulnerable' => 35,
                'Endangered' => 25,
                'Critically Endangered' => 10
            ]
        ];

        $this->mockDb->expects($this->once())
                    ->method('getStatistics')
                    ->with('animals')
                    ->willReturn($expectedStats);

        $result = $this->animal->getStatistics();

        $this->assertEquals($expectedStats, $result);
    }

    protected function tearDown(): void
    {
        $this->animal = null;
        $this->mockDb = null;
    }
}

