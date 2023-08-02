-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/4/2018 @ GForce-Team Sprint Dinosaurio 
-- Description:			Obtiene todos los materiales de la ola de picking con sus unidades de medida

/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[OP_WMS_SP_GET_PICKING_MATERIALS_WITH_MEASUREMENT_UNIT]
					@WAVE_PICKING_ID = 10003
				--
				EXEC [FERCO].[OP_WMS_SP_GET_PICKING_MATERIALS_WITH_MEASUREMENT_UNIT]
					@WAVE_PICKING_ID = 10012
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_GET_PICKING_MATERIALS_WITH_MEASUREMENT_UNIT] (@WAVE_PICKING_ID INT)
AS
BEGIN
    SET NOCOUNT ON;
	--
    SELECT DISTINCT
        [TL].[MATERIAL_ID]
       ,'Unidad Base' [MEASUREMENT_UNIT]
       ,1 [QTY]
       ,[TL].[BARCODE_ID]
       ,[TL].[ALTERNATE_BARCODE]
    FROM
        [FERCO].[OP_WMS_TASK_LIST] [TL]
    WHERE
        [WAVE_PICKING_ID] = @WAVE_PICKING_ID
    UNION ALL
    SELECT DISTINCT
        [TL].[MATERIAL_ID]
       ,[UMM].[MEASUREMENT_UNIT]
       ,[UMM].[QTY]
       ,[UMM].[BARCODE]
       ,[UMM].[ALTERNATIVE_BARCODE]
    FROM
        [FERCO].[OP_WMS_TASK_LIST] [TL]
    INNER JOIN [FERCO].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UMM] ON [UMM].[MATERIAL_ID] = [TL].[MATERIAL_ID]
    WHERE
        [WAVE_PICKING_ID] = @WAVE_PICKING_ID
    ORDER BY
        [TL].[MATERIAL_ID]
       ,[QTY];
END;
