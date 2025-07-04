/*
    ---------------------------------------------------------------------
    -Fecha: 03/07/2025
    -Grupo: 05
    -Materia: Bases de Datos Aplicada

    - Integrantes:
        - Nicolás Pérez       | 40015709
        - Santiago Sánchez    | 42281463
        - Jonathan Enrique    | 43301711
        - Teo Turri           | 42819058

    - Consigna: 
        Lote de pruebas para la tabla indicada en el nombre del archivo .sql
	- Aclaracion:
		El script se puede correr de una sola ejecucion, o ejecuciones por modulo.

		Se deben haber ejecutado los siguientes archivos sql:
			Scripts: 00_CreacionTablas.sql, 01_InsercionDatosBasicos.sql, 02_Preimportaciones, 03_Importaciones, 04_EjecucionImportaciones
			Stored Procedures: 01_PersonaSP.sql, 03_SocioSP.sql, 19_FacturaSP, 20_DetalleFacturaSP, 21_CreacionFacturaDetalleSP
		

    ---------------------------------------------------------------------
*/

USE Com5600G05;
GO
SET NOCOUNT ON;



BEGIN TRY
    BEGIN TRAN;

    -- 0. Datos de prueba
    DECLARE 
        @idSocio            INT,
        @idCategoriaMayor   INT,
        @idObraSocial       INT,
        @idFactura          INT;

    -- 0.1 Creo persona y socio
    EXEC Persona.CrearPersona
        @dni                = 42819058,
        @nombre             = 'Teo',
        @apellido           = 'Turri',
        @email              = 'teoturri12@gmail.com',
        @telefono           = '11111111',
        @telefonoEmergencia = '22222222',
        @fechaNacimiento    = '2000-11-23',
        @idPersona          = @idSocio OUTPUT;

    SELECT @idCategoriaMayor = idCategoria 
      FROM Socio.Categoria 
     WHERE nombre = 'Mayor';

    SELECT TOP 1 @idObraSocial = idObraSocial 
      FROM Socio.ObraSocial;

    EXEC Socio.CrearSocioConObraSocialExistenteYPersonaExistente
        @idPersona    = @idSocio,
        @idObraSocial = @idObraSocial,
        @nroObraSocial= 'P1234',
        @nroSocio     = 'P-5000',
        @idCategoria  = @idCategoriaMayor;

    -- 1. Test de inserción masiva con el wrapper
    DECLARE @detalles Factura.DetalleFacturaTipo;
    INSERT INTO @detalles (descripcion, idSocioBeneficiario)
    VALUES
      ('Cuota',        @idSocio),
      ('Taekwondo',    @idSocio),
      ('UsoPileta:Mes',@idSocio);

    EXEC Factura.WrapperCrearFacturaConDetalle
      @idPersona = @idSocio,
      @detalles  = @detalles,
      @idFactura = @idFactura OUTPUT;



    -- 2. Verifico resultados
    SELECT f.*, df.*
      FROM Factura.Factura f
      JOIN Factura.DetalleFactura df 
        ON df.idFactura = f.idFactura
     WHERE f.idFactura = @idFactura;


    -- 3. Limpieza de datos de prueba
    DELETE FROM Factura.DetalleFactura
	WHERE idSocioBeneficiario = @idSocio;

    DELETE FROM Factura.Factura
     WHERE idPersona = @idSocio;

    DELETE FROM Socio.Socio
     WHERE idSocio = @idSocio;

    DELETE FROM Persona.Persona
     WHERE idPersona = @idSocio;

    COMMIT;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK;

    DECLARE 
        @ErrMsg   NVARCHAR(4000) = ERROR_MESSAGE();
    THROW 70000, @ErrMsg, 1
END CATCH;
GO