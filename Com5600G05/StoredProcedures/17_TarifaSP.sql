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
	@descripcionActividad VARCHAR(20),-- ya esta validada en crecion de tabla
	@duracion VARCHAR(10),
	@edad VARCHAR(10),
	@tipoCliente VARCHAR(10)
AS
BEGIN
	-- verifico que coincidan con los valores validos
	IF NOT (@duracion = 'Día' OR @duracion = 'MES' OR @duracion = 'TEMPORADA')
	BEGIN;
		THROW 51000, 'La duracion debe ser DIA, MES o TEMPORADA', 1;
	END

	IF NOT (@edad = 'ADULTO' OR @edad = 'MENOR')
	BEGIN;
		THROW 51000, 'La categoría de edad debe ser ADULTO o MENOR', 1;	
	END

	IF NOT (@tipoCliente = 'SOCIO' OR @tipoCliente = 'INVITADO')
	BEGIN;
		THROW 51000, 'El tipo de cliente debe ser SOCIO o INVITADO', 1;
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
		@descripcionActividad,
		@tipoCliente,
		@duracion,
		@edad
	);
END
GO
CREATE OR ALTER PROCEDURE Actividad.ModificarTarifa
	@idTarifa INT,
	@precio DECIMAL(10 ,2),
	@fechaVigencia DATE
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Actividad.Tarifa T WHERE T.idTarifa = @idTarifa)
	BEGIN
		RAISERROR('NO EXISTE EL ID %d DE TARIFA',16,1,@idTarifa);
	END
	UPDATE Actividad.Tarifa 
	SET
		precio = @precio,
		fechaVigencia = @fechaVigencia
	WHERE idTarifa = @idTarifa;
END
GO

CREATE OR ALTER PROCEDURE Actividad.EliminarTarifa
	@idTarifa INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Actividad.Tarifa T WHERE T.idTarifa = @idTarifa)
	BEGIN
		RAISERROR('NO EXISTE EL ID %d DE TARIFA',16,1,@idTarifa);
	END
	DELETE FROM Actividad.Tarifa WHERE idTarifa = @idTarifa;
END
GO