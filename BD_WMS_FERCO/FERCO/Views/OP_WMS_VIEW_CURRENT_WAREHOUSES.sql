﻿
CREATE VIEW FERCO.OP_WMS_VIEW_CURRENT_WAREHOUSES
AS
SELECT DISTINCT TOP (100) PERCENT
  CURRENT_WAREHOUSE
FROM FERCO.OP_WMS_LICENSES
WHERE (CURRENT_WAREHOUSE IS NOT NULL)
ORDER BY CURRENT_WAREHOUSE
