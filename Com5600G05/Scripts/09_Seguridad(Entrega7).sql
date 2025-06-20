USE Com5600G05						
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Rol'
      AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    CREATE TABLE dbo.Rol (
        idRol       INT IDENTITY(1,1) PRIMARY KEY,
        nombreRol   VARCHAR(50) NOT NULL UNIQUE,
        area        VARCHAR(100) NOT NULL
        CONSTRAINT CK_Rol_Area CHECK (area IN ('Tesorería','Socios','Autoridades'))
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM Rol WHERE nombreRol = 'Jefe de Tesorería')
    INSERT INTO Rol (nombreRol, area) VALUES ('Jefe de Tesorería', 'Tesorería');

IF NOT EXISTS (SELECT 1 FROM Rol WHERE nombreRol = 'Administrativo de Cobranza')
    INSERT INTO Rol (nombreRol, area) VALUES ('Administrativo de Cobranza', 'Tesorería');

IF NOT EXISTS (SELECT 1 FROM Rol WHERE nombreRol = 'Administrativo de Morosidad')
    INSERT INTO Rol (nombreRol, area) VALUES ('Administrativo de Morosidad', 'Tesorería');

IF NOT EXISTS (SELECT 1 FROM Rol WHERE nombreRol = 'Administrativo de Facturacion')
    INSERT INTO Rol (nombreRol, area) VALUES ('Administrativo de Facturacion', 'Tesorería');

IF NOT EXISTS (SELECT 1 FROM Rol WHERE nombreRol = 'Administrativo Socio')
    INSERT INTO Rol (nombreRol, area) VALUES ('Administrativo Socio', 'Socios');

IF NOT EXISTS (SELECT 1 FROM Rol WHERE nombreRol = 'Socios web')
    INSERT INTO Rol (nombreRol, area) VALUES ('Socios web', 'Socios');

IF NOT EXISTS (SELECT 1 FROM Rol WHERE nombreRol = 'presidente')
    INSERT INTO Rol (nombreRol, area) VALUES ('presidente', 'Autoridades');

IF NOT EXISTS (SELECT 1 FROM Rol WHERE nombreRol = 'vicepresidente')
    INSERT INTO Rol (nombreRol, area) VALUES ('vicepresidente', 'Autoridades');

IF NOT EXISTS (SELECT 1 FROM Rol WHERE nombreRol = 'secretario')
    INSERT INTO Rol (nombreRol, area) VALUES ('secretario', 'Autoridades');

IF NOT EXISTS (SELECT 1 FROM Rol WHERE nombreRol = 'vocales')
    INSERT INTO Rol (nombreRol, area) VALUES ('vocales', 'Autoridades');
GO


IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Empleado'
      AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    CREATE TABLE dbo.Empleado (
        idPersona INT PRIMARY KEY IDENTITY(1,1),

        legajo              VARBINARY(MAX) NOT NULL,
        nombre              VARBINARY(MAX) NOT NULL,
        apellido            VARBINARY(MAX) NOT NULL,
        fechaNac            VARBINARY(MAX) NOT NULL,
        dni                 VARBINARY(MAX) NOT NULL,
        telefono            VARBINARY(MAX) NOT NULL,
        telefonoEmergencia  VARBINARY(MAX) NOT NULL,
        email               VARBINARY(MAX) NOT NULL,

        idRol INT NOT NULL,
        CONSTRAINT FK_Empleado_Rol FOREIGN KEY (idRol) REFERENCES Rol(idRol)
    );
END;
GO


IF NOT EXISTS (
  SELECT 1 
  FROM sys.symmetric_keys 
  WHERE name = '##MS_DatabaseMasterKey##'
)
BEGIN
  CREATE MASTER KEY
    ENCRYPTION BY PASSWORD = 'boquita123';
END
GO


IF NOT EXISTS (
  SELECT 1
  FROM sys.certificates
  WHERE name = 'CertificadoEmpleado'
)
BEGIN
  CREATE CERTIFICATE CertificadoEmpleado
    WITH SUBJECT = 'Certificado para cifrar datos de Empleado';
END
GO


IF NOT EXISTS (
  SELECT 1
  FROM sys.symmetric_keys
  WHERE name = 'ClaveEmpleado'
)
BEGIN
  CREATE SYMMETRIC KEY ClaveEmpleado
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE CertificadoEmpleado;
END
GO

CREATE OR ALTER PROCEDURE validarEmpleado
  @legajo              VARCHAR(20),			
  @nombre              VARCHAR(50),
  @apellido            VARCHAR(50),
  @fechaNac            DATE,
  @dni                 VARCHAR(15),
  @telefono            VARCHAR(20),
  @telefonoEmergencia  VARCHAR(20),
  @email               VARCHAR(100),
  @idRol               INT
