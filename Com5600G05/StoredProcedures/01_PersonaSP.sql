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

-- Crear Rol
CREATE OR ALTER PROCEDURE CrearPersona
	@dni INT,
	@nombre VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@apellido VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@email VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@cuit VARCHAR(11),
	@telefono INT,
	@telefonoEmergencia INT,
	@fechaNacimiento DATE
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Persona WHERE dni = @dni)
	BEGIN
		DECLARE @mensajeDni VARCHAR(100);
		SET @mensajeDni = 'Ya existe una persona con el DNI ' + @dni;
		THROW 51000, @mensajeDni, 1;
	END

	IF EXISTS (SELECT 1 FROM Persona WHERE cuit = @cuit)
	BEGIN
		DECLARE @mensajeCuit VARCHAR(100);
		SET @mensajeCuit = 'ya existe una persona con el CUIT ' + @cuit;
		THROW 51000, @mensajeCuit, 1;
	END

	DECLARE @dniCUIT INT = CAST(SUBSTRING(@cuit, 3, 8) AS INT);
	IF NOT (@dni = @dniCUIT)
	BEGIN;
		THROW 51000, 'El DNI no coincide con el CUIT', 1;
	END

	-- esto tal vez deberia ir en una funcion
	IF NOT (@email LIKE '%_@%_.%_')
	BEGIN;
		THROW 51000, 'El formato del email es invalido', 1;
	END

	INSERT INTO Persona
	VALUES (
		@dni,
		@nombre,
		@apellido,
		@email,
		@cuit,
		@telefono,
		@telefonoEmergencia,
		@fechaNacimiento,
		0
	);

	RETURN SCOPE_IDENTITY();
END
GO

-- modificar persona
CREATE OR ALTER PROCEDURE ModificarPersona
	@idPersona INT,
	@dni INT,
	@nombre VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@apellido VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@email VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@cuit VARCHAR(11),
	@telefono INT,
	@telefonoEmergencia INT,
	@fechaNacimiento DATE
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Persona WHERE idPersona = @idPersona)
	BEGIN
		DECLARE @mensajeId VARCHAR(100);
		SET @mensajeId = 'No existe una persona con el ID ' + @idPersona;
		THROW 51000, @mensajeId, 1;
	END

	IF EXISTS (SELECT 1 FROM Persona WHERE dni = @dni AND idPersona <> @idPersona)
	BEGIN
		DECLARE @mensajeDni VARCHAR(100);
		SET @mensajeDni = 'Ya existe otra persona con el DNI ' + @dni;
		THROW 51000, @mensajeDni, 1;
	END

	IF EXISTS (SELECT 1 FROM Persona WHERE cuit = @cuit AND idPersona <> @idPersona)
	BEGIN
		DECLARE @mensajeCuit VARCHAR(100);
		SET @mensajeCuit = 'ya existe otra persona con el CUIT ' + @cuit;
		THROW 51000, @mensajeCuit, 1;
	END

	DECLARE @dniCUIT INT = CAST(SUBSTRING(@cuit, 3, 8) AS INT);
	IF NOT (@dni = @dniCUIT)
	BEGIN;
		THROW 51000, 'El DNI no coincide con el CUIT', 1;
	END

	-- esto tal vez deberia ir en una funcion
	IF NOT (@email LIKE '%_@%_.%_')
	BEGIN;
		THROW 51000, 'El formato del email es invalido', 1;
	END

	UPDATE Persona
	SET 
		dni = @dni,
		nombre = @nombre,
		apellido = @apellido,
		email = @email,
		cuit = @cuit,
		telefono = @telefono,
		telefonoEmergencia = @telefonoEmergencia,
		fechaNacimiento = @fechaNacimiento
	WHERE idPersona = @idPersona
END
GO