/*
	Fecha: 23/05/2025
	Grupo: 05
	Materia: Bases de Datos Aplicada
	Nicolas Perez 40015709
	Santiago Sanchez 42281463
	Jonathan Enrique 43301711
	Teo Turri 42819058

	Genere store procedures para manejar la inserción, modificado, borrado (si corresponde,
	también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.
	Los nombres de los store procedures NO deben comenzar con “SP”. 

*/
USE Com5600G05 
GO
-------<<<<<<<TABLA PERSONA>>>>>>>-------
-- INSERCION DE TABLA PERSONAS EXITOSO
-- SE EJECUTARA EL STORE PROCEDURE 01_PersonaSP

--- *Juan PERSONA MAYOR
EXEC Persona.CrearPersona @dni = 37102403,@nombre ='Juan', @apellido = 'Sanbuzetti', @email ='JuanSambuZatti@gmail.com',@telefono = '112233445', @telefonoEmergencia = '112233445',@fechaNacimiento ='1997-03-22';
--- >JUAN PADRE DE SOFIA
EXEC Persona.CrearPersona @dni = 30123456,@nombre ='Juan', @apellido = 'Gómez', @email ='juan.gomez123@mail.com',@telefono = '1122334455', @telefonoEmergencia = '1122334455',@fechaNacimiento ='1990-03-22';
---SOFIA PERSONA MENOR
EXEC Persona.CrearPersona @dni = 50102403,@nombre ='Sofía', @apellido = 'Gómez', @email ='sofia.gomez01@mail.com',@telefono = '1122334455', @telefonoEmergencia = '1122334455',@fechaNacimiento ='2015-03-22';
--- >MARIA MADRE DE MATEO
EXEC Persona.CrearPersona @dni = 41900234,@nombre ='María', @apellido = 'Pérez', @email ='maria.perez832@mail.com',@telefono = '112233445', @telefonoEmergencia = '112233445',@fechaNacimiento ='1998-03-22';
--- MATEO PERSONA MENOR
EXEC Persona.CrearPersona @dni = 50201304,@nombre ='Mateo', @apellido = 'Pérez', @email ='mateo.perez21@mail.com',@telefono = '112233445', @telefonoEmergencia = '112233445',@fechaNacimiento ='2012-03-22';
--- >PEDRO PADRE VALENTINA
EXEC Persona.CrearPersona @dni = 30123434,@nombre ='Pedro', @apellido = 'Fernández', @email ='pedro.fernandez008@mail.com',@telefono = '112233445', @telefonoEmergencia = '112233445',@fechaNacimiento ='1992-03-22';
--- VALENTINA PERSONA MENOR
EXEC Persona.CrearPersona @dni = 51102403,@nombre ='Valentina', @apellido = 'Fernández', @email ='valen.fernandez@mail.com',@telefono = '112233445', @telefonoEmergencia = '112233445',@fechaNacimiento ='2015-03-22';
--- >CARLOS PADRE DE LUCIA
EXEC Persona.CrearPersona @dni = 33102403,@nombre ='Carlos', @apellido = 'Torres', @email ='JuanSambuZatti@gmail.com',@telefono = '112233445', @telefonoEmergencia = '112233445',@fechaNacimiento ='1993-03-22';
--- LUCIA PERSONA MENOR
EXEC Persona.CrearPersona @dni = 54102403,@nombre ='Lucía', @apellido = 'Torres', @email ='lucia.romero193@mail.com',@telefono = '112233445', @telefonoEmergencia = '112233445',@fechaNacimiento ='2012-03-22';
--- *NICO PERSONA MAYOR
EXEC Persona.CrearPersona @dni = 36102403,@nombre ='Nicolás', @apellido = 'Romero', @email ='nico.romero@mail.com',@telefono = '112233445', @telefonoEmergencia = '112233445',@fechaNacimiento ='1997-03-22';

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