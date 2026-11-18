CREATE DATABASE IF NOT EXISTS veterinaria;

USE veterinaria;

CREATE TABLE IF NOT EXISTS cliente (
                                       cedula VARCHAR(20) PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    edad INT NOT NULL,
    CONSTRAINT chk_cliente_edad CHECK (edad BETWEEN 18 AND 60),
    CONSTRAINT chk_cliente_cedula CHECK (TRIM(cedula) <> ''),
    CONSTRAINT chk_cliente_nombre CHECK (TRIM(nombre) <> ''),
    CONSTRAINT chk_cliente_telefono CHECK (TRIM(telefono) <> '')
    );

CREATE TABLE IF NOT EXISTS mascota (
                                       codigo VARCHAR(15) PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    especie ENUM('PERRO', 'GATO', 'OTRO') NOT NULL,
    edad INT NOT NULL,
    cedula_cliente VARCHAR(20) NOT NULL,
    CONSTRAINT chk_mascota_codigo CHECK (TRIM(codigo) <> ''),
    CONSTRAINT chk_mascota_nombre CHECK (TRIM(nombre) <> ''),
    CONSTRAINT fk_mascota_cliente
    FOREIGN KEY (cedula_cliente)
    REFERENCES cliente(cedula)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT
    );

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_listar_clientes$$

CREATE DEFINER = 'vet_definer'@'localhost'
PROCEDURE sp_listar_clientes()
SQL SECURITY DEFINER
BEGIN
SELECT cedula, nombre, telefono
FROM cliente;
END$$

DROP PROCEDURE IF EXISTS sp_insertar_cliente$$

CREATE DEFINER = 'vet_definer'@'localhost'
PROCEDURE sp_insertar_cliente(
    IN p_cedula VARCHAR(20),
    IN p_nombre VARCHAR(80),
    IN p_telefono VARCHAR(20),
    IN p_edad INT
)
SQL SECURITY DEFINER
BEGIN
INSERT INTO cliente (cedula, nombre, telefono, edad)
VALUES (p_cedula, p_nombre, p_telefono, p_edad);
END$$

DROP PROCEDURE IF EXISTS sp_listar_mascotas$$

CREATE DEFINER = 'vet_definer'@'localhost'
PROCEDURE sp_listar_mascotas()
SQL SECURITY DEFINER
BEGIN
SELECT codigo, nombre, especie, edad, cedula_cliente
FROM mascota;
END$$

DROP PROCEDURE IF EXISTS sp_insertar_mascota$$

CREATE DEFINER = 'vet_definer'@'localhost'
PROCEDURE sp_insertar_mascota(
    IN p_codigo VARCHAR(15),
    IN p_nombre VARCHAR(80),
    IN p_especie VARCHAR(10),
    IN p_edad INT,
    IN p_cedula_cliente VARCHAR(20)
)
SQL SECURITY DEFINER
BEGIN
INSERT INTO mascota (codigo, nombre, especie, edad, cedula_cliente)
VALUES (p_codigo, p_nombre, p_especie, p_edad, p_cedula_cliente);
END$$

DROP PROCEDURE IF EXISTS sp_actualizar_mascota$$

CREATE DEFINER = 'vet_definer'@'localhost'
PROCEDURE sp_actualizar_mascota(
    IN p_codigo VARCHAR(15),
    IN p_nombre VARCHAR(80),
    IN p_especie VARCHAR(10),
    IN p_edad INT,
    IN p_cedula_cliente VARCHAR(20)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_existe INT DEFAULT 0;

SELECT COUNT(*)
INTO v_existe
FROM mascota
WHERE codigo = p_codigo;

IF v_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La mascota no existe';
ELSE
UPDATE mascota
SET nombre = p_nombre,
    especie = p_especie,
    edad = p_edad,
    cedula_cliente = p_cedula_cliente
WHERE codigo = p_codigo;
END IF;
END$$

DROP PROCEDURE IF EXISTS sp_eliminar_mascota$$

CREATE DEFINER = 'vet_definer'@'localhost'
PROCEDURE sp_eliminar_mascota(
    IN p_codigo VARCHAR(15)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_existe INT DEFAULT 0;

SELECT COUNT(*)
INTO v_existe
FROM mascota
WHERE codigo = p_codigo;

IF v_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La mascota no existe';
ELSE
DELETE FROM mascota
WHERE codigo = p_codigo;
END IF;
END$$

DROP PROCEDURE IF EXISTS sp_listar_mascotas_con_dueno$$

CREATE DEFINER = 'vet_definer'@'localhost'
PROCEDURE sp_listar_mascotas_con_dueno()
SQL SECURITY DEFINER
BEGIN
SELECT
    m.codigo,
    m.nombre,
    m.especie,
    m.edad,
    m.cedula_cliente,
    c.nombre AS nombre_cliente
FROM mascota m
         INNER JOIN cliente c
                    ON m.cedula_cliente = c.cedula;
END$$

DELIMITER ;




USE veterinaria;

REVOKE ALL PRIVILEGES, GRANT OPTION
    FROM 'vet_definer'@'localhost';

REVOKE ALL PRIVILEGES, GRANT OPTION
    FROM 'vet_app'@'localhost';

GRANT SELECT, INSERT
      ON veterinaria.cliente
          TO 'vet_definer'@'localhost';

GRANT SELECT, INSERT, UPDATE, DELETE
      ON veterinaria.mascota
          TO 'vet_definer'@'localhost';

GRANT EXECUTE ON PROCEDURE veterinaria.sp_listar_clientes
TO 'vet_app'@'localhost';

GRANT EXECUTE ON PROCEDURE veterinaria.sp_insertar_cliente
TO 'vet_app'@'localhost';

GRANT EXECUTE ON PROCEDURE veterinaria.sp_listar_mascotas
TO 'vet_app'@'localhost';

GRANT EXECUTE ON PROCEDURE veterinaria.sp_insertar_mascota
TO 'vet_app'@'localhost';

GRANT EXECUTE ON PROCEDURE veterinaria.sp_actualizar_mascota
TO 'vet_app'@'localhost';

GRANT EXECUTE ON PROCEDURE veterinaria.sp_eliminar_mascota
TO 'vet_app'@'localhost';

GRANT EXECUTE ON PROCEDURE veterinaria.sp_listar_mascotas_con_dueno
TO 'vet_app'@'localhost';

SHOW GRANTS FOR 'vet_definer'@'localhost';

SHOW GRANTS FOR 'vet_app'@'localhost';














