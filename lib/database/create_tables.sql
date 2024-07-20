-- create_tables.sql
-- Developer:  Kevin M. https://github.com/kvnbbg

CREATE TABLE Utilisateur (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    mot_de_passe VARCHAR(255),
    avatar VARCHAR(255),
    sexe ENUM('Homme', 'Femme', 'Autre'),
    date_de_naissance DATE NOT NULL,
    date_inscription TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Abonnement (
    id INT PRIMARY KEY AUTO_INCREMENT,
    utilisateur_id INT,
    FOREIGN KEY (utilisateur_id) REFERENCES Utilisateur(id),
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    type ENUM('Abonnement mensuel', 'Abonnement annuel') NOT NULL,
    prix DECIMAL(10, 2) NOT NULL,
);

CREATE TABLE PointInteret (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL,
    description TEXT,
    latitude FLOAT,
    longitude FLOAT,
    video_url VARCHAR(255),
    image_url VARCHAR(255),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ParcoursPointInteret (
    id INT AUTO_INCREMENT PRIMARY KEY,
    parcours_id INT,
    point_interet_id INT,
    FOREIGN KEY (parcours_id) REFERENCES Parcours(id),
    FOREIGN KEY (point_interet_id) REFERENCES PointInteret(id)
);

CREATE TABLE Commentaire (
    id INT AUTO_INCREMENT PRIMARY KEY,
    utilisateur_id INT,
    parcours_id INT,
    contenu TEXT,
    commentaire TEXT,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (utilisateur_id) REFERENCES Utilisateur(id),
  FOREIGN KEY (parcours_id) REFERENCES Parcours(id)
);

CREATE TABLE Video (
  id INT AUTO_INCREMENT PRIMARY KEY,
  titre VARCHAR(100),
  url VARCHAR(255),
  point_interet_id INT,
  FOREIGN KEY (point_interet_id) REFERENCES PointInteret(id)
);

CREATE TABLE tentatives_connexion (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(100),
  status VARCHAR(50),
  timestamp DATETIME
);