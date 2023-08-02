﻿CREATE VIEW ULTIMA_FECHA AS 
SELECT RD.MATERIAL_ID,  max(RH.POSTED_ERP )  UTL_FECHA ,
DATEDIFF(day ,MAX( RH.POSTED_ERP),getdate()) Dias
FROM FERCO.OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL RD , FERCO.OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER RH
WHERE RD.ERP_RECEPTION_DOCUMENT_HEADER_ID = RH.ERP_RECEPTION_DOCUMENT_HEADER_ID
AND  RH.TYPE <> 'DEVOLUCION_FACTURA'
GROUP BY RD.MATERIAL_ID