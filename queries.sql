USE productos;

SELECT *
FROM Producto; 

-- Eliminamos NULL de producto y separamos el id del nombre

DELETE 
FROM Producto
WHERE Codigo_unico IS NULL; 


ALTER TABLE Producto
ADD ID_Producto INT,
    Nombre_Producto NVARCHAR(255)


UPDATE Producto
SET 
    ID_Producto = LEFT(Codigo_unico, CHARINDEX(' ', Codigo_unico) - 1),
    Nombre_Producto = LTRIM(SUBSTRING(Codigo_unico, CHARINDEX(' ', Codigo_unico), LEN(Codigo_unico)))


ALTER TABLE Producto
DROP COLUMN Codigo_unico
-- -------------------------------------------
SELECT *
FROM Vendedor; 

-- Eliminamos NULL utilizadno el ID 
DELETE FROM Vendedor
WHERE ID_Vendedor IS NULL; 

-- ---------------------------------------------
SELECT *
FROM Ventas;

-- Eliminamos columna6 que tiene todos null 
ALTER TABLE Ventas
DROP COLUMN column6; 

-- ----------------
SELECT *
FROM Cliente; -- No necesita limpieza 

-- Paso 1: Renombrar la columna
EXEC sp_rename 'Cliente.Codigo', 'ID_Cliente', 'COLUMN';

-- Paso 2: Agregar Primary Key
ALTER TABLE Cliente
ADD CONSTRAINT PK_Cliente PRIMARY KEY (ID_Cliente);



--. Relacionamos cliente y ventas 

ALTER TABLE Ventas
ADD CONSTRAINT FK_Ventas_Cliente FOREIGN KEY (ID_Cliente)
REFERENCES Cliente (ID_Cliente);


-- ---------- Cambiamos tipos de datos (ventas)------------

-- Cambiar el tipo en Cliente con NOT NULL
ALTER TABLE Cliente ALTER COLUMN ID_Cliente INT NOT NULL;

-- Volver a crear la PK
ALTER TABLE Cliente
ADD CONSTRAINT PK_Cliente PRIMARY KEY (ID_Cliente);

-- Volver a crear la FK
ALTER TABLE Ventas
ADD CONSTRAINT FK_Ventas_Cliente FOREIGN KEY (ID_Cliente)
REFERENCES Cliente (ID_Cliente);


-- IDs a INT
ALTER TABLE Ventas ALTER COLUMN ID_Venta INT NOT NULL;
ALTER TABLE Ventas ALTER COLUMN ID_Prod INT;
ALTER TABLE Ventas ALTER COLUMN ID_Ubicación INT;
ALTER TABLE Ventas ALTER COLUMN ID_Codigo_Pago INT;
ALTER TABLE Ventas ALTER COLUMN ID_Vendedor INT;

-- Dinero y cantidades a DECIMAL/INT
ALTER TABLE Ventas ALTER COLUMN Valor_Unidad DECIMAL(10,2);
ALTER TABLE Ventas ALTER COLUMN Cantidad INT;
ALTER TABLE Ventas ALTER COLUMN Costos_Directos DECIMAL(10,2);
ALTER TABLE Ventas ALTER COLUMN Costos_Indirectos DECIMAL(10,2);


---- Consultas 

/*
Extraiga el nombre del cliente, la fecha de la compra y el total de la venta.
*/

SELECT 
    c.Nombre_completo AS Nombre_cliente,
    v.Fecha_compra AS Fecha_compra,
    SUM(v.Cantidad * v.Valor_Unidad) AS total_vent
FROM Cliente c 
JOIN Ventas v
    ON c.ID_Cliente = v.ID_Cliente
GROUP BY c.Nombre_completo, v.Fecha_compra
ORDER BY v.Fecha_compra DESC; 

/*
Filtre las ventas realizadas en los últimos 30 días.
*/

SELECT Fecha_compra
FROM Ventas
WHERE Fecha_compra BETWEEN '2019-11-01' AND '2019-12-01'
ORDER BY Fecha_compra DESC;

SELECT Fecha_compra
FROM Ventas
WHERE Fecha_compra >= DATEADD(DAY, -30, GETDATE())
ORDER BY Fecha_compra DESC;


-- -------------  EDA (Exploratory Data Analysis)-----

-- Fechas min max

SELECT 
    MIN(Fecha_compra) AS min_fecha,
    MAX(Fecha_compra) AS max_fecha
FROM Ventas

-- Cantidad de registros por tabla

SELECT 
    COUNT(ID_Cliente) AS Total_filas
FROM Cliente;

SELECT 
    COUNT(ID_Venta) AS Total_filas
FROM Ventas;

-- Estadisticas basicas de ventas----

SELECT 
   MIN(Valor_Unidad) AS min_valor,
   MAX(Valor_Unidad)AS max_valor,
   AVG(Valor_Unidad) AS promedio_valor
FROM Ventas;

-- Clientes unicos

SELECT 
    COUNT(DISTINCT ID_Venta) AS cant_cliente_unico
FROM Ventas;

-- Verificar NULL-- 

SELECT 
    COUNT(ID_Venta) AS nulos_id
FROM Ventas
WHERE ID_Venta IS NULL; 

SELECT COUNT(ID_Cliente) AS nulos_id_cliente
FROM Ventas 
WHERE ID_Cliente IS NULL;

SELECT COUNT(Fecha_compra) AS nulos_fecha 
FROM Ventas 
WHERE Fecha_compra IS NULL;

SELECT COUNT(Valor_Unidad) AS nulos_valor 
FROM Ventas 
WHERE Valor_Unidad IS NULL;

-- Clientes duplicados

SELECT
    Nombre_completo,
    COUNT(ID_Cliente) Cantidad_duplicado
FROM Cliente
GROUP BY Nombre_completo
HAVING COUNT(ID_Cliente) > 1; 


-- Cuántas compras hizo cada cliente 

SELECT 
    c.Nombre_completo,
    COUNT(v.ID_Venta) Cantidad
FROM Cliente c 
JOIN Ventas v 
    ON c.ID_Cliente = v.ID_Cliente
GROUP BY c.Nombre_completo
ORDER BY Cantidad DESC;

-- Clientes que más gastaron

SELECT 
    c.ID_Cliente,
    c.Nombre_completo,
    SUM(v.Cantidad * v.Valor_Unidad) AS Total_gastado
FROM Cliente c
JOIN Ventas v
    ON c.ID_Cliente = v.ID_Cliente
GROUP BY c.ID_Cliente, c.Nombre_completo
ORDER BY Total_gastado DESC;

-- Total facturado---

SELECT 
    SUM(Cantidad * Valor_Unidad) AS Total_facturado
FROM Ventas; 


-- Total facturado por mes

SELECT 
    YEAR(Fecha_compra) AS año,
    MONTH(Fecha_compra) AS mes,
    SUM(Cantidad * Valor_Unidad) AS Total_facturado
FROM Ventas
GROUP BY YEAR(Fecha_compra), MONTH(Fecha_compra)
ORDER BY mes, año; 

