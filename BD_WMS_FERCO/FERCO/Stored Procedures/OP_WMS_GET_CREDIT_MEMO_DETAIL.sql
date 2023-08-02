-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	10/11/2017 @ NEXUS-Team Sprint eFERCO 
-- Description:			Devuelve el detalle de una nota de credito para enviar a ERP

-- Modificacion 1/29/2018 @ REBORN-Team Sprint Trotzdem
					-- rodrigo.gomez
					-- Se agregan campos extra para las devoluciones y notas de credito

-- Modificacion 4/6/2018 @ REBORN Sprint Buho
	-- diego.as
	-- Se agrega campo COST_CENTER para envio en la interfaz

-- Modificacion 13/05/2022
	-- Elder Lucas
	-- Se agrega campo AgrNo en los resultados de la consulta para manejarlo en la interfaz

/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[OP_WMS_GET_CREDIT_MEMO_DETAIL]
					@RECEPTION_HEADER_ID = 56881
					,@OWNER = 'ferco'
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_GET_CREDIT_MEMO_DETAIL]
    (
      @RECEPTION_HEADER_ID INT
    , @OWNER VARCHAR(50)
    )
AS
    BEGIN
        SET NOCOUNT ON;
		--
        SELECT DISTINCT
			[RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
          , [FERCO].OP_WMS_FN_SPLIT_COLUMNS([RDD].[MATERIAL_ID], 2, '/') [MATERIAL_ID]
          , [M].[MATERIAL_NAME]
          , SUM([RDD].[QTY_CONFIRMED]) [QTY]
          , [RDD].[LINE_NUM]
          , CAST([RDH].[DOC_ID]as int) [DOC_ENTRY]
		  , [RDD].[TAX_CODE]
		  , [RDD].[VAT_PERCENT]
		  , [RDD].[PRICE]
		  , [RDD].[DISCOUNT]
		  , [RDD].[WAREHOUSE_CODE]
		  , [RDD].[CURRENCY]
		  , [RDD].[RATE]
		  , [RDD].[COST_CENTER]
		  , VID.AgrNo
        FROM
            [FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [RDD]
        INNER JOIN [FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH] ON [RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [RDD].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
        INNER JOIN [FERCO].[OP_WMS_TASK_LIST] [TL] ON [TL].[SERIAL_NUMBER] = [RDH].[TASK_ID]      
        INNER JOIN [FERCO].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [RDD].[MATERIAL_ID]
		INNER JOIN [SWIFT_INTERFACES].[ferco].[ERP_VIEW_INVOICE_DETAIL_FOR_INTERFACE] [VID] 
			ON [VID].[DocEntry] = [RDH].[DOC_ENTRY] AND [VID].[ItemCode] = [M].[ITEM_CODE_ERP] COLLATE DATABASE_DEFAULT
        WHERE
            [RDD].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_HEADER_ID
            AND [RDD].[ERP_RECEPTION_DOCUMENT_DETAIL_ID] > 0
            AND [M].[CLIENT_OWNER] = @OWNER
			AND [RDD].[LINE_NUM] > -1
        GROUP BY
			[RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
          , [RDD].[MATERIAL_ID]
          , [RDD].[LINE_NUM]
          , [M].[MATERIAL_NAME]
          , [RDH].[DOC_ID]
		  , [RDD].[TAX_CODE]
		  , [RDD].[VAT_PERCENT]
		  , [RDD].[PRICE]
		  , [RDD].[DISCOUNT]
		  , [RDD].[WAREHOUSE_CODE]
		  , [RDD].[CURRENCY]
		  , [RDD].[RATE]
		  , [RDD].[COST_CENTER]
		  , VID.AgrNo
		  HAVING  SUM([RDD].[QTY_CONFIRMED]) > 0;
    END;