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

-- Crear Colonia
CREATE OR ALTER PROCEDURE CrearColonia
	@nombre VARCHAR(255),
	@precio DECIMAL(19, 2),
	@fechaInicio DATE,
	@fechaFin DATE,
	@descripcion VARCHAR(255),
	@añoVerano INT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM ActExtra.Colonia WHERE nombre = @nombre)
	BEGIN
		RAISERROR('Ya existe una colonia con el nombre %s.', 10, 1, @nombre);
	END
	ELSE
	BEGIN
		INSERT INTO ActExtra.Colonia
		VALUES (
			@nombre,
			@precio,
			@fechaInicio,
			@fechaFin,
			@descripcion,
			@añoVerano
		);
	END
END
GO