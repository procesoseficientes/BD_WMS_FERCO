
-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	11/23/2017 @ NEXUS-Team Sprint GTA 
-- Description:			Obtiene el detalle de un picking general para enviar a ERP

/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[OP_WMS_SP_GET_GENERAL_EXIT_DETAIL]
					@GENERAL_EXIT_ID = 1
*/
-- =============================================
CREATE PROCEDURE FERCO.OP_WMS_SP_GET_GENERAL_EXIT_DETAIL (@GENERAL_EXIT_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [FERCO].[OP_WMS_FN_SPLIT_COLUMNS]([TL].[MATERIAL_ID], 2, '/') [ItemCode]
   ,[TL].[QUANTITY_ASSIGNED] - [TL].[QUANTITY_PENDING] [Quantity]
   ,[W].[ERP_WAREHOUSE] [WarehouseCode]
  FROM [FERCO].[OP_WMS_TASK_LIST] [TL]
  INNER JOIN [FERCO].[OP_WMS_WAREHOUSES] [W]
    ON [TL].[WAREHOUSE_SOURCE] = [W].[WAREHOUSE_ID]
  INNER JOIN [FERCO].[OP_WMS_PICKING_ERP_DOCUMENT] [PED]
    ON [PED].[WAVE_PICKING_ID] = [TL].[WAVE_PICKING_ID]
  WHERE [PED].[PICKING_ERP_DOCUMENT_ID] = @GENERAL_EXIT_ID;
END;
