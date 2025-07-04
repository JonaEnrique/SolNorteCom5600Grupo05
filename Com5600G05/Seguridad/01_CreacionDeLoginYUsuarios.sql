USE Com5600G05
GO

-- Creacion de logins en el servidor
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'NicolasPerez' AND type = 'S')
	DROP LOGIN NicolasPerez;

CREATE LOGIN NicolasPerez
WITH PASSWORD = N'12345678';

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'SantiagoSanchez' AND type = 'S')
	DROP LOGIN SantiagoSanchez;

CREATE LOGIN SantiagoSanchez
WITH PASSWORD = N'12345678';

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'TeoTurri' AND type = 'S')
	DROP LOGIN TeoTurri;

CREATE LOGIN TeoTurri
WITH PASSWORD = N'12345678';

-- Creacion de users en la base de datos
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'NicolasPerez' AND type = 'S')
	DROP USER NicolasPerez;
	
CREATE USER NicolasPerez
FOR LOGIN NicolasPerez;

GRANT VIEW DEFINITION
TO NicolasPerez

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'SantiagoSanchez' AND type = 'S')
	DROP USER SantiagoSanchez;
	
CREATE USER SantiagoSanchez
FOR LOGIN SantiagoSanchez;

GRANT VIEW DEFINITION
TO SantiagoSanchez

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'TeoTurri' AND type = 'S')
	DROP USER TeoTurri;
	
CREATE USER TeoTurri
FOR LOGIN TeoTurri;

GRANT VIEW DEFINITION
TO TeoTurri

-- Asignacion de roles
ALTER ROLE JefeDeTesoreria
ADD MEMBER SantiagoSanchez;

ALTER ROLE AdministrativoSocio
ADD MEMBER NicolasPerez;

ALTER ROLE Presidente
ADD MEMBER TeoTurri;

-- Creacion de usuarios para pruebas
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'UsuarioSocioWeb' AND type = 'S')
	DROP USER UsuarioSocioWeb;

CREATE USER UsuarioSocioWeb
WITHOUT LOGIN;

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'UsuarioAdministrativoDeFacturacion' AND type = 'S')
	DROP USER UsuarioAdministrativoDeFacturacion;

CREATE USER UsuarioAdministrativoDeFacturacion
WITHOUT LOGIN;

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'UsuarioSecretario' AND type = 'S')
	DROP USER UsuarioSecretario;

CREATE USER UsuarioSecretario
WITHOUT LOGIN;