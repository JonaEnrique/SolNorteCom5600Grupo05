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

-- Crear ActividadDeportiva sin costo
CREATE OR ALTER PROCEDURE Actividad.CrearActividadDeportivaSinCosto
	@nombre VARCHAR(30)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Actividad.ActividadDeportiva WHERE nombre = @nombre)
	BEGIN
		RAISERROR('Ya existe una actividad deportiva con el nombre %s', 10, 1, @nombre);
	END
	ELSE
	BEGIN
		INSERT INTO Actividad.ActividadDeportiva
		VALUES (@nombre);
	END
END
GO

-- crear una actividad deportiva y darle un costo con una fecha de vigencia
CREATE OR ALTER PROCEDURE Actividad.CrearActividadDeportivaConCostoNuevo
	@nombre VARCHAR(30),
	@fechaVigencia DATE,
	@precio DECIMAL(10, 2)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			IF EXISTS (SELECT 1 FROM Actividad.ActividadDeportiva WHERE nombre = @nombre)
			BEGIN
				DECLARE @mensajeActividadDeportiva VARCHAR(100);
				SET @mensajeActividadDeportiva = 'Ya existe una actividad deportiva con el nombre ' + @nombre;
				THROW 51000, @mensajeActividadDeportiva, 1;
			END
	
			INSERT INTO Actividad.ActividadDeportiva
			VALUES (@nombre);

			DECLARE @idActividadDeportiva INT = SCOPE_IDENTITY();

			EXEC Actividad.CrearCostoActividadDeportiva
				@precio,
				@fechaVigencia,
				@idActividadDeportiva;
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		DECLARE @mensajeError VARCHAR(100) = ERROR_MESSAGE();
		RAISERROR (@mensajeError, 10, 1);
		ROLLBACK TRANSACTION
	END CATCH
END
GO

-- modificar nombre actividad deportiva
CREATE OR ALTER PROCEDURE Actividad.ModificarNombreActividadDeportiva
	@idActividadDeportiva INT,
	@nombreNuevo VARCHAR(100)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Actividad.ActividadDeportiva WHERE idActividadDeportiva = @idActividadDeportiva)
	BEGIN
		DECLARE @mensajeIdActividad VARCHAR(100);
		SET @mensajeIdActividad = 'No existe una actividad deportiva con el ID ' + CAST(@idActividadDeportiva AS varchar);
		THROW 51000, @mensajeIdActividad, 1;
	END

	IF EXISTS (SELECT 1 FROM Actividad.ActividadDeportiva WHERE nombre = @nombreNuevo AND idActividadDeportiva <> @idActividadDeportiva)
	BEGIN
		DECLARE @mensajeNombre VARCHAR(100);
		SET @mensajeNombre = 'Ya existe otra actividad deportiva con el nombre ' + @nombreNuevo;
		THROW 51000, @mensajeNombre, 1;
	END

	UPDATE Actividad.ActividadDeportiva
	SET nombre = @nombreNuevo
	WHERE idActividadDeportiva = @idActividadDeportiva;
END
GO

-- el costo se modifica asignandole uno nuevo en costo actividad deportiva