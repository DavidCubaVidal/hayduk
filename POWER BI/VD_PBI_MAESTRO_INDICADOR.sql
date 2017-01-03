create table D_PBI_MAESTRO_INDICADOR (
ID_Indicador INT
,Gerencia varchar(75)
,Indicador varchar(75)
,[Periodo de Analisis] varchar(75)
,[Frecuencia de Revision] varchar(75)
,[Fecha de Corte] varchar(75)
)

select * from D_PBI_MAESTRO_INDICADOR
sp_refreshview VD_PBI_MAESTRO_INDICADOR
select * from VD_PBI_MAESTRO_INDICADOR

ALTER VIEW VD_PBI_MAESTRO_INDICADOR AS
select * from D_PBI_MAESTRO_INDICADOR


INSERT dbo.D_PBI_MAESTRO_INDICADOR VALUES (1,'GERENCIA FLOTA','Cumplimiento de Participación Propias','Temporada de pesca','Semanal','14/11/2016')
INSERT dbo.D_PBI_MAESTRO_INDICADOR VALUES (2,'GERENCIA FLOTA','Consumo de Combustible (Gal/TM MP)','Temporada de pesca','Semanal','14/11/2016')
INSERT dbo.D_PBI_MAESTRO_INDICADOR VALUES (3,'GERENCIA FLOTA','Utilización Capacidad de Bodega','Temporada de pesca','Semanal','14/11/2016')
INSERT dbo.D_PBI_MAESTRO_INDICADOR VALUES (4,'GERENCIA FLOTA','%  SP+P, Prime de la MP Recibida Propia','Temporada de pesca','Semanal','14/11/2016')
INSERT dbo.D_PBI_MAESTRO_INDICADOR VALUES (5,'GERENCIA FLOTA','Cumplimiento de Participación de Terceros','Temporada de pesca','Semanal','14/11/2016')
INSERT dbo.D_PBI_MAESTRO_INDICADOR VALUES (6,'GERENCIA FLOTA','%  SP+P, Prime de la MP Recibida Terceros','Temporada de pesca','Semanal','14/11/2016')
INSERT dbo.D_PBI_MAESTRO_INDICADOR VALUES (7,'GERENCIA OPERACIONES','Utilización de Capacidad de Planta','Temporada de pesca','Semanal','12/08/2016')
INSERT dbo.D_PBI_MAESTRO_INDICADOR VALUES (8,'GERENCIA OPERACIONES','Eficiencia Aprovechamiento Sólidos','Temporada de pesca','Semanal','12/08/2016')
INSERT dbo.D_PBI_MAESTRO_INDICADOR VALUES (9,'GERENCIA OPERACIONES','Eficiencia Aprovechamiento Grasas','Temporada de pesca','Semanal','12/08/2016')
INSERT dbo.D_PBI_MAESTRO_INDICADOR VALUES (10,'GERENCIA OPERACIONES','Consumo de Combustible (Gal/TM)','Temporada de pesca','Semanal','12/08/2016')

