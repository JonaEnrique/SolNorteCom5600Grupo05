/*
	Fecha: 23/05/2025
	Grupo: 05
	Materia: Bases de Datos Aplicada
	Nicolas Perez 40015709
	Santiago Sanchez 42281463
	Jonathan Enrique 43301711
	Teo Turri 42819058

	Consigna:
		Genere store procedures para manejar la inserción, modificado, borrado (si corresponde,
		también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.
		Los nombres de los store procedures NO deben comenzar con “SP”. 

*/

USE Com5600G05
GO

CREATE OR ALTER PROCEDURE Factura.ValidarCabeceraFactura
	@puntoDeVenta   CHAR(4),
	@tipoFactura    CHAR(1),
	@fechaEmision   DATE,
	@idSocio        INT
AS
BEGIN
	-- Parámetros imprescindibles
	IF @puntoDeVenta     IS NULL
	OR  @tipoFactura     IS NULL
	OR  @fechaEmision    IS NULL
	OR  @idSocio         IS NULL
	BEGIN
		THROW 51050, 'Faltan parámetros: puntoDeVenta, tipoFactura, fechaEmision o idSocio.', 1;
	END

	-- Tipo de factura válido
	IF @tipoFactura NOT IN ('A','B','C','E','M')
		THROW 51051, 'tipoFactura debe ser A, B, C, E o M.', 1;

	-- Punto de venta: 4 dígitos numéricos
	IF @puntoDeVenta NOT LIKE '[0-9][0-9][0-9][0-9]'
		THROW 51052, 'puntoDeVenta debe ser 4 dígitos numéricos.', 1;
	
	IF NOT EXISTS (SELECT 1 FROM Socio.Socio WHERE idSocio = @idSocio)
		THROW 51053, 'idSocio ingresado no existe', 1;

	-- Socio existe y es categoría Mayor
	DECLARE @categoria VARCHAR(50);
	SELECT 
		@categoria = c.nombre
	FROM 
		Socio.Socio s
	JOIN 
		Socio.Categoria c 
		ON c.idCategoria = s.idCategoria
	WHERE 
		s.idSocio = @idSocio;

	IF @categoria <> 'Mayor'
		THROW 51054, 'El socio debe ser de categoría MAYOR.', 1;

	-- Fecha de emisión no futura
	IF @fechaEmision > GETDATE()
		THROW 51055, 'La fecha de emisión no puede ser posterior a hoy.', 1;
END;
GO


-- Crear Factura
CREATE OR ALTER PROCEDURE Factura.CrearFactura
	@puntoDeVenta CHAR(4) = '0001',
	@tipoFactura CHAR(1) = 'C',
	@fechaEmision DATE = NULL,
	@idSocio INT,
	@idFactura INT OUTPUT
AS
BEGIN
	
	IF @fechaEmision IS NULL
		SELECT @fechaEmision = GETDATE();

	EXEC Factura.ValidarCabeceraFactura 
		@puntoDeVenta = @puntoDeVenta,
		@tipoFactura = @tipoFactura,
		@fechaEmision = @fechaEmision,
		@idSocio = @idSocio;

	INSERT INTO Factura.Factura (
		puntoDeVenta,
		tipoFactura,
		fechaEmision,
		idSocio
	)
	VALUES (
		@puntoDeVenta,
		@tipoFactura,
		@fechaEmision,
		@idSocio
	);

	SET @idFactura = SCOPE_IDENTITY();
END
GO


CREATE OR ALTER PROCEDURE Factura.ActualizarCabeceraFactura
	@idFactura INT,
	@puntoDeVenta CHAR(4) = NULL,
	@tipoFactura CHAR(1) = NULL,
	@fechaEmision DATE = NULL,
	@idSocio INT = NULL

