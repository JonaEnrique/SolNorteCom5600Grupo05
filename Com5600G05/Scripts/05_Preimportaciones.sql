/*
    ---------------------------------------------------------------------
    -Fecha: 20/06/2025
    -Grupo: 05
    -Materia: Bases de Datos Aplicada

    - Integrantes:
        - Nicolás Pérez       | 40015709
        - Santiago Sánchez    | 42281463
        - Jonathan Enrique    | 43301711
        - Teo Turri           | 42819058

    - Consigna: 
        Cargar en la base de datos los datos comunes que
		se utilizarán en los distintos stored procedures de importacion.
	- Notas:
		Asegurarse de modificar el parametro del store procedure: Socio.CargarObrasSociales, 
		para que apunte correctamente al archivo 'Datos socios.xlsx' local en su host. (Item 5)
		
    ---------------------------------------------------------------------
*/


USE Com5600G05						
GO

--------------------------------------------------------------------------------
-- 00 – CONFIGURACIÓN INICIAL
--------------------------------------------------------------------------------

-- Habilitar consultas Ad Hoc para OPENROWSET
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO

--------------------------------------------------------------------------------
-- 1) CARGA DE ACTIVIDADES DEPORTIVAS
--------------------------------------------------------------------------------
INSERT INTO Actividad.ActividadDeportiva (nombre)
SELECT v.nombre
FROM (VALUES
    ('Futsal'),
    ('Vóley'),
    ('Taekwondo'),
    ('Baile artístico'),
    ('Natación'),
    ('Ajederez')
) AS v(nombre)
WHERE NOT EXISTS (
    SELECT 1
    FROM Actividad.ActividadDeportiva d
    WHERE d.nombre = v.nombre
);
GO


--------------------------------------------------------------------------------
-- 2) CARGA DE CATEGORÍAS DE EDAD
--------------------------------------------------------------------------------
INSERT INTO Socio.Categoria (nombre, edadMinima, edadMaxima)
SELECT 
    v.nombre,
    v.edadMinima,
    v.edadMaxima
FROM (VALUES
    ('Menor',  NULL, 12),   -- Hasta 12 años inclusive
    ('Cadete', 13,   17),   -- De 13 a 17 años
    ('Mayor',  18,   NULL)  -- Desde 18 años en adelante
) AS v(nombre, edadMinima, edadMaxima)
WHERE NOT EXISTS (
    SELECT 1
    FROM Socio.Categoria c
    WHERE c.nombre = v.nombre
);
GO


--------------------------------------------------------------------------------
-- 3) CARGA DE FORMAS DE PAGO
--------------------------------------------------------------------------------
INSERT INTO Pago.FormaPago (nombre)
SELECT v.nombre
FROM (VALUES
    ('efectivo')
) AS v(nombre)
WHERE NOT EXISTS (
    SELECT 1
    FROM Pago.FormaPago f
    WHERE f.nombre = v.nombre
);
GO



--------------------------------------------------------------------------------
-- 4) PROCEDIMIENTO PARA CARGAR OBRAS SOCIALES DESDE EXCEL
--    Lee un archivo .xlsx y actualiza la tabla Socio.ObraSocial,
--------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE Importacion.CargarObrasSociales
    @rutaCompletaArchivo VARCHAR(260)
AS
BEGIN

    BEGIN TRY
        DECLARE @sql VARCHAR(1024);

        
        SET @sql = '
        INSERT INTO Socio.ObraSocial (nombre, telefono)
        SELECT DISTINCT
            TRIM([ Nombre de la obra social o prepaga]),
            TRIM([teléfono de contacto de emergencia ])
        FROM OPENROWSET(
            ''Microsoft.ACE.OLEDB.16.0'',
            ''Excel 12.0;HDR=YES;IMEX=1;Database=' + @rutaCompletaArchivo + ''',
            ''SELECT [ Nombre de la obra social o prepaga], [teléfono de contacto de emergencia ] 
              FROM [Responsables de Pago$]''
        ) AS datosExcel
        WHERE NOT EXISTS (
            SELECT 1
            FROM Socio.ObraSocial o
            WHERE o.nombre = TRIM([ Nombre de la obra social o prepaga]) COLLATE Modern_Spanish_CI_AS
        );';

        EXEC (@sql);

    END TRY
    BEGIN CATCH
		
        DECLARE @ErrorMensaje VARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(
            'Error en Importacion.CargarObrasSociales: %s', 
            16, 1, @ErrorMensaje
        );
    END CATCH
	
END;
GO

--------------------------------------------------------------------------------
-- 5) INVOCACIÓN DEL PROCEDIMIENTO
--    Asegurarse de ajustar la ruta al archivo Excel antes de ejecutar.
--------------------------------------------------------------------------------
EXEC Importacion.cargarObrasSociales
    @rutaCompletaArchivo = 'C:\Temp\Datos socios.xlsx';
GO



