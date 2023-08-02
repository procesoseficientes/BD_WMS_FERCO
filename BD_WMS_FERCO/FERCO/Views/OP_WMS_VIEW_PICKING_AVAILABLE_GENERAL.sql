

-- =============================================
-- Autor:	--
-- Fecha de Creacion: 	--
-- Description:	 --

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-04-12 Team ERGON - Sprint ERGON EPONA
-- Description:	 Se agrega cambio en calcular inventario comprometido.

-- Modificación: pablo.aguilar
-- Fecha de Modificaci[on: 2017-04-28 ErgonTeam@Ganondorf
-- Description:	 Se agrega la zona 

-- Modificacion 9/7/2017 @ Reborn-Team Sprint Collin
-- diego.as
-- Se agrega JOIN a la tabla [OP_WMS_INV_X_LICENSE] para no tomar en cuenta el inventario bloqueado por estado
-- Ademas se quita duplicidad de JOIN a la tabla OP_WMS_POLIZA_HEADER

-- Modificacion 19/9/2017 @ Reborn-Team Sprint Collin
-- rudi.garcia
-- Se agrego la condicion "[LOCKED_BY_INTERFACES] <> 1"

-- Modificacion 22-Dec-17 @ Nexus Team Sprint @IceAge
-- pablo.aguilar
-- Se unifican criterios para obtener licencias para picking

-- Modificacion:			marvin.solares
-- Fecha: 					20180926 GForce@Kiwi 
-- Description:				se agrega la columna allow_fast_picking en el query de la vista

-- Autor:				rudi.garcia
-- Fecha de Creacion: 	26-Jul-2019 @ G-Force-Team Sprint Dublin
-- Description:			se agrega manejo de proyectos

/*
-- Ejemplo de Ejecucion:
			SELECT * FROM [FERCO].[OP_WMS_VIEW_PICKING_AVAILABLE_GENERAL]
*/
-- =============================================
CREATE VIEW [FERCO].[OP_WMS_VIEW_PICKING_AVAILABLE_GENERAL]
AS
SELECT
	[IL].[MATERIAL_ID]
	,[IL].[MATERIAL_NAME]
	,[M].[CLIENT_OWNER]
	,[M].[ALTERNATE_BARCODE]
	,[M].[BARCODE_ID]
	,[IL].[TERMS_OF_TRADE]
	,[CL].[CLIENT_NAME]
	,[L].[CODIGO_POLIZA]
	,[PH].[FECHA_DOCUMENTO]
	,[L].[CURRENT_LOCATION]
	,[L].[CURRENT_WAREHOUSE]
	,[L].[LICENSE_ID]
	,CASE	WHEN [IL].[QTY] - ISNULL([CI].[COMMITED_QTY], 0) < 0
			THEN 0
			ELSE [IL].[QTY] - ISNULL([CI].[COMMITED_QTY], 0)
		END AS [QTY]
	,ISNULL([CI].[COMMITED_QTY], 0) [COMMITED_QTY]
	,[IL].[QTY] [LICENCE_QTY]
	,[M].[BATCH_REQUESTED]
	,[M].[IS_CAR]
	,[SH].[ZONE]
	,[SH].[ALLOW_FAST_PICKING] [ALLOW_FAST_PICKING]
	,[IL].[STATUS_ID]
	,[SML].[STATUS_CODE]
FROM
	[FERCO].[OP_WMS_INV_X_LICENSE] AS [IL]
INNER JOIN [FERCO].[OP_WMS_MATERIALS] AS [M] ON ([IL].[MATERIAL_ID] = [M].[MATERIAL_ID])
INNER JOIN [FERCO].[OP_WMS_LICENSES] AS [L] ON ([IL].[LICENSE_ID] = [L].[LICENSE_ID])
INNER JOIN [FERCO].[OP_WMS_SHELF_SPOTS] [SH] WITH (INDEX ([IDX_OP_WMS_SHELF_SPOTS_ALLOW_PICKING])) ON ([L].[CURRENT_LOCATION] = [SH].[LOCATION_SPOT])
INNER JOIN [FERCO].[OP_WMS_VIEW_CLIENTS] AS [CL] ON (CAST([L].[CLIENT_OWNER] COLLATE DATABASE_DEFAULT AS NVARCHAR(15)) = [CL].[CLIENT_CODE])
INNER JOIN [FERCO].[OP_WMS_POLIZA_HEADER] [PH] ON [L].[CODIGO_POLIZA] = [PH].[CODIGO_POLIZA]
--INNER JOIN [FERCO].[OP_WMS_TARIFICADOR_HEADER] [TH] ON [PH].[ACUERDO_COMERCIAL]= [TH].[ACUERDO_COMERCIAL_ID]
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
	AND [IL].[PROJECT_ID] IS NULL;
