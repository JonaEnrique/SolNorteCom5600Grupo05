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

CREATE OR ALTER PROCEDURE CrearObraSocial
	@nombre VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@telefono VARCHAR(50) -- debe coincidir con la cantidad de caracteres de la tabla
AS
BEGIN
	IF EXISTS (SELECT 1 FROM ObraSocial WHERE nombre = @nombre)
	BEGIN
		DECLARE @mensajeNombre VARCHAR(100);
		SET @mensajeNombre = 'Ya existe una obra social con el nombre ' + @nombre;
		THROW 51000, @mensajeNombre, 1;
	END

	INSERT INTO ObraSocial
	VALUES (
		@nombre,
		@telefono
	);

	RETURN SCOPE_IDENTITY();
END
GO

-- modificar obra social
CREATE OR ALTER PROCEDURE ModificarObraSocial
	@idObraSocial INT,
	@nombreNuevo VARCHAR(100), -- debe coincidir con la cantidad de caracteres de la tabla
	@telefonoNuevo VARCHAR(50) -- debe coincidir con la cantidad de caracteres de la tabla
AS
BEGIN
	IF EXISTS (SELECT 1 FROM ObraSocial WHERE nombre = @nombre AND idObraSocial <> @idObraSocial)
	BEGIN
		DECLARE @mensajeNombre VARCHAR(100);
		SET @mensajeNombre = 'Ya existe otra obra social con el nombre ' + @nombre;
		THROW 51000, @mensajeNombre, 1;
	END

	UPDATE ObraSocial
	SET
		nombre = @nombreNuevo,
		telefono = @telefonoNuevo
	WHERE idObraSocial = @idObraSocial
END
GO