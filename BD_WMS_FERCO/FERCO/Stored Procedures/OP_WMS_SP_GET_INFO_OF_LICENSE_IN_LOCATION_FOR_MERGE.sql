﻿-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	5/9/2018 @ GForce-Team Sprint Capibara
-- Description:			Obtiene la informacion del merge de ubicacion con la ubicacion enviada

/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[OP_WMS_SP_GET_INFO_OF_LICENSE_IN_LOCATION_FOR_MERGE]
					@LOCATION = 'B01-P01'
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_GET_INFO_OF_LICENSE_IN_LOCATION_FOR_MERGE]
    (
     @LOCATION VARCHAR(25)
    ,@MATERIAL_ID VARCHAR(50) = NULL 
    )
AS
BEGIN
    SET NOCOUNT ON;
	--
    DECLARE @MATERIALS AS TABLE
        (
         [LICENSE_ID] INT
        ,[LICENSE_DESCRIPTION] VARCHAR(50)
        ,[MATERIAL_ID] VARCHAR(50)
        ,[QTY] INT
        ,[BATCH] VARCHAR(50)
        ,[EXPIRATION_DATE] DATE
        ,[TONE] VARCHAR(20)
        ,[CALIBER] VARCHAR(20)
        ,[TONE_AND_CALIBER_ID] INT
        ,[PICKING_DEMAND_HEADER_ID] INT
        ,[DOC_NUM] INT
        );
	--
    DECLARE
        @CLIENT_OWNER VARCHAR(50) = ''
       ,@HEADER_ID INT = 0
       ,@LICENSE_ID INT = 1
       ,@LICENSE_DESCRIPTION VARCHAR(50) = ''
       ,@ORDER INT = 1
       ,@IS_WASTE_LOCATION INT = 0;
	
	-- ------------------------------------------------------------------------------------
	-- Verifica si la ubicacion es de merma
	-- ------------------------------------------------------------------------------------
    SELECT
        @IS_WASTE_LOCATION = [IS_WASTE]
    FROM
        [FERCO].[OP_WMS_SHELF_SPOTS]
    WHERE
        [LOCATION_SPOT] = @LOCATION;

	-- ------------------------------------------------------------------------------------
	-- Agrupa los materiales que se pueden unificar por ubicación, agrupando por lote, tono y calibre
	-- ------------------------------------------------------------------------------------
    SELECT
        [IL].[MATERIAL_ID]
       ,[L].[CLIENT_OWNER]
       ,[IL].[MATERIAL_NAME]
       ,CASE WHEN @IS_WASTE_LOCATION = 0 THEN [IL].[BATCH]
             ELSE NULL
        END [BATCH]
       ,CASE WHEN @IS_WASTE_LOCATION = 0 THEN [IL].[DATE_EXPIRATION]
             ELSE NULL
        END [DATE_EXPIRATION]
       ,[IL].[BARCODE_ID]
       ,CASE WHEN [L].[PICKING_DEMAND_HEADER_ID] IS NULL
             THEN SUM([IL].[QTY]) - SUM(ISNULL([CI].[COMMITED_QTY], 0))
             ELSE SUM([IL].[QTY])
        END [QTY]
       ,CASE WHEN @IS_WASTE_LOCATION = 0
             THEN RANK() OVER (PARTITION BY [IL].[MATERIAL_ID] ORDER BY [L].[PICKING_DEMAND_HEADER_ID], [IL].[BATCH], [IL].[DATE_EXPIRATION], [TC].[TONE], [TC].[CALIBER] DESC)
             ELSE RANK() OVER (PARTITION BY [IL].[MATERIAL_ID] ORDER BY [L].[PICKING_DEMAND_HEADER_ID] DESC)
        END AS [ORDER]
       ,CASE WHEN @IS_WASTE_LOCATION = 0 THEN MAX([IL].[TONE_AND_CALIBER_ID])
             ELSE NULL
        END [TONE_AND_CALIBER_ID]
       ,CASE WHEN @IS_WASTE_LOCATION = 0 THEN [TC].[TONE]
             ELSE NULL
        END [TONE]
       ,CASE WHEN @IS_WASTE_LOCATION = 0 THEN [TC].[CALIBER]
             ELSE NULL
        END [CALIBER]
       ,[L].[PICKING_DEMAND_HEADER_ID]
       ,[DH].[DOC_NUM]
    INTO
        [#LICENSE]
    FROM
        [FERCO].[OP_WMS_LICENSES] [L]
    INNER JOIN [FERCO].[OP_WMS_INV_X_LICENSE] [IL] ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
    INNER JOIN [FERCO].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SM] ON [SM].[STATUS_ID] = [IL].[STATUS_ID]
    LEFT JOIN [FERCO].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TC] ON [TC].[TONE_AND_CALIBER_ID] = [IL].[TONE_AND_CALIBER_ID]
    LEFT JOIN [FERCO].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [CI] ON [CI].[MATERIAL_ID] = [IL].[MATERIAL_ID]
                                                              AND [CI].[LICENCE_ID] = [IL].[LICENSE_ID]
    LEFT JOIN [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH] ON [DH].[PICKING_DEMAND_HEADER_ID] = [L].[PICKING_DEMAND_HEADER_ID]
    WHERE
        [L].[CURRENT_LOCATION] = @LOCATION
        AND (
             [IL].[MATERIAL_ID] = @MATERIAL_ID
            
            )
        AND [IL].[QTY] > 0
        AND [IL].[IS_BLOCKED] = 0
        AND (
             [IL].[LOCKED_BY_INTERFACES] = 0
             OR [L].[PICKING_DEMAND_HEADER_ID] IS NOT NULL
            )
        AND [SM].[BLOCKS_INVENTORY] = 0
        AND (
             [IL].[HANDLE_SERIAL] = 0
             OR [CI].[MATERIAL_ID] IS NULL
            )
    GROUP BY
        [IL].[MATERIAL_ID]
       ,[IL].[MATERIAL_NAME]
       ,[L].[CLIENT_OWNER]
       ,[IL].[BATCH]
       ,[IL].[DATE_EXPIRATION]
       ,[TC].[TONE]
       ,[TC].[CALIBER]
       ,[IL].[BARCODE_ID]
       ,[L].[PICKING_DEMAND_HEADER_ID]
       ,[DH].[DOC_NUM]
    HAVING
        (
         SUM([IL].[QTY]) - SUM(ISNULL([CI].[COMMITED_QTY], 0)) > 0
         OR ISNULL([L].[PICKING_DEMAND_HEADER_ID], 0) > 0
        );
	-- ------------------------------------------------------------------------------------
	-- Devuelve la agrupacion de las licencias
	-- ------------------------------------------------------------------------------------
    SELECT DISTINCT
        [CLIENT_OWNER]
       ,[PICKING_DEMAND_HEADER_ID]
       ,[ORDER]
    INTO
        [#POSSIBLE_LICENSES]
    FROM
        [#LICENSE];

    WHILE EXISTS ( SELECT TOP 1
                    1
                   FROM
                    [#POSSIBLE_LICENSES] )
    BEGIN
        SELECT TOP 1
            @CLIENT_OWNER = [CLIENT_OWNER]
           ,@HEADER_ID = ISNULL([PICKING_DEMAND_HEADER_ID], 0)
           ,@ORDER = [ORDER]
           ,@LICENSE_DESCRIPTION = CAST(@LICENSE_ID AS VARCHAR) + '-'
            + [CLIENT_OWNER]
        FROM
            [#POSSIBLE_LICENSES];
		--
        INSERT  INTO @MATERIALS
                (
                 [LICENSE_ID]
                ,[LICENSE_DESCRIPTION]
                ,[MATERIAL_ID]
                ,[QTY]
                ,[BATCH]
                ,[EXPIRATION_DATE]
                ,[TONE]
                ,[CALIBER]
                ,[TONE_AND_CALIBER_ID]
                ,[PICKING_DEMAND_HEADER_ID]
                ,[DOC_NUM]
				)
        SELECT
            @LICENSE_ID
           ,@LICENSE_DESCRIPTION
           ,[MATERIAL_ID]
           ,[QTY]
           ,[BATCH]
           ,[DATE_EXPIRATION]
           ,[TONE]
           ,[CALIBER]
           ,[TONE_AND_CALIBER_ID]
           ,[PICKING_DEMAND_HEADER_ID]
           ,[DOC_NUM]
        FROM
            [#LICENSE]
        WHERE
            [CLIENT_OWNER] = @CLIENT_OWNER
            AND ISNULL([PICKING_DEMAND_HEADER_ID], 0) = @HEADER_ID
            AND [MATERIAL_ID]=@MATERIAL_ID AND[ORDER] = @ORDER;
		--
        SELECT
            @LICENSE_ID = @LICENSE_ID + 1;

        DELETE FROM
            [#POSSIBLE_LICENSES]
        WHERE
            [CLIENT_OWNER] = @CLIENT_OWNER
            AND ISNULL([PICKING_DEMAND_HEADER_ID], 0) = @HEADER_ID
            AND [ORDER] = @ORDER;
    END;


    SELECT
        [LICENSE_ID]
       ,[LICENSE_DESCRIPTION]
       ,[MATERIAL_ID]
       ,SUM([QTY]) [QTY]
       ,[BATCH]
       ,[EXPIRATION_DATE]
       ,[TONE]
       ,[CALIBER]
       ,[TONE_AND_CALIBER_ID]
       ,[PICKING_DEMAND_HEADER_ID]
       ,[DOC_NUM]
    FROM
        @MATERIALS
	GROUP BY [LICENSE_ID]
            ,[LICENSE_DESCRIPTION]
            ,[MATERIAL_ID]
            ,[BATCH]
            ,[EXPIRATION_DATE]
            ,[TONE]
            ,[CALIBER]
            ,[TONE_AND_CALIBER_ID]
            ,[PICKING_DEMAND_HEADER_ID]
            ,[DOC_NUM];
END;
