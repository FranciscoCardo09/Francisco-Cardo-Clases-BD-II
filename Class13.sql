USE sakila;


-- 1: Add a new customer
-- To store 1
-- For address use an existing address. The one that has the biggest address_id in 'United States'
INSERT INTO customer (
    store_id, first_name, last_name, email, address_id, active, create_date
)
VALUES (
    1,
    'Juan',
    'Pérez',
    'juan.perez@example.com',
    (
        SELECT MAX(a.address_id)
        FROM address a
        JOIN city ci ON a.city_id = ci.city_id
        JOIN country co ON ci.country_id = co.country_id
        WHERE co.country = 'United States'
    ),
    1,
    NOW()
);

-- 2: Add a rental
-- Make easy to select any film title. I.e. I should be able to put 'film tile' in the where, and not the id.
-- Do not check if the film is already rented, just use any from the inventory, e.g. the one with highest id.
-- Select any staff_id from Store 2.
INSERT INTO rental (
    rental_date, inventory_id, customer_id, staff_id
)
VALUES (
    NOW(),
    (
        SELECT MAX(i.inventory_id)
        FROM inventory i
        JOIN film f ON i.film_id = f.film_id
        WHERE f.title = 'ACADEMY DINOSAUR'
    ),
    (
        SELECT MIN(customer_id)
        FROM customer
    ),
    (
        SELECT MIN(staff_id)
        FROM staff
        WHERE store_id = 2
    )
);

-- 3: Update film year based on the rating
-- For example if rating is 'G' release date will be '2001'
-- You can choose the mapping between rating and year.
-- Write as many statements are needed.
UPDATE film
SET release_year = CASE rating
    WHEN 'G' THEN 2001
    WHEN 'PG' THEN 2002
    WHEN 'PG-13' THEN 2003
    WHEN 'R' THEN 2004
    WHEN 'NC-17' THEN 2005
    ELSE release_year
END;

-- 4: Return a film
-- Write the necessary statements and queries for the following steps.
-- Find a film that was not yet returned. And use that rental id. Pick the latest that was rented for example.
-- Use the id to return the film.
SELECT rental_id
FROM rental
WHERE return_date IS NULL
ORDER BY rental_date DESC
LIMIT 1;

-- 5: Try to delete a film
-- Check what happens, describe what to do.
-- Write all the necessary delete statements to entirely remove the film from the DB.

-- Intentá eliminar una película
DELETE FROM film WHERE title = 'FEVER EMPIRE';
-- Error: foreign key constraint en otras tablas

-- Eliminación total en orden correcto
-- 1. Eliminar de payment → rental → inventory → film_category → film_actor → film
DELETE FROM payment
WHERE rental_id IN (
    SELECT rental_id
    FROM rental
    WHERE inventory_id IN (
        SELECT inventory_id
        FROM inventory
        WHERE film_id = (
            SELECT film_id FROM film WHERE title = 'FEVER EMPIRE'
        )
    )
);

DELETE FROM rental
WHERE inventory_id IN (
    SELECT inventory_id
    FROM inventory
    WHERE film_id = (
        SELECT film_id FROM film WHERE title = 'FEVER EMPIRE'
    )
);

DELETE FROM inventory
WHERE film_id = (
    SELECT film_id FROM film WHERE title = 'FEVER EMPIRE'
);

DELETE FROM film_category
WHERE film_id = (
    SELECT film_id FROM film WHERE title = 'FEVER EMPIRE'
);

DELETE FROM film_actor
WHERE film_id = (
    SELECT film_id FROM film WHERE title = 'FEVER EMPIRE'
);

DELETE FROM film
WHERE title = 'FEVER EMPIRE';

-- 6: Rent a film
-- Find an inventory id that is available for rent (available in store) pick any movie. Save this id somewhere.
-- Add a rental entry
-- Add a payment entry
-- Use sub-queries for everything, except for the inventory id that can be used directly in the queries. 

-- 1. Encontrar un inventory disponible.
SELECT inventory_id
FROM inventory i
WHERE NOT EXISTS (
    SELECT 1
    FROM rental r
    WHERE r.inventory_id = i.inventory_id
      AND r.return_date IS NULL
)
LIMIT 1;

-- 2. Insertar en rental
INSERT INTO rental (
    rental_date, inventory_id, customer_id, staff_id
)
VALUES (
    NOW(),
    500,
    (
        SELECT MIN(customer_id) FROM customer
    ),
    (
        SELECT MIN(staff_id) FROM staff WHERE store_id = (
            SELECT store_id FROM inventory WHERE inventory_id = 500
        )
    )
);

-- 3. Insertar en payment
INSERT INTO payment (
    customer_id, staff_id, rental_id, amount, payment_date
)
VALUES (
    (
        SELECT MIN(customer_id) FROM customer
    ),
    (
        SELECT MIN(staff_id) FROM staff WHERE store_id = (
            SELECT store_id FROM inventory WHERE inventory_id = 500
        )
    ),
    (
        SELECT rental_id
        FROM rental
        WHERE inventory_id = 500
        ORDER BY rental_date DESC
        LIMIT 1
    ),
    4.99,
    NOW()
);







