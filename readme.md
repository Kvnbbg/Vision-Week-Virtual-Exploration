# Vision Week 🚀

[![GitHub contributors](https://img.shields.io/github/contributors/Kvnbbg/Vision-Week)](https://github.com/Kvnbbg/Vision-Week/graphs/contributors)
[![GitHub issues](https://img.shields.io/github/issues/Kvnbbg/Vision-Week)](https://github.com/Kvnbbg/Vision-Week/issues)
[![GitHub forks](https://img.shields.io/github/forks/Kvnbbg/Vision-Week)](https://github.com/Kvnbbg/Vision-Week/network)
[![GitHub stars](https://img.shields.io/github/stars/Kvnbbg/Vision-Week)](https://github.com/Kvnbbg/Vision-Week/stargazers)
[![GitHub license](https://img.shields.io/github/license/Kvnbbg/Vision-Week)](https://github.com/Kvnbbg/Vision-Week/blob/main/LICENSE)

Welcome to Vision Week, a web application dedicated to showcasing a curated collection of exploration videos, offering viewers a chance to virtually embark on exciting adventures.

## About

Vision Week, formerly known as Exploration Video Website, is a project designed to bring the spirit of exploration to your fingertips. Whether you're passionate about deep-sea diving, space exploration, archaeology, or nature, Vision Week has something for everyone.

## Preview

👁️ [Watch the preview of Vision Week](https://kvnbbg.github.io/Vision-Week-Virtual-Exploration/)

## Features

* **Explore by Category:** Discover videos organized by exploration type.
* **Search Functionality:** Find specific videos using keywords or location.
* **Detailed Information:** Learn more about each exploration with descriptions, source links, and additional resources (future implementation).
* **Latest News Updates:** Stay informed with the most recent articles and news updates fetched and displayed from the database.
* **User Data Management:** Manage and view user data efficiently, including registration, login, and profile management.
* **Zoo Information:** Explore detailed information about various animals and their habitats, perfect for animal lovers and those curious about wildlife.
* **Access Logs:** Keep track of data access logs, providing transparency and security for user interactions with the app.
* **Interactive Experience (Future):** Users can interact with other viewers through comments and ratings (future implementation).
* **Wider Video Library (Future):** Integrate with platforms like YouTube or Vimeo for a more extensive video collection (future implementation).

## Technologies

* **Frontend:** HTML, CSS, JavaScript
* **Backend (Future Implementation):** Potentially a server-side language like PHP to manage video data and user interactions.
* **Database:** SQLite for quick and easy setup, with plans to migrate to MySQL in the future.

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Kvnbbg/Vision-Week.git
   cd Vision-Week
   ```

2. **Open in your browser:**
   Open `index.php` in your browser and start your built-in server. 

## Code Snippet

Here’s a glimpse of the code that powers Vision Week:

```php
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

$articles = fetchFromDatabase($db, "SELECT title, content, published_at FROM news ORDER BY published_at DESC LIMIT 3");
$users = fetchFromDatabase($usersDb, "SELECT * FROM Users");
$zoo = fetchFromDatabase($zooDb, "SELECT * FROM Zoo");
$logs = fetchFromDatabase($dataDb, "SELECT * FROM DataAccessLog");

$welcomeMessage = isset($_SESSION['user']) ? "Welcome back, " . htmlspecialchars($_SESSION['user']['username']) . "!" : "Welcome to our website!";
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
    </main>

    <?php if (file_exists('footer.php')) include 'footer.php'; ?>

    <script src="/assets/script.js"></script>
    <script src="/conception/receuil-des-besoins/design_thinking.js"></script>
</body>
</html>
```

## Contributing

We welcome contributions to improve this project! Feel free to fork the repository and submit pull requests with your enhancements.

Read our [CONTRIBUTING](CONTRIBUTING.md) guidelines for more details.

## Future Development

* **Video Platform Integration:** Integrate with video platforms like YouTube or Vimeo.
* **User Interactions:** Implement user comments and ratings for a more interactive experience.
* **Educational Resources:** Add educational resources related to different exploration fields.
* **Backend Development:** Develop a backend to manage video data and user interactions.

## Sponsor Vision Week

Your sponsorship helps cover expenses such as hosting fees, domain registration, and development tools, allowing us to continue improving and expanding Vision Week for the community.

Read more about [SPONSORING](SPONSORING.md) Vision Week.

Thank you for your support!

## Acknowledgements

This project was created by Kevin MARVILLE for STUDI. Special thanks to [STUDI](remerciements/STUDI) for their support and inspiration.

## Learn More

For more information, visit [kvnbbg.fr](https://kvnbbg.fr).

## Useful Links

- [Learn more about PHP](https://www.php.net/)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [JavaScript Info](https://javascript.info/)
- [Node.js Documentation](https://nodejs.org/en/docs/)
- [Express.js Documentation](https://expressjs.com/)

---

### Side Project for Fun

Check out my side project, TurboZoo:
- [GitHub](https://github.com/Kvnbbg/TurboZoo)
- [Replit](https://replit.com/@kvnbbg/TurboZoo)
- [First Version Video](https://www.youtube.com/watch?v=iS9uFwMw1SM)

---

## Contributors

[![GitHub contributors](https://contrib.rocks/image?repo=Kvnbbg/Vision-Week)](https://github.com/Kvnbbg/Vision-Week/graphs/contributors)

We appreciate all the contributors who have helped make this project better.
