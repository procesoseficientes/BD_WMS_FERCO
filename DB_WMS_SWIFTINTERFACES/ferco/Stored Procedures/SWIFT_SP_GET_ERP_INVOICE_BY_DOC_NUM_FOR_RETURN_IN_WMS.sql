-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	10-Oct-17 @ Nexus Team Sprint eNave 
-- Description:			SP que obtiene una factura con su detalle

-- Modificacion 1/26/2018 @ Reborn-Team Sprint Trotzdem
					-- diego.as
					-- Se agrega obtencion de campos necesarios para ferco

/*
-- Ejemplo de Ejecucion:
				EXEC [ferco].[SWIFT_SP_GET_ERP_INVOICE_BY_DOC_NUM_FOR_RETURN_IN_WMS]
					@DATABASE = 'SBOFERCO'
					,@DOC_NUM = 20102035
					,@USE_SUBSIDIARY = 0
*/
-- =============================================
CREATE PROCEDURE [ferco].[SWIFT_SP_GET_ERP_INVOICE_BY_DOC_NUM_FOR_RETURN_IN_WMS](
	@DATABASE VARCHAR(50)
	,@DOC_NUM INT
	,@USE_SUBSIDIARY INT = 0
) AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @QUERY NVARCHAR(MAX)
	--
	SELECT @QUERY = N'
		SELECT 
			*
		FROM (SELECT * FROM OPENQUERY([SAPSERVER],''
			SELECT 
				[H].[DocEntry] [DOC_ENTRY]
				,[H].[DocNum] [DOC_NUM]
				,[H].[CardCode] [CLIENT_CODE]
				,[H].[CardName] [CLIENT_NAME]
				,[H].[Comments] [COMMENTS]
				,[H].[DocDate] [DOC_DATE]
				,[H].[DocDueDate] [DELIVERY_DATE]
				,[H].[DocStatus] [STATUS]
				,[H].[SlpCode] [CODE_SELLER]
				,[H].[DocTotal] [TOTAL_AMOUNT]
				,[D].[LineNum] [LINE_NUM]
				,[D].[ItemCode] COLLATE DATABASE_DEFAULT [MATERIAL_ID]
				,[D].[Dscription] [MATERIAL_NAME]
				,[D].[Quantity] [QTY]
				,[D].[OpenQty] [OPEN_QTY]
				,[D].[Price] [PRICE]
				,[D].[DiscPrcnt] [DISCOUNT_PERCENT]
				,[D].[LineTotal] [TOTAL_LINE]
				,[D].[WhsCode] [WAREHOUSE_CODE]
				,''''ferco'''' [MATERIAL_OWNER]
				,[H].[Address] [ADDRESS]
				,[H].[DocCur] [DOC_CURRENCY]
				,[H].[DocRate] [DOC_RATE] 
				'
				IF(@USE_SUBSIDIARY = '1') BEGIN
					SET @QUERY = @QUERY + ',[H].[U_Sucursal] [SUBSIDIARY] '
				END
				ELSE BEGIN
					SET @QUERY = @QUERY + ',CAST(NULL AS VARCHAR) [SUBSIDIARY] '
				END
				SET @QUERY = @QUERY + '
				,[D].[Currency] [DET_CURRENCY]
				,[D].[Rate] [DET_RATE]
				,[D].[TaxCode] [DET_TAX_CODE]
				,[D].[VatPrcnt] [DET_VAT_PERCENT]
				,[D].[ocrCode]  [COST_CENTER]
				,D.[unitMsr] [UNIT]
				
			FROM ' + @DATABASE + '.[dbo].[OINV] [H]
			INNER JOIN ' + @DATABASE + '.[dbo].[INV1] [D] ON ([H].[DocEntry] = [D].[DocEntry])
			WHERE [H].[DocNum] = ' + CAST(@DOC_NUM AS VARCHAR) + '
		'')) [O];'
	--
	PRINT '@QUERY: ' + @QUERY
	--
	EXEC(@QUERY)
END


