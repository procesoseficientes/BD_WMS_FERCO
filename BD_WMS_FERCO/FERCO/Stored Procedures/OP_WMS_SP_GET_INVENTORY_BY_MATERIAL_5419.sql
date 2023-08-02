-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	3/20/2018 @ GTEAM-Team Sprint Anemona 
-- Description:			obtiene el inventario por material id completo

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20181121 GForce@Ornitorrinco
-- Description:	        Se agrega el estado del material por licencia en la consulta

/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[OP_WMS_SP_GET_INVENTORY_BY_MATERIAL]
					@MATERIAL_ID = 'viscosa/VCA1030'
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_GET_INVENTORY_BY_MATERIAL_5419] (
		@MATERIAL_ID VARCHAR(25)
	)
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
		,[SML].[STATUS_NAME]
	FROM
		[FERCO].[OP_WMS_LICENSES] [L]
	INNER JOIN [FERCO].[OP_WMS_INV_X_LICENSE] [IL] ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
	INNER JOIN [FERCO].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SML] ON  [SML].[STATUS_ID] = [IL].[STATUS_ID]
	INNER JOIN [FERCO].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [IL].[MATERIAL_ID]
	LEFT JOIN [FERCO].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TC] ON [TC].[TONE_AND_CALIBER_ID] = [IL].[TONE_AND_CALIBER_ID]
	WHERE
		[IL].[MATERIAL_ID] = @MATERIAL_ID
		AND [IL].[QTY] > 0;


END;

