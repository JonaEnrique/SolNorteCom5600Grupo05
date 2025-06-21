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

CREATE OR ALTER PROCEDURE Socio.CrearObraSocial
	@nombre VARCHAR(40),
	@telefono VARCHAR(40)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Socio.ObraSocial WHERE nombre = @nombre)
	BEGIN
		DECLARE @mensajeNombre VARCHAR(100);
		SET @mensajeNombre = 'Ya existe una obra social con el nombre ' + @nombre;
		THROW 51000, @mensajeNombre, 1;
	END

	INSERT INTO Socio.ObraSocial (
		nombre,
		telefono
	)
	VALUES (
		@nombre,
		@telefono
	);

	RETURN SCOPE_IDENTITY();
END
GO

-- modificar obra social
CREATE OR ALTER PROCEDURE Socio.ModificarObraSocial
	@idObraSocial INT,
	@nombreNuevo VARCHAR(40),
	@telefonoNuevo VARCHAR(40)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Socio.ObraSocial WHERE nombre = @nombreNuevo AND idObraSocial <> @idObraSocial)
	BEGIN
		DECLARE @mensajeNombre VARCHAR(100);
		SET @mensajeNombre = 'Ya existe otra obra social con el nombre ' + @nombreNuevo;
		THROW 51000, @mensajeNombre, 1;
	END

	UPDATE Socio.ObraSocial
	SET
		nombre = @nombreNuevo,
		telefono = @telefonoNuevo
	WHERE idObraSocial = @idObraSocial
END
GO

-- Eliminando Obra social

CREATE OR ALTER PROCEDURE Socio.EliminarObraSocial
@idObraSocial INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Socio.ObraSocial WHERE idObraSocial = @idObraSocial)
	BEGIN;
		THROW 51000, 'La obra social que se intento eliminar no existe', 1;
	END

	IF EXISTS (SELECT 1 FROM Socio.Socio WHERE idObraSocial = @idObraSocial)
	BEGIN;
		THROW 51000, 'La obra social que se intento eliminar esta asociada a por lo menos un Socio', 1;
	END

	DELETE FROM Socio.ObraSocial
	WHERE idObraSocial = @idObraSocial;
END
GO