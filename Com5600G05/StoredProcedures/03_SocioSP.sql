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
CREATE OR ALTER PROCEDURE CrearSocioConObraSocialExistenteYPersonaExistente
	@dniPersona INT,
	@nombreObraSocial VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@nroObraSocial VARCHAR(30), -- debe coincidir con la cantidad de caracteres de la tabla
	@nroSocio VARCHAR(30), -- debe coincidir con la cantidad de caracteres de la tabla
	@debitoAutomatico BIT,
	@idCategoria INT -- asumo que se selecciona de una lista
AS
BEGIN
	DECLARE @idPersona INT;
	SET @idPersona = (
		SELECT idPersona
		FROM Persona
		WHERE dni = @dniPersona
	);
	IF @idPersona IS NULL
	BEGIN
		DECLARE @mensajePersona VARCHAR(100);
		SET @mensajePersona = 'No existe una persona con el DNI ' + @dniPersona;
		THROW 51000, @mensajePersona, 1;
	END

	DECLARE @idObraSocial INT;
	SET @idObraSocial = (
		SELECT idObraSocial
		FROM ObraSocial
		WHERE nombre = @nombreObraSocial
	);
	IF @idObraSocial IS NULL
	BEGIN
		DECLARE @mensajeObraSocial VARCHAR(100);
		SET @mensajeObraSocial = 'No existe una obra social con el nombre ' + @nombreObraSocial;
		THROW 51000, @mensajeObraSocial, 1;
	END

	INSERT INTO Socio
	VALUES (
		@idPersona,
		@nroObraSocial,
		@nroSocio,
		'ACTIVO', -- esto tiene que coincidir con el del check
		@debitoAutomatico,
		@idObraSocial,
		@idCategoria
	);
END
GO

CREATE OR ALTER PROCEDURE CrearSocioConPersonaNuevaYObraSocialExistente
	@dni INT,
	@nombre VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@apellido VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@email VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@cuit VARCHAR(11),
	@telefono INT,
	@telefonoEmergencia INT,
	@fechaNacimiento DATE,
	@nombreObraSocial VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@nroObraSocial VARCHAR(30), -- debe coincidir con la cantidad de caracteres de la tabla
	@nroSocio VARCHAR(30), -- debe coincidir con la cantidad de caracteres de la tabla
	@debitoAutomatico BIT,
	@idCategoria INT -- asumo que se selecciona de una lista
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @idPersona INT;
			EXEC @idPersona = CrearPersona
				@dni,
				@nombre,
				@apellido,
				@email,
				@cuit,
				@telefono,
				@telefonoEmergencia,
				@fechaNacimiento;

			DECLARE @idObraSocial INT;
			SET @idObraSocial = (
				SELECT idObraSocial
				FROM ObraSocial
				WHERE nombre = @nombreObraSocial
			);
			IF @idObraSocial IS NULL
			BEGIN
				DECLARE @mensajeObraSocial VARCHAR(100);
				SET @mensajeObraSocial = 'No existe una obra social con el nombre ' + @nombreObraSocial;
				THROW 51000, @mensajeObraSocial, 1;
			END

			IF EXISTS (SELECT 1 FROM Socio WHERE nroSocio = @nroSocio)
			BEGIN
				DECLARE @mensajeNroSocio VARCHAR(100);
				SET @mensajeNroSocio = 'Ya existe un socio con el numero ' + @nroSocio;
				THROW 51000, @mensajeNroSocio, 1;
			END

			INSERT INTO Socio
			VALUES (
				@idPersona,
				@nroObraSocial,
				@nroSocio,
				'ACTIVO', -- esto tiene que coincidir con el del check
				@debitoAutomatico,
				@idObraSocial,
				@idCategoria
			);
			COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE CrearSocioConPersonaYObraSocialNueva
	@dni INT,
	@nombre VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@apellido VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@email VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@cuit VARCHAR(11),
	@telefono INT,
	@telefonoEmergencia INT,
	@fechaNacimiento DATE,
	@nombreObraSocial VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@telefonoObraSocial VARCHAR(50), -- debe coincidir con la cantidad de caracteres de la tabla
	@nroObraSocial VARCHAR(30), -- debe coincidir con la cantidad de caracteres de la tabla
	@nroSocio VARCHAR(30), -- debe coincidir con la cantidad de caracteres de la tabla
	@debitoAutomatico BIT,
	@idCategoria INT -- asumo que se selecciona de una lista
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @idPersona INT;
			EXEC @idPersona = CrearPersona
				@dni,
				@nombre,
				@apellido,
				@email,
				@cuit,
				@telefono,
				@telefonoEmergencia,
				@fechaNacimiento;

			DECLARE @idObraSocial INT;
			EXEC @idObraSocial = CrearObraSocial
				@nombreObraSocial,
				@telefonoObraSocial;

			INSERT INTO Socio
			VALUES (
				@idPersona,
				@nroObraSocial,
				@nroSocio,
				'ACTIVO', -- esto tiene que coincidir con el del check
				@debitoAutomatico,
				@idObraSocial,
				@idCategoria
			);
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
END
GO

-- modificar socio
CREATE OR ALTER PROCEDURE ModificarSocio
	@idSocio INT,
	@nroObraSocial VARCHAR(30), -- debe coincidir con la cantidad de caracteres de la tabla
	@nroSocio VARCHAR(30), -- debe coincidir con la cantidad de caracteres de la tabla
	@debitoAutomatico BIT,
	@idCategoria INT -- asumo que se selecciona de una lista
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Socio WHERE idSocio = @idSocio)
	BEGIN
		DECLARE @mensajeId VARCHAR(100);
		SET @mensajeId = 'No existe un socio con el id ' + CAST(@idSocio AS VARCHAR);
		THROW 51000, @mensajeId, 1;
	END

	IF NOT EXISTS (SELECT 1 FROM Categoria WHERE idCategoria = @idCategoria)
	BEGIN
		DECLARE @mensajeCategoria VARCHAR(100);
		SET @mensajeCategoria = 'No existe una categoria con el id ' + CAST(@idCategoria AS VARCHAR);
		THROW 51000, @mensajeCategoria, 1;
	END

	UPDATE Socio
	SET
		nroObraSocial = @nroObraSocial,
		nroSocio = @nroSocio,
		debitoAutomatico = @debitoAutomatico,
		idCategoria = @idCategoria
	WHERE idSocio = @idSocio;
END
GO

-- Modificar Obra Social del Socio
CREATE OR ALTER PROCEDURE ModificarObraSocialSocio
	@idSocio INT,
	@idObraSocial INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Socio WHERE idSocio = @idSocio)
	BEGIN
		DECLARE @mensajeId VARCHAR(100);
		SET @mensajeId = 'No existe un socio con el id ' + CAST(@idSocio AS VARCHAR);
		THROW 51000, @mensajeId, 1;
	END

	IF NOT EXISTS (SELECT 1 FROM ObraSocial WHERE idObraSocial = @idObraSocial)
	BEGIN
		DECLARE @mensajeObraSocial VARCHAR(100);
		SET @mensajeObraSocial = 'No existe una obra social con el ID ' + CAST(@idObraSocial AS VARCHAR);
		THROW 51000, @mensajeObraSocial, 1;
	END

	UPDATE Socio
	SET idObraSocial = @idObraSocial
	WHERE idSocio = @idSocio;
END
GO