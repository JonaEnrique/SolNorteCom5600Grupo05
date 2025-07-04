USE Com5600G05
GO

-- Añadir usuarios a roles
CREATE OR ALTER PROCEDURE Seguridad.AsignarRolAdministrativoDeCobranza
	@Usuario VARCHAR(30)
WITH EXECUTE AS OWNER
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @Usuario AND type = 'S')
	BEGIN
		RAISERROR('No existe el usuario %s', 16, 1, @Usuario);
		RETURN;
	END

	DECLARE @asignacion VARCHAR(100) =
		'ALTER ROLE AdministrativoDeCobranza ' +
		'ADD MEMBER ' + @Usuario + ';'

	EXEC (@asignacion);
END
GO

CREATE OR ALTER PROCEDURE Seguridad.AsignarRolAdministrativoDeMorosidad
	@Usuario VARCHAR(30)
WITH EXECUTE AS OWNER
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @Usuario AND type = 'S')
	BEGIN
		RAISERROR('No existe el usuario %s', 16, 1, @Usuario);
		RETURN;
	END

	DECLARE @asignacion VARCHAR(100) =
		'ALTER ROLE AdministrativoDeMorosidad ' +
		'ADD MEMBER ' + @Usuario + ';'

	EXEC (@asignacion);
END
GO

CREATE OR ALTER PROCEDURE Seguridad.AsignarRolAdministrativoDeFacturacion
	@Usuario VARCHAR(50)
WITH EXECUTE AS OWNER
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @Usuario AND type = 'S')
	BEGIN
		RAISERROR('No existe el usuario %s', 16, 1, @Usuario);
		RETURN;
	END

	DECLARE @asignacion VARCHAR(100) =
		'ALTER ROLE AdministrativoDeFacturacion ' +
		'ADD MEMBER ' + @Usuario + ';'

	EXEC (@asignacion);
END
GO

CREATE OR ALTER PROCEDURE Seguridad.AsignarRolAdministrativoDeFacturacion
	@Usuario VARCHAR(50)
WITH EXECUTE AS OWNER
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @Usuario AND type = 'S')
	BEGIN
		RAISERROR('No existe el usuario %s', 16, 1, @Usuario);
		RETURN;
	END

	DECLARE @asignacion VARCHAR(100) =
		'ALTER ROLE AdministrativoDeFacturacion ' +
		'ADD MEMBER ' + @Usuario + ';'

	EXEC (@asignacion);
END
GO

CREATE OR ALTER PROCEDURE Seguridad.AsignarRolSociosWeb
	@Usuario VARCHAR(30)
WITH EXECUTE AS OWNER
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @Usuario AND type = 'S')
	BEGIN
		RAISERROR('No existe el usuario %s', 16, 1, @Usuario);
		RETURN;
	END

	DECLARE @asignacion VARCHAR(100) =
		'ALTER ROLE SociosWeb ' +
		'ADD MEMBER ' + @Usuario + ';'

	EXEC (@asignacion);
END
GO

CREATE OR ALTER PROCEDURE Seguridad.AsignarRolSecretario
	@Usuario VARCHAR(30)
WITH EXECUTE AS OWNER
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @Usuario AND type = 'S')
	BEGIN
		RAISERROR('No existe el usuario %s', 16, 1, @Usuario);
		RETURN;
	END

	DECLARE @asignacion VARCHAR(100) =
		'ALTER ROLE Secretario ' +
		'ADD MEMBER ' + @Usuario + ';'

	EXEC (@asignacion);
END
GO

CREATE OR ALTER PROCEDURE Seguridad.AsignarRolVocales
	@Usuario VARCHAR(30)
WITH EXECUTE AS OWNER
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @Usuario AND type = 'S')
	BEGIN
		RAISERROR('No existe el usuario %s', 16, 1, @Usuario);
		RETURN;
	END

	DECLARE @asignacion VARCHAR(100) =
		'ALTER ROLE Vocales' +
		'ADD MEMBER ' + @Usuario + ';'

	EXEC (@asignacion);
