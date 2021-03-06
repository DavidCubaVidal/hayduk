ALTER PROCEDURE [dbo].[USP_PBI_APROVECHAMIENTO_GRASAS] -- exec USP_PBI_APROVECHAMIENTO_GRASAS
AS
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

DECLARE @DESDE DATETIME
		--@HASTA DATETIME,
		--@CENTRO VARCHAR(10)
SET @DESDE='2015-01-01'
--SET @HASTA='2016-01-07'	
--SET @CENTRO='H106'

CREATE TABLE #EFICIENCIA(
COD_PLANTA VARCHAR(4)NULL,
PLANTA VARCHAR(15)NULL,
FECHA_PROD DATETIME NULL,
CONSUMO_MP decimal(10,2)NULL,
HUMEDAD_MP decimal(10,2)NULL,
GRASA_MP decimal(10,2)NULL,
SOLIDO_MP decimal(10,2)NULL,
TM_SOLIDOS_MP decimal(10,2)NULL,
TM_GRASA_MP decimal(10,2)NULL,
PRODUCCION_HARINA decimal(10,2)NULL,
GRASA_HARINA decimal(10,2)NULL,
HUMEDAD_HARINA decimal(10,2)NULL,
SOLIDO_HARINA decimal(10,2)NULL,
TM_SOLIDOS_HARINA decimal(10,2)NULL,
TM_GRASA_HARINA decimal(10,2)NULL,
PRODUCCION_ACEITE decimal(10,2)null,
SOLIDO_ACEITE decimal(10,2)null,
GRASA_ACEITE decimal(10,2)null,
ACEITE_TM decimal(10,2)null
)


select distinct a.MANDT, a.MATNR,a.MAKTX  
into #CONSUMO_MP
from STAGE_SAP_PRD.dbo.MATERIAL a
where MATNR='000000000016000000'

select 
a.WERKS_I,
b.NAME2,
CONVERT(DATETIME,SUBSTRING(a.BUDAT,1,4)+'-'+SUBSTRING(a.BUDAT,5,2)+'-'+SUBSTRING(a.BUDAT,7,2))AS FECHA_PROD,
a.MATNR_I,
a.CHARG_I,
a.MENGE_I,
a.SHKZG_I,
a.MEINS_I,
a.AUFNR_I
INTO #CONSUMO
from  STAGE_SAP_PRD.dbo.DOCUMENTO_MATERIAL a
INNER JOIN STAGE_SAP_PRD.dbo.CENTRO b on a.WERKS_I=b.WERKS and a.MANDT=b.MANDT
inner join #CONSUMO_MP  c on a.MANDT =c.MANDT and a.MATNR_I=c.MATNR
WHERE 
a.BWART_I in ('261','262')       -- Clase de Movimiento para Traslado a Centro.
and LGORT_I = '1150'			 -- Almacen de Harina
and 
CONVERT(DATETIME,SUBSTRING(a.BUDAT,1,4)+'-'+SUBSTRING(a.BUDAT,5,2)+'-'+SUBSTRING(a.BUDAT,7,2))
--BETWEEN '2015-11-10' AND '2015-11-23' AND a.WERKS_I='H105'
>=@DESDE -- BETWEEN @DESDE AND @HASTA AND a.WERKS_I=@CENTRO
--BETWEEN '2015-04-01' AND '2015-07-31' 

SELECT WERKS_I,NAME2,FECHA_PROD,MATNR_I,CHARG_I,MEINS_I,AUFNR_I,
RTRIM(LTRIM(MATNR_I))+RTRIM(LTRIM(CHARG_I))AS MATERIAL_LOTE,
sum(Case when SHKZG_I = 'S' then convert(numeric(20,4),MENGE_I * -1) 
	else CONVERT(numeric(20,4),MENGE_I) end)AS CONSUMO
INTO #HASTAAL
FROM #CONSUMO
GROUP BY WERKS_I,NAME2,FECHA_PROD,MATNR_I,CHARG_I,MEINS_I,AUFNR_I

