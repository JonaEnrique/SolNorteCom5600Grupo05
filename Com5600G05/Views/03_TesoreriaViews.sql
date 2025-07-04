USE Com5600G05
GO

-- Ver detalles de factura con sus facturas correspondientes, datos de socio y pago realizado si lo hay
CREATE OR ALTER VIEW Factura.VisualizarFacturas (
	[Numero de factura],
	Descripcion,
	[Punto de venta],
	[Tipo de factura],
	[Fecha de emision],
	[Fecha de recargo],
	[Fecha de vencimiento],
	[Total de factura],
	Estado,
	[Monto item],
	[Descuento item],
	[DNI Socio],
	[Nombre socio],
	[Apellido socio],
	[Monto pagado],
	[Fecha de pago],
	[Forma de pago]
)
AS
SELECT
	f.nroFactura,
	df.descripcion,
    f.puntoDeVenta,
    f.tipoFactura,
    f.fechaEmision,
    f.fechaRecargo,
    f.fechaVencimiento,
    f.totalFactura,
    f.estado,
    df.montoBase,
    df.porcentajeDescuento,
	s.dni,
	s.nombre,
	s.apellido,
	p.monto,
	p.fecha,
	fp.nombre
FROM Factura.DetalleFactura AS df
INNER JOIN Factura.Factura AS f
	ON df.idFactura = f.idFactura
INNER JOIN Persona.Persona AS s
	ON f.idSocio = s.idPersona
LEFT OUTER JOIN Pago.Pago AS p
	ON p.idFactura = f.idFactura
LEFT OUTER JOIN Pago.FormaPago AS fp
	ON p.idFormaPago = fp.idFormaPago
GO
