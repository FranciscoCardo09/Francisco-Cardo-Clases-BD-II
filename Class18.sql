USE sakila;

-- 1) Write a function that returns the amount of copies of a film in a store in sakila-db. Pass either the film id or the film name and the store id.

DROP FUNCTION IF EXISTS inventory_copies;

DELIMITER QueLaPruebaSeaFacil
CREATE FUNCTION inventory_copies(
    p_film_id INT,
    p_film_name VARCHAR(100),
    p_store_id INT
) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE copies INT;

    IF p_film_id IS NOT NULL THEN
        SELECT COUNT(*) INTO copies
        FROM inventory
        WHERE film_id = p_film_id
          AND (p_store_id IS NULL OR store_id = p_store_id);
    ELSE
        SELECT COUNT(*) INTO copies
        FROM inventory i
        JOIN film f ON i.film_id = f.film_id
        WHERE f.title = p_film_name
          AND (p_store_id IS NULL OR i.store_id = p_store_id);
    END IF;

    RETURN copies;
END QueLaPruebaSeaFacil
DELIMITER ;

SELECT inventory_copies(1, NULL, 2);
SELECT inventory_copies(NULL, 'ADAPTATION HOLES', NULL);

-- 2) Write a stored procedure with an output parameter that contains a list of customer first and last names separated by ";", 
-- that live in a certain country. You pass the country it gives you the list of people living there. 
-- USE A CURSOR, do not use any aggregation function.

DELIMITER QueLaPruebaSeaFacil
DROP PROCEDURE IF EXISTS customers_in_country QueLaPruebaSeaFacil
CREATE PROCEDURE customers_in_country(
    IN p_country VARCHAR(50),
    OUT p_customer_list TEXT
)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE c_first VARCHAR(45);
    DECLARE c_last  VARCHAR(45);
    DECLARE full_list TEXT DEFAULT '';
    DECLARE cur CURSOR FOR
        SELECT cu.first_name, cu.last_name
        FROM customer cu
        JOIN address a ON cu.address_id = a.address_id
        JOIN city ci ON a.city_id = ci.city_id
        JOIN country co ON ci.country_id = co.country_id
        WHERE co.country = p_country;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    OPEN cur;
    fetch_loop: LOOP
        FETCH cur INTO c_first, c_last;
        IF done = 1 THEN
            LEAVE fetch_loop;
        END IF;
        IF full_list = '' THEN
            SET full_list = CONCAT(c_first, ' ', c_last);
        ELSE
            SET full_list = CONCAT(full_list, ';', c_first, ' ', c_last);
        END IF;
    END LOOP;
    CLOSE cur;
    SET p_customer_list = full_list;
END QueLaPruebaSeaFacil
DELIMITER ;

SET @customers = '';
CALL customers_in_country('Argentina', @customers);
SELECT @customers;

-- 3) Review the function inventory_in_stock and the procedure film_in_stock explain the code, write usage examples.

-- Function film_in_stock:
DELIMITER $$
CREATE FUNCTION inventory_in_stock(p_film_id INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE stock INT;
    SELECT COUNT(*) INTO stock
    FROM inventory i
    WHERE i.film_id = p_film_id
      AND i.inventory_id NOT IN (
          SELECT r.inventory_id
          FROM rental r
          WHERE r.return_date IS NULL
      );
    RETURN stock;
END $$
DELIMITER ;

-- Cantidad de copias disponibles del film con id 1
SELECT inventory_in_stock(1);
-- Cantidad de copias disponibles del film con id 50
SELECT inventory_in_stock(50);

-- La función inventory_in_stock devuelve la cantidad de copias de un film que no están actualmente 
-- alquiladas (es decir, las copias que están disponibles en inventario). Se pasa solo el film_id 
-- y la función retorna un número entero.

-- Procedure film_in_stock:
DELIMITER $$
CREATE PROCEDURE film_in_stock(
    IN p_film_id INT,
    IN p_store_id INT
)
BEGIN
    SELECT i.inventory_id, i.film_id, i.store_id
    FROM inventory i
    WHERE i.film_id = p_film_id
      AND i.store_id = p_store_id
      AND i.inventory_id NOT IN (
          SELECT r.inventory_id
          FROM rental r
          WHERE r.return_date IS NULL
      );
END $$
DELIMITER ;

-- Declaramos la variable para el parámetro OUT
SET @film_count = 0;
-- Llamamos al procedimiento con los tres parámetros
CALL film_in_stock(1, 1, @film_count);
-- Mostramos el resultado
SELECT @film_count;

-- El procedimiento film_in_stock devuelve un listado de inventario de copias disponibles de un film 
-- en una tienda específica y además actualiza la variable de salida OUT con la cantidad de copias disponibles. 
-- Es útil cuando quieres tanto ver las copias como saber cuántas hay.