USE Com5600G05
GO

CREATE OR ALTER VIEW Socio.VisualizarDatosSocios (
	[Numero de socio],
	Apellido,
	Nombre,
	CUIT,
	Telefono,
	[Telefono de emergencia],
	Categoria,
	[Numero de obra social],
	[Obra Social],
	[Telefono de obra social]
)
AS
SELECT
	s.nroSocio,
	p.apellido,
	p.nombre,
	s.cuit,
	p.telefono,
	p.telefonoEmergencia,
	c.nombre,
	o.nombre,
	s.nroObraSocial,
	o.telefono
FROM Socio.Socio AS s
INNER JOIN Persona.Persona AS p
	ON p.idPersona = s.idSocio
INNER JOIN Socio.Categoria AS c
	ON s.idCategoria = c.idCategoria
INNER JOIN Socio.ObraSocial AS o
	ON o.idObraSocial = s.idObraSocial
GO