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

-- Crear Clase
CREATE OR ALTER PROCEDURE Actividad.AsignarActividadASocio
	@idActividadDeportiva INT,
	@idSocio INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Socio.Socio WHERE idSocio = @idSocio)
	BEGIN
		RAISERROR('No existe un socio con el ID %d', 10, 1, @idSocio);
		RETURN;
	END
	IF NOT EXISTS (SELECT 1 FROM Actividad.ActividadDeportiva WHERE idActividadDeportiva = @idActividadDeportiva)
	BEGIN
		RAISERROR('No existe una actividad deportiva con el ID %d', 10 ,1 , @idActividadDeoortiva);
		RETURN;
	END

	INSERT INTO Actividad.SocioRealizaActividad (
		idSocio,
		idActividadDeportiva
	)
	VALUES (
		@idSocio,
		@idActividadDeportiva
	);
END
GO

-- modificar realiza actividad
CREATE OR ALTER PROCEDURE Actividad.ModificarRealizaActividad
	@idRealizaActividad INT,
	@idActividad INT,
	@idSocio INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Actividad.SocioRealizaActividad WHERE idRelacion = @idRealizaActividad)
	BEGIN
		DECLARE @mensajeId VARCHAR(100);
		SET @mensajeId = 'No existe una relacion de realiza actividad con el ID ' + CAST(@idRealizaActividad AS varchar);
		THROW 51000, @mensajeId, 1;
	END

	IF NOT EXISTS (SELECT 1 FROM Actividad.ActividadDeportiva WHERE idActividadDeportiva = @idActividad)
	BEGIN
		DECLARE @mensajeIdActividad VARCHAR(100);
		SET @mensajeIdActividad = 'No existe una actividad deportiva con el ID ' + CAST(@idActividad AS VARCHAR);
		THROW 51000, @mensajeIdActividad, 1;
	END

	IF NOT EXISTS (SELECT 1 FROM Socio.Socio WHERE idSocio = @idSocio)
	BEGIN
		DECLARE @mensajeSocio VARCHAR(100);
		SET @mensajeSocio = 'No existe un socio con el ID ' + CAST(@idSocio AS VARCHAR);
		THROW 51000, @mensajeSocio, 1;
	END

	IF EXISTS (
		SELECT 1
		FROM Actividad.SocioRealizaActividad
		WHERE
			idRelacion <> @idRealizaActividad AND
			idActividadDeportiva = @idActividad AND
			idSocio = @idSocio
	)
	BEGIN
		DECLARE @mensajeRealiza VARCHAR(100);
		SET @mensajeRealiza = 'Ya existe la relacion entre el socio ' + CAST(@idSocio AS VARCHAR)
			+ ' y la actividad deportiva ' + CAST(@idActividad AS VARCHAR);
		THROW 51000, @mensajeRealiza, 1;
	END

	UPDATE Actividad.SocioRealizaActividad
	SET
		idActividadDeportiva = @idActividad,
		idSocio = @idSocio
	WHERE idRelacion = @idRealizaActividad;
END
GO