AS
BEGIN
	 SET NOCOUNT ON;


	  IF @legajo IS NULL OR LEN(TRIM(@legajo)) = 0
	  BEGIN
		RAISERROR('El legajo es obligatorio.', 16, 1);
		RETURN;
	  END


	  IF @nombre IS NULL
		 OR LEN(TRIM(@nombre)) = 0
		 OR @nombre COLLATE Modern_Spanish_CI_AS LIKE '%[^A-Za-zÁÉÍÓÚÜÑáéíóúüñ ]%'
	  BEGIN
		RAISERROR('El nombre es obligatorio y sólo debe contener letras y espacios.', 16, 1);
		RETURN;
	  END


	  IF @apellido IS NULL
		 OR LEN(TRIM(@apellido)) = 0
		 OR @apellido COLLATE Modern_Spanish_CI_AS LIKE '%[^A-Za-zÁÉÍÓÚÜÑáéíóúüñ ]%'
	  BEGIN
		RAISERROR('El apellido es obligatorio y sólo debe contener letras y espacios.', 16, 1);
		RETURN;
	  END


	  IF @fechaNac IS NULL
		 OR @fechaNac > CAST(GETDATE() AS DATE)
	  BEGIN
		RAISERROR('La fecha de nacimiento es obligatoria y no puede ser mayor al día de hoy.', 16, 1);
		RETURN;
	  END


	  IF @dni IS NULL
		 OR LEN(TRIM(@dni)) = 0
		 OR @dni LIKE '%[^0-9]%'
		 OR TRY_CONVERT(INT, TRIM(@dni)) NOT BETWEEN 1 AND 99999999
	  BEGIN
		RAISERROR(
		  'El DNI es obligatorio, debe contener sólo dígitos y estar entre 1 y 99.999.999.',
		  16, 1
		);
		RETURN;
	  END


	  IF @email IS NULL
		 OR LEN(TRIM(@email)) = 0
		 OR @email NOT LIKE '%_@_%._%'
	  BEGIN
		RAISERROR('El e-mail es obligatorio y debe tener un formato válido.', 16, 1);
		RETURN;
	  END


	  IF @telefono IS NULL
		 OR LEN(TRIM(@telefono)) = 0
		 OR @telefono LIKE '%[^0-9]%'
		 OR @telefonoEmergencia IS NULL
		 OR LEN(TRIM(@telefonoEmergencia)) = 0
		 OR @telefonoEmergencia LIKE '%[^0-9]%'
	  BEGIN
		RAISERROR('Los teléfonos son obligatorios y deben contener sólo dígitos.', 16, 1);
		RETURN;
	  END


	  IF @idRol IS NULL
		 OR NOT EXISTS (SELECT 1 FROM Rol WHERE idRol = @idRol)
	  BEGIN
		RAISERROR('No existe el id de rol ingresado.', 16, 1);
		RETURN;
	  END
END;
GO


--Falta agregar Esquema Usuario.
CREATE OR ALTER PROCEDURE insertarEmpleado
	@legajo VARCHAR(20),
	@nombre VARCHAR(50),
	@apellido VARCHAR(50),
	@fechaNac DATE,
	@dni VARCHAR(15),
	@telefono VARCHAR(20),
	@telefonoEmergencia VARCHAR(20),
	@email VARCHAR(100),
	@idRol INT
AS
BEGIN
	BEGIN TRY
		EXEC validarEmpleado
		  @legajo             = @legajo,
		  @nombre             = @nombre,
		  @apellido           = @apellido,
		  @fechaNac           = @fechaNac,
		  @dni                = @dni,
		  @telefono           = @telefono,
		  @telefonoEmergencia = @telefonoEmergencia,
		  @email              = @email,
		  @idRol              = @idRol;

		OPEN SYMMETRIC KEY ClaveEmpleado
			DECRYPTION BY CERTIFICATE CertificadoEmpleado;

		-- Insertar los datos encriptados
		INSERT INTO Empleado (legajo, nombre, apellido, fechaNac, dni, telefono, telefonoEmergencia, email, idRol)
		VALUES (
		  EncryptByKey(Key_GUID('ClaveEmpleado'), @legajo),
		  EncryptByKey(Key_GUID('ClaveEmpleado'), @nombre),
		  EncryptByKey(Key_GUID('ClaveEmpleado'), @apellido),
		  EncryptByKey(Key_GUID('ClaveEmpleado'), CONVERT(VARCHAR(10), @fechaNac, 23)),
		  EncryptByKey(Key_GUID('ClaveEmpleado'), @dni),
		  EncryptByKey(Key_GUID('ClaveEmpleado'), @telefono),
		  EncryptByKey(Key_GUID('ClaveEmpleado'), @telefonoEmergencia),
		  EncryptByKey(Key_GUID('ClaveEmpleado'), @email),
		  @idRol
		);

		-- Cerrar la clave
		CLOSE SYMMETRIC KEY ClaveEmpleado;
	END TRY
	BEGIN CATCH

		-- Asegura cerrar la clave si hay error
		IF KEY_ID('ClaveEmpleado') IS NOT NULL
			CLOSE SYMMETRIC KEY ClaveEmpleado;

		DECLARE @errorMensaje VARCHAR(4000) = ERROR_MESSAGE();
		RAISERROR('Error en insertarEmpleado: %s', 16, 1, @errorMensaje);
		RETURN;

	END CATCH
