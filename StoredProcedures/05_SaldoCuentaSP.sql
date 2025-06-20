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

CREATE OR ALTER PROCEDURE CrearSaldoCuenta
	@fecha DATE,
	@monto DECIMAL(10, 2), -- tiene que coincidir con los decimales de la tabla
	@nroSocio VARCHAR(30) -- tiene que coincidir con la cantidad de caracteres de la tabla
AS
BEGIN
	DECLARE @idSocio INT;
	SET @idSocio = (
		SELECT idSocio
		FROM Socio
		WHERE nroSocio = @nroSocio
	);

	IF @idSocio IS NULL
	BEGIN
		DECLARE @mensajeSocio VARCHAR(100);
		SET @mensajeSocio = 'No existe numero de socio ' + @nroSocio;
		THROW 51000, @mensajeSocio, 1;
	END

	DECLARE @idCategoriaSocio INT;
	SET @idCategoriaSocio = (
		SELECT idCategoria
		FROM Socio
		WHERE idSocio = @idSocio
	);

	DECLARE @categoriaSocio VARCHAR(10);
	SET @categoriaSocio = (
		SELECT nombre
		FROM Categoria
		WHERE idCategoria = @idCategoriaSocio
	);

	IF NOT @categoriaSocio = 'MAYOR'
	BEGIN;
		THROW 51000, 'El socio debe ser mayor para tener saldo de cuenta', 1;
	END

	INSERT INTO SaldoCuenta
	VALUES (
		@fecha,
		@monto,
		0, -- se crea sin haber sido usado
		@idSocio
	);
END
GO

-- Modificar estado saldo de cuenta
CREATE OR ALTER PROCEDURE ModificarEstadoSaldoCuenta
	@idSaldoCuenta INT,
	@efectuado BIT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM SaldoCuenta WHERE idSaldoCuenta = @idSaldoCuenta)
	BEGIN
		DECLARE @mensajeSaldo VARCHAR(100);
		SET @mensajeSaldo = 'No existe un saldo a cuenta con el ID ' + CAST(@idSaldoCuenta AS VARCHAR);
		THROW 51000, @mensajeSaldo, 1;
	END

	UPDATE SaldoCuenta
	SET efectuado = @efectuado
	WHERE idSaldoCuenta = @idSaldoCuenta;
END
GO