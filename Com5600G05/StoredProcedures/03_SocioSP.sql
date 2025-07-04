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



CREATE OR ALTER PROCEDURE Socio.CrearSocioConObraSocialExistenteYPersonaExistente
	@idPersona INT,
	@idObraSocial INT,
	@nroObraSocial VARCHAR(30),
	@nroSocio VARCHAR(10),
	@cuit VARCHAR(20) = NULL,
	@idCategoria INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Persona.Persona WHERE idPersona = @idPersona)
	BEGIN
		DECLARE @mensajePersona VARCHAR(100);
		SET @mensajePersona = 'No existe una persona con el ID ' + CAST(@idPersona AS VARCHAR);
		THROW 51000, @mensajePersona, 1;
	END

	IF NOT EXISTS (SELECT 1 FROM Socio.ObraSocial WHERE idObraSocial = @idObraSocial)
	BEGIN
		DECLARE @mensajeObraSocial VARCHAR(100);
		SET @mensajeObraSocial = 'No existe una obra social con el ID ' + @idObraSocial;
		THROW 51000, @mensajeObraSocial, 1;
	END

	INSERT INTO Socio.Socio (
		idSocio,
		nroSocio,
		idCategoria,
		idObraSocial,
		nroObraSocial,
		cuit
	)
	VALUES (
		@idPersona,
		@nroSocio,
		@idCategoria,
		@idObraSocial,
		@nroObraSocial,
		@cuit
	);
END
GO

CREATE OR ALTER PROCEDURE Socio.CrearSocioConPersonaNuevaYObraSocialExistente
	@dni INT,
	@nombre VARCHAR(50),
	@apellido VARCHAR(50),
	@email VARCHAR(255),
	@telefono VARCHAR(20),
	@telefonoEmergencia VARCHAR(20),
	@fechaNacimiento DATE,
	@idObraSocial INT,
	@nroObraSocial VARCHAR(30),
	@nroSocio VARCHAR(10),
	@idCategoria INT,
	@cuit VARCHAR(20)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @idPersona INT;
			EXEC @idPersona = Persona.CrearPersona
				@dni,
				@nombre,
				@apellido,
				@email,
				@telefono,
				@telefonoEmergencia,
				@fechaNacimiento

			IF NOT EXISTS (SELECT 1 FROM Socio.ObraSocial WHERE idObraSocial = @idObraSocial)
			BEGIN
				DECLARE @mensajeObraSocial VARCHAR(100);
				SET @mensajeObraSocial = 'No existe una obra social con el ID ' + CAST(@idObraSocial AS VARCHAR);
				THROW 51000, @mensajeObraSocial, 1;
			END

			IF EXISTS (SELECT 1 FROM Socio.Socio WHERE nroSocio = @nroSocio)
			BEGIN
				DECLARE @mensajeNroSocio VARCHAR(100);
				SET @mensajeNroSocio = 'Ya existe un socio con el numero ' + @nroSocio;
				THROW 51000, @mensajeNroSocio, 1;
			END

			IF EXISTS (SELECT 1 FROM Socio.Socio WHERE cuit = @cuit)
			BEGIN
				DECLARE @mensajeCuit VARCHAR(100);
				SET @mensajeCuit = 'Ya existe un socio con el cuit ' + @cuit;
				THROW 51000, @mensajeCuit, 1;
			END

			INSERT INTO Socio (
				idSocio,
				nroSocio,
				idCategoria,
				idObraSocial,
				nroObraSocial,
				cuit
			)
			VALUES (
				@idPersona,
				@nroSocio,
				@idCategoria,
				@idObraSocial,
				@nroObraSocial,
				@cuit
			);
			COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE Socio.CrearSocioConPersonaYObraSocialNueva
	@dni INT,
	@nombre VARCHAR(50),
	@apellido VARCHAR(50),
	@email VARCHAR(255),
	@telefono VARCHAR(20),
	@telefonoEmergencia VARCHAR(20),
	@fechaNacimiento DATE,
	@nroObraSocial VARCHAR(30),
	@nroSocio VARCHAR(10),
	@idCategoria INT,
	@cuit VARCHAR(20),
	@nombreObraSocial VARCHAR(40),
	@telefonoObraSocial VARCHAR(40)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @idPersona INT;
			EXEC @idPersona = Persona.CrearPersona
				@dni,
				@nombre,
				@apellido,
				@email,
				@telefono,
				@telefonoEmergencia,
				@fechaNacimiento;

			DECLARE @idObraSocial INT;
			EXEC @idObraSocial = Socio.CrearObraSocial
				@nombreObraSocial,
				@telefonoObraSocial;

			INSERT INTO Socio (
				idSocio,
				nroSocio,
				idCategoria,
				idObraSocial,
				nroObraSocial,
				cuit
			)
			VALUES (
				@idPersona,
				@nroSocio,
				@idCategoria,
				@idObraSocial,
				@nroObraSocial,
				@cuit
			);
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
END
GO

