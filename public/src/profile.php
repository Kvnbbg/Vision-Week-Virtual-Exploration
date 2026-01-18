<?php
require_once 'config.php';
session_start();

// Redirect to login page if the user is not logged in
if (!isset($_SESSION['user'])) {
    header('Location: login.php');
    exit;
}

$db = getDatabaseConnection(USERS_DB_FILE);
$errorMessage = '';
$successMessage = '';

if (!$db) {
    $errorMessage = 'Échec de la connexion à la base de données. Veuillez réessayer plus tard.';
    $user = [
        'username' => $_SESSION['user']['username'] ?? '',
        'email' => '',
    ];
} else {
    // Fetch user details from the database
    $userId = $_SESSION['user']['id'];
    $stmt = $db->prepare('SELECT * FROM Users WHERE id = :id');
    $stmt->execute([':id' => $userId]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$user) {
        $errorMessage = 'Impossible de récupérer votre profil. Veuillez vous reconnecter.';
        $user = [
            'username' => $_SESSION['user']['username'] ?? '',
            'email' => '',
        ];
    }
}

// Handle form submission for updating user details
if ($_SERVER['REQUEST_METHOD'] === 'POST' && $db) {
    $username = trim($_POST['username']);
    $email = trim($_POST['email']);
    $password = trim($_POST['password']);
    $confirmPassword = trim($_POST['confirm_password']);

    if (empty($username) || empty($email)) {
        $errorMessage = 'Veuillez remplir tous les champs obligatoires.';
    } elseif (!empty($password) && $password !== $confirmPassword) {
        $errorMessage = 'Les mots de passe ne correspondent pas.';
    } else {
        try {
            $db->beginTransaction();

            $stmt = $db->prepare('UPDATE Users SET username = :username, email = :email WHERE id = :id');
            $stmt->execute([':username' => $username, ':email' => $email, ':id' => $userId]);

            if (!empty($password)) {
                $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
                $stmt = $db->prepare('UPDATE Users SET password = :password WHERE id = :id');
                $stmt->execute([':password' => $hashedPassword, ':id' => $userId]);
            }

            $db->commit();
            $successMessage = 'Profil mis à jour avec succès.';
            $_SESSION['user']['username'] = $username; // Update session username
        } catch (PDOException $e) {
            $db->rollBack();
            error_log($e->getMessage());
            $errorMessage = 'Une erreur est survenue. Veuillez réessayer plus tard.';
        }
    }
}
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profil - Vision Week</title>
    <link rel="stylesheet" href="assets/styles.css">
</head>
<body>
    <?php if (file_exists('header.php')) include 'header.php'; ?>
    <?php if (file_exists('navigation.php')) include 'navigation.php'; ?>

    <main class="container">
        <h1>Profil de <?php echo htmlspecialchars($_SESSION['user']['username']); ?></h1>

        <?php if ($errorMessage): ?>
            <p class="error"><?php echo htmlspecialchars($errorMessage); ?></p>
        <?php endif; ?>

        <?php if ($successMessage): ?>
            <p class="success"><?php echo htmlspecialchars($successMessage); ?></p>
        <?php endif; ?>

        <form action="profile.php" method="post">
            <div class="form-group">
                <label for="username">Nom d'utilisateur:</label>
                <input type="text" id="username" name="username" value="<?php echo htmlspecialchars($user['username']); ?>" required>
            </div>
            <div class="form-group">
                <label for="email">E-mail:</label>
                <input type="email" id="email" name="email" value="<?php echo htmlspecialchars($user['email']); ?>" required>
            </div>
            <div class="form-group">
                <label for="password">Nouveau mot de passe:</label>
                <input type="password" id="password" name="password">
            </div>
            <div class="form-group">
                <label for="confirm_password">Confirmez le nouveau mot de passe:</label>
                <input type="password" id="confirm_password" name="confirm_password">
            </div>
            <div class="form-group">
                <button type="submit">Mettre à jour</button>
            </div>
        </form>
    </main>

    <?php if (file_exists('footer.php')) include 'footer.php'; ?>
</body>
</html>

<style>
/* Basic styles for the profile page */
body {
    font-family: Arial, sans-serif;
    background-color: #f4f4f4;
    margin: 0;
    padding: 0;
}

.container {
    max-width: 600px;
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

.success {
    color: green;
    text-align: center;
    margin-bottom: 15px;
}

p {
    text-align: center;
    color: #555;
}
</style>
