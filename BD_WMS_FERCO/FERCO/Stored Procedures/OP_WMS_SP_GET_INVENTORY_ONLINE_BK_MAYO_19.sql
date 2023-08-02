-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-03-13 @ Team ERGON - Sprint VERGON 
-- Description:	        sp que obtiene el inventario 

-- Modificación: rudi.garcia
-- Fecha de Creacion: 	2017-03-15 Team ERGON - Sprint ERGON V
-- Description:	 Se agrego el codigo y nombre del proveedor

-- Descripcion:	        hector.gonzalez
-- Fecha de Creacion: 	27-03-2017 Team Ergon SPRINT Hyper
-- Description:			    Se agrego bodegas de usuario logueado 

-- Descripcion:	        hector.gonzalez
-- Fecha de Creacion: 	29-03-2017 Team Ergon SPRINT Hyper
-- Description:			    Se agrego ZONE

-- Descripcion:	        hector.gonzalez
-- Fecha de Creacion: 	22-05-2017 Team Ergon SPRINT Sheik
-- Description:			    Se agrego HANDLE_SERIAL

-- Modificacion 18-Jul-17 @ Nexus Team Sprint AgeOfEmpires
-- alberto.ruiz
-- Se agregan columnas de vencimiento 

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-09-05 @ Team REBORN - Sprint 
-- Description:	   Se agregaron STATUS_NAME, [BLOCKS_INVENTORY] y COLOR

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-09-15 @ Team REBORN - Sprint 
-- Description:	   Se agrego TONE y CALIBER

-- Autor:				diego.as
-- Fecha de Creacion: 	2018-04-11 G-Force - Sprint Buho
-- Description:			Se agrega LEFT JOIN a tablas [OP_WMS_LICENSES] y [OP_WMS_NEXT_PICKING_DEMAND_HEADER]
--						para devolver los campos [DOC_NUM], [PROJECT], [CLIENT_NAME], [LOCKED_BY_INTERFACES]	

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20190109 GForce@Quetzal
-- Descripcion:			Se agrega peso y unidad de peso