END
GO

-- Quitar usuarios de roles
CREATE OR ALTER PROCEDURE Seguridad.QuitarRolAdministrativoDeCobranza
	@Usuario VARCHAR(30)
WITH EXECUTE AS OWNER
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @Usuario AND type = 'S')
	BEGIN
		RAISERROR('No existe el usuario %s', 16, 1, @usuario);
		RETURN;
	END

	IF NOT EXISTS (
		SELECT 1
		FROM sys.database_role_members AS rm
		INNER JOIN sys.database_principals AS p1
			ON rm.member_principal_id = p1.principal_id
		INNER JOIN sys.database_principals AS p2
			ON rm.role_principal_id = p2.principal_id
		WHERE p1.name = @usuario AND p2.name = 'AdministrativoDeCobranza'
	)
	BEGIN
		RAISERROR('El usuario %s no tiene el rol AdministrativoDeCobranza', 16, 1, @usuario);
		RETURN;
	END

	DECLARE @desasignacion VARCHAR(100) =
		'ALTER ROLE AdministrativoDeCobranza ' +
		'DROP MEMBER ' + @usuario + ';';

	EXEC (@desasignacion);
END
GO

CREATE OR ALTER PROCEDURE Seguridad.QuitarRolAdministrativoDeMorosidad
	@Usuario VARCHAR(30)
WITH EXECUTE AS OWNER
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @Usuario AND type = 'S')
	BEGIN
		RAISERROR('No existe el usuario %s', 16, 1, @usuario);
		RETURN;
	END

	IF NOT EXISTS (
		SELECT 1
		FROM sys.database_role_members AS rm
		INNER JOIN sys.database_principals AS p1
			ON rm.member_principal_id = p1.principal_id
		INNER JOIN sys.database_principals AS p2
			ON rm.role_principal_id = p2.principal_id
		WHERE p1.name = @usuario AND p2.name = 'AdministrativoDeMorosidad'
	)
	BEGIN
		RAISERROR('El usuario %s no tiene el rol AdministrativoDeMorosidad', 16, 1, @usuario);
		RETURN;
	END

	DECLARE @desasignacion VARCHAR(100) =
		'ALTER ROLE  AdministrativoDeMorosidad' +
		'DROP MEMBER ' + @usuario + ';';

	EXEC (@desasignacion);
END
GO

CREATE OR ALTER PROCEDURE Seguridad.QuitarRolAdministrativoDeFacturacion
	@Usuario VARCHAR(50)
WITH EXECUTE AS OWNER
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @Usuario AND type = 'S')
	BEGIN
		RAISERROR('No existe el usuario %s', 16, 1, @usuario);
		RETURN;
	END

	IF NOT EXISTS (
		SELECT 1
		FROM sys.database_role_members AS rm
		INNER JOIN sys.database_principals AS p1
			ON rm.member_principal_id = p1.principal_id
		INNER JOIN sys.database_principals AS p2
			ON rm.role_principal_id = p2.principal_id
		WHERE p1.name = @usuario AND p2.name = 'AdministrativoDeFacturacion'
	)
	BEGIN
		RAISERROR('El usuario %s no tiene el rol AdministrativoDeFacturacion', 16, 1, @usuario);
		RETURN;
	END

	DECLARE @desasignacion VARCHAR(100) =
		'ALTER ROLE AdministrativoDeFacturacion ' +
		'DROP MEMBER ' + @usuario + ';';

	EXEC (@desasignacion);
END
GO

CREATE OR ALTER PROCEDURE Seguridad.QuitarRolAdministrativoDeSocio
	@Usuario VARCHAR(30)
