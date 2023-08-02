
-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		16-Aug-17 @ A-Team Sprint Banjo-Kazooie
-- Description:			    Vista que obtiene las solicitudes de transferencia

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [ferco].[ERP_VW_TRANSFER_REQUEST_HEADER]
*/
-- =============================================
CREATE VIEW [ferco].[ERP_VW_TRANSFER_REQUEST_HEADER]
AS
SELECT
    *
  FROM OPENQUERY([SAPSERVER], '
		SELECT
			[WTQ].[DocNum] [DOC_NUM]
			,[WTQ].[DocEntry] [DOC_ENTRY]
			,[WTQ].[Filler] [FROM_WAREHOUSE_CODE]
			,[WTQ].[ToWhsCode] [TO_WAREHOUSE_CODE]
			,[WTQ].[DocDate] [DOC_DATE]
			,[WTQ].[DocDueDate] [DOC_DUE_DATE]
			,[WTQ].[DocStatus] [DOC_STATUS]
			,[WTQ].[CardCode] [CLIENT_ID]
			,[WTQ].[CardName] [CLIENT_NAME]
			,''ferco'' [SOURCE]
      ,ISNULL([WTQ].[Comments], ''N/A'') AS  [COMMENTS]
      ,ISNULL([WTQ].[Comments], ''N/A'') AS [U_sucursal]
      ,ISNULL([WTQ].[U_ESTADO2], ''0'') AS [U_ESTADO]
		 ,NULL AS PROJECT
			--,[WTQ].[U_Proyecto] AS PROJECT
		FROM [SBOFERCO].[dbo].[OWTQ] [WTQ]
		WHERE [WTQ].[DocStatus] = ''O''
	')
	/*
	UNION ALL
    SELECT
    *
  FROM OPENQUERY([SAPSERVER], '
		SELECT
			[WTQ].[DocNum] [DOC_NUM]
			,[WTQ].[DocEntry] [DOC_ENTRY]
			,[WTQ].[Filler] [FROM_WAREHOUSE_CODE]
			,[WTQ].[ToWhsCode] [TO_WAREHOUSE_CODE]
			,[WTQ].[DocDate] [DOC_DATE]
			,[WTQ].[DocDueDate] [DOC_DUE_DATE]
			,[WTQ].[DocStatus] [DOC_STATUS]
			,[WTQ].[CardCode] [CLIENT_ID]
			,[WTQ].[CardName] [CLIENT_NAME]
			,''DETALLES'' [SOURCE]
      ,ISNULL([WTQ].[Comments], ''N/A'') AS  [COMMENTS]
      ,ISNULL([WTQ].[Comments], ''N/A'') AS [U_sucursal]
      ,ISNULL([WTQ].[U_ESTADO2], ''0'') AS [U_ESTADO]
			,NULL AS PROJECT
		FROM [DETALLES].[dbo].[OWTQ] [WTQ]
		WHERE [WTQ].[DocStatus] = ''O''
	')*/
	--UNION ALL
 --   SELECT
 --   *
 -- FROM OPENQUERY([SAPSERVER], '
	--	SELECT
	--		[WTQ].[DocNum] [DOC_NUM]
	--		,[WTQ].[DocEntry] [DOC_ENTRY]
	--		,[WTQ].[Filler] [FROM_WAREHOUSE_CODE]
	--		,[WTQ].[ToWhsCode] [TO_WAREHOUSE_CODE]
	--		,[WTQ].[DocDate] [DOC_DATE]
	--		,[WTQ].[DocDueDate] [DOC_DUE_DATE]
	--		,[WTQ].[DocStatus] [DOC_STATUS]
	--		,[WTQ].[CardCode] [CLIENT_ID]
	--		,[WTQ].[CardName] [CLIENT_NAME]
	--		,''ALMASA'' [SOURCE]
 --     ,ISNULL([WTQ].[Comments], ''N/A'') AS  [COMMENTS]
 --     ,ISNULL([WTQ].[Comments], ''N/A'') AS [U_sucursal]
 --     ,ISNULL([WTQ].[U_ESTADO2], ''0'') AS [U_ESTADO]
	--		,NULL AS PROJECT
	--	FROM [SBO_ALMASA].[dbo].[OWTQ] [WTQ]
	--	WHERE [WTQ].[DocStatus] = ''O''
	--')

