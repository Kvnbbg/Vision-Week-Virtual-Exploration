<?php
// Configuration (consider using a separate file for production/development)
define('ENVIRONMENT', 'development'); // Change to 'production' for live deployment

if (ENVIRONMENT === 'development') {
  error_reporting(E_ALL);
  ini_set('display_errors', 1);
} else {
  error_reporting(0);
  ini_set('display_errors', 0);
}

// Include essential files
require_once 'config.php'; // Database connection, security settings, etc.

// Start a session for user management (optional)
session_start();

// Dynamic content generation

try {
  // Connect to database (refer to config.php)
  $db = new PDO(DB_DSN, DB_USER, DB_PASSWORD);

  // Example: Fetch recent news articles
  $sql = "SELECT title, content, published_at FROM news ORDER BY published_at DESC LIMIT 3";
  $statement = $db->prepare($sql);
  $statement->execute();
  $articles = $statement->fetchAll(PDO::FETCH_ASSOC);

  // Example: Display user information based on session data (if logged in)
  if (isset($_SESSION['user'])) {
    $username = $_SESSION['user']['username'];
    $welcomeMessage = "Welcome back, $username!";
  } else {
    $welcomeMessage = "Welcome to our website!";
  }

  // You can add more dynamic logic here based on user input, URL parameters, etc.
} catch (PDOException $e) {
  // Error handling: Log the error and display a generic message to the user
  error_log($e->getMessage());
  $errorMessage = "An error occurred. Please try again later.";
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Dynamic Website</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <?php if (file_exists('header.php')) include_once 'header.php'; ?>

  <?php if (file_exists('navigation.php')) include_once 'navigation.php'; ?>

  <main>
    <?php if (isset($errorMessage)) : ?>
      <p class="error"><?php echo $errorMessage; ?></p>
    <?php endif; ?>

    <?php if (isset($welcomeMessage)) : ?>
      <h1><?php echo $welcomeMessage; ?></h1>
    <?php endif; ?>

    <section>
      <?php if (!empty($articles)) : ?>
        <h2>Latest News</h2>
        <ul>
          <?php foreach ($articles as $article) : ?>
            <li>
              <h3><?php echo $article['title']; ?></h3>
              <p><?php echo $article['content']; ?></p>
              <p class="published-date">Published: <?php echo $article['published_at']; ?></p>
            </li>
          <?php endforeach; ?>
        </ul>
      <?php else : ?>
        <p>No recent news articles found.</p>
      <?php endif; ?>
    </section>

    </main>

  <?php if (file_exists('footer.php')) include_once 'footer.php'; ?>

  <script src="script.js"></script>
</body>
</html>
