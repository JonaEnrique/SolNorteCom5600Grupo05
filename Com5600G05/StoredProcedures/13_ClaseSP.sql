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

-- Crear Clase
CREATE OR ALTER PROCEDURE Actividad.CrearActividadDeportivaSinCosto
	@fecha DATE,
	@profesor VARCHAR(100), -- tiene que coincidir con la cantidad de caracteres de la tabla
	@idActividad INT -- asumo que lo selecciono de una lista desplegable
AS
BEGIN
	IF EXISTS (
		SELECT 1
		FROM Actividad.Clase
		WHERE
			fecha = @fecha AND
			profesor = @profesor AND
			idActividadDeportiva = @idActividad
	)
	BEGIN
		DECLARE @textoFecha VARCHAR(12) = CAST(@fecha AS VARCHAR);
		DECLARE @nombreActividadDeportiva VARCHAR(100)
		SET @nombreActividadDeportiva = (
			SELECT nombre
			FROM Actividad.ActividadDeportiva
			WHERE idActividadDeportiva = @idActividad
		);
		RAISERROR(
			'Ya existe una clase en la fecha %s con el profesor %s de la actividad %s', 
			10, 1,
			@textoFecha, @profesor, @nombreActividadDeportiva
		);
	END
	ELSE
	BEGIN
		INSERT INTO Actividad.Clase (
			fecha,
			profesor,
			idActividadDeportiva
		)
		VALUES (
			@fecha,
			@profesor,
			@idActividad
		);
	END
END
GO

-- no se modifica una vez creada