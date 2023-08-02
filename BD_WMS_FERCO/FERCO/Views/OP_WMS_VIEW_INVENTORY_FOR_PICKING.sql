
-- =============================================
-- Autor:	        rudi.garci
-- Fecha de Creacion: 	2017-04-18 @ Team ERGON - Sprint Epona
-- Description:	        Vista que obtiene el inventario disponible para crear una tarea picking

-- Modificacion 9/7/2017 @ Reborn-Team Sprint Collin
-- diego.as
-- Se agrega JOIN a la tabla [OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] para no tomar en cuenta el inventario bloqueado por estado

-- Modificacion 9/7/2017 @ Reborn-Team Sprint Collin
-- rudi.garcia
-- Se agrego la condicion "[LOCKED_BY_INTERFACES] <> 1"

-- Modificacion 19-Dec-17 @ Nexus Team Sprint @IceAge
-- pablo.aguilar
--  Se modifican las condiciones para que este igual que OP_WMS_VIEW_PICKING_AVAILABLE_GENERAL y se modifican formato y condiciones por indices.

-- Autor:				rudi.garcia
-- Fecha de Creacion: 	26-Jul-2019 @ G-Force-Team Sprint Dublin
-- Description:			se agrega validacion de proyecto en el where

/*
-- Ejemplo de Ejecucion:
			SELECT  * FROM [FERCO].[OP_WMS_VIEW_INVENTORY_FOR_PICKING]  
*/
-- =============================================
CREATE VIEW [FERCO].[OP_WMS_VIEW_INVENTORY_FOR_PICKING]
AS
SELECT
	[M].[MATERIAL_ID]
	,[M].[MATERIAL_NAME]
	,[CL].[CLIENT_CODE]
	,[CL].[CLIENT_NAME]
	,[L].[REGIMEN]
	,[L].[CURRENT_WAREHOUSE]
	,SUM([IL].[QTY]) AS [QTY]
	,ISNULL(SUM([CI].[COMMITED_QTY]), 0) AS [COMMITED_QTY]
	,CASE	WHEN SUM([IL].[QTY])
					- ISNULL(SUM([CI].[COMMITED_QTY]), 0) < 0
			THEN 0
			ELSE SUM([IL].[QTY])
					- ISNULL(SUM([CI].[COMMITED_QTY]), 0)
		END AS [AVAILABLE_QTY]
FROM
	[FERCO].[OP_WMS_INV_X_LICENSE] AS [IL]
INNER JOIN [FERCO].[OP_WMS_MATERIALS] AS [M] ON ([IL].[MATERIAL_ID] = [M].[MATERIAL_ID])
INNER JOIN [FERCO].[OP_WMS_LICENSES] AS [L] ON ([IL].[LICENSE_ID] = [L].[LICENSE_ID])
INNER JOIN [FERCO].[OP_WMS_SHELF_SPOTS] [SH] WITH (INDEX ([IDX_OP_WMS_SHELF_SPOTS_ALLOW_PICKING])) ON ([L].[CURRENT_LOCATION] = [SH].[LOCATION_SPOT])
INNER JOIN [FERCO].[OP_WMS_VIEW_CLIENTS] AS [CL] ON (CAST([L].[CLIENT_OWNER] COLLATE DATABASE_DEFAULT AS NVARCHAR(15)) = [CL].[CLIENT_CODE])
INNER JOIN [FERCO].[OP_WMS_POLIZA_HEADER] [PH] ON [L].[CODIGO_POLIZA] = [PH].[CODIGO_POLIZA]
--INNER JOIN [FERCO].[OP_WMS_TARIFICADOR_HEADER] [TH] ON [PH].[ACUERDO_COMERCIAL] = [TH].[ACUERDO_COMERCIAL_ID]
INNER JOIN [FERCO].[OP_WMS_CONFIGURATIONS] [C] ON (
											[C].[PARAM_TYPE] = 'PRODUCTOS'
											AND [C].[PARAM_GROUP] = 'BLOQUEO_EXPIRACION'
											AND [C].[PARAM_NAME] = 'BLOQUEO_DIAS_PRONTA_EXPIRACION'
											)
LEFT JOIN [FERCO].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [CI] ON (
											[CI].[LICENCE_ID] = [IL].[LICENSE_ID]
											AND [CI].[MATERIAL_ID] = [IL].[MATERIAL_ID]
											)
INNER JOIN [FERCO].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SML] ON (
											[SML].[STATUS_ID] = [IL].[STATUS_ID]
											AND [SML].[BLOCKS_INVENTORY] = 0
											)
WHERE
	[IL].[PK_LINE] > 0
	AND [L].[REGIMEN] = 'GENERAL'
	AND [IL].[QTY] > 0
	--AND GETDATE() BETWEEN [TH].[VALID_FROM]
	--				AND		[TH].[VALID_TO]
	AND [SH].[ALLOW_PICKING] = 1
	AND [L].[CURRENT_LOCATION] IS NOT NULL
	AND (
			(
				[M].[BATCH_REQUESTED] = 1
				AND GETDATE() < DATEADD(DAY,
										[C].[NUMERIC_VALUE]
										* -1,
										[IL].[DATE_EXPIRATION])
			)
			OR (
				[M].[BATCH_REQUESTED] = 0
				AND [IL].[DATE_EXPIRATION] IS NULL
				)
		)
	AND [IL].[LOCKED_BY_INTERFACES] = 0
	AND [IL].[PROJECT_ID] IS NULL
GROUP BY
	[M].[MATERIAL_ID]
	,[M].[MATERIAL_NAME]
	,[CL].[CLIENT_CODE]
	,[CL].[CLIENT_NAME]
	,[L].[REGIMEN]
	,[L].[CURRENT_WAREHOUSE];
