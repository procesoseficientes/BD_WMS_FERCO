﻿
CREATE VIEW FERCO.OP_WMS_VIEW_VALORIZACION
AS --SELECT     CLIENT_NAME, CLIENT_OWNER, NUMERO_ORDEN, LICENSE_ID, BARCODE_ID, MATERIAL_NAME, QTY, CURRENT_LOCATION, SUBSTRING(CURRENT_LOCATION, 
--                      1, 3) AS BODEGA, ISNULL
--                          ((SELECT     VALOR_UNITARIO
--                              FROM         [FERCO].OP_WMS_FUNC_GET_SKU_VALOR_UNITARIO_ALMGEN(A.DOC_ID, '%' + A.BARCODE_ID + '%') 
--                                                    AS OP_WMS_FUNC_GET_SKU_VALOR_UNITARIO_ALMGEN_2), 1.00) AS VALOR_UNITARIO, ISNULL
--                          ((SELECT     VALOR_UNITARIO
--                              FROM         [FERCO].OP_WMS_FUNC_GET_SKU_VALOR_UNITARIO_ALMGEN(A.DOC_ID, '%' + A.BARCODE_ID + '%') 
--                                                    AS OP_WMS_FUNC_GET_SKU_VALOR_UNITARIO_ALMGEN_1), 1.00) * QTY AS TOTAL_VALOR, VOLUMEN, VOLUMEN * QTY AS TOTAL_VOLUMEN, 
--                      TERMS_OF_TRADE
--                      , a.CODIGO_POLIZA
--FROM        [FERCO].OP_WMS_VIEW_INVENTORY_DETAIL  AS A

SELECT
  [CLIENT_NAME]
 ,[CLIENT_OWNER]
 ,[NUMERO_ORDEN]
 ,[LICENSE_ID]
 ,[BARCODE_ID]
 ,[MATERIAL_NAME]
 ,[QTY]
 ,[CURRENT_LOCATION]
 ,[BODEGA]
 ,[VALOR_UNITARIO]
 ,[TOTAL_VALOR]
 ,[VOLUMEN]
 ,[TOTAL_VOLUMEN]
 ,[TERMS_OF_TRADE]
 ,[CODIGO_POLIZA]
 ,[BATCH]
 ,[DATE_EXPIRATION]
 ,[VIN]
 ,[CURRENT_WAREHOUSE]
 ,[MATERIAL_ID]
FROM [FERCO].OP_WMS_VIEW_VALORIZACION_ALMGEN
UNION
SELECT
  [CLIENT_NAME]
 ,[CLIENT_OWNER]
 ,[NUMERO_ORDEN]
 ,[LICENSE_ID]
 ,[BARCODE_ID]
 ,[MATERIAL_NAME]
 ,[QTY]
 ,[CURRENT_LOCATION]
 ,[BODEGA]
 ,[VALOR_UNITARIO]
 ,[TOTAL_VALOR]
 ,[VOLUMEN]
 ,[TOTAL_VOLUMEN]
 ,[TERMS_OF_TRADE]
 ,[CODIGO_POLIZA]
 ,[BATCH]
 ,[DATE_EXPIRATION]
 ,[VIN]
 ,[CURRENT_WAREHOUSE]
 ,[MATERIAL_ID]
FROM [FERCO].OP_WMS_VIEW_VALORIZACION_FISCAL
