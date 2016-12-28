with member acumuladoanual as
	sum(ytd(),[Measures].[Descarga OF -OC])
select {[Measures].[Descarga OF -OC],acumuladoanual} on 0, 
[FECHA CALENDARIO].[J Calendario].[Mes] on 1
from [FLOTA PP]
where {[FECHA CALENDARIO].[Año].&[2015],[FECHA CALENDARIO].[Año].&[2016]}
;

with member acumuladoanual as
	Sum(YTD([FECHA CALENDARIO].[J Calendario].CurrentMember),[Measures].[Descarga OF -OC])
select {[Measures].[Descarga OF -OC],acumuladoanual} on 0, 
[FECHA CALENDARIO].[J Calendario].[Mes] on 1
from [FLOTA PP]
where {[FECHA CALENDARIO].[Año].&[2015],[FECHA CALENDARIO].[Año].&[2016]}
;



Sum(YTD([FECHA CALENDARIO].[J Calendario].CurrentMember),[Measures].[Descarga OF -OC])

