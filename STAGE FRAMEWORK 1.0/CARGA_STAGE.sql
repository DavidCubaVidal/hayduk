SELECT * FROM CARGA_STAGE; -- DROP TABLE CARGA_STAGE

CREATE TABLE CARGA_STAGE (
	MODULO_SAP VARCHAR(75),
	TIPO_TABLA VARCHAR(75),
	TABLA_SAP VARCHAR(75),
	TABLA_STAGE VARCHAR(75),
	ACTIVO INT,
	CAMPOS VARCHAR(2000),
	FILTROS VARCHAR(2000)
);

--TRANSACCIONALES
INSERT INTO CARGA_STAGE VALUES ('PM','TRANSACCIONALES','RESB','RESERVA',1,'A.VORNR,A.WERKS,A.LGORT,A.MANDT,A.SAKNR,A.MATNR,A.RSNUM,A.RSPOS,A.AUFNR,A.POSNR,A.BDART,A.RSSTA,A.XLOEK,A.XWAOK,A.KZEAR,A.XFEHL,A.CHARG,A.BDTER,A.BDMNG,A.MEINS,A.ENMNG,A.ENWRT,A.WAERS,A.AUFPL','');
INSERT INTO CARGA_STAGE VALUES ('PM','TRANSACCIONALES','ESLL','SERVICIO',1,'A.PACKNO,A.INTROW,A.SUB_PACKNO,A.MANDT,A.SRVPOS,A.KTEXT1,A.KSTAR','');
INSERT INTO CARGA_STAGE VALUES ('PM','TRANSACCIONALES','AFVC','OPERACION_ORDEN',0,'A.MANDT,A.AUFPL,A.APLZL,A.VORNR,A.STEUS,A.ARBID,A.WERKS,A.LTXA1,A.EKORG,A.EKGRP,A.MATKL,A.ANZZL,A.KTSCH,A.ABLAD,A.BNFPO','');
INSERT INTO CARGA_STAGE VALUES ('PM','TRANSACCIONALES','AFVV','OPERACION_ORDEN_CANTIDAD',1,'A.MANDT,A.AUFPL,A.APLZL,A.MEINH,A.DAUNO,A.ARBEI,A.FSAVD,A.FSEDD','');
INSERT INTO CARGA_STAGE VALUES ('PM','TRANSACCIONALES','PMCO','ESTRUCTURA_COSTO_OM',1,'A.MANDT,A.OBJNR,A.COCUR,A.ACPOS,A.WRTTP,(CASE A.ACPOS WHEN ''MO'' THEN ''Mano Obra'' WHEN ''MAT'' THEN ''Materiales'' WHEN ''TER'' THEN ''Terceros'' WHEN '' '' THEN ''Otros'' ELSE A.ACPOS END) AS DES_ACPOS,(CASE WHEN A.WRTTP = ''01'' THEN ''Plan'' ELSE ''Real'' END) AS TIPO_COSTO,(A.WRT00 + A.WRT01 + A.WRT02 + A.WRT03 + A.WRT04 + A.WRT05 + A.WRT06 + A.WRT07 + A.WRT08 + A.WRT09 + A.WRT10 + A.WRT11 + A.WRT12 + A.WRT13 + A.WRT14 + A.WRT15 + A.WRT16) AS MONTO','');
INSERT INTO CARGA_STAGE VALUES ('PM','TRANSACCIONALES','COBRB','NORMA_LIQUIDACION_ORDEN',1,'A.MANDT,SUBSTRING(A.OBJNR,3,14) AS NORMA,A.KONTY,A.KOSTL,A.OBJNR,A.AUFNR','');
INSERT INTO CARGA_STAGE VALUES ('PM','TRANSACCIONALES','EBAN','SOLICITUD_PEDIDO',1,'A.MANDT,A.AFNAM,A.LIFNR,A.BANFN,A.BNFPO,A.BEDNR,A.PREIS,A.WAERS,A.PEINH,A.MENGE,A.MEINS,A.MATNR,A.MATKL,A.PACKNO,A.EBELN,A.EBELP','');
INSERT INTO CARGA_STAGE VALUES ('PM','TRANSACCIONALES','ILOA','EMPLAZAMIENTO_IMPUTACION_MT',1,'A.*','');
INSERT INTO CARGA_STAGE VALUES ('PM','TRANSACCIONALES','EBKN','IMPUTACION_SOLICITUD_PEDIDO',1,'A.*','');
INSERT INTO CARGA_STAGE VALUES ('PM','TRANSACCIONALES','QMIH','CABECERA_AVISO_I',1,'A.*','');
INSERT INTO CARGA_STAGE VALUES ('PM','TRANSACCIONALES','QMEL','CABECERA_AVISO_II',1,'A.*','');
INSERT INTO CARGA_STAGE VALUES ('PM','TRANSACCIONALES','AFIH','CABECERA_OM',1,'A.*','');
INSERT INTO CARGA_STAGE VALUES ('PM','TRANSACCIONALES','T499S','EMPLAZAMIENTO',1,'A.*','');