SELECT a.WERKS_I,a.NAME2,a.FECHA_PROD,a.MATNR_I,a.CHARG_I,
a.MEINS_I,a.AUFNR_I,a.MATERIAL_LOTE,
CASE WHEN a.CONSUMO=0 THEN NULL ELSE a.CONSUMO END AS CONSUMO,
PP_HUMEDAD=
CONVERT(NUMERIC(18,2),(SELECT PP_HUMEDAD FROM STAGE_SAP_PRD.dbo.SECCION_1 X WHERE (a.MATERIAL_LOTE)=X.MATERIAL_LOTE)), 
PP_GRASA=
CONVERT(NUMERIC(18,2),(SELECT PP_GRASA FROM STAGE_SAP_PRD.dbo.SECCION_1 X WHERE (a.MATERIAL_LOTE)=X.MATERIAL_LOTE))
INTO #HASTAAL1
FROM #HASTAAL a
WHERE CONSUMO>0

SELECT WERKS_I,NAME2,FECHA_PROD,MATNR_I,CHARG_I,CONSUMO,PP_HUMEDAD,PP_GRASA,
(CONSUMO*PP_HUMEDAD)AS MULT_HUMEDAD,(CONSUMO*PP_GRASA)AS MULT_GRASA 
INTO #HASTAAL2
FROM #HASTAAL1


SELECT WERKS_I,NAME2,FECHA_PROD,SUM(CONSUMO)as CONSUMO,SUM(MULT_HUMEDAD)AS MULT_HUMEDAD,
SUM(MULT_GRASA)AS MULT_GRASA 
INTO #HASTAAL3
FROM #HASTAAL2
GROUP BY WERKS_I,NAME2,FECHA_PROD,MATNR_I

SELECT WERKS_I,NAME2,FECHA_PROD,CONSUMO,MULT_HUMEDAD/CONSUMO AS HUMEDAD,MULT_GRASA/CONSUMO AS GRASA 
into #HASTAAL4
FROM #HASTAAL3

SELECT WERKS_I,NAME2,FECHA_PROD,CONSUMO,HUMEDAD,GRASA,(100-HUMEDAD-GRASA)AS SOLIDO,
(CONSUMO*((100-HUMEDAD-GRASA)))/100 AS TM_SOLIDOS_MP,
convert(numeric(10,2),((convert(numeric(10,2),GRASA))/100)*CONSUMO) AS TM_GRASA_MP
INTO #MP
FROM #HASTAAL4

INSERT INTO #EFICIENCIA(
COD_PLANTA,PLANTA,FECHA_PROD,CONSUMO_MP,HUMEDAD_MP,GRASA_MP,SOLIDO_MP,TM_SOLIDOS_MP,TM_GRASA_MP,
PRODUCCION_HARINA,GRASA_HARINA,HUMEDAD_HARINA,SOLIDO_HARINA,TM_SOLIDOS_HARINA,TM_GRASA_HARINA,
PRODUCCION_ACEITE,SOLIDO_ACEITE,GRASA_ACEITE,ACEITE_TM)
SELECT WERKS_I,NAME2,FECHA_PROD,CONSUMO,HUMEDAD,GRASA,SOLIDO,TM_SOLIDOS_MP,TM_GRASA_MP,
null,null,null,null,null,null,null,null,null,null
FROM #MP

--PRODUCCION HARINA
--OBTENIENDO GRASA Y HUMEDAD DE LOTES DE INSPECCION

SELECT MANDT,OBJNR,STAT 
into #DOC_ANULADOS
FROM STAGE_SAP_PRD.dbo.ESTADO_OBJETO
WHERE STAT='LOTA'

