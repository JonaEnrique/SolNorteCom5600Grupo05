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

-- Crear Activida extra
CREATE OR ALTER PROCEDURE CrearActividadExtra
	@fechaHoraInicio DATETIME,
	@fechaHoraFin DATETIME,
	@nroSocio INT,
	@tipoActividad INT -- tipo de actividad asumo que se selecciona de una lista desplegable
AS
BEGIN
	-- extraigo la fecha de fechaHoraInicio
	DECLARE @fechaJornada DATE;
	SET @fechaJornada = CAST(@fechaHoraInicio AS DATE);

	-- consigo el ID de la jornada con esa fecha
	DECLARE @idJornada INT;
	SET @idJornada = (
		SELECT idJornada
		FROM Jornada
		WHERE fecha = @fechaJornada
	);

	-- consigo el ID del Socio asociado
	DECLARE @idSocio INT;
	SET @idSocio = (
		SELECT idSocio
		FROM Socio
		WHERE nroSocio = @nroSocio
	);

	INSERT INTO ActividadExtra
	VALUES (
		@fechaHoraInicio,
		@fechaHoraFin,
		@idJornada,
		@idSocio,
		@tipoActividad
	);
END
GO

-- no se modifica una vez creada