
-- =============================================
-- Autor:				Otto Hernandez
-- Fecha de Creacion: 	20-06-2017
-- Description:			SP que importa SKU


CREATE PROCEDURE [FERCO].[BULK_DATA_SP_IMPORT_SKU]
AS
BEGIN
    SET NOCOUNT ON;
    --
    DECLARE @NAME_PRICE_LIST VARCHAR(250) = '',
            @CODEE_PRICE_LIST INT;

    -- ------------------------------------------------------------------------------------
    -- Obtiene los productos
    -- ------------------------------------------------------------------------------------
    MERGE [FERCO].[OP_WMS_MATERIALS] [TRG]
    USING
    (SELECT * FROM [FERCO].[VIEW_SKU_ERP]) AS [SRC]
    ON [TRG].[MATERIAL_ID] = [SRC].[MATERIAL_ID] COLLATE DATABASE_DEFAULT
    WHEN MATCHED THEN
        UPDATE SET [TRG].[CLIENT_OWNER] = [SRC].[CLIENT_OWNER],
                   [TRG].[MATERIAL_ID] = [SRC].[MATERIAL_ID],
                   --[TRG].[BARCODE_ID] = ISNULL([SRC].[BARCODE_ID], [SRC].[MATERIAL_ID]),
                   --[TRG].[ALTERNATE_BARCODE] = ISNULL([SRC].[ALTERNATE_BARCODE], [SRC].[MATERIAL_ID]),
                   [TRG].[MATERIAL_NAME] = ISNULL([SRC].[MATERIAL_NAME], 'na'),
                   [TRG].[SHORT_NAME] = ISNULL([SRC].[SHORT_NAME], 'na'),
                   [TRG].[VOLUME_FACTOR] = [SRC].[VOLUME_FACTOR],
                   [TRG].[MATERIAL_CLASS] = [SRC].[MATERIAL_CLASS],
                   [TRG].[HIGH] = [SRC].[HIGH],
                   [TRG].[LENGTH] = [SRC].[LENGTH],
                   [TRG].[WIDTH] = [SRC].[WIDTH],
                   [TRG].[MAX_X_BIN] = [SRC].[MAX_X_BIN],
                   [TRG].[SCAN_BY_ONE] = [SRC].[SCAN_BY_ONE],
                   [TRG].[REQUIRES_LOGISTICS_INFO] = [SRC].[REQUIRES_LOGISTICS_INFO],
                   [TRG].[WEIGTH] = [SRC].[WEIGTH],
                   [TRG].[WEIGHT_MEASUREMENT] = 'KG',
                   [TRG].[IMAGE_1] = NULL,
                   [TRG].[IMAGE_2] = NULL,
                   [TRG].[IMAGE_3] = NULL,
                   [TRG].[LAST_UPDATED] = [SRC].[LAST_UPDATED],
                   [TRG].[LAST_UPDATED_BY] = [SRC].[LAST_UPDATED_BY],
                   [TRG].[IS_CAR] = [SRC].[IS_CAR],
                   [TRG].[MT3] = [SRC].[MT3],
                   [TRG].[BATCH_REQUESTED] = [SRC].[BATCH_REQUESTED],
                   [TRG].[SERIAL_NUMBER_REQUESTS] = [SRC].[SERIAL_NUMBER_REQUESTS],
                   [TRG].[HANDLE_TONE] = [SRC].[HANDLE_TONE],
                   [TRG].[HANDLE_CALIBER] = [SRC].[HANDLE_CALIBER],
                   [TRG].[ITEM_CODE_ERP] = [SRC].[MATERIAL_ID_SAP],
                   [TRG].[ERP_AVERAGE_PRICE] = [SRC].[ERP_AVERAGE_PRICE]
    WHEN NOT MATCHED THEN
        INSERT
        (
            [CLIENT_OWNER],
            [MATERIAL_ID],
            [BARCODE_ID],
            [ALTERNATE_BARCODE],
            [MATERIAL_NAME],
            [SHORT_NAME],
            [VOLUME_FACTOR],
            [MATERIAL_CLASS],
            [HIGH],
            [LENGTH],
            [WIDTH],
            [MAX_X_BIN],
            [SCAN_BY_ONE],
            [REQUIRES_LOGISTICS_INFO],
            [WEIGTH],
            [WEIGHT_MEASUREMENT],
            [IMAGE_1],
            [IMAGE_2],
            [IMAGE_3],
            [LAST_UPDATED],
            [LAST_UPDATED_BY],
            [IS_CAR],
            [MT3],
            [BATCH_REQUESTED],
            [SERIAL_NUMBER_REQUESTS],
            [HANDLE_TONE],
            [HANDLE_CALIBER],
            [ITEM_CODE_ERP],
            [ERP_AVERAGE_PRICE]
        )
        VALUES
        ([SRC].[CLIENT_OWNER], [SRC].[MATERIAL_ID], ISNULL([SRC].[BARCODE_ID], 0),
         ISNULL([SRC].[ALTERNATE_BARCODE], 0), ISNULL([SRC].[MATERIAL_NAME], 'na'), ISNULL([SRC].[SHORT_NAME], 'na'),
         [SRC].[VOLUME_FACTOR], [SRC].[MATERIAL_CLASS], [SRC].[HIGH], [SRC].[LENGTH], [SRC].[WIDTH], [SRC].[MAX_X_BIN],
         [SRC].[SCAN_BY_ONE], [SRC].[REQUIRES_LOGISTICS_INFO], [SRC].[WEIGTH], 'KG', NULL, NULL, NULL,
         [SRC].[LAST_UPDATED], [SRC].[LAST_UPDATED_BY], [SRC].[IS_CAR], [SRC].[MT3], [SRC].[BATCH_REQUESTED],
         [SRC].[SERIAL_NUMBER_REQUESTS], [SRC].[HANDLE_TONE], [SRC].[HANDLE_CALIBER], [SRC].[MATERIAL_ID_SAP],
         [SRC].[ERP_AVERAGE_PRICE]);

