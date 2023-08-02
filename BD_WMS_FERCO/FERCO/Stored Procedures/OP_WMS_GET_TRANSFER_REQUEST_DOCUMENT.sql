﻿
-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	8/31/2017 @ NEXUS-Team Sprint CommandAndConquer 
-- Description:			Obtiene el encabezado para una solicitud de traslado para enviar a ERP

/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[OP_WMS_GET_TRANSFER_REQUEST_DOCUMENT]
					@DOCUMENT_ID = 83

SELECT * FROM [FERCO].[OP_WMS_TRANSFER_REQUEST_HEADER]
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_GET_TRANSFER_REQUEST_DOCUMENT] (@DOCUMENT_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @TRANSFER_REQUEST_ID INT
  --
  SELECT
    @TRANSFER_REQUEST_ID = [MH].[TRANSFER_REQUEST_ID]
  FROM [FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH]
  INNER JOIN [FERCO].[OP_WMS_MANIFEST_HEADER] [MH]
    ON [MH].[MANIFEST_HEADER_ID] = [RDH].[DOC_NUM]
  WHERE [ERP_RECEPTION_DOCUMENT_HEADER_ID] = @DOCUMENT_ID
  --
  SELECT
    [TRH].[TRANSFER_REQUEST_ID]
   ,[TRH].[REQUEST_TYPE]
   ,[W1].[ERP_WAREHOUSE] [WAREHOUSE_FROM]
   ,[W2].[ERP_WAREHOUSE] [WAREHOUSE_TO]
   ,[TRH].[REQUEST_DATE]
   ,[TRH].[DELIVERY_DATE]
   ,[TRH].[COMMENT]
   ,[TRH].[STATUS]
   ,[TRH].[CREATED_BY]
   ,[TRH].[LAST_UPDATE]
   ,[TRH].[LAST_UPDATE_BY]
   ,[TRH].[OWNER]
   ,[TRH].[DOC_ENTRY]
   ,[VTRH].[COMMENTS]
  FROM [FERCO].[OP_WMS_TRANSFER_REQUEST_HEADER] [TRH]
  INNER JOIN [FERCO].[OP_WMS_WAREHOUSES] [W1]
    ON [W1].[WAREHOUSE_ID] = [TRH].[WAREHOUSE_FROM]
  INNER JOIN [FERCO].[OP_WMS_WAREHOUSES] [W2]
    ON [W2].[WAREHOUSE_ID] = [TRH].[WAREHOUSE_TO]
  LEFT JOIN [SWIFT_INTERFACES_SV].[ferco].[ERP_VW_TRANSFER_REQUEST_HEADER] [VTRH]
    ON (
      [TRH].[DOC_NUM] = [VTRH].[DOC_NUM]
      )
  WHERE [TRANSFER_REQUEST_ID] = @TRANSFER_REQUEST_ID
END
