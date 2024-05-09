-- Insert the new animal into the Animals table
INSERT INTO Animals (name, type, country_id) VALUES ('Slim', 'Giraffe', 1);

-- Create a table to store the list of animals
CREATE TABLE Zoo (
    name VARCHAR(255),
    type VARCHAR(255),
    country VARCHAR(255)
);

-- Insert data into Zoo table using a SELECT statement
INSERT INTO Zoo (name, type, country)
SELECT Animals.name, Animals.type, Countries.country
FROM Animals
INNER JOIN Countries ON Animals.country_id = Countries.id
ORDER BY Countries.country;
SELECT * FROM Zoo