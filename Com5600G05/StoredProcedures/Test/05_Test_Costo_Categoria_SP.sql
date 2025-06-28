-------<<<<<<<TABLA COSTO CATEGORIA>>>>>>>-------
-- SE EJECUTARA EL STORE PROCEDURE 08_COSTOCATEGORIASP
EXEC Socio.CrearCostoCategoria  @fechaVigencia = '2025-07-31' ,@precio = 25000 ,@idCategoria = 1;
EXEC Socio.CrearCostoCategoria  @fechaVigencia = '2025-07-31' ,@precio = 15000 ,@idCategoria = 2;
EXEC Socio.CrearCostoCategoria  @fechaVigencia = '2025-07-31' ,@precio = 10000 ,@idCategoria = 3;

--ERROR ID INVALIDO
EXEC Socio.CrearCostoCategoria  @fechaVigencia = '2025-07-31' ,@precio = 25000 ,@idCategoria = 7;
-- MOSTRAR COSTO CATEGORIA
SELECT * FROM Socio.CostoCategoria;

