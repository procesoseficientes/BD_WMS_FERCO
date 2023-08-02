﻿-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-04-12 @ Team ERGON - Sprint ERGON EPONA
-- Description:	 


-- Modificacion:					rudi.garcia
-- Fecha de Creacion: 		2017-05-02 @ TeamErgon Sprint Ganondorf
-- Description:			    Se agrego el parametro @TASK_TYPE

-- Modificacion 9/14/2017 @ Reborn - Team Sprint Collin
					-- diego.as
					-- Se agrega LEFT JOIN para traer el TONO y CALIBRE

/*
-- Ejemplo de Ejecucion:
	 EXEC [FERCO].[OP_WMS_SP_GET_MY_PICKING_LIST_DETAIL_BY_LICENCE] @LOGIN_ID = 'ACAMACHO', @TASK_TYPE = 'TAREA_PICKING'
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_GET_MY_PICKING_LIST_DETAIL_BY_LICENCE] (
		@LOGIN_ID VARCHAR(25)
		,@TASK_TYPE VARCHAR(25)
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	SELECT
		[T].[WAVE_PICKING_ID]
		,[T].[CODIGO_POLIZA_SOURCE]
		,[T].[CODIGO_POLIZA_TARGET]
		,[T].[LICENSE_ID_SOURCE]
		,[S].[LOCATION_SPOT] [LOCATION_SPOT_SOURCE]
		,[T].[QUANTITY_PENDING] [QTY_AVAILABLE]
		,[T].[SERIAL_NUMBER]
		,[T].[WAREHOUSE_SOURCE]
		,[T].[REGIMEN]
		,[T].[MATERIAL_ID]
		,[T].[BARCODE_ID]
		,[T].[MATERIAL_NAME]
		,[T].[MATERIAL_SHORT_NAME]
		,[T].[ALTERNATE_BARCODE]
		,[T].[QUANTITY_PENDING] [QUANTITY_PENDING]
		,[T].[QUANTITY_ASSIGNED] [QUANTITY_ASSIGNED]
		,[S].[SPOT_TYPE] [TIPO]
		,[L].[USED_MT2] [MT2AVAILABLE]
		,[T].[LOCATION_SPOT_TARGET]
		,[IL].[BATCH]
		,[IL].[DATE_EXPIRATION]
		,(CASE	WHEN [TCM].[TONE] IS NULL THEN ''
				ELSE [TCM].[TONE]
			END) AS [TONE]
		,(CASE	WHEN [TCM].[CALIBER] IS NULL THEN ''
				ELSE [TCM].[CALIBER]
			END) AS [CALIBER]
	FROM
		[FERCO].[OP_WMS_TASK_LIST] [T]
	INNER JOIN [FERCO].[OP_WMS_LICENSES] [L] ON [L].[LICENSE_ID] = [T].[LICENSE_ID_SOURCE]
	INNER JOIN [FERCO].[OP_WMS_SHELF_SPOTS] [S] ON [L].[CURRENT_LOCATION] = [S].[LOCATION_SPOT]
	INNER JOIN [FERCO].[OP_WMS_INV_X_LICENSE] [IL] ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
											AND [IL].[MATERIAL_ID] = [T].[MATERIAL_ID]
	LEFT JOIN [FERCO].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM] ON ([TCM].[TONE_AND_CALIBER_ID] = [IL].[TONE_AND_CALIBER_ID])
	WHERE
		[T].[TASK_ASSIGNEDTO] = @LOGIN_ID
		AND [T].[TASK_TYPE] = @TASK_TYPE
		AND [T].[IS_COMPLETED] <> 1
		AND [T].[IS_CANCELED] = 0
		AND [T].[IS_PAUSED] = 0
		AND [T].[QUANTITY_PENDING] > 0
	ORDER BY
		[T].[WAVE_PICKING_ID]
		,[LOCATION_SPOT_SOURCE] ASC
		,ISNULL([IL].[DATE_EXPIRATION], [IL].[CREATED_DATE]) ASC
		,[QTY_AVAILABLE] ASC;
END;
