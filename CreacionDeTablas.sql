/*
	Fecha: 23/05/2025
	Grupo: 05
	Materia: Bases de Datos Aplicada
	Nicolas Perez 40015709
	Santiago Sanchez 42281463
	Jonathan Enrique 43301711
	Teo Turri 42819058
*/

CREATE TABLE Area (
	idArea INT IDENTITY,
	nombre NVARCHAR(255),
	CONSTRAINT pkArea
		PRIMARY KEY (idArea)
);

CREATE TABLE Rol (
	idRol INT IDENTITY,
	nombreRol VARCHAR(50),
	idArea INT,
	CONSTRAINT pkRol
		PRIMARY KEY (idRol),
	CONSTRAINT fkRol
		FOREIGN KEY (idArea)
		REFERENCES Area (idArea)
);

CREATE TABLE Persona (
	idPersona INT IDENTITY,
	nombre VARCHAR(255),
	apellido VARCHAR(255),
	fechaNac DATE,
	dni INT,
	telefono INT,
	email VARCHAR(255),
	telefonoEmergencia INT,
	CONSTRAINT pkPersona
		PRIMARY KEY (idPersona)
);

CREATE TABLE Usuario (
	idUsuario INT,
	nombre VARCHAR(255),
	contraseña VARCHAR(255),
	fechaUltimaRenovacion DATE,
	fechaARenovar DATE,
	CONSTRAINT pkUsuario
		PRIMARY KEY (idUsuario)
);

CREATE TABLE RolUsuario (
	idRol INT,
	idUsuario INT,
	CONSTRAINT pkRolUsuario
		PRIMARY KEY (idRol, idUsuario),
	CONSTRAINT fkRol
		FOREIGN KEY (idRol)
		REFERENCES Rol (idRol),
	CONSTRAINT fkUsuario
		FOREIGN KEY (idUsuario)
		REFERENCES Usuario (idUsuario)
);

CREATE TABLE EstadoSocio (
	idEstadoSocio INT IDENTITY,
	descripcion VARCHAR(255),
	CONSTRAINT pkEstadoSocio
		PRIMARY KEY (idEstadoSocio)
);

CREATE TABLE ObraSocial (
	idObraSocial INT IDENTITY,
	nombre VARCHAR(255),
	CONSTRAINT pkObraSocial
		PRIMARY KEY (idObraSocial)
);

CREATE TABLE TelefonoObraSocial (
	idTelefonoObraSocial INT IDENTITY,
	telefono CHAR(20),
	idObraSocial INT,
	CONSTRAINT pkTelefonoObraSocial
		PRIMARY KEY (idTelefonoObraSocial),
	CONSTRAINT fkObraSocial
		FOREIGN KEY (idObraSocial)
		REFERENCES ObraSocial (idObraSocial)
);

CREATE TABLE Categoria (
	idCategoria INT IDENTITY,
	nombre VARCHAR(20),
	edadMinima TINYINT,
	edadMaxima TINYINT,
	CONSTRAINT pkCategoria
		PRIMARY KEY (idCategoria)
);

-- saque idSaldoACuenta porque era 1:N
CREATE TABLE Socio (
	idSocio INT,
	nroSocio INT UNIQUE,
	idEstadoSocio INT,
	idObraSocial INT,
	CONSTRAINT pkSocio
		PRIMARY KEY (idSocio),
	CONSTRAINT fkSocio
		FOREIGN KEY (idSocio)
		REFERENCES Persona (idPersona),
	CONSTRAINT fkObraSocial
		FOREIGN KEY (idObraSocial)
		REFERENCES ObraSocial (idObraSocial)
);

CREATE TABLE Parentesco (
	idParentesco INT IDENTITY,
	nombre VARCHAR(255),
	CONSTRAINT pkParentesco
		PRIMARY KEY (idParentesco)
);

CREATE TABLE GrupoFamiliar (
	idSocioTutor INT,
	idSocioMenor INT,
	idParentesco INT,
	CONSTRAINT pkGrupoFamiliar
		PRIMARY KEY (idSocioTutor, idSocioMenor),
	CONSTRAINT fkSocioTutor
		FOREIGN KEY (idSocioTutor)
		REFERENCES Socio (idSocio),
	CONSTRAINT fkSocioMenor
		FOREIGN KEY (idSocioMenor)
		REFERENCES Socio (idSocio)
);

