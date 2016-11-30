
----------------- Estados de los informes de flota ---------------------------------
select distinct DOMVALUE_L as Codigo, DDTEXT as Descripcion 
into #EstadoInforme
from prd.DD07T (nolock)
where DDLANGUAGE = 'S' 
and AS4LOCAL = 'A'
and rtrim(ltrim(DOMNAME)) = 'ZD_STINF'


;With Informe_Flota as (
select 
x.NUMINF	AS NroInforme,
x.MATRICULA AS Matricula,
x.EMBARC	AS Embarcacion,
x.TIPINF    AS TipoInforme,
x.CAP_TM	AS CapacidadTM,
x.[STATUS]	AS CodEstado,
c.Descripcion	AS DesEstado,
isnull(d.PTODSC,'') AS PuertoZarpe,
isnull((select min(z7.NAME1) from prd.T001W z7 where x.WERDES = z7.WERKS and x.MANDT = z7.MANDT),'No especificado') AS PlantaDescarga,
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
inner join prd.ZTPP_CALAS f (nolock) on x.MANDT = f.MANDT and x.NUMINF = f.NUMINF --select * from prd.ZTPP_CALAS f (nolock)
left outer join prd.ZTPP_HOJA_MUESTR g (nolock)on x.MANDT=g.MANDT AND x.NUMINF=g.NUMINF and f.NUMCALA=g.NUMCALA
where 
f.FECCAL2 between convert(varchar(8),@ParamFechaInicio,112) and convert(varchar(8),@ParamFechaFinal,112)
--x.NUMINF = '023747'
and x.TIPINF = 'P'
and x.TIPORED = '01'
)
Select t11.*, t12.Porc_Juvenil
into #DATOS
from Informe_Flota t11 left join (
		select t1.NUMINF, t1.NUMCALA, t1.NUMMUE, t2.ESPECIE
		,Porc_Juvenil = (CASE WHEN CAST(SUM(t1.CANT) AS decimal(8,2)) = 0 THEN 0 ELSE (Case
		-- 01	ANCHOVETA
		when t2.ESPECIE = '01' then (select SUM(t3.CANT) from prd.ZTPP_LONG_INFORF t3 where TALLA < 12 and t1.NUMINF=t3.NUMINF and t1.NUMCALA=t3.NUMCALA and t1.NUMMUE = t3.NUMMUE)
		-- 03	ATUN ALETA AMARILLA
		when t2.ESPECIE = '03' then (select SUM(t3.CANT) from prd.ZTPP_LONG_INFORF t3 where TALLA < 60 and t1.NUMINF=t3.NUMINF and t1.NUMCALA=t3.NUMCALA and t1.NUMMUE = t3.NUMMUE)
		-- 04	BARRILETE
		when t2.ESPECIE = '04' then (select SUM(t3.CANT) from prd.ZTPP_LONG_INFORF t3 where TALLA < 47 and t1.NUMINF=t3.NUMINF and t1.NUMCALA=t3.NUMCALA and t1.NUMMUE = t3.NUMMUE)
		-- 05	BONITO
		when t2.ESPECIE = '05' then (select SUM(t3.CANT) from prd.ZTPP_LONG_INFORF t3 where TALLA < 52 and t1.NUMINF=t3.NUMINF and t1.NUMCALA=t3.NUMCALA and t1.NUMMUE = t3.NUMMUE)
		-- 06	CABALLA
		when t2.ESPECIE = '06' then (select SUM(t3.CANT) from prd.ZTPP_LONG_INFORF t3 where TALLA < 29 and t1.NUMINF=t3.NUMINF and t1.NUMCALA=t3.NUMCALA and t1.NUMMUE = t3.NUMMUE)
		-- 09	FALSO VOLADOR
		when t2.ESPECIE = '09' then (select SUM(t3.CANT) from prd.ZTPP_LONG_INFORF t3 where TALLA < 20 and t1.NUMINF=t3.NUMINF and t1.NUMCALA=t3.NUMCALA and t1.NUMMUE = t3.NUMMUE)
		-- 10	JUREL
		when t2.ESPECIE = '10' then (select SUM(t3.CANT) from prd.ZTPP_LONG_INFORF t3 where TALLA < 31 and t1.NUMINF=t3.NUMINF and t1.NUMCALA=t3.NUMCALA and t1.NUMMUE = t3.NUMMUE)
		-- 11	MERLUZA
		when t2.ESPECIE = '11' then (select SUM(t3.CANT) from prd.ZTPP_LONG_INFORF t3 where TALLA < 35 and t1.NUMINF=t3.NUMINF and t1.NUMCALA=t3.NUMCALA and t1.NUMMUE = t3.NUMMUE)
		else 0
		end) / CAST(SUM(t1.CANT) AS decimal(8,2)) end)
		from prd.ZTPP_LONG_INFORF t1 (nolock)
		inner join prd.ZTPP_HOJA_MUESTR (nolock) t2 on t1.NUMINF=t2.NUMINF and t1.NUMCALA=t2.NUMCALA and t1.NUMMUE = t2.NUMMUE 
		-- where t1.NUMINF = '023846'
		group by t1.NUMINF, t1.NUMCALA, t1.NUMMUE, t2.ESPECIE
) t12 on t11.NroInforme = t12.NUMINF and t11.NUMCALA = t12.NUMCALA and t11.NUMMUE = t12.NUMMUE and t11.ESPECIE = t12.ESPECIE
order by t11.NUMCALA

select distinct NroInforme, NUMCALA, NUMMUE into #TEMP from #DATOS
where ESPECIE = '01'

select NUMINF, NUMCALA, NUMMUE, [10.00],[10.50],[11.00],[11.50],[12.00],[12.50],[13.00],[13.50],[14.00],[14.50],[15.00],[15.50],[16.00],[16.50],[17.00],[17.50],[18.00],[18.50],[19.00]
into #Tallas
from
(select a.NUMINF, a.NUMCALA, a.NUMMUE, CONVERT(varchar(20),a.TALLA) as TALLA, a.CANT
from prd.ZTPP_LONG_INFORF a
inner join #TEMP b on a.NUMINF = b.NroInforme and a.NUMCALA = b.NUMCALA and a.NUMMUE = b.NUMMUE
where TALLA between 10 and 19) as Fuente
PIVOT
(
AVG(CANT) FOR TALLA IN ([10.00],[10.50],[11.00],[11.50],[12.00],[12.50],[13.00],[13.50],[14.00],[14.50],[15.00],[15.50],[16.00],[16.50],[17.00],[17.50],[18.00],[18.50],[19.00])
) AS PivotTable

select a.*, [10.00],[10.50],[11.00],[11.50],[12.00],[12.50],[13.00],[13.50],[14.00],[14.50],[15.00],[15.50],[16.00],[16.50],[17.00],[17.50],[18.00],[18.50],[19.00]
,Des_Especie = (select top 1 t3.DDTEXT from prd.DD07T t3 (nolock) where a.ESPECIE = t3.DOMVALUE_L and t3.DOMNAME = 'ZD_ESPECIE')
from #DATOS a
left outer join #Tallas b on a.NroInforme = b.NUMINF and a.NUMCALA = b.NUMCALA and a.NUMMUE = b.NUMMUE 


drop table #EstadoInforme 
drop table #DATOS
drop table #TEMP 
drop table #Tallas 
