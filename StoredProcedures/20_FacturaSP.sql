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

-- Crear Factura
CREATE OR ALTER PROCEDURE CrearFactura
	@nroFactura VARCHAR(11),
	@tipoFactura CHAR(1),
	@descripcion VARCHAR(100), -- esto creo que quedo de mas
	@condicionIVA VARCHAR(30), -- debe tener la misma cantidad de caracteres que en la tabla
	@fechaEmision DATE,
	@cuit CHAR(11),
	@montoIVA DECIMAL(10, 2), -- debe tener los mismos decimales que en la tabla
	@total DECIMAL(10, 2), -- debe tener los mismos decimales que en la tabla
	@nroSocio VARCHAR(30) -- debe tener la misma cantidad de caracteres que en la tabla
AS
BEGIN
	-- checkeo que no se haya cargado ya la factura
	IF EXISTS (SELECT 1 FROM Factura WHERE nroFactura = @nroFactura)
	BEGIN
		DECLARE @mensajeNroFactura VARCHAR(100);
		SET @mensajeNroFactura = 'Ya existe una factura con el numero ' + @nroFactura;
		THROW 51000, @mensajeNroFactura, 1;
	END

	-- checkeo que el tipo de factura sea valido
	IF NOT (@tipoFactura = 'A' OR @tipoFactura = 'B' OR @tipoFactura = 'C')
	BEGIN;
		THROW 51000, 'El tipo de factura debe ser A, B o C', 1;
	END

	-- busco el id del numero de socio
	DECLARE @idSocio INT;
	SET @idSocio = (
		SELECT idSocio
		FROM Socio
		WHERE nroSocio = @nroSocio
	);

	-- si no existe tiro una excepcion
	IF @idSocio IS NULL
	BEGIN
		DECLARE @mensajeSocio VARCHAR(100);
		SET @mensajeSocio = 'No existe un socio con el numero ' + @nroSocio;
		THROW 51000, @mensajeSocio, 1;
	END

	-- busco la categoria del socio
	DECLARE @categoria INT;
	SET @categoria = (
		SELECT c.nombre
		FROM Categoria c
		WHERE c.idCategoria = (
			SELECT s.idCategoria
			FROM Socio s
			WHERE s.idSocio = @idSocio
		)
	);

	-- si no es mayor tiro una excepcion
	IF NOT @categoria = 'MAYOR'
	BEGIN;
		THROW 51000, 'El socio asociado a una factura debe ser de categoria MAYOR', 1;
	END

	-- compruebo que la fecha de emision sea valida
	IF @fechaEmision > GETDATE()
	BEGIN;
		THROW 51000, 'La fecha de emision no puede ser posterior a la fecha de hoy', 1;
	END

	INSERT INTO Factura
	VALUES (
		@nroFactura,
		@tipoFactura,
		@descripcion,
		@condicionIVA,
		@fechaEmision,
		DATEADD(DAY, 5, @fechaEmision),
		DATEADD(DAY, 10, @fechaEmision),
		@cuit,
		@montoIVA,
		@total,
		'PENDIENTE',
		@idSocio
	);

	-- creo que necesito esto para pago
	RETURN SCOPE_IDENTITY();
END
GO

-- actualizar estado de una factura
CREATE OR ALTER PROCEDURE ActualizarEstadoFactura
	@idFactura INT,
	@estadoNuevo VARCHAR(30) -- debe coincidir con la cantidad de caracteres de la tabla
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Factura WHERE idFactura = @idFactura)
	BEGIN
		DECLARE @mensajeFactura VARCHAR(100);
		SET @mensajeFactura = 'No existe una factura de ID ' + CAST(@idFactura AS VARCHAR);
		THROW 51000, @mensajeFactura, 1;
	END

	IF NOT (@estadoNuevo = 'PAGADA' OR @estadoNuevo = 'CANCELADA' OR @estadoNuevo = 'PAGADA VENCIDA')
	BEGIN;
		THROW 51000, 'El estado nuevo debe ser PAGADA, CANCELADA o PAGADA VENCIDA', 1;
	END
END
GO