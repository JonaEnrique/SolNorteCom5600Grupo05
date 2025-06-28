
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
