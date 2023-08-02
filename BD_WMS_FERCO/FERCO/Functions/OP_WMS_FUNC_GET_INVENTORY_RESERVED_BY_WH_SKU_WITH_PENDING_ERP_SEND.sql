﻿
-- =============================================
-- Autor:	        rudi.garcia
-- Fecha de Creacion: 	2017-03-24 @ Team ERGON - Sprint Hyper
-- Description:	        Funcion que obtiene el inventario reservado


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-04-12 Team ERGON - Sprint ERGON EPONA
-- Description:	 Se modifica para que el inventario reservado realize un SUM a las tareas pendientes

-- Modificación: pablo.aguilar
-- Fecha de Modificaci[on: 2017-05-03 ErgonTeam@Ganondorf
-- Description:	 Se agrega para que tome en cuenta tambien a las tareas de reubicación

-- Modificacion 9/20/2017 @ NEXUS-Team Sprint DuckHunt
					-- rodrigo.gomez
					-- Se agrega el tipo de implosion para inventario reservado



/*
-- Ejemplo de Ejecucion:
			SELECT * FROM [FERCO].OP_WMS_FUNC_GET_INVENTORY_RESERVED()
*/
-- =============================================
CREATE FUNCTION [FERCO].[OP_WMS_FUNC_GET_INVENTORY_RESERVED_BY_WH_SKU_WITH_PENDING_ERP_SEND] (
	@pCODE_WAREHOUSE VARCHAR(25),
	@pCODE_MATERIAL VARCHAR(50)
)
RETURNS @MATERIALES_RESERVADO TABLE (
  CODE_WAREHOUSE	VARCHAR(25)
 ,CODE_MATERIAL		VARCHAR(50)
 ,QTY_RESERVED		NUMERIC(18, 4)
 ,ERP_WAREHOUSE		VARCHAR(25)
)
AS
BEGIN

  INSERT INTO @MATERIALES_RESERVADO
    SELECT
      [T].[WAREHOUSE_SOURCE]
     ,[T].[MATERIAL_ID]
     ,SUM([T].[QUANTITY_PENDING]) RESERVADO
	 ,((SELECT TOP 1  ERP_WAREHOUSE FROM FERCO.OP_WMS_WAREHOUSES WHERE WAREHOUSE_SOURCE = [T].WAREHOUSE_SOURCE)) AS ERP_WAREHOUSE
    FROM [FERCO].[OP_WMS_TASK_LIST] [T]
		LEFT JOIN [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] PH ON [PH].[WAVE_PICKING_ID] = [T].[WAVE_PICKING_ID]
    WHERE [T].[TASK_TYPE] IN ('TAREA_PICKING', 'TAREA_REUBICACION','IMPLOSION_INVENTARIO')
    AND (T.[IS_COMPLETED] <> 1 OR ( [PH].[IS_POSTED_ERP] = 0))
    AND (T.[IS_PAUSED] <> 3)
    AND (T.[CANCELED_DATETIME] IS NULL)
	AND T.WAREHOUSE_SOURCE = @pCODE_WAREHOUSE
	AND T.MATERIAL_ID = @pCODE_MATERIAL
    GROUP BY [T].[MATERIAL_ID]
            ,[T].[WAREHOUSE_SOURCE]

  RETURN;
END



