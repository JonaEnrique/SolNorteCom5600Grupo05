/****************************************
*	Fecha: 23/05/2025					*
*	Grupo: 05							*
*	Materia: Bases de Datos Aplicada	*
*	Nicolas Perez 40015709				*
*	Santiago Sanchez 42281463			*
*	Jonathan Enrique 43301711			*
*	Teo Turri 42819058					*
*****************************************/
USE MASTER
GO

IF EXISTS (SELECT name FROM master.sys.databases WHERE name = N'Com5600G05')
BEGIN
	ALTER DATABASE[Com5600G05] set single_user with rollback immediate --CIERRE DE CONEXION 
END
GO

DROP DATABASE IF EXISTS [Com5600G05]  --ELIMINACIÓN DE DB SI EXISTE
CREATE DATABASE Com5600G05            --CREACIÓN DE DB
GO

USE Com5600G05						  --USO DE DB
GO
--***************CREACION DE SCHEMAS***************--

DROP SCHEMA IF EXISTS Socio;
GO
CREATE SCHEMA socio;
GO

DROP SCHEMA IF EXISTS ActExtra;
GO
CREATE SCHEMA ActExtra;
GO

DROP SCHEMA IF EXISTS ActDeportiva;
GO
CREATE SCHEMA ActDeportiva;
GO

DROP SCHEMA IF EXISTS Factura;
GO
CREATE SCHEMA Factura;
GO

DROP SCHEMA IF EXISTS Persona;
GO
CREATE SCHEMA Persona;
GO

DROP SCHEMA IF EXISTS Pileta;
GO
CREATE SCHEMA Pileta;
GO

DROP SCHEMA IF EXISTS Pago;
GO
CREATE SCHEMA Pago;
GO

DROP SCHEMA IF EXISTS Usuario;
GO
CREATE SCHEMA Usuario;
GO
--***************CREACION DE TABLAS***************--

--		//////		TABLAS CON SCHEMA USUARIO		//////		--


DROP TABLE IF EXISTS [Com5600G05].[Usuario].[Area]
GO
CREATE TABLE  [Com5600G05].[Usuario].[Area](
	idArea	INT IDENTITY,
	nombre	NVARCHAR(255),
	CONSTRAINT PK_Area PRIMARY KEY (idArea)
);

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME ='[Com5600G05].[Usuario].[Rol]')
BEGIN
		ALTER TABLE [Com5600G05].[Usuario].[Rol] DROP CONSTRAINT FK_Areas;
		
		DROP TABLE [Com5600G05].[Usuario].[Rol];
END
GO

CREATE TABLE [Com5600G05].[Usuario].[Rol] (
	idRol		INT IDENTITY,
	nombreRol	VARCHAR(50),
	idArea		INT,
	CONSTRAINT PK_Rol PRIMARY KEY (idRol),
	CONSTRAINT FK_Areas FOREIGN KEY (idArea) REFERENCES [Com5600G05].[Usuario].[Area] (idArea)
);

DROP TABLE IF EXISTS [Com5600G05].[Usuario].[Usuario]
GO
CREATE TABLE [Com5600G05].[Usuario].[Usuario] (
	idUsuario				INT,
	nombre					VARCHAR(255),
	contraseña				VARCHAR(255),
	fechaUltimaRenovacion	DATE,
	fechaARenovar			DATE, 
	CONSTRAINT PK_Usuario PRIMARY KEY (idUsuario)
);


IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME ='[Com5600G05].[Usuario].[RolUsuario]')
BEGIN
		ALTER TABLE [Com5600G05].[Usuario].[RolUsuario] DROP CONSTRAINT FK_Rol;
		ALTER TABLE [Com5600G05].[Usuario].[RolUsuario] DROP CONSTRAINT FK_Usuario;

		DROP TABLE [Com5600G05].[Usuario].[RolUsuario];
END
GO
CREATE TABLE [Com5600G05].[Usuario].[RolUsuario] (
	idRol			INT,
	idUsuario		INT,
	CONSTRAINT PK_RolUsuario	PRIMARY KEY (idRol, idUsuario),
	CONSTRAINT FK_Rol			FOREIGN KEY (idRol)		REFERENCES [Com5600G05].[Usuario].[Rol] (idRol),
	CONSTRAINT FK_Usuario		FOREIGN KEY (idUsuario) REFERENCES [Com5600G05].[Usuario].[Usuario] (idUsuario)
);

--		//////		TABLAS CON SCHEMA USUARIO		//////		--


DROP TABLE IF EXISTS [Com5600G05].[Persona].[Persona]
GO
CREATE TABLE  [Com5600G05].[Persona].[Persona] (
	idPersona			INT IDENTITY,
	nombre				VARCHAR(255),
	apellido			VARCHAR(255),
	fechaNac			DATE,
	dni					INT,
	telefono			INT,
	email				VARCHAR(255),
	telefonoEmergencia  INT,
	CONSTRAINT PK_Persona PRIMARY KEY (idPersona)
);


IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME ='[Com5600G05].[Persona].[Profesor]')
BEGIN
		ALTER TABLE [Com5600G05].[Persona].[Profesor] DROP CONSTRAINT FK_Persona;

		DROP TABLE [Com5600G05].[Persona].[Profesor];
