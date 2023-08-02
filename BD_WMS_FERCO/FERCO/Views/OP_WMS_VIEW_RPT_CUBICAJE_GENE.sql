﻿
CREATE VIEW FERCO.OP_WMS_VIEW_RPT_CUBICAJE_GENE
AS
SELECT
  CLIENT_NAME
 ,REGIMEN
 ,MATERIAL_CLASS
 ,BARCODE_ID
 ,MATERIAL_NAME
 ,VOLUMEN
 ,SUM(QTY) AS CANTIDAD
 ,SUM(TOTAL_VOLUMEN)
  AS TOTAL_VOLUMEN
FROM FERCO.OP_WMS_VIEW_RPT_ALMGEN
WHERE (QTY > 0)
GROUP BY REGIMEN
        ,BARCODE_ID
        ,MATERIAL_NAME
        ,MATERIAL_CLASS
        ,VOLUMEN
        ,CLIENT_NAME
