USE Com5600G05						
GO


EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO


--------------------------------------Creacion de tablas para que funcionen los SP--------------------------------------------

CREATE TABLE Jornada(
	fecha DATE PRIMARY KEY,
	huboLluvia BIT NOT NULL
);
GO


CREATE TABLE ActividadDeportiva(
	idActividadDeportiva INT PRIMARY KEY IDENTITY(1,1),
	nombre VARCHAR(30) COLLATE Modern_Spanish_CI_AS NOT NULL UNIQUE

);
GO

CREATE TABLE Categoria(
	idCategoria INT PRIMARY KEY IDENTITY(1,1),
	nombre VARCHAR(30) COLLATE Modern_Spanish_CI_AS NOT NULL UNIQUE,
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
	descripcion VARCHAR(30) COLLATE Modern_Spanish_CI_AS NOT NULL UNIQUE
);
GO


CREATE TABLE Tarifa(

	idTarifaPileta INT PRIMARY KEY IDENTITY(1,1),
	fechaVigencia DATE NOT NULL,
	precio DECIMAL(10,2) NOT NULL,

	tipoCliente VARCHAR(10) COLLATE Modern_Spanish_CI_AS CHECK (TipoCliente IN ('Socio','Invitado')),
	tipoDuracion VARCHAR(10) COLLATE Modern_Spanish_CI_AS CHECK (tipoDuracion IN ('Día','Mes','Temporada')),
	tipoEdad VARCHAR(10) COLLATE Modern_Spanish_CI_AS CHECK (tipoEdad IN ('Adulto','Menor')),
	idTipoActividadExtra INT NOT NULL,


	CONSTRAINT FK_Tarifa_TipoActividadExtra FOREIGN KEY (idTipoActividadExtra) REFERENCES TipoActividadExtra (idTipoActividadExtra)
);
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


CREATE TABLE Cuota (
    idCuota			INT PRIMARY KEY IDENTITY(1,1),
    idSocio			INT NOT NULL,
	periodo			DATE NOT NULL,
    	
    montoCuota		DECIMAL(10,2) NOT NULL,
    estado			VARCHAR(20) NOT NULL CHECK(estado IN ('Pendiente','Pagada','Pagada Vencida', 'Cancelada')) DEFAULT 'Pendiente',
        
		
    CONSTRAINT FK_Cuota_Socio			FOREIGN KEY (idSocio) REFERENCES Socio(idSocio),

	CHECK (montoCuota >= 0),
);

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



CREATE TABLE Factura(

	idFactura INT PRIMARY KEY IDENTITY(1,1),

	nroComprobante AS RIGHT('00000000' + CONVERT(VARCHAR(8), idFactura), 8 ) PERSISTED,

	puntoDeVenta CHAR(4) NOT NULL DEFAULT '0001',
	tipoFactura CHAR(1) NOT NULL,
	concepto VARCHAR(100) NOT NULL,
	fechaEmision DATE NOT NULL,

	cae CHAR(14) DEFAULT NULL,
	caeVTO DATE DEFAULT NULL,
	
	totalFactura DECIMAL(10,2), --IVA incluido o no.

	--condicionVenta VARCHAR(30) NOT NULL, --Contado/Debito Automatico/Cta Cte/..
	
	fechaRecargo AS DATEADD(DAY, 5, fechaEmision)  PERSISTED,
	fechaVencimiento AS DATEADD(DAY, 10, fechaEmision)  PERSISTED,

	estado VARCHAR(15) NOT NULL CHECK (estado IN ('Pendiente', 'Pagada','Pagada Vencida', 'Cancelada')) DEFAULT 'Pendiente',

	idSocio INT NOT NULL,
	idPago INT,

	CONSTRAINT FK_Factura_Socio FOREIGN KEY (idSocio) REFERENCES Socio(idSocio),
	CONSTRAINT FK_Factura_Pago FOREIGN KEY (idPago) REFERENCES Pago(idPago),

	CHECK (tipoFactura IN ('A','B','C','E','M')),
	CHECK (tipoFactura IN ('A','M') OR tipoFactura IN ('B','C','E')),
	CHECK ((cae IS NULL  AND caeVto IS NULL) OR (cae IS NOT NULL AND caeVto IS NOT NULL)),
	CHECK (totalFactura >= 0)
);
GO




CREATE TABLE ItemFactura(
	idItemFactura INT PRIMARY KEY IDENTITY(1,1),
	descripcion VARCHAR(50) NOT NULL,

	importeBase DECIMAL(10,2) NOT NULL, 
    descuentoPorcentaje TINYINT DEFAULT 0,
    importeNeto AS (importeBase * ((1 - descuentoPorcentaje)/100)) PERSISTED, 

	alicuotaIVA DECIMAL(4,2),                 -- Ej. 21, 10.5; NULL en B/C
	ivaImporte AS (CASE
						WHEN alicuotaIVA IS NULL THEN 0
						ELSE importeBase * (1 - descuentoPorcentaje/100.0) * alicuotaIVA / 100.0
					END) PERSISTED,
	totalItem AS (importeBase * (1 - descuentoPorcentaje/100.0) + 
					CASE
						WHEN alicuotaIVA IS NULL THEN 0
						ELSE importeBase * (1 - descuentoPorcentaje/100.0) * alicuotaIVA / 100.0
					END) PERSISTED,
	
	idFactura INT NOT NULL,

	CONSTRAINT FK_ItemFactura_Factura FOREIGN KEY (idFactura) REFERENCES Factura(idFactura),

	CHECK (importeBase >= 0),
    CHECK (descuentoPorcentaje BETWEEN 0 AND 100),
    CHECK ((alicuotaIVA IS NULL AND ivaImporte = 0) OR alicuotaIVA IN (0, 10.5, 21.0))
);	
GO




CREATE TABLE Pago(

	idPago INT PRIMARY KEY IDENTITY(1,1),
	idTransaccion VARCHAR(32) NOT NULL UNIQUE,
	fecha DATE NOT NULL,
	monto DECIMAL(10,2) NOT NULL CHECK (monto >= 0),

	idFormaPago INT NOT NULL,

	CONSTRAINT FK_Pago_FormaPago FOREIGN KEY (idFormaPago) REFERENCES FormaPago(idFormaPago),

);

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


