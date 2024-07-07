<?php
// This script initializes the database connection, serves the Flutter web build, 
// and handles data fetching for the Vision Week app.

// Parse the JawsDB connection information
$jawsdb_url = parse_url(getenv("JAWSDB_URL"));
$jawsdb_server = $jawsdb_url["host"];
$jawsdb_username = $jawsdb_url["user"];
$jawsdb_password = $jawsdb_url["pass"];
$jawsdb_db = substr($jawsdb_url["path"], 1);

// Connect to the database
$conn = new mysqli($jawsdb_server, $jawsdb_username, $jawsdb_password, $jawsdb_db);

// Check the connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Function to fetch data from the database
function fetchFromDatabase($conn, $query) {
    $result = $conn->query($query);
    return $result ? $result->fetch_all(MYSQLI_ASSOC) : [];
}

// Fetch data for various sections
$articles = fetchFromDatabase($conn, "SELECT title, content, published_at FROM news ORDER BY published_at DESC LIMIT 3");
$users = fetchFromDatabase($conn, "SELECT * FROM Users");
$zoo = fetchFromDatabase($conn, "SELECT * FROM Zoo");
$logs = fetchFromDatabase($conn, "SELECT * FROM DataAccessLog");

// Determine welcome message
session_start();
$welcomeMessage = isset($_SESSION['user']) ? "Welcome back, " . htmlspecialchars($_SESSION['user']['username']) . "!" : "Welcome to our website!";

// HTML output begins here
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vision Week - Virtual Exploration</title>
    <link rel="stylesheet" href="assets/styles.css">
</head>
<body>
    <?php if (file_exists('header.php')) include 'header.php'; ?>
    <?php if (file_exists('navigation.php')) include 'navigation.php'; ?>

    <main>
        <h1><?php echo htmlspecialchars($welcomeMessage); ?></h1>

        <section>
            <h2>Latest News</h2>
            <?php if (!empty($articles)): ?>
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
    </main>

    <?php if (file_exists('footer.php')) include 'footer.php'; ?>
    <script src="/assets/script.js"></script>
</body>
</html>

<?php
// Close the database connection
$conn->close();
?>