-- le agregue el nro de tarjeta a la tarjeta
CREATE TABLE Tarjeta (
	idTarjeta INT IDENTITY,
	nroTarjeta CHAR(16),
	empresa VARCHAR(255),
	vencimiento DATE,
	titular VARCHAR(255),
	ultimosCuatroDigitos CHAR(4),
	token VARCHAR(255),
	debitoAutomatico BIT,
	idSocio INT,
	CONSTRAINT pkTarjeta
		PRIMARY KEY (idTarjeta),
	CONSTRAINT fkSocio
		FOREIGN KEY (idSocio)
		REFERENCES Socio(idSocio)
);

CREATE TABLE CostoCategoria (
	idCostoCategoria INT IDENTITY,
	fechaVigencia DATE,
	precio DECIMAL(19, 2),
	idCategoria INT,
	CONSTRAINT pkCostoCategoria
		PRIMARY KEY (idCostoCategoria),
	CONSTRAINT fkCategoria
		FOREIGN KEY (idCategoria)
		REFERENCES Categoria(idCategoria)
);

CREATE TABLE Profesor (
	idProfesor INT,
	CONSTRAINT pkProfesor
		PRIMARY KEY (idProfesor),
	CONSTRAINT fkPersona
		FOREIGN KEY (idProfesor)
		REFERENCES Persona(idPersona)
);

CREATE TABLE ActividadDeportiva (
	idActividadDeportiva INT IDENTITY,
	nombre VARCHAR(255),
	CONSTRAINT pkActividadDeportiva
		PRIMARY KEY (idActividadDeportiva)
);

CREATE TABLE CostoActividadDeportiva (
	idCostoActividadDeportiva INT IDENTITY,
	fechaVigencia DATE,
	precio DECIMAL(19, 2),
	idActividadDeportiva INT,
	CONSTRAINT pkCostoActividadDeportiva
		PRIMARY KEY (idCostoActividadDeportiva),
	CONSTRAINT fkActividadDeportiva
		FOREIGN KEY (idActividadDeportiva)
		REFERENCES ActividadDeportiva (idActividadDeportiva)
);

CREATE TABLE Clase (
	idClase INT IDENTITY,
	fecha DATE,
	horaInicio TIME(0),
	horaFin TIME(0),
	idProfesor INT,
	idCategoria INT,
	idActividadDeportiva INT,
	CONSTRAINT pkClase
		PRIMARY KEY (idClase),
	CONSTRAINT fkProfesor
		FOREIGN KEY (idProfesor)
		REFERENCES Profesor(idProfesor),
	CONSTRAINT fkCategoria
		FOREIGN KEY (idCategoria)
		REFERENCES Categoria(idCategoria),
	CONSTRAINT fkActividadDeportiva
		FOREIGN KEY (idActividadDeportiva)
		REFERENCES ActividadDeportiva(idActividadDeportiva)
);

CREATE TABLE SocioRealizaActividad (
	idSocio INT,
	idActividadDeportiva INT,
	CONSTRAINT pkSocioRealizaActividad
		PRIMARY KEY (idSocio, idActividadDeportiva),
	CONSTRAINT fkSocio
		FOREIGN KEY (idSocio)
		REFERENCES Socio(idSocio),
	CONSTRAINT fkActividadDeportiva
		FOREIGN KEY (idActividadDeportiva)
		REFERENCES ActividadDeportiva (idActividadDeportiva)
);

-- estado capas tiene que ser otra entidad, porque los estados se repiten
CREATE TABLE RegistroActividadDeportiva (
	idRegistroActividadDeportiva INT IDENTITY,
	monto DECIMAL(19, 2),
	fechaVencimiento DATE,
	estado VARCHAR(255),
	idSocio INT,
	idActividadDeportiva INT,
	CONSTRAINT pkRegistroActividadDeportiva
		PRIMARY KEY (idRegistroActividadDeportiva),
	CONSTRAINT fkSocioRealizaActividad
		FOREIGN KEY (idSocio, idActividadDeportiva)
		REFERENCES SocioRealizaActividad(idSocio, idActividadDeportiva)
);

