<?php
// DEPRECATION NOTE: This login system is part of a traditional PHP web page flow
// and uses a separate SQLite database. For the main Vision Week application (Flutter),
// Firebase Authentication is the recommended and primary authentication method.
// This script should be reviewed for its current necessity or adapted if
// intended for a separate administrative web interface.

require_once 'config.php';
session_start();

$errorMessage = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = trim($_POST['username']);
    $password = trim($_POST['password']);

    if (empty($username) || empty($password)) {
        $errorMessage = 'Veuillez remplir tous les champs.';
    } else {
        $db = getDatabaseConnection(USERS_DB_FILE);

        if (!$db) {
            $errorMessage = 'Échec de la connexion à la base de données. Veuillez réessayer plus tard.';
        } else {
            $stmt = $db->prepare('SELECT * FROM Users WHERE username = :username LIMIT 1');
            $stmt->execute([':username' => $username]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($user && password_verify($password, $user['password'])) {
                $_SESSION['user'] = [
                    'id' => $user['id'],
                    'username' => $user['username'],
                ];
                header('Location: index.php');
                exit;
            } else {
                $errorMessage = 'Nom d’utilisateur ou mot de passe incorrect.';
            }
        }
    }
}
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Connexion - Vision Week</title>
    <link rel="stylesheet" href="assets/styles.css">
</head>
<body>
    <?php if (file_exists('header.php')) include 'header.php'; ?>
    <?php if (file_exists('navigation.php')) include 'navigation.php'; ?>

    <main class="container">
        <h1>Connexion</h1>

        <?php if ($errorMessage): ?>
            <p class="error"><?php echo htmlspecialchars($errorMessage); ?></p>
        <?php endif; ?>

        <form action="login.php" method="post">
            <div class="form-group">
                <label for="username">Nom d'utilisateur:</label>
                <input type="text" id="username" name="username" value="<?php echo isset($username) ? htmlspecialchars($username) : ''; ?>">
            </div>
            <div class="form-group">
                <label for="password">Mot de passe:</label>
                <input type="password" id="password" name="password">
            </div>
            <div class="form-group">
                <button type="submit">Se connecter</button>
            </div>
        </form>
        <p>Pas encore inscrit? <a href="register.php">Créer un compte</a></p>
    </main>

    <?php if (file_exists('footer.php')) include 'footer.php'; ?>
</body>
</html>

<style>
/* Basic styles for the login page */
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
