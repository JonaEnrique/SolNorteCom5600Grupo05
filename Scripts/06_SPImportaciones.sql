USE Com5600G05						
GO

-----------------------jornadas-----------------------

CREATE OR ALTER PROCEDURE importarJornadas 
	@rutaCompletaArchivo VARCHAR(260)
AS
BEGIN

	CREATE TABLE #tempDatosCsv(
		fecha        CHAR(17),
		temperatura  CHAR(5),
		mmLluvia     CHAR(5),
		humedad      CHAR(2),
		viento       CHAR(5)
	);
	BEGIN TRY
		

		DECLARE @sqlBulk VARCHAR(256);

		SET @sqlBulk = '
		BULK INSERT #tempDatosCsv
		FROM ''' + REPLACE(@rutaCompletaArchivo, '''', '''''') + '''
		WITH (
			FIELDTERMINATOR = '','',
			ROWTERMINATOR   = ''0x0A'',
			FIRSTROW        = 6
		);
		';
		EXEC sp_executesql @sqlBulk;

		UPDATE #tempDatosCsv
		SET
		  fecha = LEFT(TRIM(REPLACE(REPLACE(fecha, CHAR(10), ''), CHAR(13), '')), 10) --Quita todos los LF y CL que haya.
		WHERE ISDATE(LEFT(TRIM(REPLACE(REPLACE(fecha, CHAR(13), ''), CHAR(10), '')), 10)) = 1;

		WITH lluviaPorDia AS (
		  SELECT
			CAST(fecha AS DATE) AS fechaDia,
			SUM(CAST(mmLluvia AS DECIMAL(9,2))) AS cantidadMmEnElDia
		  FROM #tempDatosCsv
		  WHERE ISDATE(fecha) = 1	--Asegurar que la fecha sea valida.
		  GROUP BY CAST(fecha AS DATE)
		)
		INSERT INTO Jornada (huboLluvia, fecha)
		SELECT
		  CASE WHEN cantidadMmEnElDia > 0 THEN 1 ELSE 0 END,
		  fechaDia
		FROM lluviaPorDia d
		WHERE NOT EXISTS (
		  SELECT 1 FROM Jornada j
		  WHERE j.fecha = d.fechaDia
		);
		
	END TRY
	BEGIN CATCH


        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Error en importarJornadas: %s', 16, 1, @ErrorMsg);
       
    END CATCH

	DROP TABLE #tempDatosCsv;
END;


-----------------------------tarifas---------------------------------------



CREATE OR ALTER PROCEDURE importarTarifas
	@rutaCompletaArchivo VARCHAR(260)
