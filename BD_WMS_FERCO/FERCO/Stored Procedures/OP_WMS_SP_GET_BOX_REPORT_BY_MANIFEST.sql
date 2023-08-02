﻿-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	17-Oct-17 @ Nexus Team Sprint eFERCO 
-- Description:			SP que obtiene las cajas con su contenido

-- Modificacion 11/22/2017 @ NEXUS-Team Sprint GTA
					-- rodrigo.gomez
					-- Se agrega numero de documento en ERP.

-- Modificacion 27-Nov-17 @ Nexus Team Sprint GTA
					-- alberto.ruiz
					-- Se agrega log

/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[OP_WMS_SP_GET_BOX_REPORT_BY_MANIFEST]
					@MANIFEST_HEADER_ID = 1114
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_GET_BOX_REPORT_BY_MANIFEST](
	@MANIFEST_HEADER_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @TASK TABLE (
		[WAVE_PICKING_ID] INT PRIMARY KEY
		,[DISTRIBUTION_CENTER] VARCHAR(50)
		,[PLATE_NUMBER] VARCHAR(50)
		,[PILOT_FULL_NAME] VARCHAR(250)
		,[MANIFEST_HEADER_ID] INT
	)
	--
	INSERT INTO @TASK
	SELECT DISTINCT 
		[MD].[WAVE_PICKING_ID]
		,[MH].[DISTRIBUTION_CENTER]
		,[V].[PLATE_NUMBER]
		,[P].[NAME] + ' ' + [P].[LAST_NAME]
		,[MD].[MANIFEST_HEADER_ID]
	FROM [FERCO].[OP_WMS_MANIFEST_DETAIL] [MD]
		INNER JOIN [FERCO].[OP_WMS_MANIFEST_HEADER] [MH] ON [MH].[MANIFEST_HEADER_ID] = [MD].[MANIFEST_HEADER_ID]
		INNER JOIN [FERCO].[OP_WMS_VEHICLE] [V] ON [V].[VEHICLE_CODE] = [MH].[VEHICLE]
		INNER JOIN [FERCO].[OP_WMS_PILOT] [P] ON [P].[PILOT_CODE] = [MH].[DRIVER]
	WHERE [MD].[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID
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
		,ISNULL([DH].[DELIVERY_NOTE_INVOICE],[DH].[ERP_REFERENCE_DOC_NUM]) [ERP_REFERENCE]
		,[T].[DISTRIBUTION_CENTER] 
		,[T].[PLATE_NUMBER]
		,[T].[PILOT_FULL_NAME]
		,[T].[MANIFEST_HEADER_ID]
	FROM [op_wms].[dbo].[OP_WMS_DISTRIBUTED_TASK_HISTORY] [DT]
	INNER JOIN [op_wms].[dbo].[OP_WMS_DEMAND_TO_PICK_HISTORY] [DP] ON ([DP].[ERP_DOCUMENT] = [DT].[ERP_DOC])
	INNER JOIN @TASK [T] ON (
 		[FERCO].[OP_WMS_FN_SPLIT_COLUMNS]([DT].[ERP_DOC],2,'-') = [T].[WAVE_PICKING_ID]
	)
	INNER JOIN [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH] ON [DH].[WAVE_PICKING_ID] = [T].[WAVE_PICKING_ID]
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
		,ISNULL([DH].[DELIVERY_NOTE_INVOICE],[DH].[ERP_REFERENCE_DOC_NUM]) [ERP_REFERENCE]
		,[T].[DISTRIBUTION_CENTER] 
		,[T].[PLATE_NUMBER]
		,[T].[PILOT_FULL_NAME]
		,[T].[MANIFEST_HEADER_ID]
	FROM [op_wms].[dbo].[OP_WMS_DISTRIBUTED_TASK] [DT]
	INNER JOIN [op_wms].[dbo].[OP_WMS_DEMAND_TO_PICK] [DP] ON ([DP].[ERP_DOCUMENT] = [DT].[ERP_DOC])
	INNER JOIN @TASK [T] ON (
		[FERCO].[OP_WMS_FN_SPLIT_COLUMNS]([DT].[ERP_DOC],2,'-') = [T].[WAVE_PICKING_ID]
	)
	INNER JOIN [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH] ON [DH].[WAVE_PICKING_ID] = [T].[WAVE_PICKING_ID]
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
				,'Consulta de Cajas por Manifiesto'  -- REPORT_NAME - varchar(250)
				,NULL  -- PARAMETER_LOGIN - varchar(50)
				,NULL  -- PARAMETER_WAREHOUSE - varchar(50)
				,NULL  -- PARAMETER_START_DATETIME - datetime
				,NULL  -- PARAMETER_END_DATETIME - datetime
				,'@MANIFEST_HEADER_ID: ' + CAST(@MANIFEST_HEADER_ID AS VARCHAR)  -- EXTRA_PARAMETER - varchar(max)
			)
END