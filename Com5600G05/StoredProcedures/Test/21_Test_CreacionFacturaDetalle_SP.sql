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
			Stored Procedures: 01_PersonaSP.sql, 02_SocioSP.sql, 03_SocioSP.sql, 04_GrupoFamiliarSP.sql,
							   19_FacturaSP,  20_DetalleFacturaSP, 21_CreacionFacturaDetalleSP
							  
		

    ---------------------------------------------------------------------
*/

USE Com5600G05;
GO


--Test 1: Insercion de una Factura con Detalles para Socio sin GrupoFamiliar.

BEGIN TRY
	SET XACT_ABORT ON;
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



--Test 2: Insercion de una Factura con Detalles para Socio sin GrupoFamiliar. (Aplican descuentos por grupo Familiar y por actividades deportivas)

BEGIN TRY
	SET XACT_ABORT ON;
    BEGIN TRAN;

    -- 0. Datos de prueba
    DECLARE 
        @idSocio1           INT,
		@idSocio2           INT,
        @idCategoriaMayor   INT,
		@idCategoriaMenor	INT,
        @idObraSocial       INT,
        @idFactura          INT,
		@idGrupoFamiliar	INT;
	
	

    -- 0.1 Creo personas y socios
    EXEC Persona.CrearPersona
        @dni                = 42819058,
        @nombre             = 'Teo',
        @apellido           = 'Turri',
        @email              = 'teoturri12@gmail.com',
        @telefono           = '11111111',
        @telefonoEmergencia = '22222222',
        @fechaNacimiento    = '2000-11-23',
        @idPersona          = @idSocio1 OUTPUT;

	EXEC Persona.CrearPersona
        @dni                = 44442222,
        @nombre             = 'Nico',
        @apellido           = 'Perez',
        @email              = 'nicoperez@gmail.com',
        @telefono           = '2222',
        @telefonoEmergencia = '3333',
        @fechaNacimiento    = '2001-11-23',
        @idPersona          = @idSocio2 OUTPUT;


    SELECT @idCategoriaMayor = idCategoria 
		FROM Socio.Categoria 
     WHERE nombre = 'Mayor';

	 SELECT @idCategoriaMenor = idCategoria 
		FROM Socio.Categoria 
     WHERE nombre = 'Menor';

    SELECT TOP 1 @idObraSocial = idObraSocial 
		FROM Socio.ObraSocial;

    EXEC Socio.CrearSocioConObraSocialExistenteYPersonaExistente
        @idPersona    = @idSocio1,
        @idObraSocial = @idObraSocial,
        @nroObraSocial= 'P1234',
        @nroSocio     = 'P-5001',
        @idCategoria  = @idCategoriaMayor;

	 EXEC Socio.CrearSocioConObraSocialExistenteYPersonaExistente
        @idPersona    = @idSocio2,
        @idObraSocial = @idObraSocial,
        @nroObraSocial= 'P1234',
        @nroSocio     = 'P-5002',
        @idCategoria  = @idCategoriaMenor;

	EXEC Socio.CrearGrupoFamiliar
        @idSocioTutor = @idSocio1,
		@idSocioMenor = @idSocio2,
		@parentesco = NULL,
		@idGrupoFamiliar = @idGrupoFamiliar OUTPUT;

    -- 1. Test de inserción masiva con el wrapper
    DECLARE @detalles Factura.DetalleFacturaTipo;
    INSERT INTO @detalles (descripcion, idSocioBeneficiario)
    VALUES
      ('Cuota',        @idSocio1),
      ('Taekwondo',    @idSocio1),
	  ('Cuota',		   @idSocio2),
      ('Futsal',	   @idSocio2),
	  ('Taekwondo',	   @idSocio2);

    EXEC Factura.WrapperCrearFacturaConDetalle
      @idPersona = @idSocio1,
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
	WHERE idSocioBeneficiario IN (@idSocio1, @idSocio2);

    DELETE FROM Factura.Factura
     WHERE idPersona IN (@idSocio1, @idSocio2);

	DELETE FROM Socio.GrupoFamiliar
     WHERE idGrupoFamiliar = @idGrupoFamiliar;

    DELETE FROM Socio.Socio
     WHERE idSocio IN (@idSocio1, @idSocio2);

    DELETE FROM Persona.Persona
     WHERE idPersona IN (@idSocio1, @idSocio2);

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



--Test 3: Creacion Nota de debito.

BEGIN TRY
	SET XACT_ABORT ON;
    BEGIN TRAN;

    -- 0. Datos de prueba
    DECLARE 
        @idSocio          INT,
        @idCategoriaMayor   INT,
        @idObraSocial       INT,
        @idFactura          INT;
	
	

    -- 0.1 Creo personas y socios
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
        @nroSocio     = 'P-5001',
        @idCategoria  = @idCategoriaMayor;


    -- 1. Test de inserción masiva con el wrapper
    DECLARE @detalles Factura.DetalleFacturaTipo;
    INSERT INTO @detalles (descripcion, idSocioBeneficiario)
    VALUES
      ('Cuota',        @idSocio);


	DECLARE @fechaEmisionFactura DATE = DATEADD(DAY, -12, GETDATE());


    EXEC Factura.WrapperCrearFacturaConDetalle
	  @fechaEmision = @fechaEmisionFactura,
      @idPersona = @idSocio,
      @detalles  = @detalles,
      @idFactura = @idFactura OUTPUT;

	
	EXEC Factura.RecargarFacturaAutomaticamente;

    -- 2. Verifico resultados
    SELECT f.*, nd.*
      FROM Factura.Factura f
      JOIN Factura.DetalleFactura df
        ON df.idFactura = f.idFactura
	  JOIN Factura.NotaDebito nd
		ON nd.idFactura = f.idFactura
     WHERE f.idFactura = @idFactura;


	DISABLE TRIGGER Factura.NoEliminarNotaDebito ON Factura.NotaDebito;

    -- 3. Limpieza de datos de prueba
    DELETE FROM Factura.DetalleFactura
	WHERE idSocioBeneficiario IN (@idSocio);

	DELETE FROM Factura.NotaDebito
	WHERE idFactura IN (@idFactura);

    DELETE FROM Factura.Factura
     WHERE idPersona IN (@idSocio);


    DELETE FROM Socio.Socio
     WHERE idSocio IN (@idSocio);

    DELETE FROM Persona.Persona
     WHERE idPersona IN (@idSocio);

	 ENABLE TRIGGER Factura.NoEliminarNotaDebito ON Factura.NotaDebito;

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

