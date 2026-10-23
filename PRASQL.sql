
-- ============================================================
-- PRACTICA #1 DE SQL
-- Motor de base de datos: SQLite
-- ============================================================


-- EJERCICIO 1: Crear la base de datos PRASQL.
-- En SQLite, la base de datos se crea como un archivo llamado
-- prasql.db. Abre o crea ese archivo antes de ejecutar el script.


-- EJERCICIOS 2, 3 Y 4:
-- Crear las tablas Cliente, Factura y Recibo.
-- Crear las PRIMARY KEY de las tres tablas.
-- Crear las FOREIGN KEY de las tablas Factura y Recibo.

PRAGMA foreign_keys = ON;

CREATE TABLE cliente (
    codigo_cliente INTEGER PRIMARY KEY,
    nombre_cliente TEXT NOT NULL,
    estado TEXT NOT NULL
);

CREATE TABLE factura (
    codigo_cliente INTEGER NOT NULL,
    numero_factura INTEGER PRIMARY KEY,
    monto NUMERIC NOT NULL,
    FOREIGN KEY (codigo_cliente)
        REFERENCES cliente(codigo_cliente)
);

CREATE TABLE recibo (
    codigo_cliente INTEGER NOT NULL,
    numero_recibo INTEGER PRIMARY KEY,
    numero_factura INTEGER NOT NULL,
    monto NUMERIC NOT NULL,
    FOREIGN KEY (codigo_cliente)
        REFERENCES cliente(codigo_cliente),
    FOREIGN KEY (numero_factura)
        REFERENCES factura(numero_factura)
);


-- CARGA DE LOS DATOS ORIGINALES DE LA PRACTICA

INSERT INTO cliente
    (codigo_cliente, nombre_cliente, estado)
VALUES
    (1, 'Juan Pérez', 'Activo'),
    (2, 'Julio Paz', 'Activo'),
    (3, 'Rosa Fernández', 'Activo'),
    (4, 'Luis Roja', 'Activo'),
    (5, 'Carmen García', 'Activo'),
    (6, 'Roberto Ledesma', 'Activo'),
    (7, 'Carlos Caraballo', 'Activo'),
    (8, 'Juana Rosario', 'Activo'),
    (9, 'Pedro Jiménez', 'Activo');

INSERT INTO factura
    (codigo_cliente, numero_factura, monto)
VALUES
    (7, 120, 1000.00),
    (8, 121, 500.00),
    (7, 122, 200.00),
    (5, 111, 700.00),
    (5, 112, 1500.00),
    (9, 172, 2000.00),
    (7, 173, 2500.00),
    (8, 123, 3500.00),
    (9, 175, 4600.00);

INSERT INTO recibo
    (codigo_cliente, numero_recibo, numero_factura, monto)
VALUES
    (7, 71, 120, -100.00),
    (7, 80, 120, -200.00),
    (8, 82, 121, -100.00),
    (5, 91, 111, -200.00),
    (5, 93, 112, -300.00),
    (5, 96, 112, -400.00),
    (9, 98, 172, -200.00),
    (7, 99, 173, -500.00),
    (8, 100, 123, -3500.00),
    (9, 101, 175, -4000.00),
    (7, 102, 173, -600.00),
    (7, 103, 122, -100.00);


-- ============================================================
-- EJERCICIO 5: Hacer las sentencias SELECT necesarias.
-- ============================================================


-- 5.a. Monto total facturado por cliente.

SELECT
    c.codigo_cliente,
    c.nombre_cliente,
    COALESCE(SUM(f.monto), 0) AS total_facturado
FROM cliente c
LEFT JOIN factura f
    ON c.codigo_cliente = f.codigo_cliente
GROUP BY c.codigo_cliente, c.nombre_cliente
ORDER BY c.codigo_cliente;


-- 5.b. Monto total pagado por cada factura del cliente.

SELECT
    c.codigo_cliente,
    c.nombre_cliente,
    f.numero_factura,
    f.monto AS monto_factura,
    COALESCE(SUM(ABS(r.monto)), 0) AS total_pagado
FROM cliente c
JOIN factura f
    ON c.codigo_cliente = f.codigo_cliente
LEFT JOIN recibo r
    ON f.numero_factura = r.numero_factura
GROUP BY
    c.codigo_cliente,
    c.nombre_cliente,
    f.numero_factura,
    f.monto
ORDER BY c.codigo_cliente, f.numero_factura;


-- 5.c. Clientes que tienen más de una factura.

SELECT
    c.codigo_cliente,
    c.nombre_cliente,
    COUNT(f.numero_factura) AS cantidad_facturas
FROM cliente c
JOIN factura f
    ON c.codigo_cliente = f.codigo_cliente
GROUP BY c.codigo_cliente, c.nombre_cliente
HAVING COUNT(f.numero_factura) > 1;


-- 5.d. Facturas del cliente número 5.

SELECT *
FROM factura
WHERE codigo_cliente = 5;


-- 5.e. Recibos pagados por el cliente número 16.

SELECT *
FROM recibo
WHERE codigo_cliente = 16;


-- 5.f. Cantidad de facturas por cliente.

SELECT
    c.codigo_cliente,
    c.nombre_cliente,
    COUNT(f.numero_factura) AS cantidad_facturas
FROM cliente c
LEFT JOIN factura f
    ON c.codigo_cliente = f.codigo_cliente
GROUP BY c.codigo_cliente, c.nombre_cliente
ORDER BY c.codigo_cliente;


-- 5.g. Cantidad de recibos por cliente.

SELECT
    c.codigo_cliente,
    c.nombre_cliente,
    COUNT(r.numero_recibo) AS cantidad_recibos
