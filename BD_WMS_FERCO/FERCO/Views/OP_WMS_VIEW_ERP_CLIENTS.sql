﻿
CREATE VIEW FERCO.OP_WMS_VIEW_ERP_CLIENTS
AS
SELECT
  codcliente AS CLIENT_CODE
 ,nomcliente AS CLIENT_NAME
FROM FERCO.OP_WMS_VIEW_ACUERDOS
GROUP BY codcliente
        ,nomcliente
