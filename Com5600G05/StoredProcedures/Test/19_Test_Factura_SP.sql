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
			Stored Procedures: 01_PersonaSP.sql, 03_SocioSP.sql
		

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
-- 1) Pruebas de Validación de Cabecera (`Factura.ValidarCabeceraFactura`)
--------------------------------------------------------------------------------


-- Test 1.1: 

PRINT '------------------------- Test 1.1 -------------------------';

DECLARE @idSocioTest1_1 INT   = CAST(SESSION_CONTEXT(N'idSocio1') AS INT);

BEGIN TRY
    PRINT 'ERROR: se esperaba THROW por puntoDeVenta NULL';
    EXEC Factura.ValidarCabeceraFactura 
        @puntoDeVenta = NULL,  -- error
        @tipoFactura  = 'A',
        @fechaEmision = '2025-07-03',
        @idSocio      = @idSocioTest1_1;
END TRY
BEGIN CATCH
    PRINT + CAST(ERROR_NUMBER() AS VARCHAR) + ' / ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test 1.2:

PRINT '------------------------- Test 1.2 -------------------------';

DECLARE @idSocioTest1_2 INT   = CAST(SESSION_CONTEXT(N'idSocio1') AS INT);

BEGIN TRY
    PRINT 'ERROR: se esperaba THROW por puntoDeVenta con caracteres que no son números.';
    EXEC Factura.ValidarCabeceraFactura 
        @puntoDeVenta = '1a23',  -- error
        @tipoFactura  = 'A',
        @fechaEmision = '2025-07-03',
        @idSocio      = @idSocioTest1_2;
END TRY
BEGIN CATCH
    PRINT + CAST(ERROR_NUMBER() AS VARCHAR) + ' / ' + ERROR_MESSAGE();
END CATCH;
GO



-- Test 1.3:

PRINT '------------------------- Test 1.3 -------------------------';

DECLARE @idSocioTest1_3 INT   = CAST(SESSION_CONTEXT(N'idSocio1') AS INT);

BEGIN TRY
    PRINT 'ERROR: se esperaba THROW por tipoFactura inválido';
    EXEC Factura.ValidarCabeceraFactura 
        @puntoDeVenta = '0001',
        @tipoFactura  = 'X',   -- error
        @fechaEmision = '2025-07-03',
        @idSocio      = @idSocioTest1_3;
END TRY
BEGIN CATCH
    PRINT  + CAST(ERROR_NUMBER() AS VARCHAR) + ' / ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test 1.4:

PRINT '------------------------- Test 1.4 -------------------------';

DECLARE @idSocioTest1_4 INT   = (SELECT TOP 1 idSocio + 1 FROM Socio.Socio ORDER BY idSocio DESC);

BEGIN TRY
    PRINT 'ERROR: se esperaba THROW por idSocio inexistente';
    EXEC Factura.ValidarCabeceraFactura 
        @puntoDeVenta = '0001',
        @tipoFactura  = 'B',
        @fechaEmision = '2025-07-03',
        @idSocio      = @idSocioTest1_4;            -- error 
END TRY
BEGIN CATCH
    PRINT + CAST(ERROR_NUMBER() AS VARCHAR) + ' / ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test 1.5

PRINT '------------------------- Test 1.5 -------------------------';

DECLARE @idSocioTest1_5 INT   = CAST(SESSION_CONTEXT(N'idSocio2') AS INT);


BEGIN TRY
    PRINT 'ERROR: se esperaba THROW por ser un Socio <> ''Mayor''';
    EXEC Factura.ValidarCabeceraFactura 
        @puntoDeVenta = '0001',
        @tipoFactura  = 'B',
        @fechaEmision = '2025-07-03',
        @idSocio      = @idSocioTest1_5;            -- error 
END TRY
BEGIN CATCH
    PRINT + CAST(ERROR_NUMBER() AS VARCHAR) + ' / ' + ERROR_MESSAGE();
END CATCH;
GO


-- Test 1.6:

PRINT '------------------------- Test 1.6 -------------------------';

DECLARE @idSocioTest1_6 INT   = CAST(SESSION_CONTEXT(N'idSocio1') AS INT);
DECLARE @fechaMañana DATE = DATEADD(DAY,1,GETDATE());

BEGIN TRY
    PRINT 'ERROR: se esperaba THROW por fecha futura';
    EXEC Factura.ValidarCabeceraFactura 
        @puntoDeVenta = '0001',
        @tipoFactura  = 'A',
        @fechaEmision = @fechaMañana,  -- error
        @idSocio      = @idSocioTest1_6;
END TRY
BEGIN CATCH
    PRINT + CAST(ERROR_NUMBER() AS VARCHAR) + ' / ' + ERROR_MESSAGE();
END CATCH;
GO



-- Test 1.7

