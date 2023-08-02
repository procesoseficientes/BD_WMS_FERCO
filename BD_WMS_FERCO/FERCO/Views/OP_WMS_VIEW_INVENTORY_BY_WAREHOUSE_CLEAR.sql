


-- =============================================
-- Autor:					rudi.garcia
-- Fecha de Creacion: 		2017-03-24 @ Team ERGON Sprint Hyper
-- Description:			    Vista que trae el inventario disponible por bodega

/*
-- Ejemplo de Ejecucion:
		SELECT * FROM [FERCO].OP_WMS_VIEW_INVENTORY_BY_WAREHOUSE
*/
-- =============================================

CREATE VIEW [FERCO].[OP_WMS_VIEW_INVENTORY_BY_WAREHOUSE_CLEAR]
AS
SELECT
	[L].[CURRENT_WAREHOUSE]
	,[m].[MATERIAL_ID]
	,[m].[MATERIAL_NAME]
	,SUM([IL].[QTY]) [QTY]
	,[w].[ERP_WAREHOUSE] [ERP_WAREHOUSE]
FROM
	[FERCO].[OP_WMS_INV_X_LICENSE] [IL]
INNER JOIN [FERCO].[OP_WMS_LICENSES] [L] ON (
											[IL].[LICENSE_ID] = [L].[LICENSE_ID]
											)
											INNER JOIN [FERCO].[OP_WMS_MATERIALS] m ON [m].[MATERIAL_ID] = [IL].[MATERIAL_ID]
											INNER JOIN [FERCO].[OP_WMS_WAREHOUSES] w ON [w].[WAREHOUSE_ID] = [L].[CURRENT_WAREHOUSE]
LEFT JOIN [FERCO].[OP_WMS_FUNC_GET_INVENTORY_RESERVED]() [IR] ON (
											[IR].[CODE_WAREHOUSE] = [L].[CURRENT_WAREHOUSE]
											AND [IR].[CODE_MATERIAL] = [IL].[MATERIAL_ID]
											)

WHERE
	[L].[CURRENT_WAREHOUSE] IS NOT NULL AND [m].[NON_STORAGE] = 0
GROUP BY
	[L].[CURRENT_WAREHOUSE]
	,[w].[ERP_WAREHOUSE]
	,[m].[MATERIAL_ID]
	,[m].[MATERIAL_NAME];

