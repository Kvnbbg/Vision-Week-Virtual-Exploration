<?php
use PHPUnit\Framework\TestCase;

class DatabaseTest extends TestCase
{
  private $pdo;

  public function setUp(): void
  {
    // Replace with your actual database connection details
    $this->pdo = new PDO('mysql:host=localhost;dbname=your_database', 'username', 'password');
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
