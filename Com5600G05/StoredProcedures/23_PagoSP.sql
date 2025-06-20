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

-- Generar un pago
CREATE OR ALTER PROCEDURE CrearPago
	@idTransaccion INT,
	@recargo DECIMAL(10, 2), -- debe tener la misma cantidad de decimales que en la tabla
	@monto DECIMAL(10, 2), -- debe tener la misma cantidad de decimales que en la tabla
	@idFormaDePago INT, -- asumo que lo selecciona de una lista
	@nroFactura VARCHAR(11)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			IF EXISTS (SELECT 1 FROM FormaDePago WHERE idFormaDePago)
			BEGIN;
				THROW 51000, 'La forma de pago seleccionada no existe', 1;
			END

			IF EXISTS (SELECT 1 FROM Pago WHERE idTransaccion = @idTransaccion)
			BEGIN
				DECLARE @mensajeTransaccion VARCHAR(100);
				SET @mensajeTransaccion = 'Ya existe un pago con el codigo de transaccion ' + CAST(@idTransaccion AS VARCHAR);
				THROW 51000, @mensajeTransaccion, 1;
			END

			IF @monto < 0
			BEGIN;
				THROW 51000, 'El monto a pagar no puede ser negativo', 1;
			END

			DECLARE @idFactura INT;
			SET @idFactura = (
				SELECT idFactura
				FROM Factura
				WHERE nroFactura = @nroFactura
			);

			IF @idFactura IS NULL
			BEGIN
				DECLARE @mensajeFactura VARCHAR(100);
				SET @mensajeFactura = 'No existe una factura de numero ' + @nroFactura;
				THROW 51000, @mensajeFactura, 1;
			END

			INSERT INTO Pago
			VALUES (
				@idTransaccion,
				GETDATE(),
				@recargo,
				@monto,
				@idFormaDePago,
				@idFactura
			);
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		DECLARE @mensajeError VARCHAR(100) = ERROR_MESSAGE();
		RAISERROR(@mensajeError, 10, 1);
		ROLLBACK TRANSACTION
	END CATCH
END
GO