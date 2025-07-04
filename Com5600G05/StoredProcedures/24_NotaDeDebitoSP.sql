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



CREATE OR ALTER PROCEDURE Factura.CrearNotaDebito
	@fechaEmision DATE,
	@idFactura INT
AS
BEGIN

	IF @fechaEmision IS NULL OR @idFactura IS NULL
	BEGIN;
		THROW 51400, 'Todos los parametros deben existir, es decir, no ser NULL.', 1;
	END;
	
	IF @fechaEmision > GETDATE()
	BEGIN;
		THROW 51401, 'La fecha de emision no puede ser posterior a la fecha actual', 1;
	END;

	IF NOT EXISTS( SELECT 1 FROM Factura.Factura WHERE idFactura = @idFactura)
	BEGIN;
		THROW 51402, 'El idFactura ingresado no existe en la tabla Factura.', 1;
	END;

	IF EXISTS( SELECT 1 FROM Factura.Factura f JOIN Factura.NotaDebito nd ON nd.idFactura = f.idFactura
		WHERE f.idFactura = @idFactura)
	BEGIN;
		THROW 51403, 'La Factura ya presenta una nota de debito.', 1;
	END;


	IF @fechaEmision <= (SELECT fechaRecargo FROM Factura.Factura WHERE idFactura = @idFactura) 
	BEGIN;
		THROW 51404, 'La fecha de emision debe ser mayor a la fecha de recargo en Factura.', 1;
	END;

	IF 'Emitida' <> (SELECT estado FROM Factura.Factura WHERE idFactura = @idFactura)
		THROW 51405, 'No se puede agregar una nota de debito a una Factura que no esta en estado Emitida', 1;

	INSERT INTO Factura.NotaDebito(fechaEmision, montoBase, porcentajeIVA, idFactura)
	SELECT 
		@fechaEmision,
		totalFactura * 0.10,
		CASE
			WHEN tipoFactura IN ('C','E') THEN 0.00
			ELSE 21.00
		END,
		@idFactura
	FROM Factura.Factura
	WHERE idFactura = @idFactura;


	UPDATE Factura.Factura
	SET estado = 'Vencida'
	WHERE idFactura = @idFactura;
END;
GO

--Job que se corre todos los dias. 

CREATE OR ALTER PROCEDURE Factura.RecargarFacturaAutomaticamente
AS
BEGIN


	-- Detecto facturas vencidas que están Emitidas.
	DECLARE @facturasVencidas TABLE (
		idFactura INT PRIMARY KEY
	);
	INSERT INTO @facturasVencidas (idFactura)
	SELECT
		f.idFactura
	FROM
		Factura.Factura AS f
	WHERE
		f.estado = 'Emitida'
		AND f.fechaVencimiento < GETDATE();

	-- Crear notas de débito por facturas vencidas.
	DECLARE @fechaHoy DATE = GETDATE();
	DECLARE @sql VARCHAR(MAX) = '';

	SELECT
		@sql += 
			N'EXEC Factura.CrearNotaDebito'
			+ ' @idFactura = '   + CAST(idFactura   AS VARCHAR)
			+ ', @fechaEmision = ''' + CAST(@fechaHoy AS VARCHAR)  + ''';'
			+ CHAR(13) + CHAR(10)
	FROM
		@facturasVencidas;

	PRINT @sql;

	IF LEN(@sql) > 0
		EXEC (@sql);

END;
GO



CREATE OR ALTER TRIGGER Factura.NoModificarNotaDebito
ON Factura.NotaDebito
INSTEAD OF UPDATE
AS
BEGIN;
	THROW 51406, 'No está permitido modificar notas de debito ya emitidas.', 1;
END;
GO


CREATE OR ALTER TRIGGER Factura.NoEliminarNotaDebito
ON Factura.NotaDebito
INSTEAD OF DELETE
AS
BEGIN;
	THROW 51407, 'No está permitido eliminar notas de debito ya emitidas.', 1;
END;
GO

