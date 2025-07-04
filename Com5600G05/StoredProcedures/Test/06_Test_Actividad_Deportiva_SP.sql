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
-------<<<<<<<TABLA ACTIVIDAD DEPORTIVA>>>>>>>-------
--INSERCION EXITOSA
EXEC Actividad.CrearActividadDeportivaSinCosto @nombre = 'Futsal';
EXEC Actividad.CrearActividadDeportivaSinCosto @nombre = 'Vóley';
EXEC Actividad.CrearActividadDeportivaSinCosto @nombre = 'Taekwondo';
EXEC Actividad.CrearActividadDeportivaSinCosto @nombre = 'Baile artístico';
EXEC Actividad.CrearActividadDeportivaSinCosto @nombre = 'Natación';
EXEC Actividad.CrearActividadDeportivaSinCosto @nombre = 'Ajedrez';

--ERROR NOMBRE YA EXISTENE
EXEC Actividad.CrearActividadDeportivaSinCosto @nombre = 'Natación';

--INSERCION ACTIVIDAD DEPORTIVA CON COSTO 
EXEC Actividad.CrearActividadDeportivaConCostoNuevo @nombre = 'Ajedrez',@fechaVigencia ='2025-07-31',@precio=25000;
--ERROR NOMBRE YA EXISTENE
EXEC Actividad.CrearActividadDeportivaConCostoNuevo @nombre = 'Boxeo',@fechaVigencia ='2025-07-31',@precio=25000;

--MODIFICAR ACTIVIDAD DEPORTIVA
--ERROR ID INVALIDA
EXEC Actividad.ModificarNombreActividadDeportiva @idActividadDeportiva = 9,@nombreNuevo ='Balet';
--ERROR YA EXISTE EL NOMBRE
EXEC Actividad.ModificarNombreActividadDeportiva @idActividadDeportiva = 4,@nombreNuevo ='Futsal';

--ELIMINAR ACTIVIDAD DEPORTIVA
--ERROR ID INVALIDO
EXEC Actividad.EliminarActividadDeportiva @idActividadDeportiva=20;
--ERROR TIENE ASOCIACION CON SOCIO 
EXEC Actividad.EliminarActividadDeportiva @idActividadDeportiva=1;
--ERROR TIENE ASOCIACION CON CLASE
EXEC Actividad.EliminarActividadDeportiva @idActividadDeportiva=1;
-- MOSTRAR COSTO CATEGORIA
SELECT * FROM Actividad.ActividadDeportiva;