END
GO
CREATE TABLE [Com5600G05].[Persona].[Profesor] (
	idProfesor	INT,
	CONSTRAINT PK_Profesor   PRIMARY KEY (idProfesor),
	CONSTRAINT FK_Persona	 FOREIGN KEY (idProfesor) REFERENCES [Com5600G05].[Persona].[Persona](idPersona)
);


IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME ='[Com5600G05].[Persona].[Invitado]')
BEGIN
		ALTER TABLE [Com5600G05].[Persona].[Invitado] DROP CONSTRAINT FK_PersonaNoSocio;

		DROP TABLE [Com5600G05].[Persona].[Invitado];
END
GO
CREATE TABLE [Com5600G05].[Persona].[Invitado] (
	idInvitado	INT,
	CONSTRAINT PK_Invitado PRIMARY KEY (idInvitado),
	CONSTRAINT FK_PersonaNoSocio  FOREIGN KEY (idInvitado) REFERENCES [Com5600G05].[Persona].[Persona] (idPersona)
);
--		//////		TABLAS CON SCHEMA SOCIO		//////		--


DROP TABLE IF EXISTS [Com5600G05].[socio].[EstadoSocio]
GO
CREATE TABLE [Com5600G05].[socio].[EstadoSocio] (
	idEstadoSocio	INT IDENTITY,
	descripcion		VARCHAR(255),
	CONSTRAINT PK_EstadoSocio PRIMARY KEY (idEstadoSocio)
);


DROP TABLE IF EXISTS [Com5600G05].[socio].[ObraSocial]
GO
CREATE TABLE [Com5600G05].[socio].[ObraSocial] (
	idObraSocial	INT IDENTITY,
	nombre			VARCHAR(255),
	CONSTRAINT PK_ObraSocial PRIMARY KEY (idObraSocial)
);

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME ='[Com5600G05].[socio].[TelefonoObraSocial]')
BEGIN
		ALTER TABLE [Com5600G05].[socio].[TelefonoObraSocial] DROP CONSTRAINT FK_ObraSocial;

		DROP TABLE [Com5600G05].[socio].[TelefonoObraSocial];
END
GO
CREATE TABLE [Com5600G05].[socio].[TelefonoObraSocial] (
	idTelefonoObraSocial	INT IDENTITY,
	telefono				CHAR(20),
	idObraSocial			INT,
	CONSTRAINT PK_TelefonoObraSocial PRIMARY KEY (idTelefonoObraSocial),
	CONSTRAINT FK_ObraSocial		 FOREIGN KEY (idObraSocial) REFERENCES  [Com5600G05].[socio].[ObraSocial] (idObraSocial)
);
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME ='[Com5600G05].[socio].[Socio]')
BEGIN
		ALTER TABLE [Com5600G05].[socio].[Socio] DROP CONSTRAINT FK_Socio;
		ALTER TABLE [Com5600G05].[socio].[Socio] DROP CONSTRAINT FK_ObraSocial_Socio;

		DROP TABLE [Com5600G05].[socio].[Socio];
END
GO
CREATE TABLE [Com5600G05].[socio].[Socio] (
	idSocio				INT,
	nroSocio			INT   UNIQUE,
	idEstadoSocio		INT,
	idObraSocio			INT,
	CONSTRAINT PK_Socio			   PRIMARY KEY (idSocio),
	CONSTRAINT FK_Socio			   FOREIGN KEY (nroSocio)	 REFERENCES [Com5600G05].[Persona].[Persona] (idPersona),
	CONSTRAINT FK_ObraSocial_Socio FOREIGN KEY (idObraSocio) REFERENCES  [Com5600G05].[socio].[ObraSocial] (idObraSocial)
);
--vertemasocio
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME ='[Com5600G05].[socio].[GrupoFamiliar]')
BEGIN
		ALTER TABLE [Com5600G05].[socio].[GrupoFamiliar] DROP CONSTRAINT FK_SocioTutor;
		ALTER TABLE [Com5600G05].[socio].[GrupoFamiliar] DROP CONSTRAINT FK_SocioMenor;

		DROP TABLE [Com5600G05].[socio].[GrupoFamiliar];
END
GO
CREATE TABLE [Com5600G05].[socio].[GrupoFamiliar] (
	idSocioTutor INT,
	idSocioMenor INT,
	idParentesco INT,
	CONSTRAINT PK_GrupoFamiliar PRIMARY KEY (idSocioTutor, idSocioMenor),
	CONSTRAINT FK_SocioTutor    FOREIGN KEY (idSocioTutor) REFERENCES [Com5600G05].[socio].[Socio] (idSocio),
	CONSTRAINT FK_SocioMenor    FOREIGN KEY (idSocioMenor) REFERENCES [Com5600G05].[socio].[Socio] (idSocio)
);

DROP TABLE IF EXISTS [Com5600G05].[socio].[Parentesco]
GO
--ok
CREATE TABLE [Com5600G05].[socio].[Parentesco] (
	idParentesco	INT IDENTITY,
	nombre			VARCHAR(255),
	CONSTRAINT PK_Parentesco PRIMARY KEY (idParentesco)
);
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME ='[Com5600G05].[socio].[Tarjeta]')
BEGIN
		ALTER TABLE [Com5600G05].[socio].[Tarjeta] DROP CONSTRAINT fkSocioTarjeta;

		DROP TABLE [Com5600G05].[socio].[Tarjeta];
