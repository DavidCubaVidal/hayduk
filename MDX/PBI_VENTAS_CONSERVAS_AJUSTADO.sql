-- totales
with member numero as [Measures].[Cantidad Facturada Ajus Acum]
select NON EMPTY {numero} on 0,
NON  EMPTY {([FECHA CALENDARIO].[J Calendario].[Año].allmembers * [GRUPO CLIENTE].[Grupo Cliente].[Grupo Cliente].allmembers)} on 1
from [VENTAS SD];

-- Venta Campomar
-- Canal 'moderno + tradicional'
with member numero as sum([GRUPO CLIENTE].[Grupo Cliente].&[20],[Measures].[Cantidad Facturada Ajus Acum])+
sum([GRUPO CLIENTE].[Grupo Cliente].&[10],[Measures].[Cantidad Facturada Ajus Acum])
select NON EMPTY {numero} on 0,
NON  EMPTY {([FECHA CALENDARIO].[J Calendario].[Año].allmembers)} on 1
from [VENTAS SD];

-- Comportamiento Canal Moderno
-- [Measures].[Cantidad Facturada Ajus Acum] 'moderno' / [Measures].[Cantidad Facturada Ajus Acum] 'moderno + tradicional'
with member numero as sum([GRUPO CLIENTE].[Grupo Cliente].&[20],[Measures].[Cantidad Facturada Ajus Acum])
/[Measures].[Venta Campomar]
select NON EMPTY {numero} on 0,
NON  EMPTY {([FECHA CALENDARIO].[J Calendario].[Año].allmembers)} on 1
from [VENTAS SD];

-- Comportamiento Canal Tradicional
--[Measures].[Cantidad Facturada Ajus Acum] 'tradicional' / [Measures].[Cantidad Facturada Ajus Acum] 'moderno + tradicional'
with member numero as sum([GRUPO CLIENTE].[Grupo Cliente].&[10],[Measures].[Cantidad Facturada Ajus Acum])
/[Measures].[Venta Campomar]
select NON EMPTY {numero} on 0,
NON  EMPTY {([FECHA CALENDARIO].[J Calendario].[Año].allmembers)} on 1
from [VENTAS SD];
