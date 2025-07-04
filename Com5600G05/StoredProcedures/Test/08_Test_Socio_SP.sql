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

-------<<<<<<<TABLA SOCIO>>>>>>>-------
-- SE EJECUTARA EL STORE PROCEDURE 03_SOCIO_SP
--INSERCION EXITOSA
--Juan Sanbuzetti
EXEC Socio.CrearSocioConObraSocialExistenteYPersonaExistente 
@idPersona = 1,
@nroSocio='S0001',
@idObraSocial = 1,
@nroObraSocial = 'ME-852785984', 
@cuit = 37102403, 
@idCategoria = 3;

--Juan Gómez
EXEC Socio.CrearSocioConObraSocialExistenteYPersonaExistente 
@idPersona = 2,
@idObraSocial = 2,
@nroObraSocial = '1258788',
@nroSocio='S0002',
@cuit = 30123456, 
@idCategoria = 3;

--Sofia Gomez
EXEC Socio.CrearSocioConObraSocialExistenteYPersonaExistente 
@idPersona = 3,
@idObraSocial = 1,
@nroObraSocial = 'ME-852785985',
@nroSocio='S0003',
@cuit = 50102403, 
@idCategoria = 2;

--María Pérez
EXEC Socio.CrearSocioConObraSocialExistenteYPersonaExistente 
@idPersona = 4,
@idObraSocial = 1,
@nroObraSocial = 'ME-852785986',
@nroSocio='S0004', 
@cuit = 41900234, 
@idCategoria = 3;

--Mateo Pérez
EXEC Socio.CrearSocioConObraSocialExistenteYPersonaExistente 
@idPersona = 5,
@idObraSocial = 1,
@nroObraSocial = 'ME-852785987',
@nroSocio='S0005', 
@cuit = 37102403, 
@idCategoria = 2;

--Pedro Fernández
EXEC Socio.CrearSocioConObraSocialExistenteYPersonaExistente 
@idPersona = 6,
@idObraSocial = 3,
@nroObraSocial = 'ME-852785988',
@nroSocio='S0006', 
@cuit = 50201304, 
@idCategoria = 3;

--Valentina Fernández
EXEC Socio.CrearSocioConObraSocialExistenteYPersonaExistente 
@idPersona = 7,
@idObraSocial = 1,
@nroObraSocial = 'ME-852785484',
@nroSocio='S0007',
@cuit = 51102403, 
@idCategoria = 1;

--Carlos Torres
EXEC Socio.CrearSocioConObraSocialExistenteYPersonaExistente 
@idPersona = 8,
@idObraSocial = 1,
@nroObraSocial = 'ME-852785990',
@nroSocio='S0008', 
@cuit = 33102403, 
@idCategoria = 3;

--Lucía Torres
EXEC Socio.CrearSocioConObraSocialExistenteYPersonaExistente 
@idPersona = 9,
@idObraSocial = 3,
@nroObraSocial = 'ME-852785999',
@nroSocio='S0009',
@cuit = 54102403, 
@idCategoria = 1;

--Nicolás Romero
EXEC Socio.CrearSocioConObraSocialExistenteYPersonaExistente 
@idPersona = 10,
@idObraSocial = 2,
@nroObraSocial = '698555',
@nroSocio='S0010', 
@cuit = 36102403, 
@idCategoria = 3;


--MODIFICAR TABLA SOCIO

--ERROR ID INVALIDO
EXEC Socio.ModificarSocio @idSocio=14, @nroObraSocial ='123245546' ,@nroSocio= 'S0014', @idCategoria = 3;
--ERROR ID CATEGORIA INVALIDA
EXEC Socio.ModificarSocio @idSocio=10, @nroObraSocial ='123245546' ,@nroSocio= 'S0010', @idCategoria = 5;

--MODIFICAR TABLA SOCIO VINCULADA CON OBRASOCIAL

--ERROR ID INVALIDO
EXEC Socio.ModificarObraSocialSocio  @idSocio=40 ,@idObraSocial=2;
--ERROR ID INVALIDO DE OBRASOCIAL
EXEC Socio.ModificarObraSocialSocio  @idSocio=1 ,@idObraSocial=5;

--ELIMINAR SOCIO
--ERROR ID INVALIDO
EXEC Socio.EliminarSocio @idSocio = 20;

--MOSTRAR TABLAS NECESESARIAS PARA SOCIO
SELECT * FROM Socio.Socio;
SELECT * FROM Persona.Persona P;
SELECT * FROM Socio.ObraSocial;
SELECT * FROM Socio.Categoria;