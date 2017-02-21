---- 1. Creamos una temporal para ingresar los informes de flota -----
CREATE TABLE #INFORME_FLOTA
(
MANDT varchar(6) null,
MATRICULA varchar(30) null,
EMBARC varchar(200) null,
Embarcacion varchar(230) null,
WERDES varchar(8) null,
Centro varchar(70) null,
NUMINF varchar(12) null,
TIPINF varchar(2) null,
MATNR varchar(36) null,
especie varchar(100) null,
FECZARP varchar(16) null,
HORZARP varchar(12) null,
FECARRI varchar(16) null,
HORARRI varchar(12) null,
FECDES2 varchar(16) null,
HORDES2 varchar(12) null,
DESTIN varchar(6) null,
DECLARADO decimal(13,3) null,
DESCARGA decimal(13,3) null,
Estado varchar(6) null
)

IF (@paramDestino='CHI')
BEGIN

----2. Ingresamos los informes de flota donde su descarga haya sido en los días seleccionados
INSERT INTO #INFORME_FLOTA
select A.MANDT, A.MATRICULA, A.EMBARC, (A.MATRICULA + ' - ' + A.EMBARC) as Embarcacion ,A.WERDES,
(select min(rtrim(ltrim(x3.WERKS)) + ' - ' + rtrim(ltrim(x3.NAME1))) from prd.T001W x3 (nolock) where A.WERDES = x3.WERKS and A.MANDT = x3.MANDT) as Centro,
A.NUMINF, A.TIPINF, A.MATNR, 
(select min(x2.MAKTX) from prd.MAKT x2 (nolock) where A.MANDT = x2.MANDT and A.MATNR = x2.MATNR and x2.SPRAS = 'S') as especie,
A.FECZARP, A.HORZARP, A.FECARRI, A.HORARRI, A.FECDES2, A.HORDES2, A.DESTIN,
DECLARADO = isnull((select sum(x1.TBODE) from prd.ZTPP_CALAS x1 (nolock)
			     where x1.MANDT = A.MANDT and x1.NUMINF = A.NUMINF 
			     ),0),
DESCARGA = isnull((CASE WHEN A.TIPINF = 'P' THEN (SELECT SUM(z.IGMNG)FROM prd.AFKO z (nolock) where z.MANDT=A.MANDT and z.AUFNR=A.AUFNR)
				 WHEN A.TIPINF = 'T' THEN (SELECT SUM(y.MENGE)FROM prd.EKPO y (nolock) where y.MANDT=A.MANDT and y.EBELN=A.EBELN)
				 ELSE A.GWEMG END),0)
,A.[STATUS] as Estado
from prd.ZTPP_INFOR_FLOTA A (nolock)
where A.MANDT = '300' 
and A.ZARPE = 'X'
and A.PESCA = 'X'
and
(CASE WHEN left(rtrim(ltrim(A.HORDES2)),6) between '000000' and '070000' 
then convert(varchar(8), convert(datetime,A.FECDES2) - 1, 112) else A.FECDES2 end) 
between convert(varchar(8),convert(datetime,@fecha_inicio),112) and convert(varchar(8),convert(datetime,@fecha_fin),112)
--and A.TIPORED in (@paramTipoRed)
and (CASE WHEN A.DESTIN = '' THEN 'X' ELSE A.DESTIN END) in ('CHI')
and A.FECDES2<>'00000000'

IF (convert(varchar(8),convert(datetime,getdate()),112) = convert(varchar(8),convert(datetime,@fecha_fin),112))
BEGIN

INSERT INTO #INFORME_FLOTA
select A.MANDT, A.MATRICULA, A.EMBARC, (A.MATRICULA + ' - ' + A.EMBARC) as Embarcacion ,A.WERDES,
(select min(rtrim(ltrim(x3.WERKS)) + ' - ' + rtrim(ltrim(x3.NAME1))) from prd.T001W x3 (nolock) where A.WERDES = x3.WERKS and A.MANDT = x3.MANDT) as Centro,
A.NUMINF, A.TIPINF, A.MATNR, 
(select min(x2.MAKTX) from prd.MAKT x2 (nolock) where A.MANDT = x2.MANDT and A.MATNR = x2.MATNR and x2.SPRAS = 'S') as especie,
A.FECZARP, A.HORZARP, A.FECARRI, A.HORARRI, A.FECDES2, A.HORDES2, A.DESTIN,
DECLARADO = isnull((select sum(x1.TBODE) from prd.ZTPP_CALAS x1 (nolock)
			     where x1.MANDT = A.MANDT and x1.NUMINF = A.NUMINF 
			     ),0),
DESCARGA = isnull((CASE WHEN A.TIPINF = 'P' THEN (SELECT SUM(z.IGMNG)FROM prd.AFKO z (nolock) 
                 where z.MANDT=A.MANDT and z.AUFNR=A.AUFNR)
				 WHEN A.TIPINF = 'T' THEN (SELECT SUM(y.MENGE)FROM prd.EKPO y (nolock) 
				 where y.MANDT=A.MANDT and y.EBELN=A.EBELN)
				 ELSE A.GWEMG END),0)