AS
BEGIN
	DECLARE @tempTarifasActividades TABLE (
		nombre VARCHAR(30) NOT NULL,
		precio DECIMAL(10,2) NOT NULL,
		fechaVigencia DATE NOT NULL
	);

	DECLARE @tempTarifasCategoria TABLE (
		nombre VARCHAR(30) NOT NULL,
		precio DECIMAL(10,2) NOT NULL,
		fechaVigencia DATE NOT NULL
	);

	DECLARE @tempTarifasPileta TABLE (
		precio DECIMAL(10,2),
		fechaVigencia DATE NOT NULL,
		tipoCliente VARCHAR(10),
		tipoEdad VARCHAR(10),
		tipoDuracion VARCHAR(10),
		ordenCarga INT
	);

	DECLARE @trancountInicio INT = @@TRANCOUNT;

	BEGIN TRY
		BEGIN TRANSACTION;


		-----------------Actividades Deportivas--------------------
		DECLARE @sqlActividad VARCHAR(512) = '
		INSERT INTO @tempTarifasActividades(nombre, precio, fechaVigencia) 
		SELECT Actividad, [Valor por mes], CAST([Vigente Hasta] AS date)
		FROM OPENROWSET(
			''Microsoft.ACE.OLEDB.16.0'',
			''Excel 12.0;HDR=YES;IMEX=1;Database=' + @rutaCompletaArchivo + ''',
			''SELECT * FROM [Tarifas$B2:D8]''
		);';
		exec sp_executesql @sqlActividad;

		-- Actualizar si un precio ha cambiado y tiene la misma fecha.

		UPDATE c
		SET c.precio = t.precio
		FROM CostoActividadDeportiva c
		JOIN @tempTarifasActividades t ON c.fechaVigencia = t.fechaVigencia
		JOIN ActividadDeportiva a ON a.nombre = t.nombre COLLATE Modern_Spanish_CI_AS
		WHERE c.idActividadDeportiva = a.idActividadDeportiva
		  AND c.precio <> t.precio;

		-- Insertar si hay una nueva fecha de vigencia.

		INSERT INTO CostoActividadDeportiva (fechaVigencia, precio, idActividadDeportiva)
		SELECT 
			t.fechaVigencia,
			t.precio,
			a.idActividadDeportiva
		FROM @tempTarifasActividades t
		JOIN ActividadDeportiva a ON a.nombre = t.nombre COLLATE Modern_Spanish_CI_AS
		WHERE NOT EXISTS (
			SELECT 1
			FROM CostoActividadDeportiva c
			WHERE c.idActividadDeportiva = a.idActividadDeportiva
			  AND c.fechaVigencia = t.fechaVigencia
		);

		--------------------- Categorias ----------------------

		DECLARE @sqlCategoria VARCHAR(512) = '
		INSERT INTO @tempTarifasCategoria(nombre, precio, fechaVigencia) 
		SELECT [Categoria socio], [Valor cuota], CAST([Vigente Hasta] AS date)
		FROM OPENROWSET(
			''Microsoft.ACE.OLEDB.16.0'',
			''Excel 12.0;HDR=YES;IMEX=1;Database=' + @rutaCompletaArchivo + ''',
			''SELECT * FROM [Tarifas$B10:D13]''
		);';
		exec sp_executesql @sqlCategoria;

		-- Actualizar si un precio ha cambiado y tiene la misma fecha.

		UPDATE cc
		SET cc.precio = t.precio
		FROM CostoCategoria cc
		JOIN @tempTarifasCategoria t ON t.fechaVigencia = cc.fechaVigencia
		JOIN Categoria c ON c.nombre = t.nombre COLLATE Modern_Spanish_CI_AS
		WHERE cc.idCategoria = c.idCategoria
		  AND cc.precio <> t.precio;

		-- Insertar si hay una nueva fecha de vigencia.

		INSERT INTO CostoCategoria (fechaVigencia, precio, idCategoria)
		SELECT 
			t.fechaVigencia,
			t.precio,
			c.idCategoria
		FROM @tempTarifasCategoria t
		JOIN Categoria c ON c.nombre = t.nombre COLLATE Modern_Spanish_CI_AS
		WHERE NOT EXISTS (
			SELECT 1
			FROM CostoCategoria cc
			WHERE cc.idCategoria = c.idCategoria
			  AND cc.fechaVigencia = t.fechaVigencia
		);

		---------------------Uso Pileta--------------------------

		DECLARE @sqlPiletaSocios VARCHAR(512) = '
		INSERT INTO @tempTarifasPileta(precio, fechaVigencia, ordenCarga)
		SELECT Socios, CAST([Vigente Hasta] AS date), ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
		FROM OPENROWSET(
			''Microsoft.ACE.OLEDB.16.0'',
			''Excel 12.0;HDR=YES;IMEX=1;Database=' + @rutaCompletaArchivo + ''',
			''SELECT * FROM [Tarifas$D16:F22]''
		);';
		exec sp_executesql @sqlPiletaSocios;

		DECLARE @sqlPiletaInvitados VARCHAR(512) = '
		INSERT INTO @tempTarifasPileta(precio, fechaVigencia, ordenCarga)
		SELECT Invitados, CAST([Vigente Hasta] AS date), ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + 6
		FROM OPENROWSET(
			''Microsoft.ACE.OLEDB.16.0'',
			''Excel 12.0;HDR=YES;IMEX=1;Database=' + @rutaCompletaArchivo + ''',
			''SELECT * FROM [Tarifas$E16:F18]''
		);';
		exec sp_executesql @sqlPiletaInvitados;

		UPDATE t
		SET 
			tipoCliente = CASE 
						WHEN ordenCarga IN (1,2,3,4,5,6) THEN 'Socio'
						WHEN ordenCarga IN (7,8) THEN 'Invitado'
					  END,
			tipoEdad = CASE 
					WHEN ordenCarga IN (1,3,5,7) THEN 'Adulto'
					WHEN ordenCarga IN (2,4,6,8) THEN 'Menor'
				   END,
			tipoDuracion = CASE 
						WHEN ordenCarga IN (1,2,7,8) THEN 'Día'
						WHEN ordenCarga IN (3,4) THEN 'Temporada'
						WHEN ordenCarga IN (5,6) THEN 'Mes'
					  END
		FROM @tempTarifasPileta t;



		DECLARE @idUsoPileta INT;
		SELECT @idUsoPileta = idTipoActividadExtra FROM TipoActividadExtra WHERE descripcion = 'UsoPileta';

		
		-- Actualizar si un precio ha cambiado y tiene la misma fecha.

		UPDATE t
		SET t.precio = temp.precio
		FROM Tarifa t
		JOIN @tempTarifasPileta temp
		  ON t.fechaVigencia = temp.fechaVigencia
		 AND t.tipoCliente   = temp.tipoCliente
		 AND t.tipoEdad      = temp.tipoEdad
		 AND t.tipoDuracion  = temp.tipoDuracion
		 AND t.idTipoActividadExtra = @idUsoPileta
		WHERE t.precio <> temp.precio;

		
		-- Insertar si hay una nueva fecha de vigencia.

		INSERT INTO Tarifa (fechaVigencia, precio, tipoCliente, tipoDuracion, tipoEdad, idTipoActividadExtra)
		SELECT 
			temp.fechaVigencia,
			temp.precio,
			temp.tipoCliente,
			temp.tipoDuracion,
			temp.tipoEdad,
			@idUsoPileta
		FROM @tempTarifasPileta temp
		WHERE NOT EXISTS (
			SELECT 1
			FROM Tarifa t
			WHERE t.fechaVigencia = temp.fechaVigencia
			  AND t.tipoCliente   = temp.tipoCliente
			  AND t.tipoEdad      = temp.tipoEdad
			  AND t.tipoDuracion  = temp.tipoDuracion
			  AND t.idTipoActividadExtra = @idUsoPileta
		);


		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		WHILE @@TRANCOUNT > @trancountInicio
			ROLLBACK TRANSACTION;
		DECLARE @ErrorMsg VARCHAR(4000) = ERROR_MESSAGE();
		RAISERROR('Error en importarTarifas: %s', 16, 1, @ErrorMsg);
	END CATCH

	WHILE @@TRANCOUNT > @trancountInicio
			ROLLBACK TRANSACTION;

