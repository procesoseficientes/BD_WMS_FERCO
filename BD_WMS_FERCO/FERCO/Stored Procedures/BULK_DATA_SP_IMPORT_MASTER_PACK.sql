
-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	06-10-2017
-- Description:			SP que importa master pack Sku
-- =============================================
--BEGIN
--EXEC [FERCO].[BULK_DATA_SP_IMPORT_MASTER_PACK]
-- END
-- =============================================
CREATE PROCEDURE [FERCO].[BULK_DATA_SP_IMPORT_MASTER_PACK]
AS
BEGIN
    SET NOCOUNT ON;
    --
    DECLARE @CODE_CLIENT VARCHAR(25);

    DECLARE @CLIENTS TABLE
    (
        [CODE_CLIENT] VARCHAR(25)
    );

    INSERT INTO @CLIENTS
    SELECT DISTINCT
           [VC].[CLIENT_CODE]
    FROM [FERCO].[OP_WMS_VIEW_CLIENTS] [VC];

    TRUNCATE TABLE [FERCO].[OP_WMS_COMPONENTS_BY_MASTER_PACK];

    WHILE EXISTS (SELECT TOP 1 1 FROM @CLIENTS)
    BEGIN
        SELECT TOP 1
               @CODE_CLIENT = [CODE_CLIENT]
        FROM @CLIENTS;

        PRINT @CODE_CLIENT;
        -- ------------------------------------------------------------------------------------
        -- Obtiene los productos marter pack 
        -- ------------------------------------------------------------------------------------
        --  SELECT * FROM [FERCO].[OP_WMS_MATERIALS] [TRG]
        --	SELECT * FROM [FERCO].[VIEW_SKU_MASTER_PACK_ERP_HEADER]
        PRINT 'SKU MASTERPACKS ' + @CODE_CLIENT;

        MERGE [FERCO].[OP_WMS_MATERIALS] [TRG]
        USING
        (
            SELECT *
            FROM [FERCO].[VIEW_SKU_MASTER_PACK_ERP_HEADER]
            WHERE [CLIENT_OWNER] = @CODE_CLIENT
        ) AS [SRC]
        ON [TRG].[MATERIAL_ID] = @CODE_CLIENT + '/' + [SRC].[MATERIAL_ID] COLLATE DATABASE_DEFAULT
        WHEN MATCHED THEN
            UPDATE SET [TRG].[CLIENT_OWNER] = @CODE_CLIENT, --[SRC].[CLIENT_OWNER]
                       [TRG].[MATERIAL_ID] = @CODE_CLIENT + '/' + [SRC].[MATERIAL_ID],
                       [TRG].[BARCODE_ID] = ISNULL([SRC].[BARCODE_ID], 0),
                       [TRG].[ALTERNATE_BARCODE] = ISNULL([SRC].[ALTERNATE_BARCODE], 0),
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
                       [TRG].[IMAGE_1] = NULL,
                       [TRG].[IMAGE_2] = NULL,
                       [TRG].[IMAGE_3] = NULL,
                       [TRG].[LAST_UPDATED] = [SRC].[LAST_UPDATED],
                       [TRG].[LAST_UPDATED_BY] = [SRC].[LAST_UPDATED_BY],
                       [TRG].[IS_CAR] = [SRC].[IS_CAR],
                       [TRG].[MT3] = [SRC].[MT3],
                       [TRG].[BATCH_REQUESTED] = [SRC].[BATCH_REQUESTED],
                       [TRG].[SERIAL_NUMBER_REQUESTS] = [SRC].[SERIAL_NUMBER_REQUESTS],
                       [TRG].[IS_MASTER_PACK] = 1,
                       [TRG].[EXPLODE_IN_RECEPTION] = 1,
                       [TRG].[ITEM_CODE_ERP] = [SRC].[ItemCode],
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
                [IMAGE_1],
                [IMAGE_2],
                [IMAGE_3],
                [LAST_UPDATED],
                [LAST_UPDATED_BY],
                [IS_CAR],
                [MT3],
                [BATCH_REQUESTED],
                [SERIAL_NUMBER_REQUESTS],
                [IS_MASTER_PACK],
                [EXPLODE_IN_RECEPTION],
                [ITEM_CODE_ERP],
                [ERP_AVERAGE_PRICE]
            )
            VALUES
            (@CODE_CLIENT, @CODE_CLIENT + '/' + [SRC].[MATERIAL_ID], ISNULL([SRC].[BARCODE_ID], 0),
             ISNULL([SRC].[ALTERNATE_BARCODE], 0), ISNULL([SRC].[MATERIAL_NAME], 'na'),
             ISNULL([SRC].[SHORT_NAME], 'na'), [SRC].[VOLUME_FACTOR], [SRC].[MATERIAL_CLASS], [SRC].[HIGH],
             [SRC].[LENGTH], [SRC].[WIDTH], [SRC].[MAX_X_BIN], [SRC].[SCAN_BY_ONE], [SRC].[REQUIRES_LOGISTICS_INFO],
             [SRC].[WEIGTH], NULL, NULL, NULL, [SRC].[LAST_UPDATED], [SRC].[LAST_UPDATED_BY], [SRC].[IS_CAR],
             [SRC].[MT3], [SRC].[BATCH_REQUESTED], [SRC].[SERIAL_NUMBER_REQUESTS], 1, 1, [SRC].[ItemCode],
             [SRC].[ERP_AVERAGE_PRICE]);

        -- ------------------------------------------------------------------------------------
        -- Obtiene los productos componentes de los master pack
        -- ------------------------------------------------------------------------------------
        PRINT 'SKU COMPONENTES ' + @CODE_CLIENT;

        MERGE [FERCO].[OP_WMS_MATERIALS] [TRG]
        USING
        (
            SELECT [MATERIAL_ID],
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
                   CAST(NULL AS IMAGE) [IMAGE_1],
                   CAST(NULL AS IMAGE) [IMAGE_2],
                   CAST(NULL AS IMAGE) [IMAGE_3],
                   [LAST_UPDATED],
                   [LAST_UPDATED_BY],
                   [IS_CAR],
                   [MT3],
                   [BATCH_REQUESTED],
                   [SERIAL_NUMBER_REQUESTS],
                   [WEIGTH],
                   [ERP_AVERAGE_PRICE],
                   [INVT],
                   [ItemCode]
            FROM [FERCO].[VIEW_SKU_MASTER_PACK_ERP_DETAIL]
            WHERE [CLIENT_OWNER] = @CODE_CLIENT
            GROUP BY [MATERIAL_ID],
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
                     [LAST_UPDATED],
                     [LAST_UPDATED_BY],
                     [IS_CAR],
                     [MT3],
                     [BATCH_REQUESTED],
                     [SERIAL_NUMBER_REQUESTS],
                     [WEIGTH],
                     [ERP_AVERAGE_PRICE],
                     [INVT],
                     [ItemCode]
        ) AS [SRC]
        ON ([TRG].[MATERIAL_ID] = @CODE_CLIENT + '/' + [SRC].[MATERIAL_ID] COLLATE DATABASE_DEFAULT)
        WHEN MATCHED THEN
            UPDATE SET [TRG].[CLIENT_OWNER] = @CODE_CLIENT, --[SRC].[CLIENT_OWNER]
                       [TRG].[MATERIAL_ID] = @CODE_CLIENT + '/' + [SRC].[MATERIAL_ID],
                       [TRG].[BARCODE_ID] = ISNULL([SRC].[BARCODE_ID], 0),
                       [TRG].[ALTERNATE_BARCODE] = ISNULL([SRC].[ALTERNATE_BARCODE], 0),
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
                       [TRG].[IMAGE_1] = NULL,
                       [TRG].[IMAGE_2] = NULL,
                       [TRG].[IMAGE_3] = NULL,
                       [TRG].[LAST_UPDATED] = [SRC].[LAST_UPDATED],
                       [TRG].[LAST_UPDATED_BY] = [SRC].[LAST_UPDATED_BY],
                       [TRG].[IS_CAR] = [SRC].[IS_CAR],
                       [TRG].[MT3] = [SRC].[MT3],
                       [TRG].[BATCH_REQUESTED] = [SRC].[BATCH_REQUESTED],
                       [TRG].[SERIAL_NUMBER_REQUESTS] = [SRC].[SERIAL_NUMBER_REQUESTS],
                       [TRG].[IS_MASTER_PACK] = 0,
                       [TRG].[ITEM_CODE_ERP] = [SRC].[ItemCode],
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
                [LAST_UPDATED],
                [LAST_UPDATED_BY],
                [IS_CAR],
                [MT3],
                [BATCH_REQUESTED],
                [SERIAL_NUMBER_REQUESTS],
                [IS_MASTER_PACK],
                [ITEM_CODE_ERP],
                [ERP_AVERAGE_PRICE]
            )
            VALUES
            (@CODE_CLIENT, @CODE_CLIENT + '/' + [SRC].[MATERIAL_ID], ISNULL([SRC].[BARCODE_ID], 0),
             ISNULL([SRC].[ALTERNATE_BARCODE], 0), ISNULL([SRC].[MATERIAL_NAME], 'na'),
             ISNULL([SRC].[SHORT_NAME], 'na'), [SRC].[VOLUME_FACTOR], [SRC].[MATERIAL_CLASS], [SRC].[HIGH],
             [SRC].[LENGTH], [SRC].[WIDTH], [SRC].[MAX_X_BIN], [SRC].[SCAN_BY_ONE], [SRC].[REQUIRES_LOGISTICS_INFO],
             [SRC].[WEIGTH], [SRC].[LAST_UPDATED], [SRC].[LAST_UPDATED_BY], [SRC].[IS_CAR], [SRC].[MT3],
             [SRC].[BATCH_REQUESTED], [SRC].[SERIAL_NUMBER_REQUESTS], 0, [SRC].[ItemCode], [SRC].[ERP_AVERAGE_PRICE]);



        PRINT 'SKU COMPONENTES fin' + @CODE_CLIENT;
        -- ------------------------------------------------------------------------------------
        -- Obtiene los productos componentes de los master pack
        -- ------------------------------------------------------------------------------------
        PRINT 'COMPONENTES ' + @CODE_CLIENT;


	--	TRUNCATE TABLE [FERCO].[OP_WMS_COMPONENTS_BY_MASTER_PACK];
        MERGE [FERCO].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [TRG]
        USING
        (
            SELECT DISTINCT
                   [MATERIAL_ID_FATHER],
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
                   [LAST_UPDATED],
                   [LAST_UPDATED_BY],
                   [IS_CAR],
                   [MT3],
                   [BATCH_REQUESTED],
                   [SERIAL_NUMBER_REQUESTS],
                   [ERP_AVERAGE_PRICE],
                   [INVT],
                   [QUANTITY],
                   [ItemCode]
            FROM [FERCO].[VIEW_SKU_MASTER_PACK_ERP_DETAIL]
            WHERE [CLIENT_OWNER] = @CODE_CLIENT
        ) AS [SRC]
        ON (
               [TRG].[MASTER_PACK_CODE] = @CODE_CLIENT + '/' + [SRC].[MATERIAL_ID_FATHER] COLLATE DATABASE_DEFAULT
               AND [TRG].[COMPONENT_MATERIAL] = @CODE_CLIENT + '/' + [SRC].[MATERIAL_ID] COLLATE DATABASE_DEFAULT
           )
        WHEN MATCHED THEN
            UPDATE SET [TRG].[COMPONENT_MATERIAL] = @CODE_CLIENT + '/' + [SRC].[MATERIAL_ID],
                       [TRG].[MASTER_PACK_CODE] = @CODE_CLIENT + '/' + [SRC].[MATERIAL_ID_FATHER],
                       [TRG].[QTY] = [SRC].[QUANTITY]
        WHEN NOT MATCHED THEN
            INSERT
            (
                [COMPONENT_MATERIAL],
                [MASTER_PACK_CODE],
                [QTY]
            )
            VALUES
            (@CODE_CLIENT + '/' + [SRC].[MATERIAL_ID], @CODE_CLIENT + '/' + [SRC].[MATERIAL_ID_FATHER],
             [SRC].[QUANTITY]);


        UPDATE [mat]
        SET [mat].[IS_MASTER_PACK] = 0
        FROM [FERCO].[OP_WMS_MATERIALS] [mat]
            LEFT JOIN [FERCO].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [mas]
                ON [mat].[MATERIAL_ID] = [mas].[MASTER_PACK_CODE]
        WHERE [mat].[IS_MASTER_PACK] = 1
              AND [mas].[COMPONENT_MATERIAL] IS NULL
              AND [CLIENT_OWNER] = @CODE_CLIENT;

        DELETE FROM @CLIENTS
        WHERE [CODE_CLIENT] = @CODE_CLIENT;
    END;



END;








