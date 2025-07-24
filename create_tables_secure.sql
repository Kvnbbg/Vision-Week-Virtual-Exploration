-- create_tables_secure.sql
-- Version sécurisée du schéma de base de données
-- Developer: Kevin M. https://github.com/kvnbbg
-- Updated: 2025-07-24

-- Table des utilisateurs avec sécurité renforcée
CREATE TABLE utilisateurs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) UNIQUE NOT NULL DEFAULT (UUID()),
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    email_verifie BOOLEAN DEFAULT FALSE,
    mot_de_passe_hash VARCHAR(255) NOT NULL, -- Stockage du hash bcrypt
    salt VARCHAR(32) NOT NULL, -- Salt unique pour chaque utilisateur
    avatar VARCHAR(255),
    sexe ENUM('Homme', 'Femme', 'Autre', 'Non_specifie') DEFAULT 'Non_specifie',
    date_de_naissance DATE NOT NULL,
    date_inscription TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    derniere_connexion TIMESTAMP NULL,
    statut ENUM('actif', 'suspendu', 'supprime') DEFAULT 'actif',
    tentatives_connexion_echouees INT DEFAULT 0,
    compte_verrouille_jusqu TIMESTAMP NULL,
    token_verification_email VARCHAR(255),
    token_reset_password VARCHAR(255),
    token_reset_expiration TIMESTAMP NULL,
    preferences_confidentialite JSON,
    consentement_rgpd BOOLEAN DEFAULT FALSE,
    date_consentement_rgpd TIMESTAMP NULL,
    
    -- Index pour les performances
    INDEX idx_email (email),
    INDEX idx_uuid (uuid),
    INDEX idx_statut (statut),
    INDEX idx_derniere_connexion (derniere_connexion),
    
    -- Contraintes de validation
    CONSTRAINT chk_email_format CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_nom_length CHECK (CHAR_LENGTH(nom) >= 2),
    CONSTRAINT chk_prenom_length CHECK (CHAR_LENGTH(prenom) >= 2),
    CONSTRAINT chk_date_naissance CHECK (date_de_naissance <= CURDATE() - INTERVAL 13 YEAR)
);

-- Table des abonnements avec gestion des paiements
CREATE TABLE abonnements (
    id INT PRIMARY KEY AUTO_INCREMENT,
    utilisateur_id INT NOT NULL,
    type_abonnement ENUM('mensuel', 'annuel', 'essai_gratuit') NOT NULL,
    statut ENUM('actif', 'suspendu', 'expire', 'annule') DEFAULT 'actif',
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    prix DECIMAL(10, 2) NOT NULL,
    devise VARCHAR(3) DEFAULT 'EUR',
    methode_paiement ENUM('carte_credit', 'paypal', 'virement', 'autre'),
    transaction_id VARCHAR(255),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
    
    -- Index pour les performances
    INDEX idx_utilisateur_statut (utilisateur_id, statut),
    INDEX idx_date_fin (date_fin),
    INDEX idx_transaction (transaction_id),
    
    -- Contraintes de validation
    CONSTRAINT chk_prix_positif CHECK (prix >= 0),
    CONSTRAINT chk_dates_coherentes CHECK (date_fin > date_debut)
);

-- Table des parcours avec métadonnées enrichies
CREATE TABLE parcours (
    id INT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) UNIQUE NOT NULL DEFAULT (UUID()),
    nom VARCHAR(100) NOT NULL,
    description TEXT,
    difficulte ENUM('facile', 'moyen', 'difficile') DEFAULT 'moyen',
    duree_estimee INT, -- en minutes
    age_minimum INT DEFAULT 13,
    categorie VARCHAR(50),
    tags JSON, -- Tags pour la recherche
    image_couverture VARCHAR(255),
    statut ENUM('brouillon', 'publie', 'archive') DEFAULT 'brouillon',
    createur_id INT,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    nombre_vues INT DEFAULT 0,
    note_moyenne DECIMAL(3,2) DEFAULT 0.00,
    nombre_evaluations INT DEFAULT 0,
    
    FOREIGN KEY (createur_id) REFERENCES utilisateurs(id) ON DELETE SET NULL,
    
    -- Index pour les performances
    INDEX idx_statut_categorie (statut, categorie),
    INDEX idx_difficulte (difficulte),
    INDEX idx_note (note_moyenne),
    INDEX idx_uuid (uuid),
    
    -- Contraintes de validation
    CONSTRAINT chk_duree_positive CHECK (duree_estimee > 0),
    CONSTRAINT chk_age_minimum CHECK (age_minimum >= 0 AND age_minimum <= 100),
    CONSTRAINT chk_note_valide CHECK (note_moyenne >= 0 AND note_moyenne <= 5)
);

