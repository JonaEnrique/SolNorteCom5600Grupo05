/*
    ---------------------------------------------------------------------
    -Fecha: 20/06/2025
    -Grupo: 05
    -Materia: Bases de Datos Aplicada

    - Integrantes:
        - Nicol�s P�rez       | 40015709
        - Santiago S�nchez    | 42281463
        - Jonathan Enrique    | 43301711
        - Teo Turri           | 42819058

    - Consigna: 
        Cree la base de datos, entidades y relaciones. Incluya restricciones y claves.
    ---------------------------------------------------------------------
*/

USE MASTER;
GO

IF EXISTS (SELECT name FROM master.sys.databases WHERE name = 'Com5600G05')
BEGIN
    ALTER DATABASE Com5600G05 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
END
GO

DROP DATABASE IF EXISTS Com5600G05;
	CREATE DATABASE Com5600G05 COLLATE Modern_Spanish_CI_AS;
GO

USE Com5600G05;
GO

-- *************** CREACI�N DE SCHEMAS *************** --

DROP SCHEMA IF EXISTS Socio;
GO
CREATE SCHEMA Socio;
GO

DROP SCHEMA IF EXISTS Actividad;
GO
CREATE SCHEMA Actividad;
GO

DROP SCHEMA IF EXISTS Factura;
GO
CREATE SCHEMA Factura;
GO

DROP SCHEMA IF EXISTS Persona;
GO
CREATE SCHEMA Persona;
GO

DROP SCHEMA IF EXISTS Pago;
GO
CREATE SCHEMA Pago;
GO

DROP SCHEMA IF EXISTS Usuario;
GO
CREATE SCHEMA Usuario;
GO

DROP SCHEMA IF EXISTS Importacion;
GO
CREATE SCHEMA Importacion;
GO

DROP SCHEMA IF EXISTS Reporte;
GO
CREATE SCHEMA Reporte;
GO

DROP SCHEMA IF EXISTS Seguridad;
GO
CREATE SCHEMA Seguridad;
GO

-- *************** BORRADO de TABLAS *************** --


DECLARE @borrarFKs VARCHAR(MAX) = '';

SELECT
    @borrarFKs += 
      'ALTER TABLE ' 
      + QUOTENAME(OBJECT_SCHEMA_NAME(f.parent_object_id)) 
      + '.' + QUOTENAME(OBJECT_NAME(f.parent_object_id)) 
      + ' DROP CONSTRAINT ' + QUOTENAME(f.name) + ';' + CHAR(13)		--Salto de linea final.
FROM sys.foreign_keys f;

EXEC(@borrarFKs);

DROP TABLE IF EXISTS Pago.Reembolso;
GO

DROP TABLE IF EXISTS Pago.Pago;
GO

DROP TABLE IF EXISTS Pago.FormaPago;
GO

DROP TABLE IF EXISTS Factura.NotaCredito;
GO

DROP TABLE IF EXISTS Factura.Factura;
GO

DROP TABLE IF EXISTS Actividad.Tarifa;
GO

DROP TABLE IF EXISTS Actividad.InvitacionEvento;
GO

DROP TABLE IF EXISTS Actividad.ActividadExtra;
GO

DROP TABLE IF EXISTS Actividad.Asiste;
GO

DROP TABLE IF EXISTS ActDeportiva.SocioRealizaActividad;
GO

DROP TABLE IF EXISTS ActDeportiva.Clase;
GO

DROP TABLE IF EXISTS ActDeportiva.CostoActividadDeportiva;
GO

DROP TABLE IF EXISTS Actividad.ActividadDeportiva;
GO

DROP TABLE IF EXISTS Socio.CostoCategoria;
GO

DROP TABLE IF EXISTS Socio.GrupoFamiliar;
GO

DROP TABLE IF EXISTS Socio.Socio;
GO

DROP TABLE IF EXISTS Socio.Categoria;
GO

DROP TABLE IF EXISTS Socio.ObraSocial;
GO

DROP TABLE IF EXISTS Usuario.Usuario;
GO

DROP TABLE IF EXISTS Persona.Persona;
GO

DROP TABLE IF EXISTS Usuario.Rol;
GO

DROP TABLE IF EXISTS Actividad.Jornada;
GO

-- *************** CREACI�N DE TABLAS *************** --

CREATE TABLE Usuario.Rol (
    idRol   INT IDENTITY(1,1) PRIMARY KEY,
    nombre  VARCHAR(50) NOT NULL,
    area    VARCHAR(50) NOT NULL,

	UNIQUE(nombre, area),

    CHECK (
        (area = 'Tesorer�a'   AND nombre IN (
            'Jefe de Tesorer�a',
            'Administrativo de Cobranza',
            'Administrativo de Morosidad',
            'Administrativo de Facturacion'
        ))
     OR (area = 'Socios'      AND nombre IN (
            'Administrativo Socio',
            'Socios web'
        ))
     OR (area = 'Autoridades' AND nombre IN (
            'presidente',
            'vicepresidente',
            'secretario',
            'vocales'
        ))
    ),
);
GO

CREATE TABLE Persona.Persona (
    idPersona           INT IDENTITY(1,1) PRIMARY KEY,
    nombre              VARCHAR(50)     NOT NULL,
    apellido            VARCHAR(50)     NOT NULL,
    fechaNac            DATE,    --Deberia ser NOT NULL pero hay una fecha que es 10/19/1981 en el archivo
    dni                 INT,     --Deberia ser UNIQUE pero hay un dni que se repite en el archivo.
    telefono            VARCHAR(20),
    telefonoEmergencia  VARCHAR(20),
    email               VARCHAR(255),
    borrado				BIT NOT NULL DEFAULT 0,

    
    CHECK (dni > 0 AND dni <= 999999999),
    CHECK (TRIM(nombre) <> '' AND TRIM(apellido) <> ''),
    CHECK (fechaNac <= GETDATE()),
    CHECK (
        telefono IS NULL 
        OR (TRIM(telefono) <> '' AND telefono NOT LIKE '%[^0-9]%')
    ),
    CHECK (
        telefonoEmergencia IS NULL 
        OR (TRIM(telefonoEmergencia) <> '' AND telefonoEmergencia NOT LIKE '%[^0-9]%')
    ),
    CHECK (
        email IS NULL 
        OR TRIM(email) LIKE '%_@_%._%'
    )
);
GO


CREATE TABLE Usuario.Usuario (
    idUsuario             INT IDENTITY(1,1) PRIMARY KEY,
    nombre                VARCHAR(30)     NOT NULL,
    contrase�a            VARCHAR(64)     NOT NULL,
    fechaUltimaRenovacion DATE            NOT NULL,
    fechaARenovar         DATE            NOT NULL,
    idPersona             INT             NOT NULL,
	idRol                 INT			  NOT NULL,


    FOREIGN KEY (idPersona) REFERENCES Persona.Persona(idPersona),
	FOREIGN KEY (idRol) REFERENCES Usuario.Rol(idRol),

    CHECK (
        TRIM(nombre) <> ''
        AND nombre LIKE '%[A-Za-z]%'       -- al menos una letra
        AND nombre NOT LIKE '%[^A-Za-z0-9]%'-- solo letras o n�meros
    ),
    CHECK (
        TRIM(contrase�a) <> ''
        AND contrase�a LIKE '%[A-Za-z]%'    -- al menos una letra
        AND contrase�a NOT LIKE '%[^A-Za-z0-9]%' -- solo letras o n�meros
    ),
    CHECK (fechaUltimaRenovacion <= GETDATE()),
    CHECK (fechaARenovar >= fechaUltimaRenovacion),
 
);
GO

CREATE TABLE Socio.ObraSocial (
	idObraSocial	INT IDENTITY(1,1) PRIMARY KEY, 
	nombre			VARCHAR(40) UNIQUE NOT NULL,
	telefono		VARCHAR(40) NOT NULL,

	CHECK (TRIM(nombre) <> '' AND nombre LIKE '%[A-Za-z]%'),
    CHECK (telefono <> '' AND telefono NOT LIKE '%[^0-9/ ()-]%')

);
GO

CREATE TABLE Socio.Categoria (
    idCategoria INT IDENTITY(1,1) PRIMARY KEY,
    nombre      VARCHAR(20) UNIQUE NOT NULL,
    edadMinima  TINYINT    NULL,
    edadMaxima  TINYINT    NULL,

    CHECK (nombre IN ('Menor', 'Cadete', 'Mayor')),
    CHECK (edadMinima IS NULL OR edadMinima >= 0),
    CHECK (edadMaxima IS NULL OR edadMaxima >= 0),
    CHECK (
        edadMaxima IS NULL
        OR edadMinima IS NULL
        OR edadMaxima > edadMinima
    )
);
GO



CREATE TABLE Socio.Socio (
    idSocio         INT           PRIMARY KEY,
    nroSocio        VARCHAR(10)   UNIQUE NOT NULL,
    idCategoria     INT           NOT NULL,
    idObraSocial    INT,
    nroObraSocial   VARCHAR(30),
	cuit			VARCHAR(20)   DEFAULT NULL,
	borrado			BIT NOT NULL DEFAULT 0,

    FOREIGN KEY (idSocio)       REFERENCES Persona.Persona(idPersona),
    FOREIGN KEY (idCategoria)   REFERENCES Socio.Categoria(idCategoria),
    FOREIGN KEY (idObraSocial)  REFERENCES Socio.ObraSocial(idObraSocial),

    CHECK (TRIM(nroSocio) <> '' AND nroSocio NOT LIKE '%[^A-Za-z0-9-]%'),
    CHECK ((idObraSocial IS NULL AND nroObraSocial IS NULL) 
           OR (idObraSocial IS NOT NULL AND TRIM(nroObraSocial)<>'' AND nroObraSocial NOT LIKE '%[^A-Za-z0-9-]%'))
);
GO

CREATE TABLE Socio.GrupoFamiliar (
    idGrupoFamiliar   INT IDENTITY(1,1) PRIMARY KEY,
    idSocioTutor      INT           NOT NULL,
    idSocioMenor      INT           NOT NULL,
    parentesco        VARCHAR(30)   DEFAULT NULL,

    FOREIGN KEY (idSocioTutor) REFERENCES Socio.Socio(idSocio),
    FOREIGN KEY (idSocioMenor) REFERENCES Socio.Socio(idSocio),

    UNIQUE (idSocioTutor, idSocioMenor),

    CHECK (
        parentesco IS NULL
        OR (
            TRIM(parentesco) <> ''
            AND parentesco NOT LIKE '%[^A-Za-z ]%'
        )
    )
);
GO

CREATE TABLE Socio.CostoCategoria (
    idCostoCategoria        INT IDENTITY(1,1) PRIMARY KEY,
    fechaVigencia           DATE            NOT NULL,
    precio                  DECIMAL(10,2)   NOT NULL,
    idCategoria    INT             NOT NULL,

    FOREIGN KEY (idCategoria) REFERENCES Socio.Categoria(idCategoria),

    CHECK (precio > 0)
);
GO


CREATE TABLE Actividad.ActividadDeportiva (
	idActividadDeportiva	INT IDENTITY(1,1) PRIMARY KEY,
	nombre					VARCHAR(30) UNIQUE NOT NULL,
	borrado				BIT NOT NULL DEFAULT 0,

	CHECK (nombre IN ('V�ley', 'Futsal', 'Taekwondo', 'Baile art�stico', 'Nataci�n', 'Ajedrez'))
);
GO


CREATE TABLE Actividad.CostoActividadDeportiva (
    idCostoActividadDeportiva INT IDENTITY(1,1) PRIMARY KEY,
    fechaVigencia             DATE            NOT NULL,
    precio                    DECIMAL(10,2)   NOT NULL,
    idActividadDeportiva      INT             NOT NULL,

    FOREIGN KEY (idActividadDeportiva) REFERENCES Actividad.ActividadDeportiva(idActividadDeportiva),

    CHECK (precio > 0)
);
GO


CREATE TABLE Actividad.Clase (
    idClase                 INT IDENTITY(1,1) PRIMARY KEY,
    fecha                   DATE            NOT NULL,
    profesor                VARCHAR(100)    NOT NULL,
    idActividadDeportiva    INT             NOT NULL,

    FOREIGN KEY (idActividadDeportiva) REFERENCES Actividad.ActividadDeportiva(idActividadDeportiva),
 
    CHECK (TRIM(profesor) <> '' AND profesor NOT LIKE '%[^A-Za-z ]%')
);
GO


CREATE TABLE Actividad.SocioRealizaActividad (
    idRelacion               INT IDENTITY(1,1) PRIMARY KEY,
    idSocio                  INT NOT NULL,
    idActividadDeportiva     INT NOT NULL,

    FOREIGN KEY (idSocio) REFERENCES Socio.Socio(idSocio),
    FOREIGN KEY (idActividadDeportiva) REFERENCES Actividad.ActividadDeportiva(idActividadDeportiva),

	UNIQUE(idSocio, idActividadDeportiva),
);
GO


CREATE TABLE Actividad.Asiste (
    idAsistencia INT IDENTITY(1,1) PRIMARY KEY,
    idSocio      INT           NOT NULL,
    idClase      INT           NOT NULL,
    asistencia   VARCHAR(2)       NOT NULL,

    FOREIGN KEY (idSocio) REFERENCES Socio.Socio(idSocio),
    FOREIGN KEY (idClase) REFERENCES Actividad.Clase(idClase),

    UNIQUE (idClase, idSocio),
    CHECK (asistencia IN ('P', 'PP', 'A', 'J'))
);
GO

--Mas alla de que no se presentan tarifas de Colonia o AlquilerSum, la tabla lo contempla
CREATE TABLE Actividad.Tarifa (
    idTarifa               INT             IDENTITY(1,1) PRIMARY KEY,
    precio                 DECIMAL(10,2)   NOT NULL,
    fechaVigencia          DATE            NOT NULL,

    descripcionActividad   VARCHAR(20)     NOT NULL,
    tipoCliente            VARCHAR(10),
    tipoDuracion           VARCHAR(10),
    tipoEdad               VARCHAR(10),


    CHECK (precio > 0),
    CHECK (descripcionActividad IN ('UsoPileta', 'Colonia', 'AlquilerSum')),
    CHECK (
        (descripcionActividad = 'UsoPileta'
			AND tipoCliente   IS NOT NULL AND tipoCliente   IN ('Socio','Invitado')
			AND tipoDuracion  IS NOT NULL AND tipoDuracion   IN ('D�a','Mes', 'Temporada')
			AND tipoEdad      IS NOT NULL AND tipoEdad   IN ('Adulto','Menor') 
		)	
	OR (descripcionActividad IN ('Colonia','AlquilerSum')
             AND tipoCliente   IS NULL
             AND tipoDuracion  IS NULL
             AND tipoEdad      IS NULL 
		)
    )
);
GO

CREATE TABLE Actividad.Jornada(
	idJornada INT IDENTITY(1,1) PRIMARY KEY,
	fecha DATE NOT NULL UNIQUE,
	huboLluvia BIT NOT NULL
);
GO