SELECT PASTRTERM,PAENDTERM,CHARG,LOSMENGE,GESSTICHPR,MANDANT,PRUEFLOS,WERK,ART,OBJNR,
OBTYP,MATNR,AUFPL,KTEXTLOS,
STAT=(SELECT STAT FROM #DOC_ANULADOS B WHERE A.MANDANT=B.MANDT AND A.OBJNR=B.OBJNR)
INTO #REGISTRO_INSPECCION1
FROM STAGE_SAP_PRD.dbo.LOTE_INSPECCION A
where A.MATNR in ('000000000010000004','000000000010000003')
and A.ART='89'AND A.MANDANT='300'
--and A.AUFPL<>'0000000000'
--and A.PRUEFLOS IN('890000000940','890000001331')
--and WERK='H105'
--and CHARG='H105140002'
and AUFPL<>'0000000000'
ORDER BY A.PASTRTERM

--QALS_D02

select  A.MANDANT, A.PRUEFLOS, A.VORGLFNR, A.MERKNR, A.QPMK_WERKS,B.KTEXTLOS, 
A.VERWMERKM, A.KURZTEXT, A.MASSEINHSW, MKVERSION,B.PASTRTERM,B.CHARG,B.LOSMENGE 
INTO #CARACTERISTICAS
from STAGE_SAP_PRD.dbo.GESTION_INSPECCION A
inner join #REGISTRO_INSPECCION1 B on A.MANDANT = B.MANDANT and A.PRUEFLOS = B.PRUEFLOS
AND A.QPMK_WERKS=B.WERK
WHERE B.STAT IS NULL

SELECT 
A.*, 
B.MITTELWERT
into #TEMPO
from #CARACTERISTICAS A
LEFT OUTER JOIN STAGE_SAP_PRD.dbo.RESULTADOS_GESTION_INSPECCION B on A.MANDANT = B.MANDANT and A.PRUEFLOS = B.PRUEFLOS 
and A.VORGLFNR = B.VORGLFNR and A.MERKNR = B.MERKNR
WHERE KTEXTLOS<>''

SELECT MANDANT,PRUEFLOS,VORGLFNR,
QPMK_WERKS,KTEXTLOS,MASSEINHSW,MKVERSION,PASTRTERM,
CHARG,LOSMENGE,
[% HUMEDAD],[% GRASA]
INTO #HASTAAL149
FROM
(SELECT MANDANT,PRUEFLOS,VORGLFNR,
QPMK_WERKS,KTEXTLOS,MASSEINHSW,MKVERSION,PASTRTERM,
CHARG,LOSMENGE,KURZTEXT,MITTELWERT
    FROM #TEMPO) AS SourceTable
PIVOT
(
MIN(MITTELWERT)
FOR KURZTEXT IN ([% HUMEDAD],[% GRASA])
) AS PivotTable

SELECT MANDANT,PRUEFLOS,VORGLFNR,QPMK_WERKS,KTEXTLOS,MASSEINHSW,MKVERSION,
CONVERT(DATETIME,SUBSTRING(PASTRTERM,1,4)+'-'+SUBSTRING(PASTRTERM,5,2)+'-'+SUBSTRING(PASTRTERM,7,2))
AS PASTRTERM,CHARG,LOSMENGE,[% HUMEDAD],[% GRASA]
INTO #HASTAAL150
FROM #HASTAAL149

SELECT MAX(PASTRTERM)AS FECHA,KTEXTLOS,MANDANT,CHARG,QPMK_WERKS 
INTO #AGRUPACION
FROM #HASTAAL150
--WHERE KTEXTLOS='4900531359'
GROUP BY KTEXTLOS,MANDANT,CHARG,QPMK_WERKS 

SELECT B.* 
INTO #HASTAAL151
FROM #AGRUPACION A
INNER JOIN #HASTAAL150 B ON A.CHARG=B.CHARG AND A.FECHA=B.PASTRTERM AND A.MANDANT=B.MANDANT
AND A.QPMK_WERKS=B.QPMK_WERKS AND A.KTEXTLOS=B.KTEXTLOS

--OBTENIENDO PRODUCCION

select distinct a.MANDT, a.MATNR      
into #HARINA    
from STAGE_SAP_PRD.dbo.MATERIAL a    
where MATKL = '002.010'    
    
select distinct MBLNR,WERKS_I,BUDAT,BWART_I, MATNR_I, CHARG_I,SHKZG_I,MEINS_I,MENGE_I,  A.AUFNR_I,  
MJAHR_I,ZEILE_I     
into #PT    
from STAGE_SAP_PRD.dbo.DOCUMENTO_MATERIAL A    
INNER JOIN #HARINA B ON A.MANDT=B.MANDT AND A.MATNR_I=B.MATNR    
where    
BWART_I='131'    
and LGORT_I = '1150'    
--and WERKS_I='H101'     
and SUBSTRING(BLDAT,1,4)>=2013    
    
--QUITANDO ANULADOS    
    
SELECT MANDT_I,SJAHR_I,SMBLN_I,SMBLP_I, A.AUFNR_I     
INTO #ANULADOS    
FROM STAGE_SAP_PRD.dbo.DOCUMENTO_MATERIAL A    
INNER JOIN #HARINA B ON A.MANDT=B.MANDT AND A.MATNR_I=B.MATNR    
where    
BWART_I=('132')    
and LGORT_I = '1150'    
    
SELECT A.MBLNR,A.WERKS_I AS COD_PLANTA,A.BUDAT,A.BWART_I,A.MATNR_I,A.CHARG_I,A.SHKZG_I,A.MEINS_I,A.MENGE_I, 
A.AUFNR_I,
CONVERT(DATETIME,SUBSTRING(BUDAT,1,4)+'-'+SUBSTRING(BUDAT,5,2)+'-'+SUBSTRING(BUDAT,7,2))AS
FECHA_PRODUCCION,    
A.MJAHR_I,A.ZEILE_I     
INTO #SIN_ANULADOS    
FROM #PT A    
WHERE NOT EXISTS(SELECT 1 FROM #ANULADOS B WHERE A.MBLNR=B.SMBLN_I AND A.MJAHR_I=B.SJAHR_I AND A.ZEILE_I=B.SMBLP_I)    

SELECT B.KTEXT,A.* 
INTO #SIN_ANULADOS1
FROM #SIN_ANULADOS	A
INNER JOIN STAGE_SAP_PRD.dbo.ORDEN_FABRICACION B ON A.AUFNR_I=B.AUFNR
WHERE B.KTEXT NOT LIKE '%Residuos%'
--and A.MBLNR='4900513169'


SELECT 
'300'AS MANDANT,A.PRUEFLOS,A.VORGLFNR,B.COD_PLANTA,
B.MBLNR AS KTEXTLOS,
A.MASSEINHSW,A.MKVERSION,A.PASTRTERM,B.CHARG_I as LOTE_PT,B.MENGE_I as PRODUCCION,
A.[% HUMEDAD]AS HUMEDAD,
A.[% GRASA]AS GRASA,
B.FECHA_PRODUCCION,B.MATNR_I,B.BWART_I,B.SHKZG_I,B.MEINS_I,B.MJAHR_I,B.ZEILE_I,
(A.LOSMENGE*50)/1000 as TM,
((A.LOSMENGE*50)/1000)*A.[% GRASA] as RATIOGRASA,
((A.LOSMENGE*50)/1000)*A.[% HUMEDAD] AS RATIOHUMEDAD,
CASE WHEN PRUEFLOS IS NULL THEN 0 ELSE 1 END AS TIPO
INTO #HASTAAL152
FROM #HASTAAL151 A
RIGHT OUTER JOIN #SIN_ANULADOS1 B ON A.KTEXTLOS=B.MBLNR AND A.QPMK_WERKS=B.COD_PLANTA
AND A.CHARG=B.CHARG_I
WHERE 
--B.FECHA_PRODUCCION BETWEEN '2015-04-01' AND '2015-07-31'  
--and COD_PLANTA='H105'
 B.FECHA_PRODUCCION >=@DESDE -- BETWEEN @DESDE AND @HASTA and B.COD_PLANTA=@CENTRO
--and (A.[% HUMEDAD]IS NOT NULL AND A.[% GRASA]IS NOT NULL)

--890000000940 ANULADO

SELECT MANDANT,COD_PLANTA,FECHA_PRODUCCION,LOTE_PT,PRODUCCION,HUMEDAD,GRASA,TM,
RATIOGRASA,RATIOHUMEDAD,TIPO 
INTO #HASTAAL153
FROM #HASTAAL152

SELECT MANDANT,COD_PLANTA,B.NAME2,FECHA_PRODUCCION,
convert(numeric(10,2),SUM(PRODUCCION)*50/1000)AS TM,
convert(numeric(10,2),SUM(PRODUCCION))AS SAC,
CONVERT(NUMERIC(10,2),SUM(RATIOGRASA)/SUM(TM))AS GRASA,
CONVERT(NUMERIC(10,2),SUM(RATIOHUMEDAD)/SUM(TM))AS HUMEDAD 
INTO #HASTAAL154
FROM #HASTAAL153 A
INNER JOIN STAGE_SAP_PRD.dbo.CENTRO B ON A.COD_PLANTA=B.WERKS AND A.MANDANT=B.MANDT
GROUP BY MANDANT,COD_PLANTA,FECHA_PRODUCCION,NAME2


INSERT INTO #EFICIENCIA(
COD_PLANTA,PLANTA,FECHA_PROD,CONSUMO_MP,HUMEDAD_MP,GRASA_MP,SOLIDO_MP,TM_SOLIDOS_MP,TM_GRASA_MP,
PRODUCCION_HARINA,GRASA_HARINA,HUMEDAD_HARINA,SOLIDO_HARINA,TM_SOLIDOS_HARINA,TM_GRASA_HARINA,
PRODUCCION_ACEITE,SOLIDO_ACEITE,GRASA_ACEITE,ACEITE_TM)
SELECT COD_PLANTA,NAME2,FECHA_PRODUCCION,null,null,null,null,null,null,
TM AS PRODUCCION_HARINA,GRASA AS GRASA_HARINA,HUMEDAD AS HUMEDAD_HARINA,
(100-GRASA-HUMEDAD)AS SOLIDO_HARINA,
convert(numeric(10,2),((100-GRASA-HUMEDAD)*TM)/100) AS TM_SOLIDOS_HARINA,
CONVERT(numeric(10,2),(GRASA*TM)/100) AS TM_GRASA_HARINA,
NULL,NULL,NULL,NULL
FROM #HASTAAL154

--PRODUCCION ACEITE
select a.MANDT, a.MATNR      
into #ACEITE    
from STAGE_SAP_PRD.dbo.MATERIAL a    
where MATNR IN ('000000000010000001')
--MATKL = '002.020'    
   
select distinct MBLNR,WERKS_I,BUDAT,BWART_I, MATNR_I, CHARG_I,SHKZG_I,MEINS_I,MENGE_I,    
MJAHR_I,ZEILE_I,AUFNR_I     
into #PT100    
from STAGE_SAP_PRD.dbo.DOCUMENTO_MATERIAL A    
INNER JOIN #ACEITE B ON A.MANDT=B.MANDT AND A.MATNR_I=B.MATNR    
where    
BWART_I='531'    
and LGORT_I = '1150'    
--and WERKS_I='H101'     
and SUBSTRING(BLDAT,1,4)>=2013    
        
--QUITANDO ANULADOS    
    
SELECT MANDT_I,SJAHR_I,SMBLN_I,SMBLP_I,A.AUFNR_I     
INTO #ANULADOS100    
FROM STAGE_SAP_PRD.dbo.DOCUMENTO_MATERIAL A    
INNER JOIN #ACEITE B ON A.MANDT=B.MANDT AND A.MATNR_I=B.MATNR    
where    
BWART_I=('532')    
and LGORT_I = '1150'    

    
SELECT A.MBLNR,A.WERKS_I AS COD_CENTRO,A.BUDAT,
CONVERT(DATETIME,SUBSTRING(BUDAT,1,4)+'-'+SUBSTRING(BUDAT,5,2)+'-'+SUBSTRING(BUDAT,7,2))AS FECHA_PRODUCCION,
A.BWART_I,A.MATNR_I,A.CHARG_I AS LOTE_PT,
A.SHKZG_I,A.MEINS_I,A.MENGE_I AS TM,
RTRIM(LTRIM(A.MATNR_I))+RTRIM(LTRIM(A.CHARG_I))AS COD_MATERIAL_LOTE,    
A.MJAHR_I,A.ZEILE_I,A.AUFNR_I     
INTO #SIN_ANULADOS100    
FROM #PT100 A    
WHERE NOT EXISTS(SELECT 1 FROM #ANULADOS100 B WHERE A.MBLNR=B.SMBLN_I AND A.MJAHR_I=B.SJAHR_I 
					AND A.ZEILE_I=B.SMBLP_I) 
					

--ASOCIANDO CON CARACTERISTICAS DE ACEITE
         
SELECT MBLNR,COD_CENTRO as COD_PLANTA,BUDAT,FECHA_PRODUCCION,BWART_I,MATNR_I,LOTE_PT,
SHKZG_I,MEINS_I,TM AS CANTIDAD_SACOS,COD_MATERIAL_LOTE,MJAHR_I,ZEILE_I,AUFNR_I,
QM_HUMEDAD=(SELECT QM_HUMEDAD FROM STAGE_SAP_PRD.dbo.CARACTERISTICAS_ACEITE B WHERE A.COD_MATERIAL_LOTE=B.COD_MATERIAL_LOTE),
QM_SOLIDOS=(SELECT QM_SOLIDOS FROM STAGE_SAP_PRD.dbo.CARACTERISTICAS_ACEITE B WHERE A.COD_MATERIAL_LOTE=B.COD_MATERIAL_LOTE),
QM_ACIDEZ=(SELECT QM_ACIDEZ FROM STAGE_SAP_PRD.dbo.CARACTERISTICAS_ACEITE B WHERE A.COD_MATERIAL_LOTE=B.COD_MATERIAL_LOTE)  
INTO #HASTAAL60
FROM #SIN_ANULADOS100 A
WHERE FECHA_PRODUCCION >=@DESDE --BETWEEN @DESDE AND @HASTA and COD_CENTRO=@CENTRO
--WHERE FECHA_PRODUCCION between'2015-11-18'AND '2015-11-18' and COD_CENTRO='H106'    

SELECT 
A.COD_PLANTA,B.NAME2 AS PLANTA,
FECHA_PRODUCCION,LOTE_PT,CANTIDAD_SACOS AS TM,
convert(numeric(10,2),QM_HUMEDAD)as HUMEDAD,
convert(numeric(10,2),QM_SOLIDOS)as SOLIDOS
--(100-convert(numeric(10,2),QM_HUMEDAD)-convert(numeric(10,2),QM_SOLIDOS))as GRASA
INTO #HASTAAL45
FROM #HASTAAL60 A
INNER JOIN STAGE_SAP_PRD.dbo.CENTRO B ON A.COD_PLANTA=B.WERKS

SELECT COD_PLANTA,PLANTA,FECHA_PRODUCCION,LOTE_PT,TM,(HUMEDAD*TM)AS HUMEDAD_TM,
SOLIDOS*TM AS SOLIDOS_TM 
INTO #HASTAAL46
FROM #HASTAAL45

SELECT COD_PLANTA,PLANTA,FECHA_PRODUCCION,
convert(numeric(10,2),(SUM(HUMEDAD_TM)/SUM(TM)))AS HUMEDAD,
convert(numeric(10,2),(SUM(SOLIDOS_TM)/SUM(TM)))AS SOLIDOS,
SUM(TM)AS TM 
INTO #HASTAAL47
FROM #HASTAAL46
GROUP BY COD_PLANTA,PLANTA,FECHA_PRODUCCION

SELECT COD_PLANTA,PLANTA,FECHA_PRODUCCION,
TM,HUMEDAD,SOLIDOS,
(100-HUMEDAD-SOLIDOS)AS GRASA,
convert(numeric(10,2),((100-HUMEDAD-SOLIDOS)/100)*TM) AS ACEITE_TM
INTO #HASTAAL48
FROM #HASTAAL47

INSERT INTO #EFICIENCIA(
COD_PLANTA,PLANTA,FECHA_PROD,CONSUMO_MP,HUMEDAD_MP,GRASA_MP,SOLIDO_MP,TM_SOLIDOS_MP,TM_GRASA_MP,
PRODUCCION_HARINA,GRASA_HARINA,HUMEDAD_HARINA,SOLIDO_HARINA,TM_SOLIDOS_HARINA,TM_GRASA_HARINA,
PRODUCCION_ACEITE,SOLIDO_ACEITE,GRASA_ACEITE,ACEITE_TM)
SELECT COD_PLANTA,PLANTA,FECHA_PRODUCCION,
NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
TM,SOLIDOS,GRASA,ACEITE_TM  
FROM #HASTAAL48

/*SELECT COD_PLANTA,PLANTA,FECHA_PROD,
SUM(CONSUMO_MP)AS CONSUMO_MP,
SUM(HUMEDAD_MP)AS HUMEDAD_MP,
SUM(GRASA_MP)AS GRASA_MP,
SUM(SOLIDO_MP)AS SOLIDO_MP,
SUM(TM_SOLIDOS_MP)AS TM_SOLIDOS_MP,
SUM(TM_GRASA_MP)AS TM_GRASA_MP,
SUM(PRODUCCION_HARINA)AS PRODUCCION_HARINA,
SUM(GRASA_HARINA)AS GRASA_HARINA,
SUM(HUMEDAD_HARINA)AS HUMEDAD_HARINA,
SUM(SOLIDO_HARINA)AS SOLIDO_HARINA,
SUM(TM_SOLIDOS_HARINA)AS TM_SOLIDOS_HARINA,
SUM(TM_GRASA_HARINA)AS TM_GRASA_HARINA,
SUM(PRODUCCION_ACEITE)AS PRODUCCION_ACEITE,
SUM(SOLIDO_ACEITE)AS SOLIDO_ACEITE,
AVG(GRASA_ACEITE)AS GRASA_ACEITE,
SUM(ACEITE_TM)AS ACEITE_TM
INTO #EFICIENCIA1
FROM #EFICIENCIA
GROUP BY COD_PLANTA,PLANTA,FECHA_PROD*/

SELECT COD_PLANTA,PLANTA,FECHA_PROD,
ISNULL(SUM(CONSUMO_MP),0)AS CONSUMO_MP,
ISNULL(SUM(HUMEDAD_MP),0)AS HUMEDAD_MP,
ISNULL(SUM(GRASA_MP),0) AS GRASA_MP,
ISNULL(SUM(SOLIDO_MP),0)AS SOLIDO_MP,
ISNULL(SUM(TM_SOLIDOS_MP),0)AS TM_SOLIDOS_MP,
ISNULL(SUM(TM_GRASA_MP),0)AS TM_GRASA_MP,
ISNULL(SUM(PRODUCCION_HARINA),0)AS PRODUCCION_HARINA,
ISNULL(SUM(GRASA_HARINA),0)AS GRASA_HARINA,
ISNULL(SUM(HUMEDAD_HARINA),0)AS HUMEDAD_HARINA,
ISNULL(SUM(SOLIDO_HARINA),0)AS SOLIDO_HARINA,
ISNULL(SUM(TM_SOLIDOS_HARINA),0)AS TM_SOLIDOS_HARINA,
ISNULL(SUM(TM_GRASA_HARINA),0)AS TM_GRASA_HARINA,
ISNULL(SUM(PRODUCCION_ACEITE),0)AS PRODUCCION_ACEITE,
ISNULL(SUM(SOLIDO_ACEITE),0) AS SOLIDO_ACEITE,
ISNULL(AVG(GRASA_ACEITE),0)AS GRASA_ACEITE,
ISNULL(SUM(ACEITE_TM),0)AS ACEITE_TM
INTO #EFICIENCIA1
FROM #EFICIENCIA
GROUP BY COD_PLANTA,PLANTA,FECHA_PROD


SELECT COD_PLANTA,PLANTA,
CONVERT(VARCHAR(10),FECHA_PROD,103)AS FECHA_PROD,
FECHA_PROD AS FECHA_PROD_D,
CONSUMO_MP,HUMEDAD_MP,GRASA_MP,
SOLIDO_MP,TM_SOLIDOS_MP,TM_GRASA_MP,PRODUCCION_HARINA,GRASA_HARINA,
HUMEDAD_HARINA,SOLIDO_HARINA,
(100-SOLIDO_ACEITE-GRASA_ACEITE)AS HUMEDAD_ACEITE,
TM_SOLIDOS_HARINA,TM_GRASA_HARINA,
(PRODUCCION_ACEITE*SOLIDO_ACEITE)/100 as TM_SOLIDO_ACEITE,
PRODUCCION_ACEITE,SOLIDO_ACEITE,GRASA_ACEITE,ACEITE_TM,99.74 as META,
convert(numeric(10,2),((GRASA_ACEITE/100)* PRODUCCION_ACEITE)) AS TM_GRASA_ACEITE
,CONVERT(numeric(10,2),
CASE WHEN TM_GRASA_MP=0 THEN 0 ELSE 
((((convert(numeric(10,2),GRASA_ACEITE)/100)* PRODUCCION_ACEITE)+TM_GRASA_HARINA)/(TM_GRASA_MP))*100
END ) AS EFICIENCIA_ACEITE_DIARIO
/*
CASE WHEN (TM_GRASA_MP-TM_GRASA_HARINA)=0 THEN 0 
ELSE 
(((GRASA_ACEITE/100)* PRODUCCION_ACEITE)/(TM_GRASA_MP-TM_GRASA_HARINA))*100 END AS EFICIENCIA_ACEITE_DIARIO*/
INTO #EFICIENCIA2
FROM #EFICIENCIA1
ORDER BY FECHA_PROD_D

declare @ResumenEficiencia2 table (
codplanta char(4),
fechaprod varchar(8),
Acumulado decimal(18,4)
)

--insert into @ResumenEficiencia2
--select COD_PLANTA, FECHA_PROD
--from #EFICIENCIA2

IF OBJECT_ID('F_APROVECHAMIENTO_GRASAS', 'U') IS NOT NULL
DROP TABLE F_APROVECHAMIENTO_GRASAS;

SELECT *,
 ( select sum(z.TM_GRASA_ACEITE) from #EFICIENCIA2 z where z.COD_PLANTA = a.COD_PLANTA and z.FECHA_PROD_D <= a.FECHA_PROD_D ) a,
 ( select sum(z.TM_GRASA_MP) from #EFICIENCIA2 z where z.COD_PLANTA = a.COD_PLANTA and z.FECHA_PROD_D <= a.FECHA_PROD_D ) b,
 ( select sum(z.TM_GRASA_HARINA) from #EFICIENCIA2 z where z.COD_PLANTA = a.COD_PLANTA and z.FECHA_PROD_D <= a.FECHA_PROD_D ) c,
 
 ((( select sum(z.TM_GRASA_ACEITE) from #EFICIENCIA2 z where z.COD_PLANTA = a.COD_PLANTA and z.FECHA_PROD_D <= a.FECHA_PROD_D ) +
 ( select sum(z.TM_GRASA_HARINA) from #EFICIENCIA2 z where z.COD_PLANTA = a.COD_PLANTA and z.FECHA_PROD_D <= a.FECHA_PROD_D ))/
 (( select sum(z.TM_GRASA_MP) from #EFICIENCIA2 z where z.COD_PLANTA = a.COD_PLANTA and z.FECHA_PROD_D <= a.FECHA_PROD_D ) ))*100 
 
/*( ( select sum(z.TM_GRASA_ACEITE) from #EFICIENCIA2 z where z.COD_PLANTA = a.COD_PLANTA and z.FECHA_PROD_D <= a.FECHA_PROD_D ) /
( ( select sum(z.TM_GRASA_MP) from #EFICIENCIA2 z where z.COD_PLANTA = a.COD_PLANTA and z.FECHA_PROD_D <= a.FECHA_PROD_D ) - 
( select sum(z.TM_GRASA_HARINA) from #EFICIENCIA2 z where z.COD_PLANTA = a.COD_PLANTA and z.FECHA_PROD_D <= a.FECHA_PROD_D ) ) ) 
* 100*/
as ACUMULADO
INTO F_APROVECHAMIENTO_GRASAS
FROM #EFICIENCIA2 a

DROP TABLE #ACEITE
DROP TABLE #ANULADOS
DROP TABLE #HASTAAL
DROP TABLE #PT
DROP TABLE #SIN_ANULADOS
DROP TABLE #HASTAAL45    
DROP TABLE #AGRUPACION
DROP TABLE #ANULADOS100 
DROP TABLE #CARACTERISTICAS
DROP TABLE #HASTAAL150
DROP TABLE #HASTAAL151
DROP TABLE #HASTAAL152
DROP TABLE #HARINA
DROP TABLE #PT100
DROP TABLE #REGISTRO_INSPECCION1
DROP TABLE #SIN_ANULADOS1
DROP TABLE #TEMPO
DROP TABLE #DOC_ANULADOS
DROP TABLE #HASTAAL153
DROP TABLE #HASTAAL154
DROP TABLE #SIN_ANULADOS100
DROP TABLE #CONSUMO
DROP TABLE #CONSUMO_MP
DROP TABLE #HASTAAL60
DROP TABLE #HASTAAL1
DROP TABLE #HASTAAL149
DROP TABLE #HASTAAL2
DROP TABLE #HASTAAL3
DROP TABLE #HASTAAL4
DROP TABLE #MP
DROP TABLE #HASTAAL46
DROP TABLE #EFICIENCIA
DROP TABLE #EFICIENCIA1
DROP TABLE #HASTAAL47
DROP TABLE #HASTAAL48
DROP TABLE #EFICIENCIA2 -- select * from #EFICIENCIA2



END
