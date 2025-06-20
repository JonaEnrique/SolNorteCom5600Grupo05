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

CREATE OR ALTER PROCEDURE Socio.CrearGrupoFamiliar
	@idSocioTutor INT,
	@idSocioMenor INT,
	@parentesco VARCHAR(30)
AS
BEGIN
	-- si no lo encontre tiro una excepcion
	IF NOT EXISTS (SELECT 1 FROM Socio.Socio WHERE idSocio = @idSocioTutor)
	BEGIN
		DECLARE @mensajeResponsable VARCHAR(100);
		SET @mensajeResponsable = 'No existe socio con el ID ' + CAST(@idSocioTutor AS VARCHAR);
		THROW 51000, @mensajeResponsable, 1;
	END

	-- veo la categoria del responsable
	DECLARE @categoriaTutor INT;
	SET @categoriaTutor = (
		SELECT nombre
		FROM Socio.Categoria
		WHERE idCategoria = (
			SELECT idCategoria
			FROM Socio.Socio
			WHERE idSocio = @idSocioTutor
		)
	);

	-- si no es mayor tiro una excepcion
	IF NOT @categoriaTutor = 'MAYOR'
	BEGIN;
		THROW 51000, 'El responsable debe ser de categoria MAYOR', 1;
	END

	-- si no lo encontre tiro una excepcion
	IF NOT EXISTS (SELECT 1 FROM Socio.Socio WHERE idSocio = @idSocioMenor)
	BEGIN
		DECLARE @mensajeMenor VARCHAR(100);
		SET @mensajeMenor = 'No existe socio con el ID  ' + @idSocioMenor;
		THROW 51000, @mensajeMenor, 1;
	END

	-- supongo que el segundo socio no puede ser mayor
	-- busco la categoria del menor
	DECLARE @categoriaMenor INT;
	SET @categoriaMenor = (
		SELECT nombre
		FROM Socio.Categoria
		WHERE idCategoria = (
			SELECT idCategoria
			FROM Socio.Socio
			WHERE idSocio = @idSocioMenor
		)
	);

	-- si no es menor o cadete tiro una excepcion
	IF @categoriaMenor = 'MAYOR'
	BEGIN;
		THROW 51000, 'El segundo socio debe ser MENOR o CADETE', 1;
	END

	-- si son iguales tiro una excepcion
	IF @idSocioTutor = @idSocioMenor
	BEGIN;
		THROW 51000, 'El socio no puede ser tutor de si mismo', 1;
	END

	INSERT INTO GrupoFamiliar (
		idSocioTutor,
		idSocioMenor,
		parentesco
	)
	VALUES (
		@idResponsable,
		@idMenor,
		@parentesco
	);
END
GO

-- modificar menor de un grupo familiar
CREATE OR ALTER PROCEDURE Socio.ModificarMenorGrupoFamiliar
	@idGrupoFamiliar INT, -- supongo que se selecciona de una lista
	@idSocioMenorNuevo INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM GrupoFamiliar WHERE idGrupoFamiliar = @idGrupoFamiliar)
	BEGIN
		DECLARE @mensajeGrupo VARCHAR(100);
		SET @mensajeGrupo = 'No existe un grupo familiar con el ID ' + CAST(@idGrupoFamiliar AS VARCHAR);
		THROW 51000, @mensajeGrupo, 1;
	END

	IF NOT EXISTS (SELECT 1 FROM Socio WHERE idSocio = @idSocioMenorNuevo)
	BEGIN
		DECLARE @mensajeSocio VARCHAR(100);
		SET @mensajeSocio = 'No existe un socio con el ID ' + CAST(@idSocioMenorNuevo AS VARCHAR);
		THROW 51000, @mensajeSocio, 1;
	END

	DECLARE @categoria VARCHAR(30);
	SET @categoria = (
		SELECT c.nombre
		FROM Categoria c
		WHERE c.idCategoria = (
			SELECT s.idCategoria
			FROM Socio s
			WHERE s.idSocio = @idSocioMenorNuevo
		)
	);

	IF @categoria = 'MAYOR'
	BEGIN;
		THROW 51000, 'El socio debe ser de categoria MENOR o CADETE', 1;
	END

	UPDATE Socio.GrupoFamiliar
	SET idSocioMenor = @idSocioMenorNuevo
	WHERE idGrupoFamiliar = @idGrupoFamiliar;
END
GO

-- modificar socio tutor de grupo familiar
CREATE OR ALTER PROCEDURE Socio.ModificarResponsableGrupoFamiliar
	@idGrupoFamiliar INT,
	@idSocioTutorNuevo INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM GrupoFamiliar WHERE idGrupoFamiliar = @idGrupoFamiliar)
	BEGIN
		DECLARE @mensajeGrupo VARCHAR(100);
		SET @mensajeGrupo = 'No existe un grupo familiar con el ID ' + CAST(@idGrupoFamiliar AS VARCHAR);
		THROW 51000, @mensajeGrupo, 1;
	END

	IF NOT EXISTS (SELECT 1 FROM Socio WHERE idSocio = @idSocioTutorNuevo)
	BEGIN
		DECLARE @mensajeSocio VARCHAR(100);
		SET @mensajeSocio = 'No existe un socio con el ID ' + CAST(@idSocioTutorNuevo AS VARCHAR);
		THROW 51000, @mensajeSocio, 1;
	END

	DECLARE @categoria VARCHAR(30);
	SET @categoria = (
		SELECT c.nombre
		FROM Categoria c
		WHERE c.idCategoria = (
			SELECT s.idCategoria
			FROM Socio s
			WHERE s.idSocio = @idSocioTutorNuevo
		)
	);

	IF @categoria <> 'MAYOR'
	BEGIN;
		THROW 51000, 'El socio debe ser de categoria MAYOR', 1;
	END

	UPDATE GrupoFamiliar
	SET idSocioResponsable = @idSocioTutorNuevo
	WHERE idGrupoFamiliar = @idGrupoFamiliar;
END
GO

-- modificar parentesco
CREATE OR ALTER PROCEDURE Socio.ModificarParentescoGrupoFamiliar
	@idGrupoFamiliar INT,
	@parentescoNuevo VARCHAR(30)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Socio.GrupoFamiliar WHERE idGrupoFamiliar = @idGrupoFamiliar)
	BEGIN
		DECLARE @mensajeGrupo VARCHAR(100);
		SET @mensajeGrupo = 'No existe un grupo familiar con el ID ' + CAST(@idGrupoFamiliar AS VARCHAR);
		THROW 51000, @mensajeGrupo, 1;
	END

	UPDATE Socio.GrupoFamiliar
	SET parentesco = @parentescoNuevo
	WHERE idGrupoFamiliar = @idGrupoFamiliar
END
GO