
-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-02-19 @ Team ERGON - Sprint ERGON III
-- Description:	 Consultar productos por bodega, cliente, ubicación y zona. 

-- Modificacion 8/17/2017 @ NEXUS-Team Sprint Banjo-Kazooie
-- rodrigo.gomez
-- Se agrego la columna de QTY

/*
-- Ejemplo de Ejecucion:
			EXEC [FERCO].[OP_WMS_SP_GET_MATERIALS_BY_WAREHOUSE_CLIENT_LOCATION_OR_ZONE]   
				@WAREHOUSE = 'BODEGA_01' ,
				@REGIMEN = 'GENERAL', 
				@CLIENT_CODE = 'C00016'  , 
				@LOCATION = 'B04-TB-C02-NU' ,
				@LOGIN_ID = 'ADMIN'
*/
-- =============================================
CREATE PROCEDURE FERCO.OP_WMS_SP_GET_MATERIALS_BY_WAREHOUSE_CLIENT_LOCATION_OR_ZONE (@WAREHOUSE VARCHAR(MAX)
, @REGIMEN VARCHAR(50)
, @ZONE VARCHAR(MAX) = NULL
, @CLIENT_CODE VARCHAR(MAX) = NULL
, @LOCATION VARCHAR(MAX) = NULL
, @LOGIN_ID VARCHAR(50) = NULL)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @HAS_PERMISSION INT = 0
         ,@CHECK_ID VARCHAR(25) = 'TCD001'
         ,@QUERY NVARCHAR(2000);

  -- ------------------------------------------------------------------------------------
  -- Obtiene el permiso
  -- ------------------------------------------------------------------------------------
  SELECT TOP 1
    @HAS_PERMISSION = 1
  FROM [FERCO].[OP_WMS_ROLES_JOIN_CHECKPOINTS] [C]
  INNER JOIN [FERCO].[OP_WMS_LOGINS] [L]
    ON ([L].[ROLE_ID] = [C].[ROLE_ID])
  WHERE [C].[CHECK_ID] = @CHECK_ID
  AND [L].[LOGIN_ID] = @LOGIN_ID


  SELECT
    [W].[VALUE] [CODE_WAREHOUSE] INTO [#WAREHOUSE]
  FROM [FERCO].[OP_WMS_FN_SPLIT](@WAREHOUSE, '|') [W];

  SELECT
    [Z].[VALUE] [CODE_ZONE] INTO [#ZONE]
  FROM [FERCO].[OP_WMS_FN_SPLIT](@ZONE, '|') [Z];

  SELECT
    [C].[VALUE] [CODE_CLIENT] INTO [#CLIENT]
  FROM [FERCO].[OP_WMS_FN_SPLIT](@CLIENT_CODE, '|') [C];

  SELECT
    [L].[VALUE] [LOCATION] INTO [#LOCATION]
  FROM [FERCO].[OP_WMS_FN_SPLIT](@LOCATION, '|') [L];

  --
  SELECT
    [M].[CLIENT_OWNER]
   ,[M].[MATERIAL_ID]
   ,[M].[BARCODE_ID]
   ,[M].[ALTERNATE_BARCODE]
   ,[M].[MATERIAL_NAME]
   ,[M].[SHORT_NAME]
   ,[M].[VOLUME_FACTOR]
   ,[M].[MATERIAL_CLASS]
   ,[M].[HIGH]
   ,[M].[LENGTH]
   ,[M].[WIDTH]
   ,[M].[MAX_X_BIN]
   ,[M].[SCAN_BY_ONE]
   ,[M].[REQUIRES_LOGISTICS_INFO]
   ,[M].[WEIGTH]
   ,[M].[LAST_UPDATED]
   ,[M].[LAST_UPDATED_BY]
   ,[M].[IS_CAR]
   ,[M].[MT3]
   ,[M].[BATCH_REQUESTED]
   ,[M].[SERIAL_NUMBER_REQUESTS]
   ,[M].[IS_MASTER_PACK]
   ,[M].[ERP_AVERAGE_PRICE]
   ,CASE @HAS_PERMISSION
      WHEN 1 THEN SUM([IL].[QTY]) - ISNULL(SUM([CIL].[COMMITED_QTY]), 0)
      ELSE 0
    END AS [QTY]
   ,CASE @HAS_PERMISSION
      WHEN 1 THEN SUM([IL].[QTY]) - ISNULL(SUM([CIL].[COMMITED_QTY]), 0)
      ELSE -1
    END AS [CURRENTLY_AVAILABLE]
  FROM [FERCO].[OP_WMS_INV_X_LICENSE] [IL]
  INNER JOIN [FERCO].[OP_WMS_LICENSES] [L]
    ON [L].[LICENSE_ID] = [IL].[LICENSE_ID]
  INNER JOIN [FERCO].[OP_WMS_SHELF_SPOTS] [S]
    ON [S].[LOCATION_SPOT] = [L].[CURRENT_LOCATION]
  INNER JOIN [#WAREHOUSE] [W]
    ON [S].[WAREHOUSE_PARENT] = [W].[CODE_WAREHOUSE]
  LEFT JOIN [#ZONE] [Z]
    ON [Z].[CODE_ZONE] = [S].[ZONE]
  LEFT JOIN [#CLIENT] [C]
    ON [C].[CODE_CLIENT] = [L].[CLIENT_OWNER]
  INNER JOIN [FERCO].[OP_WMS_MATERIALS] [M]
    ON [M].[MATERIAL_ID] = [IL].[MATERIAL_ID]
  LEFT JOIN [#LOCATION] [LS]
    ON [LS].[LOCATION] = [L].[CURRENT_LOCATION]
  LEFT JOIN [FERCO].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [CIL]
    ON [CIL].[MATERIAL_ID] = [IL].[MATERIAL_ID]
      AND [CIL].[LICENCE_ID] = [L].[LICENSE_ID]
  WHERE [IL].[QTY] > 0
  AND [L].[REGIMEN] = @REGIMEN
  AND (
  @ZONE IS NULL
  OR [Z].[CODE_ZONE] IS NOT NULL
  )
  AND (
  @CLIENT_CODE IS NULL
  OR [C].[CODE_CLIENT] IS NOT NULL
  )
  AND (
  @LOCATION IS NULL
  OR [LS].[LOCATION] IS NOT NULL
  )
  GROUP BY [M].[MATERIAL_ID]
          ,[M].[CLIENT_OWNER]
          ,[M].[BARCODE_ID]
          ,[M].[ALTERNATE_BARCODE]
          ,[M].[MATERIAL_NAME]
          ,[M].[SHORT_NAME]
          ,[M].[VOLUME_FACTOR]
          ,[M].[MATERIAL_CLASS]
          ,[M].[HIGH]
          ,[M].[LENGTH]
          ,[M].[WIDTH]
          ,[M].[MAX_X_BIN]
          ,[M].[SCAN_BY_ONE]
          ,[M].[REQUIRES_LOGISTICS_INFO]
          ,[M].[WEIGTH]
          ,[M].[LAST_UPDATED]
          ,[M].[LAST_UPDATED_BY]
          ,[M].[IS_CAR]
          ,[M].[MT3]
          ,[M].[BATCH_REQUESTED]
          ,[M].[SERIAL_NUMBER_REQUESTS]
          ,[M].[IS_MASTER_PACK]
          ,[M].[ERP_AVERAGE_PRICE];


END;
