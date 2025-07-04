USE Com5600G05 
GO



-------<<<<<<<TABLA TARIFA>>>>>>>-------
-- SE EJECUTARA EL STORE PROCEDURE 17_TARIFA_SP

EXEC Actividad.CrearTarifa @precio =25000, @fechaVigencia = '2025-09-20', @descripcionActividad ='UsoPileta', @duracion ='DIA', @edad ='ADULTO', @tipoCliente ='SOCIO';
EXEC Actividad.CrearTarifa @precio =15000, @fechaVigencia = '2025-09-20', @descripcionActividad ='UsoPileta', @duracion ='DIA', @edad ='MENOR', @tipoCliente ='SOCIO';

EXEC Actividad.CrearTarifa @precio =625000, @fechaVigencia = '2025-09-20', @descripcionActividad ='UsoPileta', @duracion ='MES', @edad ='ADULTO', @tipoCliente ='SOCIO';
EXEC Actividad.CrearTarifa @precio =375000, @fechaVigencia = '2025-09-20', @descripcionActividad ='UsoPileta', @duracion ='MES', @edad ='MENOR', @tipoCliente ='SOCIO';

EXEC Actividad.CrearTarifa @precio =2000000, @fechaVigencia = '2025-09-20', @descripcionActividad ='UsoPileta', @duracion ='TEMPORADA', @edad ='ADULTO', @tipoCliente ='SOCIO';
EXEC Actividad.CrearTarifa @precio =1200000, @fechaVigencia = '2025-09-20', @descripcionActividad ='UsoPileta', @duracion ='TEMPORADA', @edad ='MENOR', @tipoCliente ='SOCIO';

EXEC Actividad.CrearTarifa @precio =30000, @fechaVigencia = '2025-09-20', @descripcionActividad ='UsoPileta', @duracion ='DIA', @edad ='ADULTO', @tipoCliente ='INVITADO';
EXEC Actividad.CrearTarifa @precio =20000, @fechaVigencia = '2025-09-20', @descripcionActividad ='UsoPileta', @duracion ='DIA', @edad ='MENOR', @tipoCliente ='INVITADO';

--ERRORES INSECION
--NO SE INGRESO CORECTAMENTE TEMPOPARADA

--RECORDAR QUE TE PUEDE TOMAR DIA o dia  dependiendo como uno modifique el COLLETION	
EXEC Actividad.CrearTarifa @precio =20000, @fechaVigencia = '2025-09-20', @descripcionActividad ='UsoPileta', @duracion ='diass', @edad ='MENOR', @tipoCliente ='INVITADO';

--NO SE INGRESO CORECTAMENTE EDAD

--RECORDAR QUE TE PUEDE TOMAR MENOR o menor  dependiendo como uno modifique el COLLETION	
EXEC Actividad.CrearTarifa @precio =20000, @fechaVigencia = '2025-09-20', @descripcionActividad ='UsoPileta', @duracion ='dia', @edad ='MENORcito', @tipoCliente ='INVITADO';

--NO SE INGRESO CORECTAMENTE  tipoCliente

--RECORDAR QUE TE PUEDE TOMAR SOCIO o socio lo mismo con INVITADO o invitado dependiendo como uno modifique el COLLETION	
EXEC Actividad.CrearTarifa @precio =20000, @fechaVigencia = '2025-09-20', @descripcionActividad ='UsoPileta', @duracion ='dia', @edad ='MENOR', @tipoCliente ='INVsdfdITADO';

SELECT * FROM  Actividad.Tarifa;

-------<<<<<<<TABLA ACTIVIDAD EXTRA>>>>>>>-------
-- SE EJECUTARA EL STORE PROCEDURE 16_ACTIVIDA_EXTRA_SP
EXEC Actividad.CrearActividadExtra @descrpicionActividad = 'UsoPileta', @fechaInicio ='2025-06-28', @fechaFin = '2025-06-28', @idSocio = 1, @idTarifa = 1, @idJornada=1;
EXEC Actividad.CrearActividadExtra @descrpicionActividad = 'UsoPileta', @fechaInicio ='2025-06-28', @fechaFin = '2025-06-28', @idSocio = 2, @idTarifa = 1, @idJornada=1;
EXEC Actividad.CrearActividadExtra @descrpicionActividad = 'UsoPileta', @fechaInicio ='2025-06-29', @fechaFin = '2025-06-29', @idSocio = 2, @idTarifa = 1, @idJornada=2;
--HABLAR CON TEO Y NICO

SELECT * FROM Actividad.ActividadExtra;

-------<<<<<<<TABLA INVITAR EVENTO>>>>>>>-------
-- SE EJECUTARA EL STORE PROCEDURE 18_Invitar_Evento_SP
EXEC Actividad.CrearInvitacion @fechaInvitacion ='2025-06-29', @idActividadExtra =3 ,@idInvitado = 3;
EXEC Actividad.CrearInvitacion @fechaInvitacion ='2025-06-29', @idActividadExtra =3 ,@idInvitado = 4;
EXEC Actividad.CrearInvitacion @fechaInvitacion ='2025-06-29', @idActividadExtra =3 ,@idInvitado = 5;
EXEC Actividad.CrearInvitacion @fechaInvitacion ='2025-06-29', @idActividadExtra =3 ,@idInvitado = 6;
EXEC Actividad.CrearInvitacion @fechaInvitacion ='2025-06-29', @idActividadExtra =3 ,@idInvitado = 10;

--ERROR DE INSERCION

--ERROR NO EXISTE ACCTIVIDAD EXTRA
EXEC Actividad.CrearInvitacion @fechaInvitacion ='2025-06-29', @idActividadExtra =30 ,@idInvitado = 10;
--ERROR NO EXISTE ID INVITADO
EXEC Actividad.CrearInvitacion @fechaInvitacion ='2025-06-29', @idActividadExtra =3 ,@idInvitado = 14;

--MOSTRAR INVITACION EVENTO
SELECT * FROM Actividad.InvitacionEvento; 

-------<<<<<<<TABLA FORMA DE PAGO>>>>>>>-------
--se ejecuta el SP 21_FORMA_DE_PAGO_SP
--INSERCION EXITOSA
EXEC Pago.CrearFormaDePago @nombre = 'efectivo';
EXEC Pago.CrearFormaDePago @nombre = 'Visa';
EXEC Pago.CrearFormaDePago @nombre = 'MasterCard';
EXEC Pago.CrearFormaDePago @nombre = 'Tarjeta Naranja';
EXEC Pago.CrearFormaDePago @nombre = 'Pago Facil';
EXEC Pago.CrearFormaDePago @nombre = 'Rapipago';
EXEC Pago.CrearFormaDePago @nombre = 'Transferencia Mercado Pago';

--ERROR DE INSERCION
--ERROR NOMBRE YA EXISTENTE
EXEC Pago.CrearFormaDePago @nombre = 'Transferencia Mercado Pago';

--ERROR MODIFICAR SE DESEA AGREGAR UN NOMBRE DE FORMA DE PAGO YA EXISTENTE
EXEC ModificarFormaDePago @idFormaPago=1, @nombreNuevo ='Transferencia Mercado Pago';
--ERROR ELIMINAR EL ID ES INVALIDO
EXEC Pago.EliminarFormaDePago @idFormaDePago =10;
--ERROR PAGO VINCULADO A FORMA DE PAGO


--MOSRTRAR FORMA DE PAGO
SELECT * FROM Pago.FormaPago