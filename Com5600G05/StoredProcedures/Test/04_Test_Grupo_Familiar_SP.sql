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
--INSERCION EXITOSA
DECLARE @IDFamiliar1 INT;
EXEC Socio.CrearGrupoFamiliar @idSocioTutor=2,@idSocioMenor=3,@parentesco='Padre',@idGrupoFamiliar=@IDFamiliar1 OUTPUT;
DECLARE @IDFamiliar2 INT;
EXEC Socio.CrearGrupoFamiliar @idSocioTutor=4,@idSocioMenor=5,@parentesco='Padre',@idGrupoFamiliar=@IDFamiliar2 OUTPUT;
DECLARE @IDFamiliar3 INT;
EXEC Socio.CrearGrupoFamiliar @idSocioTutor=6,@idSocioMenor=7,@parentesco='Padre',@idGrupoFamiliar=@IDFamiliar3 OUTPUT;
DECLARE @IDFamiliar4 INT;
EXEC Socio.CrearGrupoFamiliar @idSocioTutor=8,@idSocioMenor=9,@parentesco='Padre',@idGrupoFamiliar=@IDFamiliar4 OUTPUT;

--EROR DE INSERCION

--NO EXITE EL ID DEL TUTOR
DECLARE @TEST_A1 INT;
EXEC Socio.CrearGrupoFamiliar @idSocioTutor=80,@idSocioMenor=9,@parentesco='Padre',@idGrupoFamiliar=@TEST_A1 OUTPUT;

--NO EXISTE EL ID DEL MENOR O CADETE
DECLARE @TEST_A2 INT;
EXEC Socio.CrearGrupoFamiliar @idSocioTutor=8,@idSocioMenor=90,@parentesco='Padre',@idGrupoFamiliar=@TEST_A2 OUTPUT;

--EL SOCIO NO PUEDE SER SU PROPIO TUTOR Y PERTENERCER A UN GRUPO FAMILIAR
DECLARE @TEST_A3 INT;
EXEC Socio.CrearGrupoFamiliar @idSocioTutor=9,@idSocioMenor=9,@parentesco='Padre',@idGrupoFamiliar=@TEST_A3 OUTPUT;

--EL SOCIO PARA SER TUTOR DEBE SER MAYOR DE EDAD
DECLARE @TEST_A4 INT;
EXEC Socio.CrearGrupoFamiliar @idSocioTutor=9,@idSocioMenor=8,@parentesco='Padre',@idGrupoFamiliar=@TEST_A4 OUTPUT;

--EL SOCIO NO PUEDE SERTUTOR DE UN MAYOR
DECLARE @TEST_A5 INT;
EXEC Socio.CrearGrupoFamiliar @idSocioTutor=8,@idSocioMenor=2,@parentesco='Padre',@idGrupoFamiliar=@TEST_A5 OUTPUT;

--ERROR MODICICACION DE MENOR O CADETE

--NO EXISTE EL ID DEL GRUPO FAMILIAR
EXEC Socio.ModificarMenorGrupoFamiliar @idGrupoFamiliar = 60 ,@idSocioMenorNuevo = 3;

--NO EXITE EL SOCIO MENOR
EXEC Socio.ModificarMenorGrupoFamiliar @idGrupoFamiliar = 1 ,@idSocioMenorNuevo = 30;

--EL SOCIO TUTOR NO PUEDE SER TUTOR DE UN MAYOR
EXEC Socio.ModificarMenorGrupoFamiliar @idGrupoFamiliar = 1 ,@idSocioMenorNuevo = 8;

--ERROR MODICICACION DE TUTOR

--NO EXISTE EL ID DEL GRUPO FAMILIAR
EXEC Socio.ModificarResponsableGrupoFamiliar @idGrupoFamiliar = 60 ,@idSocioTutorNuevo = 3;

--NO EXITE EL SOCIO MENOR
EXEC Socio.ModificarResponsableGrupoFamiliar @idGrupoFamiliar = 1 ,@idSocioTutorNuevo = 30;

--NO EXITE EL SOCIO MENOR
EXEC Socio.ModificarResponsableGrupoFamiliar @idGrupoFamiliar = 1 ,@idSocioTutorNuevo = 30;

--EL SOCIO TUTOR NO PUEDE SER MENOR
EXEC Socio.ModificarResponsableGrupoFamiliar @idGrupoFamiliar = 1 ,@idSocioTutorNuevo = 7;