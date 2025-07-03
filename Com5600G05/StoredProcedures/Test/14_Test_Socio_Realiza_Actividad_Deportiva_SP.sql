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