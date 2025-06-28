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
CREATE OR ALTER PROCEDURE Socio.CrearCategoriaSinCosto
	@edadMinima TINYINT,
	@edadMaxima TINYINT,
	@nombre VARCHAR(20)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Socio.Categoria WHERE nombre = @nombre)
	BEGIN
		RAISERROR('Ya existe una categoria con el nombre %s', 10, 1, @nombre);
	END
	ELSE
	BEGIN
		INSERT INTO Categoria
		VALUES (
			@nombre,
			@edadMinima,
			@edadMaxima
			
		);
	END
END
GO

-- crear una categoria y darle un costo con una fecha de vigencia
CREATE OR ALTER PROCEDURE Socio.CrearCategoriaConCostoNuevo
	@edadMinima TINYINT,
	@edadMaxima TINYINT,
	@nombre VARCHAR(20),
	@fechaVigencia DATE,
	@precio DECIMAL(10, 2)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			IF EXISTS (SELECT 1 FROM Socio.Categoria WHERE nombre = @nombre)
			BEGIN
				RAISERROR('Ya existe una categoría con ese nombre', 16, 1);
			END
			INSERT INTO Socio.Categoria (
				edadMinima,
				edadMaxima,
				nombre
			)
			VALUES (
				@edadMinima,
				@edadMaxima,
				@nombre
			);

			DECLARE @idCategoria INT = SCOPE_IDENTITY();

			INSERT INTO Socio.CostoCategoria (
				fechaVigencia,
				precio,
				idCategoria
			)
			VALUES (
				@fechaVigencia,
				@precio,
				@idCategoria
			);
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
END
GO

-- modificar categoria
CREATE OR ALTER PROCEDURE Socio.ModificarCategoria
	@idCategoria INT,
	@edadMinima TINYINT,
	@edadMaxima TINYINT,
	@nombre VARCHAR(20)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Socio.Categoria WHERE idCategoria = @idCategoria)
	BEGIN
		DECLARE @mensajeCategoria VARCHAR(100);
		SET @mensajeCategoria = 'No existe una categoria con el ID ' + CAST(@idCategoria AS varchar);
		THROW 51000, @mensajeCategoria, 1;
	END
	IF @edadMinima >= @edadMaxima
	BEGIN;
		THROW 51000, 'La edad minima debe ser menor a la edad maxima', 1;
	END

	IF NOT EXISTS (SELECT 1 FROM Socio.Categoria WHERE nombre = @nombre AND idCategoria <> @idCategoria)
	BEGIN
		DECLARE @mensajeNombre VARCHAR(100);
		SET @mensajeNombre = 'Ya existe otra categoria de nombre ' + @nombre;
		THROW 51000, @mensajeNombre, 1;
	END

	

	UPDATE Socio.Categoria
	SET
		edadMinima = @edadMinima,
		edadMaxima = @edadMaxima,
		nombre = @nombre
	WHERE idCategoria = @idCategoria;
END
GO


-- eliminar categoria
-- tambien elimina los costos que tiene asociado
CREATE OR ALTER PROCEDURE Socio.EliminarCategoria
	@idCategoria INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Socio.Categoria WHERE idCategoria = @idCategoria)
	BEGIN;
		THROW 51000, 'La categoria que se intento borrar no existe', 1;
	END

	IF EXISTS (SELECT 1 FROM Socio.Socio WHERE idCategoria = @idCategoria)
	BEGIN;
		THROW 51000, 'La categoria que se intento eliminar tiene socios asociados', 1;
	END

	DELETE FROM Socio.CostoCategoria
	WHERE idCategoria = @idCategoria;

	DELETE FROM Socio.Categoria
	WHERE idCategoria = @idCategoria;
END
GO