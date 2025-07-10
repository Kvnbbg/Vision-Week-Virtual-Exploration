<?php
use PHPUnit\Framework\TestCase;

class DatabaseTest extends TestCase
{
  private $pdo;

  public function setUp(): void
  {
    // Read database connection details from environment variables for CI, with defaults for local testing
    $host = getenv('DB_HOST_CI') ?: '127.0.0.1';
    $port = getenv('DB_PORT_CI') ?: '3306';
    $dbName = getenv('DB_NAME_CI') ?: 'vision_week_db'; // Default to the one used in docker-compose & CI
    $user = getenv('DB_USER_CI') ?: 'visionuser';     // Default to the one used in docker-compose & CI
    $pass = getenv('DB_PASS_CI') ?: 'visionpass';     // Default to the one used in docker-compose & CI

    $dsn = "mysql:host={$host};port={$port};dbname={$dbName};charset=utf8mb4";

    try {
        $this->pdo = new PDO($dsn, $user, $pass, [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ]);
    } catch (\PDOException $e) {
        // It's useful to see the DSN in case of connection errors during tests
        throw new \PDOException($e->getMessage() . " (DSN: $dsn)", (int)$e->getCode());
    }
  }

  public function testInsertNewAnimal()
  {
    $animalName = 'Leo';
    $animalType = 'Lion';
    $countryId = 1;

    $inserted = $this->insertAnimalIntoDatabase($animalName, $animalType, $countryId);

    $this->assertTrue($inserted);
  }

  private function insertAnimalIntoDatabase($name, $type, $countryId)
  {
    $sql = "INSERT INTO animals (name, type, country_id) VALUES (:name, :type, :countryId)";
    $statement = $this->pdo->prepare($sql);
    $statement->execute([
      ':name' => $name,
      ':type' => $type,
      ':countryId' => $countryId,
    ]);

    return $statement->rowCount() > 0;
  }

  public function testRetrieveAnimalData()
  {
    $animalData = $this->retrieveAnimalDataFromDatabase();

    $this->assertNotEmpty($animalData);
  }

  private function retrieveAnimalDataFromDatabase()
  {
    $sql = "SELECT * FROM animals";
    $statement = $this->pdo->query($sql);
    return $statement->fetchAll(PDO::FETCH_ASSOC);
  }

  public function testUpdateAnimalInformation()
  {
    $animalId = 1;
    $newAnimalType = 'Tiger';

    $updated = $this->updateAnimalInformationInDatabase($animalId, $newAnimalType);

    $this->assertTrue($updated);
  }

  private function updateAnimalInformationInDatabase($id, $newType)
  {
    $sql = "UPDATE animals SET type = :type WHERE id = :id";
    $statement = $this->pdo->prepare($sql);
    $statement->execute([
      ':type' => $newType,
      ':id' => $id,
    ]);

    return $statement->rowCount() > 0;
  }

  public function testDeleteAnimal()
  {
    $animalId = 1;

    $deleted = $this->deleteAnimalFromDatabase($animalId);

    $this->assertTrue($deleted);
  }

  private function deleteAnimalFromDatabase($id)
  {
    $sql = "DELETE FROM animals WHERE id = :id";
    $statement = $this->pdo->prepare($sql);
    $statement->execute([':id' => $id]);

    return $statement->rowCount() > 0;
  }
}
