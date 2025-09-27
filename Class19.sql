USE sakila;

-- 1) Create a user data_analyst

-- Primero tenés que estar logueado como root (o un usuario con permisos de administración).
CREATE USER 'data_analyst'@'localhost' IDENTIFIED BY '12345';
-- Esto crea el usuario data_analyst que solo puede conectarse desde localhost.

-- 2) Grant permissions only to SELECT, UPDATE and DELETE to all sakila tables to it.
GRANT SELECT, UPDATE, DELETE ON sakila.* TO 'data_analyst'@'localhost';
SHOW GRANTS FOR 'data_analyst'@'localhost';

-- 3) Login with this user and try to create a table. Show the result of that operation.
-- mysql -u data_analyst -p -> Salir de MySQL y entrar con el nuevo usuario
-- contraseña 12345

CREATE TABLE prueba (
  id INT PRIMARY KEY,
  nombre VARCHAR(50)
);
-- ERROR 1142 (42000): CREATE command denied...
-- Porque este usuario no tiene permisos de CREATE. Solo SELECT, UPDATE and DELETE.alter

-- 4) Try to update a title of a film. Write the update script.
UPDATE sakila.film
SET title = 'NEW TITLE'
WHERE film_id = 1;
-- Query OK, 1 row affected (0,01 sec)
-- Rows matched: 1  Changed: 1  Warnings: 0

-- 5) With root or any admin user revoke the UPDATE permission. Write the command
-- Salir y volver a entrar como root/admin:
-- mysql -u root -p
-- Y ejecutar:
REVOKE UPDATE ON sakila.* FROM 'data_analyst'@'localhost';
SHOW GRANTS FOR 'data_analyst'@'localhost';

-- 6) Ingresar otra vez como data_analyst y repetir el UPDATE del paso 5:
UPDATE sakila.film
SET title = 'ANOTHER TITLE'
WHERE film_id = 1;
-- ERROR 1142 (42000): UPDATE command denied to user 'data_analyst'@'localhost' for table 'film'