




-- =============================================
-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	2017-01-13 TeamErgon Sprint 1
-- Description:			    Vista que trae el detalle de las recepciones de sap


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-01-18 Team ERGON - Sprint ERGON 1
-- Description:	 Se agrega al select el campo OBJECT_TYPE

-- Modificacion 09-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
-- alberto.ruiz
-- Ajuste por intercompany

-- Modificacion 12-Jan-18 @ Nexus Team Sprint Ransey
-- alberto.ruiz
-- Se agrega columna [WhsCode]


/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [ferco].[ERP_VIEW_RECEPTION_DOCUMENT_DETAIL] 
					
*/
-- =============================================
CREATE VIEW [ferco].[ERP_VIEW_RECEPTION_DOCUMENT_DETAIL]
AS
SELECT *
FROM OPENQUERY
     ([SAPSERVER],
      'SELECT 
		CAST( poD.DocEntry as varchar)  AS SAP_RECEPTION_ID --DOC_ENTRY
		,po.DocNum AS ERP_DOC --DOC_NUM
		,po.CardCode AS PROVIDER_ID
		,po.CardName AS PROVIDER_NAME
 		,pod.ItemCode AS SKU
		,pod.dscription AS SKU_DESCRIPTION
		,pod.OpenQty AS QTY
    ,pod.ObjType as OBJECT_TYPE
		,pod.LineNum AS LINE_NUM
		,CASE ISNULL(PO.COMMENTS,'''')
			WHEN '''' THEN ''N/A''
			ELSE PO.COMMENTS
		END AS COMMENTS
		,pod.ItemCode [MASTER_ID_SKU]
		,''ferco'' [OWNER_SKU]
		,''ferco'' [OWNER]
		,POD.[WhsCode] [ERP_WAREHOUSE_CODE]
		,[POD].[UomCode] [UNIT]
		,[UM].[UomName] [UNIT_DESCRIPTION]
	FROM [SBOFERCO].dbo.por1 POD
	inner join [SBOFERCO].DBO.OPOR PO ON (po.DocEntry = pod.DocEntry)
	LEFT JOIN [SBOFERCO].[dbo].[OUOM] UM ON [UM].[UomEntry] = [POD].[UomEntry]
	where 
		po.DocStatus=''O''
		AND po.DocType=''I''
		AND pod.OpenQty > 0 '
     )
/*
UNION ALL
SELECT *
FROM OPENQUERY
     ([SAPSERVER],
      'SELECT 
		CAST( poD.DocEntry as varchar)  AS SAP_RECEPTION_ID --DOC_ENTRY
		,po.DocNum AS ERP_DOC --DOC_NUM
		,po.CardCode AS PROVIDER_ID
		,po.CardName AS PROVIDER_NAME
 		,pod.ItemCode AS SKU
		,pod.dscription AS SKU_DESCRIPTION
		,pod.OpenQty AS QTY
    ,pod.ObjType as OBJECT_TYPE
		,pod.LineNum AS LINE_NUM
		,CASE ISNULL(PO.COMMENTS,'''')
			WHEN '''' THEN ''N/A''
			ELSE PO.COMMENTS
		END AS COMMENTS
		,pod.ItemCode [MASTER_ID_SKU]
		,''DETALLES'' [OWNER_SKU]
		,''DETALLES'' [OWNER]
		,POD.[WhsCode] [ERP_WAREHOUSE_CODE]
		,[POD].[UomCode] [UNIT]
		,[UM].[UomName] [UNIT_DESCRIPTION]
	FROM [DETALLES].dbo.por1 POD
	INNER JOIN [DETALLES].[dbo].[OPOR] PO ON (po.DocEntry = pod.DocEntry)
	LEFT JOIN [DETALLES].[dbo].[OUOM] UM ON [UM].[UomEntry] = [POD].[UomEntry]
	where po.DocStatus=''O''
		AND po.DocType=''I''
		AND pod.OpenQty > 0 '
     )*/
--	 UNION ALL
--SELECT *
--FROM OPENQUERY
--     ([SAPSERVER],
--      'SELECT 
--		CAST( poD.DocEntry as varchar)  AS SAP_RECEPTION_ID --DOC_ENTRY
--		,po.DocNum AS ERP_DOC --DOC_NUM
--		,po.CardCode AS PROVIDER_ID
--		,po.CardName AS PROVIDER_NAME
-- 		,pod.ItemCode AS SKU
--		,pod.dscription AS SKU_DESCRIPTION
--		,pod.OpenQty AS QTY
--    ,pod.ObjType as OBJECT_TYPE
--		,pod.LineNum AS LINE_NUM
--		,CASE ISNULL(PO.COMMENTS,'''')
--			WHEN '''' THEN ''N/A''
--			ELSE PO.COMMENTS
--		END AS COMMENTS
--		,pod.ItemCode [MASTER_ID_SKU]
--		,''VOI7'' [OWNER_SKU]
--		,''VOI7'' [OWNER]
--		,POD.[WhsCode] [ERP_WAREHOUSE_CODE]
--		,[POD].[UomCode] [UNIT]
--		,[UM].[UomName] [UNIT_DESCRIPTION]
--	FROM [CASA_OAKLAND].dbo.por1 POD
--	INNER JOIN [CASA_OAKLAND].[dbo].[OPOR] PO ON (po.DocEntry = pod.DocEntry)
--	LEFT JOIN [CASA_OAKLAND].[dbo].[OUOM] UM ON [UM].[UomEntry] = [POD].[UomEntry]
--	where po.DocStatus=''O''
--		AND po.DocType=''I''
--		AND pod.OpenQty > 0 '
--     )
--	  UNION ALL 
--	 SELECT *
--FROM OPENQUERY
--     ([SAPSERVER],
--      'SELECT 
--		CAST( poD.DocEntry as varchar)  AS SAP_RECEPTION_ID --DOC_ENTRY
--		,po.DocNum AS ERP_DOC --DOC_NUM
--		,po.CardCode AS PROVIDER_ID
--		,po.CardName AS PROVIDER_NAME
-- 		,pod.ItemCode AS SKU
--		,pod.dscription AS SKU_DESCRIPTION
--		,pod.OpenQty AS QTY
--    ,pod.ObjType as OBJECT_TYPE
--		,pod.LineNum AS LINE_NUM
--		,CASE ISNULL(PO.COMMENTS,'''')
--			WHEN '''' THEN ''N/A''
--			ELSE PO.COMMENTS
--		END AS COMMENTS
--		,pod.ItemCode [MASTER_ID_SKU]
--		,''ALMASA'' [OWNER_SKU]
--		,''ALMASA'' [OWNER]
--		,POD.[WhsCode] [ERP_WAREHOUSE_CODE]
--		,[POD].[UomCode] [UNIT]
--		,[UM].[UomName] [UNIT_DESCRIPTION]
--	FROM [SBO_ALMASA].dbo.por1 POD
--	inner join [SBO_ALMASA].DBO.OPOR PO ON (po.DocEntry = pod.DocEntry)
--	LEFT JOIN [SBO_ALMASA].[dbo].[OUOM] UM ON [UM].[UomEntry] = [POD].[UomEntry]
--	where 
--		po.DocStatus=''O''
--		AND po.DocType=''I''
--		AND pod.OpenQty > 0 '
--     );

