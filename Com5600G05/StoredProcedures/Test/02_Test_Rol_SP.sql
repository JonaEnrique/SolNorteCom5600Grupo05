-------<<<<<<<TABLA ROL>>>>>>>-------
--INSERCION DE DATOS EXITOSA

-- SE EJECUTARA EL STORE PROCEDURE 06_ROLSP
EXEC Usuario.CrearRol @nombreRol = 'Jefe de Tesorer�a' , @area ='Tesorer�a';
EXEC Usuario.CrearRol @nombreRol = 'Administrativo de Cobranza' , @area ='Tesorer�a';
EXEC Usuario.CrearRol @nombreRol = 'Administrativo de Morosidad' , @area ='Tesorer�a';
EXEC Usuario.CrearRol @nombreRol = 'Administrativo de Facturacion' , @area ='Tesorer�a';

EXEC Usuario.CrearRol @nombreRol = 'Administrativo Socio' , @area = 'Socios';
EXEC Usuario.CrearRol @nombreRol = 'Socios web' , @area = 'Socios';

EXEC Usuario.CrearRol @nombreRol = 'presidente' , @area = 'Autoridades';
EXEC Usuario.CrearRol @nombreRol = 'vicepresidente' , @area = 'Autoridades';
EXEC Usuario.CrearRol @nombreRol = 'secretario' , @area = 'Autoridades';
EXEC Usuario.CrearRol @nombreRol =  'vocales', @area = 'Autoridades';
-- MOSTRAR TALBLA ROL
SELECT R.idRol, R.area,R.nombre FROM Usuario.Rol R ORDER BY R.idRol;

--ERROR DE INSERCION

-- SE INSERTA UNA TUPLA CON NOMBRE_ROL CON UN AREA YA EXISTENTE
--EN CASO DE SER ASI SE DEBERA ENVIAR UN MENSAJE DE ERROR 
EXEC Usuario.CrearRol @nombreRol = 'presidente' , @area = 'Autoridades';

--ERROR DE MODIFICACION
-- @IDROL NO EXISTENTE
-- EN ESTE CASO DEBE DE DAR ERROR POR ID Y POR ROL Y AREA EXISTENTES 

EXEC Usuario.ModificarRol @idRol = 1,  @nombreRol = 'presidente', @area= 'Autoridades';

--ID NOMBREROL Y AREA YA EXSISTENTE

EXEC Usuario.ModificarRol @idRol = 16, @nombreRol = 'presidente', @area= 'Autoridades';