PRINT '------------------------- Test 1.7 -------------------------';

DECLARE @idSocioTest1_7 INT   = CAST(SESSION_CONTEXT(N'idSocio1') AS INT);
BEGIN TRY
    PRINT 'EXITO: Validación Correcta';
    EXEC Factura.ValidarCabeceraFactura 
        @puntoDeVenta = '0001',
        @tipoFactura  = 'C',
        @fechaEmision = '2025-07-03',
        @idSocio      = @idSocioTest1_7;
END TRY
BEGIN CATCH
    PRINT + CAST(ERROR_NUMBER() AS VARCHAR) + ' / ' + ERROR_MESSAGE();
END CATCH;
GO


--------------------------------------------------------------------------------
-- 2) Insersión de una Factura (`Factura.CrearFactura`)
--------------------------------------------------------------------------------

-- Test 2.1

PRINT '------------------------- Test 2.1 -------------------------';

DECLARE @idSocioTest2_1 INT   = CAST(SESSION_CONTEXT(N'idSocio1') AS INT);
DECLARE @idFacturaTest2_1 INT;

BEGIN TRY
    PRINT 'EXITO: Insersion Factura solo con el idSocio';
    EXEC Factura.CrearFactura
        @idSocio      = @idSocioTest2_1,
		@idFactura	  = @idFacturaTest2_1 OUTPUT
END TRY
BEGIN CATCH
    PRINT + CAST(ERROR_NUMBER() AS VARCHAR) + ' / ' + ERROR_MESSAGE();
END CATCH;

EXEC sp_set_session_context 'idFactura1',    @idFacturaTest2_1;

--SELECT @idSocioTest2_1 AS idSocio
--SELECT * FROM Factura.Factura WHERE idFactura = @@idFacturaTest2_1;

GO

-- Test 2.2

PRINT '------------------------- Test 2.2 -------------------------';

DECLARE @idSocioTest2_2 INT   = CAST(SESSION_CONTEXT(N'idSocio1') AS INT);
DECLARE @idFacturaTest2_2 INT;

BEGIN TRY
    PRINT 'EXITO: Insersion Factura solo con todos los parametros.';
    EXEC Factura.CrearFactura
		@puntoDeVenta = '0001',
        @tipoFactura  = 'C',
        @fechaEmision = '2025-07-03',
        @idSocio      = @idSocioTest2_2,
		@idFactura	  = @idFacturaTest2_2 OUTPUT;
END TRY
BEGIN CATCH
    PRINT + CAST(ERROR_NUMBER() AS VARCHAR) + ' / ' + ERROR_MESSAGE();
END CATCH;

--SELECT @idSocioTest2_2 AS idSocio
--SELECT * FROM Factura.Factura WHERE idFactura = @idFacturaTest2_2;

EXEC sp_set_session_context 'idFactura2',    @idFacturaTest2_2;
GO


--------------------------------------------------------------------------------
-- 3) Actualizar estado de una Factura (`Factura.ActualizarEstadoFactura`)
--------------------------------------------------------------------------------

-- Test 3.1:

PRINT '------------------------- Test 3.1 -------------------------';

DECLARE @idFacturaTest3_1 INT = CAST(SESSION_CONTEXT(N'idFactura1') AS INT);          

BEGIN TRY
    PRINT 'ERROR: Se esperaba THROW por estado inválido.';
    EXEC Factura.ActualizarEstadoFactura
        @idFactura    = @idFacturaTest3_1,
        @estadoNuevo  = 'No emitida';
END TRY
BEGIN CATCH
    PRINT CAST(ERROR_NUMBER() AS VARCHAR) + ' / ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test 3.2:

PRINT '------------------------- Test 3.2 -------------------------';

DECLARE @idFacturaTest3_2 INT = (SELECT TOP 1 idFactura + 1 FROM Factura.Factura ORDER BY idFactura DESC);

BEGIN TRY
    PRINT 'ERROR: Se esperaba THROW por no existir una Factura con el id ingresado.';
    EXEC Factura.ActualizarCabeceraFactura
        @idFactura      = @idFacturaTest3_2;
END TRY
BEGIN CATCH
    PRINT + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO
-- Test 3.3:

PRINT '------------------------- Test 3.3 -------------------------';

DECLARE @idFacturaTest3_3 INT = CAST(SESSION_CONTEXT(N'idFactura1') AS INT);          

BEGIN TRY
    PRINT 'ERROR: Se esperaba THROW por querer pasar a un estado distinto de Borrador -> (Emitida, Cancelada)';
    EXEC Factura.ActualizarEstadoFactura
        @idFactura    = @idFacturaTest3_3,
        @estadoNuevo  = 'Pagada';
END TRY
BEGIN CATCH
    PRINT CAST(ERROR_NUMBER() AS VARCHAR) + ' / ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test 3.4:

