<?php
/**
 * social.php
 * This file contains the social media links section, which can be included anywhere in your site.
 */

// Define your social media links
$socialLinks = [
    
    'twitter' => 'https://twitter.com/techandstream',
    'facebook' => 'https://www.facebook.com/techandstream',
    'instagram' => 'https://www.instagram.com/techandstream/',
    'linkedin' => 'https://www.linkedin.com/in/kevin-marville',
    'youtube' => 'https://www.youtube.com/user/techandstream'
];
?>

<div class="social-links">
    <ul>
        <?php foreach ($socialLinks as $platform => $url): ?>
            <li>
                <a href="<?php echo htmlspecialchars($url); ?>" target="_blank">
                    <img src="assets/icons/<?php echo $platform; ?>.png" alt="<?php echo ucfirst($platform); ?> Icon">
                </a>
            </li>
        <?php endforeach; ?>
    </ul>
</div>

<style>
/* Basic styles for the social links */
.social-links ul {
    list-style: none;
    margin: 0;
    padding: 0;
    display: flex;
    gap: 15px;
}

.social-links li {
    display: inline;
}

.social-links a {
    display: block;
    width: 40px;
    height: 40px;
    text-decoration: none;
}

.social-links img {
    width: 100%;
    height: auto;
    transition: transform 0.3s;
}

.social-links a:hover img {
    transform: scale(1.1);
}
</style>
