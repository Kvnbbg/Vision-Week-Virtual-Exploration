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

function fetchFromDatabase($db, $query) {
    try {
        $stmt = $db->query($query);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        error_log($e->getMessage());
        return [];
    }
}

$db = getDatabaseConnection(DB_FILE);
$usersDb = getDatabaseConnection('sql/users.db');
$zooDb = getDatabaseConnection('sql/zoo.db');
$dataDb = getDatabaseConnection('sql/data.db');

$articles = [];
$users = [];
$zoo = [];
$logs = [];
$errorMessage = '';

if ($db) {
    $articles = fetchFromDatabase($db, "SELECT title, content, published_at FROM news ORDER BY published_at DESC LIMIT 3");
} else {
    $errorMessage = "Database connection failed. Please try again later.";
}

$welcomeMessage = isset($_SESSION['user']) ? "Welcome back, " . htmlspecialchars($_SESSION['user']['username']) . "!" : "Welcome to our website!";

if ($usersDb) {
    $users = fetchFromDatabase($usersDb, "SELECT * FROM Users");
}

if ($zooDb) {
    $zoo = fetchFromDatabase($zooDb, "SELECT * FROM Zoo");
}

if ($dataDb) {
    $logs = fetchFromDatabase($dataDb, "SELECT * FROM DataAccessLog");
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vision Week, a virtual exploration!</title>
    <link rel="stylesheet" href="assets/styles.css">
    <link rel="icon" type="image/x-icon" href="assets/favicon.ico">
</head>

<body>
    <?php if (file_exists('header.php')) include 'header.php'; ?>
    <?php if (file_exists('navigation.php')) include 'navigation.php'; ?>

    <main>
        <button onclick="openDesignThinkingQuiz()">Take the Design Thinking Quiz</button>

        <?php if ($errorMessage): ?>
            <p class="error"><?php echo htmlspecialchars($errorMessage); ?></p>
        <?php endif; ?>

        <h1><?php echo htmlspecialchars($welcomeMessage); ?></h1>

        <section>
            <?php if (!empty($articles)): ?>
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

        <section>
            <h2>User Data</h2>
            <?php if (!empty($users)): ?>
                <ul>
                    <?php foreach ($users as $user): ?>
                        <li><?php echo htmlspecialchars($user['username']); ?> - <?php echo htmlspecialchars($user['email']); ?></li>
                    <?php endforeach; ?>
                </ul>
            <?php else: ?>
                <p>No user data found.</p>
            <?php endif; ?>
        </section>

        <section>
            <h2>Zoo Data</h2>
            <?php if (!empty($zoo)): ?>
                <ul>
                    <?php foreach ($zoo as $animal): ?>
                        <li><?php echo htmlspecialchars($animal['animal_name']); ?> (<?php echo htmlspecialchars($animal['animal_type']); ?>) - <?php echo htmlspecialchars($animal['country_name']); ?></li>
                    <?php endforeach; ?>
                </ul>
            <?php else: ?>
                <p>No zoo data found.</p>
            <?php endif; ?>
        </section>

        <section>
            <h2>Access Logs</h2>
            <?php if (!empty($logs)): ?>
                <ul>
                    <?php foreach ($logs as $log): ?>
                        <li>User ID: <?php echo htmlspecialchars($log['user_id']); ?> accessed Data ID: <?php echo htmlspecialchars($log['data_id']); ?> at <?php echo htmlspecialchars($log['access_time']); ?> for action: <?php echo htmlspecialchars($log['action']); ?></li>
                    <?php endforeach; ?>
                </ul>
            <?php else: ?>
                <p>No access logs found.</p>
            <?php endif; ?>
        </section>

        <section>
            <h2>Game with ai randomizer position</h2>
        <?php if (file_exists('game.php')) include 'game.php'; ?>
        </section>
    </main>

    <?php if (file_exists('footer.php')) include 'footer.php'; ?>

    <script src="/assets/script.js"></script>
    <script src="/conception/receuil-des-besoins/design_thinking.js"></script>
</body>
</html>
