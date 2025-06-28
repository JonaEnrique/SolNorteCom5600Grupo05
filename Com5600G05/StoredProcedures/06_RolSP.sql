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
CREATE OR ALTER PROCEDURE Usuario.CrearRol
	@nombreRol VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@area VARCHAR(100) -- debe coincidir con la cantidad de caracteres de la tabla y con las areas del check
AS
BEGIN
	-- supongo que la combinacion rol y area es unique
	IF EXISTS (SELECT 1 FROM Usuario.Rol WHERE nombre = @nombreRol AND area = @area)
	BEGIN
		DECLARE @mensaje VARCHAR(100);
		SET @mensaje = 'Ya existe el rol ' + @nombreRol + ' en el area ' + @area;
		THROW 51000, @mensaje, 1;
	END

	INSERT INTO Rol (
		nombre,
		area
	)
	VALUES (
		@nombreRol,
		@area
	);
END
GO

-- modificar rol
CREATE OR ALTER PROCEDURE Usuario.ModificarRol
	@idRol INT,
	@nombreRol VARCHAR(100),
	@area VARCHAR(100)
AS
BEGIN
	--NO EXISTE EL ID_ROL INGRESADO
	IF NOT EXISTS (SELECT 1 FROM Usuario.Rol  R WHERE R.idRol = @idRol )
	BEGIN
		RAISERROR('Error: El idRol %d no es válido.', 16, 1, @idRol);
	END

	-- supongo que la combinacion rol y area es unique
	IF EXISTS (SELECT 1 FROM Usuario.Rol WHERE nombre = @nombreRol AND area = @area)
	BEGIN
		DECLARE @mensaje VARCHAR(100);
		SET @mensaje = 'Ya existe el rol ' + @nombreRol + ' en el area ' + @area;
		THROW 51000, @mensaje, 1;
	END

	UPDATE Usuario.Rol
	SET
		nombre = @nombreRol,
		area = @area
	WHERE idRol = @idRol;
END
GO