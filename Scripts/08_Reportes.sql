USE Com5600G05						
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Reporte')
    EXEC('CREATE SCHEMA Reporte');
GO


--Reporte 3 
CREATE OR ALTER PROCEDURE Reporte.InasistenciasCategoriaActividad
AS
BEGIN
	SELECT ca.nombre AS Categoria, ad.nombre AS Actividad, COUNT(DISTINCT s.nroSocio) AS CantidadSociosConInasistencia
	FROM Asiste a
	JOIN Socio s ON s.idSocio = a.idSocio
	JOIN Categoria ca ON ca.idCategoria = s.idCategoria
	JOIN Clase cl ON cl.idClase = a.idClase
	JOIN ActividadDeportiva ad ON ad.idActividadDeportiva = cl.idActividadDeportiva
	WHERE a.asistencia <> 'P'
	GROUP BY ca.nombre, ad.nombre
	ORDER BY CantidadSociosConInasistencia DESC
	FOR XML PATH('Registro'), ROOT('ReporteInasistenciasCategoriaActividad');
END;

--Reporte 4
CREATE OR ALTER PROCEDURE Reporte.InasistenciasSocio
AS
BEGIN
	SELECT DISTINCT p.nombre as Nombre, p.apellido as Apellido, 
		  CASE
			WHEN DATEADD(year, DATEDIFF(year, p.fechaNac, GETDATE()), p.fechaNac) > GETDATE() 
				THEN DATEDIFF(year, p.fechaNac, GETDATE()) - 1
				ELSE DATEDIFF(year, p.fechaNac, GETDATE()) 
			END AS Edad,
			ca.nombre AS Categoria, 
			ad.nombre AS Actividad
	FROM Socio s
	JOIN Persona p ON p.idPersona = s.idSocio
	JOIN Categoria ca ON ca.idCategoria = s.idCategoria
	JOIN Asiste a ON a.idSocio = s.idSocio
	JOIN Clase c ON c.idClase = a.idClase
	JOIN ActividadDeportiva ad ON ad.idActividadDeportiva = c.idActividadDeportiva
	WHERE a.asistencia <> 'P'
	FOR XML PATH('Socio'), ROOT('ReporteInasistenciasSocio');
END;