-- modificar socio
CREATE OR ALTER PROCEDURE Socio.ModificarSocio
	@idSocio INT,
	@nroObraSocial VARCHAR(30), -- debe coincidir con la cantidad de caracteres de la tabla
	@nroSocio VARCHAR(10), -- debe coincidir con la cantidad de caracteres de la tabla
	@idCategoria INT -- asumo que se selecciona de una lista
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Socio.Socio WHERE idSocio = @idSocio)
	BEGIN
		DECLARE @mensajeId VARCHAR(100);
		SET @mensajeId = 'No existe un socio con el id ' + CAST(@idSocio AS VARCHAR);
		THROW 51000, @mensajeId, 1;
	END

	IF NOT EXISTS (SELECT 1 FROM Socio.Categoria WHERE idCategoria = @idCategoria)
	BEGIN
		DECLARE @mensajeCategoria VARCHAR(100);
		SET @mensajeCategoria = 'No existe una categoria con el id ' + CAST(@idCategoria AS VARCHAR);
		THROW 51000, @mensajeCategoria, 1;
	END

	UPDATE Socio.Socio
	SET
		nroObraSocial = @nroObraSocial,
		nroSocio = @nroSocio,
		idCategoria = @idCategoria
	WHERE idSocio = @idSocio;
END
GO

-- Modificar Obra Social del Socio
CREATE OR ALTER PROCEDURE Socio.ModificarObraSocialSocio
	@idSocio INT,
	@idObraSocial INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Socio.Socio WHERE idSocio = @idSocio)
	BEGIN
		DECLARE @mensajeId VARCHAR(100);
		SET @mensajeId = 'No existe un socio con el id ' + CAST(@idSocio AS VARCHAR);
		THROW 51000, @mensajeId, 1;
	END

	IF NOT EXISTS (SELECT 1 FROM Socio.ObraSocial WHERE idObraSocial = @idObraSocial)
	BEGIN
		DECLARE @mensajeObraSocial VARCHAR(100);
		SET @mensajeObraSocial = 'No existe una obra social con el ID ' + CAST(@idObraSocial AS VARCHAR);
		THROW 51000, @mensajeObraSocial, 1;
	END

	UPDATE Socio.Socio
	SET idObraSocial = @idObraSocial
	WHERE idSocio = @idSocio;
END
GO

-- Eliminar socio

CREATE OR ALTER PROCEDURE Socio.EliminarSocio
	@idSocio INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Socio.Socio WHERE idSocio = @idSocio)
	BEGIN;
		THROW 51000, 'El socio que se intento eliminar no existe', 1;
	END

<<<<<<< HEAD
	IF EXISTS (SELECT 1 FROM Factura.Factura F WHERE F.idPersona = @idSocio)
=======
	IF EXISTS (SELECT 1 FROM Factura.Factura WHERE idPersona = @idSocio)
>>>>>>> 15b10a82ff39fd4b8bb722dc1bab922bc562240e
	BEGIN
		PRINT('El socio que se intento eliminar tiene facturas asociadas, se borrara logicamente');
		UPDATE Socio.Socio
		SET borrado = 1
		WHERE idSocio = @idSocio;
		RETURN;
	END

	IF EXISTS (SELECT 1 FROM Actividad.Asiste WHERE idSocio = @idSocio)
	BEGIN
		PRINT('El socio que se intento eliminar tiene asistencias registradas, se borrara logicamente');
		UPDATE Socio.Socio
		SET borrado = 1
		WHERE idSocio = @idSocio;
		RETURN;
	END

	IF EXISTS (SELECT 1 FROM Actividad.SocioRealizaActividad WHERE idSocio = @idSocio)
	BEGIN
		PRINT('El socio que se intento eliminar realiza al menos una actividad, se borrara logicamente');
		UPDATE Socio.Socio
		SET borrado = 1
		WHERE idSocio = @idSocio;
		RETURN;
	END

	IF EXISTS (SELECT 1 FROM Actividad.ActividadExtra WHERE idSocio = @idSocio)
	BEGIN
		PRINT('El socio que se intento eliminar esta registrado en una actividad extra, se borrara logicamente');
		UPDATE Socio.Socio
		SET borrado = 1
		WHERE idSocio = @idSocio;
		RETURN;
	END

	IF EXISTS (SELECT 1 FROM Actividad.InvitacionEvento WHERE idInvitado = @idSocio)
	BEGIN
		PRINT('El socio que se intento eliminar esta registrado en una en una invitacion, se borrara logicamente');
		UPDATE Socio.Socio
		SET borrado = 1
		WHERE idSocio = @idSocio;
		RETURN;
	END

	IF EXISTS (SELECT 1 FROM Socio.GrupoFamiliar WHERE idSocioTutor = @idSocio)
	BEGIN;
		THROW 51000, 'El socio que se intento eliminar es tutor en un grupo familiar', 1;
	END

	IF EXISTS (SELECT 1 FROM Socio.GrupoFamiliar WHERE idSocioMenor = @idSocio)
	BEGIN;
		THROW 51000, 'El socio que se intento eliminar es menor en un grupo familiar', 1;
	END

	DELETE FROM Socio.Socio
	WHERE idSocio = @idSocio;
END
GO
