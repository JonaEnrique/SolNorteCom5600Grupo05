USE Com5600G05						
GO


EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO


--------------------------------------Creacion de tablas para que funcionen los SP--------------------------------------------


CREATE TABLE ActividadDeportiva(
	idActividadDeportiva INT PRIMARY KEY IDENTITY(1,1),
	nombre VARCHAR(30) NOT NULL UNIQUE

);
GO

CREATE TABLE Categoria(
	idCategoria INT PRIMARY KEY IDENTITY(1,1),
	nombre VARCHAR(30) NOT NULL UNIQUE,
	edadMinima TINYINT,
	edadMaxima TINYINT
);
GO

CREATE TABLE CostoActividadDeportiva(

	idCostoActividad INT PRIMARY KEY IDENTITY(1,1),
	fechaVigencia DATE NOT NULL,
	precio DECIMAL(10,2) NOT NULL,
	
	idActividadDeportiva INT NOT NULL,

    CONSTRAINT FK_CostoActividad_ActividadDeportiva FOREIGN KEY (idActividadDeportiva) REFERENCES ActividadDeportiva (idActividadDeportiva),
	CONSTRAINT UQ_Actividad_Fecha UNIQUE(idActividadDeportiva, fechaVigencia)
);
GO

CREATE TABLE CostoCategoria(

	idCostoCategoria INT PRIMARY KEY IDENTITY(1,1),
	fechaVigencia DATE NOT NULL,
	precio DECIMAL(10,2) NOT NULL,

	idCategoria INT NOT NULL,

	CONSTRAINT FK_CostoCategoria_Categoria FOREIGN KEY (idCategoria) REFERENCES Categoria (idCategoria)

);
GO

CREATE TABLE TipoActividadExtra(
	idTipoActividadExtra INT PRIMARY KEY IDENTITY(1,1),
	descripcion VARCHAR(30) NOT NULL UNIQUE
);
GO

CREATE TABLE Tarifa(

	idTarifaPileta INT PRIMARY KEY IDENTITY(1,1),
	fechaVigencia DATE NOT NULL,
	precio DECIMAL(10,2) NOT NULL,

	tipoCliente VARCHAR(10) CHECK (TipoCliente IN ('Socio','Invitado')),
	tipoDuracion VARCHAR(10) CHECK (tipoDuracion IN ('Día','Mes','Temporada')),
	tipoEdad VARCHAR(10) CHECK (tipoEdad IN ('Adulto','Menor')),
	idTipoActividadExtra INT NOT NULL,


	CONSTRAINT FK_Tarifa_TipoActividadExtra FOREIGN KEY (idTipoActividadExtra) REFERENCES TipoActividadExtra (idTipoActividadExtra)
);
GO

CREATE TABLE Jornada(
	idJornada INT PRIMARY KEY,
	fecha DATE UNIQUE NOT NULL,
	huboLluvia BIT NOT NULL,
)
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Jornada')
      AND name = 'IX_Jornada_Fecha'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Jornada_Fecha
    ON dbo.Jornada(fecha);
END;
GO


CREATE TABLE Persona(
	idPersona INT PRIMARY KEY IDENTITY(1,1),
	nombre VARCHAR(50) NOT NULL,
	apellido VARCHAR(50) NOT NULL,
	fechaNac DATE, --Deberia ser NOT NULL pero hay una fecha que es 10/19/1981.
	dni VARCHAR(15) NOT NULL, --Deberia ser UNIQUE pero hay un dni que se repite en el archivo.
	telefono VARCHAR(20),
	telefonoEmergencia VARCHAR(20),
	email VARCHAR(100),
	idRol INT DEFAULT NULL
);
GO


CREATE TABLE ObraSocial(
	idObraSocial INT PRIMARY KEY IDENTITY(1,1),
	nombre VARCHAR(40) NOT NULL,
	telefono VARCHAR(40) NOT NULL
);
GO



CREATE TABLE Socio(
	idSocio INT PRIMARY KEY,
	nroSocio VARCHAR(10) NOT NULL,
	idCategoria INT NOT NULL,
	idObraSocial INT,
	nroObraSocial VARCHAR(30),

	CONSTRAINT FK_Socio_Persona FOREIGN KEY (idSocio) REFERENCES Persona(idPersona),
	CONSTRAINT FK_Socio_Categoria FOREIGN KEY (idCategoria) REFERENCES Categoria(idCategoria),
	CONSTRAINT FK_Socio_ObraSocial FOREIGN KEY (idObraSocial) REFERENCES ObraSocial(idObraSocial)
);
GO

