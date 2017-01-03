-- *************************************************
-- *********    MODIFICAR VARIABLES     ************
-- *************************************************
DECLARE @MODULO_SAP VARCHAR(75) = <Modulo_SAP>, @TABLA_STAGE VARCHAR(75) = <Tabla_Stage>, @HORARIO VARCHAR(75) = <Horario>
		, @LOG_ID INT, @MENSAJE VARCHAR(MAX);

BEGIN TRY
	
	-- LOG INI
	INSERT INTO CARGA_STAGE_LOG VALUES (@MODULO_SAP, 'POST_SCRIPT', @TABLA_STAGE, CAST(GETDATE()AS DATE), @HORARIO, GETDATE(), NULL, 0, 0, 'Inicio Carga', 0);
	SET @LOG_ID = @@IDENTITY;

	-- *****************************************
	-- *********    PEGAR QUERY     ************
	-- *****************************************
	
	-- LOG FIN
	UPDATE CARGA_STAGE_LOG SET FECHA_FIN = GETDATE(), DURACION = DATEDIFF(SECOND,FECHA_INI,GETDATE()), REGISTROS = @@ROWCOUNT, EXITO = 1, MENSAJE = 'Carga completa' WHERE LOG_ID = @LOG_ID;

END TRY
BEGIN CATCH

	SET @MENSAJE = ERROR_MESSAGE()
	UPDATE CARGA_STAGE_LOG SET FECHA_FIN = GETDATE(), REGISTROS = @@ROWCOUNT, EXITO = 0, MENSAJE = @MENSAJE WHERE LOG_ID = @LOG_ID;
	RETURN

END CATCH
