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

-- Crear tarifa
CREATE OR ALTER PROCEDURE Actividad.CrearTarifa
	@precio DECIMAL(10 ,2),
	@fechaVigencia DATE,
	@idTipoActividad INT,
	@actividad VARCHAR(20),
	@duracion VARCHAR(10),
	@edad VARCHAR(10),
	@tipoCliente VARCHAR(10)
AS
BEGIN
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

	IF NOT (
		@actividad = 'UsoPileta' OR
		@actividad = 'Colonia' OR
		@actividad = 'AlquilerSum'
	)
	BEGIN;
		THROW 51000, 'La actividad debe ser UsoPileta, Colonia o AlquilerSum', 1;
	END

	INSERT INTO Actividad.Tarifa (
		precio,
		fechaVigencia,
		descripcionActividad,
		tipoCliente,
		tipoDuracion,
		tipoEdad
	)
	VALUES (
		@precio,
		@fechaVigencia,
		@actividad,
		@tipoCliente,
		@duracion,
		@edad
	);
END
GO