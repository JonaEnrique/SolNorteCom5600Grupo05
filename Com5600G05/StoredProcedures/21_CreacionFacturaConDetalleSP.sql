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

IF TYPE_ID(N'Factura.DetalleFacturaTipo') IS NULL
BEGIN
  CREATE TYPE Factura.DetalleFacturaTipo AS TABLE
  (
    descripcion            VARCHAR(50) NOT NULL,  
    idSocioBeneficiario    INT          NOT NULL
  );
END
GO


CREATE OR ALTER PROCEDURE Factura.WrapperCrearFacturaConDetalle
	@puntoDeVenta CHAR(4) = '0001',
	@tipoFactura CHAR(1) = 'C',
	@fechaEmision DATE = NULL,
	@idPersona INT,
	@detalles Factura.DetalleFacturaTipo READONLY,
	@idFactura INT OUTPUT
AS
BEGIN
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		
		BEGIN TRAN;

		DECLARE @idFacturaCreada INT;

		--Creo Factura
		EXEC Factura.CrearFactura @puntoDeVenta = @puntoDeVenta, @tipoFactura = @tipoFactura, 
			@fechaEmision = @fechaEmision, @idPersona = @idPersona, @idFactura = @idFacturaCreada OUTPUT

        --Creo detalles dinamicamente
		DECLARE @sql VARCHAR(MAX) = '';
		SELECT @sql +=
				'EXEC Factura.CrearDetalleFactura' 
				+ ' @idFactura = ' + CAST(@idFacturaCreada AS VARCHAR(10)) +', ' 
				+ ' @descripcion = ''' + descripcion + ''', '
				+ ' @idSocioBeneficiario = ' + CAST(idSocioBeneficiario AS VARCHAR(10)) + ' ; '
		FROM @detalles;

		EXEC(@sql);

		EXEC Factura.ActualizarEstadoFactura @idFactura = @idFacturaCreada, @estadoNuevo = 'Emitida';

		SET @idFactura = @idFacturaCreada;
		COMMIT;

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH;

END;



