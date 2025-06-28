USE Com5600G05
GO
--INSERCION EXITOSA
EXEC Socio.CrearGrupoFamiliar @idSocioTutor=2,@idSocioMenor=3,@parentesco='Padre';
EXEC Socio.CrearGrupoFamiliar @idSocioTutor=4,@idSocioMenor=5,@parentesco='Padre';
EXEC Socio.CrearGrupoFamiliar @idSocioTutor=6,@idSocioMenor=7,@parentesco='Padre';
EXEC Socio.CrearGrupoFamiliar @idSocioTutor=8,@idSocioMenor=9,@parentesco='Padre';

--EROR DE INSERCION

--NO EXITE EL ID DEL TUTOR
EXEC Socio.CrearGrupoFamiliar @idSocioTutor=80,@idSocioMenor=9,@parentesco='Padre';

--NO EXISTE EL ID DEL MENOR O CADETE
EXEC Socio.CrearGrupoFamiliar @idSocioTutor=8,@idSocioMenor=90,@parentesco='Padre';

--EL SOCIO NO PUEDE SER SU PROPIO TUTOR Y PERTENERCER A UN GRUPO FAMILIAR
EXEC Socio.CrearGrupoFamiliar @idSocioTutor=9,@idSocioMenor=9,@parentesco='Padre';

--EL SOCIO PARA SER TUTOR DEBE SER MAYOR DE EDAD
EXEC Socio.CrearGrupoFamiliar @idSocioTutor=9,@idSocioMenor=8,@parentesco='Padre';

--EL SOCIO NO PUEDE SERTUTOR DE UN MAYOR
EXEC Socio.CrearGrupoFamiliar @idSocioTutor=8,@idSocioMenor=2,@parentesco='Padre';

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