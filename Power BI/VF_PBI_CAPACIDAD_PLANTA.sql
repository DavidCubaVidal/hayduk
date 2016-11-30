
-- sp_refreshview VF_PBI_CAPACIDAD_PLANTA
-- select * from [VF_PBI_CAPACIDAD_PLANTA]

ALTER VIEW [dbo].[VF_PBI_CAPACIDAD_PLANTA] AS
WITH CTE1 AS (
	SELECT --t3.DES_CENTRO,
	t9.ID_TIEMPO, ID_TEMP_PESCA = (SELECT TOP 1 TP.ID_TEMP_PESCA FROM VD_TEMPORADA_PESCA TP WHERE t9.FECH_DIA_SAP BETWEEN TP.FEC_INICIO AND TP.FEC_FIN),
	t3.ID_CENTRO, SUM(COALESCE(DESCARGA_OF,DESCARGA_OC)) AS DESCARGA_OF_OC, NULL AS DIAS,
	CASE
		WHEN t3.ID_CENTRO = 5 THEN CAST(106.4 AS Decimal(8, 2))
		WHEN t3.ID_CENTRO = 6 THEN CAST(144 AS Decimal(8, 2))
		WHEN t3.ID_CENTRO = 9 THEN CAST(96 AS Decimal(8, 2))
		WHEN t3.ID_CENTRO = 10 THEN CAST(96 AS Decimal(8, 2))
	END AS CAP_PLANTA,
	CASE
		WHEN t3.ID_CENTRO = 5 THEN CAST(0.45 AS Decimal(5, 4))
		WHEN t3.ID_CENTRO = 6 THEN CAST(0.43 AS Decimal(5, 4))
		WHEN t3.ID_CENTRO = 9 THEN CAST(0.47 AS Decimal(5, 4))
		WHEN t3.ID_CENTRO = 10 THEN CAST(0.56 AS Decimal(5, 4))
	END AS CAP_PLANTA_META
	FROM VD_INFORME_FLOTA (NOLOCK) t1
	INNER JOIN VF_INFORME_FLOTA (NOLOCK) t2 ON t1.ID_INFORME_FLOTA = t2.ID_INFORME_FLOTA
	INNER JOIN VD_CENTRO_MM t3 (NOLOCK) ON t1.ID_CENTRO_DESCARGA = t3.ID_CENTRO
	INNER JOIN VD_TIEMPO (NOLOCK) t9 ON t1.ID_TIEMPO = t9.ID_TIEMPO
	WHERE t1.ID_CENTRO_DESCARGA IN (5,6,9,10)
	AND t1.DES_DESTINO = 'Consumo Humano Indirecto'
	GROUP BY t9.ID_TIEMPO, t3.ID_CENTRO, FECH_DIA_SAP--, t3.DES_CENTRO

	UNION ALL
	
	SELECT --t3.DES_CENTRO,
	t9.ID_TIEMPO, ID_TEMP_PESCA = (SELECT TOP 1 TP.ID_TEMP_PESCA FROM VD_TEMPORADA_PESCA TP WHERE t9.FECH_DIA_SAP BETWEEN TP.FEC_INICIO AND TP.FEC_FIN),
	t3.ID_CENTRO, NULL AS DESCARGA_OF_OC, COUNT(DISTINCT t1.ID_TIEMPO) DIAS,
	CASE
		WHEN t3.ID_CENTRO = 5 THEN CAST(106.4 AS Decimal(8, 2))
		WHEN t3.ID_CENTRO = 6 THEN CAST(144 AS Decimal(8, 2))
		WHEN t3.ID_CENTRO = 9 THEN CAST(96 AS Decimal(8, 2))
		WHEN t3.ID_CENTRO = 10 THEN CAST(96 AS Decimal(8, 2))
	END AS CAP_PLANTA,
	CASE
		WHEN t3.ID_CENTRO = 5 THEN CAST(0.45 AS Decimal(5, 4))
		WHEN t3.ID_CENTRO = 6 THEN CAST(0.43 AS Decimal(5, 4))
		WHEN t3.ID_CENTRO = 9 THEN CAST(0.47 AS Decimal(5, 4))
		WHEN t3.ID_CENTRO = 10 THEN CAST(0.56 AS Decimal(5, 4))
	END AS CAP_PLANTA_META
	FROM VF_PRODUCCION (NOLOCK) t1
	INNER JOIN VD_CENTRO_MM t3 (NOLOCK) ON t1.ID_CENTRO = t3.ID_CENTRO
	INNER JOIN VD_TIEMPO (NOLOCK) t9 ON t1.ID_TIEMPO = t9.ID_TIEMPO
	INNER JOIN VD_ORDENES_FABRICACION (NOLOCK) t4 ON t1.ID_ORD_FABRIC = t4.ID_ORD_REPR
	WHERE t1.ID_CENTRO IN (5,6,9,10)
	AND t1.ID_UNIDAD_NEGOCIO = 1 --Harina y Aceite
	AND t1.ID_MEDIDA = 5 --TM
	AND t4.DES_CLASE_ORDEN = 'Colector de costes del producto'
	GROUP BY t9.ID_TIEMPO, t3.ID_CENTRO, FECH_DIA_SAP--, t3.DES_CENTRO
) SELECT CTE1.ID_TIEMPO, ID_TEMP_PESCA, ID_CENTRO, SUM(DESCARGA_OF_OC) AS DESCARGA_OF_OC, SUM(DIAS) AS DIAS,
MIN(CAST(CAP_PLANTA AS Decimal(8, 2))) AS CAP_PLANTA, MIN(CAP_PLANTA_META) AS CAP_PLANTA_META,
CAST((SUM(DIAS) * CAP_PLANTA * 24) AS Decimal(8, 2)) AS CAP_PLANTA_24--, (SUM(DESCARGA_OF_OC) / (SUM(DIAS) * CAP_PLANTA * 24)) AS CAP_PLANTA_REAL
FROM CTE1
--INNER JOIN VD_TIEMPO (NOLOCK) t9 ON CTE1.ID_TIEMPO = t9.ID_TIEMPO
--WHERE t9.DESC_ANNO = 2016 and t9.DESC_MES in ('Junio', 'Julio')
GROUP BY CTE1.ID_TIEMPO, ID_TEMP_PESCA, ID_CENTRO, CAP_PLANTA, CAP_PLANTA_META







--
select CTE1.*
from [VF_PBI_CAPACIDAD_PLANTA] CTE1


select CTE1.ID_CENTRO, SUM(DESCARGA_OF_OC) AS DESCARGA_OF_OC, SUM(DIAS) AS DIAS,
MIN(CAP_PLANTA) AS CAP_PLANTA, MIN(CAP_PLANTA_META) AS CAP_PLANTA_META,
(SUM(DIAS) * CAP_PLANTA * 24) AS CAP_PLANTA_24
from [VF_PBI_CAPACIDAD_PLANTA] CTE1
INNER JOIN VD_TIEMPO (NOLOCK) t9 ON CTE1.ID_TIEMPO = t9.ID_TIEMPO
WHERE t9.DESC_ANNO = 2016 and t9.DESC_MES in ('Junio', 'Julio')
GROUP BY CTE1.ID_CENTRO, CAP_PLANTA



select distinct CAP_PLANTA
from [VF_PBI_CAPACIDAD_PLANTA]

