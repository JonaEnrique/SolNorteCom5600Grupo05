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
-------<<<<<<<TABLA ASISTE>>>>>>>-------
-- SE EJECUTARA EL STORE PROCEDURE 14_CLASE_SP
--EXEC Actividad.CrearAsistenciaSeleccionandoClase 

--JUAN SANBUZETTI REALIZA SOLO FUTSAL
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase =1 ,@idSocio = 1;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase =2,@idSocio =  1;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase =3 ,@idSocio = 1;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase =4 ,@idSocio = 1;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='A' ,@idClase =5 ,@idSocio = 1;

--JUAN REALIZA SOLO FUTSAL
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='A' ,@idClase =1 ,@idSocio = 2;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='A' ,@idClase =2,@idSocio =  2;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='J' ,@idClase =3 ,@idSocio = 2;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='A' ,@idClase =4 ,@idSocio = 2;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='A' ,@idClase =5 ,@idSocio = 2;

--SOFIA REALIZA VOLEY Y BAILE
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='A' ,@idClase = 6 ,@idSocio = 3;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 7,@idSocio =  3;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='p' ,@idClase = 8 ,@idSocio = 3;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 9 ,@idSocio = 3;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='A' ,@idClase = 10 ,@idSocio = 3;

EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='A' ,@idClase = 16 ,@idSocio = 3;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 17,@idSocio =  3;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='J' ,@idClase = 18 ,@idSocio = 3;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 19 ,@idSocio = 3;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='A' ,@idClase = 20 ,@idSocio = 3;

--MARIA REALIZA BAILE Y NATACION
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 16 ,@idSocio = 4;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 17,@idSocio =  4;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='J' ,@idClase = 18 ,@idSocio = 4;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 19 ,@idSocio = 4;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='A' ,@idClase = 20 ,@idSocio = 4;


EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 21 ,@idSocio = 4;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 22,@idSocio =  4;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 23 ,@idSocio = 4;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 24 ,@idSocio = 4;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='J' ,@idClase = 25 ,@idSocio = 4;

--MATEO REALIZA SOLO  TAEKWOONDO
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 11 ,@idSocio = 5;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 12,@idSocio =  5;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 13 ,@idSocio = 5;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 14 ,@idSocio = 5;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='J' ,@idClase = 15 ,@idSocio = 5;

--PEDRO REALIZA FUTSAL Y AJEDREZ
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase =1, @idSocio = 6;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase =2, @idSocio = 6;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='J' ,@idClase =3 ,@idSocio = 6;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase =4 ,@idSocio = 6;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='A' ,@idClase =5 ,@idSocio = 6;

EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase =26 ,@idSocio = 6;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase =27,@idSocio  = 6;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase =28,@idSocio  = 6;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase =29, @idSocio = 6;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase =30 ,@idSocio = 6;

--VALENTINA REALIZA VOLEY Y TAEKWOONDO
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='A' ,@idClase = 6 ,@idSocio = 7;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 7,@idSocio =  7;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='p' ,@idClase = 8 ,@idSocio = 7;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 9 ,@idSocio = 7;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='A' ,@idClase = 10 ,@idSocio = 7;

EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 11 ,@idSocio = 7;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 12,@idSocio =  7;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 13 ,@idSocio = 7;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 14 ,@idSocio = 7;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='J' ,@idClase = 15 ,@idSocio = 7;

--CARLOS REALIZA SOLO EJEDREZ
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase =1, @idSocio = 8;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase =2, @idSocio = 8;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='J' ,@idClase =3 ,@idSocio = 8;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase =4 ,@idSocio = 8;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='A' ,@idClase =5 ,@idSocio = 8;

--LUCIA REALIZA NATACION Y BAILE
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 16 ,@idSocio = 9;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 17,@idSocio =  9;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='J' ,@idClase = 18 ,@idSocio = 9;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 19 ,@idSocio = 9;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='A' ,@idClase = 20 ,@idSocio = 9;


EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 21 ,@idSocio = 9;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 22,@idSocio =  9;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 23 ,@idSocio = 9;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='P' ,@idClase = 24 ,@idSocio = 9;
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='J' ,@idClase = 25 ,@idSocio = 9;

--NICO NO REALIZA DEPORTE PORQUE NO LE PINTA


--ERROR ID SOCIO INVALIDO
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='A' ,@idClase =15 ,@idSocio = 30;
--ERROR MO EXISTE ID CLASE
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='A' ,@idClase =150 ,@idSocio = 3;
--ERROR ESTADO INVALIDO
EXEC Actividad.CrearAsistenciaSeleccionandoClase @estadoAsistencia ='R' ,@idClase =1 ,@idSocio = 3;
SELECT * FROM Actividad.Asiste;
SELECT * FROM Actividad.ActividadDeportiva