AS
BEGIN

	IF @idFactura IS NULL
		THROW 51056, 'El idFactura ingresado es NULL.', 1;
	--Validaciones basicas.
	IF NOT EXISTS (SELECT 1 FROM Factura.Factura WHERE idFactura = @idFactura)
	BEGIN
		DECLARE @mensajeFactura VARCHAR(100);
		SET @mensajeFactura = 'No existe una factura de ID ' + CAST(@idFactura AS VARCHAR);
		THROW 51057, @mensajeFactura, 1;
	END

	IF 'Borrador' <> (SELECT estado FROM Factura.Factura WHERE idFactura = @idFactura)
		THROW 51058, 'La factura ya fue emitida, no se puede modificar.', 1;

	IF @puntoDeVenta		IS NULL
		AND @tipoFactura	IS NULL
		AND @fechaEmision	IS NULL
		AND @idSocio		IS NULL
			THROW 51059, 'Debe proveer al menos un campo a modificar.', 1;
	

	--Verificar parametros
	SELECT 
		@puntoDeVenta = COALESCE(@puntoDeVenta, puntoDeVenta),
		@tipoFactura = COALESCE(@tipoFactura, tipoFactura),
		@fechaEmision = COALESCE(@fechaEmision, fechaEmision),
		@idSocio = COALESCE(@idSocio, idSocio)
	FROM Factura.Factura
	WHERE idFactura = @idFactura;

	EXEC Factura.ValidarCabeceraFactura 
		@puntoDeVenta = @puntoDeVenta,
		@tipoFactura = @tipoFactura,
		@fechaEmision = @fechaEmision,
		@idSocio = @idSocio;
	

	--Actualizar

	UPDATE Factura.Factura
	SET
		puntoDeVenta = @puntoDeVenta,
		tipoFactura = @tipoFactura,
		fechaEmision = @fechaEmision,
		idSocio = @idSocio
	WHERE idFactura = @idFactura;

END;
GO


CREATE OR ALTER PROCEDURE Factura.ActualizarEstadoFactura
	@idFactura INT,
	@estadoNuevo VARCHAR(20)
AS
BEGIN
	--Validaciones basicas.

	IF @estadoNuevo NOT IN ('Borrador','Emitida','Pagada','Vencida','Cancelada')
		THROW 51058, 'Estado inválido.', 1;

	IF NOT EXISTS (SELECT 1 FROM Factura.Factura WHERE idFactura = @idFactura)
	BEGIN
		DECLARE @mensajeFactura VARCHAR(100);
		SET @mensajeFactura = 'No existe una factura de ID ' + CAST(@idFactura AS VARCHAR);
		THROW 51060, @mensajeFactura, 1;
	END


	DECLARE @estadoFactura VARCHAR(20);

	SELECT @estadoFactura = estado
	FROM Factura.Factura
	WHERE idFactura = @idFactura;


	--Cambios de estados posibles.

	IF @estadoFactura = 'Borrador' AND @estadoNuevo NOT IN ('Emitida', 'Cancelada')
		THROW 51061, 'Una factura en estado Borrador solo puede pasar a: Emitida, Cancelada', 1;

	IF @estadoFactura = 'Emitida' 
		THROW 51062, 'Una factura en estado Emitida no puede cambiar de estado manualmente.
						Emitida -> Cancelada: A traves de una Nota de Credito.
						Emitida -> Pagada: A traves de un registro de Pago.
						Emitida -> Vencida: A traves de un Job que verifique si la Factura esta vencida.
						Emitida -> Borrador: Ya fue emitida, no es posible.', 1;

	IF @estadoFactura IN ('Pagada', 'Cancelada', 'Vencida')
		THROW 51063, 'Una factura en estado Pagada/Cancelada/Vencida no puede modificar su estado.', 1;


	--Actualizar

	UPDATE Factura.Factura
	SET
		estado = @estadoNuevo
	WHERE idFactura = @idFactura;

END;
GO


CREATE OR ALTER PROCEDURE Factura.EliminarFactura
	@idFactura INT
AS
BEGIN
	
	IF @idFactura IS NULL
		THROW 51064, 'El idFactura ingresado es NULL.', 1;

	IF NOT EXISTS (SELECT 1 FROM Factura.Factura WHERE idFactura = @idFactura)
	BEGIN
		DECLARE @mensajeFactura VARCHAR(100);
		SET @mensajeFactura = 'No existe una factura de ID ' + CAST(@idFactura AS VARCHAR);
		THROW 51065, @mensajeFactura, 1;
	END


	DECLARE @estadoFactura VARCHAR(20);

	SELECT @estadoFactura = estado
	FROM Factura.Factura
	WHERE idFactura = @idFactura;


	IF @estadoFactura <> 'Borrador'
		THROW 51066, 'La factura no esta en estado Borrador, no se puede eliminar.', 1;
	
	IF EXISTS(SELECT 1 FROM Factura.Factura f JOIN Factura.DetalleFactura df ON df.idFactura = f.idFactura WHERE f.idFactura = @idFactura)
		THROW 51067, 'No se puede eliminar la Factura ya que contiene Detalles. Elimine primero los detalles.', 1;


	--Elimino la factura.
	DELETE FROM Factura.Factura
	WHERE idFactura = @idFactura;


END;
GO