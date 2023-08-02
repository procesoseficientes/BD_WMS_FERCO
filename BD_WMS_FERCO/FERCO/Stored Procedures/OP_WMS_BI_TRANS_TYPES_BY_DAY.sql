-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	13-Aug-18 @ Nexus Team Sprint @FocaMonje 
-- Description:			SP que 
/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[OP_WMS_BI_TRANS_TYPES_BY_DAY]
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_BI_TRANS_TYPES_BY_DAY]
AS
BEGIN
	
	--
	DECLARE	@LAST_DATE_LOGGED DATE  = '00010101';
	
	SELECT TOP 1
		@LAST_DATE_LOGGED = [Date]
	FROM
		[SCM_BI].[dbo].[DAILY_TRANSACTION_ANALISIS]
	ORDER BY
		[Date] DESC;	
	
	
	
	
	INSERT	INTO [SCM_BI].[dbo].[DAILY_TRANSACTION_ANALISIS]
			(
				[User]
				,[UserName]
				,[TransType]
				,[TransTypeDescription]
				,[Date]
				,[DateTimeFirstTransaction]
				,[DateTimeLastTransaction]
				,[QuantityUnits]
				,[TransactionCount]
			)
	SELECT
		[USUARIO]
		,[NOMBRE_USUARIO]
		,[TIPO_TRANSACCION]
		,[DESCRIPCION_TIPO_TRANSACCION]
		,[FECHA_TRANSACCION]
		,[PRIMERA_TRANSACCION]
		,[ULTIMA_TRANSACCION]
		,[UNIDADES]
		,[TOTAL_TRANSACCIONES]
	FROM
		[FERCO].[OP_WMS_VIEW_DAILY_TRANSACTION_BY_TYPE_AND_USER]
	WHERE
		[FECHA_TRANSACCION] > @LAST_DATE_LOGGED;
	


END;

