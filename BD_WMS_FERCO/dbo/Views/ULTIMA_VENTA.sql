﻿CREATE VIEW ULTIMA_VENTA AS 
 SELECT  MATERIAL_ID, MAX( PH.POSTED_ERP)  UTL_FECHA ,SUM(PD.QTY*PD.PRICE) VENTA,
         --PH.CODE_WAREHOUSE
        DATEDIFF(day ,MAX( PH.POSTED_ERP),getdate()) Dias
 FROM  FERCO.OP_WMS_NEXT_PICKING_DEMAND_DETAIL PD , FERCO.OP_WMS_NEXT_PICKING_DEMAND_HEADER PH
 WHERE PD.PICKING_DEMAND_HEADER_ID = PH.PICKING_DEMAND_HEADER_ID
--AND PH.POSTED_STATUS = 1
GROUP BY MATERIAL_ID --PH.CODE_WAREHOUSE,