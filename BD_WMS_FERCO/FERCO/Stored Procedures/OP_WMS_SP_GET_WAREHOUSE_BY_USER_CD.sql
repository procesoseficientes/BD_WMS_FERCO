
-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-01-31 @ Team ERGON - Sprint ERGON II
-- Description:	        consultar a la tabla OP_WMS_WAREHOUSES_BY_USER filtrando por login 

/*
-- Ejemplo de Ejecucion:
			EXEC  [FERCO].[OP_WMS_SP_GET_WAREHOUSE_BY_USER_CD] @LOGIN = DEFAULT
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_GET_WAREHOUSE_BY_USER_CD] (@LOGIN VARCHAR(50)= NULL)
AS
BEGIN
  SET NOCOUNT ON;
  --SELECT 
  -- [WU].[WAREHOUSE_BY_USER_ID]
  -- ,[WU].[LOGIN_ID]
  -- ,[WU].[WAREHOUSE_ID]
  -- ,[W].[NAME]
  -- ,[W].[ERP_WAREHOUSE]
  --FROM [FERCO].[OP_WMS_WAREHOUSE_BY_USER] [WU]
  --INNER JOIN [FERCO].[OP_WMS_WAREHOUSES] [W]
  --  ON (
  --    [W].[WAREHOUSE_ID] = [WU].[WAREHOUSE_ID]
  --    )
  --WHERE [WU].[LOGIN_ID] = @LOGIN 

  IF @LOGIN IS NULL
  BEGIN 
  SELECT DISTINCT 
   -- [WU].[WAREHOUSE_BY_USER_ID]
   --,[WU].[LOGIN_ID]
   [WU].[WAREHOUSE_ID]
   ,[W].[NAME]
    ,[W].[ERP_WAREHOUSE]
  FROM [FERCO].[OP_WMS_WAREHOUSE_BY_USER] [WU]
  INNER JOIN [FERCO].[OP_WMS_WAREHOUSES] [W]
    ON (
      [W].[WAREHOUSE_ID] = [WU].[WAREHOUSE_ID]
      )
  WHERE @LOGIN IS NULL OR [WU].[LOGIN_ID] = @LOGIN
  END 

  ELSE
  BEGIN 
    SELECT DISTINCT 
   [WU].[WAREHOUSE_BY_USER_ID]
   ,[WU].[LOGIN_ID]
   ,[WU].[WAREHOUSE_ID]
   ,[W].[NAME]
    ,[W].[ERP_WAREHOUSE]
  FROM [FERCO].[OP_WMS_WAREHOUSE_BY_USER] [WU]
  INNER JOIN [FERCO].[OP_WMS_WAREHOUSES] [W]
    ON (
      [W].[WAREHOUSE_ID] = [WU].[WAREHOUSE_ID]
      )
  WHERE [WU].[LOGIN_ID] = @LOGIN 
END 
END
