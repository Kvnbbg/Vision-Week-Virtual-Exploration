<?php
require_once 'config.php';

session_start();

function getDatabaseConnection($dbFile) {
    try {
        $db = new PDO('sqlite:' . $dbFile);
        $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        return $db;
    } catch (PDOException $e) {
        error_log($e->getMessage());
        return null;
    }
}

$db = getDatabaseConnection(DB_FILE);

if ($db) {
    // Fetch recent articles (example dynamic content)
    try {
        $sql = "SELECT title, content, published_at FROM news ORDER BY published_at DESC LIMIT 3";
        $statement = $db->prepare($sql);
        $statement->execute();
        $articles = $statement->fetchAll(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        error_log($e->getMessage());
        $errorMessage = "Unable to fetch articles. Please try again later.";
    }

    // Check user session
    $welcomeMessage = isset($_SESSION['user']) ? "Welcome back, " . htmlspecialchars($_SESSION['user']['username']) . "!" : "Welcome to our website!";
} else {
    $errorMessage = "Database connection failed. Please try again later.";
}

function connectDatabase($dbFile) {
  try {
      $db = new PDO('sqlite:' . $dbFile);
      $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
      return $db;
  } catch (PDOException $e) {
      error_log($e->getMessage());
      return null;
  }
}

$usersDb = connectDatabase('sql/users.db');
$zooDb = connectDatabase('sql/zoo.db');
$dataDb = connectDatabase('sql/data.db');

// Example query
if ($usersDb) {
  $stmt = $usersDb->query("SELECT * FROM Users");
  $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
  print_r($users);
}

if ($zooDb) {
  $stmt = $zooDb->query("SELECT * FROM Zoo");
  $zoo = $stmt->fetchAll(PDO::FETCH_ASSOC);
  print_r($zoo);
}

if ($dataDb) {
  $stmt = $dataDb->query("SELECT * FROM DataAccessLog");
  $logs = $stmt->fetchAll(PDO::FETCH_ASSOC);
  print_r($logs);
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vision Week, a virtual exploration!</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <?php if (file_exists('header.php')) include 'header.php'; ?>
    <?php if (file_exists('navigation.php')) include 'navigation.php'; ?>

    <main>
        <button onclick="openDesignThinkingQuiz()">Take the Design Thinking Quiz</button>

        <?php if (isset($errorMessage)): ?>
            <p class="error"><?php echo htmlspecialchars($errorMessage); ?></p>
        <?php endif; ?>

        <h1><?php echo htmlspecialchars($welcomeMessage); ?></h1>

        <section>
            <?php if (isset($articles) && !empty($articles)): ?>
                <h2>Latest News</h2>
                <ul>
                    <?php foreach ($articles as $article): ?>
                        <li>
                            <h3><?php echo htmlspecialchars($article['title']); ?></h3>
                            <p><?php echo htmlspecialchars($article['content']); ?></p>
                            <p class="published-date">Published: <?php echo htmlspecialchars($article['published_at']); ?></p>
                        </li>
                    <?php endforeach; ?>
                </ul>
            <?php else: ?>
                <p>No recent news articles found.</p>
            <?php endif; ?>
        </section>
    </main>

    <?php if (file_exists('footer.php')) include 'footer.php'; ?>

    <script src="/assets/script.js"></script>
    <script src="/conception/receuil-des-besoins/design_thinking.js"></script>
</body>
</html>
