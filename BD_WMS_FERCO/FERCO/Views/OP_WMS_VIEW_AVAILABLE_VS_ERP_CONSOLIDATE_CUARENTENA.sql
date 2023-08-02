﻿CREATE VIEW [FERCO].[OP_WMS_VIEW_AVAILABLE_VS_ERP_CONSOLIDATE_CUARENTENA]
AS
SELECT
	[A].[CURRENT_WAREHOUSE] AS [Bodega]
	,[A].[MATERIAL_ID] AS [Codigo]
	,[A].[MATERIAL_NAME] AS [Nombre]
	,ISNULL([A].[AVAILABLE], 0) -- ISNULL([A].[INV_ZZ], 0)
	 AS [DispWMS]
	--,ISNULL([A].[INV_ZZ], 0) AS [Inventario ZZ]
	,ISNULL([A].[INVENTORY_IN_RECEPTION], 0) [Inv recibido sin confirmación]
	,ISNULL([A].[PICKED_PENDING_ERP], 0) [Inventario Preparado]
	,ISNULL([A].[PICKED_PENDING_ERP_WT], 0) [Inventario Preparado WT]
	,ISNULL([A].[AVAILABLE], 0) - --ISNULL([A].[INV_ZZ], 0)
	+ ISNULL([A].[INVENTORY_IN_RECEPTION], 0)
	+ ISNULL([A].[PICKED_PENDING_ERP], 0)
	+ ISNULL([A].[PICKED_PENDING_ERP_WT], 0)
	 [Total Wms]
	,ISNULL([X].[ON_HAND], 0) [Inv ERP]
	,ISNULL([X].[ON_HAND_01], 0) [Inv ERP 01]
	,ISNULL([X].[ON_HAND_03], 0) [Inv ERP 03]
	--,(ISNULL([A].[AVAILABLE], 0) - ISNULL([A].[INV_ZZ], 0)
	--	+ ISNULL([A].[PICKED_PENDING_ERP], 0)
	--	- ISNULL([A].[PICKED_PENDING_ERP_WT], 0))
	--- ISNULL([X].[ON_HAND], 0) [Diferencia]
	,  ISNULL([A].[AVAILABLE], 0) - --ISNULL([A].[INV_ZZ], 0)

	+ ISNULL([A].[PICKED_PENDING_ERP], 0)
	+ ISNULL([A].[PICKED_PENDING_ERP_WT], 0)
	- ISNULL([X].[ON_HAND], 0) AS [Diferencia]
FROM
	[FERCO].[OP_WMS_VIEW_GET_CONSOLIDATE_WMS_INVENTORY_STATUS_BY_WH_CUARENTENA_CEDI] [A]
LEFT JOIN [SWIFT_INTERFACES_ONLINE].[ferco].[ERP_VIEW_INVENTORY_ONLINE_WS_18] [X] ON (
											[X].[CODE_WAREHOUSE] = [A].[ERP_WAREHOUSE]
											AND [X].[CODE_SKU] = [FERCO].[OP_WMS_FN_SPLIT_COLUMNS]([A].[MATERIAL_ID],
											2, '/')
											)