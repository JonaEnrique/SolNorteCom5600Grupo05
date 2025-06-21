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
CREATE OR ALTER PROCEDURE Factura.CrearFactura
	@puntoDeVenta CHAR(4),
	@tipoFactura CHAR(1),
	@tipoItem VARCHAR(30),
	@fechaEmision DATE,
	@subtotal DECIMAL(10, 2),
	@porcentajeIva DECIMAL(4, 2),
	@idSocio INT
AS
BEGIN
	-- checkeo que el tipo de factura sea valido
	IF NOT (@tipoFactura = 'A' OR @tipoFactura = 'B' OR @tipoFactura = 'C')
	BEGIN;
		THROW 51000, 'El tipo de factura debe ser A, B o C', 1;
	END

	-- si no existe el socio tiro una excepcion
	IF NOT EXISTS (SELECT 1 FROM Socio.Socio WHERE idSocio = @idSocio)
	BEGIN
		DECLARE @mensajeSocio VARCHAR(100);
		SET @mensajeSocio = 'No existe un socio con el ID ' + @idSocio;
		THROW 51000, @mensajeSocio, 1;
	END

	-- busco la categoria del socio
	DECLARE @categoria INT;
	SET @categoria = (
		SELECT c.nombre
		FROM Socio.Categoria c
		WHERE c.idCategoria = (
			SELECT s.idCategoria
			FROM Socio.Socio s
			WHERE s.idSocio = @idSocio
		)
	);

	-- si no es mayor tiro una excepcion
	IF NOT @categoria = 'Mayor'
	BEGIN;
		THROW 51000, 'El socio asociado a una factura debe ser de categoria MAYOR', 1;
	END

	-- compruebo que la fecha de emision sea valida
	IF @fechaEmision > GETDATE()
	BEGIN;
		THROW 51000, 'La fecha de emision no puede ser posterior a la fecha de hoy', 1;
	END

	INSERT INTO Factura.Factura (
		puntoDeVenta,
		tipoFactura,
		tipoItem,
		fechaEmision,
		subtotal,
		porcentajeIva,
		estado,
		idSocio
	)
	VALUES (
		@puntoDeVenta,
		@tipoFactura,
		@tipoItem,
		@fechaEmision,
		@subtotal,
		@porcentajeIva,
		'Pendiente',
		@idSocio
	);

	-- creo que necesito esto para pago
	RETURN SCOPE_IDENTITY();
END
GO

-- actualizar estado de una factura
CREATE OR ALTER PROCEDURE Factura.ActualizarEstadoFactura
	@idFactura INT,
	@estadoNuevo VARCHAR(15)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Factura.Factura WHERE idFactura = @idFactura)
	BEGIN
		DECLARE @mensajeFactura VARCHAR(100);
		SET @mensajeFactura = 'No existe una factura de ID ' + CAST(@idFactura AS VARCHAR);
		THROW 51000, @mensajeFactura, 1;
	END

	IF NOT (@estadoNuevo = 'Pagada' OR @estadoNuevo = 'Cancelada' OR @estadoNuevo = 'Pagada Vencida')
	BEGIN;
		THROW 51000, 'El estado nuevo debe ser PAGADA, CANCELADA o PAGADA VENCIDA', 1;
	END
END
GO