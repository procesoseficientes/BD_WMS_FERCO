﻿
-- =============================================
-- Autor:					pablo.aguilar
-- Fecha de Creacion: 		25-Jun-18 @ Nexus-Team Sprint  
-- Description:			    

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [FERCO].[OP_WMS_VW_GET_RECEPTION_WITH_PENDING_ERP_SENDING]
*/
-- =============================================
CREATE VIEW [FERCO].[OP_WMS_VW_GET_RECEPTION_WITH_PENDING_ERP_SENDING]
AS
(
			SELECT
				[T].[WAREHOUSE_SOURCE]
				,[T].[MATERIAL_ID]
				,T.LICENSE_ID_SOURCE
				,T.ACCEPTED_DATE
				,T.ASSIGNED_DATE
				,T.COMPLETED_DATE
				,T.WAVE_PICKING_ID
				,[T].[TASK_SUBTYPE] 
				,t.DOC_ID_TARGET  documento
				,[T].[QUANTITY_ASSIGNED] - [T].[QUANTITY_PENDING] [RESERVADO]
			FROM
				[FERCO].[OP_WMS_TASK_LIST] [T]
				INNER JOIN [FERCO].[OP_WMS_MATERIALS] M ON [M].[MATERIAL_ID] = [T].[MATERIAL_ID]
				LEFT JOIN [FERCO].[OP_WMS_LICENSES] [L]  ON (
														CAST(T.DOC_ID_SOURCE AS VARCHAR) = L.CODIGO_POLIZA
														)
				LEFT JOIN [FERCO].[OP_WMS_INV_X_LICENSE] IL ON IL.LICENSE_ID = L.LICENSE_ID AND IL.MATERIAL_ID = T.MATERIAL_ID
			WHERE 
				[T].[TASK_TYPE] = 'TAREA_RECEPCION'
				--AND [T].[TASK_SUBTYPE] <> 'DESPACHO_WT'
				AND [T].[IS_COMPLETED] = 1
				AND ([T].[IS_PAUSED] <> 3)
				AND ([T].[CANCELED_DATETIME] IS NULL)
				--AND [T].[QUANTITY_ASSIGNED] - [T].[QUANTITY_PENDING] > 0
				AND [IL].[LOCKED_BY_INTERFACES] = 1  
				AND [IL].[QTY] > 0
				AND [IL].[STATUS] <> 'DISPATCH'
				AND [L].[CURRENT_LOCATION] IS NOT NULL
				AND [M].[NON_STORAGE] = 0
				--AND [W].[WAREHOUSE_ID] = 'CEDI_ZONA_5'
				AND [L].[WAVE_PICKING_ID] IS NULL
				
)
