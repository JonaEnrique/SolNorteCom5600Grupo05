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

CREATE OR ALTER PROCEDURE Factura.CrearNotaDeCredito
	@fechaEmision DATE,
	@monto DECIMAL(10, 2),
	@motivo VARCHAR(120),
	@idFactura INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Factura.Factura WHERE idFactura = @idFactura)
	BEGIN
		DECLARE @mensajefactura VARCHAR(100);
		SET @mensajefactura = 'No existe una factura con el ID ' + CAST(@idFactura AS VARCHAR);
		THROW 51000, @mensajefactura, 1;
	END

	IF @fechaEmision > GETDATE()
	BEGIN;
		THROW 51000, 'La fecha de emision no puede ser posterior a la fecha de hoy', 1;
	END

	INSERT INTO Factura.NotaCredito (
		fechaEmision,
		monto,
		motivo,
		idFactura
	)
	VALUES (
		@fechaEmision,
		@monto,
		@motivo,
		@idFactura
	);
END
GO