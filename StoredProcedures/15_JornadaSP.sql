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

-- Crear Jornada
CREATE OR ALTER PROCEDURE CrearJornada 
	@fecha DATE,
	@llovio BIT
AS
BEGIN
	DECLARE @textoFecha VARCHAR(30);
	SET @textoFecha = CAST(@fecha AS VARCHAR)

	IF EXISTS (SELECT 1 FROM Jornada WHERE fecha = @fecha)
	BEGIN
		RAISERROR('Ya se cargo la fecha %s.', 10, 1, @textoFecha);
	END
	ELSE
	BEGIN
		INSERT INTO Jornada
		VALUES (@fecha, @llovio);
	END
END
GO