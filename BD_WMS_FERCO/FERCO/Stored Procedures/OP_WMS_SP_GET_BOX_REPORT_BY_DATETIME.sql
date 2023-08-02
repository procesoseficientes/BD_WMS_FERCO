﻿-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	17-Oct-17 @ Nexus Team Sprint eFERCO 
-- Description:			SP que obtiene las cajas con su contenido

-- Modificacion 27-Nov-17 @ Nexus Team Sprint GTA
					-- alberto.ruiz
					-- Se agrega log

/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[OP_WMS_SP_GET_BOX_REPORT_BY_DATETIME]
					@START_DATETIME = '2017-10-17 00:41:25.520'
					,@END_DATETIME = '2017-10-18 18:41:25.520'
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_GET_BOX_REPORT_BY_DATETIME](
	@START_DATETIME DATETIME
	,@END_DATETIME DATETIME
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT DISTINCT
		[DT].[ERP_DOC] [WAVE_PICKING_ID]
		,[DT].[BOX_ID]
		,[DT].[MATERIAL_ID]
		,[DT].[MATERIAL_NAME]
		,[DT].[QUANTITY]
		,[DP].[ERP_DOC_DATE] [PICKED_DATETIME]
		,[DT].[STATUS]
		,CASE [DT].[STATUS]
			WHEN 'PICKED' THEN 'Despachado'
			ELSE 'Pendiente'
		END [STATUS_DESCRIPTION]
		,[DT].[LOGIN_ID]
		,[DT].[LOCATION_SPOT]
		,[DT].[BOX_ASSIGNED]
		,CASE
			WHEN [DT].[BOX_ASSIGNED] = 1 THEN 'Asignada'
			ELSE 'Pendiente'
		END [BOX_ASSIGNED_DESCRIPTION]
		,[DT].[BOX_NUMBER]
		,[DT].[TOTAL_BOXES]
		,[DP].[GATE]
		,[DP].[CLIENT_ID]
		,[DP].[CLIENT_NAME]
		,[DP].[CLIENT_ROUTE]
	FROM [op_wms].[dbo].[OP_WMS_DISTRIBUTED_TASK_HISTORY] [DT]
	INNER JOIN [op_wms].[dbo].[OP_WMS_DEMAND_TO_PICK_HISTORY] [DP] ON ([DP].[ERP_DOCUMENT] = [DT].[ERP_DOC])
	WHERE [DP].[ERP_DOC_DATE] BETWEEN @START_DATETIME AND @END_DATETIME
	UNION ALL
	SELECT DISTINCT
		[DT].[ERP_DOC] [WAVE_PICKING_ID]
		,[DT].[BOX_ID]
		,[DT].[MATERIAL_ID]
		,[DT].[MATERIAL_NAME]
		,[DT].[QUANTITY]
		,[DP].[ERP_DOC_DATE] [PICKED_DATETIME]
		,[DT].[STATUS]
		,CASE [DT].[STATUS]
			WHEN 'PICKED' THEN 'Despachado'
			ELSE 'Pendiente'
		END [STATUS_DESCRIPTION]
		,[DT].[LOGIN_ID]
		,[DT].[LOCATION_SPOT]
		,[DT].[BOX_ASSIGNED]
		,CASE
			WHEN [DT].[BOX_ASSIGNED] = 1 THEN 'Asignada'
			ELSE 'Pendiente'
		END [BOX_ASSIGNED_DESCRIPTION]
		,[DT].[BOX_NUMBER]
		,[DT].[TOTAL_BOXES]
		,[DP].[GATE]
		,[DP].[CLIENT_ID]
		,[DP].[CLIENT_NAME]
		,[DP].[CLIENT_ROUTE]
	FROM [op_wms].[dbo].[OP_WMS_DISTRIBUTED_TASK] [DT]
	INNER JOIN [op_wms].[dbo].[OP_WMS_DEMAND_TO_PICK] [DP] ON ([DP].[ERP_DOCUMENT] = [DT].[ERP_DOC])
	WHERE [DP].[ERP_DOC_DATE] BETWEEN @START_DATETIME AND @END_DATETIME
	ORDER BY [DT].[ERP_DOC]
	--
	INSERT INTO [FERCO].[OP_WMS_LOG_REPORT]
			(
				[LOG_DATETIME]
				,[REPORT_NAME]
				,[PARAMETER_LOGIN]
				,[PARAMETER_WAREHOUSE]
				,[PARAMETER_START_DATETIME]
				,[PARAMETER_END_DATETIME]
				,[EXTRA_PARAMETER]
			)
	VALUES
			(
				GETDATE()  -- LOG_DATETIME - datetime
				,'Consulta de Linea de Picking'  -- REPORT_NAME - varchar(250)
				,NULL  -- PARAMETER_LOGIN - varchar(50)
				,NULL  -- PARAMETER_WAREHOUSE - varchar(50)
				,@START_DATETIME  -- PARAMETER_START_DATETIME - datetime
				,@END_DATETIME  -- PARAMETER_END_DATETIME - datetime
				,NULL  -- EXTRA_PARAMETER - varchar(max)
			)
END