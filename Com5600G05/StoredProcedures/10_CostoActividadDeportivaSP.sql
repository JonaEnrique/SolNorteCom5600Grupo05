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

CREATE OR ALTER PROCEDURE CrearCostoActividadDeportiva
	@precio DECIMAL(10, 2), -- debe coincidir con la cantidad de decimales de la tabla
	@fechaVigencia DATE,
	@idActividadDeportiva INT -- seleccionada de una lista
AS
BEGIN
	IF @precio <= 0
	BEGIN;
		THROW 51000, 'El precio debe ser positivo', 1;
	END

	-- verifico que exista el ID de la actividad seleccionada
	IF NOT EXISTS (SELECT 1 FROM ActividadDeportiva WHERE idActividad = @idActividadDeportiva)
	BEGIN
		DECLARE @mensajeActividad VARCHAR(100);
		SET @mensajeActividad = 'No existe actividad deportiva con el ID ' + CAST(@idActividadDeportiva AS VARCHAR);
		THROW 51000, @mensajeActividad, 1;
	END

	INSERT INTO CostoActividadDeportiva
	VALUES (
		@precio,
		@fechaVigencia,
		@idActividadDeportiva
	);
END

-- no se modifica, se hace una nueva