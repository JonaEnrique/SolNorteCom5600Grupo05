-------<<<<<<<TABLA USUARIO>>>>>>>-------

-- SE EJECUTARA EL STORE PROCEDURE 07_USUARIO_SP
--ISERCION EXITOSA
EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 1, 
@nombre='AIRTON', 
@contraseņa='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 2, 
@nombre='JUAN', 
@contraseņa='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 3, 
@nombre='SOFIA', 
@contraseņa='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 4, 
@nombre='MARIA', 
@contraseņa='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 5, 
@nombre='MATEO', 
@contraseņa='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 6, 
@nombre='PEDRO', 
@contraseņa='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 7, 
@nombre='VALENTINA', 
@contraseņa='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 8, 
@nombre='CARLOS', 
@contraseņa='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 9, 
@nombre='LUCIA', 
@contraseņa='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 10, 
@nombre='NICO', 
@contraseņa='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

--ERROR ID INVALIDO
EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 112, 
@nombre='NICO', 
@contraseņa='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;
--ERROR NOMBRE DE USUARIO NO DISPONIBLE
EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 10, 
@nombre='NICO', 
@contraseņa='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;
--MODIFICAR USUARIO
--ERROR ID INDVALIDO
EXEC Usuario.ModificarUsuario @idUsuario=115,@nombre='ASD',@contraseņa='ASD',@fechaRenovar='2025-09-09',@idRol = 4;
--ERROR NOMBRE DE USUARIO INVALIDO
EXEC Usuario.ModificarUsuario @idUsuario=115,@nombre='ASD',@contraseņa='ASD',@fechaRenovar='2025-09-09',@idRol = 4;

--ELIMIMAR USUARIO
EXEC Usuario.EliminarUsuario @idUsuario=115,@nombre='ASD',@contraseņa='ASD',@fechaRenovar='2025-09-09',@idRol = 4;
SELECT * FROM Usuario.Usuario;
SELECT R.idRol, R.area,R.nombre FROM Usuario.Rol R ORDER BY R.idRol;
