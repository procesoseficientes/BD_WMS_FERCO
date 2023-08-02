-- =============================================
-- Autor:	        marvin.solares
-- Fecha de Creacion: 	20181010 GForce@Langosta
-- Description:	        Sp que obtiene las licencias generadas del despacho para reabastecimientos.

-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_GET_TARGET_LOCATION_BY_LICENSE_DISPATCH] (
		@WAVE_PICKING_ID INT
		,@LOGIN VARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	SELECT DISTINCT
		[L].[TARGET_LOCATION_REPLENISHMENT] [LOCATION_SPOT_TARGET]
		,[L].[LICENSE_ID]
		,[L].[CURRENT_LOCATION]
	FROM
		[FERCO].[OP_WMS_LICENSES] [L]
	INNER JOIN [FERCO].[OP_WMS_INV_X_LICENSE] [IL] ON [L].[LICENSE_ID] = [IL].[LICENSE_ID]
	INNER JOIN [FERCO].[OP_WMS_TASK_LIST] [TL] ON [L].[WAVE_PICKING_ID] = [TL].[WAVE_PICKING_ID]
	WHERE
		[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
		AND [L].[CURRENT_LOCATION] = @LOGIN;
		

END;