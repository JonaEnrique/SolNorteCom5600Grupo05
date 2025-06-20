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
	@idPago INT
AS
BEGIN
	IF @monto <= 0
	BEGIN;
		THROW 51000, 'El monto debe ser positivo', 1;
	END

	DECLARE @montoPago DECIMAL(10, 2);

	IF NOT EXISTS (SELECT 1 FROM Pago.Pago WHERE idPago = @idPago)
	BEGIN
		DECLARE @mensajePago VARCHAR(100);
		SET @mensajePago = 'No se encontro un pago con el ID ' + CAST(@idPago AS VARCHAR);
		THROW 51000, @mensajePago, 1;
	END

	SET @monto = (
		SELECT monto
		FROM Pago.Pago
		WHERE idPago = @idPago
	);

	IF @monto > @montoPago
	BEGIN;
		THROW 51000, 'El reembolso no puede superar el monto del pago', 1;
	END

	INSERT INTO Pago.Reembolso (
		fecha,
		monto,
		motivo,
		idPago
	)
	VALUES (
		GETDATE(),
		@monto,
		@motivo,
		@idPago
	);
END
GO