END
GO
-- le agregue el nro de tarjeta a la tarjeta
CREATE TABLE [Com5600G05].[socio].[Tarjeta] (
	idTarjeta		 	 INT IDENTITY,
	nroTarjeta			 CHAR(16),
	empresa				 VARCHAR(255),
	vencimiento			 DATE,
	titular				 VARCHAR(255),
	ultimosCuatroDigitos CHAR(4),
	token				 VARCHAR(255),
	debitoAutomatico	 BIT,
	idSocio				 INT,
	CONSTRAINT pkTarjeta			 PRIMARY KEY (idTarjeta),
	CONSTRAINT fkSocioTarjeta		 FOREIGN KEY (idSocio) REFERENCES [Com5600G05].[socio].[Socio](idSocio)
);

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME ='[Com5600G05].[socio].[RegistroCuota] ')
BEGIN
		ALTER TABLE [Com5600G05].[socio].[RegistroCuota]  DROP CONSTRAINT FK_SocioCuota;

		DROP TABLE [Com5600G05].[socio].[RegistroCuota] ;
END
GO
-- deje mes y año como esta en el DER pero capas era DATE
CREATE TABLE [Com5600G05].[socio].[RegistroCuota] (
	idRegistroCuota			INT IDENTITY,
	mes						TINYINT,
	año						TINYINT,
	monto					DECIMAL(19, 2),
	fechaVencimiento		DATE,
	estado					VARCHAR(255),
	idSocio					INT,
	CONSTRAINT PK_Reg_Cuota	 PRIMARY KEY (idRegistroCuota),
	CONSTRAINT FK_SocioCuota FOREIGN KEY (idSocio)	REFERENCES [Com5600G05].[socio].[Socio](idSocio),
	CONSTRAINT unMesAño			UNIQUE (mes, año)
);


--		//////*******		TABLAS CON SCHEMA [ActDeportiva]	********//////		--
DROP TABLE IF EXISTS [Com5600G05].[ActDeportiva].[Categoria]
GO
CREATE TABLE [Com5600G05].[ActDeportiva].[Categoria] (
	idCategoria		INT IDENTITY,
	nombre			VARCHAR(20),
	edadMinima		TINYINT,
	edadMaxima		TINYINT,
	CONSTRAINT PK_Categoria PRIMARY KEY (idCategoria)
);

-- saque idSaldoACuenta porque era 1:N
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME ='[Com5600G05].[ActDeportiva].[CostoCategoria]')
BEGIN
		ALTER TABLE [Com5600G05].[ActDeportiva].[CostoCategoria]  DROP CONSTRAINT FK_Categoria;

		DROP TABLE [Com5600G05].[ActDeportiva].[CostoCategoria];
END
GO
CREATE TABLE[Com5600G05].[ActDeportiva].[CostoCategoria] (
	idCostoCategoria	INT IDENTITY,
	fechaVigencia		DATE,
	precio				DECIMAL(19, 2),
	idCategoria			INT,
	CONSTRAINT	PK_CostoCategoria		PRIMARY KEY (idCostoCategoria), 
	CONSTRAINT	FK_Categoria			FOREIGN KEY (idCategoria) REFERENCES [Com5600G05].[ActDeportiva].[Categoria](idCategoria)
);


DROP TABLE IF EXISTS [Com5600G05].[ActDeportiva].[ActividadDeportiva]
GO
CREATE TABLE [Com5600G05].[ActDeportiva].[ActividadDeportiva] (
	idActividadDeportiva	INT IDENTITY,
	nombre					VARCHAR(255),
	CONSTRAINT PK_ActividadDeportiva PRIMARY KEY (idActividadDeportiva)
);
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME =' [Com5600G05].[ActDeportiva].[CostoActividadDeportiva]')
BEGIN
		ALTER TABLE  [Com5600G05].[ActDeportiva].[CostoActividadDeportiva]  DROP CONSTRAINT FK_ActividadDeportiva;

		DROP TABLE [Com5600G05].[ActDeportiva].[CostoActividadDeportiva];
END
CREATE TABLE [Com5600G05].[ActDeportiva].[CostoActividadDeportiva] (
	idCostoActividadDeportiva	INT IDENTITY,
	fechaVigencia				DATE,
	precio						DECIMAL(19, 2),
	idActividadDeportiva		INT,
	CONSTRAINT PK_CostoActividadDeportiva    PRIMARY KEY (idCostoActividadDeportiva),
	CONSTRAINT FK_ActividadDeportiva		 FOREIGN KEY (idActividadDeportiva) REFERENCES [Com5600G05].[ActDeportiva].[ActividadDeportiva] (idActividadDeportiva)
);

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME =' [Com5600G05].[ActDeportiva].[Clase]')
BEGIN
		ALTER TABLE  [Com5600G05].[ActDeportiva].[Clase]  DROP CONSTRAINT FK_Profesor;
		ALTER TABLE  [Com5600G05].[ActDeportiva].[Clase]  DROP CONSTRAINT FK_Categ_Clase;
		ALTER TABLE  [Com5600G05].[ActDeportiva].[Clase]  DROP CONSTRAINT FK_Act_Deport_Clase;

		DROP TABLE [Com5600G05].[ActDeportiva].[Clase];
