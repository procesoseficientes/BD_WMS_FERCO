﻿-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	3/20/2018 @ GTEAM-Team Sprint Anemona 
-- Description:			obtiene el inventario por licencia completo

-- Autor:	        marvin.solares
-- Fecha de Creacion: 	20181810 GForce@Langosta
-- Description:     Se agrega wave_picking_id a la consulta

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20181121 GForce@Ornitorrinco
-- Description:	        Se agrega el estado del material por licencia en la consulta

/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[OP_WMS_SP_GET_INVENTORY_BY_LICENSE]
					@LICENSE_ID = 500846
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_GET_INVENTORY_BY_LICENSE_5419] (@LICENSE_ID INT)
AS
BEGIN
	SET NOCOUNT ON;
	--
	
	SELECT
		[L].[LICENSE_ID]
		,[L].[CURRENT_LOCATION]
		,[L].[CODIGO_POLIZA]
		,[L].[CLIENT_OWNER]
		,[IL].[MATERIAL_ID]
		,[IL].[QTY]
		,[IL].[VIN]
		,[IL].[BATCH]
		,[IL].[DATE_EXPIRATION]
		,[TC].[TONE]
		,[TC].[CALIBER]
		,[M].[SERIAL_NUMBER_REQUESTS]
		,[L].[PICKING_DEMAND_HEADER_ID]
		,[PDH].[DOC_NUM]
		,ISNULL([L].[WAVE_PICKING_ID], 0) [WAVE_PICKING_ID]
		,[SML].[STATUS_NAME]
	FROM
		[FERCO].[OP_WMS_LICENSES] [L]
	INNER JOIN [FERCO].[OP_WMS_INV_X_LICENSE] [IL] ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
	INNER JOIN [FERCO].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [IL].[MATERIAL_ID]
	LEFT JOIN [FERCO].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SML] ON [SML].[STATUS_ID] = [IL].[STATUS_ID]
	LEFT JOIN [FERCO].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TC] ON [TC].[TONE_AND_CALIBER_ID] = [IL].[TONE_AND_CALIBER_ID]
	LEFT JOIN [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH] ON [PDH].[PICKING_DEMAND_HEADER_ID] = [L].[PICKING_DEMAND_HEADER_ID]
	WHERE
		[L].[LICENSE_ID] = @LICENSE_ID
		AND [IL].[QTY] > 0;


END;

