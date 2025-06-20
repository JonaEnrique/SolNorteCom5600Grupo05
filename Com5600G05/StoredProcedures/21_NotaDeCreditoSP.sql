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

CREATE OR ALTER PROCEDURE CrearNotaDeCredito
	@nroComprobante VARCHAR(11),
	@descripcion VARCHAR(100), -- debe coincidir con la cantidad de caracteres en la tabla
	@fechaEmision DATE,
	@monto DECIMAL(10, 2), -- debe coincidir con la cantidad de decimales en la tabla
	@motivo VARCHAR(100), -- debe coincidir con la cantidad de caracteres en la tabla
	@idFactura INT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM NotaDeCredito WHERE nroComprobante = @nroComprobante)
	BEGIN
		DECLARE @mensajeNroComprobante VARCHAR(100);
		SET @mensajeNroComprobante = 'Ya existe una nota de credito con el numero de comprobante ' + @nroComprobante;
		THROW 51000, @mensajeNroComprobante, 1;
	END

	IF NOT EXISTS (SELECT 1 FROM Factura WHERE idFactura = @idFactura)
	BEGIN
		DECLARE @mensajefactura VARCHAR(100);
		SET @mensajefactura = 'No existe una factura con el ID ' + CAST(@idFactura AS VARCHAR);
		THROW 51000, @mensajefactura, 1;
	END

	IF @fechaEmision > GETDATE()
	BEGIN;
		THROW 51000, 'La fecha de emision no puede ser posterior a la fecha de hoy', 1;
	END

	INSERT INTO NotaDeCredito
	VALUES (
		@descripcion,
		@fechaEmision,
		@nroComprobante,
		@monto,
		@motivo,
		'EMITIDO', -- debe coincidir con el check
		@idFactura
	);
END
GO