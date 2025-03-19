use sakila;

-- 1. Show title and special_features of films that are PG-13
SELECT title, special_features
FROM film
WHERE rating = 'PG-13';

-- 2. Get a list of all the different films duration.
SELECT DISTINCT length 
FROM film
ORDER BY length;

-- 3. Show title, rental_rate and replacement_cost of films that have replacement_cost from 20.00 up to 24.00
SELECT title, rental_rate, replacement_cost
FROM film
WHERE replacement_cost > 20 AND replacement_cost <= 24
ORDER BY replacement_cost; 

-- 4. Show title, category and rating of films that have 'Behind the Scenes' as special_features
SELECT f.title, c.name AS category, f.rating, f.special_features
FROM film f
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
WHERE special_features = 'Behind the Scenes';

-- 5. Show first name and last name of actors that acted in 'ZOOLANDER FICTION'
SELECT ac.first_name, ac.last_name
FROM actor ac
INNER JOIN film_actor fa ON ac.actor_id = fa.actor_id
INNER JOIN film f ON fa.film_id = f.film_id
WHERE f.title = 'ZOOLANDER FICTION';

-- 6. Show the address, city and country of the store with id 1
SELECT a.address, ci.city, co.country
FROM store s
INNER JOIN address a ON s.address_id = a.address_id
INNER JOIN city ci ON a.city_id = ci.city_id
INNER JOIN country co ON ci.country_id = co.country_id
WHERE s.store_id = 1;

-- 7. Show pair of film titles and rating of films that have the same rating.
SELECT f1.title AS title1, f1.rating AS rating1, f2.title AS title2, f2.rating AS rating2
FROM film f1
INNER JOIN film f2 ON f1.rating = f2.rating
WHERE f1.film_id < f2.film_id;

-- 8. Get all the films that are available in store id 2 and the manager first/last name of this store (the manager will appear in all the rows).
SELECT f.title, s.first_name AS manager_first_name, s.last_name AS manager_last_name
FROM film f
INNER JOIN inventory i ON f.film_id = i.film_id
INNER JOIN store st ON i.store_id = st.store_id
INNER JOIN staff s ON st.manager_staff_id = s.staff_id
WHERE st.store_id = 2;