WITH EXECUTE AS OWNER
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @Usuario AND type = 'S')
	BEGIN
		RAISERROR('No existe el usuario %s', 16, 1, @usuario);
		RETURN;
	END

	IF NOT EXISTS (
		SELECT 1
		FROM sys.database_role_members AS rm
		INNER JOIN sys.database_principals AS p1
			ON rm.member_principal_id = p1.principal_id
		INNER JOIN sys.database_principals AS p2
			ON rm.role_principal_id = p2.principal_id
		WHERE p1.name = @usuario AND p2.name = 'AdministrativoDeSocio'
	)
	BEGIN
		RAISERROR('El usuario %s no tiene el rol AdministrativoDeSocio', 16, 1, @usuario);
		RETURN;
	END

	DECLARE @desasignacion VARCHAR(100) =
		'ALTER ROLE AdministrativoDeSocio ' +
		'DROP MEMBER ' + @usuario + ';';

	EXEC (@desasignacion);
END
GO

CREATE OR ALTER PROCEDURE Seguridad.QuitarRolSociosWeb
	@Usuario VARCHAR(30)
WITH EXECUTE AS OWNER
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @Usuario AND type = 'S')
	BEGIN
		RAISERROR('No existe el usuario %s', 16, 1, @usuario);
		RETURN;
	END

	IF NOT EXISTS (
		SELECT 1
		FROM sys.database_role_members AS rm
		INNER JOIN sys.database_principals AS p1
			ON rm.member_principal_id = p1.principal_id
		INNER JOIN sys.database_principals AS p2
			ON rm.role_principal_id = p2.principal_id
		WHERE p1.name = @usuario AND p2.name = 'SociosWeb'
	)
	BEGIN
		RAISERROR('El usuario %s no tiene el rol SociosWeb', 16, 1, @usuario);
		RETURN;
	END

	DECLARE @desasignacion VARCHAR(100) =
		'ALTER ROLE SociosWeb ' +
		'DROP MEMBER ' + @usuario + ';';

	EXEC (@desasignacion);
END
GO

CREATE OR ALTER PROCEDURE Seguridad.QuitarRolSecretario
	@Usuario VARCHAR(30)
WITH EXECUTE AS OWNER
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @Usuario AND type = 'S')
	BEGIN
		RAISERROR('No existe el usuario %s', 16, 1, @usuario);
		RETURN;
	END

	IF NOT EXISTS (
		SELECT 1
		FROM sys.database_role_members AS rm
		INNER JOIN sys.database_principals AS p1
			ON rm.member_principal_id = p1.principal_id
		INNER JOIN sys.database_principals AS p2
			ON rm.role_principal_id = p2.principal_id
		WHERE p1.name = @usuario AND p2.name = 'Secretario'
	)
	BEGIN
		RAISERROR('El usuario %s no tiene el rol Secretario', 16, 1, @usuario);
		RETURN;
	END

	DECLARE @desasignacion VARCHAR(100) =
		'ALTER ROLE Secretario ' +
		'DROP MEMBER ' + @usuario + ';';

	EXEC (@desasignacion);
END
GO

CREATE OR ALTER PROCEDURE Seguridad.QuitarRolVocales
	@Usuario VARCHAR(30)
WITH EXECUTE AS OWNER
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @Usuario AND type = 'S')
	BEGIN
		RAISERROR('No existe el usuario %s', 16, 1, @usuario);
		RETURN;
	END

	IF NOT EXISTS (
		SELECT 1
		FROM sys.database_role_members AS rm
		INNER JOIN sys.database_principals AS p1
			ON rm.member_principal_id = p1.principal_id
		INNER JOIN sys.database_principals AS p2
			ON rm.role_principal_id = p2.principal_id
		WHERE p1.name = @usuario AND p2.name = 'Vocales'
	)
	BEGIN
		RAISERROR('El usuario %s no tiene el rol Vocales', 16, 1, @usuario);
		RETURN;
	END

	DECLARE @desasignacion VARCHAR(100) =
		'ALTER ROLE Vocales ' +
		'DROP MEMBER ' + @usuario + ';';

	EXEC (@desasignacion);
END
GO