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


CREATE OR ALTER FUNCTION Factura.ObtenerTotal
	(@idFactura INT)
RETURNS DECIMAL(10,2)
AS
BEGIN;

	DECLARE @totalNotasDeCredito DECIMAL(10,2);

	SELECT @totalNotasDeCredito = SUM(monto)
	FROM Factura.NotaCredito
	WHERE idFactura = @idFactura;

	DECLARE @total DECIMAL(10,2);

	SELECT @total = f.totalFactura + ISNULL(nd.totalNotaDebito, 0) - @totalNotasDeCredito
    FROM Factura.Factura f
	LEFT JOIN Factura.NotaDebito nd ON nd.idFactura = f.idFactura
	WHERE f.idFactura = @idFactura;


    RETURN @total;
END;
GO


CREATE OR ALTER PROCEDURE Factura.CrearNotaDeCredito
	@fechaEmision DATE,
	@motivo VARCHAR(120),
	@monto DECIMAL(10,2) = NULL,
	@tipoNC VARCHAR(20),
	@idFactura INT
AS
BEGIN
	
	SET XACT_ABORT ON;
	-------------------Validaciones basicas---------------------------

	IF @fechaEmision IS NULL OR @motivo IS NULL OR @tipoNC IS NULL OR @idFactura IS NULL
	BEGIN;
		THROW 51200, 'Los parametros fechaEmision, motivo, tipoNC y idFactura no pueden ser NULL.', 1;
	END;


	IF NOT EXISTS (SELECT 1 FROM Factura.Factura WHERE idFactura = @idFactura)
	BEGIN
		DECLARE @mensajeNotaFactura VARCHAR(100);
		SET @mensajeNotaFactura = 'No existe una factura con el ID ' + CAST(@idFactura AS VARCHAR);
		THROW 51201, @mensajeNotaFactura, 1;
	END;


	IF TRIM(@motivo) = ''
	BEGIN;
		THROW 51202, 'El motivo no puede estar vacio.', 1;
	END

	IF @tipoNC NOT IN ('AnulacionTotal', 'AnulacionParcial', 'Reembolso')
	BEGIN;
		THROW 51203, 'El tipoNC debe ser: AnulacionTotal, AnulacionParcial o Reembolso', 1;
	END

	IF @fechaEmision > GETDATE()
	BEGIN;
		THROW 51204, 'La fecha de emision no puede ser posterior a la fecha de hoy', 1;
	END

	IF @tipoNC IN ('AnulacionTotal','Reembolso') AND @monto IS NOT NULL
	BEGIN;
		THROW 51205, 'El monto debe no ser NULL solo cuando la Anulacion es Parcial.', 1;
	END;

	IF 'Cancelada' = (SELECT estado FROM Factura.Factura WHERE idFactura = @idFactura)
	BEGIN;
		THROW 51206, 'No se puede crear una Nota de Credito ya que la Factura esta Cancelada', 1;
	END;

	-------------------Calculo monto si es Reembolso o AnulacionTotal---------------------------



	IF @tipoNC = 'AnulacionParcial' 
	BEGIN
		IF  @monto > Factura.ObtenerTotal(@idFactura)
		BEGIN;
			THROW 51207, 'No se puede usar ese monto para crear una nota de credito parcial, ya que no hay total suficiente en la Factura', 1;
		END;
	END;

	IF @tipoNC = 'AnulacionTotal'
	BEGIN

		DECLARE @fechaReferencia DATE;

		-- Obtengo la fecha del último comprobante (Factura o NC previa)
		SELECT 
			@fechaReferencia = MAX(COALESCE(nc.fechaEmision, f.fechaEmision))
		FROM Factura.Factura     f
		LEFT JOIN Factura.NotaCredito nc 
			ON nc.idFactura = f.idFactura
		WHERE f.idFactura = @idFactura;
					

		IF @fechaEmision < @fechaReferencia
		BEGIN;
			THROW 51208, 'La fecha de emisión de la Nota de Crédito no puede ser anterior a la última fecha de emisión (Factura o NC previa).', 1;
		END;

		SELECT @monto = Factura.ObtenerTotal(@idFactura);

	END;

	IF @tipoNC = 'Reembolso'
	BEGIN
		SELECT @monto = p.monto FROM Pago.Pago p WHERE p.idFactura = @idFactura;
		IF @monto IS NULL
		BEGIN;
			THROW 51209, 'No hay un pago asociado a la factura.', 1;
		END;

		IF @fechaEmision < (SELECT fecha FROM Pago.Pago WHERE @idFactura = idFactura)
		BEGIN;
			THROW 51210, 'La fecha de emision de la NC no puede ser menor a la fecha del Pago.', 1;
		END
	END;


	INSERT INTO Factura.NotaCredito (
		fechaEmision,
		monto,
		motivo,
		tipoNC,
		idFactura
	)
	VALUES (
		@fechaEmision,
		@monto,
		@tipoNC,
		@motivo,
		@idFactura
	);

	--Actualizar estado de factura.

	IF @tipoNC IN ('AnulacionTotal', 'Reembolso')
	BEGIN
		UPDATE Factura.Factura
		SET estado = 'Cancelada'
		WHERE idFactura = @idFactura;
	END;
	IF @tipoNC = 'AnulacionParcial'
	BEGIN
		-- Si la factura quedó en 0 tras la NC parcial
		IF Factura.ObtenerTotal(@idFactura) = 0
		BEGIN
			UPDATE Factura.Factura
			SET estado = 'Cancelada'
			WHERE idFactura = @idFactura;
		END;
	END;
END
GO



DISABLE TRIGGER Factura.NoModificarNotaCredito ON 

CREATE OR ALTER TRIGGER Factura.NoModificarNotaCredito
ON Factura.NotaCredito
INSTEAD OF UPDATE, DELETE
AS
BEGIN;
	THROW 51211, 'No está permitido modificar/eliminar notas de credito ya emitidas.', 1;
END;
GO

