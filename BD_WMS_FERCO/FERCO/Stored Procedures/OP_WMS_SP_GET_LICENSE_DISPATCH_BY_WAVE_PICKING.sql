-- =============================================
-- Autor:	        rudi.garcia
-- Fecha de Creacion: 	21-Aug-2018 G-Force@Humano
-- Description:	        Sp que obtiene las licencias generadas del despacho.

-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_GET_LICENSE_DISPATCH_BY_WAVE_PICKING] (
		@WAVE_PICKING_ID INT
		,@LOGIN VARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	SELECT DISTINCT
		[TL].[LOCATION_SPOT_TARGET]
		,[L].[LICENSE_ID]
		,[L].[CURRENT_LOCATION]
	FROM
		[FERCO].[OP_WMS_TASK_LIST] [TL]
	INNER JOIN [FERCO].[OP_WMS_LICENSES] [L] ON ([TL].[WAVE_PICKING_ID] = [L].[WAVE_PICKING_ID])
											AND [TL].[TASK_ASSIGNEDTO] = [L].[CURRENT_LOCATION]
	INNER JOIN [FERCO].[OP_WMS_INV_X_LICENSE] [IL] ON ([L].[LICENSE_ID] = [IL].[LICENSE_ID])
	WHERE
		[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
		AND [L].[CURRENT_LOCATION] = @LOGIN;

END;