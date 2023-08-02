


-- =============================================
-- Autor:					Brandon Sicay
-- Fecha de Creacion: 		2022-01-20 
-- Description:			    Vista que trae el inventario disponible por bodega

/*
-- Ejemplo de Ejecucion:
		SELECT * FROM [FERCO].[OP_WMS_VIEW_PWBI_COMPLETED_TASK]
*/
-- =============================================

CREATE VIEW [FERCO].[OP_WMS_VIEW_PWBI_TASK_TIME]
AS


	SELECT [T].[WAVE_PICKING_ID] [Ola de Picking], 
			[h].[DOC_NUM] [Pedido], 
			[T].[CREATED_BY] [Creado por], 
			[T].[CREATED_BY_NAME] [Nombre Creado por],
			[T].[MATERIAL_ID] [Material],
			[M].[MATERIAL_NAME] [MATERIAL_NAME],
			[T].[QUANTITY_ASSIGNED] [Cantidad Asignada],
			[T].[ASSIGNED_TO] [Asignado A],
			[T].[ASSIGNED_TO_NAME] [Nombre Asignado A],
			FORMAT([T].[ASSIGNED_DATE], 'dd/MM/yyyy HH:mm:ss' ) [Fecha de asignación],
			FORMAT([T].[ACCEPTED_DATE], 'dd/MM/yyyy HH:mm:ss' ) [Fecha de aceptación Picking],
			FORMAT([T].[COMPLETED_DATE] , 'dd/MM/yyyy HH:mm:ss' ) [Fecha de completación Picking], 
			CONVERT(VARCHAR(50), DATEADD(SECOND,DATEDIFF(SECOND,[T].[ASSIGNED_DATE],[T].[ACCEPTED_DATE]),0),114) [Intervalo Creacion Aceptacion], 
			DATEDIFF(MINUTE, [T].[ASSIGNED_DATE],[T].[ACCEPTED_DATE]) [Intervalo Creacion Aceptacion(Minutos)],
			CONVERT(VARCHAR(50), DATEADD(SECOND,DATEDIFF(SECOND,ISNULL([T1].[COMPLETED_DATE],[T].[ACCEPTED_DATE]),[T].[COMPLETED_DATE]), 0), 114) [Tiempo Picking],
			DATEDIFF(MINUTE, ISNULL([T1].[COMPLETED_DATE],[T].[ACCEPTED_DATE]),[T].[COMPLETED_DATE]) [Tiempo Picking(Minutos)], 
			CONVERT(VARCHAR(50), DATEADD(SECOND,DATEDIFF(SECOND,[T].[ACCEPTED_DATE],[T].[WAVE_FINISH_DATE]),0), 114) [Tiempo Total Picking],
			DATEDIFF(MINUTE, [T].[ACCEPTED_DATE],[T].[WAVE_FINISH_DATE]) [Tiempo Total Picking(Minutos)], 
			CONVERT(VARCHAR(50), DATEADD(SECOND,DATEDIFF(SECOND, [T].[ASSIGNED_DATE],[T].[WAVE_FINISH_DATE]),0), 114) [Tiempo Total desde asignación], 
			DATEDIFF(MINUTE, [T].[ASSIGNED_DATE],[T].[WAVE_FINISH_DATE]) [Tiempo Total desde asignación(Minutos)],
			[T].[TaskOrder] [Orden Tarea],
			CASE 
			WHEN FORMAT([T].[COMPLETED_DATE], 'HH:mm') BETWEEN '05:00' AND '13:30' THEN 'AM'
			WHEN FORMAT([T].[COMPLETED_DATE], 'HH:mm') BETWEEN '13:31' AND '20:00' THEN 'PM'
			WHEN FORMAT([T].[COMPLETED_DATE], 'HH:mm') BETWEEN '20:01' AND '23:59' THEN 'NOCHE'
			WHEN FORMAT([T].[COMPLETED_DATE], 'HH:mm') BETWEEN '00:00' AND '04:00' THEN 'NOCHE'
			END AS Turno,
			[T].[TIPO_TAREA][Tipo de Tarea], 
			[T].[WAREHOUSE_ID] [Bodega], 
			'GT' [PAIS]
			FROM [FERCO].[OP_WMS_VIEW_PWBI_TASK] [T]  
			LEFT JOIN [FERCO].[OP_WMS_VIEW_PWBI_TASK] [T1] ON [T].[WAVE_PICKING_ID] = [T1].[WAVE_PICKING_ID] AND [T1].[TaskOrder] + 1 = [T].[TaskOrder]  
			LEFT JOIN [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [h] ON [h].[WAVE_PICKING_ID] = [T].[WAVE_PICKING_ID] AND [h].[IS_CONSOLIDATED] = 0   
			INNER JOIN [FERCO].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [T].[MATERIAL_ID]
			--ORDER BY [T].[WAVE_PICKING_ID], [T].[TaskOrder];


