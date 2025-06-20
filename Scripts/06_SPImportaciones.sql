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
        Importacion de los archivos maestros provistos.
		Genera facturas en caso de ser necesario para poder realizar los cobros de Actividades Deportivas y/o Cuotas.
    ---------------------------------------------------------------------
*/


USE Com5600G05						
GO

/*
--------------------------------------------------------------------------------
  SECCIÓN: Jornadas
  Descripción : Importa los datos meteorologicos de cada jornada desde el archivo
				maestro correspondiente y registra en Actividad.Jornada si hubo
                lluvia en cada fecha.
--------------------------------------------------------------------------------
*/

CREATE OR ALTER PROCEDURE Importacion.ImportarJornadas 
	@rutaCompletaArchivo VARCHAR(260)
AS
BEGIN

	CREATE TABLE #tempDatosCsv (
		fecha        CHAR(16),
		temperatura  DECIMAL(4,1),   
		mmLluvia     DECIMAL(5,2),
		humedad      TINYINT,         
		viento       DECIMAL(5,1)    
	);

	SET NOCOUNT ON;    -- Evita mensajes
	SET XACT_ABORT ON; -- Hacer rollback automático ante cualquier error

	BEGIN TRY
		
		BEGIN TRAN;

		DECLARE @sql VARCHAR(512);
		SET @sql = '
		BULK INSERT #tempDatosCsv
		FROM ''' + REPLACE(@rutaCompletaArchivo, '''', '''''') + '''
		WITH (
			FIELDTERMINATOR = '','',
			ROWTERMINATOR   = ''0x0A'',
			FIRSTROW        = 6
		);
		';
		EXEC (@sql);

		WITH LluviaValida AS (
		  SELECT
			CONVERT(DATE, LEFT(fecha, 10), 126) AS fechaDia,
			CONVERT(DECIMAL(5,2), mmLluvia) AS mmLluvia
		  FROM #tempDatosCsv
		),  
		LluviaPorDia AS (
		  SELECT
			fechaDia,
			SUM(mmLluvia) AS TotalMmLluvia
		  FROM LluviaValida
		  GROUP BY fechaDia
		)
		INSERT INTO Actividad.Jornada (fecha, huboLluvia)
		SELECT
		  fechaDia,
		  CASE WHEN TotalMmLluvia > 0 THEN 1 ELSE 0 END
		FROM lluviaPorDia d
		WHERE NOT EXISTS (
		  SELECT 1 FROM Actividad.Jornada j
		  WHERE j.fecha = d.fechaDia
		);

		COMMIT;
		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK;
        DECLARE @ErrorMensaje VARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Error en Importacion.ImportarJornadas: %s', 16, 1, @ErrorMensaje);
       
    END CATCH
	IF @@TRANCOUNT > 0 ROLLBACK;
	DROP TABLE #tempDatosCsv;
END;
GO





/*
--------------------------------------------------------------------------------
  SECCIÓN: Tarifas
  Descripción : Carga las tarifas de actividades deportivas, categorías de socios 
                y uso de pileta desde un archivo Excel y actualiza o inserta 
                los registros en las tablas:
                  - Actividad.CostoActividadDeportiva
                  - Socio.CostoCategoria
                  - Actividad.Tarifa

  Aclaraciones:
    - Solo se agregan nuevas vigencias: si la fecha de vigencia ya existe, 
      se actualiza el precio solo si ha cambiado.
--------------------------------------------------------------------------------
*/



CREATE OR ALTER PROCEDURE Importacion.ImportarTarifas
	@rutaCompletaArchivo VARCHAR(260)
