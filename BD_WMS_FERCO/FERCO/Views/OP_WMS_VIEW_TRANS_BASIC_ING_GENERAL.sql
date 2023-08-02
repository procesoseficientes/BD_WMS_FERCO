﻿
CREATE VIEW FERCO.OP_WMS_VIEW_TRANS_BASIC_ING_GENERAL
AS
SELECT
  TB.CODIGO_POLIZA
 ,TARGET_WAREHOUSE
 ,CLIENT_NAME
 ,SUM(QUANTITY_UNITS) AS QUANTITY_UNITS
 ,(SELECT TOP 1
      TEXT_VALUE
    FROM [FERCO].OP_WMS_MATERIALS
    INNER JOIN [FERCO].OP_WMS_CONFIGURATIONS
      ON (MATERIAL_CLASS = PARAM_NAME
      AND PARAM_TYPE = 'PRODUCTOS'
      AND PARAM_GROUP = 'CLASES')
    WHERE MATERIAL_ID = MAX(TB.MATERIAL_CODE))
  AS TypeMaterial
  --, (SELECT TOP 1 MATERIAL_CLASS
  --	FROM [FERCO].OP_WMS_MATERIALS
  --	WHERE MATERIAL_ID = MAX(TB.MATERIAL_CODE)) AS TypeMaterial
 ,MATERIAL_DESCRIPTION
 ,ISNULL((SELECT
      VALOR_UNITARIO
    FROM [FERCO].OP_WMS_FUNC_GET_SKU_VALOR_UNITARIO_ALMGEN((SELECT TOP 1
        P.DOC_ID
      FROM [FERCO].[OP_WMS_POLIZA_HEADER] P
      WHERE P.CODIGO_POLIZA = MAX(TB.CODIGO_POLIZA)
      AND P.TIPO = 'INGRESO')
    , '%' + MAX(TB.MATERIAL_BARCODE) + '%')
    AS OP_WMS_FUNC_GET_SKU_VALOR_UNITARIO_ALMGEN_2)
  , 1.00) AS VALOR_UNITARIO
 ,(SUM(QUANTITY_UNITS) * ISNULL((SELECT
      VALOR_UNITARIO
    FROM [FERCO].OP_WMS_FUNC_GET_SKU_VALOR_UNITARIO_ALMGEN((SELECT TOP 1
        P.DOC_ID
      FROM [FERCO].[OP_WMS_POLIZA_HEADER] P
      WHERE P.CODIGO_POLIZA = MAX(TB.CODIGO_POLIZA)
      AND P.TIPO = 'INGRESO')
    , '%' + MAX(TB.MATERIAL_BARCODE) + '%')
    AS OP_WMS_FUNC_GET_SKU_VALOR_UNITARIO_ALMGEN_2)
  , 1.00)) AS TOTAL_VALOR
 ,MAX(TB.TRANS_DATE) AS TRANS_DATE
FROM [FERCO].OP_WMS_VIEW_TRANS_BASIC TB
WHERE TRANS_TYPE = 'INGRESO_GENERAL'
GROUP BY CODIGO_POLIZA
        ,TARGET_WAREHOUSE
        ,CLIENT_NAME
        ,MATERIAL_DESCRIPTION
