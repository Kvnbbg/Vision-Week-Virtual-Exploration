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
$usersDb = getDatabaseConnection('sql/users.db');
$zooDb = getDatabaseConnection('sql/zoo.db');
$dataDb = getDatabaseConnection('sql/data.db');

$articles = [];
$users = [];
$zoo = [];
$logs = [];
$errorMessage = '';
$welcomeMessage = '';

if ($db) {
    try {
        $sql = "SELECT title, content, published_at FROM news ORDER BY published_at DESC LIMIT 3";
        $statement = $db->prepare($sql);
        $statement->execute();
        $articles = $statement->fetchAll(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        error_log($e->getMessage());
        $errorMessage = "Unable to fetch articles. Please try again later.";
    }
} else {
    $errorMessage = "Database connection failed. Please try again later.";
}

if (isset($_SESSION['user'])) {
    $welcomeMessage = "Welcome back, " . htmlspecialchars($_SESSION['user']['username']) . "!";
} else {
    $welcomeMessage = "Welcome to our website!";
}

if ($usersDb) {
    try {
        $stmt = $usersDb->query("SELECT * FROM Users");
        $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        error_log($e->getMessage());
    }
}

if ($zooDb) {
    try {
        $stmt = $zooDb->query("SELECT * FROM Zoo");
        $zoo = $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        error_log($e->getMessage());
    }
}

if ($dataDb) {
    try {
        $stmt = $dataDb->query("SELECT * FROM DataAccessLog");
        $logs = $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        error_log($e->getMessage());
    }
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
                        <li>
                            <?php echo htmlspecialchars($user['username']); ?> - <?php echo htmlspecialchars($user['email']); ?>
                        </li>
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
                        <li>
                            <?php echo htmlspecialchars($animal['animal_name']); ?> (<?php echo htmlspecialchars($animal['animal_type']); ?>) - <?php echo htmlspecialchars($animal['country_name']); ?>
                        </li>
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
                        <li>
                            User ID: <?php echo htmlspecialchars($log['user_id']); ?> accessed Data ID: <?php echo htmlspecialchars($log['data_id']); ?> at <?php echo htmlspecialchars($log['access_time']); ?> for action: <?php echo htmlspecialchars($log['action']); ?>
                        </li>
                    <?php endforeach; ?>
                </ul>
            <?php else: ?>
                <p>No access logs found.</p>
            <?php endif; ?>
        </section>
    </main>

    <?php if (file_exists('footer.php')) include 'footer.php'; ?>

    <script src="/assets/script.js"></script>
    <script src="/conception/receuil-des-besoins/design_thinking.js"></script>
</body>
</html>
