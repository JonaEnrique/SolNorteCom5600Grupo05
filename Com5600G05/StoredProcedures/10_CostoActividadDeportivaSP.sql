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

CREATE OR ALTER PROCEDURE Actividad.CrearCostoActividadDeportiva
	@precio DECIMAL(10, 2),
	@fechaVigencia DATE,
	@idActividadDeportiva INT
AS
BEGIN
	IF @precio <= 0
	BEGIN;
		THROW 51000, 'El precio debe ser positivo', 1;
	END

	-- verifico que exista el ID de la actividad seleccionada
	IF NOT EXISTS (SELECT 1 FROM Actividad.ActividadDeportiva WHERE idActividadDeportiva = @idActividadDeportiva)
	BEGIN
		DECLARE @mensajeActividad VARCHAR(100);
		SET @mensajeActividad = 'No existe actividad deportiva con el ID ' + CAST(@idActividadDeportiva AS VARCHAR);
		THROW 51000, @mensajeActividad, 1;
	END

	INSERT INTO Actividad.CostoActividadDeportiva (
		precio,
		fechaVigencia,
		idActividadDeportiva
	)
	VALUES (
		@precio,
		@fechaVigencia,
		@idActividadDeportiva
	);
END
GO
-- no se modifica, se hace uno nuevo

--POR SI IMPLEMENTAMOS OTRA LOGICA
CREATE OR ALTER PROCEDURE Actividad.ModificarCostoActividadDeportiva
	@idCostoActividadDertiva INT,
	@fechaVigencia DATE,
	@precio DECIMAL(10, 2)
AS
BEGIN
	IF NOT EXISTS(SELECT 1 FROM Actividad.CostoActividadDeportiva WHERE idCostoActividadDeportiva = @idCostoActividadDertiva)
	BEGIN
		RAISERROR('ID: %d no existente en tabla CostoActividadDeportiva',16,1,@idCostoActividadDertiva);
	END
	UPDATE Actividad.CostoActividadDeportiva 
	SET
	fechaVigencia = @fechaVigencia,
	precio = @precio
	WHERE idCostoActividadDeportiva = @idCostoActividadDertiva;
END
GO

CREATE OR ALTER PROCEDURE Actividad.EliminarCostoActividadDeportiva
	@idCostoActividadDertiva INT
AS
BEGIN
	IF NOT EXISTS(SELECT 1 FROM Actividad.CostoActividadDeportiva WHERE idCostoActividadDeportiva = @idCostoActividadDertiva)
	BEGIN
		RAISERROR('ID: %d no existente en tabla CostoActividadDeportiva',16,1,@idCostoActividadDertiva);
	END
	DELETE Actividad.CostoActividadDeportiva WHERE idCostoActividadDeportiva = @idCostoActividadDertiva;
END
GO