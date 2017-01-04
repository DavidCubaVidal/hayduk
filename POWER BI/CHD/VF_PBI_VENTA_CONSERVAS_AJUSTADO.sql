CREATE VIEW [dbo].[VF_PBI_VENTA_CONSERVAS_AJUSTADO] AS

-- *****************************************************************************
-- ******************  CANAL MODERNO -- ID_GRUP_CLIENTE = 5 ********************
-- *****************************************************************************

-- Nota 1: Quitar los materiales (3426, 3723)
select b.ID_TIEMPO
,5 as ID_GRUP_CLIENTE
,sum(a.VAL_CANTIDAD_FACTURADA) as [Cantidad Facturada]
from VF_FACTURA_VENTA_SD a
inner join VD_TIEMPO b on a.ID_TIEMPO = b.ID_TIEMPO
inner join VD_MEDIDA c on a.ID_MEDIDA = c.ID_MEDIDA
inner join VD_FACTURA_VENTA_SD d on a.ID_FACTURA_VENTA = d.ID_FACTURA_VENTA
inner join VD_FACTURA_PEDIDO e on d.ID_FACTURA_VENTA_PED = e.ID_FACTURA_VENTA_PED
inner join VD_GRUPO_CLIENTE f on e.COD_GRUPO_CLIENTE = f.COD_GRUP_CLIENTE
inner join VD_AREA_VENTA_SD g on d.ID_AREA_VENTA = g.ID_AREA_VENTA
inner join VD_MATERIAL h on d.ID_MATERIAL = h.ID_MATERIAL
where b.DESC_ANNO = 2016
and c.DES_MEDIDA in ('Caja Patron')
and d.ID_MATERIAL not in (3426, 3723)
and d.VALIDO = 'Valido'
and f.ID_GRUP_CLIENTE = 5
group by b.ID_TIEMPO

Union All

-- *****************************************************************************
-- ******************  INSTITUCIONAL -- ID_GRUP_CLIENTE = 6 ********************
-- *****************************************************************************

-- Agregando todo
select b.ID_TIEMPO
,6 as ID_GRUP_CLIENTE
,sum(a.VAL_CANTIDAD_FACTURADA) as [Cantidad Facturada]
from VF_FACTURA_VENTA_SD a
inner join VD_TIEMPO b on a.ID_TIEMPO = b.ID_TIEMPO
inner join VD_MEDIDA c on a.ID_MEDIDA = c.ID_MEDIDA
inner join VD_FACTURA_VENTA_SD d on a.ID_FACTURA_VENTA = d.ID_FACTURA_VENTA
inner join VD_FACTURA_PEDIDO e on d.ID_FACTURA_VENTA_PED = e.ID_FACTURA_VENTA_PED
inner join VD_GRUPO_CLIENTE f on e.COD_GRUPO_CLIENTE = f.COD_GRUP_CLIENTE
inner join VD_AREA_VENTA_SD g on d.ID_AREA_VENTA = g.ID_AREA_VENTA
inner join VD_MATERIAL h on d.ID_MATERIAL = h.ID_MATERIAL
where b.DESC_ANNO = 2016
and c.DES_MEDIDA in ('Caja Patron')
-- and d.ID_MATERIAL in (3426, 3723)
and d.VALIDO = 'Valido'
and f.ID_GRUP_CLIENTE = 6
group by b.ID_TIEMPO

Union All

-- Nota 1: Agregar los materiales (3426, 3723) de CANAL MODERNO -- ID_GRUP_CLIENTE = 5
select b.ID_TIEMPO
,6 as ID_GRUP_CLIENTE
,sum(a.VAL_CANTIDAD_FACTURADA) as [Cantidad Facturada]
from VF_FACTURA_VENTA_SD a
inner join VD_TIEMPO b on a.ID_TIEMPO = b.ID_TIEMPO
inner join VD_MEDIDA c on a.ID_MEDIDA = c.ID_MEDIDA
inner join VD_FACTURA_VENTA_SD d on a.ID_FACTURA_VENTA = d.ID_FACTURA_VENTA
inner join VD_FACTURA_PEDIDO e on d.ID_FACTURA_VENTA_PED = e.ID_FACTURA_VENTA_PED
inner join VD_GRUPO_CLIENTE f on e.COD_GRUPO_CLIENTE = f.COD_GRUP_CLIENTE
inner join VD_AREA_VENTA_SD g on d.ID_AREA_VENTA = g.ID_AREA_VENTA
inner join VD_MATERIAL h on d.ID_MATERIAL = h.ID_MATERIAL
where b.DESC_ANNO = 2016
and c.DES_MEDIDA in ('Caja Patron')
and d.ID_MATERIAL in (3426, 3723)
and d.VALIDO = 'Valido'
and f.ID_GRUP_CLIENTE = 5
group by b.ID_TIEMPO

