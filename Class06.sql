USE sakila;

-- List all the actors that share the last name. Show them in order
SELECT a.actor_id, a.first_name, a.last_name
FROM actor a
WHERE EXISTS (
    SELECT *
    FROM actor b
    WHERE b.last_name = a.last_name
      AND b.actor_id != a.actor_id
)
ORDER BY a.last_name, a.first_name;

-- Find actors that don't work in any film
SELECT actor_id, first_name, last_name
FROM actor
WHERE actor_id NOT IN (
  SELECT actor_id
  FROM film_actor
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
SELECT first_name, last_name 
FROM actor
WHERE actor_id IN (
  SELECT actor_id
  FROM film_actor
  WHERE film_id = (
    SELECT film_id FROM film WHERE title = 'BETRAYED REAR'
  )
)
AND actor_id NOT IN(
  SELECT actor_id
  FROM film_actor
  WHERE film_id = (
    SELECT film_id FROM film WHERE title = 'CATCH AMISTAD'
  )
);

-- List the actors that acted in both 'BETRAYED REAR' and 'CATCH AMISTAD'
SELECT first_name, last_name 
FROM actor
WHERE actor_id IN (
  SELECT actor_id
  FROM film_actor
  WHERE film_id = (
    SELECT film_id FROM film WHERE title = 'BETRAYED REAR'
  )
)
AND actor_id IN(
  SELECT actor_id
  FROM film_actor
  WHERE film_id = (
    SELECT film_id FROM film WHERE title = 'CATCH AMISTAD'
  )
);

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

