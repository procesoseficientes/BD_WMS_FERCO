





-- =============================================
-- Autor:					Gildardo.Alvarado
-- Fecha de Creacion: 		03-Febrero-2021 @ProcesosEficientes
-- Description:				Trae el inventario reservado de WMS 

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [FERCO].[OP_WMS_VW_GET_PICKED_INVENTORY_WITH_PENDING_SENDING_WT]
*/
-- =============================================
CREATE VIEW [FERCO].[OP_WMS_VW_GET_PICKED_INVENTORY_WITH_PENDING_SENDING_WT]
AS
(
	SELECT  
		[DT].[WAREHOUSE_SOURCE]
		,[DT].[MATERIAL_ID]
		,SUM([DT].[RESERVADO]) [RESERVADO] 
		, [DT].[Tipo]
	FROM  (

			SELECT
			[T].[WAREHOUSE_SOURCE]
			,[T].[MATERIAL_ID]
			,SUM([T].[QUANTITY_ASSIGNED] - [T].[QUANTITY_PENDING]) [RESERVADO]
			,'Transferencia' [Tipo]
			FROM
				[FERCO].[OP_WMS_TASK_LIST] [T]
				INNER JOIN [FERCO].[OP_WMS_MATERIALS] M ON [M].[MATERIAL_ID] = [T].[MATERIAL_ID]
				INNER JOIN [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H] ON H.WAVE_PICKING_ID = T.WAVE_PICKING_ID
				LEFT JOIN [FERCO].[OP_WMS_PASS_DETAIL] [PD] ON ([T].[WAVE_PICKING_ID] = [PD].[WAVE_PICKING_ID] AND T.MATERIAL_ID=PD.MATERIAL_ID)
			WHERE
				[T].[TASK_TYPE] = 'TAREA_PICKING'
				AND [T].[TASK_SUBTYPE] = 'DESPACHO_WT'
				AND [T].[IS_COMPLETED] = 1
				AND ([T].[IS_PAUSED] <> 3)
				AND ([T].[CANCELED_DATETIME] IS NULL)
				AND PD.PASS_HEADER_ID IS NULL

			GROUP BY
				[T].[MATERIAL_ID]
				,[T].[WAREHOUSE_SOURCE]
			HAVING
				SUM([T].[QUANTITY_ASSIGNED] - [T].[QUANTITY_PENDING]) > 0
			) AS DT 
		GROUP BY [DT].[WAREHOUSE_SOURCE]
				,[DT].[MATERIAL_ID]
				,tipo
	)