AS
BEGIN

	CREATE TABLE #tempTarifasActividades (
		nombre VARCHAR(30) COLLATE Modern_Spanish_CI_AS,
		precio DECIMAL(10,2),
		fechaVigencia DATE
	);

	CREATE TABLE #tempTarifasCategoria (
		nombre VARCHAR(30) COLLATE Modern_Spanish_CI_AS,
		precio DECIMAL(10,2),
		fechaVigencia DATE
	);

	CREATE TABLE #tempTarifasPileta (
		precio DECIMAL(10,2),
		fechaVigencia DATE,
		tipoCliente VARCHAR(10) COLLATE Modern_Spanish_CI_AS,
		tipoEdad VARCHAR(10) COLLATE Modern_Spanish_CI_AS,
		tipoDuracion VARCHAR(10) COLLATE Modern_Spanish_CI_AS,
		ordenCarga INT
	);

	SET NOCOUNT ON;    -- Evita mensajes
	SET XACT_ABORT ON; -- Hacer rollback automático ante cualquier error

	BEGIN TRY
		BEGIN TRAN;


		-----------------Actividades Deportivas--------------------
		DECLARE @sqlActividad VARCHAR(1024) = '
		INSERT INTO #tempTarifasActividades(nombre, precio, fechaVigencia) 
		SELECT Actividad, [Valor por mes], CAST([Vigente Hasta] AS date)
		FROM OPENROWSET(
			''Microsoft.ACE.OLEDB.16.0'',
			''Excel 12.0;HDR=YES;IMEX=1;Database=' + @rutaCompletaArchivo + ''',
			''SELECT * FROM [Tarifas$B2:D8]''
		);';
		EXEC (@sqlActividad);

		-- Actualizar si un precio ha cambiado y tiene la misma fecha.

		UPDATE c
		SET c.precio = t.precio
		FROM Actividad.CostoActividadDeportiva c
		JOIN #tempTarifasActividades t ON c.fechaVigencia = t.fechaVigencia
		JOIN Actividad.ActividadDeportiva a ON a.nombre = t.nombre
		WHERE c.idActividadDeportiva = a.idActividadDeportiva
		  AND c.precio <> t.precio;

		-- Insertar si hay una nueva fecha de vigencia.

		INSERT INTO Actividad.CostoActividadDeportiva (fechaVigencia, precio, idActividadDeportiva)
		SELECT 
			t.fechaVigencia,
			t.precio,
			a.idActividadDeportiva
		FROM #tempTarifasActividades t
		JOIN Actividad.ActividadDeportiva a ON a.nombre = t.nombre
		WHERE NOT EXISTS (
			SELECT 1
			FROM Actividad.CostoActividadDeportiva c
			WHERE c.idActividadDeportiva = a.idActividadDeportiva
			  AND c.fechaVigencia = t.fechaVigencia
		);

		--------------------- Categorias ----------------------

		DECLARE @sqlCategoria VARCHAR(1024) = '
		INSERT INTO #tempTarifasCategoria(nombre, precio, fechaVigencia) 
		SELECT [Categoria socio], [Valor cuota], CAST([Vigente Hasta] AS date)
		FROM OPENROWSET(
			''Microsoft.ACE.OLEDB.16.0'',
			''Excel 12.0;HDR=YES;IMEX=1;Database=' + @rutaCompletaArchivo + ''',
			''SELECT * FROM [Tarifas$B10:D13]''
		);';
		EXEC (@sqlCategoria);

		-- Actualizar si un precio ha cambiado y tiene la misma fecha.

		UPDATE cc
		SET cc.precio = t.precio
		FROM Socio.CostoCategoria cc
		JOIN #tempTarifasCategoria t ON t.fechaVigencia = cc.fechaVigencia
		JOIN Socio.Categoria c ON c.nombre = t.nombre
		WHERE cc.idCategoria = c.idCategoria
		  AND cc.precio <> t.precio;

		-- Insertar si hay una nueva fecha de vigencia.

		INSERT INTO Socio.CostoCategoria (fechaVigencia, precio, idCategoria)
		SELECT 
			t.fechaVigencia,
			t.precio,
			c.idCategoria
		FROM #tempTarifasCategoria t
		JOIN Socio.Categoria c ON c.nombre = t.nombre
		WHERE NOT EXISTS (
			SELECT 1
			FROM Socio.CostoCategoria cc
			WHERE cc.idCategoria = c.idCategoria
			  AND cc.fechaVigencia = t.fechaVigencia
		);

		---------------------Uso Pileta--------------------------

		DECLARE @sqlPiletaSocios VARCHAR(1024) = '
		INSERT INTO #tempTarifasPileta(precio, fechaVigencia, ordenCarga)
		SELECT Socios, CAST([Vigente Hasta] AS date), ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
		FROM OPENROWSET(
			''Microsoft.ACE.OLEDB.16.0'',
			''Excel 12.0;HDR=YES;IMEX=1;Database=' + @rutaCompletaArchivo + ''',
			''SELECT * FROM [Tarifas$D16:F22]''
		);';
		EXEC (@sqlPiletaSocios);

		DECLARE @sqlPiletaInvitados VARCHAR(1024) = '
		INSERT INTO #tempTarifasPileta(precio, fechaVigencia, ordenCarga)
		SELECT Invitados, CAST([Vigente Hasta] AS date), ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + 6
		FROM OPENROWSET(
			''Microsoft.ACE.OLEDB.16.0'',
			''Excel 12.0;HDR=YES;IMEX=1;Database=' + @rutaCompletaArchivo + ''',
			''SELECT * FROM [Tarifas$E16:F18]''
		);';
		EXEC (@sqlPiletaInvitados);
		
		UPDATE t
		SET 
			tipoCliente = CASE 
						WHEN ordenCarga IN (1,2,3,4,5,6) THEN 'Socio' COLLATE Modern_Spanish_CI_AS
						WHEN ordenCarga IN (7,8) THEN 'Invitado' COLLATE Modern_Spanish_CI_AS
					  END,
			tipoEdad = CASE 
					WHEN ordenCarga IN (1,3,5,7) THEN 'Adulto' COLLATE Modern_Spanish_CI_AS
					WHEN ordenCarga IN (2,4,6,8) THEN 'Menor' COLLATE Modern_Spanish_CI_AS
				   END,
			tipoDuracion = CASE 
						WHEN ordenCarga IN (1,2,7,8) THEN 'Día' COLLATE Modern_Spanish_CI_AS
						WHEN ordenCarga IN (3,4) THEN 'Temporada' COLLATE Modern_Spanish_CI_AS 
						WHEN ordenCarga IN (5,6) THEN 'Mes' COLLATE Modern_Spanish_CI_AS
					  END
		FROM #tempTarifasPileta t;

		
		-- Actualizar si un precio ha cambiado y tiene la misma fecha.

		UPDATE t
		SET t.precio = temp.precio
		FROM Actividad.Tarifa t
		JOIN #tempTarifasPileta temp
		  ON t.fechaVigencia = temp.fechaVigencia
		 AND t.tipoCliente   = temp.tipoCliente
		 AND t.tipoEdad      = temp.tipoEdad
		 AND t.tipoDuracion  = temp.tipoDuracion
		WHERE t.precio <> temp.precio AND t.descripcionActividad = 'UsoPileta';

		
		-- Insertar si hay una nueva fecha de vigencia.

		INSERT INTO Actividad.Tarifa (fechaVigencia, precio, tipoCliente, tipoDuracion, tipoEdad, descripcionActividad)
		SELECT 
			temp.fechaVigencia,
			temp.precio,
			temp.tipoCliente,
			temp.tipoDuracion,
			temp.tipoEdad,
			'UsoPileta'
		FROM #tempTarifasPileta temp
		WHERE NOT EXISTS (
			SELECT 1
			FROM Actividad.Tarifa t
			WHERE t.fechaVigencia = temp.fechaVigencia
			  AND t.tipoCliente   = temp.tipoCliente
			  AND t.tipoEdad      = temp.tipoEdad
			  AND t.tipoDuracion  = temp.tipoDuracion
			  AND t.descripcionActividad = 'UsoPileta'
		);


		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK;
		DECLARE @ErrorMensaje VARCHAR(4000) = ERROR_MESSAGE();
		RAISERROR('Error en Importacion.ImportarTarifas: %s', 16, 1, @ErrorMensaje);
	END CATCH
	
	 IF @@TRANCOUNT > 0 ROLLBACK;

	 DROP TABLE #tempTarifasActividades;
	 DROP TABLE #tempTarifasCategoria;
	 DROP TABLE #tempTarifasPileta;
