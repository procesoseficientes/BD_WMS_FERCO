










/*
--	12/28/2020		Gildardo Alvarado
					Se intercambiaron nombres de las columnas [DispWMS] y [Total Wms]

					select * from  [FERCO].[OP_WMS_VIEW_QA] where codigo='ferco/000240'
				
*/ 

-- =============================================
CREATE VIEW [FERCO].[OP_WMS_VIEW_QA]
AS
SELECT 
    ISNULL([A].[CURRENT_WAREHOUSE],[X].[CODE_WAREHOUSE]) AS [Bodega]
	,ISNULL([A].[MATERIAL_ID],[X].[CODE_SKU]) AS [Codigo]
	,[A].[MATERIAL_NAME] AS [Nombre]
	,ISNULL([A].[AVAILABLE], 0)
	 AS [DispWMS]
	,ISNULL([A].[INVENTORY_IN_RECEPTION], 0) [Inv recibido sin confirmación]
	,ISNULL([A].[PICKED_PENDING_ERP], 0) [Inventario Preparado]
	,ISNULL([A].[PICKED_PENDING_ERP_WT], 0) [Inventario Preparado WT]
	,ISNULL([A].[AVAILABLE], 0)  
	+ ISNULL([A].[INVENTORY_IN_RECEPTION], 0)
	+ ISNULL([A].[PICKED_PENDING_ERP], 0)
	+ ISNULL([A].[PICKED_PENDING_ERP_WT], 0)
	  AS [Total Wms]
	,ISNULL([X].[ON_HAND], 0) [Inv ERP]
	,(ISNULL([A].[AVAILABLE], 0) 
	+ ISNULL([A].[INVENTORY_IN_RECEPTION], 0)
	+ ISNULL([A].[PICKED_PENDING_ERP], 0)
	+ ISNULL([A].[PICKED_PENDING_ERP_WT], 0)) - ISNULL([X].[ON_HAND], 0) AS Diferencia

FROM
	[FERCO].[OP_WMS_VIEW_CONSOLIDATE_QA] [A]
full outer JOIN [SWIFT_INTERFACES_ONLINE].[ferco].[ERP_VIEW_INVENTORY_ONLINE_SAP] [X] ON (
											[X].[CODE_WAREHOUSE] = [A].ERP_WAREHOUSE COLLATE DATABASE_DEFAULT
											AND [X].[CODE_SKU] = [FERCO].[OP_WMS_FN_SPLIT_COLUMNS]([A].[MATERIAL_ID],
											2, '/')
											)
--LEFT JOIN [FERCO].[OP_WMS_MATERIALS] [M] ON ([X].[CODE_SKU] =  [M].[ITEM_CODE_ERP])
	
