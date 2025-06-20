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

-- Crear persona
CREATE OR ALTER PROCEDURE Persona.CrearPersona
	@dni INT,
	@nombre VARCHAR(50),
	@apellido VARCHAR(50),
	@email VARCHAR(255),
	@telefono VARCHAR(20),
	@telefonoEmergencia VARCHAR(20),
	@fechaNacimiento DATE
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Persona.Persona WHERE dni = @dni)
	BEGIN
		DECLARE @mensajeDni VARCHAR(100);
		SET @mensajeDni = 'Ya existe una persona con el DNI ' + @dni;
		THROW 51000, @mensajeDni, 1;
	END

	-- esto tal vez deberia ir en una funcion
	IF NOT (@email LIKE '%_@%_.%_')
	BEGIN;
		THROW 51000, 'El formato del email es invalido', 1;
	END

	INSERT INTO Persona.Persona (
		nombre,
		apellido,
		fechaNac,
		dni,
		telefono,
		telefonoEmergencia,
		email
	)
	VALUES (
		@nombre,
		@apellido,
		@fechaNacimiento,
		@dni,
		@telefono,
		@telefonoEmergencia,
		@email
	);

	RETURN SCOPE_IDENTITY();
END
GO

-- modificar persona
CREATE OR ALTER PROCEDURE Persona.ModificarPersona
	@idPersona INT,
	@dni INT,
	@nombre VARCHAR(50),
	@apellido VARCHAR(50),
	@email VARCHAR(255),
	@telefono VARCHAR(20),
	@telefonoEmergencia VARCHAR(20),
	@fechaNacimiento DATE
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Persona.Persona WHERE idPersona = @idPersona)
	BEGIN
		DECLARE @mensajeId VARCHAR(100);
		SET @mensajeId = 'No existe una persona con el ID ' + @idPersona;
		THROW 51000, @mensajeId, 1;
	END

	IF EXISTS (SELECT 1 FROM Persona.Persona WHERE dni = @dni AND idPersona <> @idPersona)
	BEGIN
		DECLARE @mensajeDni VARCHAR(100);
		SET @mensajeDni = 'Ya existe otra persona con el DNI ' + @dni;
		THROW 51000, @mensajeDni, 1;
	END

	-- esto tal vez deberia ir en una funcion
	IF NOT (@email LIKE '%_@%_.%_')
	BEGIN;
		THROW 51000, 'El formato del email es invalido', 1;
	END

	UPDATE Persona.Persona
	SET 
		dni = @dni,
		nombre = @nombre,
		apellido = @apellido,
		email = @email,
		telefono = @telefono,
		telefonoEmergencia = @telefonoEmergencia,
		fechaNac = @fechaNacimiento
	WHERE idPersona = @idPersona
END
GO