-- Table des points d'intérêt avec géolocalisation sécurisée
CREATE TABLE points_interet (
    id INT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) UNIQUE NOT NULL DEFAULT (UUID()),
    nom VARCHAR(100) NOT NULL,
    description TEXT,
    latitude DECIMAL(10, 8), -- Précision GPS améliorée
    longitude DECIMAL(11, 8),
    altitude DECIMAL(8, 2), -- Altitude en mètres
    type_point ENUM('animal', 'habitat', 'information', 'jeu', 'autre') DEFAULT 'autre',
    video_url VARCHAR(500), -- URL plus longue pour les CDN
    video_duree INT, -- Durée en secondes
    image_url VARCHAR(500),
    audio_url VARCHAR(500),
    contenu_ar JSON, -- Contenu de réalité augmentée
    accessibilite JSON, -- Informations d'accessibilité
    langues_disponibles JSON, -- Langues supportées
    statut ENUM('actif', 'maintenance', 'desactive') DEFAULT 'actif',
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Index géospatiaux pour les requêtes de proximité
    SPATIAL INDEX idx_coordonnees (POINT(longitude, latitude)),
    INDEX idx_type_statut (type_point, statut),
    INDEX idx_uuid (uuid),
    
    -- Contraintes de validation géographique
    CONSTRAINT chk_latitude CHECK (latitude >= -90 AND latitude <= 90),
    CONSTRAINT chk_longitude CHECK (longitude >= -180 AND longitude <= 180),
    CONSTRAINT chk_video_duree CHECK (video_duree > 0)
);

-- Table de liaison parcours-points d'intérêt avec ordre
CREATE TABLE parcours_points_interet (
    id INT PRIMARY KEY AUTO_INCREMENT,
    parcours_id INT NOT NULL,
    point_interet_id INT NOT NULL,
    ordre_dans_parcours INT NOT NULL,
    obligatoire BOOLEAN DEFAULT TRUE,
    temps_estime_visite INT, -- en minutes
    instructions_specifiques TEXT,
    
    FOREIGN KEY (parcours_id) REFERENCES parcours(id) ON DELETE CASCADE,
    FOREIGN KEY (point_interet_id) REFERENCES points_interet(id) ON DELETE CASCADE,
    
    -- Contrainte d'unicité pour éviter les doublons
    UNIQUE KEY unique_parcours_point (parcours_id, point_interet_id),
    UNIQUE KEY unique_parcours_ordre (parcours_id, ordre_dans_parcours),
    
    -- Index pour les performances
    INDEX idx_parcours_ordre (parcours_id, ordre_dans_parcours),
    
    -- Contraintes de validation
    CONSTRAINT chk_ordre_positif CHECK (ordre_dans_parcours > 0),
    CONSTRAINT chk_temps_visite_positif CHECK (temps_estime_visite > 0)
);

-- Table des commentaires avec modération
CREATE TABLE commentaires (
    id INT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) UNIQUE NOT NULL DEFAULT (UUID()),
    utilisateur_id INT NOT NULL,
    parcours_id INT,
    point_interet_id INT,
    commentaire_parent_id INT, -- Pour les réponses
    contenu TEXT NOT NULL,
    note INT, -- Note de 1 à 5
    statut_moderation ENUM('en_attente', 'approuve', 'rejete', 'signale') DEFAULT 'en_attente',
    raison_rejet TEXT,
    langue VARCHAR(5) DEFAULT 'fr',
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    nombre_likes INT DEFAULT 0,
    nombre_signalements INT DEFAULT 0,
    
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
    FOREIGN KEY (parcours_id) REFERENCES parcours(id) ON DELETE CASCADE,
    FOREIGN KEY (point_interet_id) REFERENCES points_interet(id) ON DELETE CASCADE,
    FOREIGN KEY (commentaire_parent_id) REFERENCES commentaires(id) ON DELETE CASCADE,
    
    -- Index pour les performances
    INDEX idx_parcours_statut (parcours_id, statut_moderation),
    INDEX idx_point_statut (point_interet_id, statut_moderation),
    INDEX idx_utilisateur_date (utilisateur_id, date_creation),
    INDEX idx_uuid (uuid),
    
    -- Contraintes de validation
    CONSTRAINT chk_note_valide CHECK (note >= 1 AND note <= 5),
    CONSTRAINT chk_contenu_non_vide CHECK (CHAR_LENGTH(TRIM(contenu)) > 0),
    CONSTRAINT chk_cible_commentaire CHECK (
        (parcours_id IS NOT NULL AND point_interet_id IS NULL) OR
        (parcours_id IS NULL AND point_interet_id IS NOT NULL)
    )
);

