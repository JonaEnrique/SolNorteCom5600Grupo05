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

-- Crear Registro de asistencia seleccionando la clase
CREATE OR ALTER PROCEDURE CrearAsistenciaSeleccionandoClase
	@estadoAsistencia CHAR(1),
	@idClase INT, -- asumo que lo selecciono de una lista desplegable
	@nroSocio INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Socio WHERE nroSocio = @nroSocio)
	BEGIN
		RAISERROR('No existe un socio con el numero %d', 10, 1, @nroSocio);
		RETURN;
	END
	
	IF NOT EXISTS (SELECT 1 FROM Clase WHERE idClase = @idClase)
	BEGIN
		RAISERROR('No existe una clase con el ID %d', 10 ,1 , @idClase);
		RETURN;
	END

	IF @estadoAsistencia NOT LIKE '[AJP]'
	BEGIN
		RAISERROR('El estado de asistencia debe ser P, A o J', 10, 1);
		RETURN;
	END

	-- consigo el id del socio usando el nro de socio
	DECLARE @idSocio INT;
	SET @idSocio = (
		SELECT idSocio
		FROM Socio
		WHERE nroSocio = @nroSocio
	);

	INSERT INTO Asiste
	VALUES (
		@estadoAsistencia,
		@idClase,
		@idSocio
	);
END
GO

-- crear asistencia especificando la fecha, el profesor y la actividad deportiva
CREATE OR ALTER PROCEDURE CrearAsistenciaPorProfesorFechaYActividad
	@fecha DATE,
	@profesor VARCHAR(100), -- tiene que coincidir con la cantidad de carateres de la tabla
	@nombreActividad VARCHAR(100), -- tiene que coincidir con la cantidad de carateres de la tabla
	@estadoAsistencia CHAR(1),
	@nroSocio INT
AS
BEGIN
	DECLARE @idActividad INT;
	SET @idActividad = (
		SELECT idActividad
		FROM ActividadDeportiva
		WHERE nombre = @nombreActividad
	);

	IF @idActividad IS NULL
	BEGIN
		RAISERROR('La actividad %s no existe', 10, 1, @nombreActividad);
		RETURN;
	END

	DECLARE @idSocio INT;
	SET @idSocio = (
		SELECT idSocio
		FROM Socio
		WHERE nroSocio = @nroSocio
	);

	IF @idSocio IS NULL
	BEGIN
		RAISERROR('No existe un socio con el numero de socio %d', 10, 1, @nroSocio);
		RETURN;
	END

	IF NOT EXISTS (SELECT 1 FROM Clase WHERE fecha = @fecha)
	BEGIN
		DECLARE @textoFecha VARCHAR(12);
		SET @textoFecha = CAST(@fecha AS VARCHAR);
		RAISERROR('No hay clases en la fecha %s', 10, 1, @textoFecha);
		RETURN;
	END

	IF NOT EXISTS (SELECT 1 FROM Clase WHERE profesor = @profesor)
	BEGIN
		RAISERROR('No existen clases dictadas por el profesor %s', 10, 1, @profesor);
		RETURN;
	END

	IF @estadoAsistencia NOT LIKE '[AJP]'
	BEGIN
		RAISERROR('El estado de asistencia debe ser P, A, o J', 10, 1);
		RETURN;
	END
END
GO