

-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		16-Aug-17 @ A-Team Sprint Banjo-Kazooie
-- Description:			    Vista que obtiene el detalle de las solicitudes de transferencia

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [ferco].[ERP_VW_TRANSFER_REQUEST_DETAIL]
*/
-- =============================================
CREATE VIEW [ferco].[ERP_VW_TRANSFER_REQUEST_DETAIL]
AS (
	SELECT *  
	FROM OPENQUERY([SAPSERVER],'
		SELECT
			[WTQ].[DocEntry] [DOC_ENTRY]
			,(''ferco/'' + [WTQ].[ItemCode] COLLATE DATABASE_DEFAULT) [MATERIAL_ID]
			,[WTQ].[ItemCode] COLLATE DATABASE_DEFAULT [MATERIAL_MASTER_ID]
			,''ferco'' [MATERIAL_OWNER]
			,[WTQ].[FromWhsCod] [FROM_WAREHOUSE_CODE]
			,[WTQ].[WhsCode] [TO_WAREHOUSE_CODE]
			,[WTQ].[LineNum] [LINE_NUM]
			,[WTQ].[Quantity] [QTY]
			,[WTQ].[ObjType] [ERP_OBJECT_TYPE]
			,''ferco'' [SOURCE]
			, wtq.unitMsr
		FROM [SBOFERCO].[dbo].[WTQ1] [WTQ]
	')
	--UNION ALL 
	--	SELECT *  
	--FROM OPENQUERY([SAPSERVER],'
	--	SELECT
	--		[WTQ].[DocEntry] [DOC_ENTRY]
	--		,(''ALMASA/'' + [WTQ].[ItemCode] COLLATE DATABASE_DEFAULT) [MATERIAL_ID]
	--		,[WTQ].[ItemCode] COLLATE DATABASE_DEFAULT [MATERIAL_MASTER_ID]
	--		,''ALMASA'' [MATERIAL_OWNER]
	--		,[WTQ].[FromWhsCod] [FROM_WAREHOUSE_CODE]
	--		,[WTQ].[WhsCode] [TO_WAREHOUSE_CODE]
	--		,[WTQ].[LineNum] [LINE_NUM]
	--		,[WTQ].[Quantity] [QTY]
	--		,[WTQ].[ObjType] [ERP_OBJECT_TYPE]
	--		,''ALMASA'' [SOURCE]
	--		, wtq.unitMsr
	--	FROM [SBO_ALMASA].[dbo].[WTQ1] [WTQ]
	--')
)


