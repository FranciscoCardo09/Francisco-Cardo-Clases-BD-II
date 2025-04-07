USE sakila;

-- List all the actors that share the last name. Show them in order
SELECT ac.first_name, ac.last_name 
FROM actor ac
WHERE last_name IN (
    SELECT last_name
    FROM actor
    GROUP BY last_name
    HAVING COUNT(*) > 1
)
ORDER BY last_name, first_name;

-- Find actors that don't work in any film
SELECT ac.actor_id, ac.first_name, ac.last_name
FROM actor ac
WHERE NOT EXISTS (
    SELECT 1 
    FROM film_actor fa 
    WHERE fa.actor_id = ac.actor_id
);

-- Find customers that rented only one film
SELECT c.first_name, c.last_name
FROM customer c
WHERE (
    SELECT COUNT(rental_id)
    FROM rental
    WHERE customer_id = c.customer_id
) = 1;

-- Find customers that rented more than one film
SELECT c.first_name, c.last_name
FROM customer c
WHERE (
    SELECT COUNT(rental_id)
    FROM rental
    WHERE customer_id = c.customer_id
) > 1;

-- List the actors that acted in 'BETRAYED REAR' or in 'CATCH AMISTAD'
SELECT ac.first_name, ac.last_name 
FROM actor ac
WHERE last_name IN (
    SELECT last_name
    FROM film_actor fa
    JOIN film f ON fa.film_id = f.film_id
    WHERE fa.actor_id = ac.actor_id
    AND f.title IN ('BETRAYED REAR', 'CATCH AMISTAD')
)
ORDER BY ac.last_name, ac.first_name;

-- List the actors that acted in 'BETRAYED REAR' but not in 'CATCH AMISTAD'
SELECT ac.first_name, ac.last_name 
FROM actor ac
WHERE EXISTS (
    SELECT 1
    FROM film_actor fa
    JOIN film f ON fa.film_id = f.film_id
    WHERE fa.actor_id = ac.actor_id
    AND f.title = 'BETRAYED REAR'
)
AND NOT EXISTS (
    SELECT 1
    FROM film_actor fa
    JOIN film f ON fa.film_id = f.film_id
    WHERE fa.actor_id = ac.actor_id
    AND f.title = 'CATCH AMISTAD'
)
ORDER BY ac.last_name, ac.first_name;

-- List the actors that acted in both 'BETRAYED REAR' and 'CATCH AMISTAD'
SELECT ac.first_name, ac.last_name 
FROM actor ac
WHERE EXISTS (
    SELECT 1
    FROM film_actor fa
    JOIN film f ON fa.film_id = f.film_id
    WHERE fa.actor_id = ac.actor_id
    AND f.title = 'BETRAYED REAR'
)
AND EXISTS (
    SELECT 1
    FROM film_actor fa
    JOIN film f ON fa.film_id = f.film_id
    WHERE fa.actor_id = ac.actor_id
    AND f.title = 'CATCH AMISTAD'
)
ORDER BY ac.last_name, ac.first_name;

-- List all the actors that didn't work in 'BETRAYED REAR' or 'CATCH AMISTAD'
SELECT ac.first_name, ac.last_name 
FROM actor ac
WHERE last_name NOT IN (
    SELECT last_name
    FROM film_actor fa
    JOIN film f ON fa.film_id = f.film_id
    WHERE fa.actor_id = ac.actor_id
    AND f.title IN ('BETRAYED REAR', 'CATCH AMISTAD')
)
ORDER BY ac.last_name, ac.first_name;

