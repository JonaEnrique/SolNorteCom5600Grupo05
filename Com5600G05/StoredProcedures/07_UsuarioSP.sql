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

-- Crear asignarle un usuario a una persona ya registrada
CREATE OR ALTER PROCEDURE CrearUsuarioConPersonaExistente
	@dniPersona INT,
	@usuario VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@contraseña VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@fechaRenovar DATE,
	@idRol INT -- supongo que lo selecciono de una lista
AS
BEGIN
	DECLARE @idPersona INT;
	SET @idPersona = (
		SELECT idPersona
		FROM Persona
		WHERE dni = @dni
	);

	IF @idPersona IS NOT NULL
	BEGIN
		DECLARE @mensajePersona VARCHAR(100);
		SET @mensajePersona = 'No existe una persona con el DNI ' + CAST(@dni AS VARCHAR);
		THROW 51000, @mensajePersona, 1;
	END

	IF EXISTS (SELECT 1 FROM Usuario WHERE usuario = @usuario)
	BEGIN
		DECLARE @mensajeUsuario VARCHAR(100);
		SET @mensajeUsuario = 'El nombre de usuario ' + @usuario + ' ya esta en uso';
		THROW 51000, @mensajeUsuario, 1;
	END

	IF NOT EXISTS (SELECT 1 FROM Rol WHERE idRol = @idRol)
	BEGIN;
		THROW 51000, 'La el rol seleccionado es invalido', 1;
	END

	INSERT INTO Usuario
	VALUES (
		@idPersona,
		@usuario,
		@contraseña,
		@fechaRenovar,
		@idRol
	);

	-- esto puede ser innecesario
	RETURN SCOPE_IDENTITY()
END
GO

-- crear un usuario y una persona nueva en el proceso
CREATE OR ALTER PROCEDURE CrearUsuarioConPersonaNueva
	@dni INT,
	@nombre VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@apellido VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@email VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@cuit VARCHAR(11),
	@telefono INT,
	@telefonoEmergencia INT,
	@fechaNacimiento DATE,
	@usuario VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@contraseña VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@fechaRenovar DATE,
	@idRol INT -- supongo que lo selecciono de una lista
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

			IF NOT EXISTS (SELECT 1 FROM Rol WHERE idRol = @idRol)
			BEGIN;
				THROW 51000, 'La el rol seleccionado es invalido', 1;
			END

			IF EXISTS (SELECT 1 FROM Usuario WHERE usuario = @usuario)
			BEGIN
				DECLARE @mensajeUsuario VARCHAR(100);
				SET @mensajeUsuario = 'El nombre de usuario ' + @usuario + ' ya esta en uso';
				THROW 51000, @mensajeUsuario, 1;
			END

			INSERT INTO Usuario
			VALUES (
				@idPersona,
				@usuario,
				@contraseña,
				@fechaRenovar,
				@idRol
			);
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
END
GO

-- modificar usuario
CREATE OR ALTER PROCEDURE ModificarUsuario
	@idUsuario INT,
	@usuario VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@contraseña VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@fechaRenovar DATE,
	@idRol INT -- supongo que lo selecciono de una lista
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Usuario WHERE idUsuario = @idUsuario)
	BEGIN
		DECLARE @mensajeId VARCHAR(100);
		SET @mensajeId = 'No existe un usuario con el ID ' + CAST(@idUsuario AS VARCHAR);
		THROW 51000, @mensajeId, 1;
	END

	IF EXISTS (SELECT 1 FROM Usuario WHERE usuario = @usuario AND idUsuario <> @idUsuario)
	BEGIN
		DECLARE @mensajeUsuario VARCHAR(100);
		SET @mensajeUsuario = 'El nombre de usuario ' + @usuario + ' ya esta en uso';
		THROW 51000, @mensajeUsuario, 1;
	END

	IF NOT EXISTS (SELECT 1 FROM Rol WHERE idRol = @idRol)
	BEGIN
		DECLARE @mensajeRol VARCHAR(100);
		SET @mensajeRol = 'No existe el ID de rol ' + @idRol;
		THROW 51000, @mensajeRol, 1;
	END

	UPDATE Usuario
	SET
		usuario = @usuario,
		contraseña = @contraseña,
		fechaRenovar = @fechaRenovar,
		idRol = @idRol
	WHERE idUsuario = @idUsuario;
END
GO