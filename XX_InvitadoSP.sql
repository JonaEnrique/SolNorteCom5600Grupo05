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
 -- Crear Invitado
 CREATE OR ALTER PROCEDURE CrearInvitado
	@nombre VARCHAR(255),
	@apellido VARCHAR(255),
	@fechaNac DATE,
	@dni INT,
	@telefono INT,
	@email VARCHAR(255),
	@telefonoEmergencia INT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Persona.Persona WHERE dni = @dni)
	BEGIN
		RAISERROR('Ya hay una Persona registrada con el DNI %d.', 10, 1, @dni);
	END
	ELSE
	BEGIN
		INSERT INTO Persona.Persona
		VALUES (
			@nombre,
			@apellido,
			@fechaNac,
			@dni,
			@telefono,
			@email,
			@telefonoEmergencia
		);
	
		DECLARE @idPersona INT = SCOPE_IDENTITY();
		INSERT INTO Persona.Invitado
		VALUES (@idPersona);
	END
END
GO

-- Agregar Rol Invitado a Persona
CREATE OR ALTER PROCEDURE AgregarRolInvitado @dni INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Persona.Persona WHERE dni = @dni)
	BEGIN
		RAISERROR('No hay una Persona registrada con el DNI %d.', 10, 1, @dni);
		RETURN;
	END

	DECLARE @idPersonaDni INT
	SET @idPersonaDni = (
		SELECT p.idPersona
		FROM Persona.Persona p
		WHERE dni = @dni
	);

	INSERT INTO Persona.Invitado
	VALUES (@idPersonaDni);
END
GO