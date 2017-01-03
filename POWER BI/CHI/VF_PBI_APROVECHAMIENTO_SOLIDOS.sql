ALTER VIEW [dbo].[VF_PBI_APROVECHAMIENTO_SOLIDOS] AS -- select * from [VF_PBI_APROVECHAMIENTO_SOLIDOS] -- sp_refreshview VF_PBI_APROVECHAMIENTO_SOLIDOS

SELECT b.ID_TIEMPO, ID_TEMP_PESCA = (SELECT TOP 1 TP.ID_TEMP_PESCA FROM VD_TEMPORADA_PESCA TP WHERE b.FECH_DIA_SAP BETWEEN TP.FEC_INICIO AND TP.FEC_FIN),
c.ID_CENTRO, c.DES_CENTRO2, --a.*,
sum(TM_SOLIDOS_HARINA) TM_SOLIDOS_HARINA,
sum(TM_SOLIDO_ACEITE) TM_SOLIDO_ACEITE,
sum(TM_SOLIDOS_MP) TM_SOLIDOS_MP
FROM F_APROVECHAMIENTO_SOLIDOS a
JOIN VD_TIEMPO b (NOLOCK) on a.FECHA_PROD = b.DESC_FECH_2 COLLATE DATABASE_DEFAULT -- select * from VD_TEMPORADA_PESCA
JOIN VD_CENTRO_MM c (NOLOCK) on a.COD_PLANTA = c.COD_CENTRO COLLATE DATABASE_DEFAULT
Group by b.ID_TIEMPO, c.ID_CENTRO, c.DES_CENTRO2, FECH_DIA_SAP

go;

ALTER VIEW [dbo].[VF_PBI_APROVECHAMIENTO_GRASAS] AS -- select * from [VF_PBI_APROVECHAMIENTO_GRASAS] -- sp_refreshview VF_PBI_APROVECHAMIENTO_GRASAS

SELECT b.ID_TIEMPO, ID_TEMP_PESCA = (SELECT TOP 1 TP.ID_TEMP_PESCA FROM VD_TEMPORADA_PESCA TP WHERE b.FECH_DIA_SAP BETWEEN TP.FEC_INICIO AND TP.FEC_FIN),
c.ID_CENTRO, c.DES_CENTRO2, --a.*,
sum(TM_GRASA_HARINA) TM_GRASA_HARINA,
sum(TM_GRASA_ACEITE) TM_GRASA_ACEITE,
sum(TM_GRASA_MP) TM_GRASA_MP
FROM F_APROVECHAMIENTO_GRASAS a
JOIN VD_TIEMPO b (NOLOCK) on a.FECHA_PROD = b.DESC_FECH_2 COLLATE DATABASE_DEFAULT
JOIN VD_CENTRO_MM c (NOLOCK) on a.COD_PLANTA = c.COD_CENTRO COLLATE DATABASE_DEFAULT
Group by b.ID_TIEMPO, c.ID_CENTRO, c.DES_CENTRO2, FECH_DIA_SAP