END;

-----------------------socios--------------------------------



CREATE OR ALTER PROCEDURE importarSocios
	@rutaCompletaArchivo VARCHAR(260)
AS
BEGIN

	CREATE TABLE #TempDatosPersona(
		nroSocio VARCHAR(10) COLLATE Modern_Spanish_CI_AS PRIMARY KEY ,
		nombre VARCHAR(50),
		apellido VARCHAR(50),
		dni VARCHAR(15) COLLATE Modern_Spanish_CI_AS,
		email VARCHAR(100),
		fechaNacimiento DATE,
		telefono VARCHAR(20),
		telefonoEmergencia VARCHAR(20),
		obraSocial VARCHAR(40) COLLATE Modern_Spanish_CI_AS,
		nroObraSocial VARCHAR(20),
		telefonoObraSocial VARCHAR(40)
	);

	CREATE TABLE #NuevosSocios (
		idPersona INT,
		dni VARCHAR(15) COLLATE Modern_Spanish_CI_AS,
		nombre VARCHAR(50) COLLATE Modern_Spanish_CI_AS,
		apellido VARCHAR(50) COLLATE Modern_Spanish_CI_AS,
	);

	DECLARE @trancountInicio INT = @@TRANCOUNT;

	BEGIN TRY
		BEGIN TRANSACTION;

		DECLARE @sql VARCHAR(1024);

		SET @sql = '
		INSERT INTO #tempDatosPersona
		SELECT 
		  [Nro de Socio], 
		  Nombre, 
		  TRIM([ apellido]), 
		  CAST([ DNI] AS VARCHAR(15)), 
		  [ email personal], 
		  TRY_CONVERT(DATE, [ fecha de nacimiento], 103)
		  CAST(CAST([ teléfono de contacto] AS INT) AS VARCHAR(20)),
		  CAST(CAST([ teléfono de contacto emergencia] AS INT) AS VARCHAR(20)),
		  TRIM([ Nombre de la obra social o prepaga]), 
		  [nro# de socio obra social/prepaga ], 
		  [teléfono de contacto de emergencia ]
		FROM OPENROWSET(
		  ''Microsoft.ACE.OLEDB.16.0'',
		  ''Excel 12.0;HDR=YES;IMEX=1;Database=' + @rutaCompletaArchivo + ''',
		  ''SELECT * FROM [Responsables de Pago$]''
		) AS datosExcel;
		';

		EXEC(@sql);
		
		-- Insertar datos personales de nuevos socios.

		INSERT INTO Persona(nombre, apellido, fechaNac, dni, telefono, telefonoEmergencia, email, idRol)
		OUTPUT INSERTED.idPersona, INSERTED.dni, inserted.nombre, inserted.apellido INTO #NuevosSocios(idPersona, dni, nombre, apellido)
		SELECT t.nombre, t.apellido, t.fechaNacimiento, t.dni, t.telefono, t.telefonoEmergencia, t.email, NULL
		FROM #tempDatosPersona t	
		WHERE NOT EXISTS ( SELECT 1 FROM Socio s WHERE s.nroSocio = t.nroSocio );
			
		-- Insertar nuevos socios.

		INSERT INTO Socio(idSocio, nroSocio, idCategoria, idObraSocial, nroObraSocial)
		SELECT 
			ns.idPersona,
			t.nroSocio,
			c.idCategoria,
			o.idObraSocial,
			t.nroObraSocial
		FROM #nuevosSocios ns
		JOIN #tempDatosPersona t ON t.dni = ns.dni AND t.nombre COLLATE Modern_Spanish_CI_AS = ns.nombre --Debido a que hay un DNI duplicado 
			AND t.apellido COLLATE Modern_Spanish_CI_AS = ns.apellido
		JOIN Categoria c ON c.nombre = 'Mayor'
		JOIN ObraSocial o ON o.nombre = t.obraSocial



		-- Actualizar datos personales de socios.

		UPDATE p
		SET
		  p.nombre = t.nombre,
		  p.apellido = t.apellido,
		  p.dni = t.dni,
		  p.email = t.email,
		  p.fechaNac = t.fechaNacimiento,
		  p.telefono = t.telefono,
		  p.telefonoEmergencia = t.telefonoEmergencia
		FROM Persona p
		JOIN Socio s ON s.idSocio = p.idPersona
		JOIN #tempDatosPersona t ON t.nroSocio = s.nroSocio
		WHERE
		  p.nombre <> t.nombre COLLATE Modern_Spanish_CI_AS OR
		  p.apellido <> t.apellido COLLATE Modern_Spanish_CI_AS OR
		  p.dni <> t.dni OR
		  p.email <> t.email COLLATE Modern_Spanish_CI_AS OR
		  p.fechaNac <> t.fechaNacimiento OR
		  p.telefono <> t.telefono COLLATE Modern_Spanish_CI_AS OR
		  p.telefonoEmergencia <> t.telefonoEmergencia COLLATE Modern_Spanish_CI_AS;


		-- Actualizar Socio  
		UPDATE s
		SET 
			--Categoria no puede variar ya que los RP siempre deben ser Mayores.
			s.idObraSocial     = o.idObraSocial,
			s.nroObraSocial    = t.nroObraSocial
		FROM Socio s
		JOIN #tempDatosPersona t ON t.nroSocio = s.nroSocio
		JOIN ObraSocial o ON o.nombre = t.obraSocial 
		WHERE
		  s.idObraSocial <> o.idObraSocial OR
		  s.nroObraSocial <> t.nroObraSocial COLLATE Modern_Spanish_CI_AI;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		WHILE @@TRANCOUNT > @trancountInicio
			ROLLBACK TRANSACTION;
		DECLARE @ErrorMsg VARCHAR(4000) = ERROR_MESSAGE();
		RAISERROR('Error en importarSocios: %s', 16, 1, @ErrorMsg);
	END CATCH

	WHILE @@TRANCOUNT > @trancountInicio		--Para errores que el CATCH no detecta como COLLATE's incompatibles.
			ROLLBACK TRANSACTION;

	DROP TABLE #tempDatosPersona;
	DROP TABLE #nuevosSocios;
END;




-----------------------grupos familiares--------------------------------
CREATE OR ALTER PROCEDURE importarSociosMenores
	@rutaCompletaArchivo VARCHAR(260)
AS
BEGIN
	
	

	CREATE TABLE #tempDatosPersonaMenor(
		nroSocio VARCHAR(10) COLLATE Modern_Spanish_CI_AS PRIMARY KEY,
		nroSocioTutor VARCHAR(10) COLLATE Modern_Spanish_CI_AS,
		nombre VARCHAR(50),
		apellido VARCHAR(50),
		dni VARCHAR(15) COLLATE Modern_Spanish_CI_AS,
		email VARCHAR(100),
		fechaNacimiento DATE,
		telefono VARCHAR(20),
		telefonoEmergencia VARCHAR(20),
		obraSocial VARCHAR(40) COLLATE Modern_Spanish_CI_AS,
		nroObraSocial VARCHAR(20),
		telefonoObraSocial VARCHAR(40)
	);

	CREATE TABLE #NuevosSocios(
		idSocioMenor INT PRIMARY KEY,
		dni VARCHAR(15) COLLATE Modern_Spanish_CI_AS,
		nombre VARCHAR(50) COLLATE Modern_Spanish_CI_AS,
		apellido VARCHAR(50) COLLATE Modern_Spanish_CI_AS
	);

	DECLARE @SociosModificados TABLE(
		idSocioMenor INT PRIMARY KEY,
		fechaNacVieja DATE,
		fechaNacNueva DATE
	);

	DECLARE @trancountInicio INT = @@TRANCOUNT
	BEGIN TRY
		BEGIN TRANSACTION

		DECLARE @sql VARCHAR(512);

		SET @sql = '
		INSERT INTO #tempDatosPersonaMenor
		SELECT 
		  [Nro de Socio], 
		  [Nro de socio RP], 
		  Nombre, 
		  TRIM([ apellido]), 
		  CAST([ DNI] AS VARCHAR(15)), 
		  [ email personal], 
		  TRY_CONVERT(DATE, [ fecha de nacimiento], 103)
		  [ teléfono de contacto],
		  CAST([ teléfono de contacto emergencia] AS VARCHAR(20)),
		  TRIM([ Nombre de la obra social o prepaga]), 
		  [nro# de socio obra social/prepaga ], 
		  [teléfono de contacto de emergencia ]
		FROM OPENROWSET(
		  ''Microsoft.ACE.OLEDB.16.0'',
		  ''Excel 12.0;HDR=YES;IMEX=1;Database=' + @rutaCompletaArchivo + ''',
		  ''SELECT * FROM [Grupo Familiar$]''
		) AS datosExcel;
		';

		EXEC (@sql);


		--Insertar datos personales de socios menores nuevos.
		INSERT INTO Persona(nombre, apellido, fechaNac, dni, telefono, telefonoEmergencia, email, idRol)
		OUTPUT inserted.idPersona, inserted.dni, inserted.nombre, inserted.apellido INTO #NuevosSocios (idSocioMenor, dni, nombre, apellido)
		SELECT t.nombre, t.apellido, t.fechaNacimiento, t.dni, t.telefono, t.telefonoEmergencia, t.email, NULL
		FROM #tempDatosPersonaMenor t		
		WHERE NOT EXISTS ( SELECT 1 FROM Socio s WHERE s.nroSocio = t.nroSocio );
		

		--Insertar socios menores nuevos.
		WITH SociosConEdad AS (
		  SELECT 
			ns.idSocioMenor,
			CASE
			  WHEN DATEADD(YEAR, DATEDIFF(YEAR, p.fechaNac, GETDATE()), p.fechaNac) > GETDATE()
				THEN DATEDIFF(YEAR, p.fechaNac, GETDATE()) - 1
			  ELSE DATEDIFF(YEAR, p.fechaNac, GETDATE())
			END AS edad,
			p.dni, p.nombre, p.apellido
		  FROM #NuevosSocios ns
		  JOIN Persona p ON p.idPersona = ns.idSocioMenor
		)
		INSERT INTO Socio(idSocio, nroSocio, idCategoria, idObraSocial, nroObraSocial)
		SELECT sce.idSocioMenor, t.nroSocio, c.idCategoria, o.idObraSocial, t.nroObraSocial 
		FROM SociosConEdad sce
		JOIN #tempDatosPersonaMenor t ON t.dni = sce.dni  AND t.nombre COLLATE Modern_Spanish_CI_AS = sce.nombre
			AND t.apellido COLLATE Modern_Spanish_CI_AS = sce.apellido 
		JOIN Categoria c ON 
		c.nombre = CASE 
					   WHEN sce.edad <= 12 THEN 'Menor'
					   WHEN sce.edad <= 17 THEN 'Cadete'
					   ELSE 'Mayor'
				   END
		LEFT JOIN ObraSocial o ON o.nombre = t.obraSocial;



		--Insertar Grupos Familiares.

		INSERT INTO GrupoFamiliar(idSocioTutor, idSocioMenor, parentesco)
		SELECT st.idSocio, sm.idSocio, NULL
		FROM #NuevosSocios ns
		JOIN Socio sm ON sm.idSocio = ns.idSocioMenor
		JOIN #tempDatosPersonaMenor t ON t.nroSocio = sm.nroSocio
		JOIN Socio st ON st.nroSocio = t.nroSocioTutor
		WHERE NOT EXISTS (
			SELECT 1
			FROM GrupoFamiliar gf
			WHERE gf.idSocioMenor = sm.idSocio AND gf.idSocioTutor = st.idSocio
		)

		--Actualizar datos personales de socios menores
		UPDATE p
		SET 
			p.nombre = t.nombre,
			p.apellido = t.apellido,
			p.dni = t.dni,
			p.fechaNac = t.fechaNacimiento,
			p.telefono = t.telefono,
			p.telefonoEmergencia = t.telefonoEmergencia,
			p.email = t.email
		OUTPUT inserted.idPersona, deleted.fechaNac, inserted.fechaNac INTO @SociosModificados(idSocioMenor, fechaNacVieja, fechaNacNueva)
		FROM Persona p
		JOIN Socio s ON s.idSocio = p.idPersona
		JOIN #tempDatosPersonaMenor t ON t.nroSocio = s.nroSocio
		WHERE 
			p.nombre <> t.nombre COLLATE Modern_Spanish_CI_AS OR
			p.apellido <> t.apellido COLLATE Modern_Spanish_CI_AS OR
			p.dni <> t.dni OR
			p.fechaNac <> t.fechaNacimiento OR
			p.telefono <> t.telefono COLLATE Modern_Spanish_CI_AS OR
			p.telefonoEmergencia <> t.telefonoEmergencia COLLATE Modern_Spanish_CI_AS OR
			p.email <> t.email COLLATE Modern_Spanish_CI_AS;


		--Actualizar categoria si fechaNac cambio.
		WITH SociosConFechaNacModificada AS (
		  SELECT 
			sm.idSocioMenor,
			CASE
			  WHEN DATEADD(YEAR, DATEDIFF(YEAR, sm.fechaNacNueva, GETDATE()), sm.fechaNacNueva) > GETDATE()
				THEN DATEDIFF(YEAR, sm.fechaNacNueva, GETDATE()) - 1
			  ELSE DATEDIFF(YEAR, sm.fechaNacNueva, GETDATE())
			END AS edad
		  FROM @SociosModificados sm
		  WHERE sm.fechaNacNueva <> sm.fechaNacVieja
		)
		UPDATE s
		SET
			s.idCategoria = c.idCategoria
		FROM Socio s
		JOIN SociosConFechaNacModificada sm ON sm.idSocioMenor = s.idSocio
		JOIN Categoria c ON
		c.nombre = CASE 
					   WHEN sm.edad <= 12 THEN 'Menor'
					   WHEN sm.edad <= 17 THEN 'Cadete'
					   ELSE 'Mayor'
				   END
		

		--Actualizar obraSocial por si cambio.
		UPDATE s
		SET 
		  s.idObraSocial  = obraNueva.idObraSocial,
		  s.nroObraSocial = t.nroObraSocial
		FROM Socio s
		JOIN #tempDatosPersonaMenor t ON t.nroSocio = s.nroSocio 
		JOIN ObraSocial obraNueva ON obraNueva.nombre = t.obraSocial
		WHERE s.idObraSocial <> obraNueva.idObraSocial;


		--Actualizar Grupo Familiar en caso de que el tutor haya cambiado.
		UPDATE gf
		SET gf.idSocioTutor = st.idSocio
		FROM GrupoFamiliar gf
		JOIN Socio sm ON sm.idSocio = gf.idSocioMenor         
		JOIN #tempDatosPersonaMenor t ON t.nroSocio = sm.nroSocio
		JOIN Socio st ON st.nroSocio = t.nroSocioTutor        
		WHERE gf.idSocioTutor <> st.idSocio;              


		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		WHILE @@TRANCOUNT > @trancountInicio
			ROLLBACK TRANSACTION;
		DECLARE @ErrorMsg VARCHAR(4000) = ERROR_MESSAGE();
		RAISERROR('Error en importarSociosMenores: %s', 16, 1, @ErrorMsg);
	END CATCH

	WHILE @@TRANCOUNT > @trancountInicio
			ROLLBACK TRANSACTION;

	DROP TABLE #tempDatosPersonaMenor
	DROP TABLE #NuevosSocios
END;



CREATE OR ALTER PROCEDURE importarAsistencias
	@rutaCompletaArchivo VARCHAR(260)
AS
BEGIN
	
	CREATE TABLE #tempAsistencia (
		nroSocio VARCHAR(10) COLLATE Modern_Spanish_CI_AS ,
		actividad VARCHAR(30) COLLATE Modern_Spanish_CI_AS,
		fecha DATE,
		asistencia CHAR(2) COLLATE Modern_Spanish_CI_AS,
		profesor VARCHAR(100) COLLATE Modern_Spanish_CI_AS
	);

	DECLARE @trancountInicio INT = @@TRANCOUNT;

	BEGIN TRY		
		BEGIN TRANSACTION;

		DECLARE @sql VARCHAR(512) = '
        INSERT INTO #tempAsistencia(nroSocio, actividad, fecha, asistencia, profesor)
        SELECT
          [Nro de Socio],
          [Actividad],
          TRY_CONVERT(DATE, [Fecha], 103),     -- dd/mm/yyyy
          [Asistencia],
          [Profesor]
        FROM OPENROWSET(
          ''Microsoft.ACE.OLEDB.16.0'',
          ''Excel 12.0;HDR=YES;IMEX=1;Database=' + @rutaCompletaArchivo + ''',
          ''SELECT * FROM [Asistencias$]''
        ) AS datosExcel;
        ';
        EXEC sp_executesql @sql;


		INSERT INTO Clase (fecha, idActividadDeportiva, profesor)
        SELECT DISTINCT
            t.fecha, a.idActividadDeportiva, t.profesor
        FROM #tempAsistencia t
        JOIN ActividadDeportiva a ON a.nombre = t.actividad
		WHERE NOT EXISTS(
			SELECT 1 FROM Clase c WHERE c.fecha = t.fecha AND c.idActividadDeportiva = a.idActividadDeportiva 
				AND c.profesor = t.profesor
		)


		INSERT INTO Asiste(idSocio, idClase, asistencia)
		SELECT s.idSocio, c.idClase, t.asistencia
		FROM #tempAsistencia t
		JOIN Socio s ON s.nroSocio = t.nroSocio
		JOIN ActividadDeportiva a ON a.nombre = t.actividad
		JOIN Clase c ON c.fecha = t.fecha AND c.idActividadDeportiva = a.idActividadDeportiva AND c.profesor = t.profesor
		WHERE NOT EXISTS (
		  SELECT 1
		  FROM Asiste
		  WHERE Asiste.idSocio = s.idSocio
			AND Asiste.idClase = c.idClase
		);


		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		WHILE @@TRANCOUNT > @trancountInicio
			ROLLBACK TRANSACTION;
		DECLARE @ErrorMsg VARCHAR(4000) = ERROR_MESSAGE();
		RAISERROR('Error en importarAsistencias: %s', 16, 1, @ErrorMsg);
	END CATCH

	WHILE @@TRANCOUNT > @trancountInicio
		ROLLBACK TRANSACTION;
	DROP TABLE #tempAsistencia;
END;