END;
GO


--Falta agregar Esquema Usuario.
CREATE OR ALTER PROCEDURE actualizarEmpleado
	  @idPersona            INT,
	  @legajo               VARCHAR(20),
	  @nombre               VARCHAR(50),
	  @apellido             VARCHAR(50),
	  @fechaNac             DATE,
	  @dni                  VARCHAR(15),
	  @telefono             VARCHAR(20),
	  @telefonoEmergencia   VARCHAR(20),
	  @email                VARCHAR(100),
	  @idRol                INT
AS
BEGIN
	BEGIN TRY
		OPEN SYMMETRIC KEY ClaveEmpleado
		  DECRYPTION BY CERTIFICATE CertificadoEmpleado;

		UPDATE Empleado
		SET
		  legajo              = EncryptByKey(Key_GUID('ClaveEmpleado'), @legajo),
		  nombre              = EncryptByKey(Key_GUID('ClaveEmpleado'), @nombre),
		  apellido            = EncryptByKey(Key_GUID('ClaveEmpleado'), @apellido),
		  fechaNac            = EncryptByKey(Key_GUID('ClaveEmpleado'), CONVERT(VARCHAR(10), @fechaNac, 23)),
		  dni                 = EncryptByKey(Key_GUID('ClaveEmpleado'), @dni),
		  telefono            = EncryptByKey(Key_GUID('ClaveEmpleado'), @telefono),
		  telefonoEmergencia  = EncryptByKey(Key_GUID('ClaveEmpleado'), @telefonoEmergencia),
		  email               = EncryptByKey(Key_GUID('ClaveEmpleado'), @email),
		  idRol               = @idRol
		WHERE idPersona = @idPersona;

		CLOSE SYMMETRIC KEY ClaveEmpleado;
	END TRY
	BEGIN CATCH
		IF KEY_ID('ClaveEmpleado') IS NOT NULL
		  CLOSE SYMMETRIC KEY ClaveEmpleado;

		DECLARE @errorMensaje VARCHAR(4000) = ERROR_MESSAGE();
		RAISERROR('Error en actualizarEmpleado: %s', 16, 1, @errorMensaje);
		RETURN;
	END CATCH
END;
GO

--Falta agregar Esquema Usuario.
CREATE OR ALTER PROCEDURE borrarEmpleado
	@idPersona INT
AS
BEGIN
	BEGIN TRY
		DELETE FROM Empleado WHERE idPersona = @idPersona;
	END TRY
	BEGIN CATCH
		DECLARE @errorMensaje VARCHAR(4000) = ERROR_MESSAGE();
		RAISERROR('Error en borrarEmpleado: %s', 16, 1, @errorMensaje);
		RETURN;
	END CATCH
END
GO

--Falta agregar Esquema Usuario.
CREATE OR ALTER PROCEDURE obtenerEmpleados
AS
BEGIN

	BEGIN TRY

		OPEN SYMMETRIC KEY ClaveEmpleado
		  DECRYPTION BY CERTIFICATE CertificadoEmpleado;

    
		SELECT
		  idPersona,
		  CAST(DecryptByKey(legajo)            AS VARCHAR(20))  AS legajo,
		  CAST(DecryptByKey(nombre)            AS VARCHAR(50))  AS nombre,
		  CAST(DecryptByKey(apellido)          AS VARCHAR(50))  AS apellido,
		  CAST(DecryptByKey(fechaNac)          AS VARCHAR(10))  AS fechaNac,
		  CAST(DecryptByKey(dni)               AS VARCHAR(15))  AS dni,
		  CAST(DecryptByKey(telefono)          AS VARCHAR(20))  AS telefono,
		  CAST(DecryptByKey(telefonoEmergencia)AS VARCHAR(20))  AS telefonoEmergencia,
		  CAST(DecryptByKey(email)             AS VARCHAR(100)) AS email,
		  idRol
		FROM Empleado;
 
		CLOSE SYMMETRIC KEY ClaveEmpleado;
	END TRY
	BEGIN CATCH
		IF KEY_ID('ClaveEmpleado') IS NOT NULL
		  CLOSE SYMMETRIC KEY ClaveEmpleado;

		DECLARE @errorMensaje VARCHAR(4000) = ERROR_MESSAGE();
		RAISERROR('Error en obtenerEmpleados: %s', 16, 1, @errorMensaje);
		RETURN;
	END CATCH
END
GO

