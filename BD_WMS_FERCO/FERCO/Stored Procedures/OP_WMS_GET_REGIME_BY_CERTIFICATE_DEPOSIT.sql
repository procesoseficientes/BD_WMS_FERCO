-- =============================================
-- Autor:                rudi.garcia
-- Fecha de Creacion:    19-Oct-2018 @ A-TEAM Sprint G-Force@Kudo
-- Description:          SP que obtiene la poliza de del certificado de deposito

/*
-- Ejemplo de Ejecucion:
                EXEC [FERCO].OP_WMS_GET_REGIME_BY_CERTIFICATE_DEPOSIT
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_GET_REGIME_BY_CERTIFICATE_DEPOSIT] (@CERTIFICATE_DEPOSIT_ID_HEADER INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT TOP 1
    [PH].[CODIGO_POLIZA]
  FROM [FERCO].[OP_WMS_CERTIFICATE_DEPOSIT_HEADER] [CDH]
  INNER JOIN [FERCO].[OP_WMS_CERTIFICATE_DEPOSIT_DETAIL] [CDD]
    ON ([CDH].[CERTIFICATE_DEPOSIT_ID_HEADER] = [CDD].[CERTIFICATE_DEPOSIT_ID_HEADER])
  INNER JOIN [FERCO].[OP_WMS_POLIZA_HEADER] [PH]
    ON ([CDD].[DOC_ID] = [PH].[DOC_ID])
  WHERE [CDH].[CERTIFICATE_DEPOSIT_ID_HEADER] = @CERTIFICATE_DEPOSIT_ID_HEADER
  AND [PH].[WAREHOUSE_REGIMEN] = 'FISCAL'

END;