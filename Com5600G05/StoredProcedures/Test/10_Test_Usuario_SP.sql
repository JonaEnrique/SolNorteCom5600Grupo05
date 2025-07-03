/*
	Fecha: 23/05/2025
	Grupo: 05
	Materia: Bases de Datos Aplicada
	Nicolas Perez 40015709
	Santiago Sanchez 42281463
	Jonathan Enrique 43301711
	Teo Turri 42819058

	Genere store procedures para manejar la inserci�n, modificado, borrado (si corresponde,
	tambi�n debe decidir si determinadas entidades solo admitir�n borrado l�gico) de cada tabla.
	Los nombres de los store procedures NO deben comenzar con �SP�. 

*/
USE Com5600G05 
GO
-------<<<<<<<TABLA USUARIO>>>>>>>-------

-- SE EJECUTARA EL STORE PROCEDURE 07_USUARIO_SP
--ISERCION EXITOSA
EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 1, 
@nombre='AIRTON', 
@contrase�a='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 2, 
@nombre='JUAN', 
@contrase�a='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 3, 
@nombre='SOFIA', 
@contrase�a='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 4, 
@nombre='MARIA', 
@contrase�a='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 5, 
@nombre='MATEO', 
@contrase�a='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 6, 
@nombre='PEDRO', 
@contrase�a='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 7, 
@nombre='VALENTINA', 
@contrase�a='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 8, 
@nombre='CARLOS', 
@contrase�a='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 9, 
@nombre='LUCIA', 
@contrase�a='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 10, 
@nombre='NICO', 
@contrase�a='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;

--ERROR ID INVALIDO
EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 112, 
@nombre='NICO', 
@contrase�a='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;
--ERROR NOMBRE DE USUARIO NO DISPONIBLE
EXEC Usuario.CrearUsuarioConPersonaExistente 
@idPersona = 10, 
@nombre='NICO', 
@contrase�a='BOCAPASION07', 
@fechaRenovar='2025-07-31', 
@idRol = 6;
--MODIFICAR USUARIO
--ERROR ID INDVALIDO
EXEC Usuario.ModificarUsuario @idUsuario=115,@nombre='ASD',@contrase�a='ASD',@fechaRenovar='2025-09-09',@idRol = 4;
--ERROR NOMBRE DE USUARIO INVALIDO
EXEC Usuario.ModificarUsuario @idUsuario=115,@nombre='ASD',@contrase�a='ASD',@fechaRenovar='2025-09-09',@idRol = 4;

--ELIMIMAR USUARIO
EXEC Usuario.EliminarUsuario @idUsuario=115,@nombre='ASD',@contrase�a='ASD',@fechaRenovar='2025-09-09',@idRol = 4;
SELECT * FROM Usuario.Usuario;
SELECT R.idRol, R.area,R.nombre FROM Usuario.Rol R ORDER BY R.idRol;