-- deje mes y año como esta en el DER pero capas era DATE
CREATE TABLE RegistroCuota (
	idRegistroCuota INT IDENTITY,
	mes TINYINT,
	año TINYINT,
	monto DECIMAL(19, 2),
	fechaVencimiento DATE,
	estado VARCHAR(255),
	idSocio INT,
	CONSTRAINT pkRegistroCuota
		PRIMARY KEY (idRegistroCuota),
	CONSTRAINT fkSocio
		FOREIGN KEY (idSocio)
		REFERENCES Socio(idSocio),
	CONSTRAINT unMesAño
		UNIQUE (mes, año)
);

-- temporal hasta que vea como puso Teo el costo del sum
CREATE TABLE CostoSum (
	idCostoSum INT IDENTITY,
	costoPorDia DECIMAL(19, 2),
	CONSTRAINT pkCostoSum
		PRIMARY KEY (idCostoSum)
);

-- cambie el precio por la referencia a la tabla CostoSum
CREATE TABLE RegistroReservaSum (
	idRegistroReservaSum INT IDENTITY,
	fechaEmision DATE,
	fechaDiaReservado DATE,
	horaDesde TIME(0),
	horaHasta TIME(0),
	estado VARCHAR(255),
	idSocio INT,
	idCostoSum INT,
	CONSTRAINT pkResgistroReservaSum
		PRIMARY KEY (idRegistroReservaSum),
	CONSTRAINT fkSocio
		FOREIGN KEY (idSocio)
		REFERENCES Socio(idSocio),
	CONSTRAINT fkCostoSum
		FOREIGN KEY (idCostoSum)
		REFERENCES CostoSum(idCostoSum)
);

-- que es año verano?
CREATE TABLE Colonia (
	idColonia INT IDENTITY,
	nombre VARCHAR(255),
	precio DECIMAL(19, 2),
	fechaInicio DATE,
	fechaFin DATE,
	descripcion VARCHAR(255),
	añoVerano INT,
	CONSTRAINT pkColonia
		PRIMARY KEY (idColonia)
);

CREATE TABLE RegistroColonia (
	idRegistroColonia INT IDENTITY,
	fechaEmision DATE,
	monto DECIMAL(19, 2),
	fechaVencimiento DATE,
	estado VARCHAR(255),
	idSocio INT,
	idColonia INT,
	CONSTRAINT pkRegistroColonia
		PRIMARY KEY (idRegistroColonia),
	CONSTRAINT fkSocio
		FOREIGN KEY (idSocio)
		REFERENCES Socio(idSocio),
	CONSTRAINT fkColonia
		FOREIGN KEY (idColonia)
		REFERENCES Colonia(idColonia)
);

CREATE TABLE Jornada (
	idJornada INT IDENTITY,
	mmLluvia decimal(19, 2),
	fecha DATE,
	CONSTRAINT pkJornada
		PRIMARY KEY (idJornada)
);

CREATE TABLE TipoEdadPileta (
	idTipoEdadPileta INT IDENTITY,
	descripcion VARCHAR(255),
	CONSTRAINT pkTipoEdadPileta
		PRIMARY KEY (idTipoEdadPileta)
);

CREATE TABLE EstadiaPileta (
	idEstadiaPileta INT IDENTITY,
	descripcion VARCHAR(255),
	CONSTRAINT pKEstadiaPileta
		PRIMARY KEY (idEstadiaPileta)
);

CREATE TABLE CostoPiletaSocio (
	idCostoPiletaSocio INT IDENTITY,
	monto DECIMAL(19, 2),
	fechaVigencia DATE,
	idEstadiaPileta INT,
	idTipoEdadPileta INT,
	CONSTRAINT pkCostoPiletaSocio
		PRIMARY KEY (idCostoPiletaSocio),
	CONSTRAINT fkEstadiaPileta
		FOREIGN KEY (idEstadiaPileta)
		REFERENCES EstadiaPileta (idEstadiaPileta),
	CONSTRAINT fkTipoEdadPileta
		FOREIGN KEY (idTipoEdadPileta)
		REFERENCES TipoEdadPileta (idTipoEdadPileta)
);

