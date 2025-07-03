/*
    ---------------------------------------------------------------------
    -Fecha: 03/07/2025
    -Grupo: 05
    -Materia: Bases de Datos Aplicada

    - Integrantes:
        - Nicol�s P�rez       | 40015709
        - Santiago S�nchez    | 42281463
        - Jonathan Enrique    | 43301711
        - Teo Turri           | 42819058

    - Consigna: 
        Insersion de datos basicos como: Categorias, Actividades Deportivas, Formas de Pago.
    ---------------------------------------------------------------------
*/

USE Com5600G05;
GO

SET NOCOUNT, XACT_ABORT ON;

BEGIN TRY
	BEGIN TRAN;

	--------------------------------------------------------------------------------
	-- 1) CARGA DE ACTIVIDADES DEPORTIVAS
	--------------------------------------------------------------------------------
	INSERT INTO Actividad.ActividadDeportiva (nombre)
	SELECT v.nombre
	FROM (VALUES
		('Futsal'),
		('V�ley'),
		('Taekwondo'),
		('Baile art�stico'),
		('Nataci�n'),
		('Ajedrez')
	) AS v(nombre)
	WHERE NOT EXISTS (
		SELECT 1
		FROM Actividad.ActividadDeportiva d
		WHERE d.nombre = v.nombre
	);
	


	--------------------------------------------------------------------------------
	-- 2) CARGA DE CATEGOR�AS DE EDAD
	--------------------------------------------------------------------------------
	INSERT INTO Socio.Categoria (nombre, edadMinima, edadMaxima)
	SELECT 
		v.nombre,
		v.edadMinima,
		v.edadMaxima
	FROM (VALUES
		('Menor',  NULL, 12),   -- Hasta 12 a�os inclusive
		('Cadete', 13,   17),   -- De 13 a 17 a�os
		('Mayor',  18,   NULL)  -- Desde 18 a�os en adelante
	) AS v(nombre, edadMinima, edadMaxima)
	WHERE NOT EXISTS (
		SELECT 1
		FROM Socio.Categoria c
		WHERE c.nombre = v.nombre
	);
	


	--------------------------------------------------------------------------------
	-- 3) CARGA DE FORMAS DE PAGO
	--------------------------------------------------------------------------------
	INSERT INTO Pago.FormaPago (nombre)
	SELECT v.nombre
	FROM (VALUES
		('efectivo'),
		('Visa'),
		('MasterCard'),
		('Tarjeta Naranja'),
		('Pago F�cil'),
		('Rapipago'),
		('Transferencia Mercado Pago')
	) AS v(nombre)
	WHERE NOT EXISTS (
		SELECT 1
		FROM Pago.FormaPago f
		WHERE f.nombre = v.nombre
	);
	

	COMMIT;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
        ROLLBACK;

	DECLARE @msg VARCHAR(4000) = ERROR_MESSAGE();

	THROW 70000, @msg, 1;
END CATCH;
