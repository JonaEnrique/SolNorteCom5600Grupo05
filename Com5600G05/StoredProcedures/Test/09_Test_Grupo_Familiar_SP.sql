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
