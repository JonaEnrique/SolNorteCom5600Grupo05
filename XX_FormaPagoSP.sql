/*
	Fecha: 23/05/2025
	Grupo: 05
	Materia: Bases de Datos Aplicada
	Nicolas Perez 40015709
	Santiago Sanchez 42281463
	Jonathan Enrique 43301711
	Teo Turri 42819058

	Genere store procedures para manejar la inserción, modificado, borrado (si corresponde,
	también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.
	Los nombres de los store procedures NO deben comenzar con “SP”. 
*/

USE Com5600G05
GO

-- Crear FormaPago

CREATE OR ALTER PROCEDURE CrearFormaPago @formaNueva VARCHAR(255)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Pago.FormaPago WHERE nombre = @formaNueva)
	BEGIN
		RAISERROR('La forma de pago %s ya existe.', 10, 1, @formaNueva);
	END
	ELSE
	BEGIN
		INSERT INTO Pago.FormaPago
		VALUES (@formaNueva);
	END
END
GO