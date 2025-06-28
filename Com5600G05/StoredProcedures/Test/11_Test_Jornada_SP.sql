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