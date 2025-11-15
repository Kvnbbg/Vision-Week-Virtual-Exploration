<?php

namespace App\Repository;

use InvalidArgumentException;
use PDO;
use PDOException;

class AnimalRepository
{
    public function __construct(private readonly PDO $pdo)
    {
        $this->pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $this->pdo->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
    }

    public function insert(string $name, string $type, int $countryId): void
    {
        $cleanName = trim($name);
        $cleanType = trim($type);

        if ($cleanName === '' || $cleanType === '') {
            throw new InvalidArgumentException('Name and type are required.');
        }

        $statement = $this->pdo->prepare(
            'INSERT INTO Animals (name, type, country_id) VALUES (:name, :type, :country_id)'
        );

        $statement->execute([
            ':name' => $cleanName,
            ':type' => $cleanType,
            ':country_id' => $countryId,
        ]);
    }
}
