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
        Crear juegos de prueba para verificar el correcto funcionamiento de los SP de inserciones.

    - Instrucciones:
        - Las pruebas deben ejecutarse en orden.
        - Las tablas deben estar vacías antes de comenzar.
		- Cada conjunto de pruebas se ejecuta por esquema completo.
    ---------------------------------------------------------------------
*/


USE Com5600G05
GO


/*========================= JUEGOS DE PRUEBA =========================*/

--------------------------- ESQUEMA: USUARIO -------------------------- 

------------- TABLA: AREA ------------- 

-- Prueba 1: Insertar un area valida 
-- Resultado: Insercion Exitosa.
EXEC Usuario.insertarArea @nombre = 'Tesorería';

-- Prueba 2: Insertar un area no valida
-- Resultado: Error por restricción CHECK (CHK_Area_Nombre).
EXEC Usuario.insertarArea @nombre = 'RRHH';

-- Prueba 4: Insertar area con nombre vacio.
-- Resultado: Error: El nombre no puede estar vacio.
EXEC Usuario.insertarArea @nombre = '   ';

-- Prueba 4: Insertar area con mayusculas/minusculas diferentes a la restriccion (CHK_Area_Nombre) pero con un nombre valido.
-- Resultado: Insercion exitosa.
EXEC Usuario.insertarArea @nombre = 'socios';

-- Prueba 5: Insertar area duplicada
-- Resultado: Error: El area "Socios" ya existe.
EXEC Usuario.insertarArea @nombre = 'Socios';


------------------------------------------------------------------------
------------- TABLA: ROL -------------- 

-- Prueba 1: Insertar un rol valido en un area existente
-- Resultado: Insercion exitosa
EXEC Usuario.insertarRol @nombre = 'Jefe de Tesorería', @idArea = 1;

-- Prueba 2: Insertar rol con nombre vacio
-- Resultado: Error: El nombre del rol no puede estar vacio.
EXEC Usuario.insertarRol @nombre = '   ', @idArea = 1;

-- Prueba 3: Insertar rol con area inexistente
-- Resultado: Error: El area con ID "999" no existe.
EXEC Usuario.insertarRol @nombre = 'Jefe de Tesorería', @idArea = 999;

 
-- Prueba 5: Insertar rol con nombre repetido para una misma area.
-- Resultado : El rol "Jefe de Tesorería" ya existe.
EXEC Usuario.insertarRol @nombre = 'Jefe de Tesorería', @idArea = 1;

-- Prueba 5: Insertar rol con nombre no valido
-- Resultado : Error por restricción CHECK (CHK_Rol_Nombre).
EXEC Usuario.insertarRol @nombre = 'presidente ejecutivo', @idArea = 1;

-- Prueba 6: Insertar rol con mayusculas/minusculas diferentes a la restriccion (CHK_Area_Nombre) pero con un nombre valido.
-- Resultado: Insercion exitosa.
EXEC Usuario.insertarRol @nombre = 'ADMINISTRATIVO DE COBRANZA', @idArea = 1;

------------------------------------------------------------------------
------------- TABLA: USUARIO -------------- 

-- Prueba 1: Insertar un usuario valido
-- Resultado: Insercion exitosa
EXEC Usuario.insertarUsuario 
    @nombre = 'jperez', 
    @contraseña = '1234', 
    @fechaUltimaRenovacion = '2025-01-01', 
    @fechaARenovar = '2025-07-01';

-- Prueba 2: Insertar usuario con nombre vacio
-- Resultado: Error: El nombre o la contrasena no pueden estar vacios.
EXEC Usuario.insertarUsuario 
    @nombre = '   ', 
    @contraseña = 'asd123', 
    @fechaUltimaRenovacion = '2025-01-01', 
    @fechaARenovar = '2025-07-01';

-- Prueba 3: Insertar usuario con contrasena vacia
-- Resultado: Error: El nombre o la contrasena no pueden estar vacios.
EXEC Usuario.insertarUsuario 
    @nombre = 'mlopez', 
    @contraseña = '', 
    @fechaUltimaRenovacion = '2025-01-01', 
    @fechaARenovar = '2025-07-01';

-- Prueba 4: Insertar usuario con fechaARenovar igual a fechaUltimaRenovacion
-- Resultado: Error: La fecha a renovar debe ser posterior a la fecha de ultima renovacion.
EXEC Usuario.insertarUsuario 
    @nombre = 'jlopez', 
    @contraseña = 'password', 
    @fechaUltimaRenovacion = '2025-05-01', 
    @fechaARenovar = '2025-05-01';

-- Prueba 5: Insertar usuario con fechaARenovar anterior a fechaUltimaRenovacion
-- Resultado: Error: La fecha a renovar debe ser posterior a la fecha de ultima renovacion.
EXEC Usuario.insertarUsuario 
    @nombre = 'jfernandez', 
    @contraseña = 'abc321', 
    @fechaUltimaRenovacion = '2025-06-01', 
    @fechaARenovar = '2025-05-01';

-- Prueba 6: Insertar un usuario con nombre repetido
-- Resultado: Error: Ya existe un usuario con el nombre "jperez".
EXEC Usuario.insertarUsuario 
    @nombre = 'jperez', 
    @contraseña = 'nueva123', 
    @fechaUltimaRenovacion = '2025-06-01', 
    @fechaARenovar = '2025-12-01';

-----------------------------------------------------------------------
------------- TABLA: RolUsuario -------------- 


-- Prueba 1: Insertar relacion valida entre rol y usuario existentes
-- Resultado: Insercion exitosa
EXEC Usuario.insertarRolUsuario @idRol = 1, @idUsuario = 1;

