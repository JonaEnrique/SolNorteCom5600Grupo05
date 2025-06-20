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

-- Crear TipoActividad
CREATE OR ALTER PROCEDURE CrearInvitacion
	@importe DECIMAL(10 ,2), -- tiene que coincidir con el DECIMAL de la tabla Tarifa
	@fechaVigencia DATE,
	@idTipoActividad INT, -- asumo que lo selecciono de una lista
	@duracion VARCHAR(30), -- debe coincidir con la cantidad de caracteres de la tabla
	@edad VARCHAR(30), -- debe coincidir con la cantidad de caracteres de la tabla
	@tipoCliente VARCHAR(30) -- debe coincidir con la cantidad de caracteres de la tabla
AS
BEGIN
	-- verifico que el la actividad seleccionada sea valida
	IF NOT EXISTS (SELECT 1 FROM TipoActividad WHERE idTipoActividad = @idTipoActividad)
	BEGIN
		DECLARE @mensajeActividad VARCHAR(100);
		SET @mensajeActividad = 'No existe una actividad con el ID ' + CAST(@idActividad AS VARCHAR);
		THROW 51000, @mensajeActividad, 1;
	END

	-- verifico que coincidan con los valores validos
	IF NOT (@duracion = 'DIA' OR @duracion = 'MES' OR @duracion = 'TEMPORADA')
	BEGIN;
		THROW 51000, 'La duracion debe ser DIA, MES o TEMPORADA', 1;
	END

	IF NOT (@edad = 'MAYOR' OR @edad = 'CADETE' OR @edad = 'MENOR')
	BEGIN;
		THROW 51000, 'La categoria de edad debe ser MAYOR, MENOR o CADETE', 1;
	END

	IF NOT (@tipoCliente = 'SOCIO' OR @tipoCliente = 'INVITADO')
	BEGIN;
		THROW 51000, 'El tipo de cliente debe ser SOCIO o INVITADO', 1;
	END

	INSERT INTO Tarifa
	VALUES (
		@importe,
		@fechaVigencia,
		@idTipoActividad,
		@duracion,
		@edad,
		@tipoCliente
	);
END
GO