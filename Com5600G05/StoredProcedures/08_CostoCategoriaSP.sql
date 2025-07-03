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

-- crear costo de categoria y asociarlo a una categoria existente
CREATE OR ALTER PROCEDURE Socio.CrearCostoCategoria
	@fechaVigencia DATE,
	@precio DECIMAL(10, 2),
	@idCategoria INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Socio.Categoria WHERE idCategoria = @idCategoria)
	BEGIN
		RAISERROR('No existe una categoria con el ID %d', 10, 1, @idCategoria);
	END
	ELSE
	BEGIN
		INSERT INTO CostoCategoria (
			fechaVigencia,
			precio,
			idCategoria
		)
		VALUES (
			@fechaVigencia,
			@precio,
			@idCategoria
		);
	END
END
GO

-- no se modifica el costo de la categoria, si un precio se mantiene despues de su fecha de vencimiento se crea uno con el mismo precio pero diferente fecha

--	CREO FUNCION POR SI CAMBIAMOS DE LOGICA
CREATE OR ALTER PROCEDURE Socio.ModificarCostoCategoria
	@idCostoCategoria INT,
	@nuevoPrecio DECIMAL(10, 2),
	@nuevaFechaVigencia DATE
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Socio.CostoCategoria CC WHERE CC.idCostoCategoria = @idCostoCategoria )
	BEGIN
		RAISERROR('No existe un costo con el ID %d.', 10, 1, @idCostoCategoria);
		RETURN;
	END

	UPDATE Socio.CostoCategoria
	SET
		precio = @nuevoPrecio,
		fechaVigencia = @nuevaFechaVigencia
	WHERE
		idCostoCategoria = @idCostoCategoria;
END
GO
CREATE OR ALTER PROCEDURE Socio.eliminarCostoCategoria
	@idCostoCategoria INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Socio.CostoCategoria CC WHERE CC.idCostoCategoria = @idCostoCategoria )
	BEGIN
		RAISERROR('No existe un costo con el ID %d.', 10, 1, @idCostoCategoria);
		RETURN;
	END

	DELETE Socio.CostoCategoria WHERE idCostoCategoria = @idCostoCategoria;
END
GO