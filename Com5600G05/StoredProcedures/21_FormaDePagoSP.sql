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

CREATE OR ALTER PROCEDURE CrearFormaDePago
	@nombre VARCHAR(50)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Pago.FormaPago WHERE nombre = @nombre)
	BEGIN
		DECLARE @mensajeNombre VARCHAR(100);
		SET @mensajeNombre = 'Ya existe una forma de pago con el nombre' + @nombre;
		THROW 51000, @mensajeNombre, 1;
	END

	INSERT INTO Pago.FormaPago VALUES (@nombre);
END
GO

CREATE OR ALTER PROCEDURE ModificarFormaDePago
	@idFormaPago INT,
	@nombreNuevo VARCHAR(50)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Pago.FormaPago WHERE nombre = @nombreNuevo AND idFormaPago <> @idFormaPago)
	BEGIN
		DECLARE @mensajeNombre VARCHAR(100);
		SET @mensajeNombre = 'Ya existe otra forma de pago con el nombre' + @nombreNuevo;
		THROW 51000, @mensajeNombre, 1;
	END

	UPDATE Pago.FormaPago SET nombre = @nombreNuevo;
END
GO

-- eliminar forma de pago
CREATE OR ALTER PROCEDURE Pago.EliminarFormaDePago
	@idFormaDePago INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Pago.FormaPago WHERE idFormaPago = @idFormaDePago)
	BEGIN;
		THROW 51000, 'La forma de pago que se intento eliminar no existe', 1;
	END

	IF EXISTS (SELECT 1 FROM Pago.Pago WHERE idFormaPago = @idFormaDePago)
	BEGIN;
		THROW 51000, 'Existe al menos un pago con la forma de pago que se intento eliminar', 1;
	END

	DELETE FROM Pago.FormaPago
	WHERE idFormaPago = @idFormaDePago;
END
GO