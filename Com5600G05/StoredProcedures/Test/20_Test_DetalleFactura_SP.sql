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
			Scripts: 00_CreacionTablas.sql, 01_InsercionDatosBasicos.sql
			Stored Procedures: 01_PersonaSP.sql, 03_SocioSP.sql, 19_FacturaSP.sql
		

    ---------------------------------------------------------------------
*/

USE Com5600G05;
GO

SET NOCOUNT ON;

--------------------------------------------------------------------------------
-- 0) Preparacion Datos Prueba.
--------------------------------------------------------------------------------



DECLARE @idPersona1      INT,
        @idPersona2      INT,
		@idSocio1		 INT,
		@idSocio2		 INT,
        @idCategoriaMayor INT,
        @idCategoriaMenor INT,
        @idObraSocial     INT,
		@idFactura1		  INT,
		@idFactura2	      INT;

-- Insertar dos personas de prueba
EXEC Persona.CrearPersona
    @dni                = 42819058,
    @nombre             = 'Teo',
    @apellido           = 'Turri',
    @email              = 'teoturri12@gmail.com',
    @telefono           = '11111111',
    @telefonoEmergencia = '22222222',
    @fechaNacimiento    = '2000-11-23',
    @idPersona          = @idPersona1 OUTPUT;

EXEC Persona.CrearPersona
    @dni                = 11115555,
    @nombre             = 'Lionel',
    @apellido           = 'Messi',
    @email              = 'lionelmessi@gmail.com',
    @telefono           = '2222',
    @telefonoEmergencia = '3333',
    @fechaNacimiento    = '1980-04-24',
    @idPersona          = @idPersona2 OUTPUT;



-- Obtener IDs de categorías y obra social
SELECT @idCategoriaMayor = idCategoria FROM Socio.Categoria WHERE nombre = 'Mayor';
SELECT @idCategoriaMenor = idCategoria FROM Socio.Categoria WHERE nombre = 'Menor';
SELECT TOP 1 @idObraSocial = idObraSocial FROM Socio.ObraSocial;

-- Crear dos socios asociados a las personas de prueba
EXEC Socio.CrearSocioConObraSocialExistenteYPersonaExistente
    @idPersona    = @idPersona1,
    @idObraSocial = @idObraSocial,
    @nroObraSocial= 'P1234',
    @nroSocio     = 'P-5000',
    @idCategoria  = @idCategoriaMayor;

EXEC Socio.CrearSocioConObraSocialExistenteYPersonaExistente
    @idPersona    = @idPersona2,
    @idObraSocial = @idObraSocial,
    @nroObraSocial= 'P5555',
    @nroSocio     = 'P-5001',
    @idCategoria  = @idCategoriaMenor;




EXEC sp_set_session_context 'idSocio1',        @idPersona1;
EXEC sp_set_session_context 'idSocio2',        @idPersona2;
EXEC sp_set_session_context 'idCategoriaMayor',@idCategoriaMayor;
EXEC sp_set_session_context 'idCategoriaMenor',@idCategoriaMenor;
EXEC sp_set_session_context 'idObraSocial',    @idObraSocial;
EXEC sp_set_session_context 'idFactura1',       @idFactura1;
EXEC sp_set_session_context 'idFactura2',       @idFactura2;

--------------------------------------------------------------------------------
-- 1) Pruebas de Validación (`Factura.ValidarDetalleFactura`)
--------------------------------------------------------------------------------

-- Test 1.1:

PRINT '-------------- Test 1.1 --------------';
BEGIN TRY
    EXEC Factura.ValidarDetalleFacturaCuotaActividad
        @idFactura   = NULL,
        @descripcion = NULL;
END TRY
BEGIN CATCH
    PRINT CAST(ERROR_NUMBER() AS VARCHAR) + ' / ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test 1.2:
PRINT '-------------- Test 1.2 --------------';
BEGIN TRY
    EXEC Factura.ValidarDetalleFacturaCuotaActividad
        @idFactura   = -1,
        @descripcion = 'Cuota';
END TRY
BEGIN CATCH
    PRINT CAST(ERROR_NUMBER() AS VARCHAR) + ' / ' + ERROR_MESSAGE();
END CATCH;
GO


-- Test 1.1:


-- Test 1.1:

-- Test 1.1:

-- Test 1.1: