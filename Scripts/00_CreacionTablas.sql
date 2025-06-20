/*
    ---------------------------------------------------------------------
    -Fecha: 23/05/2025
    -Grupo: 05
    -Materia: Bases de Datos Aplicada

    - Integrantes:
        - Nicolás Pérez       | 40015709
        - Santiago Sánchez    | 42281463
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

-- *************** CREACIÓN DE SCHEMAS *************** --

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

DROP TABLE IF EXISTS Actividad.TipoActividadExtra;
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

-- *************** CREACIÓN DE TABLAS *************** --
CREATE TABLE Usuario.Rol (
    idRol   INT IDENTITY PRIMARY KEY,
    nombre  VARCHAR(50) NOT NULL,
    area    VARCHAR(50) NOT NULL,

	UNIQUE(nombre, area),

    CHECK (
        (area = 'Tesorería'   AND nombre IN (
            'Jefe de Tesorería',
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
    idPersona           INT IDENTITY PRIMARY KEY,
    nombre              VARCHAR(50)     NOT NULL,
    apellido            VARCHAR(50)     NOT NULL,
    fechaNac            DATE,    --Deberia ser NOT NULL pero hay una fecha que es 10/19/1981 en el archivo
    dni                 INT,     --Deberia ser UNIQUE pero hay un dni que se repite en el archivo.
    telefono            VARCHAR(20),
    telefonoEmergencia  VARCHAR(20),
    email               VARCHAR(255),
    idRol               INT             DEFAULT NULL,

    FOREIGN KEY (idRol) REFERENCES Usuario.Rol(idRol),

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
    idUsuario             INT IDENTITY PRIMARY KEY,
    nombre                VARCHAR(30)     NOT NULL,
    contraseña            VARCHAR(64)     NOT NULL,
    fechaUltimaRenovacion DATE            NOT NULL,
    fechaARenovar         DATE            NOT NULL,
    idPersona             INT             NOT NULL,

    FOREIGN KEY (idPersona) REFERENCES Persona.Persona(idPersona),

    CHECK (
        TRIM(nombre) <> ''
        AND nombre LIKE '%[A-Za-z]%'       -- al menos una letra
        AND nombre NOT LIKE '%[^A-Za-z0-9]%'-- solo letras o números
    ),
    CHECK (
        TRIM(contraseña) <> ''
        AND contraseña LIKE '%[A-Za-z]%'    -- al menos una letra
        AND contraseña NOT LIKE '%[^A-Za-z0-9]%' -- solo letras o números
    ),
    CHECK (fechaUltimaRenovacion <= GETDATE()),
    CHECK (fechaARenovar >= fechaUltimaRenovacion),
 
);
GO

CREATE TABLE Socio.ObraSocial (
	idObraSocial	INT IDENTITY PRIMARY KEY, 
	nombre			VARCHAR(40) UNIQUE NOT NULL,
	telefono		VARCHAR(40) UNIQUE NOT NULL,

	CHECK (TRIM(nombre) <> '' AND nombre LIKE '%[A-Za-z]%'),
    CHECK (telefono <> '' AND telefono NOT LIKE '%[^0-9/ ]%')

);
GO

CREATE TABLE Socio.Categoria (
    idCategoria INT IDENTITY PRIMARY KEY,
    nombre      VARCHAR(20) UNIQUE NOT NULL,
    edadMinima  TINYINT    NULL,
    edadMaxima  TINYINT    NULL,

    CHECK (TRIM(nombre) <> '' AND nombre NOT LIKE '%[^A-Za-z]%'),
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
    nroSocio        VARCHAR(10)   NOT NULL,
    idCategoria     INT           NOT NULL,
    idObraSocial    INT,
    nroObraSocial   VARCHAR(30),
	cuit			VARCHAR(20)   DEFAULT NULL,

    FOREIGN KEY (idSocio)       REFERENCES Persona.Persona(idPersona),
    FOREIGN KEY (idCategoria)   REFERENCES Socio.Categoria(idCategoria),
    FOREIGN KEY (idObraSocial)  REFERENCES Socio.ObraSocial(idObraSocial),

    CHECK (TRIM(nroSocio) <> '' AND nroSocio NOT LIKE '%[^A-Za-z0-9]%'),
    CHECK ((idObraSocial IS NULL AND nroObraSocial IS NULL) 
           OR (idObraSocial IS NOT NULL AND TRIM(nroObraSocial)<>'' AND nroObraSocial NOT LIKE '%[^A-Za-z0-9]%'))
);
GO

CREATE TABLE Socio.GrupoFamiliar (
    idGrupoFamiliar   INT IDENTITY PRIMARY KEY,
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
    idCostoCategoria        INT IDENTITY PRIMARY KEY,
    fechaVigencia           DATE            NOT NULL,
    precio                  DECIMAL(10,2)   NOT NULL,
    idCategoria    INT             NOT NULL,

    FOREIGN KEY (idCategoria) REFERENCES Socio.Categoria(idCategoria),

    CHECK (precio > 0)
);
GO


CREATE TABLE Actividad.ActividadDeportiva (
	idActividadDeportiva	INT IDENTITY PRIMARY KEY,
	nombre					VARCHAR(30) UNIQUE NOT NULL,

	CHECK (TRIM(nombre) <> '' AND nombre NOT LIKE '%[^A-Za-z ]%')
);
GO



CREATE TABLE Actividad.CostoActividadDeportiva (
    idCostoActividadDeportiva INT IDENTITY PRIMARY KEY,
    fechaVigencia             DATE            NOT NULL,
    precio                    DECIMAL(10,2)   NOT NULL,
    idActividadDeportiva      INT             NOT NULL,

    FOREIGN KEY (idActividadDeportiva) REFERENCES Actividad.ActividadDeportiva(idActividadDeportiva),

    CHECK (precio > 0)
);
GO


CREATE TABLE Actividad.Clase (
    idClase                 INT IDENTITY PRIMARY KEY,
    fecha                   DATE            NOT NULL,
    profesor                VARCHAR(100)    NOT NULL,
    idActividadDeportiva    INT             NOT NULL,

    FOREIGN KEY (idActividadDeportiva) REFERENCES Actividad.ActividadDeportiva(idActividadDeportiva),
 
    CHECK (TRIM(profesor) <> '' AND profesor NOT LIKE '%[^A-Za-z ]%')
);
GO


CREATE TABLE Actividad.SocioRealizaActividad (
    idRelacion               INT IDENTITY PRIMARY KEY,
    idSocio                  INT NOT NULL,
    idActividadDeportiva     INT NOT NULL,

    FOREIGN KEY (idSocio) REFERENCES Socio.Socio(idSocio),
    FOREIGN KEY (idActividadDeportiva) REFERENCES Actividad.ActividadDeportiva(idActividadDeportiva),

	UNIQUE(idSocio, idActividadDeportiva),
);
GO


CREATE TABLE Actividad.Asiste (
    idAsistencia INT IDENTITY PRIMARY KEY,
    idSocio      INT           NOT NULL,
    idClase      INT           NOT NULL,
    asistencia   CHAR(2)       NOT NULL,

    FOREIGN KEY (idSocio) REFERENCES Socio.Socio(idSocio),
    FOREIGN KEY (idClase) REFERENCES Actividad.Clase(idClase),

    UNIQUE (idClase, idSocio),

    CHECK (TRIM(asistencia) <> '' AND asistencia NOT LIKE '%[^A-Za-z]%')
);
GO

CREATE TABLE Actividad.TipoActividadExtra (
    idTipoAct   INT IDENTITY PRIMARY KEY,
    descripcion VARCHAR(20)	 NOT NULL,

    CHECK (descripcion IN ('UsoPileta', 'Colonia', 'AlquilerSum'))
);
GO

CREATE TABLE Actividad.ActividadExtra (
    idActExtra    INT       IDENTITY PRIMARY KEY,
    fechaInicio   DATE      NOT NULL,
    fechaFin      DATE      NOT NULL,
    idSocio       INT       NOT NULL,
    idTipoAct     INT       NOT NULL, 

    FOREIGN KEY (idSocio) REFERENCES Socio.Socio(idSocio),

    FOREIGN KEY (idTipoAct) REFERENCES Actividad.TipoActividadExtra(idTipoAct),

    CHECK (fechaFin >= fechaInicio)       
);
GO

CREATE TABLE Actividad.InvitacionEvento (
    idInvitacion       INT IDENTITY PRIMARY KEY,
    fechaInvitacion    DATE      NOT NULL,
    idInvitado         INT       NOT NULL,
    idActExtra         INT       NOT NULL,

    FOREIGN KEY (idActExtra)  REFERENCES Actividad.ActividadExtra(idActExtra),
    FOREIGN KEY (idInvitado)  REFERENCES Persona.Persona(idPersona),

);
GO


CREATE TABLE Actividad.Tarifa (
    idTarifa       INT             IDENTITY PRIMARY KEY,
    importe        DECIMAL(10,2)   NOT NULL,
    fechaVigencia  DATE            NOT NULL,
    idTipoAct      INT             NOT NULL,
    tipoCliente    VARCHAR(10)     NOT NULL,
    tipoDuracion   VARCHAR(10)     NOT NULL,
    tipoEdad       VARCHAR(10)     NOT NULL,

    FOREIGN KEY (idTipoAct) REFERENCES Actividad.TipoActividadExtra(idTipoAct),

    CHECK (importe >= 0),
    CHECK (TRIM(tipoCliente)   IN ('Socio','Invitado')),
    CHECK (TRIM(tipoDuracion)  IN ('Día','Mes','Temporada')),
    CHECK (TRIM(tipoEdad)      IN ('Adulto','Menor'))
);
GO

CREATE TABLE Pago.FormaPago (
	idFormaPago		INT IDENTITY PRIMARY KEY,
	nombre			VARCHAR(50) NOT NULL,

	CHECK ( nombre IN ( 'Visa','MasterCard','Tarjeta Naranja','Pago Facil','Rapipago','Transferencia Mercado Pago')),
);
GO

CREATE TABLE Pago.Pago (
    idPago           INT           IDENTITY PRIMARY KEY,
    idTransaccion    VARCHAR(64)   NOT NULL UNIQUE,
    fecha            DATE          NOT NULL,
    monto            DECIMAL(10,2) NOT NULL CHECK (monto > 0),

    idFormaPago      INT           NOT NULL,
 
    FOREIGN KEY (idFormaPago) REFERENCES Pago.FormaPago(idFormaPago),
 
    CHECK (TRIM(idTransaccion) <> '')
);
GO

CREATE TABLE Factura.Factura (
    idFactura          INT    IDENTITY(1,1) PRIMARY KEY,
    nroFactura         AS RIGHT('00000000' + CONVERT(VARCHAR(8), idFactura), 8) PERSISTED,
    puntoDeVenta       CHAR(4)      NOT NULL DEFAULT '0001',
    tipoFactura        CHAR(1)      NOT NULL,
    tipoItem           VARCHAR(30)  NOT NULL,
    fechaEmision       DATE         NOT NULL,
    fechaRecargo       AS DATEADD(DAY, 5, fechaEmision)   PERSISTED,
    fechaVencimiento   AS DATEADD(DAY,10, fechaEmision)   PERSISTED,
    subtotal           DECIMAL(10,2) NOT NULL,
    porcentajeIva      DECIMAL(4,2)  NOT NULL DEFAULT 0,
    totalFactura       AS (
                            subtotal
                            + CASE 
                                WHEN tipoFactura = 'A' 
                                  THEN ROUND(subtotal * porcentajeIva, 2)
                                ELSE 0
                              END
                        ) PERSISTED,
    estado             VARCHAR(15)  NOT NULL DEFAULT 'Pendiente',
    idSocio            INT          NOT NULL,
    idPago             INT          NULL,

    FOREIGN KEY (idSocio) REFERENCES Socio.Socio(idSocio),
    FOREIGN KEY (idPago)  REFERENCES Pago.Pago(idPago),

    CHECK (tipoFactura IN ('A','B','C','E','M')),
    CHECK (tipoItem IN (
        'UsoPileta','Cuota','AlquilerSum','Colonia',
        'Vóley','Futsal','Baile artístico','Natación','Ajederez'
    )),
    CHECK (subtotal >= 0),
    CHECK (porcentajeIva BETWEEN 0 AND 1),
    CHECK (
        (tipoFactura = 'A' AND porcentajeIva > 0 AND porcentajeIva <= 1)
     OR (tipoFactura IN ('B','C','M','E') AND porcentajeIva = 0)
    ),
    CHECK (totalFactura > 0),
    CHECK (estado IN ('Pendiente','Pagada','Pagada Vencida','Cancelada'))
);
GO


CREATE TABLE Factura.NotaCredito (
	idNotaCredito		INT IDENTITY PRIMARY KEY,
	fechaEmision		DATE NOT NULL,
	nroNotaCredito		AS RIGHT('00000000' + CONVERT(VARCHAR(8), idNotaCredito), 8) PERSISTED,
	monto				decimal(10,2),
	motivo				VARCHAR(120),
	idFactura			INT,
	
	FOREIGN KEY(idFactura)  REFERENCES Factura.Factura(idFactura),

	CHECK (monto > 0),
    CHECK (TRIM(motivo) <> '')
);
GO




CREATE TABLE Pago.Reembolso (
	idReembolso		INT IDENTITY PRIMARY KEY,
	fecha			DATE NOT NULL,
	monto			DECIMAL(10, 2) NOT NULL,
	motivo			VARCHAR(255) NOT NULL,

	idPago			INT,

	FOREIGN KEY (idPago) REFERENCES Pago.Pago(idPago),

	CHECK (TRIM(motivo) <> ''),
	CHECK (monto > 0)
);
GO


CREATE TABLE Pago.SaldoDeCuenta (
	idSaldoDeCuenta	 INT IDENTITY PRIMARY KEY,
	monto			 DECIMAL(10, 2) NOT NULL,
	aplicado		 BIT,

	idPago			 INT NOT NULL,
	idSocio			 INT NOT NULL,

	FOREIGN KEY (idPago) REFERENCES Pago.Pago(idPago),
	FOREIGN KEY (idSocio) REFERENCES Socio.Socio (idSocio),

	CHECK (monto > 0)
);
GO


CREATE TABLE Actividad.Jornada(
	idJornada INT IDENTITY PRIMARY KEY,
	fecha DATE NOT NULL UNIQUE,
	huboLluvia BIT NOT NULL
);
GO

