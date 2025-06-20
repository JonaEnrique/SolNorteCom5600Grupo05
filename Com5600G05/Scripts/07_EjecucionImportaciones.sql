USE Com5600G05						
GO


exec importarJornadas @rutaCompletaArchivo = 'C:\Temp\open-meteo-buenosaires_2024.csv';
exec importarJornadas @rutaCompletaArchivo = 'C:\Temp\open-meteo-buenosaires_2025.csv';
exec importarTarifas @rutaCompletaArchivo = 'C:\Temp\Datos socios.xlsx';
exec importarSocios @rutaCompletaArchivo = 'C:\Temp\Datos socios.xlsx';
exec importarSociosMenores @rutaCompletaArchivo = 'C:\Temp\Datos socios.xlsx';
exec importarAsistencias @rutaCompletaArchivo = 'C:\Temp\Datos socios.xlsx';
exec importarCuotas @rutaCompletaArchivo = 'C:\Temp\Datos socios.xlsx';