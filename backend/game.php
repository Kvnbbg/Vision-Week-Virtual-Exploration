<?php
require_once 'config.php';
session_start();

// Sanitize user input
function sanitize_input($data) {
    return htmlspecialchars(stripslashes(trim($data)));
}

// Generate random positions for objects
function get_random_position($max_width, $max_height) {
    return [
        'x' => rand(0, $max_width - 50), // Subtract object width to keep within bounds
        'y' => rand(0, $max_height - 50) // Subtract object height to keep within bounds
    ];
}

// Define a list of objects/cards with initial positions
$objects = [];
$max_objects = 5;
$box_width = 800;
$box_height = 600;

for ($i = 0; $i < $max_objects; $i++) {
    $objects[] = get_random_position($box_width, $box_height);
}

// Handle form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name = sanitize_input($_POST['name']);
    $email = sanitize_input($_POST['email']);
    $message = sanitize_input($_POST['message']);

    if (!empty($name) && !empty($email) && !empty($message)) {
        $successMessage = 'Merci pour votre message. Nous vous répondrons bientôt.';
        // Handle the form submission, e.g., save to the database or send an email
    } else {
        $errorMessage = 'Veuillez remplir tous les champs.';
    }
}

// Record game data
function record_game_data($data) {
    $file = 'game_data.json';
    if (file_exists($file)) {
        $current_data = json_decode(file_get_contents($file), true);
    } else {
        $current_data = [];
    }
    $current_data[] = $data;
    file_put_contents($file, json_encode($current_data));
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['game_data'])) {
    record_game_data(json_decode($_POST['game_data'], true));
    exit;
}
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Jeu - Vision Week</title>
    <link rel="stylesheet" href="assets/styles.css">
    <style>
        /* Basic styles for the game */
        .game-box {
            position: relative;
            width: 800px;
            height: 600px;
            background-color: #f0f0f0;
            margin: 50px auto;
            border: 1px solid #ccc;
            overflow: hidden;
        }
        .object {
            position: absolute;
            width: 50px;
            height: 50px;
            background-color: #007bff;
            border-radius: 50%;
            cursor: pointer;
            transition: transform 0.3s;
        }
        .object.clicked {
            background-color: #28a745;
        }
        .interaction-log {
            max-width: 800px;
            margin: 20px auto;
            padding: 10px;
            background-color: #fff;
            border: 1px solid #ccc;
        }
        .score {
            text-align: center;
            font-size: 24px;
            margin-top: 20px;
        }
        .game-link {
            display: block;
            text-align: center;
            margin: 20px 0;
            padding: 10px 20px;
            background-color: #007bff;
            color: #fff;
            text-decoration: none;
            border-radius: 4px;
            transition: background-color 0.3s;
        }
        .game-link:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
    <?php if (file_exists('header.php')) include 'header.php'; ?>
    <?php if (file_exists('navigation.php')) include 'navigation.php'; ?>

    <main class="container">
        <h1>Jeu d'Interaction des Objets</h1>
        <div class="score">Score: <span id="score">0</span></div>
        <div class="game-box" id="gameBox">
            <?php foreach ($objects as $index => $object): ?>
                <div class="object" id="object-<?php echo $index; ?>" style="left: <?php echo $object['x']; ?>px; top: <?php echo $object['y']; ?>px;"></div>
            <?php endforeach; ?>
        </div>
        <div class="interaction-log" id="interactionLog">
            <h2>Interactions</h2>
            <p id="interactionMessage">Cliquez sur les objets qui bougent pour marquer des points!</p>
        </div>
        <a href="game2.php" class="game-link">Jouer à Jeu II</a>
    </main>

    <?php if (file_exists('footer.php')) include 'footer.php'; ?>

    <script>
        let score = 0;
        const scoreElement = document.getElementById('score');
        const gameBox = document.getElementById('gameBox');
        const objects = document.querySelectorAll('.object');
        const gameData = [];

        objects.forEach(object => {
            object.addEventListener('click', () => {
                if (!object.classList.contains('clicked')) {
                    score++;
                    scoreElement.innerText = score;
                    object.classList.add('clicked');
                    object.style.backgroundColor = '#28a745';
                }
            });

            setInterval(() => {
                if (!object.classList.contains('clicked')) {
                    const newX = Math.floor(Math.random() * (gameBox.clientWidth - 50));
                    const newY = Math.floor(Math.random() * (gameBox.clientHeight - 50));
                    object.style.left = newX + 'px';
                    object.style.top = newY + 'px';
                    gameData.push({ id: object.id, x: newX, y: newY });
                }
            }, 1000);
        });

        setTimeout(() => {
            alert('Le temps est écoulé! Votre score est ' + score);
            fetch('game.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ game_data: JSON.stringify(gameData) })
            }).then(() => window.location.reload());
        }, 30000); // 30 seconds timer
    </script>
</body>
</html>