PRINT '------------------------- Test 3.4 -------------------------';

DECLARE @idFacturaTest3_4 INT = CAST(SESSION_CONTEXT(N'idFactura2') AS INT);          

BEGIN TRY
    PRINT 'EXITO: Borrador -> Emitida';
    EXEC Factura.ActualizarEstadoFactura
        @idFactura    = @idFacturaTest3_4,
        @estadoNuevo  = 'Emitida';
END TRY
BEGIN CATCH
    PRINT CAST(ERROR_NUMBER() AS VARCHAR) + ' / ' + ERROR_MESSAGE();
END CATCH;

--SELECT * FROM Factura.Factura WHERE idFactura = @idFacturaTest3_4;
GO


-- Test 3.5:
PRINT '------------------------- Test 3.5 -------------------------';

DECLARE @idFacturaTest3_5 INT = CAST(SESSION_CONTEXT(N'idFactura2') AS INT);  

BEGIN TRY
    PRINT 'ERROR: Se esperaba THROW por querer pasar de Emitida -> Borrador';
    EXEC Factura.ActualizarEstadoFactura
        @idFactura    = @idFacturaTest3_5,
        @estadoNuevo  = 'Borrador';
END TRY
BEGIN CATCH
    PRINT CAST(ERROR_NUMBER() AS VARCHAR) + ' / ' + ERROR_MESSAGE();
END CATCH;
GO
-- Test 3.6:

PRINT '------------------------- Test 3.6 -------------------------';

DECLARE @idFacturaTest3_6 INT = CAST(SESSION_CONTEXT(N'idFactura2') AS INT);          


BEGIN TRY
    PRINT 'ERROR: Se espera THROW ya que una Factura en estado Emitida no puede cambiar su estado manualmente.';
    EXEC Factura.ActualizarEstadoFactura
        @idFactura    = @idFacturaTest3_6,
        @estadoNuevo  = 'Vencida';
END TRY
BEGIN CATCH
    PRINT CAST(ERROR_NUMBER() AS VARCHAR) + ' / ' + ERROR_MESSAGE();
END CATCH;

--SELECT * FROM Factura.Factura WHERE idFactura = @idFacturaTest3_6;
GO


-- Test 3.7:
PRINT '------------------------- Test 3.7 -------------------------';

DECLARE @idFacturaTest3_7 INT = CAST(SESSION_CONTEXT(N'idFactura2') AS INT);  

UPDATE Factura.Factura
SET estado = 'Pagada'
WHERE idFactura = @idFacturaTest3_7;


BEGIN TRY
    PRINT 'ERROR: Se esperaba THROW por querer cambiar de estado Pagada/Vencida/Cancelada manualmente.';
    EXEC Factura.ActualizarEstadoFactura
        @idFactura    = @idFacturaTest3_7,
        @estadoNuevo  = 'Borrador';
END TRY
BEGIN CATCH
    PRINT CAST(ERROR_NUMBER() AS VARCHAR) + ' / ' + ERROR_MESSAGE();
END CATCH;
GO



--------------------------------------------------------------------------------
-- 4) Actualizar cabecera de una Factura (`Factura.ActualizarCabeceraFactura`)
--------------------------------------------------------------------------------

-- Test 4.1

PRINT '------------------------- Test 4.1 -------------------------';

BEGIN TRY
    PRINT 'ERROR: Se esperaba THROW por idFactura NULL.';
    EXEC Factura.ActualizarCabeceraFactura
        @idFactura      = NULL;
END TRY
BEGIN CATCH
    PRINT + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test 4.2

PRINT '------------------------- Test 4.2 -------------------------';

DECLARE @idFacturaTest4_2 INT = (SELECT TOP 1 idFactura + 1 FROM Factura.Factura ORDER BY idFactura DESC);

BEGIN TRY
    PRINT 'ERROR: Se esperaba THROW por no existir una Factura con el id ingresado.';
    EXEC Factura.ActualizarCabeceraFactura
        @idFactura      = @idFacturaTest4_2;
END TRY
BEGIN CATCH
    PRINT + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test 4.3
PRINT '------------------------- Test 4.3 -------------------------';

DECLARE @idFacturaTest4_3 INT = CAST(SESSION_CONTEXT(N'idFactura2') AS INT);  

UPDATE Factura.Factura
SET estado = 'Emitida'
WHERE idFactura = @idFacturaTest4_3;


BEGIN TRY
    PRINT 'ERROR: Se esperaba THROW por querer modificar una Factura ya emitida.';
    EXEC Factura.ActualizarCabeceraFactura
        @idFactura      = @idFacturaTest4_3;
END TRY
BEGIN CATCH
    PRINT + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test 4.4

PRINT '------------------------- Test 4.4 -------------------------';