CREATE TABLE GrupoFamiliar(
	idSocioTutor INT,
	idSocioMenor INT,
	parentesco VARCHAR(30) DEFAULT NULL

	CONSTRAINT PK_GrupoFamiliar PRIMARY KEY (idSocioTutor, idSocioMenor),
	CONSTRAINT FK_GrupoFamiliar_SocioTutor FOREIGN KEY (idSocioTutor) REFERENCES Socio(idSocio),
	CONSTRAINT FK_GrupoFamiliar_SocioMenor FOREIGN KEY (idSocioMenor) REFERENCES Socio(idSocio)
);
GO

CREATE TABLE FormaPago(
	idFormaPago INT PRIMARY KEY IDENTITY(1,1),
	descripcion VARCHAR(20) NOT NULL UNIQUE
);
GO

CREATE TABLE Clase(
	idClase INT PRIMARY KEY IDENTITY(1,1),
	fecha DATE NOT NULL,
	profesor VARCHAR(100) NOT NULL,
	idActividadDeportiva INT NOT NULL,
	--idCategoria INT NOT NULL, --Socios que son Mayores y Menores asisten a la misma clase, lo cual no tiene logica si las clases se dictan por categoria.

	CONSTRAINT FK_Clase_Actividad FOREIGN KEY (idActividadDeportiva) REFERENCES ActividadDeportiva(idActividadDeportiva),	
	--CONSTRAINT FK_Clase_Categoria FOREIGN KEY (idCategoria) REFERENCES Categoria(idCategoria),

	CONSTRAINT UQ_Clase_ActividadFechaCategoria UNIQUE(idActividadDeportiva, fecha, profesor)
);
GO

CREATE TABLE Asiste(
	idAsistencia INT PRIMARY KEY IDENTITY(1,1),
	idSocio INT NOT NULL,
	idClase INT NOT NULL,
	asistencia CHAR(2) NOT NULL

	CONSTRAINT FK_Asiste_Socio FOREIGN KEY (idSocio) REFERENCES Socio(idSocio),
	CONSTRAINT FK_Asiste_Clase FOREIGN KEY (idClase) REFERENCES Clase(idClase),

	CONSTRAINT UQ_Asiste_ClaseSocio UNIQUE(idClase, idSocio)
);
GO

-------------------------------------------------------------------------------------------------------------



CREATE OR ALTER PROCEDURE cargarObrasSociales
	@rutaCompletaArchivo VARCHAR(260)
AS
BEGIN
	BEGIN TRY		
		DECLARE @sql VARCHAR(1024);
		SET @sql = '
		INSERT INTO ObraSocial(nombre, telefono)
		SELECT DISTINCT 
			TRIM([ Nombre de la obra social o prepaga]), 
			TRIM([teléfono de contacto de emergencia ])
		FROM OPENROWSET(
			''Microsoft.ACE.OLEDB.16.0'',
			''Excel 12.0;HDR=YES;IMEX=1;Database=' + @rutaCompletaArchivo + ''',
			''SELECT [ Nombre de la obra social o prepaga], [teléfono de contacto de emergencia] FROM [Responsables de Pago$]''
		) AS datosExcel
		WHERE NOT EXISTS (
			SELECT 1 
			FROM ObraSocial o
			WHERE o.nombre = TRIM([ Nombre de la obra social o prepaga]) COLLATE Modern_Spanish_CI_AS
		);';
		EXEC (@sql);

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMsg VARCHAR(4000) = ERROR_MESSAGE();
		RAISERROR('Error en cargarObrasSociales: %s', 16, 1, @ErrorMsg);
	END CATCH
END;
GO


CREATE OR ALTER PROCEDURE cargarActividadesDeportivas
	@rutaCompletaArchivo VARCHAR(260)
AS
BEGIN
	BEGIN TRY		
		DECLARE @sql VARCHAR(512);

		SET @sql = '
		INSERT INTO ActividadDeportiva(nombre)
		SELECT Actividad
		FROM OPENROWSET(
			''Microsoft.ACE.OLEDB.16.0'',
			''Excel 12.0;HDR=YES;IMEX=1;Database=' + @rutaCompletaArchivo + ''',
			''SELECT Actividad FROM [Tarifas$B2:B8]''
		) AS datosExcel
		WHERE NOT EXISTS (
			SELECT 1 
			FROM ActividadDeportiva a
			WHERE a.nombre = Actividad COLLATE Modern_Spanish_CI_AS
		);';

		EXEC(@sql);

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMsg VARCHAR(4000) = ERROR_MESSAGE();
		RAISERROR('Error en cargarActividadesDeportivas: %s', 16, 1, @ErrorMsg);
	END CATCH