END;
GO




/*
--------------------------------------------------------------------------------
  SECCIÓN: Socios
  Descripción : Carga los datos de socios desde el archivo maestro correspondiente, e
                inserta en los datos en las tablas Persona.Persona y Socio.Socio

  Aclaraciones:
    - Existe un socio con DNI duplicado
    - Existe un socio con FechaNac incorrecta(10/19/1981), donde el numero del mes es 19.
    
--------------------------------------------------------------------------------
*/


CREATE OR ALTER PROCEDURE Importacion.ImportarSociosRP
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
		idPersona INT PRIMARY KEY,
		dni VARCHAR(15) COLLATE Modern_Spanish_CI_AS,
		nombre VARCHAR(50) COLLATE Modern_Spanish_CI_AS,
		apellido VARCHAR(50) COLLATE Modern_Spanish_CI_AS,
	);

	
	SET NOCOUNT ON;    -- Evita mensajes
	SET XACT_ABORT ON; -- Hacer rollback automático ante cualquier error

	BEGIN TRY
		BEGIN TRAN;

		DECLARE @sql VARCHAR(2048);

		SET @sql = '
		INSERT INTO #tempDatosPersona
		SELECT 
		  [Nro de Socio], 
		  Nombre, 
		  TRIM([ apellido]), 
		  CAST([ DNI] AS VARCHAR(15)), 
		  [ email personal], 
		  TRY_CONVERT(DATE, [ fecha de nacimiento], 103),
		  CAST(CAST([ teléfono de contacto] AS DECIMAL(20,0)) AS VARCHAR(20)),
		  CAST(CAST([ teléfono de contacto emergencia] AS DECIMAL(20,0)) AS VARCHAR(20)),
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

		INSERT INTO Persona.Persona(nombre, apellido, fechaNac, dni, telefono, telefonoEmergencia, email)
		OUTPUT INSERTED.idPersona, INSERTED.dni, inserted.nombre, inserted.apellido INTO #NuevosSocios(idPersona, dni, nombre, apellido)
		SELECT t.nombre, t.apellido, t.fechaNacimiento, t.dni, t.telefono, t.telefonoEmergencia, t.email
		FROM #tempDatosPersona t	
		WHERE NOT EXISTS ( SELECT 1 FROM Socio.Socio s WHERE s.nroSocio = t.nroSocio );
			
		-- Insertar nuevos socios.

		INSERT INTO Socio.Socio(idSocio, nroSocio, idCategoria, idObraSocial, nroObraSocial)
		SELECT 
			ns.idPersona,
			t.nroSocio,
			c.idCategoria,
			o.idObraSocial,
			t.nroObraSocial
		FROM #nuevosSocios ns
		JOIN #tempDatosPersona t ON t.dni = ns.dni AND t.nombre COLLATE Modern_Spanish_CI_AS = ns.nombre --Debido a que hay un DNI duplicado 
			AND t.apellido COLLATE Modern_Spanish_CI_AS = ns.apellido
		JOIN Socio.Categoria c ON c.nombre = 'Mayor'
		JOIN Socio.ObraSocial o ON o.nombre = t.obraSocial



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
		FROM Persona.Persona p
		JOIN Socio.Socio s ON s.idSocio = p.idPersona
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
		FROM Socio.Socio s
		JOIN #tempDatosPersona t ON t.nroSocio = s.nroSocio
		JOIN Socio.ObraSocial o ON o.nombre = t.obraSocial 
		WHERE
		  s.idObraSocial <> o.idObraSocial OR
		  s.nroObraSocial <> t.nroObraSocial COLLATE Modern_Spanish_CI_AI;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		DECLARE @ErrorMensaje VARCHAR(4000) = ERROR_MESSAGE();
		RAISERROR('Error en Importacion.ImportarSociosRP: %s', 16, 1, @ErrorMensaje);
	END CATCH

	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;

	DROP TABLE #tempDatosPersona;
	DROP TABLE #nuevosSocios;