,A.[STATUS] as Estado
from prd.ZTPP_INFOR_FLOTA A (nolock)
where A.MANDT = '300' 
and A.AUFNR = ''  -- Sin Orden de Fabricacion
and A.EBELN = ''  -- Sin Orden de Compra
and A.TZARPE = '01' -- Motivo de Zarpe para Pesca
and A.ZARPE = 'X'	  -- Indica que Zarpo
--and A.PESCA = 'X'	  -- Indica que Pesco
--and A.WERDES <> ''  -- Indica que han llenado el centro de descarga
--and A.FECARRI <> '00000000'
--and A.TIPORED in (@paramTipoRed)
and (CASE WHEN A.DESTIN = '' THEN 'X' ELSE A.DESTIN END) in ('CHI')
END
END
ELSE 

IF(@paramDestino='CHD')
BEGIN
INSERT INTO #INFORME_FLOTA
select A.MANDT, A.MATRICULA, A.EMBARC, (A.MATRICULA + ' - ' + A.EMBARC) as Embarcacion ,A.WERDES,
(select min(rtrim(ltrim(x3.WERKS)) + ' - ' + rtrim(ltrim(x3.NAME1))) from prd.T001W x3 (nolock) where A.WERDES = x3.WERKS and A.MANDT = x3.MANDT) as Centro,
A.NUMINF, A.TIPINF, A.MATNR, 
(select min(x2.MAKTX) from prd.MAKT x2 (nolock) where A.MANDT = x2.MANDT and A.MATNR = x2.MATNR and x2.SPRAS = 'S') as especie,
A.FECZARP, A.HORZARP, A.FECARRI, A.HORARRI, A.FECDES2, A.HORDES2, A.DESTIN,
DECLARADO = isnull((select sum(x1.TBODE) from prd.ZTPP_CALAS x1 (nolock)
			     where x1.MANDT = A.MANDT and x1.NUMINF = A.NUMINF 
			     ),0),
DESCARGA = isnull((CASE WHEN A.TIPINF = 'P' THEN (SELECT SUM(z.IGMNG)FROM prd.AFKO z (nolock) where z.MANDT=A.MANDT and z.AUFNR=A.AUFNR)
				 WHEN A.TIPINF = 'T' THEN (SELECT SUM(y.MENGE)FROM prd.EKPO y (nolock) where y.MANDT=A.MANDT and y.EBELN=A.EBELN)
				 ELSE A.GWEMG END),0)
,A.[STATUS] as Estado
from prd.ZTPP_INFOR_FLOTA A (nolock)
where A.MANDT = '300' 
and A.ZARPE = 'X'
and A.PESCA = 'X'
and
(CASE WHEN left(rtrim(ltrim(A.HORARRI)),6) between '000000' and '070000'AND A.FECARRI<>'00000000' 
then convert(varchar(8), convert(datetime,A.FECARRI), 112) else A.FECARRI end) 
between convert(varchar(8),convert(datetime,@fecha_inicio),112) 
and convert(varchar(8),convert(datetime,@fecha_fin),112)
--and A.TIPORED in (@paramTipoRed)
and (CASE WHEN A.DESTIN = '' THEN 'X' ELSE A.DESTIN END) in ('CHD')
--and A.FECDES2<>'00000000'

IF CONVERT(DATETIME,((convert(varchar(10),convert(datetime,getdate()),120))))<= 
	CONVERT(DATETIME,((convert(varchar(10),convert(datetime,@fecha_fin),120))))
--IF (convert(varchar(8),convert(datetime,getdate()),112) >= convert(varchar(8),convert(datetime,@fecha_fin),112))
BEGIN

INSERT INTO #INFORME_FLOTA
select A.MANDT, A.MATRICULA, A.EMBARC, (A.MATRICULA + ' - ' + A.EMBARC) as Embarcacion ,A.WERDES,
(select min(rtrim(ltrim(x3.WERKS)) + ' - ' + rtrim(ltrim(x3.NAME1))) from prd.T001W x3 (nolock) where A.WERDES = x3.WERKS and A.MANDT = x3.MANDT) as Centro,
A.NUMINF, A.TIPINF, A.MATNR, 
(select min(x2.MAKTX) from prd.MAKT x2 (nolock) where A.MANDT = x2.MANDT and A.MATNR = x2.MATNR and x2.SPRAS = 'S') as especie,
A.FECZARP, A.HORZARP, A.FECARRI, A.HORARRI, A.FECDES2, A.HORDES2, A.DESTIN,
DECLARADO = isnull((select sum(x1.TBODE) from prd.ZTPP_CALAS x1 (nolock)
			     where x1.MANDT = A.MANDT and x1.NUMINF = A.NUMINF 
			     ),0),
