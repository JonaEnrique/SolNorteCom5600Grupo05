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
EXEC Socio.EliminarObraSocial @idObraSocial= 2;

--MOSTRAR SOCIO
SELECT * FROM Socio.Socio;
-- MOSTRAR OBRA SOCIAL
SELECT * FROM Socio.ObraSocial;