END;
GO



/*
--------------------------------------------------------------------------------
  SECCIÓN: Grupos Familiares
  Descripción : Carga las relaciones de tutores y menores desde el archivo maestro 
				correspondiente y las inserta en la tabla Socio.GrupoFamiliar,
				estableciendo quien es responsable de cada socio.

--------------------------------------------------------------------------------
*/
CREATE OR ALTER PROCEDURE Importacion.ImportarGrupoFamiliar
	@rutaCompletaArchivo VARCHAR(260)
AS
BEGIN
	
	

	CREATE TABLE #tempDatosPersonaGrupoFamiliar(
		nroSocio VARCHAR(10) COLLATE Modern_Spanish_CI_AS PRIMARY KEY,
		nroSocioTutor VARCHAR(10) COLLATE Modern_Spanish_CI_AS,
		nombre VARCHAR(50) COLLATE Modern_Spanish_CI_AS,
		apellido VARCHAR(50) COLLATE Modern_Spanish_CI_AS,
		dni VARCHAR(15) COLLATE Modern_Spanish_CI_AS,
		email VARCHAR(100) COLLATE Modern_Spanish_CI_AS,
		fechaNacimiento DATE,
		telefono VARCHAR(20) COLLATE Modern_Spanish_CI_AS,
		telefonoEmergencia VARCHAR(20) COLLATE Modern_Spanish_CI_AS,
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

	SET NOCOUNT ON;    -- Evita mensajes
	SET XACT_ABORT ON; -- Hacer rollback automático ante cualquier error

	BEGIN TRY
		BEGIN TRAN;

		DECLARE @sql VARCHAR(2048);

		SET @sql = '
		INSERT INTO #tempDatosPersonaGrupoFamiliar
		SELECT 
		  [Nro de Socio], 
		  [Nro de socio RP], 
		  Nombre, 
		  TRIM([ apellido]), 
		  CAST(CAST([ DNI] AS DECIMAL(15,0)) AS VARCHAR(15)),
		  [ email personal], 
		  TRY_CONVERT(DATE, [ fecha de nacimiento], 103),
		  [ teléfono de contacto],
		  TRY_CONVERT(VARCHAR(20), CAST([ teléfono de contacto emergencia] AS DECIMAL(20,0))),
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


		
		--Insertar datos personales de socios de GrupoFamiliar.
		INSERT INTO Persona.Persona(nombre, apellido, fechaNac, dni, telefono, telefonoEmergencia, email)
		OUTPUT inserted.idPersona, inserted.dni, inserted.nombre, inserted.apellido INTO #NuevosSocios (idSocioMenor, dni, nombre, apellido)
		SELECT t.nombre, t.apellido, t.fechaNacimiento, t.dni, t.telefono, t.telefonoEmergencia, t.email
		FROM #tempDatosPersonaGrupoFamiliar t		
		WHERE NOT EXISTS ( SELECT 1 FROM Socio.Socio s WHERE s.nroSocio = t.nroSocio );
		

		--Insertar socios de GrupoFamiliar.
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
		  JOIN Persona.Persona p ON p.idPersona = ns.idSocioMenor
		)
		INSERT INTO Socio.Socio(idSocio, nroSocio, idCategoria, idObraSocial, nroObraSocial)
		SELECT sce.idSocioMenor, t.nroSocio, c.idCategoria, o.idObraSocial, t.nroObraSocial 
		FROM SociosConEdad sce
		JOIN #tempDatosPersonaGrupoFamiliar t ON t.dni = sce.dni  
			AND t.nombre = sce.nombre
			AND t.apellido = sce.apellido 
		JOIN Socio.Categoria c ON 
		c.nombre = CASE 
					   WHEN sce.edad <= 12 THEN 'Menor'
					   WHEN sce.edad <= 17 THEN 'Cadete'
					   ELSE 'Mayor'
				   END
		LEFT JOIN Socio.ObraSocial o ON o.nombre = t.obraSocial;



		--Insertar Grupos Familiares.

		INSERT INTO Socio.GrupoFamiliar(idSocioTutor, idSocioMenor, parentesco)
		SELECT st.idSocio, sm.idSocio, NULL
		FROM #NuevosSocios ns
		JOIN Socio.Socio sm ON sm.idSocio = ns.idSocioMenor
		JOIN #tempDatosPersonaGrupoFamiliar t ON t.nroSocio = sm.nroSocio
		JOIN Socio.Socio st ON st.nroSocio = t.nroSocioTutor
		WHERE NOT EXISTS (
			SELECT 1
			FROM Socio.GrupoFamiliar gf
			WHERE gf.idSocioMenor = sm.idSocio AND gf.idSocioTutor = st.idSocio
		)

		--Actualizar datos personales de socios en Grupo Familiar
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
		FROM Persona.Persona p
		JOIN Socio.Socio s ON s.idSocio = p.idPersona
		JOIN #tempDatosPersonaGrupoFamiliar t ON t.nroSocio = s.nroSocio
		WHERE 
			p.nombre <> t.nombre OR
			p.apellido <> t.apellido OR
			p.dni <> t.dni OR
			p.fechaNac <> t.fechaNacimiento OR
			p.telefono <> t.telefono OR
			p.telefonoEmergencia <> t.telefonoEmergencia OR
			p.email <> t.email;


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
		FROM Socio.Socio s
		JOIN SociosConFechaNacModificada sm ON sm.idSocioMenor = s.idSocio
		JOIN Socio.Categoria c ON
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
		FROM Socio.Socio s
		JOIN #tempDatosPersonaGrupoFamiliar t ON t.nroSocio = s.nroSocio 
		JOIN Socio.ObraSocial obraNueva ON obraNueva.nombre = t.obraSocial
		WHERE s.idObraSocial <> obraNueva.idObraSocial;


		--Actualizar Grupo Familiar en caso de que el tutor haya cambiado.
		UPDATE gf
		SET gf.idSocioTutor = st.idSocio
		FROM Socio.GrupoFamiliar gf
		JOIN Socio.Socio sm ON sm.idSocio = gf.idSocioMenor         
		JOIN #tempDatosPersonaGrupoFamiliar t ON t.nroSocio = sm.nroSocio
		JOIN Socio.Socio st ON st.nroSocio = t.nroSocioTutor        
		WHERE gf.idSocioTutor <> st.idSocio;              

		
		COMMIT TRANSACTION;
		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		DECLARE @ErrorMensaje VARCHAR(4000) = ERROR_MESSAGE();
		RAISERROR('Error en Importacion.ImportarGrupoFamiliar: %s', 16, 1, @ErrorMensaje);
	END CATCH
	
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
	
	DROP TABLE #tempDatosPersonaGrupoFamiliar
	DROP TABLE #NuevosSocios