-----------------------------------------------------------------------------
---- INSERTA LOS SKUS POR CLIENTE ASIGNADO EN SAP PARA SER DUEÑO DEL INVENTARIO
-----------------------------------------------------------------------------
--DECLARE @CLIENT_ID VARCHAR(25)

--DECLARE CLIENTS CURSOR
--LOCAL STATIC READ_ONLY FORWARD_ONLY FOR SELECT DISTINCT
--  [CLIENT_CODE]
--SELECT * FROM FERCO.[OP_WMS_VIEW_CLIENTS]
--WHERE [CLIENT_CODE] <> 'ferco'

--OPEN CLIENTS
--FETCH NEXT FROM CLIENTS INTO @CLIENT_ID
--WHILE @@FETCH_STATUS = 0
--BEGIN
--MERGE [FERCO].[OP_WMS_MATERIALS] [TRG]
--USING (SELECT
--    *
--  FROM FERCO.VIEW_SKU_ERP) AS [SRC]
--ON [TRG].[MATERIAL_ID] = @CLIENT_ID + '/' + [SRC].[MATERIAL_ID_SAP] COLLATE DATABASE_DEFAULT
--WHEN MATCHED
--  THEN UPDATE
--    SET [TRG].[CLIENT_OWNER] = @CLIENT_ID
--       ,[TRG].[MATERIAL_ID] = @CLIENT_ID + '/' + [SRC].[MATERIAL_ID_SAP]
--       ,[TRG].[BARCODE_ID] = ISNULL([SRC].[BARCODE_ID], 0)
--       ,[TRG].[ALTERNATE_BARCODE] = ISNULL([SRC].[ALTERNATE_BARCODE], 0)
--       ,[TRG].[MATERIAL_NAME] = ISNULL([SRC].[MATERIAL_NAME], 'na')
--       ,[TRG].[SHORT_NAME] = ISNULL([SRC].[SHORT_NAME], 'na')
--       ,[TRG].[VOLUME_FACTOR] = [SRC].[VOLUME_FACTOR]
--       ,[TRG].[MATERIAL_CLASS] = [SRC].[MATERIAL_CLASS]
--       ,[TRG].[HIGH] = [SRC].[HIGH]
--       ,[TRG].[LENGTH] = [SRC].[LENGTH]
--       ,[TRG].[WIDTH] = [SRC].[WIDTH]
--       ,[TRG].[MAX_X_BIN] = [SRC].[MAX_X_BIN]
--       ,[TRG].[SCAN_BY_ONE] = [SRC].[SCAN_BY_ONE]
--       ,[TRG].[REQUIRES_LOGISTICS_INFO] = [SRC].[REQUIRES_LOGISTICS_INFO]
--       ,[TRG].[WEIGTH] = [SRC].[WEIGTH]
--       ,TRG.WEIGHT_MEASUREMENT = 'KG'
--       ,[TRG].[IMAGE_1] = [SRC].[IMAGE_1]
--       ,[TRG].[IMAGE_2] = [SRC].[IMAGE_2]
--       ,[TRG].[IMAGE_3] = [SRC].[IMAGE_3]
--       ,[TRG].[LAST_UPDATED] = [SRC].[LAST_UPDATED]
--       ,[TRG].[LAST_UPDATED_BY] = [SRC].[LAST_UPDATED_BY]
--       ,[TRG].[IS_CAR] = [SRC].[IS_CAR]
--       ,[TRG].[MT3] = [SRC].[MT3]
--       ,[TRG].[BATCH_REQUESTED] = [SRC].[BATCH_REQUESTED]
--       ,[TRG].[SERIAL_NUMBER_REQUESTS] = [SRC].[SERIAL_NUMBER_REQUESTS]
--       ,[TRG].[HANDLE_TONE] = [SRC].[HANDLE_TONE]
--       ,[TRG].[HANDLE_CALIBER] = [SRC].[HANDLE_CALIBER]
--       ,TRG.ITEM_CODE_ERP = SRC.MATERIAL_ID_SAP
--WHEN NOT MATCHED
--  THEN INSERT ([CLIENT_OWNER]
--    , [MATERIAL_ID]
--    , [BARCODE_ID]
--    , [ALTERNATE_BARCODE]
--    , [MATERIAL_NAME]
--    , [SHORT_NAME]
--    , [VOLUME_FACTOR]
--    , [MATERIAL_CLASS]
--    , [HIGH]
--    , [LENGTH]
--    , [WIDTH]
--    , [MAX_X_BIN]
--    , [SCAN_BY_ONE]
--    , [REQUIRES_LOGISTICS_INFO]
--    , [WEIGTH]
--    , WEIGHT_MEASUREMENT
--    , [IMAGE_1]
--    , [IMAGE_2]
--    , [IMAGE_3]
--    , [LAST_UPDATED]
--    , [LAST_UPDATED_BY]
--    , [IS_CAR]
--    , [MT3]
--    , [BATCH_REQUESTED]
--    , [SERIAL_NUMBER_REQUESTS]
--    , [HANDLE_TONE]
--    , [HANDLE_CALIBER]
--    , ITEM_CODE_ERP)
--      VALUES (@CLIENT_ID, @CLIENT_ID + '/' + [SRC].[MATERIAL_ID_SAP], ISNULL([SRC].[BARCODE_ID], 0), ISNULL([SRC].[ALTERNATE_BARCODE], 0), ISNULL([SRC].[MATERIAL_NAME], 'na'), ISNULL([SRC].[SHORT_NAME], 'na'), [SRC].[VOLUME_FACTOR], [SRC].[MATERIAL_CLASS], [SRC].[HIGH], [SRC].[LENGTH], [SRC].[WIDTH], [SRC].[MAX_X_BIN], [SRC].[SCAN_BY_ONE], [SRC].[REQUIRES_LOGISTICS_INFO], [SRC].[WEIGTH], 'KG', [SRC].[IMAGE_1], [SRC].[IMAGE_2], [SRC].[IMAGE_3], [SRC].[LAST_UPDATED], [SRC].[LAST_UPDATED_BY], [SRC].[IS_CAR], [SRC].[MT3], [SRC].[BATCH_REQUESTED], [SRC].[SERIAL_NUMBER_REQUESTS], [SRC].[HANDLE_TONE], [SRC].[HANDLE_CALIBER], SRC.MATERIAL_ID_SAP);




--FETCH NEXT FROM CLIENTS INTO @CLIENT_ID
--END
--CLOSE CLIENTS
--DEALLOCATE CLIENTS

END;







