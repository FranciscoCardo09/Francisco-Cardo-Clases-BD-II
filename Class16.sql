USE sakila;
-- 1: Insert a new employee to , but with an null email. Explain what happens.

-- Tabla:
CREATE TABLE IF NOT EXISTS employees (
    employeeNumber INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL
);

-- Insert:
INSERT INTO employees (employeeNumber, nombre, apellido, email)
VALUES (666, 'Teodoro', 'Reyna', NULL);

-- Error:
-- ERROR 1048 (23000): Column 'email' cannot be null

-- Explicacion:
-- La columna email tiene una restricción NOT NULL, por lo que MySQL no permite insertar valores nulos. Esto es un constraint de integridad de entidad.

-- 2: Run the first the query

UPDATE employees SET employeeNumber = employeeNumber - 20;
-- What did happen? Explain. Then run this other

-- Explicacion: 
-- Si employeeNumber es PRIMARY KEY y la resta genera números repetidos, MySQL lanza:

-- ERROR 1062 (23000): Duplicate entry 'xxx' for key 'PRIMARY'

-- Si no hay duplicados, actualiza todos los valores.

UPDATE employees SET employeeNumber = employeeNumber + 20;
-- Explain this case also.

-- Explicacion:
-- Lo mismo. Si el incremento genera valores duplicados en la clave primaria da error.

-- 3: Add a age column to the table employee where and it can only accept values from 16 up to 70 years old.
-- Si la columna existe, borrarla (MySQL >= 8.0.19 permite IF EXISTS)
ALTER TABLE employees DROP COLUMN edad;

-- Crear la columna con el CHECK
ALTER TABLE employees
  ADD COLUMN edad TINYINT UNSIGNED NOT NULL,
  ADD CONSTRAINT check_edad CHECK (edad BETWEEN 16 AND 70);

-- Crear triggers
DELIMITER TeoAprobame

DROP TRIGGER IF EXISTS trg_check_edad_ins TeoAprobame
CREATE TRIGGER trg_check_edad_ins
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
  IF NEW.edad < 16 OR NEW.edad > 70 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'edad debe estar entre 16 y 70';
  END IF;
END TeoAprobame

DROP TRIGGER IF EXISTS trg_check_edad_upd TeoAprobame
CREATE TRIGGER trg_check_edad_upd
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
  IF NEW.edad < 16 OR NEW.edad > 70 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'edad debe estar entre 16 y 70';
  END IF;
END TeoAprobame

DELIMITER ;

-- 4: Describe the referential integrity between tables film, actor and film_actor in sakila db.
-- Claves primarias
-- film       → PK: film_id
-- actor      → PK: actor_id
-- film_actor → PK compuesto: (actor_id, film_id)

-- Claves foráneas en film_actor
-- actor_id → FK a actor.actor_id
-- film_id  → FK a film.film_id

-- No se puede insertar en film_actor un actor_id que no exista en actor o un film_id que no exista en film.
-- No se puede borrar un actor o película referenciada en film_actor (a menos que se use ON DELETE CASCADE).
-- Garantiza que cada par (actor_id, film_id) sea único en film_actor.

-- 5: Create a new column called lastUpdate to table employee and use trigger(s) to keep the date-time updated 
-- on inserts and updates operations. Bonus: add a column lastUpdateUser and the respective trigger(s) to specify 
-- who was the last MySQL user that changed the row (assume multiple users, other than root, can connect to MySQL and change this table).
ALTER TABLE employees
  ADD COLUMN lastUpdate DATETIME,
  ADD COLUMN lastUpdateUser VARCHAR(100);

DELIMITER TeoAprobame

-- Trigger BEFORE INSERT
DROP TRIGGER IF EXISTS trg_employees_bi TeoAprobame
CREATE TRIGGER trg_employees_bi
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
  SET NEW.lastUpdate = NOW();
  SET NEW.lastUpdateUser = USER();
END TeoAprobame

-- Trigger BEFORE UPDATE
DROP TRIGGER IF EXISTS trg_employees_bu TeoAprobame
CREATE TRIGGER trg_employees_bu
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
  SET NEW.lastUpdate = NOW();
  SET NEW.lastUpdateUser = USER();
END TeoAprobame

DELIMITER ;

-- 6: Find all the triggers in sakila db related to loading film_text table. 
-- What do they do? Explain each of them using its source code for the explanation.
DELIMITER TeoAprobame

CREATE TRIGGER ins_film AFTER INSERT ON film
FOR EACH ROW
BEGIN
  INSERT INTO film_text (film_id, title, description)
  VALUES (NEW.film_id, NEW.title, NEW.description);
END TeoAprobame

CREATE TRIGGER upd_film AFTER UPDATE ON film
FOR EACH ROW
BEGIN
  IF (OLD.title != NEW.title)
     OR (OLD.description != NEW.airpods maxdescription)
     OR (OLD.film_id != NEW.film_id) THEN
    UPDATE film_text
    SET title = NEW.title,
        description = NEW.description,
        film_id = NEW.film_id
    WHERE film_id = OLD.film_id;
  END IF;
END TeoAprobame

CREATE TRIGGER del_film AFTER DELETE ON film
FOR EACH ROW
BEGIN
  DELETE FROM film_text
  WHERE film_id = OLD.film_id;
END $$

DELIMITER ;