CREATE TABLE RegistroUsoPileta (
	idRegistroUsoPileta INT IDENTITY,
	fechaEmision DATE,
	monto DECIMAL(19, 2),
	estado VARCHAR(255),
	fechaVencimiento DATE,
	idSocio INT,
	idCostoPiletaSocio INT,
	idJornada INT,
	CONSTRAINT pkRegistroUsoPileta
		PRIMARY KEY (idRegistroUsoPileta),
	CONSTRAINT fkSocio
		FOREIGN KEY (idSocio)
		REFERENCES Socio (idSocio),
	CONSTRAINT fkCostoPiletaSocio
		FOREIGN KEY (idCostoPiletaSocio)
		REFERENCES CostoPiletaSocio (idCostoPiletaSocio),
	CONSTRAINT fkJornada
		FOREIGN KEY (idJornada)
		REFERENCES Jornada (idJornada)
);

CREATE TABLE RegistroInvitacionPileta (
	idRegistroInvitacionPileta INT IDENTITY,
	fecha DATE,
	montoTotal DECIMAL(19, 2),
	idSocio INT,
	idJornada INT,
	CONSTRAINT pkRegistroInvitacionPileta
		PRIMARY KEY (idRegistroInvitacionPileta),
	CONSTRAINT fkSocio
		FOREIGN KEY (idSocio)
		REFERENCES Socio (idSocio),
	CONSTRAINT fkJornada
		FOREIGN KEY (idJornada)
		REFERENCES Jornada (idJornada)
);

CREATE TABLE InvitaASocio (
	idRegistroInvitacionPileta INT,
	idSocio INT,
	idCostoPiletaSocio INT,
	CONSTRAINT pkInvitaASocio
		PRIMARY KEY (idRegistroInvitacionPileta, idSocio),
	CONSTRAINT fkRegistroInvitacionPileta
		FOREIGN KEY (idRegistroInvitacionPileta)
		REFERENCES RegistroInvitacionPileta (idRegistroInvitacionPileta),
	CONSTRAINT fkSocio
		FOREIGN KEY (idSocio)
		REFERENCES Socio (idSocio),
	CONSTRAINT fkCostoPiletaSocio
		FOREIGN KEY (idCostoPiletaSocio)
		REFERENCES CostoPiletaSocio (idCostoPiletaSocio)
);

CREATE TABLE Invitado (
	idInvitado INT,
	CONSTRAINT pkInvitado
		PRIMARY KEY (idInvitado),
	CONSTRAINT fkPersona
		FOREIGN KEY (idInvitado)
		REFERENCES Persona (idPersona)
);

CREATE TABLE CostoPorEdadInvitado (
	idCostoPorEdadInvitado INT IDENTITY,
	monto DECIMAL(19, 2),
	fechaVigencia DATE,
	CONSTRAINT pkCostoPorEdadInvitado
		PRIMARY KEY (idCostoPorEdadInvitado)
);

CREATE TABLE InvitaAInvitado (
	idRegistroInvitacionPileta INT,
	idInvitado INT,
	idCostoPorEdadInvitado INT,
	CONSTRAINT pkInvitaAInvitado
		PRIMARY KEY (idRegistroInvitacionPileta, idInvitado),
	CONSTRAINT fkRegistroInvitacionPileta
		FOREIGN KEY (idRegistroInvitacionPileta)
		REFERENCES RegistroInvitacionPileta (idRegistroInvitacionPileta),
	CONSTRAINT fkInvitado
		FOREIGN KEY (idInvitado)
		REFERENCES Invitado (idInvitado)
);

CREATE TABLE EstadoFactura (
	idEstadoFactura INT IDENTITY,
	descripcion VARCHAR(255),
	CONSTRAINT pkEstadoFactura
		PRIMARY KEY (idEstadoFactura)
);

-- aca tenia una referencia factura pero supongo que estaba de mas
CREATE TABLE DetalleFacturaExtra (
	idDetalleFacturaExtra INT IDENTITY,
	descripcion VARCHAR(255),
	fechaVencimiento DATE,
	numeroFactura INT,
	descuento DECIMAL(19, 2),
	subtotal DECIMAL(19, 2),
	regargo DECIMAL(19, 2),
	CONSTRAINT pkDetalleFacturaExtra
		PRIMARY KEY (idDetalleFacturaExtra)
);

