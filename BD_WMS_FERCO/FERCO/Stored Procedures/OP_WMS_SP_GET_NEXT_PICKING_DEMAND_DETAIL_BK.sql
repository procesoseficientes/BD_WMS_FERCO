

-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-02-02 @ Team ERGON - Sprint ERGON 
-- Description:	        Sp que trae el detalle de un Picking wms


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-02-28 Team ERGON - Sprint ERGON IV
-- Description:	 se agrega el campo del taxcode que proviene de un parametro

-- Modificacion 14-Jul-17 @ Nexus Team Sprint AgeOfEmperies
-- alberto.ruiz
-- Se agregaron los campos [IS_MASTER_PACK] y [WAS_IMPLODED]

-- Modificacion 10-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
-- alberto.ruiz
-- Ajuste por intercompany
-- Modificacion 9/18/2017 @ Reborn-Team Sprint Collin
-- diego.as
-- Se agrean columnas TONE y CALIBER

-- Modificacion 11/3/2017 @ NEXUS-Team Sprint F-Zero
-- rodrigo.gomez
-- Se agrega columna de descuento

-- Gustavo.Garcia 05-06-2021
-- Se agrega outter join para obtener los fletes

/*
-- Ejemplo de Ejecucion:
			select * from [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
			--
			EXEC [FERCO].[OP_WMS_SP_GET_NEXT_PICKING_DEMAND_DETAIL] 
				@PICKING_DEMAND_HEADER_ID = 103175
				,@OWNER = 'ferco'



*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_GET_NEXT_PICKING_DEMAND_DETAIL_BK] (@PICKING_DEMAND_HEADER_ID INT
, @OWNER VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @TAX_CODE VARCHAR(50)
         ,@INTERNAL_SALE VARCHAR(50)
         ,@IS_INTERNAL_SALE INT = 0
         ,@QUERY NVARCHAR(4000)
         ,@PICKING_OWNER VARCHAR(50);
  --


  --
  SELECT
    @PICKING_OWNER =
    CASE [PDH].[OWNER]
      WHEN NULL THEN CASE [PDH].[SELLER_OWNER]
          WHEN NULL THEN [PDH].[CLIENT_OWNER]
          ELSE [PDH].[SELLER_OWNER]
        END
      ELSE [PDH].[OWNER]
    END
  FROM [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
  WHERE [PDH].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
  --
  SELECT TOP 1
    @TAX_CODE = [C].[TEXT_VALUE]
  FROM [FERCO].[OP_WMS_CONFIGURATIONS] [C]
  WHERE [C].[PARAM_TYPE] = 'SISTEMA'
  AND [C].[PARAM_GROUP] = 'ERP_PARAMS'
  AND [C].[PARAM_NAME] = 'TAX_CODE_ERP';
  --
  SELECT TOP 1
    @INTERNAL_SALE = [C].[TEXT_VALUE]
  FROM [FERCO].[OP_WMS_CONFIGURATIONS] [C]
  WHERE [C].[PARAM_TYPE] = 'SISTEMA'
  AND [C].[PARAM_GROUP] = 'INTERCOMPANY'
  AND [C].[PARAM_NAME] = 'INTERNAL_SALE';
  --
  SELECT TOP 1
    @IS_INTERNAL_SALE = 1
  FROM [FERCO].[OP_WMS_FUNC_SPLIT_3](@INTERNAL_SALE, '|')
  WHERE [VALUE] = @PICKING_OWNER
  --



  --
  SELECT
    @QUERY = N'
    DECLARE @MATERIALS_WITH_BATCH TABLE (
    [MATERIAL_ID] VARCHAR(50)
   ,[BATCH] VARCHAR(50)
  )
    
    
     INSERT INTO @MATERIALS_WITH_BATCH
  EXEC [FERCO].OP_WMS_SP_GET_MATERIALS_WITH_BATCH_FROM_DEMAND_DISPATCH @PICKING_DEMAND_HEADER_ID = ' + CAST(@PICKING_DEMAND_HEADER_ID AS VARCHAR) + '

    
    SELECT DISTINCT
		isnull([PDD].[PICKING_DEMAND_DETAIL_ID] , cast(0 as int)) as PICKING_DEMAND_DETAIL_ID
		,cast([PDH].[PICKING_DEMAND_HEADER_ID] as int) AS [DoEntry]
		,CASE WHEN [PDD].[MATERIAL_OWNER] = ''' + @OWNER + '''
			THEN [PDH].[DOC_ENTRY]
			ELSE isnull(cast([PDH].[DOC_ENTRY] as int) ,cast(0 as int))
		END AS [DocEntryErp]
		,isnull([M].[ITEM_CODE_ERP],CAST(rdr1.itemCode as varchar(25))) [ItemCode]
		,isnull([PDD].[QTY], CAST(rdr1.Quantity AS INT)) AS [Quantity]
		,CASE [PDH].[IS_FROM_SONDA]
			WHEN 1 THEN -1
			ELSE isnull([PDD].[LINE_NUM] - 1,CAST(rdr1.LineNum AS INT))
		END AS [LineNum]
		,CASE [PDH].[IS_FROM_ERP]
			WHEN 1 THEN cast(17 as int)
			ELSE [PDD].[ERP_OBJECT_TYPE]
		END [ObjType]
		,isnull([PDD].[PRICE],CAST (rdr1.price AS float(24))) AS [Price]
		,[W].[ERP_WAREHOUSE] AS [Warehouse]
		,''' + @TAX_CODE + '''[TaxCode]
		,isnull([M].[IS_MASTER_PACK],cast(0 as int )) [IS_MASTER_PACK]
		,ISNULL([PDD].[WAS_IMPLODED],cast(0 as int ))  WAS_IMPLODED
		,ISNULL([PDD].[ATTEMPTED_WITH_ERROR] ,cast(0 as int )) ATTEMPTED_WITH_ERROR
		,ISNULL([PDD].[IS_POSTED_ERP],cast(-1 as int ))  IS_POSTED_ERP
		,ISNULL([PDD].[POSTED_ERP] ,GETDATE())  POSTED_ERP
		,ISNULL([PDD].[ERP_REFERENCE],cast(0 as int ))  ERP_REFERENCE
		,ISNULL([PDD].[POSTED_STATUS],cast(0 as int )) POSTED_STATUS
		,ISNULL([PDD].[POSTED_RESPONSE],'''') POSTED_RESPONSE
		,ISNULL([PDD].[MATERIAL_OWNER], ''ferco'') MATERIAL_OWNER
		,ISNULL([PDD].[TONE], '''')  TONE
		,ISNULL([PDD].[CALIBER], '''') CALIBER
		,ISNULL([PDD].[DISCOUNT],cast(0 as int )) DISCOUNT
		--, 0 [DISCOUNT]
		,isnull([PDD].[DISCOUNT_TYPE],''PERCENTAGE'') DISCOUNT_TYPE
		,[MWB].[BATCH]
		,isnull([MWC].[CATEGORY_CODE],''LINEA'') AS U_FAMILIA
	FROM [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
		left outer JOIN SAPSERVER.SBOFERCO.DBO.RDR1 RDR1 ON  (rdr1.DocEntry=[PDH].DOC_ENTRY  COLLATE DATABASE_DEFAULT)
		left outer JOIN [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [PDD] ON [PDD].[PICKING_DEMAND_HEADER_ID] = [PDH].[PICKING_DEMAND_HEADER_ID]  and ''ferco/''+rdr1.itemCode=[PDD].material_id collate database_default
		left JOIN [FERCO].[OP_WMS_MATERIALS] [M] ON ([M].[MATERIAL_ID] = [PDD].[MATERIAL_ID])
		--INNER JOIN [FERCO].[OP_WMS_MATERIAL_INTERCOMPANY] [MI] ON ([MI].[SOURCE] = ''' + @OWNER + ''' AND [PDD].[MASTER_ID_MATERIAL] = [MI].[MASTER_ID])
		LEFT JOIN [FERCO].[OP_WMS_WAREHOUSES] [W] ON [PDH].[CODE_WAREHOUSE] = [W].[WAREHOUSE_ID]
		LEFT JOIN @MATERIALS_WITH_BATCH [MWB] ON ([MWB].[MATERIAL_ID] = [PDD].[MATERIAL_ID])
		LEFT JOIN [FERCO].[OP_WMS_MATERIALS_WITH_CATEGORY] [MWC] ON ([MWC].ITEM_CODE = [M].[MATERIAL_ID] )
		--LEFT JOIN SWIFT_INTERFACES.ferco.ERP_VIEW_SALES_ORDER_DETAIL_CHANNEL_MODERN ODCM ON (ODCM.docentry = pdh.doc_num and ODCM.U_MasterIdSKU = pdd.MASTER_ID_MATERIAL COLLATE DATABASE_DEFAULT) 
	WHERE 
		[PDH].[PICKING_DEMAND_HEADER_ID] = ' + CAST(@PICKING_DEMAND_HEADER_ID AS VARCHAR)
    +
    CASE
      WHEN @IS_INTERNAL_SALE = 0 THEN ';'
      ELSE ';'
    END
  --
  PRINT '--> @QUERY: ' + @QUERY
  --
  EXEC (@QUERY)
END;
