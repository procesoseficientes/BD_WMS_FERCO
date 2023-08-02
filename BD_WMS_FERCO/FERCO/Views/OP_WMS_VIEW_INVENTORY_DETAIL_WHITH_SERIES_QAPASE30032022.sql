









-- =============================================
-- Autor:					        hector.gonzalez
-- Fecha de Creacion: 		22-05-2017
-- Description:			      Obtiene el detalle de inventario con series

-- Autor:					        rudi.garcia
-- Fecha de Modificacion:	15-06-2017
-- Description:			      Se agrego el campo "[IS_EXTERNAL_INVENTORY]"

-- Modificacion 19-Jul-17 @ Nexus Team Sprint AgeOfEmpires
-- alberto.ruiz
-- Se cambiaron los subselects por inner joins

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-09-05 @ Team REBORN - Sprint 
-- Description:	   Se agrego inner join [OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] y 3 columnas del mismo

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-09-15 @ Team REBORN - Sprint 
-- Description:	   Se agrego TONE y CALIBER

-- Modificacion 24-Jan-18 @ Nexus Team Sprint @KirbysAdventure
					-- pablo.aguilar
					-- Se modifica para que no duplique por poliza el inventario en linea.

-- Autor:				diego.as
-- Fecha de Creacion: 	2018-04-11 G-Force - Sprint Buho
-- Description:			Se agrega campo LOCKED_BY_INTERFACES


-- Modificacion 25-Oct-18 @ G-FROCE Team Sprint LANGOSTA
					-- pablo.aguilar
					-- Se elimina join a reception document debido a que ahora la recepción es consolidada y duplica las lineas en inventario en linea.

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20190109 GForce@Quetzal
-- Descripcion:			Se agrega peso y unidad de peso

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20190207 GForce@Suricato
-- Descripcion:			Se cambia el source para obtener el proveedor

-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	20190410 GForce@Wapiti
-- Descripcion:			Se agrego el campo PK_LINE, DATE_EXPIRATION, STATUS_ID, [TONE_AND_CALIBER_ID]

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20190725 GForce@Dublin
-- Descripcion:			Se agrega la informacion del proyecto en el inventario en linea

/*
-- Ejemplo de Ejecucion:
		--
		SELECT * FROM [FERCO].[OP_WMS_VIEW_INVENTORY_DETAIL_WHITH_SERIES_QAPASE30032022]
		where [MATERIAL_ID] =  'ferco/029964'
		--      
*/
-- =============================================

CREATE VIEW [FERCO].[OP_WMS_VIEW_INVENTORY_DETAIL_WHITH_SERIES_QAPASE30032022]
AS
SELECT
	[C].[CLIENT_NAME]
	,[PH].[NUMERO_ORDEN]
	,[PH].[NUMERO_DUA]
	,[PH].[FECHA_LLEGADA]
	,[I].[PK_LINE]
	,[I].[STATUS_ID]
	,[I].[LICENSE_ID]
	,[I].[TONE_AND_CALIBER_ID]
	,[I].[TERMS_OF_TRADE]
	,[I].[DATE_EXPIRATION]
	,[I].[BATCH]
	,[M].[MATERIAL_ID]
	,[M].[MATERIAL_CLASS]
	,[M].[BARCODE_ID]
	,[M].[BATCH_REQUESTED]
	,[M].[HANDLE_TONE]
	,[M].[HANDLE_CALIBER]
	,ISNULL([M].[VOLUME_FACTOR], 0) AS [VOLUME_FACTOR]
	,[I].[BARCODE_ID] AS [ALTERNATE_BARCODE]
	,[M].[MATERIAL_NAME]
	, IIF([SN].[SERIAL] IS NOT NULL, 1, IIF([I].[STATUS] <> 'DISPATCH', [I].[QTY],0)) [QTY]
	,[L].[CLIENT_OWNER]
	,[L].[REGIMEN]
	,[L].[CODIGO_POLIZA]
	,[L].[CURRENT_LOCATION]
	,ISNULL([M].[VOLUME_FACTOR], 0) AS [VOLUMEN]
	,ISNULL([M].[VOLUME_FACTOR], 0) * [I].[QTY] AS [TOTAL_VOLUMEN]
	,[L].[LAST_UPDATED_BY]
	,[SN].[SERIAL] AS [SKU_SERIE]
	,[SN].[SERIAL_PREFIX]
	+ CAST([SN].[SERIAL_CORRELATIVE] AS VARCHAR(50)) [SERIAL_NUMBER]
	,[L].[CURRENT_WAREHOUSE]
	,[PH].[DOC_ID]
	,[L].[USED_MT2]
	,[I].[VIN]
	,CASE [L].[CODIGO_POLIZA_RECTIFICACION]
		WHEN NULL THEN 'SI'
		ELSE 'NO'
		END AS [PENDIENTE_RECTIFICACION]
	,[I].[CODE_SUPPLIER]
	,[I].[NAME_SUPPLIER]
	,[SH].[ZONE]
	,ISNULL([I].[HANDLE_SERIAL], 0) [HANDLE_SERIAL]
	,[I].[IS_EXTERNAL_INVENTORY]
	,[S].[STATUS_NAME]
	,[S].[STATUS_CODE]
	,CASE [S].[BLOCKS_INVENTORY]
		WHEN 1 THEN 'Si'
		WHEN 0 THEN 'No'
		ELSE 'No'
		END [BLOCKS_INVENTORY]
	,[S].[COLOR]
	,[TC].[TONE]
	,[TC].[CALIBER]
	,[I].[LOCKED_BY_INTERFACES]
	,[M]. [WEIGTH]  * [I].[QTY] [WEIGTH] 
	,[M].[WEIGHT_MEASUREMENT]
	,[L].[WAVE_PICKING_ID]
	,[M].[ERP_AVERAGE_PRICE]
	,[P].[OPPORTUNITY_CODE] [PROJECT_CODE]
	,[P].[SHORT_NAME] [PROJECT_SHORT_NAME]
	,[I].[IS_DISPATCH]
