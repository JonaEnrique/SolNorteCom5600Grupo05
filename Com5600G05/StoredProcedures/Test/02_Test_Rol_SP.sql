
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
-------<<<<<<<TABLA ROL>>>>>>>-------
--INSERCION DE DATOS EXITOSA

-- SE EJECUTARA EL STORE PROCEDURE 06_ROLSP
EXEC Usuario.CrearRol @nombreRol = 'Jefe de Tesorería' , @area ='Tesorería';
EXEC Usuario.CrearRol @nombreRol = 'Administrativo de Cobranza' , @area ='Tesorería';
EXEC Usuario.CrearRol @nombreRol = 'Administrativo de Morosidad' , @area ='Tesorería';
EXEC Usuario.CrearRol @nombreRol = 'Administrativo de Facturacion' , @area ='Tesorería';

EXEC Usuario.CrearRol @nombreRol = 'Administrativo Socio' , @area = 'Socios';
EXEC Usuario.CrearRol @nombreRol = 'Socios web' , @area = 'Socios';

EXEC Usuario.CrearRol @nombreRol = 'presidente' , @area = 'Autoridades';
EXEC Usuario.CrearRol @nombreRol = 'vicepresidente' , @area = 'Autoridades';
EXEC Usuario.CrearRol @nombreRol = 'secretario' , @area = 'Autoridades';
EXEC Usuario.CrearRol @nombreRol =  'vocales', @area = 'Autoridades';
-- MOSTRAR TALBLA ROL
SELECT R.idRol, R.area,R.nombre FROM Usuario.Rol R ORDER BY R.idRol;

--ERROR DE INSERCION

-- SE INSERTA UNA TUPLA CON NOMBRE_ROL CON UN AREA YA EXISTENTE
--EN CASO DE SER ASI SE DEBERA ENVIAR UN MENSAJE DE ERROR 
EXEC Usuario.CrearRol @nombreRol = 'presidente' , @area = 'Autoridades';

--ERROR DE MODIFICACION
-- @IDROL NO EXISTENTE
-- EN ESTE CASO DEBE DE DAR ERROR POR ID Y POR ROL Y AREA EXISTENTES 

EXEC Usuario.ModificarRol @idRol = 1,  @nombreRol = 'presidente', @area= 'Autoridades';

--ID NOMBREROL Y AREA YA EXSISTENTE

EXEC Usuario.ModificarRol @idRol = 16, @nombreRol = 'presidente', @area= 'Autoridades';
