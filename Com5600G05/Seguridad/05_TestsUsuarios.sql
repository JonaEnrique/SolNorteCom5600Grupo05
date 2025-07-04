USE Com5600G05
GO

-- Logeado como NicolasPerez
-- Asignar rol socio web
EXEC Seguridad.AsignarRolSociosWeb @usuario = 'UsuarioSocioWeb';
-- Quietar rol socio web
EXEC Seguridad.QuitarRolSociosWeb @usuario = 'UsuarioSocioWeb';

-- Logeado como SantiagoSanchez
-- Asignar rol administrativo de facturacion
EXEC Seguridad.AsignarRolAdministrativoDeFacturacion @usuario = 'UsuarioAdministrativoDeFacturacion';
-- Quitar rol administrativo de facturacion
EXEC Seguridad.QuitarRolAdministrativoDeFacturacion @usuario = 'UsuarioAdministrativoDeFacturacion';

-- Logeado como TeoTurri
-- Asignar rol secretario
EXEC Seguridad.AsignarRolSecretario @usuario = 'UsuarioSecretario';
-- Quitar rol secretario
EXEC Seguridad.QuitarRolSecretario @usuario = 'UsuarioSecretario';