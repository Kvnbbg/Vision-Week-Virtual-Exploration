<?php
require_once 'config.php';
session_start();

// Load game data
$game_data = [];
if (file_exists('game_data.json')) {
    $game_data = json_decode(file_get_contents('game_data.json'), true);
}
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Visualisation 3D - Vision Week</title>
    <link rel="stylesheet" href="assets/styles.css">
    <style>
        /* Basic styles for the 3D visualization */
        body {
            margin: 0;
            overflow: hidden;
        }
        #container {
            width: 100vw;
            height: 100vh;
        }
    </style>
</head>
<body>
    <div id="container"></div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
    <script>
        // Initialize the Three.js scene
        const container = document.getElementById('container');
        const scene = new THREE.Scene();
        const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
        const renderer = new THREE.WebGLRenderer();
        renderer.setSize(window.innerWidth, window.innerHeight);
        container.appendChild(renderer.domElement);

        // Add a light source
        const light = new THREE.PointLight(0xffffff, 1, 100);
        light.position.set(50, 50, 50);
        scene.add(light);

        // Load game data
        const gameData = <?php echo json_encode($game_data); ?>;

        // Add objects to the scene based on game data
        const objects = [];
        gameData.forEach(dataPoint => {
            const geometry = new THREE.SphereGeometry(1, 32, 32);
            const material = new THREE.MeshBasicMaterial({ color: 0x007bff });
            const sphere = new THREE.Mesh(geometry, material);
            sphere.position.set(dataPoint.x / 50, dataPoint.y / 50, 0);
            objects.push(sphere);
            scene.add(sphere);
        });

        // Set camera position
        camera.position.z = 20;

        // Render loop
        function animate() {
            requestAnimationFrame(animate);

            // Rotate objects
            objects.forEach(obj => {
                obj.rotation.x += 0.01;
                obj.rotation.y += 0.01;
            });

            renderer.render(scene, camera);
        }

        animate();
    </script>
</body>
</html>