-- Prueba 2: Insertar relacion duplicada
-- Resultado: Error: La relacion entre el rol 1 y el usuario 1 ya existe.
EXEC Usuario.insertarRolUsuario @idRol = 1, @idUsuario = 1;

-- Prueba 3: Insertar con idRol inexistente
-- Resultado: Error: El rol con ID 999 no existe.
EXEC Usuario.insertarRolUsuario @idRol = 999, @idUsuario = 1;

-- Prueba 4: Insertar con idUsuario inexistente
-- Resultado: Error: El usuario con ID 999 no existe.
EXEC Usuario.insertarRolUsuario @idRol = 1, @idUsuario = 999;

-- Prueba 5: Insertar con ambos IDs inexistentes
-- Resultado: Error: El rol con ID 999 no existe.
EXEC Usuario.insertarRolUsuario @idRol = 999, @idUsuario = 999;


-----------------------------------------------------------------------
--------------------------- ESQUEMA: PERSONA -------------------------- 

------------- TABLA: PERSONA -------------- 

-- Prueba 1: Insertar una Persona valida
-- Resultado: Insercion exitosa
EXEC Persona.insertarPersona 
    @nombre = 'Sanchez', 
    @apellido = 'Santi', 
    @fechaNac = '2000-05-10', 
    @dni = 4000000, 
    @telefono = '1134567890', 
    @telefonoEmergencia = '1145678901', 
    @email = 'sanchez.santi@gmail.com';

-- Prueba 2: Nombre vacio
-- Resultado: Error: El nombre y el apellido no pueden estar vacios.
EXEC Persona.insertarPersona 
    @nombre = '', 
    @apellido = 'Santi', 
    @fechaNac = '2000-05-10', 
    @dni = 4000000, 
    @telefono = '1134567890', 
    @telefonoEmergencia = '1145678901', 
    @email = 'sanchez.santi@gmail.com';

-- Prueba 3: Fecha de nacimiento futura
-- Resultado: Error: La fecha de nacimiento no puede ser futura.
EXEC Persona.insertarPersona 
    @nombre = 'Sanchez', 
    @apellido = 'Santi', 
    @fechaNac = '2100-01-01', 
    @dni = 4000000, 
    @telefono = '1134567890', 
    @telefonoEmergencia = '1145678901', 
    @email = 'sanchez.santi@gmail.com';

-- Prueba 4: DNI fuera de rango
-- Resultado: Error: El DNI debe estar entre 0 y 99999999.
EXEC Persona.insertarPersona 
    @nombre = 'Sanchez', 
    @apellido = 'Santi', 
    @fechaNac = '2000-05-10', 
    @dni = -5, 
    @telefono = '1134567890', 
    @telefonoEmergencia = '1145678901', 
    @email = 'sanchez.santi@gmail.com';

-- Prueba 5: Telefono con caracteres no numericos
-- Resultado: Error: Los telefonos deben contener solo digitos.
EXEC Persona.insertarPersona 
    @nombre = 'Sanchez', 
    @apellido = 'Santi', 
    @fechaNac = '2000-05-10', 
    @dni = 4000000, 
    @telefono = '11-34567890', 
    @telefonoEmergencia = '1145678901', 
    @email = 'sanchez.santi@gmail.com';


-----------------------------------------------------------------------
------------- TABLA: PROFESOR -------------- 


-- Prueba 1: Insertar un profesor valido (persona existe y no esta registrada como profesor)
-- Resultado: Insercion exitosa
EXEC Persona.insertarProfesor @idProfesor = 1;

-- Prueba 2: Profesor ya registrado
-- Resultado: Error: La persona con ID 1 ya esta registrada como profesor.
EXEC Persona.insertarProfesor @idProfesor = 1;

-- Prueba 3: Persona inexistente (ID no esta en tabla Persona)
-- Resultado: Error: No existe una persona con ID 999.
EXEC Persona.insertarProfesor @idProfesor = 999;


-----------------------------------------------------------------------
------------- TABLA: INVITADO -------------- 



-- Prueba 1: Insertar un invitado valido (persona existe y no esta registrada como invitado)
-- Resultado: Insercion exitosa
EXEC Persona.insertarPersona 
    @nombre = 'Milei', 
    @apellido = 'Javier', 
    @fechaNac = '1960-05-10', 
    @dni = 4000001, 
    @telefono = '1133334444', 
    @telefonoEmergencia = '11222211111', 
    @email = 'milei.javier@gmail.com';

EXEC Persona.insertarInvitado @idInvitado = 2;

-- Prueba 2: Invitado ya registrado
-- Resultado: Error: La persona con ID 2 ya esta registrada como invitado.
EXEC Persona.insertarInvitado @idInvitado = 2;

-- Prueba 3: Persona inexistente(ID no esta en la tabla Persona)
-- Resultado: Error: No existe una persona con ID 999.
EXEC Persona.insertarInvitado @idInvitado = 999;


-----------------------------------------------------------------------
--------------------------- ESQUEMA: PAGO ----------------------------

------------- TABLA: FormaPago -------------- 

-- Prueba 1: Insertar una forma de pago valida
-- Resultado: Insercion exitosa
EXEC Pago.insertarFormaPago @nombre = 'Visa';

-- Prueba 2: Forma de pago duplicada
-- Resultado: Error: La forma de pago "Visa" ya esta registrada.
EXEC Pago.insertarFormaPago @nombre = 'Visa';

-- Prueba 3: Forma de pago no permitida
-- Resultado: Error: "Efectivo" no es una forma de pago valida.
EXEC Pago.insertarFormaPago @nombre = 'Efectivo';

-- Prueba 4: Nombre vacio
-- Resultado: Error: El nombre de la forma de pago no puede estar vacio.
EXEC Pago.insertarFormaPago @nombre = '';