CREATE TABLE Actividad.ActividadExtra (
    idActividadExtra		INT             IDENTITY(1,1) PRIMARY KEY,
    descripcionActividad    VARCHAR(20)     NOT NULL,
    fechaInicio				DATE			NOT NULL,
    fechaFin				DATE			NOT NULL,
    idSocio					INT             NOT NULL,
	idTarifa				INT				NOT NULL,
	idJornada				INT				NOT NULL,
    FOREIGN KEY (idSocio) REFERENCES Socio.Socio(idSocio),
	FOREIGN KEY (idTarifa) REFERENCES Actividad.Tarifa(idTarifa),
	FOREIGN KEY (idJornada) REFERENCES Actividad.Jornada(idJornada),
    CHECK (fechaFin >= fechaInicio),
    CHECK (descripcionActividad IN ('UsoPileta', 'Colonia', 'AlquilerSum'))
);
GO


CREATE TABLE Actividad.InvitacionEvento (
    idInvitacion       INT IDENTITY(1,1) PRIMARY KEY,
    fechaInvitacion    DATE      NOT NULL,
    idInvitado         INT       NOT NULL,
    idActExtra         INT       NOT NULL,
	--QUE SOCIO LO INVITO
    FOREIGN KEY (idActExtra)  REFERENCES Actividad.ActividadExtra(idActividadExtra),
    FOREIGN KEY (idInvitado)  REFERENCES Persona.Persona(idPersona),

);
GO



CREATE TABLE Pago.FormaPago (
	idFormaPago		INT IDENTITY(1,1) PRIMARY KEY,
	nombre			VARCHAR(50) UNIQUE NOT NULL,

	CHECK ( nombre IN ( 'efectivo', 'Visa','MasterCard','Tarjeta Naranja','Pago F�cil','Rapipago','Transferencia Mercado Pago')), --Se incluye efectivo, ya que es el medio de pago en el archivo Maestro.
);
GO



CREATE TABLE Factura.Factura (
    idFactura          INT    IDENTITY(1,1) PRIMARY KEY,
    nroFactura         AS RIGHT('00000000' + CONVERT(VARCHAR(8), idFactura), 8) PERSISTED,

    puntoDeVenta       CHAR(4)       NOT NULL DEFAULT '0001',
    tipoFactura        CHAR(1)       NOT NULL DEFAULT 'C',
    fechaEmision       DATE          NOT NULL,
    fechaRecargo       AS DATEADD(DAY, 5, fechaEmision)   PERSISTED,
    fechaVencimiento   AS DATEADD(DAY, 10, fechaEmision)   PERSISTED,
    totalFactura       DECIMAL(10,2) DEFAULT NULL,
    estado             VARCHAR(15)   NOT NULL DEFAULT 'Borrador',

	fechaPago		   DATE			 DEFAULT NULL,

    idPersona          INT           NOT NULL,

    FOREIGN KEY (idPersona) REFERENCES Persona.Persona(idPersona),

    CHECK (tipoFactura IN ('A','B','C','E','M')),

    CHECK (totalFactura > 0),
    CHECK (estado IN ('Borrador','Emitida','Pagada','Vencida','Cancelada'))

);
GO



CREATE TABLE Factura.DetalleFactura (
    idDetalleFactura        INT             IDENTITY(1,1) PRIMARY KEY,
    idFactura               INT             NOT NULL,
    descripcion             VARCHAR(50)     NOT NULL,
    montoBase               DECIMAL(10,2)   NOT NULL,
    porcentajeDescuento     INT             NOT NULL DEFAULT 0,
    motivoDescuento         VARCHAR(100)    NULL DEFAULT NULL,
    porcentajeIVA           DECIMAL(5,2)    NOT NULL DEFAULT 0.00,

	idSocioBeneficiario		INT	NOT NULL,

	FOREIGN KEY (idSocioBeneficiario) REFERENCES Socio.Socio(idSocio), 
    FOREIGN KEY (idFactura) REFERENCES Factura.Factura(idFactura),

    importeIVA              AS (
      ROUND(
        montoBase 
        * (100.0 - porcentajeDescuento) / 100.0
        * porcentajeIVA / 100.0
      , 2)
    ) PERSISTED,

    montoFinal       AS (
      ROUND(
        montoBase 
        * (100.0 - porcentajeDescuento) / 100.0
        * (1.0 + porcentajeIVA / 100.0)
      , 2)
    ) PERSISTED,



    CHECK (descripcion IN (
        'Cuota', 'Taekwondo', 'V�ley', 'Futsal', 
        'Nataci�n', 'Baile art�stico', 'Ajedrez',
		'UsoPileta:D�a', 'UsoPileta:Mes', 
		'UsoPileta:Temporada', 'Colonia', 'AlquilerSUM'
    )),
    CHECK (montoBase > 0),
    CHECK (porcentajeDescuento BETWEEN 0 AND 100),
    CHECK (
        (porcentajeDescuento = 0 AND motivoDescuento IS NULL)
     OR (porcentajeDescuento >  0 AND motivoDescuento IS NOT NULL)
    ),

    CHECK (porcentajeIVA = 0.00 OR porcentajeIVA = 21.00 )
);
GO

