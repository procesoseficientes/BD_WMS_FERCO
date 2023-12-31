﻿










-- =============================================
-- Autor:					pablo.aguilar
-- Fecha de Creacion: 		25-Jun-18 @ Nexus-Team Sprint  
-- Description:			    

/*
-- Ejemplo de Ejecucion:

        SELECT * FROM [FERCO].[OP_WMS_VW_GET_PICKED_INVENTORY_WITH_PENDING_ERP_SENDING_WT] where material_id='ferco/015089'
        SELECT * FROM [FERCO].[OP_WMS_VW_GET_PICKED_INVENTORY_WITH_PENDING_ERP_SENDING]
*/
-- =============================================
CREATE VIEW [FERCO].[OP_WMS_VW_GET_PICKED_INVENTORY_WITH_PENDING_ERP_SENDING_WT]
AS
(


		SELECT  [DT].[WAREHOUSE_SOURCE]
		,[DT].[MATERIAL_ID]
		,SUM ([DT].[RESERVADO]) [RESERVADO] 
		--,dt.CODIGO_POLIZA_TARGET
				
		, [DT].[Tipo] FROM  (

			SELECT
			[T].[WAREHOUSE_SOURCE]
			,[T].[MATERIAL_ID]
			--,t.CODIGO_POLIZA_TARGET
			,SUM([T].[QUANTITY_ASSIGNED] - [T].[QUANTITY_PENDING]) [RESERVADO]
			,'Transferencia' [Tipo]
			FROM 
				[FERCO].[OP_WMS_TASK_LIST] [T]
				INNER JOIN [FERCO].[OP_WMS_MATERIALS] M ON [M].[MATERIAL_ID] = [T].[MATERIAL_ID]
				inner JOIN FERCO.OP_WMS_POLIZA_HEADER PH ON PH.CODIGO_POLIZA = T.CODIGO_POLIZA_TARGET
				INNER JOIN FERCO.OP_WMS_LICENSES L ON L.CODIGO_POLIZA = PH.CODIGO_POLIZA
				INNER JOIN FERCO.OP_WMS_INV_X_LICENSE IXL ON IXL.LICENSE_ID = L.LICENSE_ID AND IXL.MATERIAL_ID = T.MATERIAL_ID
			
				--LEFT JOIN FERCO.OP_WMS_COMPONENTS_BY_MASTER_PACK COM ON M.MATERIAL_ID = COM.COMPONENT_MATERIAL
				--LEFT JOIN [FERCO].[OP_WMS_PASS_DETAIL] PASS ON PASS.WAVE_PICKING_ID=T.WAVE_PICKING_ID and PASS.MATERIAL_ID=ISNULL(COM.MASTER_PACK_CODE,M.MATERIAL_ID )
			WHERE
				[T].[TASK_TYPE] = 'TAREA_PICKING'
				AND [T].[TASK_SUBTYPE] = 'DESPACHO_WT'
				--AND [T].[IS_COMPLETED] = 1
				AND ([T].[IS_PAUSED] <> 3)
				AND ([T].[CANCELED_DATETIME] IS NULL)
				--AND PASS.PASS_HEADER_ID IS NULL
				AND [T].[QUANTITY_ASSIGNED] - [T].[QUANTITY_PENDING] > 0
				AND IXL.QTY > 0
				AND [IXL].[STATUS] <> 'DISPATCH'

				AND [T].[WAVE_PICKING_ID] IN (
				SELECT
					[H].[WAVE_PICKING_ID]
				FROM
					[FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H]
					--INNER JOIN [SAPSERVER].SBOFERCO.[dbo].[OWTQ] R ON R.[DocEntry] = [H].[DOC_ENTRY] AND R.[DocStatus]= 'O'
					--INNER JOIN [SAPSERVER].SBOFERCO.[dbo].[WTQ1] d ON [R].[DocEntry] = d.[DocEntry] AND  [d].[LineStatus] ='O'
					--AND [M].[ITEM_CODE_ERP] =  D.[ItemCode] COLLATE SQL_Latin1_General_CP850_CI_AS
				WHERE
					[H].[WAVE_PICKING_ID] = [T].[WAVE_PICKING_ID]
					AND ISNULL([H].[IS_POSTED_ERP],0) <> 1 --AND [H].[WAVE_PICKING_ID] NOT IN ( 896, 3328) 
					)
			GROUP BY
				[T].[MATERIAL_ID]
				,[T].[WAREHOUSE_SOURCE]
							--,t.CODIGO_POLIZA_TARGET
			HAVING
				SUM([T].[QUANTITY_ASSIGNED] - [T].[QUANTITY_PENDING]) > 0
			) AS DT 
		GROUP BY [DT].[WAREHOUSE_SOURCE]
				,[DT].[MATERIAL_ID]
				,tipo
				--,dt.CODIGO_POLIZA_TARGET
				
	)
