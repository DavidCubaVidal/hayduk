DECLARE @tableHTML  NVARCHAR(MAX) ;

SET @tableHTML =
   N'<head>' +
    N'<style type="text/css">h2, body {font-family: Arial, verdana;} table{font-size:11px; border-collapse:collapse;} td{background-color:#F1F1F1; border:1px solid black; padding:3px;} th{background-color:#99CCFF;}</style>' +
   N'<h2><font color="red" size="4">ERROR: CARGA DE DATOS EN STAGE</font></h2>' +   
   N'</head>' +
N'<body>' +
N' <hr> ' +
N' ' +   
   	
    N'<table border="1">' +
    N'<tr><th>MODULO_SAP</th><th>TABLA_STAGE</th>' +
    N'<th>TABLA_SAP</th><th>HORARIO</th><th>FECHA_INI</th>' +
    N'<th>MENSAJE</th>
    
    </tr>' +
	CAST ( ( SELECT td = MODULO_SAP,       '',
                    td = TABLA_STAGE, '',
                    td = TABLA_SAP, '',
                    td = HORARIO, '',
                    td = FECHA_INI, '',
                    td = MENSAJE
              FROM CARGA_STAGE_LOG
              WHERE EXITO != 1
                AND FECHA = CAST(GETDATE() AS DATE)
              FOR XML PATH('tr'), TYPE 
    ) AS NVARCHAR(MAX) ) +
    N'</table>' ;

DECLARE @oper_email NVARCHAR(MAX) = (select email_address from msdb.dbo.sysoperators WHERE NAME = 'Administradores');
EXEC msdb.dbo.sp_send_dbmail --@recipients='dcuba@hayduk.com.pe',
	@recipients = @oper_email,
    @profile_name = 'AdministradorBI',
    @subject = 'ERROR: CARGA DATOS EN STAGE',
    @body = @tableHTML,
    @body_format = 'HTML' ;

/*
EXEC msdb.dbo.sysmail_help_configure_sp;
EXEC msdb.dbo.sysmail_help_account_sp;
EXEC msdb.dbo.sysmail_help_profile_sp;
EXEC msdb.dbo.sysmail_help_profileaccount_sp;
EXEC msdb.dbo.sysmail_help_principalprofile_sp;
*/

SELECT COUNT(EXITO)
FROM CARGA_STAGE_LOG
WHERE EXITO != 1
  AND FECHA = CAST(GETDATE() AS DATE)
  

update CARGA_STAGE_LOG
set EXITO = 1
where LOG_ID=8


