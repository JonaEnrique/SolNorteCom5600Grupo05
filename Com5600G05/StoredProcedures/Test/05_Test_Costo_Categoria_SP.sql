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
-------<<<<<<<TABLA COSTO CATEGORIA>>>>>>>-------
-- SE EJECUTARA EL STORE PROCEDURE 08_COSTOCATEGORIASP
EXEC Socio.CrearCostoCategoria  @fechaVigencia = '2025-07-31' ,@precio = 25000 ,@idCategoria = 1;
EXEC Socio.CrearCostoCategoria  @fechaVigencia = '2025-07-31' ,@precio = 15000 ,@idCategoria = 2;
EXEC Socio.CrearCostoCategoria  @fechaVigencia = '2025-07-31' ,@precio = 10000 ,@idCategoria = 3;

--ERROR ID INVALIDO
EXEC Socio.CrearCostoCategoria  @fechaVigencia = '2025-07-31' ,@precio = 25000 ,@idCategoria = 7;
-- MOSTRAR COSTO CATEGORIA
SELECT * FROM Socio.CostoCategoria;

