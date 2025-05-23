/*
    ---------------------------------------------------------------------
    - Fecha: 23/05/2025
    - Grupo: 05
    - Materia: Bases de Datos Aplicada

    - Integrantes:
        - Nicolás Pérez       | 40015709
        - Santiago Sánchez    | 42281463
        - Jonathan Enrique    | 43301711
        - Teo Turri           | 42819058

    - Consigna: 
        Crear SP para manejar la insercion de datos en cada tabla
    ---------------------------------------------------------------------
*/

USE Com5600G05
GO

---------------------------------------------------------------------
-- AREA --

CREATE OR ALTER PROCEDURE Usuario.insertarArea
    @nombre VARCHAR(30)
AS
BEGIN
    IF LTRIM(RTRIM(@nombre)) = '' 
    BEGIN
        RAISERROR('El nombre no puede estar vacío.', 16, 1);
        RETURN;
    END

	IF EXISTS (SELECT 1 FROM Usuario.Area WHERE nombre = @nombre)
	BEGIN
		RAISERROR('El area "%s" ya existe.', 16, 1, @nombre);
		RETURN;
	END

    INSERT INTO Usuario.Area(nombre)
    VALUES (@nombre);

END;
GO
---------------------------------------------------------------------
-- ROL --


CREATE OR ALTER PROCEDURE Usuario.insertarRol
    @nombre VARCHAR(50),
    @idArea INT
AS
BEGIN

    IF LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        RAISERROR('El nombre del rol no puede estar vacío.', 16, 1);
        RETURN;
    END

	IF EXISTS (SELECT 1 FROM Usuario.Rol WHERE nombre = @nombre)
    BEGIN
        RAISERROR('El rol "%s" ya existe.', 16, 1, @nombre);
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1 
        FROM Usuario.Area 
        WHERE idArea = @idArea
    )
    BEGIN
        RAISERROR('El área con ID "%d" no existe.', 16, 1, @idArea);
        RETURN;
    END

    -- Insertar el nuevo rol
    INSERT INTO Usuario.Rol (nombre, idArea)
    VALUES (@nombre, @idArea);

END;
GO

---------------------------------------------------------------------
-- USUARIO --

CREATE OR ALTER PROCEDURE Usuario.insertarUsuario
    @nombre VARCHAR(30),
    @contraseña VARCHAR(64),
    @fechaUltimaRenovacion DATE,
    @fechaARenovar DATE
AS
BEGIN
 
    IF LTRIM(RTRIM(@nombre)) = '' OR LTRIM(RTRIM(@contraseña)) = ''
    BEGIN
        RAISERROR('El nombre o la contraseña no pueden estar vacios.', 16, 1);
        RETURN;
    END

	IF EXISTS (SELECT 1 FROM Usuario.Usuario WHERE nombre = @nombre)
    BEGIN
        RAISERROR('Ya existe un usuario con el nombre "%s".', 16, 1, @nombre);
        RETURN;
    END

    IF @fechaARenovar <= @fechaUltimaRenovacion
    BEGIN
        RAISERROR('La fecha a renovar debe ser posterior a la fecha de ultima renovacion.', 16, 1);
        RETURN;
    END

	INSERT INTO Usuario.Usuario (nombre, contraseña, fechaUltimaRenovacion, fechaARenovar)
    VALUES (@nombre, @contraseña, @fechaUltimaRenovacion, @fechaARenovar);
END;
GO

---------------------------------------------------------------------
-- RolUsuario (TABLA INTERMEDIA ENTRE ROL Y USUARIO) --


CREATE OR ALTER PROCEDURE Usuario.insertarRolUsuario
    @idRol INT,
    @idUsuario INT
AS
BEGIN

    IF NOT EXISTS (SELECT 1 FROM Usuario.Rol WHERE idRol = @idRol)
    BEGIN
        RAISERROR('El rol con ID %d no existe.', 16, 1, @idRol);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Usuario.Usuario WHERE idUsuario = @idUsuario)
    BEGIN
        RAISERROR('El usuario con ID %d no existe.', 16, 1, @idUsuario);
        RETURN;
    END

    IF EXISTS (
        SELECT 1 
        FROM Usuario.RolUsuario 
        WHERE idRol = @idRol AND idUsuario = @idUsuario
    )
    BEGIN
        RAISERROR('La relacion entre el rol %d y el usuario %d ya existe.', 16, 1, @idRol, @idUsuario);
        RETURN;
    END

    INSERT INTO Usuario.RolUsuario (idRol, idUsuario)
    VALUES (@idRol, @idUsuario);
END;
GO

---------------------------------------------------------------------
-- PERSONA --

CREATE OR ALTER PROCEDURE Persona.insertarPersona
    @nombre VARCHAR(30),
    @apellido VARCHAR(30),
    @fechaNac DATE,
    @dni INT,
    @telefono VARCHAR(20),
    @telefonoEmergencia VARCHAR(20),
    @email VARCHAR(255)
AS
BEGIN
 
    IF LTRIM(RTRIM(@nombre)) = '' OR LTRIM(RTRIM(@apellido)) = ''
    BEGIN
        RAISERROR('El nombre y el apellido no pueden estar vacios.', 16, 1);
        RETURN;
    END

    IF @fechaNac > GETDATE()
    BEGIN
        RAISERROR('La fecha de nacimiento no puede ser futura.', 16, 1);
        RETURN;
    END

    IF @dni < 0 OR @dni > 99999999
    BEGIN
        RAISERROR('El DNI debe estar entre 0 y 99999999.', 16, 1);
        RETURN;
    END

    IF @telefono LIKE '%[^0-9]%' OR @telefonoEmergencia LIKE '%[^0-9]%'
    BEGIN
        RAISERROR('Los telefonos deben contener solo digitos.', 16, 1);
        RETURN;
    END

    INSERT INTO Persona.Persona (nombre, apellido, fechaNac, dni, telefono, telefonoEmergencia, email)
    VALUES (@nombre, @apellido, @fechaNac, @dni, @telefono, @telefonoEmergencia, @email);

