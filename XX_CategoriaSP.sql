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

-- Crear Categoria
CREATE OR ALTER PROCEDURE CrearCategoria 
	@categoriaNueva VARCHAR(100),
	@edadMinima TINYINT,
	@edadMaxima TINYINT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM ActDeportiva.Categoria WHERE nombre = @categoriaNueva)
	BEGIN
		RAISERROR('La categoria %s ya existe.', 10, 1, @categoriaNueva);
	END
	ELSE
	BEGIN
		INSERT INTO ActDeportiva.Categoria
		VALUES (@categoriaNueva, @edadMinima, @edadMaxima);
	END
END
GO