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
CREATE OR ALTER PROCEDURE Actividad.CrearJornada 
	@fecha DATE,
	@llovio BIT
AS
BEGIN
	DECLARE @textoFecha VARCHAR(30);
	SET @textoFecha = CAST(@fecha AS VARCHAR)

	IF EXISTS (SELECT 1 FROM Actividad.Jornada WHERE fecha = @fecha)
	BEGIN
		RAISERROR('Ya se cargo la fecha %s.', 10, 1, @textoFecha);
		RETURN;
	END

	INSERT INTO Jornada (fecha, huboLluvia)
	VALUES (@fecha, @llovio);
END
GO

-- eliminar jornada
-- solo se borran si no tienen una actividad extra asociada
CREATE OR ALTER PROCEDURE Actividad.Jornada
	@idJornada INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Actividad.Jornada WHERE idJornada = @idJornada)
	BEGIN;
		THROW 51000, 'La jornada que se intento eliminar no existe', 1;
	END

	IF EXISTS (SELECT 1 FROM Actividad.ActividadExtra WHERE idJornada = @idJornada)
	BEGIN;
		THROW 51000, 'La jornada que se intento eliminar tiene actividades extra asociadas', 1;
	END

	DELETE FROM Actividad.Jornada
	WHERE idJornada = @idJornada;
END
GO