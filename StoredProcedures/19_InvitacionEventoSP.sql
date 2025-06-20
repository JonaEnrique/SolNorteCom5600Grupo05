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

-- Crear TipoActividad
CREATE OR ALTER PROCEDURE CrearInvitacion
	@idActividadExtra INT,
	@dniInvitado INT,
	@nroSocio INT
AS
BEGIN
	-- consigo el ID del Socio asociado usando el nroSocio
	DECLARE @idSocio INT;
	SET @idSocio = (
		SELECT idSocio
		FROM Socio
		WHERE nroSocio = @nroSocio
	);

	-- consigo el ID del invitado asociado usando el DNI
	DECLARE @idInvitado INT;
	SET @idInvitado = (
		SELECT idPersona
		FROM Persona
		WHERE DNI = @dniInvitado
	);

	IF EXISTS (SELECT 1 FROM ActividadExtra WHERE idActividadExtra = @idActividadExtra)
	BEGIN
		INSERT INTO InvitacionEvento
		VALUES (
			GETDATE(),
			@idActividadExtra,
			@idInvitado,
			@idSocio
		);
	END
	ELSE
	BEGIN
		RAISERROR('No existe una actividad con el ID %d', 10, 1, @idActividadExtra);
	END
END
GO