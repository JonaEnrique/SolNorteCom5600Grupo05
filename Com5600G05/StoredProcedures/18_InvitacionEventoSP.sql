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

-- Crear invitacion a evento
CREATE OR ALTER PROCEDURE Actividad.CrearInvitacion
	@fechaInvitacion DATE,
	@idActividadExtra INT,
	@idInvitado INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Actividad.ActividadExtra WHERE idActividadExtra = @idActividadExtra)
	BEGIN
		RAISERROR('No existe una actividad extra con el ID %d', 10, 1, @idActividadExtra);
		RETURN;
	END

	IF NOT EXISTS (SELECT 1 FROM Persona.Persona WHERE idPersona = @idInvitado)
	BEGIN
		RAISERROR('No existe una persona con el ID %d', 10, 1, @idInvitado);
		RETURN;
	END

	IF @fechaInvitacion < GETDATE()
	BEGIN
		RAISERROR('La fecha de la invitacion no puede ser previa a la fecha de hoy', 10, 1);
		RETURN;
	END

	INSERT INTO Actividad.InvitacionEvento (
		fechaInvitacion,
		idInvitado,
		idActExtra
	)
	VALUES (
		@fechaInvitacion,
		@idInvitado,
		@idActividadExtra
	);
END
GO