--Solo un pago por Factura
CREATE TABLE Pago.Pago (
    idPago           INT           IDENTITY(1,1) PRIMARY KEY,
    idTransaccion    VARCHAR(64)   NOT NULL UNIQUE,
    fecha            DATE          NOT NULL,
    monto            DECIMAL(10,2) NOT NULL CHECK (monto > 0),

    idFormaPago      INT           NOT NULL,
	idFactura		 INT		   NOT NULL UNIQUE,

    FOREIGN KEY (idFormaPago) REFERENCES Pago.FormaPago(idFormaPago),
	FOREIGN KEY (idFactura) REFERENCES Factura.Factura(idFactura),

    CHECK (TRIM(idTransaccion) <> '')
);
GO





CREATE TABLE Factura.NotaCredito (
	idNotaCredito		INT IDENTITY(1,1) PRIMARY KEY,
	fechaEmision		DATE NOT NULL,
	nroNotaCredito		AS RIGHT('00000000' + CONVERT(VARCHAR(8), idNotaCredito), 8) PERSISTED,
	
	monto				DECIMAL(10,2),
	motivo				VARCHAR(120),

	tipoNC				VARCHAR(20),

	idFactura			INT NOT NULL UNIQUE,

	FOREIGN KEY(idFactura)  REFERENCES Factura.Factura(idFactura),

	CHECK (monto > 0),
    CHECK (TRIM(motivo) <> ''),
	CHECK (tipoNC IN ('AnulacionTotal', 'AnulacionParcial', 'Reembolso'))
);
GO


CREATE TABLE Factura.NotaDebito (

	idNotaDebito     INT IDENTITY(1,1) PRIMARY KEY,
	fechaEmision     DATE,
	nroNotaDebito    AS RIGHT('00000000' + CONVERT(VARCHAR(8), idNotaDebito), 8) PERSISTED,
	tipoND			 VARCHAR(20) NOT NULL DEFAULT 'Recargo',

	montoBase        DECIMAL(10,2) NOT NULL,
	porcentajeIVA    DECIMAL(5,2)  NOT NULL DEFAULT 0.00,

	importeIVA       AS ROUND(montoBase * porcentajeIVA/100.0, 2) PERSISTED,
	totalNotaDebito  AS ROUND(montoBase + montoBase * porcentajeIVA/100.0, 2) PERSISTED,


	idFactura	INT UNIQUE NOT NULL,
  
	FOREIGN KEY (idFactura)  REFERENCES Factura.Factura(idFactura),

  	CHECK (montoBase > 0),
	CHECK (tipoND = 'Recargo')
);
GO




CREATE TABLE Pago.SaldoDeCuenta (
	idSaldoDeCuenta	 INT IDENTITY(1,1) PRIMARY KEY,
	monto			 DECIMAL(10, 2) NOT NULL,
	aplicado		 BIT DEFAULT 0,

	idPago			 INT NOT NULL,
	idSocio			 INT NOT NULL,

	FOREIGN KEY (idPago) REFERENCES Pago.Pago(idPago),
	FOREIGN KEY (idSocio) REFERENCES Socio.Socio (idSocio),

	CHECK (monto > 0)
);
GO


