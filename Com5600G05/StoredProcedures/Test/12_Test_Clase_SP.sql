-------<<<<<<<TABLA CLASE>>>>>>>-------
-- SE EJECUTARA EL STORE PROCEDURE 13_CLASE_SP

-- CLASE DE FUTSAL 
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='3/24/2025',@profesor = 'Pablo Rodrigez',@idActividad = 1;
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='4/10/2025',@profesor = 'Pablo Rodrigez',@idActividad = 1;
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='4/24/2025',@profesor = 'Pablo Rodrigez',@idActividad = 1;
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='5/10/2025',@profesor = 'Pablo Rodrigez',@idActividad = 1;
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='5/24/2025',@profesor = 'Pablo Rodrigez',@idActividad = 1;

-- CLASE DE VOLEY
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='3/24/2025',@profesor = 'Ana Paula Alvarez',@idActividad = 2;
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='4/10/2025',@profesor = 'Ana Paula Alvarez',@idActividad = 2;
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='4/24/2025',@profesor = 'Ana Paula Alvarez',@idActividad = 2;
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='5/10/2025',@profesor = 'Ana Paula Alvarez',@idActividad = 2;
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='5/24/2025',@profesor = 'Ana Paula Alvarez',@idActividad = 2;
--CLASE DE Taekwondo
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='3/24/2025',@profesor = 'Kito Mihaji',@idActividad = 3;
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='4/10/2025',@profesor = 'Kito Mihaji',@idActividad = 3;
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='4/24/2025',@profesor = 'Kito Mihaji',@idActividad = 3;
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='5/10/2025',@profesor = 'Kito Mihaji',@idActividad = 3;
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='5/24/2025',@profesor = 'Kito Mihaji',@idActividad = 3;
--CLASE DE Baile artístico
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='3/24/2025',@profesor = 'Carolina Herreta',@idActividad = 4;
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='4/10/2025',@profesor = 'Carolina Herreta',@idActividad = 4;
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='4/24/2025',@profesor = 'Carolina Herreta',@idActividad = 4;
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='5/10/2025',@profesor = 'Carolina Herreta',@idActividad = 4;
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='5/24/2025',@profesor = 'Carolina Herreta',@idActividad = 4;
--CLASE DE Natación
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='3/24/2025',@profesor = 'Paula Quiroga',@idActividad = 5;
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='4/10/2025',@profesor = 'Paula Quiroga',@idActividad = 5;
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='4/24/2025',@profesor = 'Paula Quiroga',@idActividad = 5;
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='5/10/2025',@profesor = 'Paula Quiroga',@idActividad = 5;
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='5/24/2025',@profesor = 'Paula Quiroga',@idActividad = 5;
--CLASE DE Ajederez
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='3/24/2025',@profesor = 'Hector Alvarez',@idActividad = 6;
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='4/10/2025',@profesor = 'Hector Alvarez',@idActividad = 6;
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='4/24/2025',@profesor = 'Hector Alvarez',@idActividad = 6;
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='5/10/2025',@profesor = 'Hector Alvarez',@idActividad = 6;
EXEC Actividad.CrearActividadDeportivaSinCosto @fecha='5/24/2025',@profesor = 'Hector Alvarez',@idActividad = 6;

--ERROR DE INSERCION

--ELIMINAR TABLA CLASE CON ID INVALIDO 
EXEC Actividad.EliminarClase @idClase=100;
--ELIMINAR TABLA CLASE TIENE BINCULADA ASISTENCIA
EXEC Actividad.EliminarClase @idClase=100;

SELECT * FROM Actividad.Clase;
SELECT * FROM Actividad.ActividadDeportiva;