/*
-- Ejemplo de Ejecucion:
			EXEC  [FERCO].[OP_WMS_SP_GET_INVENTORY_ONLINE] @LOGIN = 'ADMIN'
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_GET_INVENTORY_ONLINE_BK_MAYO_19]
(@LOGIN VARCHAR(25))
AS
BEGIN
    SET NOCOUNT ON;
    --
    DECLARE @WAREHOUSES TABLE
    (
        [WAREHOUSE_ID] VARCHAR(25),
        [NAME] VARCHAR(50),
        [COMMENTS] VARCHAR(150),
        [ERP_WAREHOUSE] VARCHAR(50),
        [ALLOW_PICKING] NUMERIC,
        [DEFAULT_RECEPTION_LOCATION] VARCHAR(25),
        [SHUNT_NAME] VARCHAR(25),
        [WAREHOUSE_WEATHER] VARCHAR(50),
        [WAREHOUSE_STATUS] INT,
        [IS_3PL_WAREHUESE] INT,
        [WAHREHOUSE_ADDRESS] VARCHAR(250),
        [GPS_URL] VARCHAR(100),
        [WAREHOUSE_BY_USER_ID] INT
            UNIQUE ([WAREHOUSE_ID])
    );
    --
    DECLARE @VALORIZACION TABLE
    (
        [LICENSE_ID] NUMERIC,
        [VALOR_UNITARIO] NUMERIC(36, 6),
        [TOTAL_VALOR] NUMERIC(36, 6),
        [MATERIAL_ID] VARCHAR(50)
    );
    --
    DECLARE @PARAM_GROUP VARCHAR(25) = 'REGIMEN',
            @WAREHOUSE_REGIMEN VARCHAR(25) = 'FISCAL';

    -- ------------------------------------------------------------------------------------
    -- Obtiene todas las bodegas asociadas a un usuario
    -- ------------------------------------------------------------------------------------
    INSERT INTO @WAREHOUSES
    EXEC [FERCO].[OP_WMS_SP_GET_WAREHOUSE_ASSOCIATED_WITH_USER] @LOGIN_ID = @LOGIN;

    -- -- ------------------------------------------------------------------------------------
    -- -- Obtiene la valorizacion
    -- -- ------------------------------------------------------------------------------------
    --INSERT	INTO @VALORIZACION
    --SELECT
    --	[V].[LICENSE_ID]
    --	,[V].[VALOR_UNITARIO]
    --	,[V].[TOTAL_VALOR]
    --	,[V].[MATERIAL_ID]
    --FROM
    --	[FERCO].[OP_WMS_VIEW_VALORIZACION] [V]
    --WHERE
    --	[V].[QTY] > 0;

    -- ------------------------------------------------------------------------------------
    -- Se muestra el resultado
    -- ------------------------------------------------------------------------------------
    SELECT [ID].[PK_LINE],
           [ID].[BATCH_REQUESTED],
           [ID].[STATUS_ID],
           [ID].[HANDLE_TONE],
           [ID].[HANDLE_CALIBER],
           [ID].[TONE_AND_CALIBER_ID],
           [ID].[CLIENT_NAME],
           [ID].[NUMERO_ORDEN],
           [ID].[NUMERO_DUA],
           [ID].[FECHA_LLEGADA],
           [ID].[LICENSE_ID],
           [ID].[TERMS_OF_TRADE],
           [ID].[MATERIAL_ID],
           [ID].[MATERIAL_CLASS],
           [ID].[BARCODE_ID],
           [ID].[VOLUME_FACTOR],
           [ID].[ALTERNATE_BARCODE],
           [ID].[MATERIAL_NAME],
           [ID].[QTY],
           [ID].[CLIENT_OWNER],
           [ID].[REGIMEN],
           [ID].[CODIGO_POLIZA],
           [ID].[CURRENT_LOCATION],
           [ID].[VOLUMEN],
           [ID].[TOTAL_VOLUMEN],
           [ID].[LAST_UPDATED_BY],
           [ID].[SERIAL_NUMBER],
           [ID].[SKU_SERIE],
           [ID].[DATE_EXPIRATION],
           [ID].[BATCH],
           [ID].[CURRENT_WAREHOUSE],
           [ID].[DOC_ID],
           [ID].[USED_MT2],
           [ID].[VIN],
           [ID].[PENDIENTE_RECTIFICACION],
           [TH].[ACUERDO_COMERCIAL_ID],
           [TH].[ACUERDO_COMERCIAL_NOMBRE],
           [TH].[VALID_FROM],
           [TH].[VALID_TO],
           [TH].[EXPIRES],
           [TH].[CURRENCY],
           [TH].[STATUS],
           [TH].[WAREHOUSE_WEATHER],
           [TH].[LAST_UPDATED],
           [TH].[LAST_UPDATED_BY],
           [TH].[LAST_UPDATED_AUTH_BY],
           [TH].[COMMENTS],
           [TH].[REGIMEN],
           [TH].[AUTHORIZER],
           [PH].[REGIMEN] [REGIMEN_DOCUMENTO],
           [C].[SPARE1] AS [GRUPO_REGIMEN],
           [ID].[CODE_SUPPLIER],
           [ID].[NAME_SUPPLIER],
           [ID].[ZONE],
           ([ID].[QTY] - ISNULL([CI].[COMMITED_QTY], 0)) AS [AVAILABLE_QTY],
           [ID].[ERP_AVERAGE_PRICE] [VALOR_UNITARIO],
           [ID].[ERP_AVERAGE_PRICE] * [ID].[QTY] [TOTAL_VALOR],
           CASE [ID].[HANDLE_SERIAL]
               WHEN 1 THEN
                   'Si'
               WHEN 0 THEN
                   'No'
               ELSE
                   'No'
           END [HANDLE_SERIAL],
           CASE [ID].[IS_EXTERNAL_INVENTORY]
               WHEN 1 THEN
                   'SI'
               ELSE
                   'NO'
           END AS [IS_EXTERNAL_INVENTORY],
           [PH].[FECHA_DOCUMENTO],
           NULL [DIAS_REGIMEN],
           NULL [DIAS_PARA_VENCER],
           NULL [FECHA_VENCIMIENTO],
           'Libre' [ESTADO_REGIMEN],
           [ID].[STATUS_NAME],
           [ID].[STATUS_CODE],
           [ID].[BLOCKS_INVENTORY],
           [ID].[COLOR],
           [ID].[TONE],
           [ID].[CALIBER],
           NULL AS [SALE_ORDER_ID],
           NULL [PROJECT],
           NULL AS [CUSTOMER_NAME],
           CASE
               WHEN [ID].[LOCKED_BY_INTERFACES] = 1 THEN
                   'Si'
               WHEN [ID].[LOCKED_BY_INTERFACES] = 0 THEN
                   'No'
           END [LOCKED_BY_INTERFACES],
           [ID].[WEIGTH],
           [ID].[WEIGHT_MEASUREMENT],
           [ID].[WAVE_PICKING_ID]
    FROM [FERCO].[OP_WMS_VIEW_INVENTORY_DETAIL_WHITH_SERIES] [ID]
        INNER JOIN [FERCO].[OP_WMS_TARIFICADOR_HEADER] [TH]
            ON ([ID].[TERMS_OF_TRADE] = [TH].[ACUERDO_COMERCIAL_ID])
        LEFT JOIN [FERCO].[OP_WMS_POLIZA_HEADER] [PH]
            ON ([PH].[CODIGO_POLIZA] = [ID].[CODIGO_POLIZA])
        LEFT JOIN [FERCO].[OP_WMS_CONFIGURATIONS] [C]
            ON (
                   [C].[PARAM_GROUP] = @PARAM_GROUP
                   AND [C].[PARAM_NAME] = [PH].[REGIMEN]
               )
        INNER JOIN @WAREHOUSES [W]
            ON [W].[WAREHOUSE_ID] = [ID].[CURRENT_WAREHOUSE] COLLATE DATABASE_DEFAULT
        LEFT JOIN [FERCO].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [CI]
            ON (
                   [ID].[MATERIAL_ID] = [CI].[MATERIAL_ID]
                   AND [ID].[CLIENT_OWNER] = [CI].[CLIENT_OWNER]
                   AND [CI].[LICENCE_ID] = [ID].[LICENSE_ID]
               )
    WHERE [ID].[QTY] > 0;
END;




