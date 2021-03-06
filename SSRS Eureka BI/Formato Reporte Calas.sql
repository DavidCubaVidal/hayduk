-- ********************************************************************
-- ******************        Embarcacion             ******************
-- ********************************************************************
DECLARE @inicio varchar(8) = (SELECT TOP 1 FEC_INIC FROM prd.ZTPP_TEMP_PESCA WITH (nolock) WHERE MANDT = 300 AND IDREGION = @ParamRegion AND CTEMPORADA = @ParamTemporada)
DECLARE @fin varchar(8) = (SELECT TOP 1 FEC_FIN_REG FROM prd.ZTPP_TEMP_PESCA WITH (nolock) WHERE MANDT = 300 AND IDREGION = @ParamRegion AND CTEMPORADA = @ParamTemporada)

SELECT DISTINCT A.MATRICULA, A.EMBARC
FROM prd.ZTPP_INFOR_FLOTA A (nolock)
INNER JOIN prd.ZTPP_CALAS B (nolock) ON A.MANDT=B.MANDT AND A.NUMINF=B.NUMINF
INNER JOIN prd.MARA C (nolock) ON A.MANDT=C.MANDT AND A.MATNR=C.MATNR
WHERE A.TIPINF='P'AND A.MATNR='000000000016000000'
AND A.FECZARP BETWEEN @inicio AND @fin
ORDER BY A.EMBARC


GO-- *************************************************************
-- ******************           Informes        ******************
-- ***************************************************************
DECLARE @inicio varchar(8) = (SELECT TOP 1 FEC_INIC FROM prd.ZTPP_TEMP_PESCA WITH (nolock) WHERE MANDT = 300 AND IDREGION = @ParamRegion AND CTEMPORADA = @ParamTemporada)
DECLARE @fin varchar(8) = (SELECT TOP 1 FEC_FIN_REG FROM prd.ZTPP_TEMP_PESCA WITH (nolock) WHERE MANDT = 300 AND IDREGION = @ParamRegion AND CTEMPORADA = @ParamTemporada)

SELECT DISTINCT A.NUMINF
FROM prd.ZTPP_INFOR_FLOTA A (nolock)
INNER JOIN prd.ZTPP_CALAS B (nolock) ON A.MANDT=B.MANDT AND A.NUMINF=B.NUMINF
INNER JOIN prd.MARA C (nolock) ON A.MANDT=C.MANDT AND A.MATNR=C.MATNR
inner join prd.ZTPP_PUERTOS Z (nolock) on A.PTOARRI = Z.PTONU and A.MANDT = Z.MANDT
WHERE TIPINF='P'AND A.MATNR='000000000016000000'
AND MATRICULA=@MATRICULA
AND A.FECZARP BETWEEN @inicio AND @fin
and Z.IDREGION = (@ParamRegion)
order by 1 desc

GO -- *****************************************************************
-- ******************      Conteo Informes     ************************
-- ********************************************************************

DECLARE @inicio varchar(8) = (SELECT TOP 1 FEC_INIC FROM prd.ZTPP_TEMP_PESCA WITH (nolock) WHERE MANDT = 300 AND IDREGION = @ParamRegion AND CTEMPORADA = @ParamTemporada)
DECLARE @fin varchar(8) = (SELECT TOP 1 FEC_FIN_REG FROM prd.ZTPP_TEMP_PESCA WITH (nolock) WHERE MANDT = 300 AND IDREGION = @ParamRegion AND CTEMPORADA = @ParamTemporada)

SELECT COUNT(DISTINCT A.NUMINF) AS CONTEO_INFORMES
FROM prd.ZTPP_INFOR_FLOTA A (nolock)
INNER JOIN prd.ZTPP_CALAS B (nolock) ON A.MANDT=B.MANDT AND A.NUMINF=B.NUMINF
INNER JOIN prd.MARA C (nolock) ON A.MANDT=C.MANDT AND A.MATNR=C.MATNR
inner join prd.ZTPP_PUERTOS Z (nolock) on A.PTOARRI = Z.PTONU and A.MANDT = Z.MANDT
WHERE TIPINF='P'AND A.MATNR='000000000016000000'
AND MATRICULA= @MATRICULA
AND A.FECZARP BETWEEN @inicio AND @fin
AND A.PESCA = 'X'
and Z.IDREGION = (@ParamRegion)

