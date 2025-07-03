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
-------<<<<<<<TABLA COSTO ACTIVIDAD DEPORTIVA>>>>>>>-------
-- SE EJECUTARA EL STORE PROCEDURE 11_ACTIVIDAD_DEPORTIVA_SP
--INSERCION EXITOSA
EXEC Actividad.CrearCostoActividadDeportiva @precio = 25000,@fechaVigencia ='2025-07-31' ,@idActividadDeportiva = 1;
EXEC Actividad.CrearCostoActividadDeportiva @precio = 30000,@fechaVigencia ='2025-07-31' ,@idActividadDeportiva = 2; 
EXEC Actividad.CrearCostoActividadDeportiva @precio = 25000,@fechaVigencia ='2025-07-31' ,@idActividadDeportiva = 3; 
EXEC Actividad.CrearCostoActividadDeportiva @precio = 30000,@fechaVigencia ='2025-07-31' ,@idActividadDeportiva = 4; 
EXEC Actividad.CrearCostoActividadDeportiva @precio = 45000,@fechaVigencia ='2025-07-31' ,@idActividadDeportiva = 5; 
EXEC Actividad.CrearCostoActividadDeportiva @precio =  2000,@fechaVigencia ='2025-07-31' ,@idActividadDeportiva = 8; 

--ERROR ID INVLAIDO
EXEC Actividad.CrearCostoActividadDeportiva @precio =  2000,@fechaVigencia ='2025-07-31' ,@idActividadDeportiva = 60;
-- MOSTRAR COSTO ACTIVIDAD DEPORTIVA
SELECT *FROM Actividad.CostoActividadDeportiva;
