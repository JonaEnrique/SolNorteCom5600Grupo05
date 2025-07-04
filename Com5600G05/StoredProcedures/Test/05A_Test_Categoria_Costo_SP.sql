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
--CREACION DE TABLA SIN CREAR LA TABLA COSTO 
EXEC Socio.CrearCategoriaSinCosto @edadMinima=NULL, @edadMaxima=12, @nombre='Menor';
EXEC Socio.CrearCategoriaSinCosto @edadMinima=13, @edadMaxima=17, @nombre='Cadete';
EXEC Socio.CrearCategoriaSinCosto @edadMinima=18, @edadMaxima=NULL, @nombre='Mayor';

--Creacion de Tabla INCLUYENDO TABLA COSTO CATEGORIA 
EXEC Socio.CrearCategoriaConCostoNuevo @edadMinima= NULL,@edadMaxima=12,@nombre='Menor',@fechaVigencia='2025-07-31',@precio=25000;
EXEC Socio.CrearCategoriaConCostoNuevo @edadMinima=13,@edadMaxima=17,@nombre='Cadete',@fechaVigencia='2025-07-31',@precio=15000;
EXEC Socio.CrearCategoriaConCostoNuevo @edadMinima=18,@edadMaxima=NULL,@nombre='Mayor',@fechaVigencia='2025-07-31',@precio=10000;

--ERROR NOMBRE YA EXISTENTE
EXEC Socio.CrearCategoriaConCostoNuevo @edadMinima=18,@edadMaxima=NULL,@nombre='Mayor',@fechaVigencia='2025-07-31',@precio=10000;

--MODIFICAR CATEGORIA

--ERROR ID NO RECONOCIDO
EXEC Socio.ModificarCategoria @idCategoria=12, @edadMinima=NULL ,@edadMaxima=100 ,@nombre='Boca';

--ERROR EDAD MINIMA > EDADMAXIMA
EXEC Socio.ModificarCategoria @idCategoria=2, @edadMinima=200 ,@edadMaxima=100 ,@nombre='Mayor';

--ERROR ID A ELIMINAR NO EXISTE
EXEC Socio.EliminarCategoria @idCategoria=100;
--ERROR SOCIO ASOCIADO

SELECT * FROM Socio.Categoria;
SELECT * FROM Socio.CostoCategoria;

