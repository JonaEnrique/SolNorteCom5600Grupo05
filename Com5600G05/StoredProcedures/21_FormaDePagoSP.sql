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

CREATE OR ALTER PROCEDURE Pago.CrearFormaDePago
	@nombre VARCHAR(50)
AS
BEGIN

	IF @nombre IS NULL
	BEGIN;
		THROW 51300, 'El nombre no puede ser NULL', 1;
	END;

	IF EXISTS (SELECT 1 FROM Pago.FormaPago WHERE nombre = @nombre)
	BEGIN;
		THROW 51301, 'Ya existe una forma de pago con el mismo nombre', 1;
	END

	IF @nombre NOT IN ('efectivo', 'Visa','MasterCard','Tarjeta Naranja','Pago Facil','Rapipago','Transferencia Mercado Pago')
	BEGIN;
		THROW 51302, 'El nombre debe ser uno de: efectivo, Visa, Mastercard, Tarjeta Naranja, Pago Facil, Rapipago, Transferencia Mercado Pago', 1;
	END;

	INSERT INTO Pago.FormaPago VALUES (@nombre);
END
GO



CREATE OR ALTER PROCEDURE Pago.ModificarFormaDePago
	@idFormaPago INT,
	@nombreNuevo VARCHAR(50)
AS
BEGIN
	  IF @idFormaPago IS NULL
	  BEGIN;
			THROW 51304, 'El idFormaPago no puede ser NULL.', 1;
	  END;

	  IF @nombreNuevo IS NULL
	  BEGIN;
			THROW 51305, 'El nombreNuevo no puede ser NULL.', 1;
	  END;

	  IF NOT EXISTS (SELECT 1 FROM Pago.FormaPago WHERE idFormaPago = @idFormaPago)
	  BEGIN;
			DECLARE @idNoExiste VARCHAR(100) = 'No existe una forma de pago con ID ' + CAST(@idFormaPago AS VARCHAR);
			THROW 51306, @idNoExiste, 1;
	  END;

	  IF EXISTS (
		  SELECT 1
		  FROM Pago.FormaPago
		  WHERE nombre = @nombreNuevo
			AND idFormaPago <> @idFormaPago
		)
	  BEGIN;
		THROW 51307, 'Ya existe otra forma de pago con el mismo nombre', 1;
	  END;

	  IF @nombreNuevo NOT IN (
		   'efectivo',
		   'Visa',
		   'MasterCard',
		   'Tarjeta Naranja',
		   'Pago Facil',
		   'Rapipago',
		   'Transferencia Mercado Pago'
		 )
	  BEGIN;
		THROW 51308,
		  'El nombreNuevo debe ser uno de: efectivo, Visa, MasterCard, Tarjeta Naranja, Pago Facil, Rapipago, Transferencia Mercado Pago.',
		  1;
	  END;

	  UPDATE Pago.FormaPago
	  SET nombre = @nombreNuevo
	  WHERE idFormaPago = @idFormaPago;
END
GO



CREATE OR ALTER PROCEDURE Pago.EliminarFormaDePago
	@idFormaDePago INT
AS
BEGIN

	IF @idFormaDePago IS NULL
	BEGIN;
		THROW 51309,  'El idFormaPago no puede ser NULL.', 1;
	END;

	IF NOT EXISTS (SELECT 1 FROM Pago.FormaPago WHERE idFormaPago = @idFormaDePago)
	BEGIN;
		THROW 51310, 'El idFormaPago no encontro resultados.', 1;
	END

	IF EXISTS (SELECT 1 FROM Pago.Pago WHERE idFormaPago = @idFormaDePago)
	BEGIN;
		THROW 51311, 'No se puede eliminar la forma de pago ya que existen pagos asociados al mismo. ', 1;
	END;

	DELETE FROM Pago.FormaPago
	WHERE idFormaPago = @idFormaDePago;
END
GO