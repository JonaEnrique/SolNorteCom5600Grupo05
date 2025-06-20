USE Com5600G05						
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Reporte')
    EXEC('CREATE SCHEMA Reporte');
GO


--Reporte 1


CREATE OR ALTER PROCEDURE Reporte.ListadoSociosMorosos
	@desde DATE,
	@hasta DATE
AS
BEGIN
	WITH CuotasFiltradas AS (
		  SELECT DISTINCT
			COALESCE(gf.idSocioTutor, c.idSocio) AS idDueñoFactura,
			FORMAT(c.periodo,'MMMM','es-ES')      AS mesLower
		  FROM dbo.Cuota AS c
		  LEFT JOIN dbo.GrupoFamiliar AS gf
			ON gf.idSocioMenor = c.idSocio
		  WHERE 
			c.periodo BETWEEN @desde AND @hasta 
			AND c.estado IN ('Vencida','Pagada Vencida')
	),
	MesesCapitalizados AS (
		  SELECT
			idDueñoFactura,
			UPPER(LEFT(mesLower,1)) 
			  + LOWER(SUBSTRING(mesLower,2,20)) AS mesNombre	--Puse 20 para que sea un tamaño que quepan los nombres de los meses.
		  FROM CuotasFiltradas
	),
	SociosResponsablesPago AS (
		-- traigo los datos del tutor o del propio socio.
		SELECT DISTINCT
		  s.idSocio          AS idDueñoFactura,
		  s.nroSocio,
		  p.nombre + ' ' + p.apellido AS nombreCompleto
		FROM CuotasFiltradas  cf
		JOIN Socio s ON s.idSocio = cf.idDueñoFactura
		JOIN Persona p ON p.idPersona = s.idSocio
	),
	ConteoMorosidad AS (
		SELECT
		  srp.idDueñoFactura,
		  srp.nroSocio,
		  srp.nombreCompleto,
		  mc.mesNombre,
		  COUNT(*) OVER (PARTITION BY srp.idDueñoFactura) AS TotalIncumplimientos
		FROM MesesCapitalizados mc
		JOIN SociosResponsablesPago srp
			ON srp.idDueñoFactura = mc.idDueñoFactura	
	),
	RankingMorosidad AS (
		SELECT
		  *,
		  RANK() OVER (ORDER BY TotalIncumplimientos DESC) AS RankingMorosidad
		FROM ConteoMorosidad
		WHERE TotalIncumplimientos > 2
	)
	SELECT
		'Morosos Recurrentes'										AS [NombreReporte],
		CAST(@desde AS varchar) + ' - ' + CAST(@hasta AS varchar)	AS [Período],																
		(
		  SELECT
			nroSocio                     AS [NroSocio],
			nombreCompleto               AS [NombreApellido],
			mesNombre                    AS [MesIncumplido]
		  FROM RankingMorosidad 
		  WHERE TotalIncumplimientos > 2
		  ORDER BY RankingMorosidad ASC
		  FOR XML PATH('Socio'), TYPE
		)
	FOR XML PATH(''), ROOT('MorososRecurrentes');                   
END;
GO


--Reporte 2
CREATE OR ALTER PROCEDURE Reporte.IngresosPorActividadMes
AS
BEGIN
	

	WITH ActividadMensualSocio AS (
		SELECT DISTINCT
			s.idSocio,
			c.idActividadDeportiva,
			DATEFROMPARTS(YEAR(c.fecha), MONTH(c.fecha), 1) AS fecha
			FROM Asiste a
			JOIN Socio s ON s.idSocio = a.idSocio
			JOIN Clase c ON c.idClase = a.idClase
			--Recoger asistencias desde el principio de año hasta la fecha actual.
			WHERE DATEFROMPARTS(YEAR(c.fecha), MONTH(c.fecha), 1) BETWEEN 
					 DATEFROMPARTS(YEAR(GETDATE()), 1, 1) AND GETDATE()
		),
		PrecioPorActividadSocio AS (
			SELECT
				ad.nombre	AS actividad,
				FORMAT(ams.fecha,'MMMM','es-ES') AS mesNombre,
				c.precio,

				-- Para cada asistencia, selecciona el precio cuya fecha de vigencia del costoActividad sea la menor
				-- fecha ? fechaAsistencia; si no existe ninguna, utiliza la fecha de vigencia del costoActividad maxima anterior.
				ROW_NUMBER() OVER (
					PARTITION BY ams.idSocio, ad.nombre, ams.fecha
					ORDER BY 
						CASE WHEN c.fechaVigencia >= ams.fecha THEN 0 ELSE 1 END,
						ABS(DATEDIFF(day, c.fechaVigencia, ams.fecha))	
				) AS precioMasCernano
			FROM ActividadMensualSocio ams 
			JOIN ActividadDeportiva ad ON ad.idActividadDeportiva = ams.idActividadDeportiva
			JOIN CostoActividadDeportiva c ON c.idActividadDeportiva = ams.idActividadDeportiva
		),
		ValoresParaPivot AS(
			SELECT
				actividad AS Actividad,
				mesNombre,
				precio
			FROM PrecioPorActividadSocio
			WHERE precioMasCernano = 1
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
		SUM(precio)
		FOR mesNombre IN (
			[Enero],[Febrero],[Marzo],[Abril],[Mayo],[Junio],
			[Julio],[Agosto],[Septiembre],[Octubre],[Noviembre],[Diciembre]
		)
	) AS pvt
	ORDER BY actividad
	FOR XML PATH('Actividad'), ROOT('ReporteIngresosPorActividadMes');
END;
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
GO


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
GO
