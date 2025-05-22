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

-- Crear Usuario
CREATE OR ALTER PROCEDURE CrearUsuario
	@nombre VARCHAR(255),
	@apellido VARCHAR(255),
	@fechaNac DATE,
	@dni INT,
	@telefono INT,
	@email VARCHAR(255),
	@telefonoEmergencia INT,
	@nombreUsuario VARCHAR(255),
	@contraseña VARCHAR(255),
	@fechaUltimaRenovacion DATE,
	@fechaARenovar DATE
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Persona.Persona WHERE dni = @dni)
	BEGIN
		RAISERROR('Ya se registro un usuario con el DNI %d.', 10, 1, @dni);
		RETURN;
	END
	IF EXISTS (SELECT 1 FROM Usuario.Usuario WHERE nombre = @nombreUsuario)
	BEGIN
		RAISERROR('El nombre de usuario %s ya esta en uso.', 10, 1, @nombreUsuario);
		RETURN;
	END

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

	DECLARE @idPersonaNueva INT = SCOPE_IDENTITY();

	INSERT INTO Usuario.Usuario
	VALUES (
		@idPersonaNueva,
		@nombreUsuario,
		@contraseña,
		@fechaUltimaRenovacion,
		@fechaARenovar
	);
END
GO

-- Agregar Rol Usuario a Persona
CREATE PROCEDURE AgregarRolUsuario
	@dni INT,
	@nombreUsuario VARCHAR(255),
	@contraseña VARCHAR(255),
	@fechaUltimaRenovacion DATE,
	@fechaARenovar DATE
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Persona.Persona WHERE dni = @dni)
	BEGIN
		RAISERROR('No hay persona registrada con el DNI %d.', 10, 1, @dni);
		RETURN;
	END

	DECLARE @idPersonaDni INT;
	SET @idPersonaDni = (
		SELECT p.idPersona
		FROM Persona.Persona p
		WHERE p.dni = @dni	
	);
	IF EXISTS(SELECT 1 FROM Usuario.Usuario WHERE idUsuario = @idPersonaDni)
	BEGIN
		RAISERROR('La persona ya esta registrada como Usuario.', 10, 1);
		RETURN;
	END
	INSERT INTO Usuario.Usuario
	VALUES (
		@idPersonaDni,
		@dni,
		@nombreUsuario,
		@contraseña,
		NULL,
		@fechaARenovar
	);
END
GO