-- MAESTROS
INSERT INTO CARGA_STAGE VALUES ('PM','MAESTROS','JEST','STATUS_INDIVIDUAL_OBJETO',0,'A.*','');
INSERT INTO CARGA_STAGE VALUES ('PM','MAESTROS','TJ02T','ESTADO_OBJETO',0,'A.*','');
INSERT INTO CARGA_STAGE VALUES ('PM','MAESTROS','EQUZ','SEGMENTO_TEMPORAL_EQUIPO',1,'A.*','');
INSERT INTO CARGA_STAGE VALUES ('PM','MAESTROS','SKAT','MAESTROS_CTAS_MAYOR',1,'A.*','');
INSERT INTO CARGA_STAGE VALUES ('PM','MAESTROS','EQUI','MAESTRO_EQUIPOS',1,'A.*','');
INSERT INTO CARGA_STAGE VALUES ('PM','MAESTROS','EQKT','TEXTO_EQUIPOS',1,'A.*','');
INSERT INTO CARGA_STAGE VALUES ('PM','MAESTROS','EQKT','EQUIPOS',1,'A.*','');
INSERT INTO CARGA_STAGE VALUES ('PM','MAESTROS','IFLOT','UBICACION_TECNICA',1,'A.TPLKZ,A.ILOAN,A.FLTYP,A.MANDT,A.MLANG,A.TPLNR,B.PLTXT','INNER JOIN HDKSAPSQL.PRD.prd.IFLOTX B WITH (NOLOCK) ON A.MANDT=B.MANDT AND A.TPLNR=B.TPLNR AND A.MLANG=B.SPRAS');
INSERT INTO CARGA_STAGE VALUES ('PM','MAESTROS','TJ02T','TEXTO_STATUS_SISTEMA',1,'A.*','WHERE A.SPRAS=''S''');
INSERT INTO CARGA_STAGE VALUES ('PM','MAESTROS','QPCT','CIRCUNSTANCIA',1,'A.*','');
INSERT INTO CARGA_STAGE VALUES ('PM','MAESTROS','CSKS','MAESTRO_CENTRO_COSTO',1,'A.MANDT,A.KOKRS,A.KOSTL,A.DATBI,A.KHINR,B.LTEXT,C.DESCRIPT,B.KTEXT','INNER JOIN HDKSAPSQL.PRD.prd.CSKT B WITH (NOLOCK) ON A.MANDT = B.MANDT AND A.KOKRS = B.KOKRS AND A.KOSTL = B.KOSTL AND A.DATBI = B.DATBI AND B.SPRAS = ''S'' INNER JOIN HDKSAPSQL.PRD.prd.SETHEADERT C WITH (NOLOCK) on A.MANDT = C.MANDT AND A.KHINR = C.SETNAME AND C.SETCLASS = ''0101'' AND C.SUBCLASS = ''HDKC'' AND C.LANGU = ''S''');
INSERT INTO CARGA_STAGE VALUES ('PM','MAESTROS','TPIR2T','CATEGORIA_VALOR',1,'A.*','WHERE A.LANGU=''S''');
INSERT INTO CARGA_STAGE VALUES ('PM','MAESTROS','T352R','REVISION',1,'A.*','');
INSERT INTO CARGA_STAGE VALUES ('PM','MAESTROS','T003P','CLASE_ORDEN',1,'A.*','WHERE A.SPRAS=''S''');
INSERT INTO CARGA_STAGE VALUES ('PM','MAESTROS','TQ80_T','CLASE_AVISOS',1,'A.*','WHERE A.SPRAS=''S''');
INSERT INTO CARGA_STAGE VALUES ('PM','MAESTROS','T356_T','PRIORIDAD',1,'A.*','WHERE A.SPRAS=''S''');
INSERT INTO CARGA_STAGE VALUES ('PM','MAESTROS','T353I_T','CLASE_ACTIVIDAD',1,'A.*','WHERE A.SPRAS=''S''');
INSERT INTO CARGA_STAGE VALUES ('PM','MAESTROS','T024I','GRUPO_PLANIFICADOR',1,'A.*','INNER JOIN MANDANTES B WITH (NOLOCK) on A.MANDT = B.MANDT');
INSERT INTO CARGA_STAGE VALUES ('PM','MAESTROS','T356A_T','CLASE_PRIORIDAD',1,'A.*','WHERE A.SPRAS=''S''');
INSERT INTO CARGA_STAGE VALUES ('PM','MAESTROS','T357A_T','REPERCUSION',1,'A.*','INNER JOIN MANDANTES B WITH (NOLOCK) ON A.MANDT = B.MANDT WHERE SPRAS=''S''');
INSERT INTO CARGA_STAGE VALUES ('PM','MAESTROS','T370F','TIPO_UBICACION_TECNICA',1,'A.MANDT,A.FLTYP,A.STSMA,A.PARGR,A.SALES,A.ELSE_KNZ,A.MPTYP,A.CHDOC,A.INFOW,A.TSEGTP,A.VIEW_PROF,A.CHDOC_INS,B.TYPTX','INNER JOIN HDKSAPSQL.PRD.prd.T370F_T B WITH (NOLOCK) ON A.MANDT=B.MANDT AND B.SPRAS=''S''AND A.FLTYP=B.FLTYP INNER JOIN MANDANTES C WITH (NOLOCK) ON A.MANDT = C.MANDT');
INSERT INTO CARGA_STAGE VALUES ('PM','MAESTROS','T435T','CLAVE_MODELO',1,'A.*','INNER JOIN MANDANTES B WITH (NOLOCK) on A.MANDT = B.MANDT');