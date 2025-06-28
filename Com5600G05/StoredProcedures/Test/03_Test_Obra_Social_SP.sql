-------<<<<<<<TABLA OBRA SOCIAL>>>>>>>-------
--INSERCION DE DATOS EXITOSA

-- SE EJECUTARA EL STORE PROCEDURE 06_ROLSP

--INSERCION EXITOSA

EXEC Socio.CrearObraSocial @nombre = ' Medifé',@telefono = '0800 333 0075';
EXEC Socio.CrearObraSocial @nombre = ' OSPIFSE',@telefono = '0810-333-7647';
EXEC Socio.CrearObraSocial @nombre = ' OSTCARA',@telefono = '7172-2501';

--ERROR DE INSERSION POR NOMBRE DE OBRA SOCIAL REPETIDA
EXEC Socio.CrearObraSocial @nombre = ' Medifé',@telefono = '0800 333 0075';

--ERROR DE MODIFICACION DE TALBLA OBRASOSIAL
--ID INEXISTENTE
EXEC Socio.ModificarObraSocial @idObraSocial = 5510, @nombreNuevo ='OSDE',@telefonoNuevo ='11111111111';
--NOMBRE REPETIDO
EXEC Socio.ModificarObraSocial @idObraSocial = 4, @nombreNuevo ='OSPIFSE',@telefonoNuevo ='11111111111';--VER MAL FUNCIONAMIENTO

--ERROR AL ELIMINAR OBRA SOCIAL

--ID INEXISTENTE
EXEC Socio.EliminarObraSocial @idObraSocial= 5;
--ID_OBRASOCIAL ESTA VINCULADA CON  SOCIO

-- MOSTRAR OBRA SOCIAL
SELECT * FROM Socio.ObraSocial;
