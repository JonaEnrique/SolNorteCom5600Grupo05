USE Com5600G05
GO

CREATE OR ALTER VIEW Usuario.VisualizarDatosUsuarios (
	DNI,
	Apellido,
	Nombre,
	Email,
	Telefono,
	[Telefono de emergencia],
	Area,
	Rol
)
AS
SELECT
	p.dni,
	p.apellido,
	p.nombre,
	p.email,
	p.telefono,
	p.telefonoEmergencia,
	r.area,
	r.nombre
FROM Usuario.Usuario AS u
INNER JOIN Usuario.Rol AS r
	ON u.idRol = r.idRol
INNER JOIN Persona.Persona AS p
	ON u.idPersona = p.idPersona
GO