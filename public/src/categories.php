<?php
require_once 'config.php';
session_start();

// Sample categories and videos for demonstration purposes
$categories = [
    'Nature' => [
        'Forest Exploration',
        'Ocean Depths',
        'Mountain Climbing'
    ],
    'Technology' => [
        'AI and Robotics',
        'Space Exploration',
        'Innovative Gadgets'
    ],
    'History' => [
        'Ancient Civilizations',
        'Historical Battles',
        'Archaeological Discoveries'
    ]
];

// Function to fetch categories and videos from the database (Placeholder function)
function fetchCategoriesAndVideos() {
    global $categories;
    // In a real scenario, you would fetch this data from the database
    return $categories;
}

$categoriesAndVideos = fetchCategoriesAndVideos();
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Catégories - Vision Week</title>
    <link rel="stylesheet" href="assets/styles.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>
    <?php if (file_exists('header.php')) include 'header.php'; ?>
    <?php if (file_exists('navigation.php')) include 'navigation.php'; ?>

    <main class="container">
        <h1>Catégories</h1>
        <div class="categories">
            <ul>
                <?php foreach ($categoriesAndVideos as $category => $videos): ?>
                    <li class="category-item" data-category="<?php echo htmlspecialchars($category); ?>">
                        <?php echo htmlspecialchars($category); ?>
                    </li>
                <?php endforeach; ?>
            </ul>
        </div>

        <div class="videos">
            <?php foreach ($categoriesAndVideos as $category => $videos): ?>
                <div class="video-list" id="<?php echo htmlspecialchars($category); ?>" style="display: none;">
                    <h2><?php echo htmlspecialchars($category); ?></h2>
                    <ul>
                        <?php foreach ($videos as $video): ?>
                            <li><?php echo htmlspecialchars($video); ?></li>
                        <?php endforeach; ?>
                    </ul>
                </div>
            <?php endforeach; ?>
        </div>
    </main>

    <?php if (file_exists('footer.php')) include 'footer.php'; ?>

    <script>
        $(document).ready(function() {
            $('.category-item').click(function() {
                var category = $(this).data('category');
                $('.video-list').hide();
                $('#' + category).show();
            });
        });
    </script>
</body>
</html>

<style>
/* Basic styles for the categories page */
body {
    font-family: Arial, sans-serif;
    background-color: #f4f4f4;
    margin: 0;
    padding: 0;
}

.container {
    max-width: 1200px;
    margin: 50px auto;
    padding: 20px;
    background: #fff;
    border-radius: 8px;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
}

h1 {
    text-align: center;
    color: #333;
}

.categories ul {
    list-style: none;
    padding: 0;
    display: flex;
    justify-content: center;
    gap: 20px;
}

.categories li {
    background-color: #007bff;
    color: #fff;
    padding: 10px 20px;
    border-radius: 4px;
    cursor: pointer;
    transition: background-color 0.3s;
}

.categories li:hover {
    background-color: #0056b3;
}

.videos {
    margin-top: 30px;
}

.video-list h2 {
    text-align: center;
    color: #007bff;
}

.video-list ul {
    list-style: none;
    padding: 0;
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.video-list li {
    background-color: #f8f9fa;
    padding: 10px;
    border: 1px solid #e9ecef;
    border-radius: 4px;
}
</style>
