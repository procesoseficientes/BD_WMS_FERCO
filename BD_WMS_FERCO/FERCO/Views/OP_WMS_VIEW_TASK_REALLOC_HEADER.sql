﻿-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-05-04 @ Team ERGON - Sprint Ganondorf
-- Description:	 Se crea vista de tarea de reubicación header para el administrador de tareas.


-- Modificación: rudi.garcia
-- Fecha de Creacion: 	02-Jan-2019 Team G-Force - Sprint Perezoso
-- Description:	 Se agrego el campo de quien creo la tarea.

-- Autor:				rudi.garcia
-- Fecha de Creacion: 	26-Jul-2019 @ G-Force-Team Sprint Dublin
-- Description:			se agrega manejo de proyectos

/*
-- Ejemplo de Ejecucion:
			SELECT * FROM [FERCO].OP_WMS_VIEW_TASK_REALLOC_HEADER 
*/
-- =============================================
CREATE VIEW [FERCO].[OP_WMS_VIEW_TASK_REALLOC_HEADER]
AS
SELECT
	MAX([A].[SERIAL_NUMBER]) AS [SERIAL_NUMBER]
	,[A].[WAVE_PICKING_ID] AS [WAVE_PICKING_ID]
	,MAX([A].[CLIENT_NAME]) AS [CLIENT_NAME]
	,MAX([A].[TASK_TYPE]) AS [TASK_TYPE]
	,MAX([A].[TASK_SUBTYPE]) AS [TASK_SUBTYPE]
	,MAX([A].[TASK_COMMENTS]) AS [TASK_COMMENTS]
	,MAX([A].[REGIMEN]) AS [REGIMEN]
	,MAX([A].[IS_PAUSED]) AS [IS_PAUSED]
	,MAX([A].[ASSIGNED_DATE]) AS [ASSIGNED_DATE]
	,MAX([A].[ACCEPTED_DATE]) AS [ACCEPTED_DATE]
	,MAX([A].[COMPLETED_DATE]) AS [PICKING_FINISHED_DATE]
	,MAX([A].[IS_CANCELED]) AS [IS_CANCELED]
	,MAX([A].[QUANTITY_PENDING]) AS [QUANTITY_PENDING]
	,MAX([A].[QUANTITY_ASSIGNED]) AS [QUANTITY_ASSIGNED]
	,CAST(NULL AS VARCHAR) AS [NUMERO_ORDEN_SOURCE]
	,CAST(NULL AS VARCHAR) AS [NUMERO_ORDEN_TARGET]
	,NULL AS [CODIGO_POLIZA_SOURCE]
	,MAX([A].[CODIGO_POLIZA_TARGET]) AS [CODIGO_POLIZA_TARGET]
	,CASE MIN([A].[IS_COMPLETED])
		WHEN 0 THEN CASE MAX([A].[IS_ACCEPTED])
						WHEN 0 THEN 'INCOMPLETA'
						WHEN 1 THEN 'ACEPTADA'
					END
		ELSE 'COMPLETA'
		END AS [IS_COMPLETED]
	,MAX([A].[IS_DISCRETIONARY]) AS [IS_DISCRETIONARY]
	,CASE MAX([A].[IS_DISCRETIONARY])
		WHEN 1 THEN 'Discrecional'
		ELSE 'Dirigido'
		END AS [TYPE_PICKING]
	,MAX([A].[IS_ACCEPTED]) AS [IS_ACCEPTED]
	,CASE MAX([A].[IS_FROM_ERP])
		WHEN 1 THEN 'Si'
		WHEN 0 THEN 'No'
		ELSE 'No'
		END AS [IS_FROM_ERP]
	,CASE MAX([A].[IS_FROM_SONDA])
		WHEN 1 THEN 'Si'
		WHEN 0 THEN 'No'
		ELSE 'No'
		END AS [IS_FROM_SONDA]
	,CASE	WHEN MAX([A].[LOCATION_SPOT_TARGET]) <> MIN([A].[TASK_ASSIGNEDTO])
			THEN 'Multiple'
			WHEN MAX([A].[LOCATION_SPOT_TARGET]) = MIN([A].[LOCATION_SPOT_TARGET])
			THEN MAX([A].[LOCATION_SPOT_TARGET])
		END AS [LOCATION_SPOT_TARGET]
	,MAX([A].[WAREHOUSE_SOURCE]) AS [WAREHOUSE_SOURCE]
	,CASE	WHEN MAX([A].[TASK_ASSIGNEDTO]) = ''
					OR MIN([A].[TASK_ASSIGNEDTO]) = ''
			THEN 'Sin Asignación'
			WHEN MAX([A].[TASK_ASSIGNEDTO]) <> MIN([A].[TASK_ASSIGNEDTO])
			THEN 'Multiple'
			WHEN MAX([A].[TASK_ASSIGNEDTO]) = MIN([A].[TASK_ASSIGNEDTO])
			THEN MAX([A].[TASK_ASSIGNEDTO])
		END AS [TASK_ASSIGNEDTO]
	,MAX([A].[TASK_OWNER]) AS [CREATE_BY]
	,MAX([A].[ORDER_NUMBER]) AS [ORDER_NUMBER]
	,MAX([A].[PROJECT_ID]) AS [PROJECT_ID]
	,MAX([A].[PROJECT_CODE]) AS [PROJECT_CODE]
	,MAX([A].[PROJECT_NAME]) AS [PROJECT_NAME]
	,MAX([A].[PROJECT_SHORT_NAME]) AS [PROJECT_SHORT_NAME]
FROM
	[FERCO].[OP_WMS_TASK_LIST] [A]
WHERE
	[A].[TASK_TYPE] = 'TAREA_REUBICACION'
GROUP BY
	[A].[WAVE_PICKING_ID];