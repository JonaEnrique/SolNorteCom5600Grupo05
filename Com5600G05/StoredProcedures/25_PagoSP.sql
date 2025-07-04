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




CREATE OR ALTER PROCEDURE Pago.CrearPago
	@idTransaccion VARCHAR(64),
	@fecha DATE,
	@monto DECIMAL(10,2),
	@idFormaPago INT,
	@idFactura INT
AS
BEGIN

	IF @idTransaccion IS NULL OR @fecha IS NULL OR @monto IS NULL OR @idFormaPago IS NULL OR @idFactura IS NULL
		THROW 51500, 'Todos los parametros deben existir, es decir, no ser NULL.', 1;
	
	IF @fecha > GETDATE()
		THROW 51501, 'La fecha no puede ser posterior a la fecha actual', 1;


	IF @monto <= 0
		THROW 52502, 'El monto debe ser mayor que cero.', 1;

	IF TRIM(@idTransaccion) = ''
		THROW 52503, 'El idTransaccion no puede estar vacio', 1;

	IF NOT EXISTS (SELECT 1 FROM Pago.FormaPago WHERE idFormaPago = @idFormaPago)
		THROW 52504, 'La forma de pago indicada no existe.', 1;

	IF NOT EXISTS (SELECT 1 FROM Factura.Factura WHERE idFactura = @idFactura)
		THROW 52505, 'La factura indicada no existe.', 1;

	IF EXISTS (SELECT 1 FROM Pago.Pago WHERE idFactura = @idFactura)
		THROW 52006, 'Ya existe un pago registrado para esa factura.', 1;

	IF EXISTS (SELECT 1 FROM Pago.Pago WHERE idTransaccion = @idTransaccion)
		THROW 52007, 'El idTransaccion ya fue utilizado.', 1;

	IF @fecha < (SELECT fechaEmision FROM Factura.Factura WHERE idFactura = @idFactura)
		THROW 51508, 'La fecha no puede ser anterior a la fechaEmision de Factura', 1;

	INSERT INTO Pago.Pago (idTransaccion, fecha, monto, idFormaPago, idFactura)
	VALUES
		(@idTransaccion, @fecha, @monto, @idFormaPago, @idFactura);
	
	DECLARE @idPago INT = SCOPE_IDENTITY();
	DECLARE @idSocio INT = (SELECT idPersona FROM Factura.Factura WHERE idFactura = @idFactura);
	DECLARE @totalFactura DECIMAL(10,2) = (SELECT totalFactura FROM Factura.Factura WHERE idFactura = @idFactura);
	DECLARE @saldoAFavor DECIMAL(10,2) = @monto - @totalFactura;


	IF @monto > @totalFactura
		EXEC Pago.CrearSaldoCuenta @monto = @saldoAFavor, @idPago = @idPago, @idSocio = @idSocio;

END;
GO


CREATE OR ALTER TRIGGER Pago.NoModificarPago
ON Pago.Pago
INSTEAD OF UPDATE, DELETE
AS
BEGIN;
	THROW 51509, 'No está permitido modificar/eliminar un pago registrado.', 1;
END;
GO