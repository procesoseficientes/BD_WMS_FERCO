﻿
CREATE VIEW FERCO.OP_WMS_VIEW_VENCIMIENTO_POR_POLIZA_SEGURO
AS

SELECT
  I.POLIZA_INSURANCE
 ,P.DOC_ID
 ,P.CODIGO_POLIZA
 ,P.NUMERO_ORDEN
 ,C.CLIENT_NAME
 ,T.ACUERDO_COMERCIAL_NOMBRE
 ,P.FECHA_LLEGADA
 ,VALIN_TO
 ,CASE
    WHEN DATEDIFF(DAY, GETDATE(), VALIN_TO) <= 0 THEN 0
    ELSE DATEDIFF(DAY, GETDATE(), VALIN_TO)
  END AS DAYS_REMAINING
FROM FERCO.OP_WMS_POLIZA_HEADER P
INNER JOIN FERCO.OP_WMS_TARIFICADOR_HEADER T
  ON ACUERDO_COMERCIAL_ID = ACUERDO_COMERCIAL
INNER JOIN FERCO.OP_WMS_VIEW_CLIENTS C
  ON P.CLIENT_CODE = C.CLIENT_CODE
INNER JOIN FERCO.OP_WMS_INSURANCE_DOCS I
  ON P.POLIZA_ASEGURADA = I.DOC_ID
WHERE TIPO = 'INGRESO'
AND WAREHOUSE_REGIMEN = 'FISCAL'
UNION
SELECT
  CF.TEXT_VALUE
 ,P.DOC_ID
 ,P.CODIGO_POLIZA
 ,P.NUMERO_ORDEN
 ,C.CLIENT_NAME
 ,T.ACUERDO_COMERCIAL_NOMBRE
 ,P.FECHA_LLEGADA
 ,RANGE_DATE_END
 ,CASE
    WHEN DATEDIFF(DAY, GETDATE(), RANGE_DATE_END) <= 0 THEN 0
    ELSE DATEDIFF(DAY, GETDATE(), RANGE_DATE_END)
  END AS DAYS_REMAINING
FROM FERCO.OP_WMS_POLIZA_HEADER P
INNER JOIN FERCO.OP_WMS_TARIFICADOR_HEADER T
  ON ACUERDO_COMERCIAL_ID = ACUERDO_COMERCIAL
INNER JOIN FERCO.OP_WMS_VIEW_CLIENTS C
  ON P.CLIENT_CODE = C.CLIENT_CODE
INNER JOIN FERCO.OP_WMS_CONFIGURATIONS CF
  ON P.POLIZA_ASEGURADA = CF.TEXT_VALUE
WHERE TIPO = 'INGRESO'
AND WAREHOUSE_REGIMEN = 'FISCAL'
AND CF.PARAM_TYPE = 'POLIZAS'
AND CF.PARAM_GROUP = 'POLIZAS_SEGUROS'
