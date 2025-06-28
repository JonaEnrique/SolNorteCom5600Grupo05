USE Com5600G05						
GO



EXEC Importacion.ImportarJornadas @rutaCompletaArchivo = 'C:\Temp\open-meteo-buenosaires_2024.csv';
GO
EXEC Importacion.ImportarJornadas @rutaCompletaArchivo = 'C:\Temp\open-meteo-buenosaires_2025.csv';
GO
EXEC Importacion.ImportarTarifas @rutaCompletaArchivo = 'C:\Temp\Datos socios.xlsx';
GO
EXEC Importacion.ImportarSociosRP @rutaCompletaArchivo = 'C:\Temp\Datos socios.xlsx';
GO
EXEC Importacion.ImportarGrupoFamiliar @rutaCompletaArchivo = 'C:\Temp\Datos socios.xlsx';
GO
EXEC Importacion.ImportarAsistencias @rutaCompletaArchivo = 'C:\Temp\Datos socios.xlsx';
GO
EXEC Importacion.ImportarCuotas @rutaCompletaArchivo = 'C:\Temp\Datos socios.xlsx';
GO


select * from Factura.Factura f JOIN Factura.DetalleFactura df ON df.idFactura = f.idFactura WHERE f.descripcion = 'Cuota'