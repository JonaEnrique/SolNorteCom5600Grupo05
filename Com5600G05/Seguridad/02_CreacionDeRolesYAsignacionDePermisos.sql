USE Com5600G05
GO

-- Roles de area
CREATE ROLE Tesoreria;
CREATE ROLE Socios;
CREATE ROLE Autoridades;

-- Roles anidados

-- Tesoreria
	-- Permiso del view VisualizarPagos
	GRANT SELECT
	ON Factura.VisualizarFacturas
	TO Tesoreria;

-- Jefe de tesoreria
CREATE ROLE JefeDeTesoreria;
ALTER ROLE Tesoreria
ADD MEMBER JefeDeTesoreria;

-- Administrativo de cobranza
CREATE ROLE AdministrativoDeCobranza;
ALTER ROLE Tesoreria
ADD MEMBER AdministrativoDeCobranza;

	-- Permiso de insertar pagos mediante SP
	GRANT EXECUTE
	ON Pago.CrearPago
	TO AdministrativoDeCobranza;

	-- Permiso al jefe de tesoreria de añadir y quitar miembros de los roles de tesoreria
	GRANT EXECUTE
	ON Seguridad.AsignarRolAdministrativoDeCobranza
	TO JefeDeTesoreria;
	GRANT EXECUTE
	ON Seguridad.QuitarRolAdministrativoDeCobranza
	TO JefeDeTesoreria

	GRANT EXECUTE
	ON Seguridad.AsignarRolAdministrativoDeMorosidad
	TO JefeDeTesoreria;
	GRANT EXECUTE
	ON Seguridad.QuitarRolAdministrativoDeMorosidad
	TO JefeDeTesoreria

	GRANT EXECUTE
	ON Seguridad.AsignarRolAdministrativoDeFacturacion
	TO JefeDeTesoreria;
	GRANT EXECUTE
	ON Seguridad.QuitarRolAdministrativoDeFacturacion
	TO JefeDeTesoreria

-- Administrativo de morosidad
CREATE ROLE AdministrativoDeMorosidad;
ALTER ROLE Tesoreria
ADD MEMBER AdministrativoDeMorosidad;

	-- Permiso de administrar notas de credito
	GRANT EXECUTE
	ON Factura.CrearNotaDeCredito
	TO AdministrativoDeMorosidad;

	-- Permiso de administrar notas de debito
	GRANT EXECUTE
	ON Factura.CrearNotaDeDebito
	TO AdministrativoDeMorosidad;

-- Administrativo de facturacion
CREATE ROLE AdministrativoDeFacturacion;
ALTER ROLE Tesoreria
ADD MEMBER AdministrativoDeFacturacion;

	-- Permiso de administrar Facturas
	GRANT EXECUTE
	ON Factura.CrearFactura
	TO AdministrativoDeFacturacion;

-- Socios
-- Administrativo socio
CREATE ROLE AdministrativoSocio;
ALTER ROLE Socios
ADD MEMBER AdministrativoSocio;

	-- Permiso de administrar personas
	GRANT EXECUTE
	ON Persona.CrearPersona
	TO AdministrativoSocio;
	GRANT EXECUTE
	ON Persona.ModificarPersona
	TO AdministrativoSocio;
	GRANT EXECUTE
	ON Persona.EliminarPersona
	TO AdministrativoSocio;

	-- Permiso de administrar socios
	GRANT EXECUTE
	ON Socio.CrearSocioConObraSocialExistenteYPersonaExistente
	TO AdministrativoSocio;
	GRANT EXECUTE
	ON Socio.ModificarSocio
	TO AdministrativoSocio;
	GRANT EXECUTE
	ON Socio.ModificarObraSocialSocio
	TO AdministrativoSocio;
	GRANT EXECUTE
	ON Socio.EliminarSocio
	TO AdministrativoSocio;

	-- Permiso de añadir y quitar miembros del rol Socio
	GRANT EXECUTE
	ON Seguridad.AsignarRolSociosWeb
	TO AdministrativoSocio;
	GRANT EXECUTE
	ON Seguridad.QuitarRolSociosWeb
	TO AdministrativoSocio;

	-- Permiso del view VisualizarDatosSocios
	GRANT SELECT
	ON Socio.VisualizarDatosSocios
	TO Socios;

-- Socio
CREATE ROLE SociosWeb;
ALTER ROLE Socios
ADD MEMBER SociosWeb;

	-- Permiso de crear invitaciones
	GRANT EXECUTE
	ON Actividad.CrearInvitacion
	TO SociosWeb;	

-- Autoridades
	-- Permiso del view VisualizarDatosUsuarios
	GRANT SELECT
	ON Usuario.VisualizarDatosUsuarios
	TO Autoridades;

-- Presidente
CREATE ROLE Presidente;
ALTER ROLE Autoridades
ADD MEMBER Presidente;

	-- Permiso de agregar y quitar miembros del rol Secretario
	GRANT EXECUTE
	ON Seguridad.AsignarRolSecretario
	TO Presidente;
	GRANT EXECUTE
	ON Seguridad.QuitarRolSecretario
	TO Presidente;

	-- Permiso de agregar y quitar miembros del rol Vocales
	GRANT EXECUTE
	ON Seguridad.AsignarRolVocales
	TO Presidente;
	GRANT EXECUTE
	ON Seguridad.QuitarRolVocales
	TO Presidente;

-- Vicepresidente
CREATE ROLE Vicepresidente;
ALTER ROLE Autoridades
ADD MEMBER Vicepresidente;

	-- Permiso de agregar y quitar miembros del rol Secretario
	GRANT EXECUTE
	ON Seguridad.AsignarRolSecretario
	TO Vicepresidente;
	GRANT EXECUTE
	ON Seguridad.QuitarRolSecretario
	TO Vicepresidente;

	-- Permiso de agregar y quitar miembros del rol Vocales
	GRANT EXECUTE
	ON Seguridad.AsignarRolVocales
	TO Vicepresidente;
	GRANT EXECUTE
	ON Seguridad.QuitarRolVocales
	TO Vicepresidente;

-- Secretario
CREATE ROLE Secretario;
ALTER ROLE Autoridades
ADD MEMBER Secretario;

	-- Permiso de administrar personas
	GRANT EXECUTE
	ON Persona.CrearPersona
	TO Secretario;
	GRANT EXECUTE
	ON Persona.ModificarPersona
	TO Secretario;
	GRANT EXECUTE
	ON Persona.EliminarPersona
	TO Secretario;

	-- Permiso de administrar usuarios
	GRANT EXECUTE
	ON Usuario.CrearUsuarioConPersonaExistente
	TO Secretario;
	GRANT EXECUTE
	ON Usuario.ModificarUsuario
	TO Secretario;
	GRANT EXECUTE
	ON Usuario.EliminarUsuario
	TO Secretario;

-- Vocales
CREATE ROLE Vocales;
ALTER ROLE Autoridades
ADD MEMBER Vocales;

	-- Permiso de administrar personas
	GRANT EXECUTE
	ON Persona.CrearPersona
	TO Vocales;
	GRANT EXECUTE
	ON Persona.ModificarPersona
	TO Vocales;
	GRANT EXECUTE
	ON Persona.EliminarPersona
	TO Vocales;

	-- Permiso de administrar usuarios
	GRANT EXECUTE
	ON Usuario.CrearUsuarioConPersonaExistente
	TO Vocales;
	GRANT EXECUTE
	ON Usuario.ModificarUsuario
	TO Vocales;
	GRANT EXECUTE
	ON Usuario.EliminarUsuario
	TO Vocales;	