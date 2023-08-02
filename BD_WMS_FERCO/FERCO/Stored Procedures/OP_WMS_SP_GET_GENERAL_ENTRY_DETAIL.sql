
-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	11/24/2017 @ NEXUS-Team Sprint GTA 
-- Description:			Obtiene el detalle de recepcion general

/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[OP_WMS_SP_GET_GENERAL_ENTRY_DETAIL]
					@GENERAL_ENTRY_ID = 3
*/
-- =============================================
CREATE PROCEDURE FERCO.OP_WMS_SP_GET_GENERAL_ENTRY_DETAIL (@GENERAL_ENTRY_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [FERCO].[OP_WMS_FN_SPLIT_COLUMNS]([IL].[MATERIAL_ID], 2, '/') [ItemCode]
   ,SUM([IL].[ENTERED_QTY]) [Quantity]
   ,[W].[ERP_WAREHOUSE] [WarehouseCode]
  FROM [FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RH]
  INNER JOIN [FERCO].[OP_WMS_LICENSES] [L]
    ON [L].[CODIGO_POLIZA] = [RH].[DOC_ID_POLIZA]
  INNER JOIN [FERCO].[OP_WMS_INV_X_LICENSE] [IL]
    ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
  INNER JOIN [FERCO].[OP_WMS_WAREHOUSES] [W]
    ON [W].[WAREHOUSE_ID] = [L].[CURRENT_WAREHOUSE]
  WHERE [RH].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @GENERAL_ENTRY_ID
  GROUP BY [IL].[MATERIAL_ID]
          ,[W].[ERP_WAREHOUSE];
END;
