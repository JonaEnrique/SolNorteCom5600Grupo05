-------<<<<<<<TABLA PERSONA>>>>>>>-------
-- INSERCION DE TABLA PERSONAS EXITOSO
-- SE EJECUTARA EL STORE PROCEDURE 01_PersonaSP

--- *Juan PERSONA MAYOR
EXEC Persona.CrearPersona @dni = 37102403,@nombre ='Juan', @apellido = 'Sanbuzetti', @email ='JuanSambuZatti@gmail.com',@telefono = '112233445', @telefonoEmergencia = '112233445',@fechaNacimiento ='1997-03-22';
--- >JUAN PADRE DE SOFIA
EXEC Persona.CrearPersona @dni = 30123456,@nombre ='Juan', @apellido = 'G�mez', @email ='juan.gomez123@mail.com',@telefono = '1122334455', @telefonoEmergencia = '1122334455',@fechaNacimiento ='1990-03-22';
---SOFIA PERSONA MENOR
EXEC Persona.CrearPersona @dni = 50102403,@nombre ='Sof�a', @apellido = 'G�mez', @email ='sofia.gomez01@mail.com',@telefono = '1122334455', @telefonoEmergencia = '1122334455',@fechaNacimiento ='2015-03-22';
--- >MARIA MADRE DE MATEO
EXEC Persona.CrearPersona @dni = 41900234,@nombre ='Mar�a', @apellido = 'P�rez', @email ='maria.perez832@mail.com',@telefono = '112233445', @telefonoEmergencia = '112233445',@fechaNacimiento ='1998-03-22';
--- MATEO PERSONA MENOR
EXEC Persona.CrearPersona @dni = 50201304,@nombre ='Mateo', @apellido = 'P�rez', @email ='mateo.perez21@mail.com',@telefono = '112233445', @telefonoEmergencia = '112233445',@fechaNacimiento ='2012-03-22';
--- >PEDRO PADRE VALENTINA
EXEC Persona.CrearPersona @dni = 30123434,@nombre ='Pedro', @apellido = 'Fern�ndez', @email ='pedro.fernandez008@mail.com',@telefono = '112233445', @telefonoEmergencia = '112233445',@fechaNacimiento ='1992-03-22';
--- VALENTINA PERSONA MENOR
EXEC Persona.CrearPersona @dni = 51102403,@nombre ='Valentina', @apellido = 'Fern�ndez', @email ='valen.fernandez@mail.com',@telefono = '112233445', @telefonoEmergencia = '112233445',@fechaNacimiento ='2015-03-22';
--- >CARLOS PADRE DE LUCIA
EXEC Persona.CrearPersona @dni = 33102403,@nombre ='Carlos', @apellido = 'Torres', @email ='JuanSambuZatti@gmail.com',@telefono = '112233445', @telefonoEmergencia = '112233445',@fechaNacimiento ='1993-03-22';
--- LUCIA PERSONA MENOR
EXEC Persona.CrearPersona @dni = 54102403,@nombre ='Luc�a', @apellido = 'Torres', @email ='lucia.romero193@mail.com',@telefono = '112233445', @telefonoEmergencia = '112233445',@fechaNacimiento ='2012-03-22';
--- *NICO PERSONA MAYOR
EXEC Persona.CrearPersona @dni = 36102403,@nombre ='Nicol�s', @apellido = 'Romero', @email ='nico.romero@mail.com',@telefono = '112233445', @telefonoEmergencia = '112233445',@fechaNacimiento ='1997-03-22';

-- MOSTRAR TABLA PERSONA
SELECT * FROM Persona.Persona P;

-- ERROR DE INSERCION
-- YA EXISTE @DNI INGRESADO

EXEC Persona.CrearPersona
@dni=30123456,
@nombre='Jair',
@apellido='Xeneize',
@email='boquitaPasion@mail.com',
@telefono=111777777,
@telefonoEmergencia=777777777,
@fechaNacimiento='1986-08-17';

--EMAIL INVALIDO FALTA DE '@' O '.'

EXEC Persona.CrearPersona
@dni=30123490,
@nombre='Jair',
@apellido='Xeneize',
@email='boquitaPasionmail.com',
@telefono=111777777,
@telefonoEmergencia=777777777,
@fechaNacimiento='1986-08-17';

 --FORMATO FECHA INVALIDA
EXEC Persona.CrearPersona
@dni=30123490,
@nombre='Jair',
@apellido='Xeneize',
@email='boquitaPasion@mail.com',
@telefono=111777777,
@telefonoEmergencia=777777777,
@fechaNacimiento='1986/08/17';

-- ERROR MODIFICAR PERSONA

-- NO EXISTE EL @ID_PERSONA
EXEC Persona.ModificarPersona 
@idPersona = 14,
@dni=44444444,
@nombre='Jair',
@apellido='Xeneize',
@email='boquitaPasion@mail.com',
@telefono=111777777,
@telefonoEmergencia=777777777,
@fechaNacimiento='1986-08-17';

-- YA EXISTE UNA PERSONA CON EL DNI
EXEC Persona.ModificarPersona 
@idPersona = 13,
@dni=51102403,
@nombre='Jair',
@apellido='Xeneize',
@email='boquitaPasion@mail.com',
@telefono=111777777,
@telefonoEmergencia=777777777,
@fechaNacimiento='1986-08-17';

-- ELIMINAR PERSONA

--ID_PERSONA NO EXISTE
EXEC Persona.EliminarPersona  @idPersona = 14;
--ID_PERSONA TIENE SOCIO
--ID_PESONA ES INVITADO
--ID_PERSONA ES SOCIO 