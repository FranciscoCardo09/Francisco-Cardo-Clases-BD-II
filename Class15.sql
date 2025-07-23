USE sakila;

-- 1: Create a view named list_of_customers, it should contain the following columns:
-- customer id
-- customer full name,
-- address
-- zip code
-- phone
-- city
-- country
-- status (when active column is 1 show it as 'active', otherwise is 'inactive')
-- store id
CREATE OR REPLACE VIEW list_of_customers AS
SELECT
	c.customer_id,
    CONCAT(c.first_name, '', c.last_name) AS Nombre_Completo,
    a.address,
    a.postal_code,
    a.phone,
    ci.city,
    co.country,
    CASE WHEN c.active = 1 THEN 'active' ELSE 'inactive' END AS status,
    c.store_id
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id;

SELECT * FROM list_of_customers;

-- 2: Create a view named film_details, it should contain the following columns: 
-- film id, 
-- title, 
-- description, 
-- category, 
-- price, 
-- length, 
-- rating, 
-- actors - as a string of all the actors separated by comma. Hint use GROUP_CONCAT
CREATE OR REPLACE VIEW film_details AS
SELECT 
    f.film_id,
    f.title,
    f.description,
    c.name AS category,
    p.amount AS price,
    f.length,
    f.rating,
    GROUP_CONCAT(CONCAT(a.first_name, ' ', a.last_name) SEPARATOR ', ') AS actors
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
JOIN film_actor fa ON f.film_id = fa.film_id
JOIN actor a ON fa.actor_id = a.actor_id
GROUP BY f.film_id;

SELECT * FROM list_of_customers;

-- 3: Create view sales_by_film_category, it should return 'category' and 'total_rental' columns.
CREATE OR REPLACE VIEW sales_by_film_category AS
SELECT 
	c.name as categoria,
    SUM(p.amount) as total
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name;

SELECT * FROM sales_by_film_category;

-- 4: Create a view called actor_information where it should return, 
-- actor id, 
-- first name, 
-- last name 
-- and the amount of films he/she acted on.
CREATE OR REPLACE VIEW actor_information AS
SELECT 
	a.actor_id,
    a.first_name,
    a.last_name,
    COUNT(fa.film_id) as Cantidad_peliculas
FROM film_actor fa
JOIN actor a ON fa.actor_id = a.actor_id
GROUP BY actor_id;

SELECT * FROM actor_information;

-- 5: Analyze view actor_info, 
-- explain the entire query and specially how the sub query works. 
-- Be very specific, take some time and decompose each part and give an explanation for each.

-- Acá esta la view:
CREATE VIEW actor_info AS
SELECT
  a.actor_id,
  a.first_name,
  a.last_name,
  COUNT(DISTINCT fa.film_id) AS film_count,
  GROUP_CONCAT(DISTINCT c.name ORDER BY c.name SEPARATOR ', ') AS film_categories,
  GROUP_CONCAT(DISTINCT CONCAT(f.title, ' (', f.release_year, ')') ORDER BY f.title SEPARATOR ', ') AS film_titles
FROM actor a
LEFT JOIN film_actor fa ON a.actor_id = fa.actor_id
LEFT JOIN film f ON fa.film_id = f.film_id
LEFT JOIN film_category fc ON f.film_id = fc.film_id
LEFT JOIN category c ON fc.category_id = c.category_id
GROUP BY a.actor_id;

SELECT * FROM actor_info;

-- a.actor_id, a.first_name, a.last_name
-- Acá simplemente trae la data básica del actor: su ID, nombre y apellido.

-- COUNT(DISTINCT fa.film_id) AS film_count
-- Esto cuenta en cuántas pelis actuó cada actor. El DISTINCT es clave porque puede haber repetidos si está todo con join varias veces, así que esto limpia los duplicados.

-- GROUP_CONCAT(DISTINCT c.name ...) AS film_categories
-- Acá junta todas las categorías de pelis donde participó ese actor, separadas por coma. Si actuó en pelis de “Action”, “Drama” y “Comedy”, te devuelve: Action, Comedy, Drama.

-- GROUP_CONCAT(DISTINCT CONCAT(f.title, ' (', f.release_year, ')') ...) AS film_titles
-- Es igual al anterior pero con los títulos de las pelis. Además te pone el año entre paréntesis. Te queda algo como:
-- ALIEN CENTER (2006), ZORRO ARK (2006)
-- Así tenés de todas las pelis en las que participó el actor.

-- FROM actor a LEFT JOIN ...
-- Acá empieza a unir las tablas con LEFT JOIN:

-- film_actor: para saber en qué pelis actuó

-- film: para sacar título y año

-- film_category: para ver la categoría de cada peli

-- category: para el nombre de la categoría

-- El LEFT JOIN es clave porque aunque un actor no tenga pelis cargadas, igual aparece con los campos vacíos. No lo borra del resultado.

-- GROUP BY a.actor_id
-- Agrupa por actor. O sea, todo lo que aparece después (los COUNT y GROUP_CONCAT) se hace por cada actor individualmente. Básicamente: una fila por actor.

-- 6: Materialized views, write a description, why they are used, alternatives, DBMS were they exist, etc.

-- Simulación de vista materializada: resumen de alquileres por categoría y rating
CREATE TABLE resumen_categoria_rating AS
SELECT 
    c.name AS categoria,
    f.rating,
    COUNT(r.rental_id) AS total_alquileres
FROM 
    category c
    JOIN film_category fc ON c.category_id = fc.category_id
    JOIN film f ON fc.film_id = f.film_id
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY 
    c.name, f.rating;

-- Esto crea una tabla con el total de alquileres por categoría de película y su rating.
-- Por ejemplo: cuántas veces se alquilaron películas de "Documentary" con rating "PG".

-- Para actualizarla manualmente:
TRUNCATE TABLE resumen_categoria_rating;

INSERT INTO resumen_categoria_rating
SELECT 
    c.name AS categoria,
    f.rating,
    COUNT(r.rental_id) AS total_alquileres
FROM 
    category c
    JOIN film_category fc ON c.category_id = fc.category_id
    JOIN film f ON fc.film_id = f.film_id
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY 
    c.name, f.rating;

-- Esto es útil para hacer reportes de consumo tipo: ¿qué rating se alquila más en cada categoría?
-- Ejemplo de salida:
-- | categoria     | rating | total_alquileres |
-- | Action        | PG-13  | 856              |
-- | Horror        | R      | 423              |
-- | Comedy        | G      | 732              |

-- Con esto hacés algo diferente y fácil de entender. Y si lo explicás como:
-- "Para ver qué tipo de contenido se consume más según la categoría y la clasificación de edad",
-- te lo compran sin problema.