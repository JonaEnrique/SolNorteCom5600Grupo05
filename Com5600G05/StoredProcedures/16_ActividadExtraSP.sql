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
CREATE OR ALTER PROCEDURE Actividad.CrearActividadExtra
	@descrpicionActividad VARCHAR(20),
	@fechaInicio		  DATE,
	@fechaFin		      DATE,
	@idSocio			  INT,
	@idTarifa             INT,
	@idJornada			  INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Socio.Socio S WHERE S.idSocio = @idSocio)
	BEGIN
		RAISERROR('NO EXISTE EL ID %d DE SOCIO',16,1,@idSocio);
	END
	
	IF NOT EXISTS (SELECT 1 FROM Actividad.Tarifa T WHERE T.idTarifa = @idTarifa)
	BEGIN
		RAISERROR('NO EXISTE EL ID %d DE TARIFA',16,1,@idTarifa);
	END
	
	IF NOT EXISTS (SELECT 1 FROM Actividad.Jornada j WHERE j.idJornada = @idJornada)
	BEGIN
		RAISERROR('NO EXISTE EL ID %d DE JORNADA',16,1,@idJornada);
	END
	
	INSERT INTO ActividadExtra
	VALUES (
	@descrpicionActividad,
	@fechaInicio,
	@fechaFin,
	@idSocio,
	@idTarifa,
	@idJornada
	);
END
GO

-- no se modifica una vez creada