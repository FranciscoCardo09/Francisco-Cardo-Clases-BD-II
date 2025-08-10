-- 1: Write a query that gets all the customers that live in Argentina. 
-- Show the first and last name in one column, the address and the city.
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    a.address,
    ci.city
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE co.country = 'Argentina';

-- 2: Write a query that shows the film title, language and rating. 
-- Rating shall be shown as the full text described here: https://en.wikipedia.org/wiki/Motion_picture_content_rating_system#United_States. 
-- Hint: use case.
SELECT 
    f.title,
    l.name AS language,
    CASE f.rating
        WHEN 'G' THEN 'Apta para todo público'
        WHEN 'PG' THEN 'Se sugiere orientación de los padres'
        WHEN 'PG-13' THEN 'Mayores de 13 años con supervisión de adultos'
        WHEN 'R' THEN 'Restringido a mayores de 17 años'
        WHEN 'NC-17' THEN 'Sólo para adultos'
        ELSE 'Desconocido'
    END AS rating_full
FROM film f
JOIN language l ON f.language_id = l.language_id;

-- 3: Write a search query that shows all the films (title and release year) an actor was part of. 
-- Assume the actor comes from a text box introduced by hand from a web page. 
-- Make sure to "adjust" the input text to try to find the films as effectively as you think is possible.
SET @actor_input = '  ricardo darin  ';

SELECT 
    f.title AS titulo,
    f.release_year AS año_estreno
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
JOIN actor a ON fa.actor_id = a.actor_id
WHERE UPPER(CONCAT(a.first_name, ' ', a.last_name)) LIKE CONCAT('%', UPPER(TRIM(@actor_input)), '%');

-- 4: Find all the rentals done in the months of May and June. Show the film title, 
-- customer name and if it was returned or not. There should be returned column with two possible values 'Yes' and 'No'.
SELECT 
    f.title AS titulo,
    CONCAT(c.first_name, ' ', c.last_name) AS nombre_cliente,
    CASE 
        WHEN r.return_date IS NOT NULL THEN 'Sí'
        ELSE 'No'
    END AS devuelto
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN customer c ON r.customer_id = c.customer_id
WHERE MONTH(r.rental_date) IN (5, 6);

-- 5: Investigate CAST and CONVERT functions. Explain the differences if any, write examples based on sakila DB.

-- En MySQL:

-- CAST(expr AS type) → estándar SQL.
-- CONVERT(expr, type) → sintaxis MySQL, también usada para charset.

-- Ejemplos en Sakila:

-- Convertir fecha a texto
SELECT rental_id, CAST(rental_date AS CHAR) AS rental_text
FROM rental
LIMIT 5;

-- Convertir entero a DECIMAL
SELECT film_id, CAST(rental_rate AS DECIMAL(5,2)) AS rental_rate_decimal
FROM film
LIMIT 5;

-- CONVERT funciona igual
SELECT rental_id, CONVERT(rental_date, CHAR) AS rental_text
FROM rental
LIMIT 5;

-- 6: Investigate NVL, ISNULL, IFNULL, COALESCE, etc type of function. Explain what they do. Which ones are not in MySql and write usage examples.

-- En MySQL:

-- NVL() → No existe (es de Oracle).
-- ISNULL(expr) → Devuelve 1 si es NULL, 0 si no.
-- IFNULL(expr1, expr2) → Si expr1 es NULL, devuelve expr2.
-- COALESCE(expr1, expr2, expr3, ...) → Devuelve el primer valor no nulo.

-- Ejemplos Sakila:

-- IFNULL: reemplazar NULL por texto
SELECT rental_id, IFNULL(return_date, 'Not Returned') AS return_status
FROM rental
LIMIT 5;

-- COALESCE: primer valor no nulo entre varias columnas
SELECT rental_id, COALESCE(return_date, rental_date, 'No Date') AS date_value
FROM rental
LIMIT 5;

-- ISNULL: 1 si es NULL, 0 si no
SELECT rental_id, ISNULL(return_date) AS is_null
FROM rental
LIMIT 5;
