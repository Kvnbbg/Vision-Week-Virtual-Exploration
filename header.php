<?php
// Start the session to check user authentication status
session_start();
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vision Week</title>
    <link rel="stylesheet" href="assets/styles.css">
</head>
<body>
    <header>
        <div class="container">
            <div class="logo">
                <!-- Vision Week Logo -->
                <a href="index.php">
                    <img src="assets/logo.png" alt="Vision Week Logo">
                </a>
            </div>
            <nav>
                <ul class="nav-links">
                    <li><a href="index.php">Home</a></li>
                    <li><a href="categories.php">Categories</a></li>
                    <li><a href="about.php">About</a></li>
                    <li><a href="contact.php">Contact</a></li>
                    <!-- Check if the user is logged in and display appropriate links -->
                    <?php if (isset($_SESSION['user'])): ?>
                        <li><a href="profile.php">Profile</a></li>
                        <li><a href="logout.php">Logout</a></li>
                    <?php else: ?>
                        <li><a href="login.php">Login</a></li>
                        <li><a href="register.php">Register</a></li>
                    <?php endif; ?>
                </ul>
            </nav>
        </div>
    </header>
</body>
</html>

<style>
/* Basic styles for the header */
header {
    background-color: #f8f9fa;
    padding: 20px 0;
    border-bottom: 1px solid #e9ecef;
}

.container {
    display: flex;
    justify-content: space-between;
    align-items: center;
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
}

.logo img {
    height: 50px;
}

nav {
    flex-grow: 1;
    text-align: right;
}

.nav-links {
    list-style: none;
    margin: 0;
    padding: 0;
    display: flex;
    justify-content: flex-end;
}

.nav-links li {
    margin-left: 20px;
}

.nav-links a {
    text-decoration: none;
    color: #343a40;
    font-weight: 500;
    transition: color 0.3s;
}

.nav-links a:hover {
    color: #007bff;
}
</style>
