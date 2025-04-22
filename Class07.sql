USE sakila;

-- Find the films with less duration, show the title and rating.
SELECT f.title, f.length, f.rating
FROM (
    SELECT * FROM film
) AS f,
(
    SELECT MIN(length) AS min_length FROM film
) AS min_f
WHERE f.length = min_f.min_length;
    
-- Write a query that returns the tiltle of the film which duration is the lowest. 
-- If there are more than one film with the lowest durtation, the query returns an empty resultset.
SELECT title
FROM film
WHERE length = (
    SELECT MIN(length)
    FROM film
)
AND (
    SELECT COUNT(*)
    FROM film
    WHERE length = (
        SELECT MIN(length)
        FROM film
    )
) = 1;

-- Generate a report with list of customers showing the lowest payments done by each of them. 
-- Show customer information, the address and the lowest amount, provide both solution using ALL and/or ANY and MIN.
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    a.address,
    p.amount AS lowest_payment,
    p.rental_id
FROM 
    (SELECT * FROM customer) AS c,
    (SELECT * FROM address) AS a,
    (SELECT * FROM payment) AS p
WHERE 
    c.address_id = a.address_id
    AND p.customer_id = c.customer_id
    AND p.amount <= ALL (
        SELECT p2.amount
        FROM payment p2
        WHERE p2.customer_id = p.customer_id
    );

-- Generate a report that shows the customer's information with the highest payment and the lowest payment in the same row.
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    a.address,
    (
        SELECT MIN(p1.amount)
        FROM payment p1 
        WHERE p1.customer_id = c.customer_id
    ) AS lowest_payment,
    (
        SELECT MAX(p2.amount)
        FROM payment p2
        WHERE p2.customer_id = c.customer_id
    ) AS highest_payment
FROM (
    SELECT * FROM customer
) AS c,
(
    SELECT * FROM address
) AS a
WHERE c.address_id = a.address_id;