END
CREATE TABLE [Com5600G05].[ActDeportiva].[Clase] (
	idClase					INT IDENTITY,
	fecha					DATE,
	horaInicio				TIME(0),
	horaFin					TIME(0),
	idProfesor				INT,
	idCategoria				INT,
	idActividadDeportiva	INT,
	CONSTRAINT PK_Clase							PRIMARY KEY (idClase),
	CONSTRAINT FK_Profesor						FOREIGN KEY (idProfesor)			REFERENCES [Com5600G05].[Persona].[Profesor](idProfesor),
	CONSTRAINT FK_Categ_Clase					FOREIGN KEY (idCategoria)			REFERENCES [Com5600G05].[ActDeportiva].[Categoria](idCategoria),
	CONSTRAINT FK_Act_Deport_Clase				FOREIGN KEY (idActividadDeportiva)  REFERENCES [Com5600G05].[ActDeportiva].[ActividadDeportiva](idActividadDeportiva)
);
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME ='[Com5600G05].[ActDeportiva].[SocioRealizaActividad]')
BEGIN
		ALTER TABLE  [Com5600G05].[ActDeportiva].[SocioRealizaActividad]  DROP CONSTRAINT FK_Act_Deport_Socio;
		ALTER TABLE  [Com5600G05].[ActDeportiva].[SocioRealizaActividad]  DROP CONSTRAINT FK_Act_Deportiva;

		DROP TABLE [Com5600G05].[ActDeportiva].[SocioRealizaActividad];
END
CREATE TABLE [Com5600G05].[ActDeportiva].[SocioRealizaActividad] (
	idSocio					INT,
	idActividadDeportiva	INT,
	CONSTRAINT PK_SocioRealiza_Act		PRIMARY KEY (idSocio, idActividadDeportiva),
	CONSTRAINT FK_Act_Deport_Socio		FOREIGN KEY (idSocio)				REFERENCES [Com5600G05].[socio].[Socio](idSocio),
	CONSTRAINT FK_Act_Deportiva     	FOREIGN KEY (idActividadDeportiva)	REFERENCES [Com5600G05].[ActDeportiva].[ActividadDeportiva] (idActividadDeportiva)
);
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME ='[Com5600G05].[ActDeportiva].[RegistroActividadDeportiva]')
BEGIN
		ALTER TABLE  [Com5600G05].[ActDeportiva].[RegistroActividadDeportiva]  DROP CONSTRAINT FK_SocioRealiza_Act;
		
		DROP TABLE [Com5600G05].[ActDeportiva].[RegistroActividadDeportiva];
END
	
-- estado capas tiene que ser otra entidad, porque los estados se repiten
CREATE TABLE [Com5600G05].[ActDeportiva].[RegistroActividadDeportiva] (
	idRegistroActividadDeportiva	INT IDENTITY,
	monto							DECIMAL(19, 2),
	fechaVencimiento				DATE,
	estado							VARCHAR(255),
	idSocio							INT,
	idActividadDeportiva			INT,
	CONSTRAINT PK_RegistroAct_Deportiva		PRIMARY KEY (idRegistroActividadDeportiva),
	CONSTRAINT FK_SocioRealiza_Act			FOREIGN KEY (idSocio, idActividadDeportiva)		REFERENCES [Com5600G05].[ActDeportiva].[SocioRealizaActividad](idSocio, idActividadDeportiva)
);


--		//////*******		TABLAS CON SCHEMA [ActExtra]	********//////		--


DROP TABLE IF EXISTS [Com5600G05].[ActExtra].[CostoSum]
GO
-- temporal hasta que vea como puso Teo el costo del sum
CREATE TABLE [Com5600G05].[ActExtra].[CostoSum] (
	idCostoSum		INT IDENTITY,
	costoPorDia		DECIMAL(19, 2),
	CONSTRAINT PK_CostoSum PRIMARY KEY (idCostoSum)
);

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME ='[Com5600G05].[ActExtra].[RegistroReservaSum]')
BEGIN
		ALTER TABLE  [Com5600G05].[ActExtra].[RegistroReservaSum] DROP CONSTRAINT FK_SocioSUM;
		ALTER TABLE  [Com5600G05].[ActExtra].[RegistroReservaSum] DROP CONSTRAINT FK_CostoSUM;
		
		DROP TABLE [Com5600G05].[ActExtra].[RegistroReservaSum];
