/*
	Fecha: 23/05/2025
	Grupo: 05
	Materia: Bases de Datos Aplicada
	Nicolas Perez 40015709
	Santiago Sanchez 42281463
	Jonathan Enrique 43301711
	Teo Turri 42819058

	Genere store procedures para manejar la inserción, modificado, borrado (si corresponde,
	también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.
	Los nombres de los store procedures NO deben comenzar con “SP”. 

*/
USE Com5600G05 
GO
-------<<<<<<<TABLA GRUPO FAMILIAR>>>>>>>-------

-- SE EJECUTARA EL STORE PROCEDURE 04_GRUPO_FAMILIAR_SP
--ISERCION EXITOSA
EXEC Socio.CrearGrupoFamiliar @idSocioTutor=2, @idSocioMenor=3, @parentesco='Padre';
EXEC Socio.CrearGrupoFamiliar @idSocioTutor=4, @idSocioMenor=5, @parentesco='Padre';
EXEC Socio.CrearGrupoFamiliar @idSocioTutor=6, @idSocioMenor=7, @parentesco='Padre';
EXEC Socio.CrearGrupoFamiliar @idSocioTutor=8, @idSocioMenor=9, @parentesco='Padre';

--ERROR DE INSERCION
--ID INVALIDO TUTOR
EXEC Socio.CrearGrupoFamiliar @idSocioTutor=80, @idSocioMenor=9, @parentesco='Padre';
--ID INVALIDO MENOR
EXEC Socio.CrearGrupoFamiliar @idSocioTutor=8, @idSocioMenor=90, @parentesco='Padre';
--SOCIO NO PUEDE SER SU PROPIO TUTOR
EXEC Socio.CrearGrupoFamiliar @idSocioTutor=8, @idSocioMenor=8, @parentesco='Padre';

--MOSTRAR TABLA DE GRUPOFAMILIAR 
SELECT * FROM Socio.GrupoFamiliar;

-- ERROR DE MODIFICACION
--ERROR ID GRUPO FAMILIAR INVALIDO
EXEC  Socio.ModificarMenorGrupoFamiliar @idGrupoFamiliar=5, @idSocioMenorNuevo =10;
EXEC  Socio.ModificarResponsableGrupoFamiliar @idGrupoFamiliar = 5, @idSocioTutorNuevo = 10;

--ERROR ID SOCIO INVALIDO
EXEC  Socio.ModificarMenorGrupoFamiliar @idGrupoFamiliar=1, @idSocioMenorNuevo =13;
EXEC  Socio.ModificarResponsableGrupoFamiliar @idGrupoFamiliar = 1, @idSocioTutorNuevo = 111;

--ERROR INCONGRUENCIA DE EDAD
EXEC  Socio.ModificarMenorGrupoFamiliar @idGrupoFamiliar=1, @idSocioMenorNuevo =10;
EXEC  Socio.ModificarResponsableGrupoFamiliar @idGrupoFamiliar = 1, @idSocioTutorNuevo =3;

--ERROR MODIFICAR PARENNTESCO ID INVALIDO
EXEC Socio.ModificarParentescoGrupoFamiliar @idGrupoFamiliar=7,@parentescoNuevo='PADRE BOSTERO';

--ERROR ELIMINAR GRUPOFAMILIAR
EXEC Socio.EliminarGrupoFamiliar @idGrupoFamiliar=100;
