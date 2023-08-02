-- =============================================
-- Autor:					pablo.aguilar
-- Fecha de Creacion: 		25-Jun-18 @ Nexus-Team Sprint  
-- Description:			    

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [FERCO].[OP_WMS_VW_GET_PICKED_INVENTORY_DETAIL_WITH_PENDING_ERP_SENDING] where material_id = 'ferco/001762'
*/
-- =============================================
CREATE VIEW [FERCO].[OP_WMS_VW_GET_PICKED_INVENTORY_DETAIL_WITH_PENDING_ERP_SENDING]
AS
(SELECT
		[DT].[WAREHOUSE_SOURCE]
		,[DT].[MATERIAL_ID]
		,SUM([DT].[RESERVADO]) [RESERVADO]
		,[DT].[LICENSE_ID_SOURCE]
		,[DT].[Pendiente De envio]
		,[DT].[Fuente]
		,[DT].[Ola]
		,MIN([DT].[Destino]) [Destino]
	FROM
		(SELECT
				[T].[WAREHOUSE_SOURCE]
				,[T].[MATERIAL_ID]
				,SUM([T].[QUANTITY_ASSIGNED]
						- [T].[QUANTITY_PENDING]) [RESERVADO]
				,[T].[LICENSE_ID_SOURCE]
				,1 [Pendiente De envio]
				,'Picking Orden de venta' [Fuente]
				,[T].[WAVE_PICKING_ID] [Ola]
				,[T].[LOCATION_SPOT_TARGET] [Destino]
			FROM
				[FERCO].[OP_WMS_TASK_LIST] [T]
			INNER JOIN [FERCO].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [T].[MATERIAL_ID]
			WHERE
				[T].[TASK_TYPE] = 'TAREA_PICKING'
				AND [T].[TASK_SUBTYPE] <> 'DESPACHO_WT'
				AND [T].[IS_COMPLETED] = 1
				AND ([T].[IS_PAUSED] <> 3)
				AND ([T].[CANCELED_DATETIME] IS NULL)
				AND [T].[WAVE_PICKING_ID] IN (
				SELECT
					[H].[WAVE_PICKING_ID]
				FROM
					[FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H]
				INNER JOIN [SAPSERVER].[SBOFERCO].[dbo].[ORDR] [R] ON [R].[DocEntry] = [H].[DOC_ENTRY]
											AND [R].[DocStatus] = 'O'
				INNER JOIN [SAPSERVER].[SBOFERCO].[dbo].[RDR1] [d] ON [R].[DocEntry] = [d].[DocEntry]
											AND [d].[LineStatus] = 'O'
											AND [M].[ITEM_CODE_ERP] = [d].[ItemCode] COLLATE SQL_Latin1_General_CP850_CI_AS
				WHERE
					[H].[WAVE_PICKING_ID] = [T].[WAVE_PICKING_ID]
					AND [H].[IS_POSTED_ERP] <> 1)
			GROUP BY
				[T].[MATERIAL_ID]
				,[T].[WAREHOUSE_SOURCE]
				,[T].[LICENSE_ID_SOURCE]
				,[T].[WAVE_PICKING_ID]
				,[T].[LOCATION_SPOT_TARGET]
			HAVING
				SUM([T].[QUANTITY_ASSIGNED]
					- [T].[QUANTITY_PENDING]) > 0
			UNION
			SELECT
				[T].[WAREHOUSE_SOURCE]
				,[T].[MATERIAL_ID]
				,SUM([T].[QUANTITY_ASSIGNED]
						- [T].[QUANTITY_PENDING]) [RESERVADO]
				,[T].[LICENSE_ID_SOURCE]
				,1 [Pendiente De envio]
				,'Picking Transferencia bodega' [Fuente]
				,[T].[WAVE_PICKING_ID] [Ola]
				,[T].[LOCATION_SPOT_TARGET] [Destino]
			FROM
				[FERCO].[OP_WMS_TASK_LIST] [T]
			INNER JOIN [FERCO].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [T].[MATERIAL_ID]
			WHERE
				[T].[TASK_TYPE] = 'TAREA_PICKING'
				AND [T].[TASK_SUBTYPE] = 'DESPACHO_WT'
				AND [T].[IS_COMPLETED] = 1
				AND ([T].[IS_PAUSED] <> 3)
				AND ([T].[CANCELED_DATETIME] IS NULL)
				AND [T].[WAVE_PICKING_ID] IN (
				SELECT
					[H].[WAVE_PICKING_ID]
				FROM
					[FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H]
				INNER JOIN [SAPSERVER].[SBOFERCO].[dbo].[OWTQ] [R] ON [R].[DocEntry] = [H].[DOC_ENTRY]
											AND [R].[DocStatus] = 'O'
				INNER JOIN [SAPSERVER].[SBOFERCO].[dbo].[WTQ1] [d] ON [R].[DocEntry] = [d].[DocEntry]
											AND [d].[LineStatus] = 'O'
											AND [M].[ITEM_CODE_ERP] = [d].[ItemCode] COLLATE SQL_Latin1_General_CP850_CI_AS
				WHERE
					[H].[WAVE_PICKING_ID] = [T].[WAVE_PICKING_ID]
					AND [H].[IS_POSTED_ERP] <> 1
			)
			GROUP BY
				[T].[MATERIAL_ID]
				,[T].[WAREHOUSE_SOURCE]
				,[T].[LICENSE_ID_SOURCE]
				,[T].[WAVE_PICKING_ID]
				,[T].[LOCATION_SPOT_TARGET]
			HAVING
				SUM([T].[QUANTITY_ASSIGNED]
					- [T].[QUANTITY_PENDING]) > 0) AS [DT]
	GROUP BY
		[DT].[Fuente]
		,[DT].[Ola]
		,[DT].[MATERIAL_ID]
		,[DT].[WAREHOUSE_SOURCE]
		,[DT].[LICENSE_ID_SOURCE]
		,[DT].[Pendiente De envio]);



