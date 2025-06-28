-------<<<<<<<TABLA SOCIO REALIZA ACTIVIDAD>>>>>>>-------
-- SE EJECUTARA EL STORE PROCEDURE 12_SOCIOREALIZAACT_SP

EXEC Actividad.AsignarActividadASocio @idActividadDeportiva = 1, @idSocio = 1;
EXEC Actividad.AsignarActividadASocio @idActividadDeportiva = 1, @idSocio = 2;
EXEC Actividad.AsignarActividadASocio @idActividadDeportiva = 2, @idSocio = 3;
EXEC Actividad.AsignarActividadASocio @idActividadDeportiva = 4, @idSocio = 3;
EXEC Actividad.AsignarActividadASocio @idActividadDeportiva = 4, @idSocio = 4;
EXEC Actividad.AsignarActividadASocio @idActividadDeportiva = 5, @idSocio = 4;
EXEC Actividad.AsignarActividadASocio @idActividadDeportiva = 3, @idSocio = 5;
EXEC Actividad.AsignarActividadASocio @idActividadDeportiva = 1, @idSocio = 6;
EXEC Actividad.AsignarActividadASocio @idActividadDeportiva = 6, @idSocio = 6;
EXEC Actividad.AsignarActividadASocio @idActividadDeportiva = 2, @idSocio = 7;
EXEC Actividad.AsignarActividadASocio @idActividadDeportiva = 3, @idSocio = 7;
EXEC Actividad.AsignarActividadASocio @idActividadDeportiva = 6, @idSocio = 8;
EXEC Actividad.AsignarActividadASocio @idActividadDeportiva = 5, @idSocio = 9;
EXEC Actividad.AsignarActividadASocio @idActividadDeportiva = 4, @idSocio = 9;


--ERROR DE INSERCION

-- ERROR ID INVALIDO
EXEC Actividad.AsignarActividadASocio @idActividadDeportiva = 1, @idSocio = 1234;
-- ERROR ID ACTIVIDAD DEPORTIVA INVALIDO
EXEC Actividad.AsignarActividadASocio @idActividadDeportiva = 1499944, @idSocio = 1;

--MODIFICAR
--ERROR REALIZA_ACTIVIDAD ID INVALIDO
EXEC Actividad.ModificarRealizaActividad @idRealizaActividad=123 ,@idActividad=1,@idSocio=1;
--ERROR ACTIVIDAD ID INVALIDO
EXEC Actividad.ModificarRealizaActividad @idRealizaActividad=1 ,@idActividad=100,@idSocio=1;
--ERROR SOCIO ID INVALIDO
EXEC Actividad.ModificarRealizaActividad @idRealizaActividad=1 ,@idActividad=1,@idSocio=91;

SELECT * FROM Actividad.SocioRealizaActividad;
SELECT * FROM Actividad.ActividadDeportiva;