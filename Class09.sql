USE sakila;

-- 1. Get the amount of cities per country in the database. Sort them by country, country_id.
SELECT c.country_id, c.country, (SELECT COUNT(*)
        FROM city ci
        WHERE ci.country_id = c.country_id) AS city_count
FROM country c
ORDER BY c.country, c.country_id;

-- 2. Get the amount of cities per country in the database. Show only the countries with more than 10 cities, order from the highest amount of cities to the lowest.
SELECT c.country_id, c.country, (SELECT COUNT(*) 
        FROM city ci 
        WHERE ci.country_id = c.country_id) AS city_count
FROM country c
HAVING (SELECT COUNT(*) 
	FROM city ci 
	WHERE ci.country_id = c.country_id) > 10
ORDER BY city_count DESC;

-- 3. Generate a report with customer (first, last) name, address, total films rented and the total money spent renting films. Show the ones who spent more money first.
SELECT cu.first_name, cu.last_name, a.address, COUNT(r.rental_id) AS total_films_rented, SUM(p.amount) AS total_money_spent
FROM customer cu
JOIN address a ON cu.address_id = a.address_id
LEFT JOIN rental r ON cu.customer_id = r.customer_id
LEFT JOIN payment p ON r.rental_id = p.rental_id
GROUP BY cu.customer_id, cu.first_name, cu.last_name, a.address
ORDER BY total_money_spent DESC;

-- 4. Which film categories have the larger film duration (comparing average)? Order by average in descending order.
SELECT c.name AS category_name, (SELECT AVG(f.length)
        FROM film f
        JOIN film_category fc ON f.film_id = fc.film_id
        WHERE fc.category_id = c.category_id) AS average_duration
FROM category c
ORDER BY average_duration DESC;

-- 5. Show sales per film rating.
SELECT sub.rating, SUM(sub.rental_count) AS total_rentals, SUM(sub.total_amount) AS total_sales
FROM (SELECT f.rating,(
		SELECT COUNT(*) 
		FROM rental r 
		JOIN inventory i ON r.inventory_id = i.inventory_id
		WHERE i.film_id = f.film_id) AS rental_count,(
            SELECT SUM(p.amount)
            FROM payment p
            JOIN rental r2 ON p.rental_id = r2.rental_id
            JOIN inventory i2 ON r2.inventory_id = i2.inventory_id
            WHERE i2.film_id = f.film_id) AS total_amount
    FROM film f) AS sub
GROUP BY sub.rating
ORDER BY total_sales DESC;