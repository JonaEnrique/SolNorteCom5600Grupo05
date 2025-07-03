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
-------<<<<<<<TABLA CLASE>>>>>>>-------
-- SE EJECUTARA EL STORE PROCEDURE 13_CLASE_SP

-- CLASE DE FUTSAL 
EXEC Actividad.CrearClase @fecha='3/24/2025',@profesor = 'Pablo Rodrigez',@idActividad = 1;
EXEC Actividad.CrearClase @fecha='4/10/2025',@profesor = 'Pablo Rodrigez',@idActividad = 1;
EXEC Actividad.CrearClase @fecha='4/24/2025',@profesor = 'Pablo Rodrigez',@idActividad = 1;
EXEC Actividad.CrearClase @fecha='5/10/2025',@profesor = 'Pablo Rodrigez',@idActividad = 1;
EXEC Actividad.CrearClase @fecha='5/24/2025',@profesor = 'Pablo Rodrigez',@idActividad = 1;

-- CLASE DE VOLEY
EXEC Actividad.CrearClase @fecha='3/24/2025',@profesor = 'Ana Paula Alvarez',@idActividad = 2;
EXEC Actividad.CrearClase @fecha='4/10/2025',@profesor = 'Ana Paula Alvarez',@idActividad = 2;
EXEC Actividad.CrearClase @fecha='4/24/2025',@profesor = 'Ana Paula Alvarez',@idActividad = 2;
EXEC Actividad.CrearClase @fecha='5/10/2025',@profesor = 'Ana Paula Alvarez',@idActividad = 2;
EXEC Actividad.CrearClase @fecha='5/24/2025',@profesor = 'Ana Paula Alvarez',@idActividad = 2;
--CLASE DE Taekwondo
EXEC Actividad.CrearClase @fecha='3/24/2025',@profesor = 'Kito Mihaji',@idActividad = 3;
EXEC Actividad.CrearClase @fecha='4/10/2025',@profesor = 'Kito Mihaji',@idActividad = 3;
EXEC Actividad.CrearClase @fecha='4/24/2025',@profesor = 'Kito Mihaji',@idActividad = 3;
EXEC Actividad.CrearClase @fecha='5/10/2025',@profesor = 'Kito Mihaji',@idActividad = 3;
EXEC Actividad.CrearClase @fecha='5/24/2025',@profesor = 'Kito Mihaji',@idActividad = 3;
--CLASE DE Baile artístico
EXEC Actividad.CrearClase @fecha='3/24/2025',@profesor = 'Carolina Herreta',@idActividad = 4;
EXEC Actividad.CrearClase @fecha='4/10/2025',@profesor = 'Carolina Herreta',@idActividad = 4;
EXEC Actividad.CrearClase @fecha='4/24/2025',@profesor = 'Carolina Herreta',@idActividad = 4;
EXEC Actividad.CrearClase @fecha='5/10/2025',@profesor = 'Carolina Herreta',@idActividad = 4;
EXEC Actividad.CrearClase @fecha='5/24/2025',@profesor = 'Carolina Herreta',@idActividad = 4;
--CLASE DE Natación
EXEC Actividad.CrearClase @fecha='3/24/2025',@profesor = 'Paula Quiroga',@idActividad = 5;
EXEC Actividad.CrearClase @fecha='4/10/2025',@profesor = 'Paula Quiroga',@idActividad = 5;
EXEC Actividad.CrearClase @fecha='4/24/2025',@profesor = 'Paula Quiroga',@idActividad = 5;
EXEC Actividad.CrearClase @fecha='5/10/2025',@profesor = 'Paula Quiroga',@idActividad = 5;
EXEC Actividad.CrearClase @fecha='5/24/2025',@profesor = 'Paula Quiroga',@idActividad = 5;
--CLASE DE Ajederez
EXEC Actividad.CrearClase @fecha='3/24/2025',@profesor = 'Hector Alvarez',@idActividad = 6;
EXEC Actividad.CrearClase @fecha='4/10/2025',@profesor = 'Hector Alvarez',@idActividad = 6;
EXEC Actividad.CrearClase @fecha='4/24/2025',@profesor = 'Hector Alvarez',@idActividad = 6;
EXEC Actividad.CrearClase @fecha='5/10/2025',@profesor = 'Hector Alvarez',@idActividad = 6;
EXEC Actividad.CrearClase @fecha='5/24/2025',@profesor = 'Hector Alvarez',@idActividad = 6;

--ERROR DE INSERCION

--ELIMINAR TABLA CLASE CON ID INVALIDO 
EXEC Actividad.EliminarClase @idClase=100;
--ELIMINAR TABLA CLASE TIENE BINCULADA ASISTENCIA
EXEC Actividad.EliminarClase @idClase=100;

SELECT * FROM Actividad.Clase;
SELECT * FROM Actividad.ActividadDeportiva;
