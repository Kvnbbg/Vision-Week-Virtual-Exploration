# Vision Week 🚀
![Logo](logo.png)


[![GitHub contributors](https://img.shields.io/github/contributors/Kvnbbg/Vision-Week-Virtual-Exploration)](https://github.com/Kvnbbg/Vision-Week-Virtual-Exploration/graphs/contributors)
[![GitHub issues](https://img.shields.io/github/issues/Kvnbbg/Vision-Week-Virtual-Exploration)](https://github.com/Kvnbbg/Vision-Week-Virtual-Exploration/issues)
[![GitHub forks](https://img.shields.io/github/forks/Kvnbbg/Vision-Week-Virtual-Exploration)](https://github.com/Kvnbbg/Vision-Week-Virtual-Exploration/network)
[![GitHub stars](https://img.shields.io/github/stars/Kvnbbg/Vision-Week-Virtual-Exploration)](https://github.com/Kvnbbg/Vision-Week-Virtual-Exploration/stargazers)
[![GitHub license](https://img.shields.io/github/license/Kvnbbg/Vision-Week-Virtual-Exploration)](https://github.com/Kvnbbg/Vision-Week-Virtual-Exploration/blob/main/LICENSE)

Vision Week is a web and mobile application that offers a unique virtual zoo experience using VR headsets. Users can explore various paths and access video content at each point of interest on the zoo map. The content is accessible via a monthly subscription purchased within the app.

## Table of Contents
- [About](#about)
- [Preview](#preview)
- [Features](#features)
- [Technologies](#technologies)
- [Installation](#installation)
- [Code Snippet](#code-snippet)
- [Contributing](#contributing)
- [Future Development](#future-development)
- [Sponsor](#sponsor)
- [Acknowledgements](#acknowledgements)
- [Learn More](#learn-more)
- [Useful Links](#useful-links)
- [Side Project for Fun](#side-project-for-fun)
- [Contributors](#contributors)

## About

Vision Week is an innovative project that began on March 1, 2024, and will run until July 1, 2024. It immerses users in virtual reality, inspired by Tim Cook's Apple Vision Pro and Mark Zuckerberg's Meta platforms. The project showcases the combination of virtual exploration and real-world interactions.

[Onboarding](https://trello.com/invite/b/d0s3w1dC/ATTI06fd9d3a996d76b6a64f03d769128607E026F6C8/kvnbbg-vision-week-virtual-explorat)

## Preview

👁️ [Watch the preview of Vision Week](https://kvnbbg.github.io/Vision-Week-Virtual-Exploration/)  
If it doesn't work, try [this link](https://vision-week-ceb57a1e5fed.herokuapp.com/)

## Features

- **Explore by Category:** Discover videos organized by exploration type.
- **Search Functionality:** Find specific videos using keywords or location.
- **Detailed Information:** Learn more about each exploration with descriptions and source links.
- **Interactive Games:** Engage with fun and educational games.
- **Latest News Updates:** Stay informed with the most recent articles and news updates.
- **User Data Management:** Manage and view user data efficiently.
- **Zoo Information:** Explore detailed information about various animals and their habitats.
- **Access Logs:** Keep track of data access logs for transparency and security.
- **Future Interactive Experience:** Plan to add user comments and ratings.

## Technologies

- **Frontend:** Dart (Flutter)
- **Backend:** PHP (API development)
- **Database:** Relational database

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Kvnbbg/Vision-Week-Virtual-Exploration.git
   cd Vision-Week-Virtual-Exploration
   ```

2. **Run the Application:**
   - For web: 
     ```bash
     flutter run -d chrome
     ```
   - For Android/iOS: 
     ```bash
     flutter build apk
     flutter build ios
     ```

## Code Snippet

Here's a glimpse of the code that powers Vision Week:

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
    <script src="assets/script.js"></script>
</body>
</html>
```

## Contributing

We welcome contributions to improve this project! Feel free to fork the repository and submit pull requests with your enhancements.

Read our [CONTRIBUTING](CONTRIBUTING.md) guidelines for more details.

## Future Development

- **Video Platform Integration:** Integrate with platforms like YouTube or Vimeo.
- **User Interactions:** Implement user comments and ratings.
- **Educational Resources:** Add resources related to different exploration fields.
- **Backend Development:** Develop a backend to manage video data and user interactions.

## Sponsor

Your sponsorship helps cover expenses such as hosting fees, domain registration, and development tools, allowing us to continue improving and expanding Vision Week for the community.

Read more about [SPONSORING](SPONSORING.md) Vision Week.

Thank you for your support!

## Acknowledgements

This project was created by Kevin MARVILLE for STUDI. Special thanks to [STUDI](https://studi.com) for their support and inspiration.

## Learn More

For more information, visit [kvnbbg.fr](https://kvnbbg.fr).

## Side Project for Fun

Check out my side project, TurboZoo:
- [GitHub](https://github.com/Kvnbbg/TurboZoo)
- [Replit](https://replit.com/@kvnbbg/TurboZoo)
- [First Version Video](https://www.youtube.com/watch?v=iS9uFwMw1SM)

## Contributors

[![GitHub contributors](https://contrib.rocks/image?repo=Kvnbbg/Vision-Week-Virtual-Exploration)](https://github.com/Kvnbbg/Vision-Week-Virtual-Exploration/graphs/contributors)

We appreciate all the contributors who have helped make this project better.

## Links

- [Discussion](https://github.com/Kvnbbg/Vision-Week-Virtual-Exploration/discussions)
- [GitHub Repository](https://github.com/Kvnbbg/Vision-Week-Virtual-Exploration)
- [Replit](https://replit.com/@kvnbbg/TurboZoo)
- [Heroku Deployment](https://vision-week-ceb57a1e5fed.herokuapp.com/)
- [Discord](https://discord.com/invite/wppHraKvQF)
- [Insight](https://github.com/Kvnbbg/Vision-Week-Virtual-Exploration/settings/access)