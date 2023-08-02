﻿
-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	8/25/2017 @ NEXUS-Team Sprint CommandAndConquer 
-- Description:			Sp que obtiene el detalle para venta interna

/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[OP_WMS_SP_GET_DETAIL_FOR_PICKING_INTERNAL_SALE]
					@OWNER = 'motorganica', -- varchar(50)
					@OWNER_FOR = 'viscosa', -- varchar(50)
					@PICKING_DEMAND_HEADER_ID = 5251, -- int
					@IS_SALE_INVOICE = 0 -- int
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_GET_DETAIL_FOR_PICKING_INTERNAL_SALE]
    (
     @OWNER VARCHAR(50)
    ,@OWNER_FOR VARCHAR(50)
    ,@PICKING_DEMAND_HEADER_ID INT
    ,@IS_SALE_INVOICE INT
    )
AS
BEGIN
    SET NOCOUNT ON;
  --
    DECLARE
        @QUERY VARCHAR(4000)
       ,@TAX_CODE VARCHAR(50)
       ,@IS_INTERNAL_SALE_COMPANY INT = 0
       ,@INTERNAL_SALE_COMPANIES VARCHAR(100);
  --
    SELECT
        @INTERNAL_SALE_COMPANIES = [TEXT_VALUE]
    FROM
        [FERCO].[OP_WMS_CONFIGURATIONS]
    WHERE
        [PARAM_GROUP] = 'INTERCOMPANY'
        AND [PARAM_NAME] = 'INTERNAL_SALE';
  --
    SELECT
        @IS_INTERNAL_SALE_COMPANY = CASE WHEN @INTERNAL_SALE_COMPANIES = @OWNER
                                         THEN 1
                                         ELSE 0
                                    END;
  --
    SELECT TOP 1
        @TAX_CODE = [C].[TEXT_VALUE]
    FROM
        [FERCO].[OP_WMS_CONFIGURATIONS] [C]
    WHERE
        [C].[PARAM_TYPE] = 'SISTEMA'
        AND [C].[PARAM_GROUP] = 'ERP_PARAMS'
        AND [C].[PARAM_NAME] = 'TAX_CODE_ERP';
  --
    SELECT
        @QUERY = N'
	SELECT
		[PDD].[PICKING_DEMAND_DETAIL_ID]
		,[PDD].[PICKING_DEMAND_HEADER_ID] AS [DoEntry]
		,'
        + CASE WHEN @IS_INTERNAL_SALE_COMPANY = 1
               THEN '[PDH].[DOC_ENTRY] AS [DocEntryErp]'
               ELSE '0 AS [DocEntryErp]'
          END + '
		,[MI].[ITEM_CODE] [ItemCode]
		,[PDD].[QTY] AS [Quantity]
		,CASE [PDH].[IS_FROM_SONDA]
			WHEN 1 THEN -1
			ELSE [PDD].[LINE_NUM] - 1
		END AS [LineNum]
		,CASE [PDH].[IS_FROM_ERP]
			WHEN 1 THEN 17
			ELSE [PDD].[ERP_OBJECT_TYPE]
		END [ObjType]
		,[PLI].[PRICE] AS [Price]
		,[W].[ERP_WAREHOUSE] AS [Warehouse]
		,''' + @TAX_CODE
        + '''[TaxCode]
		,[M].[IS_MASTER_PACK]
		,[PDD].[WAS_IMPLODED]
		,[PDD].[ATTEMPTED_WITH_ERROR]
		,[PDD].[IS_POSTED_ERP]
		,[PDD].[POSTED_ERP]
		,[PDD].[ERP_REFERENCE]
		,[PDD].[POSTED_STATUS]
		,[PDD].[POSTED_RESPONSE]
		,[PDD].[MATERIAL_OWNER]
		,[C].[MASTER_ID_CLIENT_CODE]
		,[C].[MASTER_ID_SUPPLIER]
		,pli.[PRICE_LIST]
	FROM [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [PDD]
		INNER JOIN [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH] ON [PDD].[PICKING_DEMAND_HEADER_ID] = [PDH].[PICKING_DEMAND_HEADER_ID]
		INNER JOIN [FERCO].[OP_WMS_MATERIALS] [M] ON ([M].[MATERIAL_ID] = [PDD].[MATERIAL_ID])
		INNER JOIN [FERCO].[OP_WMS_MATERIAL_INTERCOMPANY] [MI] ON ([MI].[SOURCE] = '''
        + @OWNER + ''' AND [PDD].[MASTER_ID_MATERIAL] = [MI].[MASTER_ID])
		' + CASE WHEN @IS_SALE_INVOICE = 1
                 THEN ' 
		INNER JOIN [FERCO].[OP_WMS_COMPANY] [C] ON [C].[COMPANY_NAME] = '''
                      + @OWNER_FOR
                      + ''' AND [C].[EXTERNAL_SOURCE_ID] = [PDH].[EXTERNAL_SOURCE_ID]
		INNER JOIN [FERCO].[OP_WMS_PRICE_LIST_FOR_INTERCOMPANY] [PLI] ON [C].[MASTER_ID_CLIENT_CODE] = [PLI].[MASTER_ID_CUSTOMER] AND [PLI].[SOURCE] = '''
                      + @OWNER
                      + ''' AND [PLI].[MATERIAL_ID] = [MI].[ITEM_CODE]'
                 ELSE '
		INNER JOIN [FERCO].[OP_WMS_COMPANY] [C] ON [C].[COMPANY_NAME] = '''
                      + @OWNER
                      + ''' AND [C].[EXTERNAL_SOURCE_ID] = [PDH].[EXTERNAL_SOURCE_ID]
		INNER JOIN [FERCO].[OP_WMS_PRICE_LIST_FOR_INTERCOMPANY] [PLI] ON [C].[MASTER_ID_CLIENT_CODE] = [PLI].[MASTER_ID_CUSTOMER] AND [PLI].[SOURCE] = [PDD].MATERIAL_OWNER AND [PLI].[MATERIAL_ID] = [MI].[ITEM_CODE]'
            END
        + '
		LEFT JOIN [FERCO].[OP_WMS_WAREHOUSES] [W] ON [PDH].[CODE_WAREHOUSE] = [W].[WAREHOUSE_ID]
	WHERE [PDH].[PICKING_DEMAND_HEADER_ID] = '
        + CAST(@PICKING_DEMAND_HEADER_ID AS VARCHAR) + ' AND [PDD].[QTY] > 0'
        + CASE WHEN @IS_SALE_INVOICE = 1
               THEN ' AND [PDD].[MATERIAL_OWNER] = ''' + @OWNER
                    + ''' AND ISNULL([PDD].[INNER_SALE_STATUS],'''') != ''SALE_INVOICE'';'
               ELSE ' AND [PDD].[MATERIAL_OWNER] = ''' + @OWNER_FOR + ''''
          END;
  --
    PRINT '--> @QUERY: ' + @QUERY;
  --
    EXEC (@QUERY);
END;
