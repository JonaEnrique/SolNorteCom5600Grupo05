# Entidades y Atributos de la Empresa SOL NORTE

## persona
- <span style="color:red">idPersona (PK)</span>
- DNI
- Nombre
- Apellido
- EMAIL
- tell
- tellEmergencia
- FechaNacimiento

## socio
- <span style="color:red">idSocio (PK)</span>
- <span style="color:yellow">idEstadoSocio (FK)</span>
- <span style="color:yellow">idPersona (FK)</span>
- <span style="color:yellow">idCategoria (FK)</span>
- <span style="color:yellow">idObraSocial (FK)</span>


## grupoFamiliar
- <span style="color:red">idGrupo (PK)</span>
- Estado
- fecha de Emisión
- <span style="color:yellow">idSocio (FK)</span>
- <span style="color:yellow">idSocio2 (FK)</span>

## invitacion_evento
- <span style="color:red">idInvitacion (PK)</span>
- fechaInvitacion
- estado
- <span style="color:yellow">idActividadExtra (FK)</span>
- <span style="color:yellow">idPersona (FK)</span>

## actividad_extra
- <span style="color:red">idActExtra (PK)</span>
- fechaHoraInicio
- fechaHoraFin
- <span style="color:yellow">idJornada (FK)</span>
- <span style="color:yellow">idSocio (FK)</span>

## tipo de actividad
- <span style="color:red">idTipoAct (PK)</span>
- descripcion
- <span style="color:yellow">idActExtra (FK)</span>

## tipo de edad
- <span style="color:red">idEdad (PK)</span>
- descripcion

## tipoCliente
- <span style="color:red">idtipoCliente (PK)</span>
- descripcion

## tipo duración
- <span style="color:red">idDuracion (PK)</span>
- descripcion

## tarifa
- <span style="color:red">idTarifa (PK)</span>
- importe
- fechaVigencia
- <span style="color:yellow">idTipoAct (FK)</span>
- <span style="color:yellow">idEdad (FK)</span>
- <span style="color:yellow">idDuracion (FK)</span>
- <span style="color:yellow">idCliente (FK)</span>

## jornada
- <span style="color:red">idJornada (PK)</span>
- ml_lluvia
- Fecha

## factura
- <span style="color:red">idFactura (PK)</span>
- NRO_Factura
- TipoFactura
- estado
- fechaEmision
- fechaVencimiento
- fechaVencimientoMax
- cuit
- montoIVA
- email
- Total
- <span style="color:yellow">idSocio (FK)</span>
- <span style="color:yellow">idItemFactura (FK)</span>
- <span style="color:yellow">idPago (FK)</span>

## DetalleFactura
- <span style="color:red">idItemFactura (PK)</span>
- descuento
- montoBase
- fecha
- recargo
- motivoDescuento
- montoFinal
- <span style="color:yellow">idActExtra (FK)</span>

## NotaCredito
- idEstado(PK)
- Descripcion
- NroComprobante
- fechaEmision
- monto
- motivo
- estado
- <span style="color:yellow">idFactura (FK)</span>

## saldo de cuenta
- <span style="color:red">idSaldo (PK)</span>
- fecha
- monto
- estado
- motivo
- <span style="color:yellow">idSocio (FK)</span>
- <span style="color:yellow">idPago (FK)</span>
## pago
- <span style="color:red">idPago (PK)</span>
- idTransaccion
- Fecha
- Monto
- estado
- <span style="color:yellow">idFormaPago (FK)</span>
- <span style="color:yellow">idSaldo (FK)</span>

## forma de pago
- <span style="color:red">idFormaPago (PK)</span>
- Nombre
## Rembolso
- <span style="color:red">idRembolso (PK)</span>
- fecha
- monto
- motivo
- <span style="color:yellow">idPago (FK)</span>
## categoria
- <span style="color:red">idCategoria (PK)</span>
- nombre
- edad_minima
- edad_maxima

## costo categoría
- <span style="color:red">idCostoCategoria (PK)</span>
- precio
- fechaVigencia
- <span style="color:yellow">idCategoria (FK)</span>

## Actividad deportiva
- <span style="color:red">idActividad (PK)</span>
- nombre

## costo actividad deportiva
- idCostoAct (PK)
- precio
- fechaVigencia
- descripcion
- <span style="color:yellow">idActividad (FK)</span>

## clase
- <span style="color:red">idClase (PK)</span>
- fecha
- hora_inicio
- hora_fin
- <span style="color:yellow">idPersona (FK)</span>
- <span style="color:yellow">idActividad (FK)</span>

## asistencia
- <span style="color:red">idAsistencia (PK)</span>
- fecha
- <span style="color:yellow">idSocio (FK)</span>
- <span style="color:yellow">idClase (FK)</span>

## SocioRealizaActividad
- <span style="color:red">idRealizacion (PK)</span>
- fecha
- <span style="color:yellow">idCategoria (FK)</span>
- <span style="color:yellow">idActividad (FK)</span>
- <span style="color:yellow">idSocio (FK)</span>

## Obra Social
- <span style="color:red">idObraSocial (PK)</span>
- Nombre
- NroObraSocial

## TelefonoObraSocial
- <span style="color:red">idTelefono (PK)</span>
- telefono
- <span style="color:yellow">idObraSocial (FK)</span>

## usuario
- <span style="color:red">idUsuario (PK)</span>
- usuario
- contraseña
- fechaRenovar
- <span style="color:yellow">idPersona (FK)</span>
- <span style="color:yellow">idRol (FK)</span>

## rol
- <span style="color:red">id_Rol (PK)</span>
- nombreRol
- <span style="color:yellow">idArea (FK)</span>


## Area
- <span style="color:red">idArea (PK)</span>
- nombre

## RolUsuario
- <span style="color:red">idRolUsuario (PK)</span>
- <span style="color:yellow">idRol (FK)</span>
- <span style="color:yellow">idSocio (FK)</span>

## EstadoSocio
- <span style="color:red">idEstado (PK)</span>
- descripcion
- fecha


# se podria poner tarjeta para el devito autopmatico y una entidad registro cuota para agilizar la busqueda del informe 6 de deudores morozos
## RegistroCuotas
- <span style="color:red">idCuota (PK)</span>
- monto
- fecha
- estado
- <span style="color:yellow">idSocio (FK)</span>