﻿-- =============================================
-- Autor:	        rudi.garcia
-- Fecha de Creacion: 	09-Nov-2017 @ Team REBORN - Sprint Eberhard
-- Description:	        Sp que valida si una licencia esta disponible para realizar picking y no esta comprometida en otro picking

/*
-- Ejemplo de Ejecucion:
			EXEC [FERCO].OP_WMS_SP_VALIDATE_IF_PICKING_LICENSE_IS_AVAILABLE @WAVE_PICKING_ID = 4752, @CURRENT_LOCATION = 'B01-P02-F01-NU', @MATERIAL_ID = 'arium/100040' , @LICENSE_ID = 388396
      , @LOGIN = 'RDMOVIL'
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_VALIDATE_IF_PICKING_LICENSE_IS_AVAILABLE] (
		@WAVE_PICKING_ID INT
		,@CURRENT_LOCATION VARCHAR(25)
		,@MATERIAL_ID VARCHAR(50)
		,@LICENSE_ID INT = NULL
		,@LOGIN VARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	DECLARE
		@QUANTITY_PENDING NUMERIC(18, 4)
		,@HANDLE_BATCH INT = 0;

	DECLARE	@WAREHOUSES TABLE (
			[WAREHOUSE_ID] VARCHAR(25)
			,[NAME] VARCHAR(50)
			,[COMMENTS] VARCHAR(150)
			,[ERP_WAREHOUSE] VARCHAR(50)
			,[ALLOW_PICKING] NUMERIC
			,[DEFAULT_RECEPTION_LOCATION] VARCHAR(25)
			,[SHUNT_NAME] VARCHAR(25)
			,[WAREHOUSE_WEATHER] VARCHAR(50)
			,[WAREHOUSE_STATUS] INT
			,[IS_3PL_WAREHUESE] INT
			,[WAHREHOUSE_ADDRESS] VARCHAR(250)
			,[GPS_URL] VARCHAR(100)
			,[WAREHOUSE_BY_USER_ID] INT
				UNIQUE ([WAREHOUSE_ID])
		);

	INSERT	INTO @WAREHOUSES
	SELECT
		[W].[WAREHOUSE_ID]
		,[W].[NAME]
		,[W].[COMMENTS]
		,[W].[ERP_WAREHOUSE]
		,[W].[ALLOW_PICKING]
		,[W].[DEFAULT_RECEPTION_LOCATION]
		,[W].[SHUNT_NAME]
		,[W].[WAREHOUSE_WEATHER]
		,[W].[WAREHOUSE_STATUS]
		,[W].[IS_3PL_WAREHUESE]
		,[W].[WAHREHOUSE_ADDRESS]
		,[W].[GPS_URL]
		,[WB].[WAREHOUSE_BY_USER_ID]
	FROM
		[FERCO].[OP_WMS_WAREHOUSES] [W]
	INNER JOIN [FERCO].[OP_WMS_WAREHOUSE_BY_USER] [WB] ON [W].[WAREHOUSE_ID] = [WB].[WAREHOUSE_ID]
	WHERE
		[WB].[LOGIN_ID] = @LOGIN;  

	IF @LICENSE_ID IS NOT NULL
	BEGIN
		SELECT TOP 1
			@MATERIAL_ID = [M].[MATERIAL_ID]
			,@HANDLE_BATCH = [M].[BATCH_REQUESTED]
		FROM
			[FERCO].[OP_WMS_MATERIALS] [M]
		INNER JOIN [FERCO].[OP_WMS_INV_X_LICENSE] [IL] ON ([IL].[MATERIAL_ID] = [M].[MATERIAL_ID])
		WHERE
			[IL].[LICENSE_ID] = @LICENSE_ID
			AND (
					[M].[BARCODE_ID] = @MATERIAL_ID
					OR [M].[ALTERNATE_BARCODE] = @MATERIAL_ID
					OR [M].[MATERIAL_ID] = @MATERIAL_ID
				);
    
	END;

	IF (
		@HANDLE_BATCH = 1
		AND NOT EXISTS ( SELECT TOP 1
								1
							FROM
								[FERCO].[OP_WMS_TASK_LIST]
							WHERE
								[WAVE_PICKING_ID] = @WAVE_PICKING_ID
								AND [LICENSE_ID_SOURCE] = @LICENSE_ID
								AND [MATERIAL_ID] = @MATERIAL_ID )
		)
	BEGIN 
		RAISERROR('La licencia no pertenece a la tarea especificada.', 16,1);
		RETURN;   
	END; 

	SELECT
		@QUANTITY_PENDING = SUM([TL].[QUANTITY_PENDING])
	FROM
		[FERCO].[OP_WMS_TASK_LIST] [TL]
	WHERE
		[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
		AND [TL].[MATERIAL_ID] = @MATERIAL_ID;

	SELECT
		[IL].[LICENSE_ID]
		,[IL].[MATERIAL_ID]
		,([IL].[QTY] - (ISNULL([CIL].[COMMITED_QTY], 0))
			+ ISNULL([TL].[QUANTITY_PENDING], 0)) AS [QTY]
		,[TCM].[TONE]
		,[TCM].[CALIBER]
		,[S].[SPOT_TYPE]
		,[L].[USED_MT2]
		,[TL].[TASK_SUBTYPE]
		,CAST(ISNULL([TL].[IS_DISCRETIONARY], '0') AS INT) [IS_DISCRETIONARY]
		,@QUANTITY_PENDING AS [QUANTITY_PENDING]
		,[M].[SERIAL_NUMBER_REQUESTS]
	FROM
		[FERCO].[OP_WMS_INV_X_LICENSE] [IL]
	INNER JOIN [FERCO].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SML] ON ([SML].[STATUS_ID] = [IL].[STATUS_ID])
	INNER JOIN [FERCO].[OP_WMS_LICENSES] [L] ON ([L].[LICENSE_ID] = [IL].[LICENSE_ID])
	INNER JOIN @WAREHOUSES [W] ON ([W].[WAREHOUSE_ID] = [L].[CURRENT_WAREHOUSE])
	INNER JOIN [FERCO].[OP_WMS_SHELF_SPOTS] [S] ON ([L].[CURRENT_LOCATION] = [S].[LOCATION_SPOT])
	INNER JOIN [FERCO].[OP_WMS_MATERIALS] [M] ON ([M].[MATERIAL_ID] = [IL].[MATERIAL_ID])
	LEFT JOIN [FERCO].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [CIL] ON (
											[CIL].[LICENCE_ID] = [IL].[LICENSE_ID]
											AND [CIL].[MATERIAL_ID] = [IL].[MATERIAL_ID]
											)
	LEFT JOIN [FERCO].[OP_WMS_TASK_LIST] [TL] ON (
											[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
											AND [TL].[LICENSE_ID_SOURCE] = [IL].[LICENSE_ID]
											AND [TL].[MATERIAL_ID] = [IL].[MATERIAL_ID]
											AND [TL].[IS_COMPLETED] <> 1
											AND [TL].[IS_PAUSED] <> 3
											)
	LEFT JOIN [FERCO].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM] ON ([TCM].[TONE_AND_CALIBER_ID] = [IL].[TONE_AND_CALIBER_ID])
	WHERE
		[SML].[BLOCKS_INVENTORY] = 0
		AND (
				[TL].[TASK_SUBTYPE] = 'INVENTARIO_PREPARADO'
				OR [IL].[LOCKED_BY_INTERFACES] = 0
			)
		AND [IL].[MATERIAL_ID] = @MATERIAL_ID
		AND [L].[CURRENT_LOCATION] = @CURRENT_LOCATION
		AND ([IL].[QTY] - (ISNULL([CIL].[COMMITED_QTY], 0))
				+ ISNULL([TL].[QUANTITY_PENDING], 0)) > 0
		AND (
				@LICENSE_ID IS NULL
				OR [IL].[LICENSE_ID] = @LICENSE_ID
			);
END;
