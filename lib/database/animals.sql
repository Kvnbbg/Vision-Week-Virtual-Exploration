CREATE TABLE animals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    species VARCHAR(255) NOT NULL,
    saved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO animals (name, species) VALUES ('Polar Bear', 'Ursus maritimus');
INSERT INTO animals (name, species) VALUES ('Lion', 'Panthera leo');
