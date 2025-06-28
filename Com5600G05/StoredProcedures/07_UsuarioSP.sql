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
CREATE OR ALTER PROCEDURE Usuario.CrearUsuarioConPersonaExistente
	@idPersona INT,
	@nombre VARCHAR(30),
	@contraseña VARCHAR(64),
	@fechaRenovar DATE,
	@idRol INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Persona.Persona WHERE idPersona = @idPersona)
	BEGIN
		DECLARE @mensajePersona VARCHAR(100);
		SET @mensajePersona = 'No existe una persona con el ID ' + CAST(@idPersona AS VARCHAR);
		THROW 51000, @mensajePersona, 1;
	END

	IF EXISTS (SELECT 1 FROM Usuario.Usuario WHERE nombre = @nombre)
	BEGIN
		DECLARE @mensajeNombre VARCHAR(100);
		SET @mensajeNombre = 'El nombre de usuario ' + @nombre + ' ya esta en uso';
		THROW 51000, @mensajeNombre, 1;
	END

	IF NOT EXISTS (SELECT 1 FROM Rol WHERE idRol = @idRol)
	BEGIN;
		THROW 51000, 'el rol seleccionado es invalido', 1;
	END

	INSERT INTO Usuario (
		nombre,
		contraseña,
		fechaUltimaRenovacion,
		fechaARenovar,
		idPersona,
		idRol
	)
	VALUES (
		@nombre,
		@contraseña,
		GETDATE(),
		@fechaRenovar,
		@idPersona,
		@idRol
	);
END
GO

-- modificar usuario
CREATE OR ALTER PROCEDURE Usuario.ModificarUsuario
	@idUsuario INT,
	@nombre VARCHAR(100),
	@contraseña VARCHAR(64),
	@fechaRenovar DATE,
	@idRol INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Usuario.Usuario WHERE idUsuario = @idUsuario)
	BEGIN
		DECLARE @mensajeId VARCHAR(100);
		SET @mensajeId = 'No existe un usuario con el ID ' + CAST(@idUsuario AS VARCHAR);
		THROW 51000, @mensajeId, 1;
	END

	IF EXISTS (SELECT 1 FROM Usuario WHERE nombre = @nombre AND idUsuario <> @idUsuario)
	BEGIN
		DECLARE @mensajeUsuario VARCHAR(100);
		SET @mensajeUsuario = 'El nombre de usuario ' + @nombre + ' ya esta en uso';
		THROW 51000, @mensajeUsuario, 1;
	END

	IF NOT EXISTS (SELECT 1 FROM Usuario.Rol WHERE idRol = @idRol)
	BEGIN
		DECLARE @mensajeRol VARCHAR(100);
		SET @mensajeRol = 'No existe el ID de rol ' + @idRol;
		THROW 51000, @mensajeRol, 1;
	END

	UPDATE Usuario.Usuario
	SET
		nombre = @nombre,
		contraseña = @contraseña,
		fechaUltimaRenovacion = GETDATE(),
		fechaARenovar = @fechaRenovar,
		idRol = @idRol
	WHERE idUsuario = @idUsuario;
END
GO

-- eliminar usuario
CREATE OR ALTER PROCEDURE Usuario.EliminarUsuario
	@idUsuario INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Usuario.Usuario WHERE idUsuario = @idUsuario)
	BEGIN;
		THROW 51000, 'El usuario que se intento eliminar no existe', 1;
	END

	DELETE FROM Usuario.Usuario
	WHERE idUsuario = @idUsuario;
END
GO