END;
GO

---------------------------------------------------------------------
-- PROFESOR --

CREATE OR ALTER PROCEDURE Persona.insertarProfesor
    @idProfesor INT
AS
BEGIN

    IF NOT EXISTS (
        SELECT 1 
        FROM Persona.Persona 
        WHERE idPersona = @idProfesor
    )
    BEGIN
        RAISERROR('No existe una persona con ID %d.', 16, 1, @idProfesor);
        RETURN;
    END

    IF EXISTS (
        SELECT 1 
        FROM Persona.Profesor 
        WHERE idProfesor = @idProfesor
    )
    BEGIN
        RAISERROR('La persona con ID %d ya esta registrada como profesor.', 16, 1, @idProfesor);
        RETURN;
    END

    INSERT INTO Com5600G05.Persona.Profesor (idProfesor)
    VALUES (@idProfesor);
END;
GO

---------------------------------------------------------------------
-- INVITADO --

CREATE OR ALTER PROCEDURE Persona.insertarInvitado
    @idInvitado INT
AS
BEGIN

    IF NOT EXISTS (
        SELECT 1 
        FROM Persona.Persona 
        WHERE idPersona = @idInvitado
    )
    BEGIN
        RAISERROR('No existe una persona con ID %d.', 16, 1, @idInvitado);
        RETURN;
    END

    IF EXISTS (
        SELECT 1 
        FROM Persona.Invitado 
        WHERE idInvitado = @idInvitado
    )
    BEGIN
        RAISERROR('La persona con ID %d ya esta registrada como invitado.', 16, 1, @idInvitado);
        RETURN;
    END

    INSERT INTO Persona.Invitado (idInvitado)
    VALUES (@idInvitado);
END;
GO

---------------------------------------------------------------------
-- FormaPago --

CREATE OR ALTER PROCEDURE Pago.insertarFormaPago
    @nombre VARCHAR(50)
AS
BEGIN

    IF LTRIM(RTRIM(@nombre)) = ''
    BEGIN
        RAISERROR('El nombre de la forma de pago no puede estar vacio.', 16, 1);
        RETURN;
    END

    IF @nombre NOT IN (
        'Visa',
        'MasterCard',
        'Tarjeta Naranja',
        'Pago Facil',
        'Rapipago',
        'Transferencia Mercado Pago'
    )
    BEGIN
        RAISERROR('"%s" no es una forma de pago valida.', 16, 1, @nombre);
        RETURN;
    END

    IF EXISTS (
        SELECT 1 
        FROM Pago.FormaPago 
        WHERE nombre = @nombre
    )
    BEGIN
        RAISERROR('La forma de pago "%s" ya esta registrada.', 16, 1, @nombre);
        RETURN;
    END

    INSERT INTO Pago.FormaPago (nombre)
    VALUES (@nombre);

END;

---------------------------------------------------------------------
-- ActividadDeportiva --

CREATE OR ALTER PROCEDURE ActDeportiva.insertarActividadDeportiva
	@actividadDeportivaNueva VARCHAR(100)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM ActDeportiva.ActividadDeportiva WHERE nombre = @actividadDeportivaNueva)
	BEGIN
		RAISERROR('La actividad deportiva %s ya existe.', 10, 1, @actividadDeportivaNueva);
	END
	ELSE
	BEGIN
		INSERT INTO ActDeportiva.ActividadDeportiva
		VALUES (@actividadDeportivaNueva);
	END
END;
GO

---------------------------------------------------------------------
-- PARENTESCO --

CREATE OR ALTER PROCEDURE Socio.insertarParentesco 
	@parentescoNuevo VARCHAR(255)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Socio.Parentesco WHERE nombre = @parentescoNuevo)
	BEGIN
		RAISERROR('Ya esta registrado el parentesco %s.', 10, 1, @parentescoNuevo);
	END
	ELSE
	BEGIN
		INSERT INTO Socio.Parentesco
		VALUES (@parentescoNuevo);
	END
END;
GO

---------------------------------------------------------------------
-- COLONIA --

CREATE OR ALTER PROCEDURE ActExtra.insertarColonia
	@nombre VARCHAR(255),
	@precio DECIMAL(19, 2),
	@fechaInicio DATE,
	@fechaFin DATE,
	@descripcion VARCHAR(255),
	@añoVerano INT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM ActExtra.Colonia WHERE nombre = @nombre)
	BEGIN
		RAISERROR('Ya existe una colonia con el nombre %s.', 10, 1, @nombre);
	END
	ELSE
	BEGIN
		INSERT INTO ActExtra.Colonia
		VALUES (
			@nombre,
			@precio,
			@fechaInicio,
			@fechaFin,
			@descripcion,
			@añoVerano
		);
	END
END
GO

---------------------------------------------------------------------
-- CATEGORIA --

CREATE OR ALTER PROCEDURE ActDeportiva.insertarCategoria 
	@categoriaNueva VARCHAR(100),
	@edadMinima TINYINT,
	@edadMaxima TINYINT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM ActDeportiva.Categoria WHERE nombre = @categoriaNueva)
	BEGIN
		RAISERROR('La categoria %s ya existe.', 10, 1, @categoriaNueva);
	END
	ELSE
	BEGIN
		INSERT INTO ActDeportiva.Categoria
		VALUES (@categoriaNueva, @edadMinima, @edadMaxima);
	END
END
GO