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

CREATE OR ALTER PROCEDURE Pago.CrearSaldoCuenta
	@monto DECIMAL(10, 2),
	@idPago INT,
	@idSocio INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Socio.Socio WHERE idSocio = @idSocio)
	BEGIN
		DECLARE @mensajeSocio VARCHAR(100);
		SET @mensajeSocio = 'No existe ID de socio ' + CAST(@idSocio AS VARCHAR);
		THROW 51000, @mensajeSocio, 1;
	END

	DECLARE @categoriaSocio VARCHAR(10);
	SET @categoriaSocio = (
		SELECT nombre
		FROM Socio.Categoria
		WHERE idCategoria = (
			SELECT idCategoria
			FROM Socio.Socio
			WHERE idSocio = @idSocio
		)
	);

	IF NOT @categoriaSocio = 'MAYOR'
	BEGIN;
		THROW 51000, 'El socio debe ser mayor para tener saldo de cuenta', 1;
	END

	IF NOT EXISTS (SELECT 1 FROM Pago.Pago WHERE idPago = @idPago)
	BEGIN
		DECLARE @mensajePago VARCHAR(100);
		SET @mensajePago = 'No existe un pago con el ID ' + CAST(@idPago AS VARCHAR);
		THROW 51000, @mensajePago, 1;
	END

	INSERT INTO Pago.SaldoDeCuenta (
		monto,
		aplicado,
		idPago,
		idSocio
	)
	VALUES (
		@monto,
		0, -- se crea sin haber sido usado
		@idPago,
		@idSocio
	);
END
GO

-- Modificar estado saldo de cuenta
CREATE OR ALTER PROCEDURE Pago.ModificarEstadoSaldoCuenta
	@idSaldoDeCuenta INT,
	@aplicado BIT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Pago.SaldoDeCuenta WHERE idSaldoDeCuenta = @idSaldoDeCuenta)
	BEGIN
		DECLARE @mensajeSaldo VARCHAR(100);
		SET @mensajeSaldo = 'No existe un saldo a cuenta con el ID ' + CAST(@idSaldoDeCuenta AS VARCHAR);
		THROW 51000, @mensajeSaldo, 1;
	END

	UPDATE SaldoDeCuenta
	SET aplicado = @aplicado
	WHERE idSaldoDeCuenta = @idSaldoDeCuenta;
END
GO