FROM cliente c
LEFT JOIN recibo r
    ON c.codigo_cliente = r.codigo_cliente
GROUP BY c.codigo_cliente, c.nombre_cliente
ORDER BY c.codigo_cliente;


-- 5.h. Cantidad total de facturas.

SELECT COUNT(*) AS total_facturas
FROM factura;


-- 5.i. Cantidad total de recibos.

SELECT COUNT(*) AS total_recibos
FROM recibo;


-- 5.j. Cliente con mayor monto facturado.

SELECT
    c.codigo_cliente,
    c.nombre_cliente,
    SUM(f.monto) AS total_facturado
FROM cliente c
JOIN factura f
    ON c.codigo_cliente = f.codigo_cliente
GROUP BY c.codigo_cliente, c.nombre_cliente
ORDER BY total_facturado DESC
LIMIT 1;


-- 5.k. Cliente con menor monto facturado.
-- Se consideran los clientes que tienen facturas.

SELECT
    c.codigo_cliente,
    c.nombre_cliente,
    SUM(f.monto) AS total_facturado
FROM cliente c
JOIN factura f
    ON c.codigo_cliente = f.codigo_cliente
GROUP BY c.codigo_cliente, c.nombre_cliente
ORDER BY total_facturado ASC
LIMIT 1;


-- 5.l. Deuda pendiente del cliente por cada factura.

SELECT
    c.codigo_cliente,
    c.nombre_cliente,
    f.numero_factura,
    f.monto AS monto_factura,
    COALESCE(SUM(ABS(r.monto)), 0) AS total_pagado,
    f.monto - COALESCE(SUM(ABS(r.monto)), 0)
        AS deuda_pendiente
FROM cliente c
JOIN factura f
    ON c.codigo_cliente = f.codigo_cliente
LEFT JOIN recibo r
    ON f.numero_factura = r.numero_factura
GROUP BY
    c.codigo_cliente,
    c.nombre_cliente,
    f.numero_factura,
    f.monto
ORDER BY c.codigo_cliente, f.numero_factura;


-- 5.m. Deuda total del cliente.

SELECT
    c.codigo_cliente,
    c.nombre_cliente,
    COALESCE(SUM(f.monto), 0)
      - COALESCE(SUM(p.total_pagado), 0) AS deuda_total
FROM cliente c
LEFT JOIN factura f
    ON c.codigo_cliente = f.codigo_cliente
LEFT JOIN (
    SELECT
        numero_factura,
        SUM(ABS(monto)) AS total_pagado
    FROM recibo
    GROUP BY numero_factura
) p
    ON f.numero_factura = p.numero_factura
GROUP BY c.codigo_cliente, c.nombre_cliente
ORDER BY c.codigo_cliente;


-- 5.n. Monto total pagado por cliente en cada factura.

SELECT
    r.codigo_cliente,
    c.nombre_cliente,
    r.numero_factura,
    SUM(ABS(r.monto)) AS monto_total_pagado
FROM recibo r
JOIN cliente c
    ON r.codigo_cliente = c.codigo_cliente
GROUP BY
    r.codigo_cliente,
    c.nombre_cliente,
    r.numero_factura
ORDER BY r.codigo_cliente, r.numero_factura;


-- 5.o. Monto total pagado por cliente.

SELECT
    c.codigo_cliente,
    c.nombre_cliente,
    COALESCE(SUM(ABS(r.monto)), 0) AS total_pagado
FROM cliente c
LEFT JOIN recibo r
    ON c.codigo_cliente = r.codigo_cliente
GROUP BY c.codigo_cliente, c.nombre_cliente
ORDER BY c.codigo_cliente;


-- ============================================================
-- EJERCICIO 6:
-- La práctica presenta una tabla de Factura como referencia.
-- Consultar los registros actuales de la tabla Factura.
-- ============================================================

SELECT *
FROM factura
ORDER BY numero_factura;


-- ============================================================
-- EJERCICIO 7:
-- Consulta de las facturas del cliente 5 ordenadas
-- por el número de factura.
-- ============================================================

SELECT *
FROM factura
WHERE codigo_cliente = 5
ORDER BY numero_factura ASC;


-- ============================================================
-- EJERCICIO 8:
-- Adicionar los siguientes registros en la tabla Factura.
-- ============================================================

INSERT INTO factura
    (codigo_cliente, numero_factura, monto)
VALUES
    (5, 110, 1300.00),
    (5, 113, 2500.00),
    (7, 114, 8200.00),
    (7, 115, 5700.00),
    (9, 116, 4500.00),
    (9, 117, 2600.00),
    (9, 118, 3500.00);


-- Comprobar las facturas insertadas.

SELECT *
FROM factura
WHERE numero_factura IN (110, 113, 114, 115, 116, 117, 118)
ORDER BY numero_factura;


-- ============================================================
-- EJERCICIO 9:
-- Borrar las facturas del cliente 5 número 110,
-- y del cliente 9 número 118.
-- ============================================================

DELETE FROM factura
WHERE (codigo_cliente = 5 AND numero_factura = 110)
   OR (codigo_cliente = 9 AND numero_factura = 118);


-- Comprobar que las facturas fueron eliminadas.

SELECT *
FROM factura
WHERE numero_factura IN (110, 118);


-- ============================================================
-- EJERCICIO 10:
-- Actualizar el monto de la factura 114 de 8200 a 34000.
-- ============================================================

UPDATE factura
SET monto = 34000.00
WHERE numero_factura = 114
  AND codigo_cliente = 7;


-- Comprobar el monto actualizado.

SELECT *
FROM factura
WHERE numero_factura = 114;