END
-- cambie el precio por la referencia a la tabla CostoSum
CREATE TABLE   [Com5600G05].[ActExtra].[RegistroReservaSum] (
	idRegistroReservaSum INT IDENTITY,
	fechaEmision		 DATE,
	fechaDiaReservado	 DATE,
	horaDesde			 TIME(0),
	horaHasta			 TIME(0),
	estado				 VARCHAR(255),
	idSocio				 INT,
	idCostoSum			 INT,
	CONSTRAINT PK_Reg_ReservaSum		 PRIMARY KEY (idRegistroReservaSum),
	CONSTRAINT FK_SocioSUM				 FOREIGN KEY (idSocio)    REFERENCES [Com5600G05].[socio].[Socio](idSocio),
	CONSTRAINT FK_CostoSUM				 FOREIGN KEY (idCostoSum) REFERENCES [Com5600G05].[ActExtra].[CostoSum](idCostoSum)
);
DROP TABLE IF EXISTS [Com5600G05].[ActExtra].[Colonia]
GO
-- que es año verano?
CREATE TABLE [Com5600G05].[ActExtra].[Colonia] (
	idColonia		INT IDENTITY,
	nombre			VARCHAR(255),
	precio			DECIMAL(19, 2),
	fechaInicio		DATE,
	fechaFin		DATE,
	descripcion		VARCHAR(255),
	añoVerano		INT,
	CONSTRAINT PK_Colonia PRIMARY KEY (idColonia)
);
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME ='[Com5600G05].[ActExtra].[RegistroColonia]')
BEGIN
		ALTER TABLE  [Com5600G05].[ActExtra].[RegistroColonia] DROP CONSTRAINT FK_SocioColonia;
		ALTER TABLE  [Com5600G05].[ActExtra].[RegistroColonia] DROP CONSTRAINT FK_Colonia;
		DROP TABLE [Com5600G05].[ActExtra].[RegistroColonia];
END
CREATE TABLE [Com5600G05].[ActExtra].[RegistroColonia] (
	idRegistroColonia		INT IDENTITY,
	fechaEmision			DATE,
	monto					DECIMAL(19, 2),
	fechaVencimiento		DATE,
	estado					VARCHAR(255),
	idSocio					INT,
	idColonia				INT,
	CONSTRAINT PK_Reg_Colonia		PRIMARY KEY (idRegistroColonia),
	CONSTRAINT FK_SocioColonia		FOREIGN KEY (idSocio)   REFERENCES [Com5600G05].[socio].[Socio](idSocio),
	CONSTRAINT FK_Colonia			FOREIGN KEY (idColonia) REFERENCES [Com5600G05].[ActExtra].[Colonia](idColonia)
);


--		//////*******		TABLAS CON SCHEMA [Pileta]	********//////		--



DROP TABLE IF EXISTS [Com5600G05].[Pileta].[Jornada]
GO
CREATE TABLE [Com5600G05].[Pileta].[Jornada] (
	idJornada INT IDENTITY,
	mmLluvia decimal(19, 2),
	fecha DATE,
	CONSTRAINT PK_Jornada PRIMARY KEY (idJornada)
);

DROP TABLE IF EXISTS [Com5600G05].[Pileta].[TipoEdadPileta]
GO
CREATE TABLE [Com5600G05].[Pileta].[TipoEdadPileta] (
	idTipoEdadPileta	INT IDENTITY,
	descripcion			VARCHAR(255),
	CONSTRAINT PK_TipoEdadPileta PRIMARY KEY (idTipoEdadPileta)
);

DROP TABLE IF EXISTS [Com5600G05].[Pileta].[EstadiaPileta]
GO
CREATE TABLE [Com5600G05].[Pileta].[EstadiaPileta] (
	idEstadiaPileta		INT IDENTITY,
	descripcion			VARCHAR(255),
	CONSTRAINT PK_EstadiaPileta PRIMARY KEY (idEstadiaPileta)
);

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME ='[Com5600G05].[Pileta].[CostoPiletaSocio]')
BEGIN
		ALTER TABLE  [Com5600G05].[Pileta].[CostoPiletaSocio]  DROP CONSTRAINT FK_EstadiaPileta;
		ALTER TABLE  [Com5600G05].[Pileta].[CostoPiletaSocio]  DROP CONSTRAINT FK_TipoEdadPileta;
		DROP TABLE [Com5600G05].[Pileta].[CostoPiletaSocio];
END
CREATE TABLE [Com5600G05].[Pileta].[CostoPiletaSocio] (
	idCostoPiletaSocio		INT IDENTITY,
	monto					DECIMAL(19, 2),
	fechaVigencia		    DATE,
	idEstadiaPileta			INT,
	idTipoEdadPileta		INT,
	CONSTRAINT PK_CostoPiletaSocio PRIMARY KEY (idCostoPiletaSocio),
	CONSTRAINT FK_EstadiaPileta	  FOREIGN KEY (idEstadiaPileta)	REFERENCES [Com5600G05].[Pileta].[EstadiaPileta] (idEstadiaPileta),
	CONSTRAINT FK_TipoEdadPileta	  FOREIGN KEY (idTipoEdadPileta)	REFERENCES [Com5600G05].[Pileta].[TipoEdadPileta] (idTipoEdadPileta)
);

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME ='[Com5600G05].[Pileta].[RegistroUsoPileta]')
BEGIN
		ALTER TABLE  [Com5600G05].[Pileta].[RegistroUsoPileta]  DROP CONSTRAINT FK_SocioUsoPileta;
		ALTER TABLE  [Com5600G05].[Pileta].[RegistroUsoPileta]  DROP CONSTRAINT FK_CostoPiletaSocio;
		ALTER TABLE  [Com5600G05].[Pileta].[RegistroUsoPileta]  DROP CONSTRAINT FK_Jornada;

		DROP TABLE [Com5600G05].[Pileta].[RegistroUsoPileta];
