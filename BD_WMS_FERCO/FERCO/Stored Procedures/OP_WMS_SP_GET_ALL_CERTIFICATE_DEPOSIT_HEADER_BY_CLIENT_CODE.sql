﻿
-- =============================================
-- Author:         diego.as
-- Create date:    15-02-2016
-- Description:    Trae los ENCABEZADOS DE CERTIFICADO DE DEPOSITO de la Tabla 
--				   [FERCO].[OP_WMS_CERTIFICATE_DEPOSIT_HEADER] 
--					DE UN CLIENTE EN ESPECIFICO.
/*
Ejemplo de Ejecucion:
				--
				EXEC [FERCO].OP_WMS_SP_GET_ALL_CERTIFICATE_DEPOSIT_HEADER_BY_CLIENT_CODE
					@CLIENT_CODE =  '123'
				
				--	
*/
-- =============================================

CREATE PROCEDURE FERCO.OP_WMS_SP_GET_ALL_CERTIFICATE_DEPOSIT_HEADER_BY_CLIENT_CODE (@CLIENT_CODE VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    [CDH].[CERTIFICATE_DEPOSIT_ID_HEADER]
   ,[CDH].[VALID_FROM]
   ,[CDH].[VALID_TO]
   ,[CDH].[LAST_UPDATED]
   ,[CDH].[LAST_UPDATED_BY]
   ,[CDH].[STATUS]
   ,[CDH].[CLIENT_CODE]
   ,CASE
      WHEN MAX(T.SERIAL_NUMBER) IS NULL THEN 'NO'
      ELSE 'SI'
    END AS PICKING
   ,MAX(T.SERIAL_NUMBER) AS SERIAL_NUMBER
   ,MAX(T.TRANS_DATE) AS TRANS_DATE
   ,MAX(T.LOGIN_ID) AS LOGIN_ID
  FROM [FERCO].[OP_WMS_CERTIFICATE_DEPOSIT_HEADER] AS CDH
  INNER JOIN [FERCO].OP_WMS_CERTIFICATE_DEPOSIT_DETAIL CD
    ON (CDH.CERTIFICATE_DEPOSIT_ID_HEADER = CD.CERTIFICATE_DEPOSIT_ID_HEADER)
  LEFT JOIN [FERCO].OP_WMS_POLIZA_HEADER PH
    ON (CD.DOC_ID = PH.DOC_ID)
  LEFT JOIN [FERCO].OP_WMS_LICENSES L
    ON (PH.CODIGO_POLIZA = L.CODIGO_POLIZA)
  LEFT JOIN [FERCO].OP_WMS_TRANS T
    ON (L.LICENSE_ID = T.LICENSE_ID
        AND T.TRANS_TYPE IN ('DESPACHO_FISCAL', 'DESPACHO_GENERAL'))
  WHERE CDH.[CLIENT_CODE] = @CLIENT_CODE
  AND CDH.[STATUS] <> 'ANULAR'
  GROUP BY [CDH].[CERTIFICATE_DEPOSIT_ID_HEADER]
          ,[CDH].[VALID_FROM]
          ,[CDH].[VALID_TO]
          ,[CDH].[LAST_UPDATED]
          ,[CDH].[LAST_UPDATED_BY]
          ,[CDH].[STATUS]
          ,[CDH].[CLIENT_CODE]

END
