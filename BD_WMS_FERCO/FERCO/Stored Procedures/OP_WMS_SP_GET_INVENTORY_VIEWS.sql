﻿
-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-03-24 @ Team ERGON - Sprint ERGON 
-- Description:	        Sp que devuelve las vistas de Vistas del inventario

-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-05-22 @ Team ERGON - Sprint Sheik
-- Description:	        Se agrego SERIAL_NUMBER Y HANDLE_SERIAL 

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-09-05 @ Team REBORN - Sprint 
-- Description:	   Se agregaron STATUS_NAME, [BLOCKS_INVENTORY] y COLOR en los 3 if 

/*
-- Ejemplo de Ejecucion:
			EXEC  [FERCO].[OP_WMS_SP_GET_INVENTORY_VIEWS] @VIEW ='BY_'
                                                      , @LOGIN = 'ADMIN'
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_GET_INVENTORY_VIEWS] (@VIEW VARCHAR(25)
, @LOGIN VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --

  CREATE TABLE #WAREHOUSES (
    WAREHOUSE_ID VARCHAR(25)
   ,NAME VARCHAR(50)
   ,COMMENTS VARCHAR(253)
   ,ERP_WAREHOUSE VARCHAR(50)
   ,ALLOW_PICKING NUMERIC
   ,DEFAULT_RECEPTION_LOCATION VARCHAR(25)
   ,SHUNT_NAME VARCHAR(25)
   ,WAREHOUSE_WEATHER VARCHAR(50)
   ,WAREHOUSE_STATUS INT
   ,IS_3PL_WAREHUESE INT
   ,WAHREHOUSE_ADDRESS VARCHAR(250)
   ,GPS_URL VARCHAR(100)
   ,WAREHOUSE_BY_USER_ID INT
    UNIQUE ([WAREHOUSE_ID])
  )

  INSERT INTO #WAREHOUSES
  EXEC [FERCO].[OP_WMS_SP_GET_WAREHOUSE_ASSOCIATED_WITH_USER] @LOGIN_ID = @LOGIN

  IF (@VIEW = 'BY_WAREHOUSE')
  BEGIN
    SELECT
      [IW].[CURRENT_WAREHOUSE]
     ,[IW].[CLIENT_OWNER]
     ,[IW].[CLIENT_NAME]
     ,[IW].[TERMS_OF_TRADE]
     ,[IW].[MATERIAL_ID]
     ,[IW].[BARCODE_ID]
     ,[IW].[ALTERNATE_BARCODE]
     ,[IW].[MATERIAL_NAME]
     ,[IW].[QTY]
     ,[IW].[VOLUMEN]
     ,[IW].[TOTAL_VOLUMEN]
     ,([IW].[QTY] - ISNULL([IR].[QTY_RESERVED], 0)) AS AVAILABLE_QTY
     ,NULL AS BATCH
     ,NULL AS [DATE_EXPIRATION]
     ,NULL AS SERIAL_NUMBER
     ,CASE [IW].[HANDLE_SERIAL]
        WHEN 1 THEN 'Si'
        WHEN 0 THEN 'No'
        ELSE 'No'
      END [HANDLE_SERIAL]
     ,[IW].[STATUS_NAME]
     ,[IW].[BLOCKS_INVENTORY]
     ,[IW].[COLOR]
     ,[IW].[TONE]
     ,[IW].[CALIBER]
    FROM [FERCO].[OP_WMS_VIEW_INVENTORY_X_WAREHOUSE] [IW]
    INNER JOIN [#WAREHOUSES] [W]
      ON [IW].[CURRENT_WAREHOUSE] COLLATE DATABASE_DEFAULT = [W].[WAREHOUSE_ID]
    LEFT JOIN [FERCO].[OP_WMS_FUNC_GET_INVENTORY_RESERVED]() [IR]
      ON ([IR].[CODE_WAREHOUSE] = [IW].[CURRENT_WAREHOUSE]
          AND [IR].[CODE_MATERIAL] = [IW].[MATERIAL_ID])
  END

  IF (@VIEW = 'BY_REGIMEN')
  BEGIN
    SELECT
      [IR].[REGIMEN]
     ,[IR].[CURRENT_WAREHOUSE]
     ,[IR].[CLIENT_OWNER]
     ,[IR].[CLIENT_NAME]
     ,[IR].[MATERIAL_ID]
     ,[IR].[BARCODE_ID]
     ,[IR].[ALTERNATE_BARCODE]
     ,[IR].[MATERIAL_NAME]
     ,[IR].[QTY]
     ,[IR].[VOLUMEN]
     ,[IR].[TOTAL_VOLUMEN]
     ,[IR].[REGIMEN_DOCUMENTO]
     ,[IR].[GRUPO_REGIMEN]
     ,([IR].[QTY] - ISNULL([IBL].[COMMITED_QTY], 0)) AS AVAILABLE_QTY
     ,[IR].[BATCH]
     ,[IR].[DATE_EXPIRATION]
     ,[IR].[SERIAL_NUMBER]
     ,CASE [IR].[HANDLE_SERIAL]
        WHEN 1 THEN 'Si'
        WHEN 0 THEN 'No'
        ELSE 'No'
      END [HANDLE_SERIAL]
     ,[IR].[STATUS_NAME]
     ,[IR].[BLOCKS_INVENTORY]
     ,[IR].[COLOR]
     ,[IR].[TONE]
     ,[IR].[CALIBER]
    FROM [FERCO].[OP_WMS_VIEW_INVENTORY_X_REGIMEN] [IR]
    INNER JOIN [#WAREHOUSES] [W]
      ON [IR].[CURRENT_WAREHOUSE] COLLATE DATABASE_DEFAULT = [W].[WAREHOUSE_ID]
    LEFT JOIN [FERCO].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [IBL]
      ON [IR].[LICENSE_ID] = [IBL].[LICENCE_ID]
        AND [IBL].[MATERIAL_ID] = [IR].[MATERIAL_ID]
        AND [IBL].[CODE_WAREHOUSE] = [IR].[CURRENT_WAREHOUSE]
  END

  IF (@VIEW = 'BY_TOT')
  BEGIN
    SELECT
      [IT].[TERMS_OF_TRADE]
     ,[IT].[CURRENT_WAREHOUSE]
     ,[IT].[CLIENT_OWNER]
     ,[IT].[CLIENT_NAME]
     ,[IT].[MATERIAL_ID]
     ,[IT].[BARCODE_ID]
     ,[IT].[ALTERNATE_BARCODE]
     ,[IT].[MATERIAL_NAME]
     ,[IT].[QTY]
     ,[IT].[VOLUMEN]
     ,[IT].[TOTAL_VOLUMEN]
     ,([IT].[QTY] - ISNULL([IBL].[COMMITED_QTY], 0)) AS AVAILABLE_QTY
     ,[IT].[BATCH]
     ,[IT].[DATE_EXPIRATION]
     ,[IT].[SERIAL_NUMBER]
     ,CASE [IT].[HANDLE_SERIAL]
        WHEN 1 THEN 'Si'
        WHEN 0 THEN 'No'
        ELSE 'No'
      END [HANDLE_SERIAL]
     ,[IT].[STATUS_NAME]
     ,[IT].[BLOCKS_INVENTORY]
     ,[IT].[COLOR]
     ,[IT].[TONE]
     ,[IT].[CALIBER]
    FROM [FERCO].[OP_WMS_VIEW_INVENTORY_X_TERMS_OF_TRADE] [IT]
    INNER JOIN [#WAREHOUSES] [W]
      ON [IT].[CURRENT_WAREHOUSE] COLLATE DATABASE_DEFAULT = [W].[WAREHOUSE_ID]
    LEFT JOIN [FERCO].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [IBL]
      ON [IBL].[LICENCE_ID] = [IT].[LICENSE_ID]
        AND [IBL].[MATERIAL_ID] = [IT].[MATERIAL_ID]
        AND [IBL].[CODE_WAREHOUSE] = [IT].[CURRENT_WAREHOUSE]
  END

  IF (@VIEW = 'BY_CLIENT')
  BEGIN
    SELECT
      [IC].[CLIENT_OWNER]
     ,[IC].[CLIENT_NAME]
     ,[IC].[REGIMEN]
     ,[IC].[CURRENT_WAREHOUSE]
     ,[IC].[MATERIAL_ID]
     ,[IC].[BARCODE_ID]
     ,[IC].[ALTERNATE_BARCODE]
     ,[IC].[MATERIAL_NAME]
     ,[IC].[QTY]
     ,[IC].[VOLUMEN]
     ,[IC].[TOTAL_VOLUMEN]
     ,([IC].[QTY] - ISNULL([IBL].[COMMITED_QTY], 0)) AS AVAILABLE_QTY
     ,[IC].[BATCH]
     ,[IC].[DATE_EXPIRATION]
     ,[IC].[SERIAL_NUMBER]
     ,CASE [IC].[HANDLE_SERIAL]
        WHEN 1 THEN 'Si'
        WHEN 0 THEN 'No'
        ELSE 'No'
      END [HANDLE_SERIAL]
     ,[IC].[STATUS_NAME]
     ,[IC].[BLOCKS_INVENTORY]
     ,[IC].[COLOR]
     ,[IC].[TONE]
     ,[IC].[CALIBER]
    FROM [FERCO].[OP_WMS_VIEW_INVENTORY_X_CLIENT] [IC]
    INNER JOIN [#WAREHOUSES] [W]
      ON [IC].[CURRENT_WAREHOUSE] COLLATE DATABASE_DEFAULT = [W].[WAREHOUSE_ID]
    LEFT JOIN [FERCO].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [IBL]
      ON [IBL].[LICENCE_ID] = [IC].[LICENSE_ID]
        AND [IBL].[MATERIAL_ID] = [IC].[MATERIAL_ID]
        AND [IBL].[CODE_WAREHOUSE] = [IC].[CURRENT_WAREHOUSE]
  END

END