END
CREATE TABLE [Com5600G05].[Pileta].[RegistroUsoPileta] (
	idRegistroUsoPileta			INT IDENTITY,
	fechaEmision				DATE,
	monto						DECIMAL(19, 2),
	estado						VARCHAR(255),
	fechaVencimiento			DATE,
	idSocio						INT,
	idCostoPiletaSocio			INT,
	idJornada					INT,
	CONSTRAINT PK_Reg_UsoPileta		PRIMARY KEY (idRegistroUsoPileta),
	CONSTRAINT FK_SocioUsoPileta	FOREIGN KEY (idSocio)				REFERENCES [Com5600G05].[socio].[Socio] (idSocio),
	CONSTRAINT FK_CostoPiletaSocio	FOREIGN KEY (idCostoPiletaSocio)	REFERENCES [Com5600G05].[Pileta].[CostoPiletaSocio] (idCostoPiletaSocio),
	CONSTRAINT FK_Jornada			FOREIGN KEY (idJornada)				REFERENCES [Com5600G05].[Pileta].[Jornada] (idJornada)
);

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME ='[Com5600G05].[Pileta].[RegistroInvitacionPileta]')
BEGIN
		ALTER TABLE  [Com5600G05].[Pileta].[RegistroInvitacionPileta]  DROP CONSTRAINT FK_SocioAnfitrion;
		ALTER TABLE  [Com5600G05].[Pileta].[RegistroInvitacionPileta]  DROP CONSTRAINT FK_JornadaPorPileta;

		DROP TABLE [Com5600G05].[Pileta].[RegistroInvitacionPileta];
END
CREATE TABLE [Com5600G05].[Pileta].[RegistroInvitacionPileta] (
	idRegistroInvitacionPileta			INT IDENTITY,
	fecha								DATE,
	montoTotal							DECIMAL(19, 2),
	idSocio								INT,
	idJornada							INT,
	CONSTRAINT PK_Reg_Invita_Pileta				  PRIMARY KEY (idRegistroInvitacionPileta),
	CONSTRAINT FK_SocioAnfitrion				  FOREIGN KEY (idSocio)   REFERENCES [Com5600G05].[socio].[Socio] (idSocio),
	CONSTRAINT FK_JornadaPorPileta				  FOREIGN KEY (idJornada) REFERENCES [Com5600G05].[Pileta].[Jornada] (idJornada)
);

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME ='[Com5600G05].[Pileta].[InvitaASocio]')
BEGIN
		ALTER TABLE  [Com5600G05].[Pileta].[InvitaASocio]  DROP CONSTRAINT FK_RegistroInvitacionPileta;
		ALTER TABLE  [Com5600G05].[Pileta].[InvitaASocio]  DROP CONSTRAINT FK_SocioAnfitionPileta;
		ALTER TABLE  [Com5600G05].[Pileta].[InvitaASocio]  DROP CONSTRAINT FK_CostoPiletaPorSocio;
		DROP TABLE [Com5600G05].[Pileta].[InvitaASocio];
END
CREATE TABLE [Com5600G05].[Pileta].[InvitaASocio] (
	idRegistroInvitacionPileta		INT,
	idSocio							INT,
	idCostoPiletaSocio				INT,
	CONSTRAINT PK_InvitaASocio				PRIMARY KEY (idRegistroInvitacionPileta, idSocio),
	CONSTRAINT FK_RegistroInvitacionPileta	FOREIGN KEY (idRegistroInvitacionPileta) REFERENCES [Com5600G05].[Pileta].[RegistroInvitacionPileta] (idRegistroInvitacionPileta),
	CONSTRAINT FK_SocioAnfitionPileta		FOREIGN KEY (idSocio)					 REFERENCES [Com5600G05].[socio].[Socio] (idSocio),
	CONSTRAINT FK_CostoPiletaPorSocio		FOREIGN KEY (idCostoPiletaSocio)		 REFERENCES [Com5600G05].[Pileta].[CostoPiletaSocio] (idCostoPiletaSocio)
);


DROP TABLE IF EXISTS [Com5600G05].[Pileta].[CostoPorEdadInvitado]
GO
CREATE TABLE [Com5600G05].[Pileta].[CostoPorEdadInvitado] (
	idCostoPorEdadInvitado  INT IDENTITY,
	monto					DECIMAL(19, 2),
	fechaVigencia			DATE,
	CONSTRAINT PK_CostoPorEdadInvitado PRIMARY KEY (idCostoPorEdadInvitado)
);

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME ='[Com5600G05].[Pileta].[InvitaAInvitado]')
BEGIN
		ALTER TABLE  [Com5600G05].[Pileta].[InvitaAInvitado]  DROP CONSTRAINT FK_Reg_Invitacion;
		ALTER TABLE  [Com5600G05].[Pileta].[InvitaAInvitado]  DROP CONSTRAINT FK_Invitado;
		
		DROP TABLE [Com5600G05].[Pileta].[InvitaAInvitado];
