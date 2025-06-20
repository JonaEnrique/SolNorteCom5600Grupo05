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

-- Crear Categoria sin costo (inicialmente mayor, cadete o menor)
CREATE OR ALTER PROCEDURE CrearCategoriaSinCosto
	@edadMinima TINYINT,
	@edadMaxima TINYINT,
	@nombre VARCHAR(100) -- tiene que coincidir con la cantidad de caracteres en la tabla
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Categoria WHERE nombre = @nombre)
	BEGIN
		RAISERROR('Ya existe una categoria con el nombre %s', 10, 1, @nombre);
	END
	ELSE
	BEGIN
		INSERT INTO Categoria
		VALUES (
			@edadMinima,
			@edadMaxima,
			@nombre
		);
	END
END
GO

-- crear una categoria y darle un costo con una fecha de vigencia
CREATE OR ALTER PROCEDURE CrearCategoriaConCostoNuevo
	@edadMinima TINYINT,
	@edadMaxima TINYINT,
	@nombre VARCHAR(100), -- tiene que coincidir con la cantidad de caracteres en la tabla
	@fechaVigencia DATE,
	@precio DECIMAL(10, 2)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Categoria WHERE nombre = @nombre)
	BEGIN
		RAISERROR('Ya existe una categoria con el nombre %s', 10, 1, @nombre);
	END
	ELSE
	BEGIN
		INSERT INTO Categoria
		VALUES (
			@edadMinima,
			@edadMaxima,
			@nombre
		);

		DECLARE @idCategoria INT = SCOPE_IDENTITY();

		INSERT INTO CostoCategoria
		VALUES (
			@fechaVigencia,
			@precio,
			@idCategoria
		);
	END
END
GO

-- modificar categoria
CREATE OR ALTER PROCEDURE ModificarCategoria
	@idCategoria INT,
	@edadMinima TINYINT,
	@edadMaxima TINYINT,
	@nombre VARCHAR(100)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Categoria WHERE idCategoria = @idCategoria)
	BEGIN
		DECLARE @mensajeCategoria VARCHAR(100);
		SET @mensajeCategoria = 'No existe una categoria con el ID ' + CAST(@idCategoria AS varchar);
		THROW 51000, @mensajeCategoria, 1;
	END

	IF EXISTS (SELECT 1 FROM Categoria WHERE nombre = @nombre AND idCategoria <> @idCategoria)
	BEGIN
		DECLARE @mensajeNombre VARCHAR(100);
		SET @mensajeNombre = 'Ya existe otra categoria de nombre ' + @nombre;
		THROW 51000, @mensajeNombre, 1;
	END

	IF @edadMinima >= @edadMaxima
	BEGIN;
		THROW 51000, 'La edad minima debe ser menor a la edad maxima', 1;
	END

	UPDATE Categoria
	SET
		edadMinima = @edadMinima,
		edadMaxima = @edadMaxima,
		nombre = @nombre
	WHERE idCategoria = @idCategoria;
END
GO