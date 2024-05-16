<?php
/**
 * footer.php
 * This file contains the footer section, which can be included at the bottom of each page.
 */
?>

<footer>
    <div class="container">
        <div class="footer-content">
            <div class="footer-logo">
                <a href="index.php">
                    <img src="assets/logo.png" alt="Vision Week Logo">
                </a>
            </div>
            <div class="footer-links">
                <ul>
                    <li><a href="index.php">Home</a></li>
                    <li><a href="categories.php">Categories</a></li>
                    <li><a href="about.php">About</a></li>
                    <li><a href="contact.php">Contact</a></li>
                    <li><a href="privacy.php">Privacy Policy</a></li>
                    <li><a href="terms.php">Terms of Service</a></li>
                </ul>
            </div>
            <div class="footer-social">
                <a href="socials.php"><img src="assets/icons/facebook.png" alt="Facebook"></a>
                <a href="socials.php"><img src="assets/icons/twitter.png" alt="Twitter"></a>
                <a href="socials.php"><img src="assets/icons/instagram.png" alt="Instagram"></a>
                <a href="socials.php"><img src="assets/icons/linkedin.png" alt="LinkedIn"></a>
            </div>
        </div>
        <div class="footer-bottom">
            <p>&copy; <?php echo date('Y'); ?> Vision Week. All rights reserved.</p>
        </div>
    </div>
</footer>

<style>
/* Basic styles for the footer */
footer {
    background-color: #343a40;
    color: #ffffff;
    padding: 20px 0;
    border-top: 1px solid #e9ecef;
}

.footer-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
}

.footer-logo img {
    height: 40px;
}

.footer-links ul {
    list-style: none;
    margin: 0;
    padding: 0;
    display: flex;
    gap: 15px;
}

.footer-links a {
    text-decoration: none;
    color: #ffffff;
    font-weight: 500;
    transition: color 0.3s;
}

.footer-links a:hover {
    color: #007bff;
}

.footer-social a {
    margin-left: 10px;
}

.footer-social img {
    height: 24px;
}

.footer-bottom {
    text-align: center;
    margin-top: 20px;
}
</style>
