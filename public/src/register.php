<?php
// DEPRECATION NOTE: This registration system is part of a traditional PHP web page flow
// and uses a separate SQLite database. For the main Vision Week application (Flutter),
// Firebase Authentication is the recommended and primary authentication method.
// This script should be reviewed for its current necessity or adapted if
// intended for a separate administrative web interface.

require_once 'config.php'; // Assumes config.php defines getDatabaseConnection() and USERS_DB_FILE for SQLite.
session_start();

$errorMessage = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = trim($_POST['username']);
    $password = trim($_POST['password']);
    $confirmPassword = trim($_POST['confirm_password']);
    $email = trim($_POST['email']);

    if (empty($username) || empty($password) || empty($confirmPassword) || empty($email)) {
        $errorMessage = 'Veuillez remplir tous les champs.';
    } elseif ($password !== $confirmPassword) {
        $errorMessage = 'Les mots de passe ne correspondent pas.';
    } else {
        $db = getDatabaseConnection(USERS_DB_FILE);
        if ($db) {
            $stmt = $db->prepare('SELECT * FROM Users WHERE username = :username OR email = :email');
            $stmt->execute([':username' => $username, ':email' => $email]);
            $existingUser = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($existingUser) {
                $errorMessage = 'Le nom d’utilisateur ou l’e-mail est déjà pris.';
            } else {
                $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
                $stmt = $db->prepare('INSERT INTO Users (username, password, email) VALUES (:username, :password, :email)');
                $stmt->execute([':username' => $username, ':password' => $hashedPassword, ':email' => $email]);
                header('Location: login.php');
                exit;
            }
        } else {
            $errorMessage = 'Échec de la connexion à la base de données. Veuillez réessayer plus tard.';
        }
    }
}
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inscription - Vision Week</title>
    <link rel="stylesheet" href="assets/styles.css">
</head>
<body>
    <?php if (file_exists('header.php')) include 'header.php'; ?>
    <?php if (file_exists('navigation.php')) include 'navigation.php'; ?>

    <main class="container">
        <h1>Inscription</h1>

        <?php if ($errorMessage): ?>
            <p class="error"><?php echo htmlspecialchars($errorMessage); ?></p>
        <?php endif; ?>

        <form action="register.php" method="post">
            <div class="form-group">
                <label for="username">Nom d'utilisateur:</label>
                <input type="text" id="username" name="username" value="<?php echo isset($username) ? htmlspecialchars($username) : ''; ?>">
            </div>
            <div class="form-group">
                <label for="email">E-mail:</label>
                <input type="email" id="email" name="email" value="<?php echo isset($email) ? htmlspecialchars($email) : ''; ?>">
            </div>
            <div class="form-group">
                <label for="password">Mot de passe:</label>
                <input type="password" id="password" name="password">
            </div>
            <div class="form-group">
                <label for="confirm_password">Confirmez le mot de passe:</label>
                <input type="password" id="confirm_password" name="confirm_password">
            </div>
            <div class="form-group">
                <button type="submit">S'inscrire</button>
            </div>
        </form>
        <p>Déjà inscrit? <a href="login.php">Se connecter</a></p>
    </main>

    <?php if (file_exists('footer.php')) include 'footer.php'; ?>
</body>
</html>

<style>
/* Basic styles for the registration page */
body {
    font-family: Arial, sans-serif;
    background-color: #f4f4f4;
    margin: 0;
    padding: 0;
}

.container {
    max-width: 500px;
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

.form-group {
    margin-bottom: 15px;
}

.form-group label {
    display: block;
    color: #555;
}

.form-group input {
    width: 100%;
    padding: 10px;
    border: 1px solid #ccc;
    border-radius: 4px;
}

.button {
    width: 100%;
    padding: 10px;
    background-color: #007bff;
    border: none;
    border-radius: 4px;
    color: #fff;
    font-size: 16px;
    cursor: pointer;
}

.button:hover {
    background-color: #0056b3;
}

.error {
    color: red;
    text-align: center;
    margin-bottom: 15px;
}

p {
    text-align: center;
    color: #555;
}

a {
    color: #007bff;
    text-decoration: none;
}

a:hover {
    text-decoration: underline;
}
</style>
