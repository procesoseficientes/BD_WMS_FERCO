﻿









-- =============================================
-- Autor:					pablo.aguilar
-- Fecha de Creacion: 		25-Jun-18 @ Nexus-Team Sprint  
-- Description:			    

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [FERCO].[OP_WMS_VW_GET_PICKED_INVENTORY_WITH_PENDING_ERP_SENDING]
*/
-- =============================================
CREATE VIEW [FERCO].[OP_WMS_VW_GET_PICKED_INVENTORY_WITH_PENDING_ERP_SENDING]
AS
(

	SELECT  [DT].[WAREHOUSE_SOURCE]
			,[DT].[MATERIAL_ID]
			,SUM([DT].[RESERVADO]) [RESERVADO] 
			, [DT].[Tipo] 
	FROM  (

			SELECT
				[T].[WAREHOUSE_SOURCE]
				,[T].[MATERIAL_ID]
				,SUM([T].[QUANTITY_ASSIGNED] - [T].[QUANTITY_PENDING]) [RESERVADO]
				, 'Venta' [Tipo]
			FROM
				[FERCO].[OP_WMS_TASK_LIST] [T]
				INNER JOIN [FERCO].[OP_WMS_MATERIALS] M ON [M].[MATERIAL_ID] = [T].[MATERIAL_ID]
			WHERE
				[T].[TASK_TYPE] = 'TAREA_PICKING'
				AND [T].[TASK_SUBTYPE] <> 'DESPACHO_WT'
				AND [T].[IS_COMPLETED] = 1
				AND ([T].[IS_PAUSED] <> 3)
				AND ([T].[CANCELED_DATETIME] IS NULL)
				AND [T].[WAVE_PICKING_ID] IN 
				(
					SELECT
						[H].[WAVE_PICKING_ID]
						
					FROM
						[FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H]			
						LEFT JOIN [SAPSERVER].[SBOFERCO].[dbo].[ORDR] R ON CAST(R.[DocEntry] AS VARCHAR) = [H].[DOC_ENTRY] AND R.[DocStatus]= 'O'
						LEFT JOIN [SAPSERVER].[SBOFERCO].[dbo].[RDR1] d ON [R].[DocEntry] = d.[DocEntry] AND  [d].[LineStatus] ='O'
						LEFT JOIN  [SAPSERVER].[SBOFERCO].[dbo].[ODRF] p ON CAST(R.[DocEntry] AS VARCHAR) = [H].[DOC_ENTRY] AND  [p].[DocStatus] ='O'
						LEFT JOIN   [SAPSERVER].[SBOFERCO].[dbo].[DRF1] p1 ON [p1].[DocEntry] = [p].[DocEntry] AND  [p1].[LineStatus] ='O'
						
						--AND [M].[ITEM_COE_ERP] =  D.[ItemCode] COLLATE SQL_Latin1_General_CP850_CI_AS
					WHERE
						[H].[WAVE_PICKING_ID] = [T].[WAVE_PICKING_ID]
						AND [H].[IS_POSTED_ERP] <> 1
						AND ([H].[DOC_ENTRY] = CAST(R.[DocEntry] AS VARCHAR) or [H].[DOC_ENTRY] =CAST(P.[DocEntry] AS VARCHAR))
						
						
				)
			GROUP BY
				[T].[MATERIAL_ID]
				,[T].[WAREHOUSE_SOURCE]
			HAVING
				SUM([T].[QUANTITY_ASSIGNED] - [T].[QUANTITY_PENDING]) > 0
		
	
			) AS DT 
			WHERE DT.WAREHOUSE_SOURCE = 'CEDI_ZONA_5'
	GROUP BY [DT].[WAREHOUSE_SOURCE]
			,[DT].[MATERIAL_ID]
			,tipo
)
