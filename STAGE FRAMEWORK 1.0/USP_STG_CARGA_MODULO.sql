--TEST:  EXEC [dbo].[USP_STG_CARGA_MODULO] 'PM', 'TEST';

ALTER PROCEDURE [dbo].[USP_STG_CARGA_MODULO] (
	@MODULO_SAP VARCHAR(75),
	@HORARIO VARCHAR(75)
	)
AS
BEGIN
SET NOCOUNT ON

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	-- Arreglo para seccion While
	IF OBJECT_ID('tempdb..#CARGA_STAGE') IS NOT NULL
		DROP TABLE #CARGA_STAGE

	SELECT TABLA_SAP, TABLA_STAGE, CAMPOS, FILTROS
	INTO #CARGA_STAGE
	FROM CARGA_STAGE
	WHERE MODULO_SAP = @MODULO_SAP AND ACTIVO = 1;

	-- Variables
	DECLARE @TABLA_SAP VARCHAR(75), @TABLA_STAGE VARCHAR(75), @CAMPOS VARCHAR(2000),
	@FILTROS VARCHAR(2000), @MENSAJE VARCHAR(MAX), @SQLCOMMAND VARCHAR(MAX), @LOG_ID INT;

	-- Bucle
	WHILE (
		SELECT Count(1)
		FROM #CARGA_STAGE
			) > 0
		BEGIN
		BEGIN TRY
			SELECT TOP 1 @TABLA_SAP = TABLA_SAP FROM #CARGA_STAGE;
			SELECT TOP 1 @TABLA_STAGE = TABLA_STAGE FROM #CARGA_STAGE;
			SELECT TOP 1 @CAMPOS = CAMPOS FROM #CARGA_STAGE;
			SELECT TOP 1 @FILTROS = FILTROS FROM #CARGA_STAGE;
			
			-- LOG INI
			INSERT INTO CARGA_STAGE_LOG VALUES (@MODULO_SAP, @TABLA_SAP, @TABLA_STAGE, CAST(GETDATE()AS DATE), @HORARIO, GETDATE(), NULL, 0, 0, 'Inicio Carga', 0);
			SET @LOG_ID = @@IDENTITY;

			-- Verificar si hay cambios en la tabla
			DECLARE @SQLCOMMAND_CHECKSUM_SAP NVARCHAR(MAX) = 'WITH TEMP_SAP AS(SELECT ' + @CAMPOS + ' FROM HDKSAPSQL.PRD.prd.' + @TABLA_SAP + ' A WITH (NOLOCK) ' + @FILTROS + ') SELECT @cnt_SAP = CHECKSUM_AGG(BINARY_CHECKSUM(*)) FROM TEMP_SAP'
			, @SQLCOMMAND_CHECKSUM_STAGE NVARCHAR(MAX) = 'SELECT @cnt_STAGE = CHECKSUM_AGG(BINARY_CHECKSUM(*)) FROM ' + @TABLA_STAGE + ' WITH (NOLOCK)',
			@SAP INT, @STAGE INT;

			EXECUTE sp_executesql @SQLCOMMAND_CHECKSUM_SAP, N'@cnt_SAP INT OUTPUT', @cnt_SAP = @SAP OUTPUT
			EXECUTE sp_executesql @SQLCOMMAND_CHECKSUM_STAGE, N'@cnt_STAGE INT OUTPUT', @cnt_STAGE = @STAGE OUTPUT

			IF (@SAP <> @STAGE OR @STAGE IS NULL) 
			BEGIN
				-- Copiar tabla
				SET @SQLCOMMAND = '
					SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

					IF OBJECT_ID(''' + @TABLA_STAGE + ''', ''U'') IS NOT NULL
					DROP TABLE ' + @TABLA_STAGE + ';

					SELECT ' + @CAMPOS + '
					INTO ' + @TABLA_STAGE + '
					FROM HDKSAPSQL.PRD.prd.' + @TABLA_SAP + ' A (NOLOCK) 
					' + @FILTROS + '
				'

				EXEC (@SQLCOMMAND)
				-- LOG FIN 'Carga completa'
				UPDATE CARGA_STAGE_LOG SET FECHA_FIN = GETDATE(), DURACION = DATEDIFF(SECOND,FECHA_INI,GETDATE()), REGISTROS = @@ROWCOUNT, EXITO = 1, MENSAJE = 'Carga completa' WHERE LOG_ID = @LOG_ID;
			END
			ELSE -- No se realizo la carga por que no hay cambios
				UPDATE CARGA_STAGE_LOG SET FECHA_FIN = GETDATE(), DURACION = DATEDIFF(SECOND,FECHA_INI,GETDATE()), REGISTROS = @@ROWCOUNT, EXITO = 1, MENSAJE = 'Sin modificar' WHERE LOG_ID = @LOG_ID;
				
			-- Borrar la tabla del arreglo
			DELETE #CARGA_STAGE WHERE TABLA_STAGE = @TABLA_STAGE;

		END TRY
		BEGIN CATCH

			-- LOG ERROR_MESSAGE
			SET @MENSAJE = ERROR_MESSAGE()
			UPDATE CARGA_STAGE_LOG SET FECHA_FIN = GETDATE(), REGISTROS = @@ROWCOUNT, EXITO = 0, MENSAJE = @MENSAJE WHERE LOG_ID = @LOG_ID;

			-- Borrar la tabla del arreglo
			DELETE #CARGA_STAGE WHERE TABLA_STAGE = @TABLA_STAGE;

		END CATCH
		END
END;