END;
GO



/*
--------------------------------------------------------------------------------
  PROCEDIMIENTO: ImportarAsistencias
  Descripción : Carga las asistencias desde archivo maestro correspondiente y genera
                las facturas correspondientes en la tabla Factura.Factura,
                basadas en las actividades efectivamente realizadas.

  Aclaraciones:
    - Solo importa asistencias hasta la fecha actual, para no registrar eventos futuros que aun no ocurrieron.
    - Cada factura se genera para la actividad realizada en una fecha concreta(principio de mes), agrupando por mes y socio según corresponda.
	- Al no haber Pagos registrados de las Actividades Deportivas, asumo que las Facturas fueron pagadas, aunque no tengan un pago asociado.
	- Las Facturas se asignaran a los Tutores, en caso de que un Socio dentro de un Grupo Familiar realice una Actividad Deportiva.
--------------------------------------------------------------------------------
*/
CREATE OR ALTER PROCEDURE Importacion.ImportarAsistencias
	@rutaCompletaArchivo VARCHAR(260)
AS
BEGIN
	
	CREATE TABLE #tempAsistencia (
		nroSocio VARCHAR(10) COLLATE Modern_Spanish_CI_AS ,
		actividad VARCHAR(30) COLLATE Modern_Spanish_CI_AS,
		fecha DATE,
		asistencia VARCHAR(2) COLLATE Modern_Spanish_CI_AS,
		profesor VARCHAR(100) COLLATE Modern_Spanish_CI_AS
	);

	SET NOCOUNT ON;    -- Evita mensajes
	SET XACT_ABORT ON; -- Hacer rollback automático ante cualquier error

	BEGIN TRY		
		BEGIN TRAN;

		DECLARE @sql VARCHAR(1024) = '
        INSERT INTO #tempAsistencia(nroSocio, actividad, fecha, asistencia, profesor)
        SELECT
          [Nro de Socio],
          [Actividad],
          CONVERT(DATE, [fecha de asistencia], 103),   
          [Asistencia],
          [Profesor]
        FROM OPENROWSET(
          ''Microsoft.ACE.OLEDB.16.0'',
          ''Excel 12.0;HDR=YES;IMEX=1;Database=' + @rutaCompletaArchivo + ''',
          ''SELECT * FROM [presentismo_actividades$]''
        ) AS datosExcel
		WHERE CONVERT(DATE, datosExcel.[fecha de asistencia], 103) <= GETDATE() 
        ';


        EXEC (@sql)

		INSERT INTO Actividad.Clase (fecha, idActividadDeportiva, profesor)
        SELECT DISTINCT
            t.fecha, a.idActividadDeportiva, t.profesor
        FROM #tempAsistencia t
        JOIN Actividad.ActividadDeportiva a ON a.nombre = t.actividad
		WHERE NOT EXISTS(
			SELECT 1 FROM Actividad.Clase c WHERE c.fecha = t.fecha AND c.idActividadDeportiva = a.idActividadDeportiva 
				AND c.profesor = t.profesor
		)


		INSERT INTO Actividad.Asiste(idSocio, idClase, asistencia)
		SELECT s.idSocio, c.idClase, t.asistencia
		FROM #tempAsistencia t
		JOIN Socio.Socio s ON s.nroSocio = t.nroSocio
		JOIN Actividad.ActividadDeportiva a ON a.nombre = t.actividad
		JOIN Actividad.Clase c ON c.fecha = t.fecha AND c.idActividadDeportiva = a.idActividadDeportiva AND c.profesor = t.profesor
		WHERE NOT EXISTS (
		  SELECT 1
		  FROM Actividad.Asiste
		  WHERE Asiste.idSocio = s.idSocio
			AND Asiste.idClase = c.idClase
		);



		--Las Facturas se asignaran a los Tutores, en caso de que un Socio dentro de un Grupo Familiar realice una Actividad Deportiva.
		
	
		WITH InformacionFactura AS (
			-- 1) Obtiene cada asistencia y el mes de facturación (primer día del mes)
			SELECT DISTINCT
				ad.idActividadDeportiva,
				ad.nombre                              AS nombreActividad,
				s.idSocio                              AS socioRealizoActividad,
				s.nroSocio                             AS nroSocioRealizoActividad,
				COALESCE(gf.idSocioTutor, s.idSocio)   AS idDueñoFactura,
				DATEFROMPARTS(YEAR(c.fecha), MONTH(c.fecha), 1) AS fechaAsistencia -- Entiendo que no cambia el precio si la actividad se realiza a mitad o principio de mes, por ende, solo se discrimina por mes y año.
			FROM Actividad.Asiste AS a
			JOIN Actividad.Clase AS c
				ON c.idClase = a.idClase
			JOIN Actividad.ActividadDeportiva AS ad
				ON ad.idActividadDeportiva = c.idActividadDeportiva
			JOIN Socio.Socio AS s
				ON s.idSocio = a.idSocio
			LEFT JOIN Socio.GrupoFamiliar AS gf
				ON gf.idSocioMenor = s.idSocio
		),
		PrecioActividadPorFecha AS (
			-- 2) Para cada asistencia, ordena las tarifas por vigencia y proximidad
			SELECT
				inf.idActividadDeportiva,
				inf.fechaAsistencia,
				inf.socioRealizoActividad,
				inf.nroSocioRealizoActividad,
				inf.idDueñoFactura,
				inf.nombreActividad,
				c.precio,
				ROW_NUMBER() OVER (
					PARTITION BY 
						inf.idActividadDeportiva, 
						inf.fechaAsistencia
					ORDER BY
						-- Prioriza primero las tarifas cuya fechaVigencia sea igual o posterior al primer día del mes de la actividad; 
						--si no existe ninguna,  considerará las tarifas anteriores.

						CASE WHEN c.fechaVigencia >= inf.fechaAsistencia THEN 0 ELSE 1 END,

						-- Luego, ordena por cercanía en días a ese primer día de mes
						ABS(DATEDIFF(day, c.fechaVigencia, inf.fechaAsistencia))
				) AS precioMasCercano
			FROM InformacionFactura AS inf
			JOIN Actividad.CostoActividadDeportiva AS c
				ON c.idActividadDeportiva = inf.idActividadDeportiva
		),
		FacturasBrutas AS (
			-- 3) Selecciona solo el precio más cercano por asistencia
			SELECT
				paf.idActividadDeportiva,
				paf.fechaAsistencia,
				paf.socioRealizoActividad,
				paf.nroSocioRealizoActividad,
				paf.idDueñoFactura,
				paf.nombreActividad,
				paf.precio
			FROM PrecioActividadPorFecha AS paf
			WHERE paf.precioMasCercano = 1
		),
		FacturasMensuales AS (
			-- 4) Cuenta cuántas actividades se cobran por socio y mes
			SELECT
				idDueñoFactura,
				DATEFROMPARTS(YEAR(fechaAsistencia), MONTH(fechaAsistencia), 1) AS primerDiaMes,
				COUNT(*)                                        AS CantidadActividades
			FROM FacturasBrutas
			GROUP BY
				idDueñoFactura,
				DATEFROMPARTS(YEAR(fechaAsistencia), MONTH(fechaAsistencia), 1)
		)
		
		INSERT INTO Factura.Factura (tipoItem,fechaEmision,observaciones,subtotal,idSocio,estado)
		SELECT
			fb.nombreActividad,
			fb.fechaAsistencia,
			CASE 
				WHEN fm.CantidadActividades > 1 
					THEN '10% descuento aplicado por ' 
						+ CAST(fm.CantidadActividades AS VARCHAR(2)) 
						+ ' actividades'
				ELSE NULL
			END,
			CASE 
				WHEN fm.CantidadActividades > 1 
					THEN ROUND(fb.precio * 0.90, 2)
				ELSE fb.precio
			END,
			fb.idDueñoFactura,
			'Pagada'
		FROM FacturasBrutas AS fb
		JOIN FacturasMensuales AS fm
			ON fm.idDueñoFactura = fb.idDueñoFactura
		   AND fm.primerDiaMes   = DATEFROMPARTS(YEAR(fb.fechaAsistencia), MONTH(fb.fechaAsistencia), 1)
		WHERE NOT EXISTS (
			SELECT 1
			FROM Factura.Factura AS f
			WHERE 
				f.tipoItem     = fb.nombreActividad
				AND f.fechaEmision = fb.fechaAsistencia
				AND f.idSocio    = fb.idDueñoFactura
		);



		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		DECLARE @ErrorMensaje VARCHAR(4000) = ERROR_MESSAGE();
		RAISERROR('Error en Importacion.ImportarAsistencias: %s', 16, 1, @ErrorMensaje);
	END CATCH

	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
	DROP TABLE #tempAsistencia;
