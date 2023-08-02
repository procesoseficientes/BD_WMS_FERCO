﻿-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	20191114 GForce@Lima
-- Description:	        sp que devuelve el inventario por ubicacion e indica si el inventario esta disponible o reservado

-- Modificacion			6-Dic-2019 @ G-Force Team Sprint Lima
-- autor:				jonathan.salvador
-- Historia/Bug:		34645: No se muestra el inventario que tiene asignado un PROJECT_ID
-- Descripcion:			Se quita validacion para obtener inventario con PROJECT_ID = null, se agrega columna QTY_RESERVED_BY_PROJECT
/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[[OP_WMS_SP_GET_INVENTORY_BY_LICENSE_SUPER]]
					@MATERIAL_ID = 'viscosa/VCA1030',@LOGIN_ID = 'MARVIN'
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_GET_INVENTORY_BY_LICENSE_SUPER] (
		@LICENSE_ID NUMERIC(18, 0)
		,@LOGIN_ID VARCHAR(100)
	)
AS
BEGIN
	SET NOCOUNT ON;
	--

	SELECT
		[WAREHOUSE_ID]
	INTO
		[#WAREHOUSES_BY_USER]
	FROM
		[FERCO].[OP_WMS_WAREHOUSE_BY_USER]
	WHERE
		[LOGIN_ID] = @LOGIN_ID;

	SELECT
		[S].[LOCATION_SPOT] [LOCATION]
		,[IL].[MATERIAL_ID]
		,[IL].[MATERIAL_NAME]
		,[IL].[QTY] [TOTAL_LOCATION]
		,[L].[LICENSE_ID]
		,SUM([IL].[QTY] - ISNULL([CIL].[COMMITED_QTY], 0) 
			- ISNULL([IRP].[QTY_RESERVED], 0)
			) [QTY_AVAILABLE]
		,ISNULL([CIL].[COMMITED_QTY], 0) [QTY_RESERVED]
		,ISNULL([IRP].[QTY_RESERVED], 0)  [QTY_RESERVED_BY_PROJECT]
		,[IL].[BATCH]
		,[IL].[DATE_EXPIRATION]
		,[TC].[TONE]
		,[TC].[CALIBER]
		,[M].[SERIAL_NUMBER_REQUESTS]
		,[M].[BATCH_REQUESTED]
		,[M].[HANDLE_TONE]
		,[M].[HANDLE_CALIBER]
		,[SML].[STATUS_NAME]
		,[IL].[LOCKED_BY_INTERFACES]
		,[IL].[LOCKED_BY_INTERFACES] [LOCATION_LOCKED]
		,[L].[REGIMEN]
		,[L].[CODIGO_POLIZA]
		,[L].[CLIENT_OWNER]
		,[P].[OPPORTUNITY_CODE] [PROJECT_CODE]
		,[P].[OPPORTUNITY_NAME] [PROJECT_NAME]
	FROM
		[FERCO].[OP_WMS_LICENSES] [L]
	INNER JOIN [#WAREHOUSES_BY_USER] [WU] ON [WU].[WAREHOUSE_ID] = [L].[CURRENT_WAREHOUSE]
	INNER JOIN [FERCO].[OP_WMS_SHELF_SPOTS] [S] ON [L].[CURRENT_LOCATION] = [S].[LOCATION_SPOT]
	INNER JOIN [FERCO].[OP_WMS_INV_X_LICENSE] [IL] ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
	INNER JOIN [FERCO].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SML] ON [SML].[STATUS_ID] = [IL].[STATUS_ID]
	INNER JOIN [FERCO].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [IL].[MATERIAL_ID]
	LEFT JOIN [FERCO].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TC] ON [TC].[TONE_AND_CALIBER_ID] = [IL].[TONE_AND_CALIBER_ID]
	LEFT JOIN [FERCO].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT] [IRP] ON (
											[IL].[PK_LINE] = [IRP].[PK_LINE]
											AND [IL].[PROJECT_ID] = [IRP].[PROJECT_ID]
											)
	LEFT JOIN [FERCO].[OP_WMS_PROJECT] [P] ON ([IRP].[PROJECT_ID] = [P].[ID])
	LEFT JOIN [FERCO].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [CIL] ON (
											[IL].[LICENSE_ID] = [CIL].[LICENCE_ID]
											AND [IL].[MATERIAL_ID] = [CIL].[MATERIAL_ID]
											)
	WHERE
		[IL].[LICENSE_ID] = @LICENSE_ID
		AND [IL].[QTY] > 0
	GROUP BY
		[S].[LOCATION_SPOT]
		,[IL].[MATERIAL_ID]
		,[IL].[MATERIAL_NAME]
		,[L].[LICENSE_ID]
		,[IL].[QTY]
		,ISNULL([CIL].[COMMITED_QTY], 0)
		,[IL].[BATCH]
		,[IL].[DATE_EXPIRATION]
		,[TC].[TONE]
		,[TC].[CALIBER]
		,[M].[SERIAL_NUMBER_REQUESTS]
		,[M].[BATCH_REQUESTED]
		,[M].[HANDLE_TONE]
		,[M].[HANDLE_CALIBER]
		,[SML].[STATUS_NAME]
		,[L].[CODIGO_POLIZA]
		,[L].[CLIENT_OWNER]
		,[IL].[LOCKED_BY_INTERFACES]
		,[L].[REGIMEN]
		,[L].[CODIGO_POLIZA]
		,[L].[CLIENT_OWNER]
		,[P].[OPPORTUNITY_CODE]
		,[P].[OPPORTUNITY_NAME]
		,[IRP].[QTY_RESERVED]
		,[IRP].[QTY_DISPATCHED]
	ORDER BY
		[IL].[QTY];


END;