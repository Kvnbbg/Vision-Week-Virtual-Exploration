<?php

declare(strict_types=1);

namespace Tests\Unit\Repository;

use App\Repository\AnimalRepository;
use PDO;
use PHPUnit\Framework\TestCase;

class AnimalRepositorySecurityTest extends TestCase
{
    private PDO $pdo;

    protected function setUp(): void
    {
        $this->pdo = new PDO('sqlite::memory:');
        $this->pdo->exec('CREATE TABLE Animals (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, type TEXT, country_id INTEGER)');
    }

    public function testInsertPreventsSqlInjection(): void
    {
        $repository = new AnimalRepository($this->pdo);

        $maliciousName = "Evil'; DROP TABLE Animals; --";
        $repository->insert($maliciousName, 'Predator', 1);

        $statement = $this->pdo->query('SELECT COUNT(*) as total FROM Animals');
        $count = (int) $statement->fetchColumn();

        self::assertSame(1, $count, 'Record should be inserted once.');

        $tables = $this->pdo->query("SELECT name FROM sqlite_master WHERE type='table' AND name='Animals'")->fetchAll(PDO::FETCH_ASSOC);
        self::assertNotEmpty($tables, 'Animals table should still exist after insertion.');
    }
}
