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
-------<<<<<<<TABLA JORNADA>>>>>>>-------

-- SE EJECUTARA EL STORE PROCEDURE 15_UJORNADA_SP
--ISERCION EXITOSA
EXEC Actividad.CrearJornada @fecha='2025-06-28',@llovio=0;
EXEC Actividad.CrearJornada @fecha='2025-06-29',@llovio=0;
EXEC Actividad.CrearJornada @fecha='2025-06-30',@llovio=0;
EXEC Actividad.CrearJornada @fecha='2025-06-01',@llovio=1;
EXEC Actividad.CrearJornada @fecha='2025-06-02',@llovio=0;
EXEC Actividad.CrearJornada @fecha='2025-06-03',@llovio=1;
EXEC Actividad.CrearJornada @fecha='2025-06-04',@llovio=0;
--ERROR FECHA REPETIDA
EXEC Actividad.CrearJornada @fecha='2025-06-28',@llovio=0;

--ERROR ID INVALIDO
EXEC Actividad.EliminarJornada @idJornada=3;
--ERROR HAY ASOCIACION CON ACTIVIDAD EXTRA

SELECT * FROM Actividad.Jornada;