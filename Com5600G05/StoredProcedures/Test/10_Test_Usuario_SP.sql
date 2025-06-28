-------<<<<<<<TABLA USUARIO>>>>>>>-------

-- SE EJECUTARA EL STORE PROCEDURE 07_USUARIO_SP
--ISERCION EXITOSA
EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 1, 
@nombre='AIRTON', 
@contraseña='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 2, 
@nombre='JUAN', 
@contraseña='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 3, 
@nombre='SOFIA', 
@contraseña='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 4, 
@nombre='MARIA', 
@contraseña='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 5, 
@nombre='MATEO', 
@contraseña='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 6, 
@nombre='PEDRO', 
@contraseña='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 7, 
@nombre='VALENTINA', 
@contraseña='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 8, 
@nombre='CARLOS', 
@contraseña='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 9, 
@nombre='LUCIA', 
@contraseña='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 10, 
@nombre='NICO', 
@contraseña='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

--ERROR ID INVALIDO
EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 112, 
@nombre='NICO', 
@contraseña='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;
--ERROR NOMBRE DE USUARIO NO DISPONIBLE
EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 10, 
@nombre='NICO', 
@contraseña='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;
--MODIFICAR USUARIO
--ERROR ID INDVALIDO
EXEC Usuario.ModificarUsuario @idUsuario=115,@nombre='ASD',@contraseña='ASD',@fechaRenovar='2025-09-09',@idRol = 4;
--ERROR NOMBRE DE USUARIO INVALIDO
EXEC Usuario.ModificarUsuario @idUsuario=115,@nombre='ASD',@contraseña='ASD',@fechaRenovar='2025-09-09',@idRol = 4;

--ELIMIMAR USUARIO
EXEC Usuario.EliminarUsuario @idUsuario=115,@nombre='ASD',@contraseña='ASD',@fechaRenovar='2025-09-09',@idRol = 4;
SELECT * FROM Usuario.Usuario;
SELECT R.idRol, R.area,R.nombre FROM Usuario.Rol R ORDER BY R.idRol;