END;
GO



CREATE OR ALTER PROCEDURE cargarCategorias
	@rutaCompletaArchivo VARCHAR(260)
AS
BEGIN
	BEGIN TRY		
		DECLARE @sql VARCHAR(1024);

		SET @sql = '
		INSERT INTO Categoria(nombre, edadMinima, edadMaxima)
		SELECT 
			[Categoria socio],
			CASE [Categoria socio]
				WHEN ''Menor''  THEN 0
				WHEN ''Cadete'' THEN 13
				WHEN ''Mayor''  THEN 18
				ELSE NULL
			END AS edadMinima,
			CASE [Categoria socio]
				WHEN ''Menor''  THEN 12
				WHEN ''Cadete'' THEN 17
				WHEN ''Mayor''  THEN NULL
				ELSE NULL
			END AS edadMaxima
		FROM OPENROWSET(
			''Microsoft.ACE.OLEDB.16.0'',
			''Excel 12.0;HDR=YES;IMEX=1;Database=' + @rutaCompletaArchivo + ''',
			''SELECT [Categoria socio] FROM [Tarifas$B10:B13]''
		) AS datosExcel
		WHERE NOT EXISTS (
			SELECT 1
			FROM Categoria c
			WHERE c.nombre = [Categoria socio] COLLATE Modern_Spanish_CI_AS
		);';

		EXEC(@sql);

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMsg VARCHAR(4000) = ERROR_MESSAGE();
		RAISERROR('Error en cargarCategorias: %s', 16, 1, @ErrorMsg);
	END CATCH
END;
GO


IF NOT EXISTS (
  SELECT 1
  FROM TipoActividadExtra t
  WHERE t.descripcion = 'UsoPileta'
)
BEGIN
  INSERT INTO TipoActividadExtra(descripcion)
  VALUES ('UsoPileta');
END


IF NOT EXISTS (
  SELECT 1
  FROM FormaPago f
  WHERE f.descripcion = 'efectivo'
)
BEGIN
  INSERT INTO FormaPago(descripcion)
  VALUES ('efectivo');
END

exec cargarObrasSociales @rutaCompletaArchivo = 'C:\Temp\Datos socios.xlsx';
exec cargarActividadesDeportivas @rutaCompletaArchivo = 'C:\Temp\Datos socios.xlsx';
exec cargarCategorias @rutaCompletaArchivo = 'C:\Temp\Datos socios.xlsx';


/*
CREATE OR ALTER PROCEDURE cargarProfesores
	@rutaCompletaArchivo VARCHAR(260)
AS
BEGIN
	
	CREATE TABLE #tempProfesores (
		nombreCompletoProfesor VARCHAR(100) COLLATE Modern_Spanish_CI_AS
	);

	BEGIN TRY		
		
		BEGIN TRANSACTION


		DECLARE @sql VARCHAR(512);

		SET @sql = '
		INSERT INTO #tempProfesores
		SELECT DISTINCT profesor
		FROM OPENROWSET(
			''Microsoft.ACE.OLEDB.16.0'',
			''Excel 12.0;HDR=YES;IMEX=1;Database=' + @rutaCompletaArchivo + ''',
			''SELECT Profesor FROM [presentismo_actividades$]''
		) AS datosExcel
		';

		EXEC sp_executesql @sql;


		INSERT INTO Persona (nombre, apellido)
		SELECT 
		  LEFT(nombreCompletoProfesor, LEN(nombreCompletoProfesor) - CHARINDEX(' ', REVERSE(nombreCompletoProfesor))),
		  RIGHT(nombreCompletoProfesor, CHARINDEX(' ', REVERSE(nombreCompletoProfesor)) - 1)
		FROM #tempProfesores
		WHERE NOT EXISTS (
		  SELECT 1 FROM Persona p
		  WHERE p.nombre = LEFT(nombreCompletoProfesor, LEN(nombreCompletoProfesor) - CHARINDEX(' ', REVERSE(nombreCompletoProfesor)))
			AND p.apellido = RIGHT(nombreCompletoProfesor, CHARINDEX(' ', REVERSE(nombreCompletoProfesor)) - 1)
		);

		COMMIT TRANSACTION 

	END TRY
	BEGIN CATCH
	IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
		DECLARE @ErrorMsg VARCHAR(4000) = ERROR_MESSAGE();
		RAISERROR('Error en cargarProfesores: %s', 16, 1, @ErrorMsg);
	END CATCH

	DROP TABLE #tempProfesores;
END;
*/



