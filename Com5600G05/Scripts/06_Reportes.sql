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
        Generacion de los reportes solicitados.
    ---------------------------------------------------------------------
*/


USE Com5600G05						
GO




--------------------------------------------------------------------------------
--REPORTE 1
--------------------------------------------------------------------------------



CREATE OR ALTER PROCEDURE Reporte.ListadoSociosMorosos
	@FechaInicio DATE,
	@FechaFin DATE
AS
BEGIN

	WITH SociosQueIncumplieron AS (

		SELECT DISTINCT
			f.idPersona,
			s.nroSocio,
			p.nombre + ' ' + p.apellido AS NombreApellido,
			FORMAT(f.fechaEmision, 'MMMM yyyy', 'es-ES') AS MesIncumplido
		FROM Factura.Factura  f
		JOIN Factura.DetalleFactura df ON df.idFactura = f.idFactura 
		JOIN Socio.Socio s ON s.idSocio = f.idPersona
		JOIN Persona.Persona p ON p.idPersona = s.idSocio
		WHERE df.descripcion   = 'Cuota' AND 
			f.fechaEmision BETWEEN @FechaInicio AND @FechaFin AND
			(f.fechaPago > f.fechaVencimiento OR f.estado = 'Vencida')
	),
	ConteoMorosidad AS (
		SELECT 
		  idPersona,
		  COUNT(*) AS CantidadIncumplimientos
		FROM SociosQueIncumplieron 
		GROUP BY idPersona
	),
	RankingMorosidad AS (
		SELECT
		  *,
		  DENSE_RANK() OVER (ORDER BY CantidadIncumplimientos DESC) AS Ranking
		FROM ConteoMorosidad
		WHERE CantidadIncumplimientos > 2
	)
	SELECT
	'Morosos Recurrentes'												AS [NombreReporte],
	CAST(@FechaInicio AS varchar) + ' - ' + CAST(@FechaFin AS varchar)	AS [Período],
	(	SELECT
			nroSocio						AS [NroSocio],
			NombreApellido					AS [NombreApellido],
			MesIncumplido                   AS [MesIncumplido]
		FROM SociosQueIncumplieron s
		JOIN RankingMorosidad r ON r.idPersona = s.idPersona
		ORDER BY r.Ranking ASC
		FOR XML PATH('Socio'), TYPE
	)
	FOR XML PATH(''), ROOT('MorososRecurrentes');                
END;
GO


--------------------------------------------------------------------------------
--REPORTE 2
--------------------------------------------------------------------------------


CREATE OR ALTER PROCEDURE Reporte.IngresosPorActividadMes
AS
BEGIN
		
		WITH ValoresParaPivot AS(
			SELECT
				df.descripcion AS Actividad,
				FORMAT(f.fechaEmision, 'MMMM', 'es-ES') AS NombreMes,
				CAST (df.montoFinal as decimal(10,2)) AS montoTotalDetalleFactura			--Sin el CAST produce mas decimales de la cuenta.
			FROM Factura.Factura f
			JOIN Factura.DetalleFactura df ON df.idFactura = f.idFactura
			WHERE df.descripcion IN ('Vóley','Futsal','Baile artístico','Natación','Ajedrez', 'Taekwondo')
			AND f.fechaEmision BETWEEN DATEFROMPARTS(YEAR(GETDATE()), 1, 1) AND GETDATE()
		)
		SELECT
			actividad,
			ISNULL([Enero],       0) AS Enero,
			ISNULL([Febrero],     0) AS Febrero,
			ISNULL([Marzo],       0) AS Marzo,
			ISNULL([Abril],       0) AS Abril,
			ISNULL([Mayo],        0) AS Mayo,
			ISNULL([Junio],       0) AS Junio,
			ISNULL([Julio],       0) AS Julio,
			ISNULL([Agosto],      0) AS Agosto,
			ISNULL([Septiembre],  0) AS Septiembre,
			ISNULL([Octubre],     0) AS Octubre,
			ISNULL([Noviembre],   0) AS Noviembre,
			ISNULL([Diciembre],   0) AS Diciembre
	FROM ValoresParaPivot
	PIVOT (
		SUM(montoTotalDetalleFactura)
		FOR NombreMes IN (
			[Enero],[Febrero],[Marzo],[Abril],[Mayo],[Junio],
			[Julio],[Agosto],[Septiembre],[Octubre],[Noviembre],[Diciembre]
		)
	) AS pvt
	ORDER BY actividad
	FOR XML PATH('Actividad'), ROOT('ReporteIngresosPorActividadMes');
END;
GO


--------------------------------------------------------------------------------
--REPORTE 3
--------------------------------------------------------------------------------


CREATE OR ALTER PROCEDURE Reporte.InasistenciasCategoriaActividad
AS
BEGIN
	SELECT ca.nombre AS Categoria, ad.nombre AS Actividad, COUNT(DISTINCT s.idSocio) AS CantidadSociosConInasistencia
	FROM Actividad.Asiste a
	JOIN Socio.Socio s ON s.idSocio = a.idSocio
	JOIN Socio.Categoria ca ON ca.idCategoria = s.idCategoria
	JOIN Actividad.Clase cl ON cl.idClase = a.idClase
	JOIN Actividad.ActividadDeportiva ad ON ad.idActividadDeportiva = cl.idActividadDeportiva
	WHERE a.asistencia <> 'P'
	GROUP BY ca.nombre, ad.nombre
	ORDER BY CantidadSociosConInasistencia DESC
	FOR XML PATH('Registro'), ROOT('ReporteInasistenciasCategoriaActividad');
END;
GO


--------------------------------------------------------------------------------
--REPORTE 4
--------------------------------------------------------------------------------


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
	FROM Socio.Socio s
	JOIN Persona.Persona p ON p.idPersona = s.idSocio
	JOIN Socio.Categoria ca ON ca.idCategoria = s.idCategoria
	JOIN Actividad.Asiste a ON a.idSocio = s.idSocio
	JOIN Actividad.Clase c ON c.idClase = a.idClase
	JOIN Actividad.ActividadDeportiva ad ON ad.idActividadDeportiva = c.idActividadDeportiva
	WHERE a.asistencia <> 'P'
	FOR XML PATH('Socio'), ROOT('ReporteInasistenciasSocio');
END;
GO
