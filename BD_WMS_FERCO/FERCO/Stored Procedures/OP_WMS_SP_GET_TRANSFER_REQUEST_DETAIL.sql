
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	16-Aug-17 @ Nexus Team Sprint Banjo-Kazooie 
-- Description:			SP que obtene el detalle de una solicitud de transferencia
/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[OP_WMS_SP_GET_TRANSFER_REQUEST_DETAIL]
					@TRANSFER_REQUEST_ID = 36
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_GET_TRANSFER_REQUEST_DETAIL] (@TRANSFER_REQUEST_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [D].[TRANSFER_REQUEST_ID]
   ,[D].[MATERIAL_ID]
   ,[D].[MATERIAL_NAME]
   ,[D].[IS_MASTERPACK]
   ,CASE
      WHEN [D].[IS_MASTERPACK] = 0 THEN 'NO'
      ELSE 'SI'
    END [IS_MASTERPACK_DESCRIPTION]
   ,[D].[QTY]
   ,[D].[STATUS]
   ,CASE [D].[STATUS]
      WHEN 'OPEN' THEN 'ABIERTA'
      WHEN 'CLOSE' THEN 'CERRADA'
      ELSE [D].[STATUS]
    END [STATUS_DESCRIPTION]
  FROM [FERCO].[OP_WMS_TRANSFER_REQUEST_DETAIL] [D] WITH (NOLOCK)
  WHERE [D].[TRANSFER_REQUEST_ID] = @TRANSFER_REQUEST_ID
END
