


-- =============================================
-- Autor:					Brandon Sicay
-- Fecha de Creacion: 		2022-01-20 
-- Description:			    Vista que trae el inventario disponible por bodega

/*
-- Ejemplo de Ejecucion:
		SELECT * FROM [FERCO].[OP_WMS_VIEW_PWBI_COMPLETED_TASK]
*/
-- =============================================

CREATE VIEW [FERCO].[OP_WMS_VIEW_PWBI_COMPLETED_TASK]
AS

SELECT [WAVE_PICKING_ID], 
			MAX ([COMPLETED_DATE]) [COMPLETED_DATE] 
			FROM [FERCO].[OP_WMS_TASK_LIST]     
			GROUP BY [WAVE_PICKING_ID] HAVING MIN( [IS_COMPLETED] ) > 0       



