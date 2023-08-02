﻿
-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		10-Jan-17 @ A-Team Sprint Balder 
-- Description:			    Funcion que obtiene la cantidad de dias del mes

/*
-- Ejemplo de Ejecucion:
        --Semanal
		SELECT [FERCO].[OP_WMS_FN_GET_SERVICE_TO_BILL_PERCENTAGE]('AUTOMATIC_SERVICE','20170107 00:00:00.000','2017-01-02 00:00:00.000',7)
		--
		SELECT [FERCO].[OP_WMS_FN_GET_SERVICE_TO_BILL_PERCENTAGE]('AUTOMATIC_SERVICE','20170107 00:00:00.000','2017-01-01 00:00:00.000',7)
		
		--primera Quincenal
		SELECT [FERCO].[OP_WMS_FN_GET_SERVICE_TO_BILL_PERCENTAGE]('AUTOMATIC_SERVICE','20170215 00:00:00.000','2017-02-01 00:00:00.000',15)
		--
		SELECT [FERCO].[OP_WMS_FN_GET_SERVICE_TO_BILL_PERCENTAGE]('AUTOMATIC_SERVICE','20170215 00:00:00.000','2017-02-10 00:00:00.000',15)

		--Segunda Quincenal
		SELECT [FERCO].[OP_WMS_FN_GET_SERVICE_TO_BILL_PERCENTAGE]('AUTOMATIC_SERVICE','20170228 00:00:00.000','2017-02-20 00:00:00.000',15)
		--
		SELECT [FERCO].[OP_WMS_FN_GET_SERVICE_TO_BILL_PERCENTAGE]('AUTOMATIC_SERVICE','20170228 00:00:00.000','2017-02-16 00:00:00.000',15)
		
		--Mensual
		SELECT [FERCO].[OP_WMS_FN_GET_SERVICE_TO_BILL_PERCENTAGE]('AUTOMATIC_SERVICE','20170228 00:00:00.000','2017-02-01 00:00:00.000',30)
		--
		SELECT [FERCO].[OP_WMS_FN_GET_SERVICE_TO_BILL_PERCENTAGE]('AUTOMATIC_SERVICE','20170228 00:00:00.000','2017-02-20 00:00:00.000',30)
		
*/
-- =============================================
CREATE FUNCTION [FERCO].[OP_WMS_FN_GET_SERVICE_TO_BILL_PERCENTAGE]
(
	@TYPE VARCHAR(25)
	,@PROCESS_DATE DATETIME
	,@RECEPTION_DATE DATETIME
	,@BILLING_FRECUENCY INT
)
RETURNS NUMERIC(8,6)
AS
BEGIN
	DECLARE @DAYS NUMERIC(8,6)
	--
	SELECT
		@DAYS = CAST(
			CASE
				WHEN @TYPE = 'ON_DEMAND' THEN 1
				WHEN @BILLING_FRECUENCY = 7 -- semanal
					AND DATEDIFF(DAY ,@RECEPTION_DATE,@PROCESS_DATE) < 6
						THEN ((8 - DATEPART(dw ,@RECEPTION_DATE))/ CAST(7 AS NUMERIC(8 ,6)))
				WHEN @BILLING_FRECUENCY = 15 -- primera quincena
					AND DATEPART(DAY ,@PROCESS_DATE) <= 15
					AND @RECEPTION_DATE BETWEEN [FERCO].[OP_WMS_GET_FIRST_DAY_OF_MONTH_TO_BILL](@PROCESS_DATE)
					AND [FERCO].[OP_WMS_FN_GET_LAST_DAY_OF_FIRST_FORTNIGHT](@PROCESS_DATE) --ultimo dia primera quincena
						THEN (CAST(16 - DATEPART(DAY,@RECEPTION_DATE) AS NUMERIC(8,6)) / 15)
				WHEN @BILLING_FRECUENCY = 15 -- segunda quincena
					AND DATEPART(DAY ,@PROCESS_DATE) > 15
					AND @RECEPTION_DATE BETWEEN [FERCO].[OP_WMS_FN_GET_FIRST_DAY_OF_SECOND_FORTNIGHT_TO_BILL](@PROCESS_DATE) AND [FERCO].[OP_WMS_FN_GET_LAST_DAY_OF_MONTH](@PROCESS_DATE)
						THEN (CAST([FERCO].[OP_WMS_FN_GET_DAYS_OF_MONTH](@PROCESS_DATE) - DATEPART(DAY ,@RECEPTION_DATE) + 1 AS NUMERIC(8,6)) / [FERCO].[OP_WMS_FN_GET_DAYS_OF_SECOND_FORTNIGHT](@PROCESS_DATE))
				WHEN @BILLING_FRECUENCY = 30 -- mensual
					AND @RECEPTION_DATE BETWEEN [FERCO].[OP_WMS_GET_FIRST_DAY_OF_MONTH_TO_BILL](@PROCESS_DATE) AND [FERCO].[OP_WMS_FN_GET_LAST_DAY_OF_MONTH](@PROCESS_DATE)
						THEN (CAST([FERCO].[OP_WMS_FN_GET_DAYS_OF_MONTH](@PROCESS_DATE) - DATEPART(DAY ,@RECEPTION_DATE) + 1 AS NUMERIC(8,6))/ [FERCO].[OP_WMS_FN_GET_DAYS_OF_MONTH](@PROCESS_DATE))
				ELSE 1
			END AS NUMERIC(8 ,6));
	--
	RETURN @DAYS
END