FROM
	[FERCO].[OP_WMS_INV_X_LICENSE] AS [I]
INNER JOIN  [FERCO].[OP_WMS_LICENSES] AS [L] ON [I].[LICENSE_ID] = [L].[LICENSE_ID]
INNER JOIN [FERCO].[OP_WMS_MATERIALS] AS [M] ON (
											[I].[MATERIAL_ID] = [M].[MATERIAL_ID]
											AND [M].[MATERIAL_ID] > ''
											)
INNER JOIN [FERCO].[OP_WMS_VIEW_CLIENTS] AS [C] ON ([C].[CLIENT_CODE] = [L].[CLIENT_OWNER])
INNER JOIN [FERCO].[OP_WMS_POLIZA_HEADER] AS [PH] ON (
											[PH].[CODIGO_POLIZA] = [L].[CODIGO_POLIZA]
											AND [PH].[CODIGO_POLIZA] > ''
											)
LEFT JOIN [FERCO].[OP_WMS_SHELF_SPOTS] [SH] ON (
											[L].[CURRENT_LOCATION] = [SH].[LOCATION_SPOT]
											AND [SH].[LOCATION_SPOT] > ''
											)
LEFT JOIN [FERCO].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [SN] ON (
											[I].[LICENSE_ID] = [SN].[LICENSE_ID]
											AND [I].[MATERIAL_ID] = [SN].[MATERIAL_ID]
											AND [SN].[LICENSE_ID] > 0
											AND [SN].[STATUS] > 0
											AND [SN].[MATERIAL_ID] > ''
											)
INNER JOIN [FERCO].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [S] ON (
											[I].[STATUS_ID] = [S].[STATUS_ID]
											AND [S].[STATUS_ID] > 0
											)
LEFT JOIN [FERCO].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TC] ON (
											[I].[TONE_AND_CALIBER_ID] = [TC].[TONE_AND_CALIBER_ID]
											AND [TC].[TONE_AND_CALIBER_ID] > 0
											)
LEFT JOIN [FERCO].[OP_WMS_PROJECT] [P] ON [I].[PROJECT_ID] = [P].[ID]
WHERE SH.SPOT_TYPE like 'PUERTA' or sh.LOCATION_SPOT like '%RUTA%'
--LEFT JOIN [FERCO].[OP_WMS_TASK_LIST] [#TL] ON ([L].[CODIGO_POLIZA] = [#TL].[CODIGO_POLIZA_TARGET] )
--		LEFT JOIN [FERCO].[OP_WMS_PASS_DETAIL] [PD] ON ([#TL].[WAVE_PICKING_ID] = [PD].[WAVE_PICKING_ID])
--		LEFT JOIN FERCO.[OP_WMS3PL_PASSES] PS ON (PD.PASS_HEADER_ID = PS.PASS_ID)
		--WHERE 
		-- [L].[WAVE_PICKING_ID] <> PD.WAVE_PICKING_ID
		-- --PS.PASS_ID IS NULL
		-- AND [I].[STATUS] <> 'DISPATCH'
