
----------------- Estados de los informes de flota ---------------------------------
IF OBJECT_ID('tempdb..#EstadoInforme') IS NOT NULL DROP TABLE #EstadoInforme
select distinct DOMVALUE_L as Codigo, DDTEXT as Descripcion 
into #EstadoInforme
from prd.DD07T (nolock)
where DDLANGUAGE = 'S' 
and AS4LOCAL = 'A'
and rtrim(ltrim(DOMNAME)) = 'ZD_STINF'

------------------------- Motivo de Zarpe -------------------------------------------
IF OBJECT_ID('tempdb..#MotivoZarpe') IS NOT NULL DROP TABLE #MotivoZarpe
select distinct DOMVALUE_L as Codigo, DDTEXT as Descripcion 
into #MotivoZarpe
from prd.DD07T (nolock)
where DDLANGUAGE = 'S' 
and AS4LOCAL = 'A'
and rtrim(ltrim(DOMNAME)) = 'ZD_TZARPE'

------------------------ Motivo de No Zarpe ------------------------------------------
IF OBJECT_ID('tempdb..#MotivoNoZarpe') IS NOT NULL DROP TABLE #MotivoNoZarpe
select distinct DOMVALUE_L as Codigo, DDTEXT as Descripcion 
into #MotivoNoZarpe
from prd.DD07T (nolock)
where DDLANGUAGE = 'S' 
and AS4LOCAL = 'A'
and rtrim(ltrim(DOMNAME)) = 'ZD_MOTNOZARP'

------------------------- Tipo de Red -------------------------------------------------
IF OBJECT_ID('tempdb..#TipoRed') IS NOT NULL DROP TABLE #TipoRed
select distinct DOMVALUE_L as Codigo, DDTEXT as Descripcion 
into #TipoRed
from prd.DD07T (nolock)
where DDLANGUAGE = 'S' 
and AS4LOCAL = 'A'
and rtrim(ltrim(DOMNAME)) = 'ZD_TIPORED'

------------------------------ Motivo de No Pesca --------------------------------------
IF OBJECT_ID('tempdb..#MotivoNoPesca') IS NOT NULL DROP TABLE #MotivoNoPesca
select distinct DOMVALUE_L as Codigo, DDTEXT as Descripcion 
into #MotivoNoPesca
from prd.DD07T (nolock)
where DDLANGUAGE = 'S' 
and AS4LOCAL = 'A'
and rtrim(ltrim(DOMNAME)) = 'ZD_NOPESCA';