END
CREATE TABLE [Com5600G05].[Pileta].[InvitaAInvitado] (
	idRegistroInvitacionPileta	INT,
	idInvitado					INT,
	idCostoPorEdadInvitado		INT,
	CONSTRAINT PK_InvitaAInvitado		  PRIMARY KEY (idRegistroInvitacionPileta, idInvitado),
	CONSTRAINT FK_Reg_Invitacion		  FOREIGN KEY (idRegistroInvitacionPileta)  REFERENCES [Com5600G05].[Pileta].[RegistroInvitacionPileta] (idRegistroInvitacionPileta),
	CONSTRAINT FK_Invitado				  FOREIGN KEY (idInvitado)					REFERENCES [Com5600G05].[Persona].[Invitado] (idInvitado)
);
--		//////*******		TABLAS CON SCHEMA [Factura]	********//////		--
DROP TABLE IF EXISTS [Com5600G05].[Factura].[EstadoFactura]
GO
CREATE TABLE [Com5600G05].[Factura].[EstadoFactura] (
	idEstadoFactura		INT IDENTITY,
	descripcion			VARCHAR(255),
	CONSTRAINT PK_EstadoFactura PRIMARY KEY (idEstadoFactura)
);
DROP TABLE IF EXISTS [Com5600G05].[Factura].[DetalleFacturaExtra]
GO
-- aca tenia una referencia factura pero supongo que estaba de mas
CREATE TABLE [Com5600G05].[Factura].[DetalleFacturaExtra] (
	idDetalleFacturaExtra		INT IDENTITY,
	descripcion					VARCHAR(255),
	fechaVencimiento			DATE,
	numeroFactura				INT,
	descuento					DECIMAL(19, 2),
	subtotal					DECIMAL(19, 2),
	regargo						DECIMAL(19, 2),
	CONSTRAINT PK_DetalleFacturaExtra PRIMARY KEY (idDetalleFacturaExtra)
);
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME ='[Com5600G05].[Factura].[Factura]')
BEGIN
		ALTER TABLE  [Com5600G05].[Factura].[Factura]  DROP CONSTRAINT FK_SocioFactura;
		ALTER TABLE  [Com5600G05].[Factura].[Factura]  DROP CONSTRAINT FK_InvitadoFactura;
		ALTER TABLE  [Com5600G05].[Factura].[Factura]  DROP CONSTRAINT FK_EstadoFactura;
		ALTER TABLE  [Com5600G05].[Factura].[Factura]  DROP CONSTRAINT FK_Reg_Cuota;
		ALTER TABLE  [Com5600G05].[Factura].[Factura]  DROP CONSTRAINT FK_Reg_Cuota;
		ALTER TABLE  [Com5600G05].[Factura].[Factura]  DROP CONSTRAINT FK_DetalleFacturaExtra;
		DROP TABLE [Com5600G05].[Factura].[Factura];
END
CREATE TABLE [Com5600G05].[Factura].[Factura] (
	idFactura					INT,
	idNumero					INT IDENTITY, 
	descripcion					VARCHAR(255),   
	tipoFactura					char(2), 
	fechaEmision				DATE,
	fechaVencimiento			DATE,
	cuit						INT,
	emailEmisor					VARCHAR(200),
	montoTotal					DECIMAL(19, 2),
	idSocio						INT,
	idInvitado					INT,
	idEstadoFactura				INT,
	idRegistroCuota				INT,
	idDetalleFacturaExtra		INT,
	CONSTRAINT PK_Factura			  PRIMARY KEY (idFactura),
	CONSTRAINT FK_SocioFactura		  FOREIGN KEY (idSocio)				  REFERENCES [Com5600G05].[socio].[Socio] (idSocio),
	CONSTRAINT FK_InvitadoFactura	  FOREIGN KEY (idInvitado)			  REFERENCES [Com5600G05].[Persona].[Invitado] (idInvitado),
	CONSTRAINT FK_EstadoFactura		  FOREIGN KEY (idEstadoFactura)		  REFERENCES [Com5600G05].[Factura].[EstadoFactura] (idEstadoFactura),
	CONSTRAINT FK_Reg_Cuota			  FOREIGN KEY (idRegistroCuota)		  REFERENCES [Com5600G05].[socio].[RegistroCuota] (idRegistroCuota),
	CONSTRAINT FK_DetalleFacturaExtra FOREIGN KEY (idDetalleFacturaExtra) REFERENCES [Com5600G05].[Factura].[DetalleFacturaExtra] (idDetalleFacturaExtra)
);

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME ='[Com5600G05].[ActExtra].[ActividadExtra]')
BEGIN
		ALTER TABLE  [Com5600G05].[ActExtra].[ActividadExtra]  DROP CONSTRAINT FK_Reg_ActividadDeportiva;
		ALTER TABLE  [Com5600G05].[ActExtra].[ActividadExtra]  DROP CONSTRAINT FK_Reg_ReservaSum;
		ALTER TABLE  [Com5600G05].[ActExtra].[ActividadExtra]  DROP CONSTRAINT FK_Reg_Colonia;
		ALTER TABLE  [Com5600G05].[ActExtra].[ActividadExtra]  DROP CONSTRAINT FK_Reg_UsoPileta;
		ALTER TABLE  [Com5600G05].[ActExtra].[ActividadExtra]  DROP CONSTRAINT FK_Reg_InvitacionPileta;
		ALTER TABLE  [Com5600G05].[ActExtra].[ActividadExtra]  DROP CONSTRAINT FK_DetalleFacturaExtra;

		DROP TABLE [Com5600G05].[ActExtra].[ActividadExtra];
