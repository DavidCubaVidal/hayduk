-- ****************************************************************************************************************************************************

declare @INICIO datetime = '2016-11-13', @FIN datetime = '2016-11-13', @CENTRO varchar(8) = 'H101';
-- declare @INICIO varchar(10) = '2016-11-13', @FIN varchar(10) = '2016-11-13', @CENTRO varchar(8) = 'H101';

declare @i varchar(10) = convert(varchar(8),convert(datetime,@INICIO),112);
declare @f varchar(10) = convert(varchar(8),convert(datetime,@FIN),112);
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

IF OBJECT_ID('tempdb..#balance') IS NOT NULL
	DROP TABLE #balance
Create table #balance (Fecha varchar(25),Centro varchar(25),Lote varchar(25),Humedad varchar(15),Grasa varchar(15))

declare @horaArray table (hora varchar(10));
declare @sqlCommand varchar(MAX);
declare @hora varchar(10);

INSERT INTO @horaArray (hora)
VALUES ('HORA01'),('HORA02'),('HORA03'),('HORA04'),('HORA05'),('HORA06'),
('HORA07'),('HORA08'),('HORA09'),('HORA10'),('HORA11'),('HORA12')

WHILE (
	SELECT Count(1)
	FROM @horaArray
	) > 0
BEGIN
	SELECT TOP 1 @hora = hora
	FROM @horaArray

	SET @sqlCommand = '
		-- TURNO 001
		With base1 as(
		select t1.DATUM as Fecha, t1.WERKS as Centro, t2.KURZTEXT as Caracteristica
		,'+ @hora +'
		from prd.ZTQM_CAR_SEC_CAB t1 (nolock)
		inner join prd.ZTQM_CAR_SEC_DET t2 (nolock) on t1.NUM_CAR_SEC = t2.NUM_CAR_SEC
		where t2.LTXA1 = ''Harina Contramuestra''
		and t2.KURZTEXT in (''RUMA PRODUCIDA'',''Humedad (%)'',''Grasa (%)'')
		and t1.DATUM between '+ @i +' and '+ @f +'
		and t1.WERKS = '''+ @CENTRO+'''
		and t1.SECCION = ''Secado - Cal''
		and t1.TURNO in (''001'')
		and t1.MATNR = ''000000000010000004''
		)
		insert into #balance
		Select *
		from(
			select Fecha, Centro, Caracteristica, '+ @hora +'
			from base1
		) as base2
		pivot(MAX('+ @hora +') for Caracteristica in ([RUMA PRODUCIDA],[Humedad (%)],[Grasa (%)])) piv;

		-- TURNO 002
		With base1 as(
		select t1.DATUM as Fecha, t1.WERKS as Centro, t2.KURZTEXT as Caracteristica
		,'+ @hora +'
		from prd.ZTQM_CAR_SEC_CAB t1 (nolock)
		inner join prd.ZTQM_CAR_SEC_DET t2 (nolock) on t1.NUM_CAR_SEC = t2.NUM_CAR_SEC
		where t2.LTXA1 = ''Harina Contramuestra''
		and t2.KURZTEXT in (''RUMA PRODUCIDA'',''Humedad (%)'',''Grasa (%)'')
		and t1.DATUM between '+ @i +' and '+ @f +'  
		and t1.WERKS = '''+ @CENTRO+'''
		and t1.SECCION = ''Secado - Cal''
		and t1.TURNO in (''002'')
		and t1.MATNR = ''000000000010000004''
		)
		insert into #balance
		Select *
		from(
			select Fecha, Centro, Caracteristica, '+ @hora +'
			from base1
		) as base2
		pivot(MAX('+ @hora +') for Caracteristica in ([RUMA PRODUCIDA],[Humedad (%)],[Grasa (%)])) piv
	'
	EXEC (@sqlCommand)
	DELETE @horaArray
	WHERE hora = @hora
END

--Resultado Totales
select
(select count(Lote) from #balance where LTRIM(RTRIM(Lote))  != '') conteoLote,
(select count(Humedad) from #balance where LTRIM(RTRIM(Humedad))  != '') conteoHumedad,
(select count(Grasa) from #balance where LTRIM(RTRIM(Grasa))  != '') conteoGrasa

--Resultado Detalle
select * from #balance
where (LTRIM(RTRIM(Lote)) + LTRIM(RTRIM(Humedad)) + LTRIM(RTRIM(Grasa))) != ''
order by Fecha, Lote



/* NOTAS:

select * from prd.ZTQM_CAR_SEC_CAB (nolock)
where WERKS = 'H101' and DATUM = '20161112'
and SECCION = 'Secado - Cal'

select * from prd.ZTQM_CAR_SEC_DET (nolock)
where NUM_CAR_SEC in (7345, 7025, 6944)
and LTXA1 = 'Harina Contramuestra'
---

select * from prd.ZTQM_CAR_SEC_CAB (nolock)
where NUM_CAR_SEC in (7361, 7698)

select * from prd.ZTQM_CAR_SEC_DET (nolock)
where NUM_CAR_SEC in (7361, 7698)
and LTXA1 = 'Harina Contramuestra'

*/