----------------------------------------------------------------------------------------
With Informe_Flota as (
select 
x.NUMINF	AS NroInforme,
x.MATRICULA AS Matricula,
x.EMBARC	AS Embarcacion,
x.TIPINF    AS TipoInforme,
x.CAP_TM	AS CapacidadTM,
isnull((select min(z1.MAKTX) from prd.MAKT z1 where x.MANDT = z1.MANDT and x.MATNR = z1.MATNR and z1.SPRAS = 'S'),'No especificado') AS Especie,
x.[STATUS]	AS CodEstado,
c.Descripcion	AS DesEstado,
(CASE WHEN x.ZARPE = 'X' then 'SI' else 'NO' end) AS Zarpo,
isnull((select min(z2.Descripcion) from #MotivoZarpe z2 where x.TZARPE = z2.Codigo),'') AS MotivoZarpe,
isnull((select min(z3.Descripcion) from #MotivoNoZarpe z3 where x.MOTNOZARP = z3.Codigo),'') AS MotivoNoZarpe,
isnull((select min(z4.Descripcion) from #TipoRed z4 where x.TIPORED = z4.Codigo),'') AS TipoRed,
isnull(d.PTODSC,'') AS PuertoZarpe,
--convert(datetime,convert(varchar(10),convert(datetime,x.FECZARP),20) + ' ' + substring(x.HORZARP, 1, 2) + ':' + substring(HORZARP, 3, 2) + ':' + substring(HORZARP, 5, 2)) AS FechaZarpeCompleta,
(CASE WHEN x.FECZARP = '00000000' or x.FECZARP = '' then '' else x.FECZARP end) AS FechaZarpe,
(CASE WHEN x.HORZARP = '000000' or x.HORZARP = '' then '' else x.HORZARP end) AS HoraZarpe,
(CASE WHEN x.FECZON1 = '00000000' or x.FECZON1 = '' then '' else x.FECZON1 end) AS FechaIngresoZona,
(CASE WHEN x.HORZON1 = '000000' or x.HORZON1 = '' then '' else x.HORZON1 end) AS HoraIngresoZona,
(CASE WHEN x.PESCA = 'X' then 'SI' else 'NO' end) as Pesco,
isnull((select min(z5.Descripcion) from #MotivoNoPesca z5 where x.NOPESCA = z5.Codigo),'') AS MotivoNoPesca,
(CASE WHEN x.FECZON2 = '00000000' or x.FECZON2 = '' then '' else x.FECZON2 end) AS FechaSalidaZona,
(CASE WHEN x.HORZON2 = '000000' or x.HORZON2 = '' then '' else x.HORZON2 end) AS HoraSalidaZona,
isnull(b.PTODSC,'') AS PuertoArribo,
(CASE WHEN x.FECARRI = '00000000' or x.FECARRI = '' then '' else x.FECARRI end) AS FechaArribo,
(CASE WHEN x.HORARRI = '000000' or x.HORARRI = '' then '' else x.HORARRI end) AS HoraArribo,
isnull((select min(z6.Descripcion) from #MotivoNoPesca z6 where x.PROBLEM = z6.Codigo),'') AS Problema,
isnull((select min(z7.NAME1) from prd.T001W z7 where x.WERDES = z7.WERKS and x.MANDT = z7.MANDT),'No especificado') AS PlantaDescarga,
(CASE WHEN x.FECDES1 = '00000000' or x.FECDES1 = '' then '' else x.FECDES1 end) AS FechaInicioDescarga,
(CASE WHEN x.HORDES1 = '000000' or x.HORDES1 = '' then '' else x.HORDES1 end) AS HoraInicioDescarga,
(CASE WHEN x.FECDES2 = '00000000' or x.FECDES2 = '' then '' else x.FECDES2 end) AS FechaFinDescarga,
(CASE WHEN x.HORDES2 = '000000' or x.HORDES2 = '' then '' else x.HORDES2 end) AS HoraFinDescarga,
f.NUMCALA,
f.FECCAL1 as FechaInicioCala,
f.HORCAL1 as HoraInicioCala,
f.FECCAL2 as FechaFinCala,
f.HORCAL2 as HoraFinCala,
f.ZONPES  as ZonaPesca,
f.LATGRA, f.LATMIN, f.LONGRA, f.LONMIN, f.TSM, f.PSC, f.PROA, f.POPA, f.TUNEL, f.CPRO, f.CPOP, f.TBODE, f.OBSERV,
Matricula2 = ( select top 1 rtrim(ltrim(x2.PTOINS)) +'-'+ rtrim(ltrim(x2.MATRICULA)) + '-' + RTRIM(ltrim(x2.TCALADO)) from prd.ZTPP_EMBARC_OFIC x2
			where x.MANDT = x2.MANTD and x.MATRICULA = x2.MATRICULA ),
g.NUMMUE,
g.ESPECIE,
g.PORCE,
g.MODA,
g.TMAX,
g.TMIN,
g.CANT
from prd.ZTPP_INFOR_FLOTA x (nolock)
left outer join prd.ZTPP_PUERTOS b (nolock) on x.PTOARRI = b.PTONU and x.MANDT = b.MANDT
inner join #EstadoInforme c on x.[STATUS] = c.Codigo
left outer join prd.ZTPP_PUERTOS d (nolock) on x.PTOZARP = d.PTONU and x.MANDT = d.MANDT
inner join prd.ZTPP_CALAS f (nolock) on x.MANDT = f.MANDT and x.NUMINF = f.NUMINF
left outer join prd.ZTPP_HOJA_MUESTR g (nolock)on x.MANDT=g.MANDT AND x.NUMINF=g.NUMINF
and f.NUMCALA=g.NUMCALA
where 
x.MANDT = @ParamMandante
and x.NUMINF = @ParamNumeroInforme
-- x.MANDT = '300'
-- and x.NUMINF = '024857' -- 023747  024857 024048
)
Select t11.*,t12.Porc_Juvenil, Porc_Acompanante = isnull(t13.Porc_Acompanante, 0)
from Informe_Flota t11
-- Porc_Juvenil
left join (
	select t1.NUMINF, t1.NUMCALA, t2.ESPECIE
	,Porc_Juvenil = (Case
	-- 01	ANCHOVETA
	when t2.ESPECIE = '01' then (select SUM(t3.CANT) from prd.ZTPP_LONG_INFORF t3 where TALLA < 12 and t1.NUMINF=t3.NUMINF and t1.NUMCALA=t3.NUMCALA)
	-- 03	ATUN ALETA AMARILLA
	when t2.ESPECIE = '03' then (select SUM(t3.CANT) from prd.ZTPP_LONG_INFORF t3 where TALLA < 60 and t1.NUMINF=t3.NUMINF and t1.NUMCALA=t3.NUMCALA)
	-- 04	BARRILETE
	when t2.ESPECIE = '04' then (select SUM(t3.CANT) from prd.ZTPP_LONG_INFORF t3 where TALLA < 47 and t1.NUMINF=t3.NUMINF and t1.NUMCALA=t3.NUMCALA)
	-- 05	BONITO
	when t2.ESPECIE = '05' then (select SUM(t3.CANT) from prd.ZTPP_LONG_INFORF t3 where TALLA < 52 and t1.NUMINF=t3.NUMINF and t1.NUMCALA=t3.NUMCALA)
	-- 06	CABALLA
	when t2.ESPECIE = '06' then (select SUM(t3.CANT) from prd.ZTPP_LONG_INFORF t3 where TALLA < 29 and t1.NUMINF=t3.NUMINF and t1.NUMCALA=t3.NUMCALA)
	-- 09	FALSO VOLADOR
	when t2.ESPECIE = '09' then (select SUM(t3.CANT) from prd.ZTPP_LONG_INFORF t3 where TALLA < 20 and t1.NUMINF=t3.NUMINF and t1.NUMCALA=t3.NUMCALA)
	-- 10	JUREL
	when t2.ESPECIE = '10' then (select SUM(t3.CANT) from prd.ZTPP_LONG_INFORF t3 where TALLA < 31 and t1.NUMINF=t3.NUMINF and t1.NUMCALA=t3.NUMCALA)
	-- 11	MERLUZA
	when t2.ESPECIE = '11' then (select SUM(t3.CANT) from prd.ZTPP_LONG_INFORF t3 where TALLA < 35 and t1.NUMINF=t3.NUMINF and t1.NUMCALA=t3.NUMCALA)
	else 0
	end) / CAST(SUM(t1.CANT) AS decimal(8,2))
	from prd.ZTPP_LONG_INFORF t1 (nolock)
	inner join prd.ZTPP_HOJA_MUESTR (nolock) t2 on t1.NUMINF=t2.NUMINF and t1.NUMCALA=t2.NUMCALA
	-- where t1.NUMINF = '023846'
	group by t1.NUMINF, t1.NUMCALA, t2.ESPECIE
) t12 on t11.NroInforme = t12.NUMINF and t11.NUMCALA = t12.NUMCALA  and t11.ESPECIE = t12.ESPECIE
-- Porc_Acompanante
left join(
	select x.NUMINF, f.NUMCALA,
	Porc_Acompanante = case when g.ESPECIE = '01' then 0 else sum(g.PORCE)/100.00 end -- % especie acompañante de la ANCHOVETA
	from prd.ZTPP_INFOR_FLOTA x (nolock)
	inner join prd.ZTPP_CALAS f (nolock) on x.MANDT = f.MANDT and x.NUMINF = f.NUMINF
	left outer join prd.ZTPP_HOJA_MUESTR g (nolock)on x.MANDT=g.MANDT AND x.NUMINF=g.NUMINF and f.NUMCALA=g.NUMCALA
	where g.NUMMUE != '001' -- Resto de especies que no son ANCHOVETA
	-- and x.NUMINF = '024857' -- 023747  024857 024048
	group by x.NUMINF, f.NUMCALA, g.ESPECIE
) t13 on t11.NroInforme = t13.NUMINF and t11.NUMCALA = t13.NUMCALA
where t11.NUMMUE = '001' -- Solo se muestra la primera muestra, el resto en detalle especie acompañante.
order by t11.NUMCALA



/* NOTAS

ESPECIE:

select * from prd.DD07T (nolock)
where DOMNAME = 'ZD_ESPECIE'

*/

--DETALLE % JUVENIL

-- query
select t1.NUMINF, t1.NUMCALA, t1.TALLA, t1.CANT, t3.DDTEXT AS ESPECIE, @Porc_Juvenil AS Porc_Juvenil
from prd.ZTPP_LONG_INFORF t1 (nolock)
inner join prd.ZTPP_HOJA_MUESTR (nolock) t2 on t1.NUMINF=t2.NUMINF and t1.NUMCALA=t2.NUMCALA
inner join prd.DD07T t3 (nolock) on t2.ESPECIE = t3.DOMVALUE_L
where t1.CANT != 0 -- Ignorando los que no tienen datos
and t1.NUMINF = @ParamNumeroInforme -- '023747'
and t1.NUMCALA = @ParamNumeroCala -- = '001'
and t2.ESPECIE = @ParamEspecie -- = '01'
and t3.DOMNAME = 'ZD_ESPECIE'
group by t1.TALLA, t1.CANT, t3.DDTEXT, t1.NUMINF, t1.NUMCALA
order by t1.TALLA


--DETALLE % PESCA ACOMPAÑANTE
select
x.NUMINF,
f.NUMCALA,
g.NUMMUE,
e.DDTEXT as Especie,
g.PORCE,
g.MODA,
g.TMAX,
g.TMIN,
g.CANT
from prd.ZTPP_INFOR_FLOTA x (nolock)
inner join prd.ZTPP_CALAS f (nolock) on x.MANDT = f.MANDT and x.NUMINF = f.NUMINF
inner join prd.ZTPP_HOJA_MUESTR g (nolock)on x.MANDT=g.MANDT AND x.NUMINF=g.NUMINF and f.NUMCALA=g.NUMCALA
inner join prd.DD07T e (nolock) on g.ESPECIE = e.DOMVALUE_L
where e.DOMNAME = 'ZD_ESPECIE'
--and x.NUMINF = '024857' -- 023747  024857 024048
and f.NUMCALA = @ParamNumeroCala
and x.NUMINF = @ParamNumeroInforme





