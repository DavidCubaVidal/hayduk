CREATE PROCEDURE [dbo].[USP_PBI_INDICADOR_META] -- exec USP_PBI_INDICADOR_META
AS
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

-- NOTA: MODIFICAR SIEMPRE LA ULTIMA TEMPORADA DE PESCA, ESTA HARDCODE

-- *************************************
-- ******    ANCHOVETA N+C    **********
-- *************************************

-- Avance de Participación Propia
declare @app decimal(8,4);

set @app = (select
	CAST("[Measures].[Avance de Cuota]" AS float ) AS [IndicadorMeta]
from openquery([BI HAYDUK SAP], '
SELECT NON EMPTY { [Measures].[Avance de Cuota] } ON COLUMNS,
NON EMPTY { ([TEMPORADA PESCA].[Temporada].[Temporada].ALLMEMBERS ) }
DIMENSION PROPERTIES MEMBER_CAPTION, MEMBER_UNIQUE_NAME ON ROWS
FROM ( SELECT ( { [TEMPORADA PESCA].[Temporada].&[300]&[01]&[201602] } ) ON COLUMNS
FROM ( SELECT ( { [TEMPORADA PESCA].[Region].&[01]&[300] } ) ON COLUMNS
FROM ( SELECT ( { [GRUPO EMPRESARIAL FLOTA].[Grupo Top Empresa Flota].&[2]&[TASA], [GRUPO EMPRESARIAL FLOTA].[Grupo Top Empresa Flota].&[3]&[DIAMANTE], [GRUPO EMPRESARIAL FLOTA].[Grupo Top Empresa Flota].&[5]&[AUSTRAL], [GRUPO EMPRESARIAL FLOTA].[Grupo Top Empresa Flota].&[6]&[EXALMAR], [GRUPO EMPRESARIAL FLOTA].[Grupo Top Empresa Flota].&[7]&[COPEINCA - CFG] } ) ON COLUMNS
FROM [FLOTA PP])))
WHERE ( [GRUPO EMPRESARIAL FLOTA].[Grupo Top Empresa Flota].CurrentMember, [TEMPORADA PESCA].[Region].&[01]&[300] )
CELL PROPERTIES VALUE, BACK_COLOR, FORE_COLOR, FORMATTED_VALUE, FORMAT_STRING, FONT_NAME, FONT_SIZE, FONT_FLAGS
'))

update [F_INDICADOR_META]
set [META_PORCENTAJE] = @app
where [ID_INDICADOR] = 1 -- Cumplimiento de Participación Propias



-- Avance de Participación Terceros
declare @apt decimal(8,4);

set @apt = (select
	CAST("[Measures].[Avance de Cuota]" AS float ) AS [IndicadorMeta]
from openquery([BI HAYDUK SAP], '
SELECT NON EMPTY { [Measures].[Avance de Cuota] } ON COLUMNS,
NON EMPTY { ([TEMPORADA PESCA].[Temporada].[Temporada].ALLMEMBERS ) }
DIMENSION PROPERTIES MEMBER_CAPTION, MEMBER_UNIQUE_NAME ON ROWS
FROM ( SELECT ( { [TEMPORADA PESCA].[Temporada].&[300]&[01]&[201602] } ) ON COLUMNS
FROM ( SELECT ( { [TEMPORADA PESCA].[Region].&[01]&[300] } ) ON COLUMNS
FROM ( SELECT ( { [GRUPO EMPRESARIAL FLOTA].[Grupo Top Empresa Flota].&[7]&[OTROS] } ) ON COLUMNS
FROM [FLOTA PP])))
WHERE ( [GRUPO EMPRESARIAL FLOTA].[Grupo Top Empresa Flota].&[7]&[OTROS], [TEMPORADA PESCA].[Region].&[01]&[300] )
CELL PROPERTIES VALUE, BACK_COLOR, FORE_COLOR, FORMATTED_VALUE, FORMAT_STRING, FONT_NAME, FONT_SIZE, FONT_FLAGS
'))

update [F_INDICADOR_META]
set [META_PORCENTAJE] = @apt
where [ID_INDICADOR] = 2 -- Cumplimiento de Participación de Terceros




-- Utilización Capacidad de Bodega
declare @ucb decimal(8,4);

set @ucb = (select
	CAST("[Measures].[Uso Capacidad de Bodega]" AS float ) AS [IndicadorMeta]
from openquery([BI HAYDUK SAP], '
SELECT NON EMPTY { [Measures].[Uso Capacidad de Bodega] } ON COLUMNS,
NON EMPTY { ([TEMPORADA PESCA].[Temporada].[Temporada].ALLMEMBERS ) }
DIMENSION PROPERTIES MEMBER_CAPTION, MEMBER_UNIQUE_NAME ON ROWS
FROM ( SELECT ( { [TEMPORADA PESCA].[Temporada].&[300]&[01]&[201602] } ) ON COLUMNS
FROM ( SELECT ( { [TEMPORADA PESCA].[Region].&[01]&[300] } ) ON COLUMNS
FROM ( SELECT ( { [GRUPO EMPRESARIAL FLOTA].[Grupo Top Empresa Flota].&[2]&[TASA], [GRUPO EMPRESARIAL FLOTA].[Grupo Top Empresa Flota].&[3]&[DIAMANTE], [GRUPO EMPRESARIAL FLOTA].[Grupo Top Empresa Flota].&[5]&[AUSTRAL], [GRUPO EMPRESARIAL FLOTA].[Grupo Top Empresa Flota].&[6]&[EXALMAR], [GRUPO EMPRESARIAL FLOTA].[Grupo Top Empresa Flota].&[7]&[COPEINCA - CFG] } ) ON COLUMNS
FROM [FLOTA PP])))
WHERE ( [GRUPO EMPRESARIAL FLOTA].[Grupo Top Empresa Flota].CurrentMember, [TEMPORADA PESCA].[Region].&[01]&[300] )
CELL PROPERTIES VALUE, BACK_COLOR, FORE_COLOR, FORMATTED_VALUE, FORMAT_STRING, FONT_NAME, FONT_SIZE, FONT_FLAGS
'))

update [F_INDICADOR_META]
set [META_PORCENTAJE] = @ucb
where [ID_INDICADOR] = 4 -- Capacidad bodega



-- Avance Extraccion Merluza
declare @temporada int = 25 -- ACTUALIZAR TEMPORADA PESCA CHD
declare @version int = (select max(ID_VERSION) from VF_PLAN_OPERATIVO_EXTRACCION where ID_TEMP_PESCA = @temporada)

declare @aem decimal(8,4) = (
	select sum(a.CAPTURA) -- Captura plan a la fecha
	from VF_PLAN_OPERATIVO_EXTRACCION a
	inner join VD_TIEMPO b on a.ID_TIEMPO = b.ID_TIEMPO
	inner join VD_TEMPORADA_PESCA c on a.ID_TEMP_PESCA = c.ID_TEMP_PESCA
	where a.ID_TEMP_PESCA = @temporada and a.ID_VERSION = @version and b.FECH_DIA_SAP between c.FEC_INICIO and convert(varchar(8), getdate(), 112)
	and a.ID_EMBARCACION in (26,31,41)  -- ('DOS HERMANOS','ROSA SILVIA 2','UNION I')
) / (
	select sum(a.CAPTURA) -- Total captura plan
	from VF_PLAN_OPERATIVO_EXTRACCION a
	where a.ID_TEMP_PESCA = @temporada and a.ID_VERSION = @version
	and a.ID_EMBARCACION in (26,31,41)
)

update [F_INDICADOR_META]
set [META_PORCENTAJE] = @aem
where [ID_INDICADOR] = 13 -- Avance Extraccion Merluza

END