END;
GO


/*
--------------------------------------------------------------------------------
  PROCEDIMIENTO: ImportarCuotas
  Descripción : Carga los pagos de cuotas archivo maestro correspondiente y genera
                los registros correspondientes en las tablas Pago.Pago y
                Factura.Factura, aplicando recargos según la fecha de pago.

  Aclaraciones:
	- No vi que se contemplen los descuentos en el archivo maestro, por lo que que el totalFactura no tendra aplicado ningun descuento.
		 En caso de haberse contemplado, podria calcularse un TotalFactura menor y dejar el resto del Pago como SaldoACuenta.
	- FechaEmision se fija siempre al primer dia del mes correspondiente al pago (mes y año de fechaPago).
	- Al analizar los pagos de cuotas detecte un importe de $22 000 aplicado cuando fechaPago supera los primeros 10 días del mes.
		 Derivo que al totalFactura debe sustraerse el recargo cobrado en el Pago cuando se cumple la condicion antes mencionada.
	
	
--------------------------------------------------------------------------------
*/

CREATE OR ALTER PROCEDURE Importacion.ImportarCuotas
	@rutaCompletaArchivo VARCHAR(260)
AS
BEGIN
	
	CREATE TABLE #tempPagos (
		idTransaccion VARCHAR(64) COLLATE Modern_Spanish_CI_AS PRIMARY KEY,
		fecha DATE,
		nroSocio VARCHAR(10) COLLATE Modern_Spanish_CI_AS,
		valor DECIMAL(10,2),
		medioDePago VARCHAR(20) COLLATE Modern_Spanish_CI_AS,

	);

	CREATE TABLE #NuevasCuotas (
		idPago INT PRIMARY KEY,
		idTransaccion VARCHAR(64) COLLATE Modern_Spanish_CI_AS,
		fechaPago DATE
	);


	SET NOCOUNT ON;    -- Evita mensajes
	SET XACT_ABORT ON; -- Hacer rollback automático ante cualquier error

	BEGIN TRY		
		BEGIN TRANSACTION;

		
		DECLARE @sql VARCHAR(1024) = '
        INSERT INTO #tempPagos(idTransaccion, fecha, nroSocio, valor, medioDePago)
        SELECT
			CAST(CAST([Id de pago] AS DECIMAL(38,0)) AS VARCHAR(32)),
			fecha,
			[Responsable de pago],
			Valor,
			[Medio de pago]
        FROM OPENROWSET(
          ''Microsoft.ACE.OLEDB.16.0'',
          ''Excel 12.0;HDR=YES;IMEX=1;Database=' + @rutaCompletaArchivo + ''',
          ''SELECT * FROM [pago cuotas$]''
        ) AS datosExcel;
        ';
        EXEC (@sql);
		
		
		--Inserto nuevos pagos y guardo sus claves en #NuevasCuotas
		INSERT INTO Pago.Pago (
			idTransaccion,
			fecha,
			monto,
			idFormaPago
		)
		OUTPUT
			inserted.idPago,
			inserted.idTransaccion,
			inserted.fecha
		INTO #NuevasCuotas (idPago, idTransaccion, fechaPago)
		SELECT
			t.idTransaccion,
			t.fecha,
			t.valor,
			fp.idFormaPago
		FROM #tempPagos AS t
		JOIN Pago.FormaPago AS fp
			ON fp.nombre = t.medioDePago
		WHERE NOT EXISTS (
			SELECT 1
			FROM Pago.Pago AS p
			WHERE p.idTransaccion = t.idTransaccion
		);


		DECLARE @recargo DECIMAL(5,4) = 1.10;
		DECLARE @diaLimiteRecargo INT     = 10;		
													
	
		-- Genero facturas a partir de los pagos recien insertados
		INSERT INTO Factura.Factura (
			tipoItem,
			fechaEmision,
			observaciones,
			subtotal,
			idSocio,
			idPago,
			estado
		)
		SELECT
			'Cuota',  
			DATEFROMPARTS(
				YEAR(nc.fechaPago),
				MONTH(nc.fechaPago),
				1
			)                              AS fechaEmision,
	
			NULL,
			-- Si el pago fue despues del dia limite se quita el recargo del total del Pago.
			CASE
				WHEN DAY(nc.fechaPago) > @diaLimiteRecargo THEN
					ROUND(t.valor / @recargo, 2)
				ELSE
					ROUND(t.valor, 2)
			END                              AS subtotal,
			s.idSocio                        AS idSocio,
			p.idPago                         AS idPago,
			CASE
				WHEN p.fecha > DATEADD(DAY,10, DATEFROMPARTS(YEAR(nc.fechaPago),MONTH(nc.fechaPago),1)) THEN 'Pagada'
				ELSE 'Pagada Vencida'
			END
		FROM #NuevasCuotas AS nc
		JOIN Pago.Pago       AS p
			ON p.idPago = nc.idPago
		JOIN #tempPagos      AS t
			ON t.idTransaccion = nc.idTransaccion
		JOIN Socio.Socio     AS s
			ON s.nroSocio = t.nroSocio
		WHERE NOT EXISTS (
			SELECT 1
			FROM Factura.Factura AS f
			  WHERE f.idSocio      = s.idSocio
				  AND f.tipoItem     = 'Cuota'
				  AND f.fechaEmision = DATEFROMPARTS(YEAR(nc.fechaPago), MONTH(nc.fechaPago), 1)   
		);


		
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		DECLARE @ErrorMensaje VARCHAR(4000) = ERROR_MESSAGE();
		RAISERROR('Error en Importacion.ImportarCuotas: %s', 16, 1, @ErrorMensaje);
	END CATCH

	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;

	DROP TABLE #tempPagos;
	DROP TABLE #NuevasCuotas;
END;
GO


