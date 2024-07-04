<?php
/**
 * navigation.php
 * This file contains the navigation bar section, which can be included at the top of each page.
 */
?>

<nav class="main-nav">
    <div class="container">
        <ul class="nav-links">
            <li><a href="index.php">Accueil</a></li>
            <li><a href="categories.php">Catégories</a></li>
            <li><a href="about.php">À propos</a></li>
            <li><a href="contact.php">Contact</a></li>
            <!-- User Authentication Links -->
            <?php if (isset($_SESSION['user'])): ?>
                <li><a href="profile.php">Profil</a></li>
                <li><a href="logout.php">Déconnexion</a></li>
            <?php else: ?>
                <li><a href="login.php">Connexion</a></li>
                <li><a href="register.php">Inscription</a></li>
            <?php endif; ?>
        </ul>
    </div>
</nav>

<style>
/* Basic styles for the navigation */
.main-nav {
    background-color: #343a40;
    padding: 10px 0;
}

.main-nav .container {
    display: flex;
    justify-content: center;
}

.nav-links {
    list-style: none;
    margin: 0;
    padding: 0;
    display: flex;
    gap: 20px;
}

.nav-links li {
    margin: 0;
}

.nav-links a {
    text-decoration: none;
    color: #ffffff;
    font-weight: 500;
    transition: color 0.3s;
}

.nav-links a:hover {
    color: #007bff;
}
</style>
