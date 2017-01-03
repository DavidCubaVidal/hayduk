--Dataset: Harina_Consolidado
With harina_pescado as (
	select PLANTA, LOTE_PT
	,case when SD_CLASI_COMERCIAL in ('SUPER PRIME','PREMIUM') then 1 else 0 end Harina_SP
	,case when SD_CLASI_COMERCIAL in ('PRIME') then 1 else 0 end Harina_P
	,case when SD_CLASI_COMERCIAL in ('STANDARD 63','STANDARD 65','STANDARD 67','THAILANDIA','TAIWAN') then 1 else 0 end Harina_STD
	,1 as Harina_Total
	from TRAZABILIDAD_ETAPA1
	where FECHA_PRODUCCION BETWEEN @ParamFechaInicio AND @ParamFechaFinal
	and PLANTA in ('MALABRIGO','COISHCO','VEGUETA','ILO','TAMBO DE MORA')
	group by PLANTA, LOTE_PT, SD_CLASI_COMERCIAL)
select PLANTA
,sum(Harina_SP) * 50 as Harina_SP_TM
,sum(Harina_P) * 50 as Harina_P_TM
,sum(Harina_STD) * 50 as Harina_STD_TM
,sum(Harina_Total) * 50 as Harina_Total_TM
from harina_pescado
group by PLANTA;

--Dataset: Harina_Detalle
select PLANTA, LOTE_PT
,case when SD_CLASI_COMERCIAL in ('SUPER PRIME','PREMIUM') then 1 else 0 end Harina_SP
,case when SD_CLASI_COMERCIAL in ('PRIME') then 1 else 0 end Harina_P
,case when SD_CLASI_COMERCIAL in ('STANDARD 63','STANDARD 65','STANDARD 67','THAILANDIA','TAIWAN') then 1 else 0 end Harina_STD
from TRAZABILIDAD_ETAPA1
where FECHA_PRODUCCION BETWEEN @ParamFechaInicio AND @ParamFechaFinal
and PLANTA in ('MALABRIGO','COISHCO','VEGUETA','ILO','TAMBO DE MORA')
group by PLANTA, LOTE_PT, SD_CLASI_COMERCIAL
order by 1

--Dataset: MP_Consolidado
With materia_prima as (
	select PLANTA, LOTE_PT 
	,case when QM_CAL_POT_MP in ('SUPER PRIME','PREMIUM') then CONSUMO_M else 0 end MP_SP
	,case when QM_CAL_POT_MP in ('PRIME') then CONSUMO_M else 0 end MP_P
	,case when QM_CAL_POT_MP in ('STANDARD') then CONSUMO_M else 0 end MP_STD
	,CONSUMO_M as MP_Total
	from TRAZABILIDAD_ETAPA1
	where FECHA_PRODUCCION BETWEEN @ParamFechaInicio AND @ParamFechaFinal
	and PLANTA in ('MALABRIGO','COISHCO','VEGUETA','ILO','TAMBO DE MORA')
	group by PLANTA, LOTE_PT, QM_CAL_POT_MP, CONSUMO_M)
select PLANTA
,sum(MP_SP) as MP_SP
,sum(MP_P) as MP_P
,sum(MP_STD) as MP_STD
,sum(MP_Total) as MP_Total
from materia_prima
group by PLANTA

--Dataset: MP_Detalle
select PLANTA, LOTE_PT 
,case when QM_CAL_POT_MP in ('SUPER PRIME','PREMIUM') then CONSUMO_M else 0 end MP_SP
,case when QM_CAL_POT_MP in ('PRIME') then CONSUMO_M else 0 end MP_P
,case when QM_CAL_POT_MP in ('STANDARD') then CONSUMO_M else 0 end MP_STD
from TRAZABILIDAD_ETAPA1
where FECHA_PRODUCCION BETWEEN @ParamFechaInicio AND @ParamFechaFinal
and PLANTA in ('MALABRIGO','COISHCO','VEGUETA','ILO','TAMBO DE MORA')
group by PLANTA, LOTE_PT, QM_CAL_POT_MP, CONSUMO_M
order by 1
