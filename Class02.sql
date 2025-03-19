-- Create a new database called imdb
DROP DATABASE IF EXISTS imdb;

CREATE DATABASE IF NOT EXISTS imdb;

USE imdb;

-- Create tables: film (film_id, title, description, release_year); actor (actor_id, first_name, last_name) , film_actor (actor_id, film_id)
-- Use autoincrement id, Create PKs
CREATE TABLE actor (
	actor_id INT AUTO_INCREMENT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (actor_id) 
);

CREATE TABLE film (
    film_id INT NOT NULL AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    description TEXT DEFAULT NULL,
    release_year YEAR,
    PRIMARY KEY (film_id)
);

CREATE TABLE film_actor (
	actor_id INT,
    film_id INT,
    PRIMARY KEY (actor_id, film_id),
    CONSTRAINT fk_film_actor_actor FOREIGN KEY (actor_id) REFERENCES actor(actor_id) ON DELETE CASCADE
);

-- Alter table add column last_update to film and actor
ALTER TABLE film
ADD last_update DATETIME;

ALTER TABLE actor
ADD last_update DATETIME;

-- Alter table add foreign keys to film_actor table
ALTER TABLE film_actor ADD
CONSTRAINT fk_film_actor_film FOREIGN KEY (film_id) REFERENCES film (film_id) ON DELETE CASCADE;

-- Insert some actors, films and who acted in each film
INSERT INTO actor (first_name, last_name) VALUES
('Ricardo', 'Darín'),
('Guillermo', 'Francella'),
('Leonardo', 'Sbaraglia'),
('Mercedes', 'Morán'),
('Peter', 'Lanzani');

INSERT INTO film (title, description, release_year) VALUES
('El Secreto de Sus Ojos', 'Un exagente judicial busca resolver un caso sin resolver.', 2009),
('El Clan', 'Historia basada en la familia Puccio que secuestraba personas.', 2015),
('Nueve Reinas', 'Dos estafadores se cruzan con un negocio millonario.', 2000),
('Relatos Salvajes', 'Seis historias sobre la violencia cotidiana.', 2014),
('El Robo del Siglo', 'El famoso robo al Banco Río en Acassuso.', 2020);

INSERT INTO film_actor (actor_id, film_id) VALUES
(1, 1),
(1, 3),
(2, 4),
(3, 2),
(4, 4),
(5, 5);

