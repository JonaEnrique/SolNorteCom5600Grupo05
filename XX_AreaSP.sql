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

-- Crear Area
CREATE OR ALTER PROCEDURE CrearArea @areaNueva VARCHAR(100)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Usuario.Area WHERE nombre = @areaNueva)
	BEGIN
		RAISERROR('El area %s ya existe.', 10, 1, @areaNueva);
	END
	ELSE
	BEGIN
		INSERT INTO Usuario.Area
		VALUES (@areaNueva);
	END
END
GO