Union All

-- Nota 2: Agregar los materiales (3899 3720 3898) de CANAL TRADICIONAL -- ID_GRUP_CLIENTE = 4
select b.ID_TIEMPO
,6 as ID_GRUP_CLIENTE
,sum(a.VAL_CANTIDAD_FACTURADA) as [Cantidad Facturada]
from VF_FACTURA_VENTA_SD a
inner join VD_TIEMPO b on a.ID_TIEMPO = b.ID_TIEMPO
inner join VD_MEDIDA c on a.ID_MEDIDA = c.ID_MEDIDA
inner join VD_FACTURA_VENTA_SD d on a.ID_FACTURA_VENTA = d.ID_FACTURA_VENTA
inner join VD_FACTURA_PEDIDO e on d.ID_FACTURA_VENTA_PED = e.ID_FACTURA_VENTA_PED
inner join VD_GRUPO_CLIENTE f on e.COD_GRUPO_CLIENTE = f.COD_GRUP_CLIENTE
inner join VD_AREA_VENTA_SD g on d.ID_AREA_VENTA = g.ID_AREA_VENTA
inner join VD_MATERIAL h on d.ID_MATERIAL = h.ID_MATERIAL
where b.DESC_ANNO = 2016
and c.DES_MEDIDA in ('Caja Patron')
and d.ID_MATERIAL in (3899, 3720, 3898)
and d.VALIDO = 'Valido'
and f.ID_GRUP_CLIENTE = 4
group by b.ID_TIEMPO

Union All

-- *****************************************************************************
-- ****************  CANAL TRADICIONAL -- ID_GRUP_CLIENTE = 4 ******************
-- *****************************************************************************

-- Nota 1: Sin cambios
-- Nota 2: Quitar los materiales (3899 3720 3898)
select b.ID_TIEMPO
,4 as ID_GRUP_CLIENTE
,sum(a.VAL_CANTIDAD_FACTURADA) as [Cantidad Facturada]
from VF_FACTURA_VENTA_SD a
inner join VD_TIEMPO b on a.ID_TIEMPO = b.ID_TIEMPO
inner join VD_MEDIDA c on a.ID_MEDIDA = c.ID_MEDIDA
inner join VD_FACTURA_VENTA_SD d on a.ID_FACTURA_VENTA = d.ID_FACTURA_VENTA
inner join VD_FACTURA_PEDIDO e on d.ID_FACTURA_VENTA_PED = e.ID_FACTURA_VENTA_PED
inner join VD_GRUPO_CLIENTE f on e.COD_GRUPO_CLIENTE = f.COD_GRUP_CLIENTE
inner join VD_AREA_VENTA_SD g on d.ID_AREA_VENTA = g.ID_AREA_VENTA
inner join VD_MATERIAL h on d.ID_MATERIAL = h.ID_MATERIAL
where b.DESC_ANNO = 2016
and c.DES_MEDIDA in ('Caja Patron')
and d.ID_MATERIAL not in (3899, 3720, 3898)
and d.VALIDO = 'Valido'
and f.ID_GRUP_CLIENTE = 4
group by b.ID_TIEMPO


-- **********************************************************************************************************************************

/*
-- Pruebas:
select b.DESC_MES, c.DES_GRUP_CLIENTE, sum(a.[Cantidad Facturada]) as [Cantidad Facturada]
from VF_PBI_VENTA_CONSERVAS_AJUSTADO a
inner join VD_TIEMPO b on a.ID_TIEMPO = b.ID_TIEMPO
inner join VD_GRUPO_CLIENTE c on a.ID_GRUP_CLIENTE = c.ID_GRUP_CLIENTE
group by b.DESC_MES,b.CODI_MES, c.DES_GRUP_CLIENTE
order by b.CODI_MES,2

*/