-- ********************************************************************
-- ******************       Reporte Calas     *************************
-- ********************************************************************
SELECT A.MANDT,A.NUMINF,A.TIPINF,A.WERKS,A.MATRICULA,A.EMBARC,
'PESQUERA HAYDUK S.A.'AS ARMADOR,
A.MATNR,A.[STATUS],
convert(numeric(18,2),B.TBODE) as TBODE,
B.NUMCALA,
CASE WHEN FECCAL1='00000000'THEN CONVERT(VARCHAR(10),CONVERT(DATETIME,'1900-01-01'),103)
ELSE
CONVERT(VARCHAR(10),CONVERT(DATETIME,SUBSTRING(FECCAL1,1,4)+'-'+SUBSTRING(FECCAL1,5,2)+'-'+SUBSTRING(FECCAL1,7,2)),103)END AS FECCAL1,
SUBSTRING(HORCAL1,1,2)+':'+SUBSTRING(HORCAL1,3,2)AS HORCAL1,
FECCAL2,
HORCAL2,
LATGRA+'°'+LATMIN+'´'+'00´´ '+'S'  AS LATITUD,
LONGRA+'°'+LONMIN +'´'+'00´´ '+'O' AS LONGITUD
INTO #FINAL
FROM prd.ZTPP_INFOR_FLOTA A (nolock) -- select * from prd.ZTPP_INFOR_FLOTA
INNER JOIN prd.ZTPP_CALAS B (nolock) ON A.MANDT=B.MANDT AND A.NUMINF=B.NUMINF
INNER JOIN prd.MARA C (nolock) ON A.MANDT=C.MANDT AND A.MATNR=C.MATNR -- TABLA MATERIAL
WHERE TIPINF='P'AND A.MATNR='000000000016000000'
--AND MATRICULA='16660' AND A.NUMINF IN ('026968')
AND MATRICULA=@MATRICULA AND A.NUMINF IN (@NUMINF)


CREATE TABLE #NUMCALA
(NUMCALA CHAR(3) COLLATE SQL_Latin1_General_CP850_BIN2 NULL)

INSERT INTO #NUMCALA(NUMCALA)
VALUES ('001')
INSERT INTO #NUMCALA(NUMCALA)
VALUES ('002')
INSERT INTO #NUMCALA(NUMCALA)
VALUES ('003')
INSERT INTO #NUMCALA(NUMCALA)
VALUES ('004')
INSERT INTO #NUMCALA(NUMCALA)
VALUES ('005')
INSERT INTO #NUMCALA(NUMCALA)
VALUES ('006')
INSERT INTO #NUMCALA(NUMCALA)
VALUES ('007')
INSERT INTO #NUMCALA(NUMCALA)
VALUES ('008')
INSERT INTO #NUMCALA(NUMCALA)
VALUES ('009')
INSERT INTO #NUMCALA(NUMCALA)
VALUES ('010')
INSERT INTO #NUMCALA(NUMCALA)
VALUES ('011')

SELECT DISTINCT NUMINF,NUMCALA,MANDT,TIPINF,WERKS,MATRICULA,EMBARC,ARMADOR 
INTO #INFO_CALA
FROM #FINAL
ORDER BY NUMINF,NUMCALA

SELECT A.NUMINF,B.NUMCALA,A.MANDT,A.MATRICULA,A.TIPINF,A.WERKS,A.ARMADOR,A.EMBARC 
INTO #UNION
FROM #INFO_CALA A
CROSS JOIN #NUMCALA B

-- Porcentaje juvenil por cala
select t1.NUMINF, t1.NUMCALA
,Porc_Juvenil = (Case
-- 01	ANCHOVETA
when t2.ESPECIE = '01' then (select SUM(t3.CANT) from prd.ZTPP_LONG_INFORF t3 where TALLA < 12 and t1.NUMINF=t3.NUMINF and t1.NUMCALA=t3.NUMCALA)
else SUM(0)
end) / nullif(CAST(SUM(t1.CANT) AS decimal(8,2)),0)
into #juvenil
from prd.ZTPP_LONG_INFORF t1 (nolock)
inner join prd.ZTPP_HOJA_MUESTR (nolock) t2 on t1.NUMINF=t2.NUMINF and t1.NUMCALA=t2.NUMCALA
where t2.ESPECIE = '01'
and t1.NUMINF = @NUMINF
--and t1.NUMINF = '026968'
group by t1.NUMINF, t1.NUMCALA, t2.ESPECIE

SELECT distinct
A.NUMINF,
A.NUMCALA,
A.MANDT,
A.TIPINF,
A.WERKS,
A.MATRICULA,
A.EMBARC,
A.ARMADOR,
B.MATNR,
B.[STATUS],
CASE WHEN B.TBODE IS NULL THEN 0 ELSE TBODE END AS TBODE,
B.FECCAL1,
B.HORCAL1,
B.FECCAL2,
B.HORCAL2,
B.LATITUD,
B.LONGITUD,
D.PTOINS +'-'+D.MATRICULA+'-'+D.TCALADO AS Matricula_Completa
,CASE WHEN C.Porc_Juvenil IS NULL THEN 0 ELSE C.Porc_Juvenil END AS Porc_Juvenil
FROM #UNION A
LEFT OUTER JOIN #FINAL B ON A.NUMINF=B.NUMINF AND A.NUMCALA=B.NUMCALA
LEFT JOIN #juvenil C ON A.NUMINF= C.NUMINF and A.NUMCALA = C.NUMCALA
LEFT JOIN prd.ZTPP_EMBARC_OFIC D (NOLOCK) ON A.MATRICULA = D.MATRICULA
ORDER BY NUMINF,NUMCALA;

drop table #FINAL
drop table #INFO_CALA
drop table #UNION
drop table #NUMCALA
drop table #juvenil


