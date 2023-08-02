﻿
/*WHERE
	A.QTY > 0*/
CREATE VIEW FERCO.OP_WMS_VIEW_REPORTES_ALMGEN
AS
SELECT
  CLIENT_NAME
 ,CLIENT_OWNER
 ,NUMERO_ORDEN
 ,LICENSE_ID
 ,BARCODE_ID
 ,MATERIAL_NAME
 ,QTY
 ,CURRENT_LOCATION
 ,SUBSTRING(CURRENT_LOCATION,
  1, 3) AS BODEGA
 ,ISNULL
  ((SELECT
      VALOR_UNITARIO
    FROM FERCO.OP_WMS_FUNC_GET_SKU_VALOR_UNITARIO_ALMGEN(A.CODIGO_POLIZA, '%' + A.BARCODE_ID + '%')
    AS OP_WMS_FUNC_GET_SKU_VALOR_UNITARIO_ALMGEN_2)
  , 1.00) AS VALOR_UNITARIO
 ,ISNULL
  ((SELECT
      VALOR_UNITARIO
    FROM FERCO.OP_WMS_FUNC_GET_SKU_VALOR_UNITARIO_ALMGEN(A.CODIGO_POLIZA, '%' + A.BARCODE_ID + '%')
    AS OP_WMS_FUNC_GET_SKU_VALOR_UNITARIO_ALMGEN_1)
  , 1.00) * QTY AS TOTAL_VALOR
 ,VOLUMEN
 ,VOLUMEN * QTY AS TOTAL_VOLUMEN
 ,MATERIAL_CLASS
 ,TERMS_OF_TRADE
FROM FERCO.OP_WMS_VIEW_INVENTORY_DETAIL_ALMGEN AS A