CREATE TABLE Factura (
	idFacturaExtra INT IDENTITY,
	descripcion VARCHAR(255),
	idFactura INT,
	tipoFactura BIT,
	fecha DATE,
	montoTotal DECIMAL(19, 2),
	fechaVencimiento DATE,
	idSocio INT,
	idInvitado INT,
	idEstadoFactura INT,
	idRegistroCuota INT,
	idDetalleFacturaExtra INT,
	CONSTRAINT pkFactura
		PRIMARY KEY (idFactura),
	CONSTRAINT fkSocio
		FOREIGN KEY (idSocio)
		REFERENCES Socio (idSocio),
	CONSTRAINT fkInvitado
		FOREIGN KEY (idInvitado)
		REFERENCES Invitado (idInvitado),
	CONSTRAINT fkEstadoFactura
		FOREIGN KEY (idEstadoFactura)
		REFERENCES EstadoFactura (idEstadoFactura),
	CONSTRAINT fkRegistroCuota
		FOREIGN KEY (idRegistroCuota)
		REFERENCES RegistroCuota (idRegistroCuota),
	CONSTRAINT fkDetalleFacturaExtra
		FOREIGN KEY (idDetalleFacturaExtra)
		REFERENCES DetalleFacturaExtra (idDetalleFacturaExtra)
);

CREATE TABLE ActividadExtra (
	idActividadExtra INT IDENTITY,
	idRegistroActividadDeportiva INT,
	idRegistroReservaSum INT,
	idRegistroColonia INT,
	idRegistroUsoPileta INT,
	idRegistroInvitacionPileta INT,
	idDetalleFacturaExtra INT,
	CONSTRAINT pkActividadExtra
		PRIMARY KEY (idActividadExtra),
	CONSTRAINT fkRegistroActividadDeportiva
		FOREIGN KEY (idRegistroActividadDeportiva)
		REFERENCES RegistroActividadDeportiva (idRegistroActividadDeportiva),
	CONSTRAINT fkRegistroReservaSum
		FOREIGN KEY (idRegistroReservaSum)
		REFERENCES RegistroReservaSum (idRegistroReservaSum),
	CONSTRAINT fkRegistroColonia
		FOREIGN KEY (idRegistroColonia)
		REFERENCES RegistroColonia (idRegistroColonia),
	CONSTRAINT fkRegistroUsoPileta
		FOREIGN KEY (idRegistroUsoPileta)
		REFERENCES RegistroUsoPileta (idRegistroUsoPileta),
	CONSTRAINT fkRegistroInvitacionPileta
		FOREIGN KEY (idRegistroInvitacionPileta)
		REFERENCES RegistroInvitacionPileta (idRegistroInvitacionPileta),
	CONSTRAINT fkDetalleFacturaExtra
		FOREIGN KEY (idDetalleFacturaExtra)
		REFERENCES DetalleFacturaExtra (idDetalleFacturaExtra)
);

CREATE TABLE FormaPago (
	idFormaPago INT IDENTITY,
	nombre VARCHAR(255),
	CONSTRAINT pkFormaPago
		PRIMARY KEY (idFormaPago)
);

CREATE TABLE Pago (
	idPago INT IDENTITY,
	idTransaccion VARCHAR(255),
	fecha DATE,
	monto DECIMAL(19, 2),
	estado VARCHAR(255),
	idFormaPago INT,
	idFactura INT,
	CONSTRAINT pkPago
		PRIMARY KEY (idPago),
	CONSTRAINT fkFormaPago
		FOREIGN KEY (idFormaPago)
		REFERENCES FormaPago (idFormaPago),
	CONSTRAINT fkFactura
		FOREIGN KEY (idFactura)
		REFERENCES Factura (idFactura)
);

CREATE TABLE Reembolso (
	idReembolso INT IDENTITY,
	fecha DATE,
	monto DECIMAL(19, 2),
	motivo VARCHAR(255),
	idPago INT,
	CONSTRAINT pkReembolso
		PRIMARY KEY (idReembolso),
	CONSTRAINT fkPago
		FOREIGN KEY (idPago)
		REFERENCES Pago (idPago)
);

CREATE TABLE SaldoAFavor (
	idSaldoAFavor INT IDENTITY,
	monto DECIMAL(19, 2),
	aplicado BIT,
	motivo VARCHAR(255),
	idPago INT,
	idSocio INT,
	CONSTRAINT pkSaldoAFavor
		PRIMARY KEY (idSaldoAFavor),
	CONSTRAINT fkPago
		FOREIGN KEY (idPago)
		REFERENCES Pago (idPago),
	CONSTRAINT fkSocio
		FOREIGN KEY (idSocio)
		REFERENCES Socio (idSocio)
);