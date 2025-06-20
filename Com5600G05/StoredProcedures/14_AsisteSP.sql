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
CREATE OR ALTER PROCEDURE Actividad.CrearAsistenciaSeleccionandoClase
	@estadoAsistencia CHAR(2),
	@idClase INT,
	@idSocio INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Socio.Socio WHERE idSocio = @idSocio)
	BEGIN
		RAISERROR('No existe un socio con el ID %d', 10, 1, @nroSocio);
		RETURN;
	END
	
	IF NOT EXISTS (SELECT 1 FROM Actividad.Clase WHERE idClase = @idClase)
	BEGIN
		RAISERROR('No existe una clase con el ID %d', 10 ,1 , @idClase);
		RETURN;
	END

	IF @estadoAsistencia NOT LIKE '[AJP]'
	BEGIN
		RAISERROR('El estado de asistencia debe ser P, A o J', 10, 1);
		RETURN;
	END

	INSERT INTO Actividad.Asiste (
		idSocio,
		idClase,
		asistencia
	)
	VALUES (
		@idSocio,
		@idClase,
		@estadoAsistencia
	);
END
GO