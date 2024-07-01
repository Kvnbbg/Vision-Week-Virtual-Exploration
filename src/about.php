<?php
require_once 'config.php';
session_start();
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>À propos - Vision Week</title>
    <link rel="stylesheet" href="assets/styles.css">
</head>
<body>
    <?php if (file_exists('header.php')) include 'header.php'; ?>
    <?php if (file_exists('navigation.php')) include 'navigation.php'; ?>

    <main class="container">
        <h1>À propos de Vision Week</h1>
        <section class="about-section">
            <h2>Notre Mission</h2>
            <p>Vision Week est une application dédiée à la présentation d'une collection de vidéos d'exploration, offrant aux spectateurs la possibilité de se lancer virtuellement dans des aventures passionnantes. Que vous soyez passionné par la plongée sous-marine, l'exploration spatiale, l'archéologie ou la nature, Vision Week a quelque chose pour vous.</p>
        </section>
        <section class="about-section">
            <h2>Notre Histoire</h2>
            <p>Vision Week, anciennement connue sous le nom d'Exploration Video Website, a été créée pour apporter l'esprit d'exploration à portée de main. Notre équipe de passionnés a travaillé sans relâche pour rassembler les meilleures vidéos d'exploration et les rendre accessibles à tous.</p>
        </section>
        <section class="about-section">
            <h2>Notre Équipe</h2>
            <p>Ce projet a été créé par Kevin MARVILLE pour STUDI. Nous tenons à remercier particulièrement STUDI pour leur soutien et leur inspiration.</p>
        </section>
        <section class="about-section">
            <h2>Contactez-Nous</h2>
            <p>Pour toute question ou suggestion, n'hésitez pas à nous contacter à l'adresse suivante : <a href="mailto:contact@kvnbbg .fr">contact@kvnbbg.fr</a></p>
        </section>
    </main>

    <?php if (file_exists('footer.php')) include 'footer.php'; ?>
</body>
</html>

<style>
/* Basic styles for the about page */
body {
    font-family: Arial, sans-serif;
    background-color: #f4f4f4;
    margin: 0;
    padding: 0;
}

.container {
    max-width: 800px;
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

.about-section {
    margin-bottom: 30px;
}

.about-section h2 {
    color: #007bff;
}

.about-section p {
    color: #555;
    line-height: 1.6;
}

.about-section a {
    color: #007bff;
    text-decoration: none;
}

.about-section a:hover {
    text-decoration: underline;
}
</style>
