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

-- Crear TipoActividad (Si es pileta, SUM, etc)
CREATE OR ALTER PROCEDURE CrearTipoActividad
	@descripcion VARCHAR(100) -- el numero de caracteres tiene que coincidir con el de la tabla
AS
BEGIN
	IF EXISTS (SELECT 1 FROM TipoActividad WHERE descripcion = @descripcion)
	BEGIN
		RAISERROR('ya existe un tipo de actividad con la descripcion %s', 10, 1, @descripcion);
		RETURN;
	END

	INSERT INTO TipoActividad
	VALUES (@descripcion);
END
GO

-- Modificar descripcion tipo de actividad
CREATE OR ALTER PROCEDURE ModificarDescripcionTipoActividad
	@idTipoActividad INT,
	@descripcionNueva VARCHAR(100)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM TipoActividad WHERE idTipoActividad = @idTipoActividad)
	BEGIN
		RAISERROR('No existe un tipo de actividad con el ID %s', 10, 1, @idTipoActividad);
		RETURN;
	END

	IF EXISTS (SELECT 1 FROM TipoActividad WHERE descripcion = @descripcion AND idTipoActividad <> @idTipoActividad)
	BEGIN
		RAISERROR('ya existe otro tipo de actividad con la descripcion %s', 10, 1, @descripcionNueva);
		RETURN;
	END

	UPDATE TipoActividad
	SET descripcion = @descripcionNueva
	WHERE idTipoActividad = @idTipoActividad;
END
GO