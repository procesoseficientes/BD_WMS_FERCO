﻿-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	4/12/2018 @ GForce-Team Sprint Buho
-- Description:			Consultar en inventario las transferencias preparados por los filtros enviados

/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[OP_WMS_SP_GET_PREPARED_TRANSFER_REQUEST_TO_DISPATCH_ERP]
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_GET_PREPARED_TRANSFER_REQUEST_TO_DISPATCH_ERP]
	(
		@START_DATETIME DATETIME
		,@END_DATETIME DATETIME
		,@CODE_WAREHOUSE VARCHAR(25)
	)
AS
	BEGIN
		SET NOCOUNT ON;
	--
		SELECT DISTINCT
			[PDH].[PICKING_DEMAND_HEADER_ID]
			,[PDH].[DOC_NUM] [SALES_ORDER_ID]
			,[PDH].[CREATED_DATE] [POSTED_DATETIME]
			,[PDH].[CLIENT_CODE] [CLIENT_ID]
			,[PDH].[CLIENT_NAME] [CUSTOMER_NAME]
			,[PDH].[TOTAL_AMOUNT] [TOTAL_AMOUNT]
			,[PDH].[CODE_ROUTE] [CODE_ROUTE]
			,[PDH].[CODE_SELLER] [LOGIN]
			,[PDH].[SERIAL_NUMBER] [DOC_SERIE]
			,[PDH].[DOC_NUM] [DOC_NUM]
			,'' [COMMENT]
			,[ES].[EXTERNAL_SOURCE_ID]
			,[ES].[SOURCE_NAME]
			,[PDH].[IS_FROM_SONDA]
			,[PDH].[SELLER_OWNER]
			,[PDH].[MASTER_ID_SELLER]
			,[PDH].[CODE_SELLER]
			,[PDH].[CLIENT_OWNER]
			,[PDH].[CLIENT_CODE] [MASTER_ID_CLIENT]
			,[PDH].[OWNER]
			,[PDH].[DEMAND_DELIVERY_DATE] [DELIVERY_DATE]
			,'WT - ERP' [SOURCE]
			,[PDH].[ADDRESS_CUSTOMER]
			,[PDH].[DISCOUNT]
			,[PDH].[DOC_ENTRY]
			,CAST([PDH].[TRANSFER_REQUEST_ID] AS VARCHAR) [LINE_DOC]
		FROM
			[FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
		INNER JOIN [FERCO].[OP_SETUP_EXTERNAL_SOURCE] [ES]
		ON	[ES].[EXTERNAL_SOURCE_ID] = [PDH].[EXTERNAL_SOURCE_ID]
		INNER JOIN [FERCO].[OP_WMS_TASK_LIST] [TL]
		ON	[TL].[WAVE_PICKING_ID] = [PDH].[WAVE_PICKING_ID]
		WHERE
			[PDH].[IS_FROM_ERP] = 1
			AND [PDH].[IS_FOR_DELIVERY_IMMEDIATE] = 0
			AND [PDH].[DEMAND_DELIVERY_DATE] BETWEEN @START_DATETIME
												AND		@END_DATETIME
			AND [PDH].[CODE_WAREHOUSE] = @CODE_WAREHOUSE
			AND [TL].[IS_COMPLETED] = 1
			AND ISNULL([PDH].[TRANSFER_REQUEST_ID] ,0) > 0;
	END;