-- Table des vidéos avec métadonnées enrichies
CREATE TABLE videos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) UNIQUE NOT NULL DEFAULT (UUID()),
    titre VARCHAR(200) NOT NULL,
    description TEXT,
    url VARCHAR(500) NOT NULL,
    url_miniature VARCHAR(500),
    duree INT NOT NULL, -- en secondes
    resolution VARCHAR(20), -- ex: "1920x1080"
    format_video VARCHAR(10), -- ex: "mp4", "webm"
    taille_fichier BIGINT, -- en octets
    point_interet_id INT,
    langue VARCHAR(5) DEFAULT 'fr',
    sous_titres_disponibles JSON, -- Langues des sous-titres
    qualites_disponibles JSON, -- Différentes qualités (480p, 720p, 1080p)
    statut ENUM('actif', 'traitement', 'erreur', 'archive') DEFAULT 'traitement',
    date_upload TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    nombre_vues INT DEFAULT 0,
    
    FOREIGN KEY (point_interet_id) REFERENCES points_interet(id) ON DELETE SET NULL,
    
    -- Index pour les performances
    INDEX idx_point_statut (point_interet_id, statut),
    INDEX idx_langue (langue),
    INDEX idx_uuid (uuid),
    
    -- Contraintes de validation
    CONSTRAINT chk_duree_positive CHECK (duree > 0),
    CONSTRAINT chk_taille_positive CHECK (taille_fichier > 0),
    CONSTRAINT chk_url_non_vide CHECK (CHAR_LENGTH(TRIM(url)) > 0)
);

-- Table des tentatives de connexion pour la sécurité
CREATE TABLE tentatives_connexion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100),
    adresse_ip VARCHAR(45), -- Support IPv6
    user_agent TEXT,
    statut ENUM('succes', 'echec', 'compte_verrouille', 'email_invalide') NOT NULL,
    raison_echec VARCHAR(100),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    pays VARCHAR(2), -- Code pays ISO
    ville VARCHAR(100),
    
    -- Index pour les analyses de sécurité
    INDEX idx_email_timestamp (email, timestamp),
    INDEX idx_ip_timestamp (adresse_ip, timestamp),
    INDEX idx_statut_timestamp (statut, timestamp)
);

-- Table des sessions utilisateur
CREATE TABLE sessions_utilisateur (
    id INT PRIMARY KEY AUTO_INCREMENT,
    utilisateur_id INT NOT NULL,
    token_session VARCHAR(255) UNIQUE NOT NULL,
    adresse_ip VARCHAR(45),
    user_agent TEXT,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_expiration TIMESTAMP NOT NULL,
    derniere_activite TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    statut ENUM('actif', 'expire', 'revoque') DEFAULT 'actif',
    
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
    
    -- Index pour les performances
    INDEX idx_token (token_session),
    INDEX idx_utilisateur_statut (utilisateur_id, statut),
    INDEX idx_expiration (date_expiration),
    
    -- Contrainte de validation
    CONSTRAINT chk_expiration_future CHECK (date_expiration > date_creation)
);

-- Table des logs d'audit
CREATE TABLE logs_audit (
    id INT PRIMARY KEY AUTO_INCREMENT,
    utilisateur_id INT,
    action VARCHAR(100) NOT NULL,
    table_affectee VARCHAR(50),
    enregistrement_id INT,
    anciennes_valeurs JSON,
    nouvelles_valeurs JSON,
    adresse_ip VARCHAR(45),
    user_agent TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE SET NULL,
    
    -- Index pour les requêtes d'audit
    INDEX idx_utilisateur_timestamp (utilisateur_id, timestamp),
    INDEX idx_action_timestamp (action, timestamp),
    INDEX idx_table_timestamp (table_affectee, timestamp)
);

-- Table des préférences utilisateur
CREATE TABLE preferences_utilisateur (
    id INT PRIMARY KEY AUTO_INCREMENT,
    utilisateur_id INT UNIQUE NOT NULL,
    theme ENUM('clair', 'sombre', 'auto') DEFAULT 'auto',
    langue VARCHAR(5) DEFAULT 'fr',
    notifications_email BOOLEAN DEFAULT TRUE,
    notifications_push BOOLEAN DEFAULT TRUE,
    partage_donnees_analytiques BOOLEAN DEFAULT FALSE,
    qualite_video_preferee VARCHAR(10) DEFAULT 'auto',
    sous_titres_actives BOOLEAN DEFAULT FALSE,
    langue_sous_titres VARCHAR(5) DEFAULT 'fr',
    volume_audio INT DEFAULT 50,
    preferences_accessibilite JSON,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
    
    -- Contraintes de validation
    CONSTRAINT chk_volume_valide CHECK (volume_audio >= 0 AND volume_audio <= 100)
);

-- Triggers pour la sécurité et l'audit

