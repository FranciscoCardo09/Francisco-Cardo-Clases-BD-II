USE sakila;

-- 1) Create two or three queries using address table in sakila db:

-- include postal_code in where (try with in/not it operator). Eventually join the table with city/country tables. Measure execution time.

-- a) Query simple con IN
SELECT *
FROM address
WHERE postal_code IN ('42399','93896');

-- b) Query con JOIN y NOT IN
SELECT a.address_id, a.postal_code, c.city, co.country
FROM address a
JOIN city c ON a.city_id = c.city_id
JOIN country co ON c.country_id = co.country_id
WHERE a.postal_code NOT IN ('42399','93896');

-- c) Ver tiempos de ejecución
SHOW PROFILES;

-- 12:35:58	SHOW PROFILES	0 row(s) returned	0.00036 sec / 0.0000091 sec -> 0.00036 sec

-- Then create an index for postal_code on address table. Measure execution time again and compare with the previous ones.
-- Explain the results

-- a) Crear índice:

CREATE INDEX idx_postal_code
ON address(postal_code);

-- b) Repetír las mismas consultas:
-- Query:
SELECT *
FROM address
WHERE postal_code IN ('42399','93896');

-- Hacer join:
SELECT a.address_id, a.postal_code, c.city, co.country
FROM address a
JOIN city c ON a.city_id = c.city_id
JOIN country co ON c.country_id = co.country_id
WHERE a.postal_code NOT IN ('42399','93896');

-- c) Probar:
SHOW PROFILES;

-- 12:37:29	SHOW PROFILES	0 row(s) returned	0.00034 sec / 0.0000081 sec --> 0.00034 sec

-- Explicacion:
-- A simple vista la diferencia de tiempo es mínima, y esto se debe a que la tabla address en sakila es chica.

-- Sin índice: MySQL no tiene ninguna referencia rápida sobre postal_code, por lo que debe recorrer la tabla completa (table scan) 
-- y comparar fila por fila hasta encontrar los valores que cumplen la condición.

-- Con índice: al existir un índice sobre postal_code, MySQL puede ir directamente a las posiciones de memoria donde se encuentran esos valores. 
-- En lugar de revisar fila por fila, consulta primero el índice y obtiene mucho más rápido las filas que necesita.

-- En un escenario real con cientos de miles o millones de filas el uso de un índice puede reducir los tiempos de ejecución de segundos o minutos a milisegundos.

-- 2) Run queries using actor table, searching for first and last name columns independently. Explain the differences and why is that happening?

-- a) Buscar por nombre:
SELECT *
FROM actor
WHERE first_name = 'JULIA';

-- 12:48:52	SELECT * FROM actor WHERE first_name = 'JULIA' LIMIT 0, 50000	4 row(s) returned	0.00066 sec / 0.000014 sec -> 0.00066 sec

-- b) Buscar por apellido:
SELECT *
FROM actor
WHERE last_name = 'MCQUEEN';

-- 12:48:52	SELECT * FROM actor WHERE last_name = 'MCQUEEN' LIMIT 0, 50000	2 row(s) returned	0.00077 sec / 0.000013 sec -> 0.00077 sec

-- Explicación:
-- En la tabla actor, hay índice por last_name (porque se usa mucho en búsquedas).
-- Pero no hay índice por first_name, entonces esa búsqueda recorre toda la tabla → es más lenta.

-- 3) Compare results finding text in the description on table film with LIKE and in the film_text using MATCH ... AGAINST. Explain the results.

-- a) Con LIKE:
SELECT title, description
FROM film
WHERE description LIKE '%amazing%';

-- 12:55:13	SELECT title, description FROM film WHERE description LIKE '%amazing%' LIMIT 0, 50000	48 row(s) returned	0.0045 sec / 0.000018 sec -> 0.0045 sec

-- b) Crear índice FULLTEXT en film_text si no existe
ALTER TABLE film_text
ADD FULLTEXT idx_fulltext_description (description);

-- c) Con FULLTEXT:
SELECT title, description
FROM film_text
WHERE MATCH(description) AGAINST('amazing');

-- 12:55:18	SELECT title, description FROM film_text WHERE MATCH(description) AGAINST('amazing') LIMIT 0, 50000	48 row(s) returned	0.0017 sec / 0.000018 sec -> 0.0017 sec

-- Explicación:
-- Con LIKE la búsqueda funciona pero MySQL recorre toda la tabla comparando texto, lo cual es más lento.
-- En cambio, al crear un índice FULLTEXT y usar MATCH ... AGAINST, MySQL consulta directamente el índice de palabras, 
-- lo que hace la búsqueda mucho más rápida y además devuelve los resultados ordenados por relevancia.