DESCARGA = isnull((CASE WHEN A.TIPINF = 'P' THEN (SELECT SUM(z.IGMNG)FROM prd.AFKO z (nolock) 
                 where z.MANDT=A.MANDT and z.AUFNR=A.AUFNR)
				 WHEN A.TIPINF = 'T' THEN (SELECT SUM(y.MENGE)FROM prd.EKPO y (nolock) 
				 where y.MANDT=A.MANDT and y.EBELN=A.EBELN)
				 ELSE A.GWEMG END),0)
,A.[STATUS] as Estado
from prd.ZTPP_INFOR_FLOTA A (nolock)
where A.MANDT = '300' 
--and A.AUFNR = ''  -- Sin Orden de Fabricacion
--and A.EBELN = ''  -- Sin Orden de Compra
and A.TZARPE = '01' -- Motivo de Zarpe para Pesca
and A.ZARPE = 'X'	  -- Indica que Zarpo
and A.PESCA = 'X'	  -- Indica que Pesco
--and A.WERDES <> ''  -- Indica que han llenado el centro de descarga
--and A.FECARRI <> '00000000'
--and A.TIPORED in (@paramTipoRed)
and (case when (A.FECARRI<>'00000000') then
CONVERT(DATETIME,((convert(varchar(10),convert(datetime,A.FECARRI),120))))else 0 end>=
CONVERT(DATETIME,((convert(varchar(10),convert(datetime,@fecha_fin),120))))OR A.FECARRI='00000000')
and (CASE WHEN A.DESTIN = '' THEN 'X' ELSE A.DESTIN END) in ('CHD')

END
ELSE 
IF  
	CONVERT(DATETIME,((convert(varchar(10),convert(datetime,@fecha_fin),120))))<
	CONVERT(DATETIME,((convert(varchar(10),convert(datetime,getdate()),120))))
BEGIN
INSERT INTO #INFORME_FLOTA
select A.MANDT, A.MATRICULA, A.EMBARC, (A.MATRICULA + ' - ' + A.EMBARC) as Embarcacion ,A.WERDES,
(select min(rtrim(ltrim(x3.WERKS)) + ' - ' + rtrim(ltrim(x3.NAME1))) from prd.T001W x3 (nolock) where A.WERDES = x3.WERKS and A.MANDT = x3.MANDT) as Centro,
A.NUMINF, A.TIPINF, A.MATNR, 
(select min(x2.MAKTX) from prd.MAKT x2 (nolock) where A.MANDT = x2.MANDT and A.MATNR = x2.MATNR and x2.SPRAS = 'S') as especie,
A.FECZARP, A.HORZARP, A.FECARRI, A.HORARRI, A.FECDES2, A.HORDES2, A.DESTIN,
DECLARADO = isnull((select sum(x1.TBODE) from prd.ZTPP_CALAS x1 (nolock)
			     where x1.MANDT = A.MANDT and x1.NUMINF = A.NUMINF 
			     ),0),
DESCARGA = isnull((CASE WHEN A.TIPINF = 'P' THEN (SELECT SUM(z.IGMNG)FROM prd.AFKO z (nolock) 
                 where z.MANDT=A.MANDT and z.AUFNR=A.AUFNR)
				 WHEN A.TIPINF = 'T' THEN (SELECT SUM(y.MENGE)FROM prd.EKPO y (nolock) 
				 where y.MANDT=A.MANDT and y.EBELN=A.EBELN)
				 ELSE A.GWEMG END),0)
,A.[STATUS] as Estado
from prd.ZTPP_INFOR_FLOTA A (nolock)
where A.MANDT = '300' 
--and A.AUFNR = ''  -- Sin Orden de Fabricacion
--and A.EBELN = ''  -- Sin Orden de Compra
and A.TZARPE = '01' -- Motivo de Zarpe para Pesca
and A.ZARPE = 'X'	  -- Indica que Zarpo
and A.PESCA = 'X'	  -- Indica que Pesco
--and A.WERDES <> ''  -- Indica que han llenado el centro de descarga
and A.FECARRI <> '00000000'
and (CASE WHEN A.DESTIN = '' THEN 'X' ELSE A.DESTIN END) in ('CHD')
--and A.TIPORED in (@paramTipoRed)
and ( 
CONVERT(DATETIME,((convert(varchar(10),convert(datetime,@fecha_fin),120))))=
case when (A.FECARRI<>'00000000') then
CONVERT(DATETIME,((convert(varchar(10),convert(datetime,A.FECARRI),120))))else 0 end
)
END

END

SELECT DISTINCT
MANDT, MATRICULA, EMBARC, Embarcacion, WERDES, Centro, NUMINF, TIPINF,
MATNR, especie, FECZARP, HORZARP, FECARRI, HORARRI, FECDES2, HORDES2, DESTIN,
DECLARADO, DESCARGA, Estado
FROM #INFORME_FLOTA

DROP TABLE #INFORME_FLOTA 