END
CREATE TABLE  [Com5600G05].[ActExtra].[ActividadExtra](
	idActividadExtra						INT IDENTITY,
	idRegistroActividadDeportiva			INT,
	idRegistroReservaSum					INT,
	idRegistroColonia						INT,
	idRegistroUsoPileta						INT,
	idRegistroInvitacionPileta				INT,
	idDetalleFacturaExtra					INT,
	CONSTRAINT PK_ActividadExtra					PRIMARY KEY (idActividadExtra), 
	CONSTRAINT FK_Reg_ActividadDeportiva			FOREIGN KEY (idRegistroActividadDeportiva)	REFERENCES [Com5600G05].[ActDeportiva].[RegistroActividadDeportiva] (idRegistroActividadDeportiva),
	CONSTRAINT FK_Reg_ReservaSum					FOREIGN KEY (idRegistroReservaSum)			REFERENCES [Com5600G05].[ActExtra].[RegistroReservaSum] (idRegistroReservaSum),
	CONSTRAINT FK_Reg_Colonia						FOREIGN KEY (idRegistroColonia)				REFERENCES [Com5600G05].[ActExtra].[RegistroColonia] (idRegistroColonia),
	CONSTRAINT FK_Reg_UsoPileta						FOREIGN KEY (idRegistroUsoPileta)			REFERENCES [Com5600G05].[Pileta].[RegistroUsoPileta] (idRegistroUsoPileta),
	CONSTRAINT FK_Reg_InvitacionPileta				FOREIGN KEY (idRegistroInvitacionPileta)	REFERENCES [Com5600G05].[Pileta].[RegistroInvitacionPileta] (idRegistroInvitacionPileta),
	CONSTRAINT FK_DetalleFacturaExtra				FOREIGN KEY (idDetalleFacturaExtra)			REFERENCES [Com5600G05].[Factura].[DetalleFacturaExtra] (idDetalleFacturaExtra)
);

--		//////*******		TABLAS CON SCHEMA [Pago]	********//////		--
DROP TABLE IF EXISTS [Com5600G05].[Pago].[FormaPago]
GO
CREATE TABLE FormaPago (
	idFormaPago		INT IDENTITY,
	nombre			VARCHAR(255),
	CONSTRAINT PK_FormaPago PRIMARY KEY (idFormaPago)
);
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME ='[Com5600G05].[Pago].[Pago]')
BEGIN
		ALTER TABLE  [Com5600G05].[Pago].[Pago]  DROP CONSTRAINT FK_FormaPago;
		ALTER TABLE  [Com5600G05].[Pago].[Pago]  DROP CONSTRAINT FK_Factura;
		DROP TABLE [Com5600G05].[Pago].[Pago];
END
CREATE TABLE [Com5600G05].[Pago].[Pago] (
	idPago				INT IDENTITY,
	idTransaccion		VARCHAR(255),
	fecha				DATE,
	monto				DECIMAL(19, 2),
	estado				VARCHAR(255),
	idFormaPago			INT,
	idFactura			INT,
	CONSTRAINT PK_Pago		PRIMARY KEY (idPago),
	CONSTRAINT FK_FormaPago	FOREIGN KEY (idFormaPago) REFERENCES FormaPago (idFormaPago),
	CONSTRAINT FK_Factura	FOREIGN KEY (idFactura)	  REFERENCES [Com5600G05].[Factura].[Factura] (idFactura)
);
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME ='[Com5600G05].[Pago].[Reembolso]')
BEGIN
		ALTER TABLE  [Com5600G05].[Pago].[Reembolso]  DROP CONSTRAINT FK_Pago;
		
		DROP TABLE [Com5600G05].[Pago].[Reembolso];
END

CREATE TABLE [Com5600G05].[Pago].[Reembolso] (
	idReembolso		INT IDENTITY,
	fecha			DATE,
	monto			DECIMAL(19, 2),
	motivo			VARCHAR(255),
	idPago			INT,
	CONSTRAINT PK_Reembolso PRIMARY KEY (idReembolso),
	CONSTRAINT FK_Pago	   FOREIGN KEY (idPago) REFERENCES [Com5600G05].[Pago].[Pago] (idPago)
);
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME ='[Com5600G05].[Pago].[SaldoAFavor]')
BEGIN
		ALTER TABLE  [Com5600G05].[Pago].[SaldoAFavor]  DROP CONSTRAINT FK_PagoSaldo;
		ALTER TABLE  [Com5600G05].[Pago].[SaldoAFavor]  DROP CONSTRAINT FK_Socio_Cuenta;
		DROP TABLE [Com5600G05].[Pago].[SaldoAFavor];
END
CREATE TABLE [Com5600G05].[Pago].[SaldoAFavor] (
	idSaldoAFavor	 INT IDENTITY,
	monto			 DECIMAL(19, 2),
	aplicado		 BIT,
	fechaGeneracion  DATE,
	motivo			 VARCHAR(255),
	idPago			 INT,
	idSocio			 INT,
	CONSTRAINT PK_SaldoAFavor PRIMARY KEY (idSaldoAFavor),
	CONSTRAINT FK_PagoSaldo FOREIGN KEY (idPago) REFERENCES [Com5600G05].[Pago].[Pago] (idPago),
	CONSTRAINT FK_Socio_Cuenta FOREIGN KEY (idSocio) REFERENCES [Com5600G05].[socio].[Socio] (idSocio)
);