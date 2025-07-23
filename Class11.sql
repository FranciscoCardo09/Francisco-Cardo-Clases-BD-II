USE sakila;

-- 1: Find all the film titles that are not in the inventory.
SELECT f.title
FROM film f
LEFT JOIN inventory i ON f.film_id = i.film_id
WHERE i.inventory_id IS NULL;

-- 2: Find all the films that are in the inventory but were never rented.
SELECT f.title, i.inventory_id
FROM inventory i
JOIN film f ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.rental_id IS NULL;

-- 3: Generate a report with: 
-- customer (first, last) name, store id, film title, 
-- when the film was rented and returned for each of these customers
-- order by store_id, customer last_name
SELECT 
    c.first_name,
    c.last_name,
    c.store_id,
    f.title,
    r.rental_date,
    r.return_date
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
ORDER BY c.store_id, c.last_name;

-- 4: Show sales per store (money of rented films)
-- show store's city, country, manager info and total sales (money)
-- (optional) Use concat to show city and country and manager first and last name
SELECT
	SUM(p.amount),
	CONCAT(ci.city, ', ', co.country) AS ubicacion,
    CONCAT(st.first_name, ' ', st.last_name) AS staff
FROM store s
JOIN address a ON s.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
JOIN staff st ON s.manager_staff_id = st.staff_id
JOIN payment p ON st.staff_id = p.staff_id
GROUP BY ubicacion, staff;

-- 5: Which actor has appeared in the most films?
SELECT 
    a.actor_id,
    a.first_name,
    a.last_name,
    COUNT(fa.film_id) AS Cantidad_de_peliculas
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id
ORDER BY Cantidad_de_peliculas DESC
LIMIT 1;