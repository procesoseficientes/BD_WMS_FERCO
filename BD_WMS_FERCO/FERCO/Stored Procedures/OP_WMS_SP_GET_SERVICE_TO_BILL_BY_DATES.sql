﻿
/*=============================================
Autor:				diego.as
Fecha de Creacion:	28-10-2016 @ TEM-A SPRINT 4
Descripcion:		SP que obtiene los registros 
					de servicios a cobrar
					, filtrado por fechas


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-03 Team ERGON - Sprint ERGON IV
-- Description:	 SE AGREGA CAMPO DE BILLINGFRECUENCY

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-27 Team ERGON - Sprint ERGON HYPER
-- Description:	Se agrega como resultado de la consulta el codigo del acuerdo comercial utilizado para el cobro y se agrega 
--              el simbolo de la moneda del  acuerdo comercial 

EJEMPLO DE EJECUCION:
	EXEC [FERCO].[OP_WMS_SP_GET_SERVICE_TO_BILL_BY_DATES]
	@INICIAL_DATE = '2014-10-13 00:00:00.000'
	,@FINAL_DATE = '2017-11-03 23:59:59.59'
  ,@CLIENT_CODE = 'C00030'
=============================================*/
CREATE PROCEDURE FERCO.OP_WMS_SP_GET_SERVICE_TO_BILL_BY_DATES (@INICIAL_DATE DATETIME
, @FINAL_DATE DATETIME
, @CLIENT_CODE VARCHAR(MAX)
, @IS_CHARGED INT = NULL)
AS
BEGIN
  --

  DECLARE @DELIMITER CHAR(1) = '|'
  SELECT
    [STB].[SERVICES_TO_BILL_ID]
   ,[STB].[QTY]
   ,[STB].[TRANSACTION_TYPE]
   ,[STB].[PRICE]
   ,[STB].[PRICE] [PRICE_TO_CHANGE]
   ,[STB].[TOTAL_AMOUNT]
   ,[STB].[PROCESS_DATE]
   ,[STB].[LAST_UPDATED_DATE]
   ,[STB].[LAST_UPDATED_BY]
   ,[STB].[TYPE_CHARGE_ID]
   ,[STB].[TYPE_CHARGE_DESCRIPTION]
   ,[STB].[CLIENT_CODE]
   ,[STB].[CLIENT_NAME]
   ,[STB].[IS_CHARGED]
   ,CASE [STB].[IS_CHARGED]
      WHEN 1 THEN 'SI'
      ELSE 'NO'
    END [IS_CHARGED_DESCRIPTION]
   ,[STB].[INVOICE_REFERENCE]
   ,[STB].[CHARGED_DATE]
   ,[STB].[LICENSE_ID]
   ,[STB].[LOCATION]
   ,[STB].[SERVICE_ID]
   ,[STB].[SERVICE_CODE]
   ,[STB].[SERVICE_DESCRIPTION]
   ,[STB].[REGIMEN]
   ,[STB].[DOC_NUM]
   ,[STB].[TRANSACTION_ID]
   ,CASE [STB].[BILLING_FRECUENCY]
      WHEN 1 THEN 'DIARIA'
      WHEN 7 THEN 'SEMANAL'
      WHEN 15 THEN 'QUINCENAL'
      WHEN 30 THEN 'MENSUAL'
      ELSE 'N/A'
    END [BILLING_FRECUENCY]
   ,[STB].[ACUERDO_COMERCIAL]
   ,[T].[ACUERDO_COMERCIAL_NOMBRE]
   ,CASE
      WHEN STB.[PROCESS_DATE] BETWEEN [T].[VALID_FROM] AND [T].[VALID_TO] THEN 'VIGENTE'
      ELSE 'VENCIDO'
    END ACUERDO_COMERCIAL_STATUS
   ,ISNULL([C].[TEXT_VALUE], '') AS [CURRENCY]
  FROM [FERCO].[OP_WMS_SERVICES_TO_BILL] AS STB
  INNER JOIN [FERCO].[OP_WMS_FUNC_SPLIT_2](@CLIENT_CODE, @DELIMITER) [CR]
    ON (
      CONVERT(VARCHAR, [CR].VALUE) = STB.CLIENT_CODE
      )
  INNER JOIN [FERCO].[OP_WMS_TARIFICADOR_HEADER] [T]
    ON [STB].[ACUERDO_COMERCIAL] = T.[ACUERDO_COMERCIAL_ID]
  LEFT JOIN [FERCO].[OP_WMS_CONFIGURATIONS] [C]
    ON [C].[PARAM_GROUP] = 'CURRENCY'
      AND [C].[PARAM_TYPE] = 'SISTEMA'
      AND [C].[PARAM_NAME] = [T].[CURRENCY]
  WHERE CONVERT(DATE, [STB].[PROCESS_DATE])
  BETWEEN CONVERT(DATE, CONVERT(VARCHAR(25), @INICIAL_DATE, 101)) AND CONVERT(DATE, CONVERT(VARCHAR(25), @FINAL_DATE, 101))
  AND (@IS_CHARGED IS NULL
  OR [STB].[IS_CHARGED] = @IS_CHARGED)
--
END
