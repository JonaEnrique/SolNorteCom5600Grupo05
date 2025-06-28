-------<<<<<<<TABLA ACTIVIDAD DEPORTIVA>>>>>>>-------
--INSERCION EXITOSA
EXEC Actividad.CrearActividadDeportivaSinCosto @nombre = 'Futsal';
EXEC Actividad.CrearActividadDeportivaSinCosto @nombre = 'Vóley';
EXEC Actividad.CrearActividadDeportivaSinCosto @nombre = 'Taekwondo';
EXEC Actividad.CrearActividadDeportivaSinCosto @nombre = 'Baile artístico';
EXEC Actividad.CrearActividadDeportivaSinCosto @nombre = 'Natación';
EXEC Actividad.CrearActividadDeportivaSinCosto @nombre = 'Ajedrez';

--ERROR NOMBRE YA EXISTENE
EXEC Actividad.CrearActividadDeportivaSinCosto @nombre = 'Ajederez';

--INSERCION ACTIVIDAD DEPORTIVA CON COSTO CON CON COSTO
EXEC Actividad.CrearActividadDeportivaConCostoNuevo @nombre = 'Boxeo',@fechaVigencia ='2025-07-31',@precio=25000;
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
--ERROR TIENE ASOCIACION CON CLASE

-- MOSTRAR COSTO CATEGORIA
SELECT * FROM Actividad.ActividadDeportiva;
