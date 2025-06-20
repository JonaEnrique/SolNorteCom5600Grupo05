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

CREATE OR ALTER PROCEDURE CrearReembolso
	@monto DECIMAL(10, 2), -- debe coincidir con los decimales de la tabla
	@motivo VARCHAR(100),
	@idTransaccionPago INT
AS
BEGIN
	IF @monto <= 0
	BEGIN;
		THROW 51000, 'El monto debe ser positivo', 1;
	END

	DECLARE @idPago INT;
	DECLARE @montoPago DECIMAL(10, 2); -- debe coincidir con los decimales de la tabla

	SELECT @idPago = p.idPago, @montoPago = p.monto
	FROM Pago AS p
	WHERE p.idTransaccion = @idTransaccionPago;

	IF @idPago IS NULL
	BEGIN
		DECLARE @mensajePago VARCHAR(100);
		SET @mensajePago = 'No se encontro un pago con el codigo de transaccion ' + CAST(@idTransaccion AS VARCHAR);
		THROW 51000, @mensajePago, 1;
	END

	IF @monto > @montoPago
	BEGIN;
		THROW 51000, 'El reembolso no puede superar el monto del pago', 1;
	END

	INSERT INTO Reembolso
	VALUES (
		GETDATE(),
		@monto,
		@motivo,
		@idPago
	);
END
GO