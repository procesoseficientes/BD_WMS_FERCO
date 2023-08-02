-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	27-Jun-18 @ Nexus Team Sprint  
-- Description:			SP que actualiza 

/*
-- Ejemplo de Ejecucion:
				[FERCO].[OP_WMS_SP_GET_SERIAL_NUMBER_X_MATERIAL_INFO]
					@
				-- 
				SELECT * FROM 
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_GET_SERIAL_NUMBER_X_MATERIAL_INFO](
	   @BARCODE_ID VARCHAR(100), @LOGIN VARCHAR(25) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	    SELECT [SN].[CORRELATIVE], [SN].[LICENSE_ID], [SN].[MATERIAL_ID], [SN].[SERIAL], [SN].[BATCH], [SN].[DATE_EXPIRATION] 
        FROM [FERCO].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [SN] 
         INNER JOIN ferco.[OP_WMS_MATERIALS] [M] ON [SN].[MATERIAL_ID] = [M].[MATERIAL_ID] 
        WHERE [M].[BARCODE_ID] = @BARCODE_ID OR [M].[ALTERNATE_BARCODE] = @BARCODE_ID
END