-- Trigger pour hasher les mots de passe (exemple conceptuel)
DELIMITER //
CREATE TRIGGER before_user_insert 
BEFORE INSERT ON utilisateurs
FOR EACH ROW
BEGIN
    -- Générer un salt unique
    SET NEW.salt = SUBSTRING(MD5(RAND()), 1, 32);
    -- Le hachage sera fait côté application avec bcrypt
END//
DELIMITER ;

-- Trigger pour l'audit des modifications
DELIMITER //
CREATE TRIGGER after_user_update 
AFTER UPDATE ON utilisateurs
FOR EACH ROW
BEGIN
    INSERT INTO logs_audit (
        utilisateur_id, action, table_affectee, enregistrement_id,
        anciennes_valeurs, nouvelles_valeurs, timestamp
    ) VALUES (
        NEW.id, 'UPDATE', 'utilisateurs', NEW.id,
        JSON_OBJECT('email', OLD.email, 'nom', OLD.nom, 'prenom', OLD.prenom),
        JSON_OBJECT('email', NEW.email, 'nom', NEW.nom, 'prenom', NEW.prenom),
        NOW()
    );
END//
DELIMITER ;

-- Vues pour les requêtes fréquentes

-- Vue des utilisateurs actifs avec leurs abonnements
CREATE VIEW vue_utilisateurs_actifs AS
SELECT 
    u.id,
    u.uuid,
    u.nom,
    u.prenom,
    u.email,
    u.date_inscription,
    u.derniere_connexion,
    a.type_abonnement,
    a.statut as statut_abonnement,
    a.date_fin as fin_abonnement
FROM utilisateurs u
LEFT JOIN abonnements a ON u.id = a.utilisateur_id 
    AND a.statut = 'actif' 
    AND a.date_fin > CURDATE()
WHERE u.statut = 'actif';

-- Vue des parcours populaires
CREATE VIEW vue_parcours_populaires AS
SELECT 
    p.id,
    p.uuid,
    p.nom,
    p.description,
    p.categorie,
    p.difficulte,
    p.duree_estimee,
    p.nombre_vues,
    p.note_moyenne,
    p.nombre_evaluations,
    COUNT(ppi.point_interet_id) as nombre_points_interet
FROM parcours p
LEFT JOIN parcours_points_interet ppi ON p.id = ppi.parcours_id
WHERE p.statut = 'publie'
GROUP BY p.id
ORDER BY p.nombre_vues DESC, p.note_moyenne DESC;

-- Procédures stockées pour les opérations courantes

-- Procédure pour nettoyer les sessions expirées
DELIMITER //
CREATE PROCEDURE nettoyer_sessions_expirees()
BEGIN
    UPDATE sessions_utilisateur 
    SET statut = 'expire' 
    WHERE date_expiration < NOW() AND statut = 'actif';
    
    DELETE FROM sessions_utilisateur 
    WHERE statut = 'expire' AND date_expiration < DATE_SUB(NOW(), INTERVAL 30 DAY);
END//
DELIMITER ;

-- Procédure pour calculer les statistiques d'un parcours
DELIMITER //
CREATE PROCEDURE calculer_stats_parcours(IN parcours_id INT)
BEGIN
    DECLARE note_moy DECIMAL(3,2);
    DECLARE nb_eval INT;
    
    SELECT AVG(note), COUNT(*) 
    INTO note_moy, nb_eval
    FROM commentaires 
    WHERE parcours_id = parcours_id 
      AND note IS NOT NULL 
      AND statut_moderation = 'approuve';
    
    UPDATE parcours 
    SET note_moyenne = COALESCE(note_moy, 0),
        nombre_evaluations = nb_eval
    WHERE id = parcours_id;
END//
DELIMITER ;

-- Index composites pour les requêtes complexes
CREATE INDEX idx_commentaires_moderation_date ON commentaires(statut_moderation, date_creation);
CREATE INDEX idx_videos_point_statut_langue ON videos(point_interet_id, statut, langue);
CREATE INDEX idx_abonnements_utilisateur_dates ON abonnements(utilisateur_id, date_debut, date_fin);

-- Configuration de la sécurité au niveau base de données
-- Ces commandes doivent être exécutées par un administrateur

-- Créer un utilisateur applicatif avec privilèges limités
-- CREATE USER 'vision_week_app'@'%' IDENTIFIED BY 'mot_de_passe_fort_genere';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON vision_week_db.* TO 'vision_week_app'@'%';
-- GRANT EXECUTE ON PROCEDURE vision_week_db.nettoyer_sessions_expirees TO 'vision_week_app'@'%';
-- GRANT EXECUTE ON PROCEDURE vision_week_db.calculer_stats_parcours TO 'vision_week_app'@'%';

-- Activer les logs binaires pour la réplication
-- SET GLOBAL log_bin_trust_function_creators = 1;

-- Configuration SSL (à adapter selon l'environnement)
-- REQUIRE SSL pour les connexions externes