DECLARE @idFacturaTest4_4 INT = CAST(SESSION_CONTEXT(N'idFactura1') AS INT);  

BEGIN TRY
    PRINT 'ERROR: idFactura es valido pero todos los demas parametros son NULL.';
    EXEC Factura.ActualizarCabeceraFactura
        @idFactura      = @idFacturaTest4_4,
		@puntoDeVenta = NULL,
		@tipoFactura  = NULL,
		@fechaEmision = NULL,
		@idSocio =	NULL;
END TRY
BEGIN CATCH
    PRINT + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO


-- Test 4.5

PRINT '------------------------- Test 4.5 -------------------------';

DECLARE @idFacturaTest4_5 INT = CAST(SESSION_CONTEXT(N'idFactura1') AS INT);  

BEGIN TRY
    PRINT 'EXITO: Factura actualizada correctamente.';
    EXEC Factura.ActualizarCabeceraFactura
        @idFactura      = @idFacturaTest4_5,
		@puntoDeVenta = '0002',
		@tipoFactura  = NULL,
		@fechaEmision = NULL,
		@idSocio =	NULL;
END TRY
BEGIN CATCH
    PRINT + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 5) Actualizar cabecera de una Factura (`Factura.ActualizarCabeceraFactura`)
--------------------------------------------------------------------------------

--Test 5.1:

PRINT '------------------------- Test 5.1 -------------------------';

BEGIN TRY
    PRINT 'ERROR: Se esperaba THROW por idFactura NULL.';
    EXEC Factura.EliminarFactura
        @idFactura      = NULL;
END TRY
BEGIN CATCH
    PRINT + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO


--Test 5.2:

PRINT '------------------------- Test 5.2 -------------------------';

DECLARE @idFacturaTest5_2 INT = (SELECT TOP 1 idFactura + 1 FROM Factura.Factura ORDER BY idFactura DESC);

BEGIN TRY
    PRINT 'ERROR: Se esperaba THROW por no existir una Factura con el id ingresado.';
    EXEC Factura.ActualizarCabeceraFactura
        @idFactura      = @idFacturaTest5_2;
END TRY
BEGIN CATCH
    PRINT + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO


--Test 5.3:

PRINT '------------------------- Test 5.3 -------------------------';

DECLARE @idFacturaTest5_3 INT = CAST(SESSION_CONTEXT(N'idFactura2') AS INT);

BEGIN TRY
    PRINT 'ERROR: Se esperaba THROW al querer borrar una Factura que ya fue Emitida.';
    EXEC Factura.EliminarFactura
        @idFactura      = @idFacturaTest5_3;
END TRY
BEGIN CATCH
    PRINT + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

--Test 5.4:

--Insertar un detalle de factura e intentar eliminar la Factura.

--Test 5.5:

PRINT '------------------------- Test 5.5 -------------------------';

DECLARE @idFacturaTest5_5 INT = CAST(SESSION_CONTEXT(N'idFactura1') AS INT);

BEGIN TRY
    PRINT 'EXITO: Factura en Borrador eliminada correctamente.';
    EXEC Factura.EliminarFactura
        @idFactura      = @idFacturaTest5_5;
END TRY
BEGIN CATCH
    PRINT + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO





--------------------------------------------------------------------------------
-- LIMPIEZA: Eliminación de las entidades de prueba y las variables de sesión
--------------------------------------------------------------------------------


DECLARE @idPersona1_Eliminacion INT   = CAST(SESSION_CONTEXT(N'idSocio1') AS INT);
DECLARE @idPersona2_Eliminacion INT   = CAST(SESSION_CONTEXT(N'idSocio2') AS INT);
DECLARE @idFactura1_Eliminacion INT   = CAST(SESSION_CONTEXT(N'idFactura1') AS INT);
DECLARE @idFactura2_Eliminacion INT   = CAST(SESSION_CONTEXT(N'idFactura2') AS INT);


DELETE FROM Factura.Factura
	 WHERE idFactura IN (@idFactura1_Eliminacion, @idFactura2_Eliminacion);

DELETE FROM Socio.Socio 
     WHERE idSocio IN (@idPersona1_Eliminacion, @idPersona2_Eliminacion);

DELETE FROM Persona.Persona 
     WHERE idPersona IN (@idPersona1_Eliminacion, @idPersona2_Eliminacion);
GO

EXEC sp_set_session_context 'idSocio1',        NULL;
EXEC sp_set_session_context 'idSocio2',        NULL;
EXEC sp_set_session_context 'idCategoriaMayor',NULL;
EXEC sp_set_session_context 'idCategoriaMenor',NULL;
EXEC sp_set_session_context 'idObraSocial',    NULL;
EXEC sp_set_session_context 'idFactura1',    NULL;
EXEC sp_set_session_context 'idFactura2',    NULL;
