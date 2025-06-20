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

CREATE OR ALTER PROCEDURE CrearGrupoFamiliar
	@nroSocioResponsable VARCHAR(30), -- debe coincidir con la cantidad de caracteres de la tabla
	@nroSocioMenor VARCHAR(30) -- debe coincidir con la cantidad de caracteres de la tabla
AS
BEGIN
	-- busco el id del responsable
	DECLARE @idResponsable INT;
	SET @idResponsable = (
		SELECT idSocio
		FROM Socio
		WHERE nroSocio = @nroSocioResponsable
	);

	-- si no lo encontre tiro una excepcion
	IF @idResponsable IS NULL
	BEGIN
		DECLARE @mensajeResponsable VARCHAR(100);
		SET @mensajeResponsable = 'No existe socio con el numero ' + @nroSocioResponsable;
		THROW 51000, @mensajeResponsable, 1;
	END

	-- veo la categoria del responsable
	DECLARE @categoriaResponsable INT;
	SET @categoriaResponsable = (
		SELECT nombre
		FROM Socio
		WHERE idSocio = @idResponsable
	);

	-- si no es mayor tiro una excepcion
	IF NOT @categoriaResponsable = 'MAYOR' -- tiene que coincidir con el check
	BEGIN;
		THROW 51000, 'El responsable debe ser de categoria MAYOR', 1;
	END

	-- busco el id del menor
	DECLARE @idMenor INT;
	SET @idMenor = (
		SELECT idSocio
		FROM Socio
		WHERE nroSocio = @nroSocioMenor
	);

	-- si no lo encontre tiro una excepcion
	IF @idMenor IS NULL
	BEGIN
		DECLARE @mensajeMenor VARCHAR(100);
		SET @mensajeMenor = 'No existe socio con el numero ' + @nroSocioMenor;
		THROW 51000, @mensajeMenor, 1;
	END

	-- supongo que el segundo socio no puede ser mayor
	-- busco la categoria del menor
	DECLARE @categoriaMenor INT;
	SET @categoriaMenor = (
		SELECT nombre
		FROM Socio
		WHERE idSocio = @idMenor
	);

	-- si no es menor o cadete tiro una excepcion
	IF @categoriaMenor = 'MAYOR' -- tiene que coincidir con el check
	BEGIN;
		THROW 51000, 'El segundo socio debe ser MENOR o CADETE', 1;
	END

	-- si son iguales tiro una excepcion
	IF @idResponsable = @idMenor
	BEGIN;
		THROW 51000, 'El socio no puede ser responsable de si mismo', 1;
	END

	INSERT INTO GrupoFamiliar
	VALUES (
		@idResponsable,
		@idMenor
	);
	
	-- devuelvo el valor de la ultima entidad añadida a la tabla por si la necesito
	-- (si no la necesito saco esta linea despues)
	RETURN SCOPE_IDENTITY();
END
GO

-- modificar menor de un grupo familiar
CREATE OR ALTER PROCEDURE ModificarMenorGrupoFamiliar
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

	UPDATE GrupoFamiliar
	SET idSocioMenor = @idSocioMenorNuevo
	WHERE idGrupoFamiliar = @idGrupoFamiliar;
END
GO

-- modificar socio responsable de grupo familiar
CREATE OR ALTER PROCEDURE ModificarResponsableGrupoFamiliar
	@idGrupoFamiliar INT,
	@idSocioResponsableNuevo INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM GrupoFamiliar WHERE idGrupoFamiliar = @idGrupoFamiliar)
	BEGIN
		DECLARE @mensajeGrupo VARCHAR(100);
		SET @mensajeGrupo = 'No existe un grupo familiar con el ID ' + CAST(@idGrupoFamiliar AS VARCHAR);
		THROW 51000, @mensajeGrupo, 1;
	END

	IF NOT EXISTS (SELECT 1 FROM Socio WHERE idSocio = @idSocioResponsableNuevo)
	BEGIN
		DECLARE @mensajeSocio VARCHAR(100);
		SET @mensajeSocio = 'No existe un socio con el ID ' + CAST(@idSocioResponsableNuevo AS VARCHAR);
		THROW 51000, @mensajeSocio, 1;
	END

	DECLARE @categoria VARCHAR(30);
	SET @categoria = (
		SELECT c.nombre
		FROM Categoria c
		WHERE c.idCategoria = (
			SELECT s.idCategoria
			FROM Socio s
			WHERE s.idSocio = @idSocioResponsableNuevo
		)
	);

	IF @categoria <> 'MAYOR'
	BEGIN;
		THROW 51000, 'El socio debe ser de categoria MAYOR', 1;
	END

	UPDATE GrupoFamiliar
	SET idSocioResponsable = @idSocioResponsableNuevo
	WHERE idGrupoFamiliar = @idGrupoFamiliar;
END
GO