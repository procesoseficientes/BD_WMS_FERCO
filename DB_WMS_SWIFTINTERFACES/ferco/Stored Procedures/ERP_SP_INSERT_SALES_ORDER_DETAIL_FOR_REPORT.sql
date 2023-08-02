
-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	8/11/2017 @ NEXUS-Team Sprint Banjo-Kazooie 
-- Description:			Se inserta el detalle del pedido en ERP_SALES_ORDER_DETAIL_CHANNEL_MODERN y se devuelve la secuencia para el reporte de trazabilidad

/*
-- Ejemplo de Ejecucion:
				DECLARE @START_DATE DATETIME = GETDATE()-1
					,@END_DATE DATETIME = GETDATE()
					,@ID INT
				
				EXEC [FERCO].[ERP_SP_INSERT_SALES_ORDER_DETAIL_FOR_REPORT] 
					@START_DATE = @START_DATE, -- varchar(100)
					@END_DATE = @END_DATE, -- varchar(100)
					@SEQUENCE = @ID OUTPUT	-- int

				SELECT @ID


*/
-- =============================================
CREATE PROCEDURE [ferco].[ERP_SP_INSERT_SALES_ORDER_DETAIL_FOR_REPORT] (@START_DATE VARCHAR(100)
, @END_DATE VARCHAR(100)
, @SEQUENCE INT OUTPUT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @SQL VARCHAR(4000) = ''
         ,@ID INT

  INSERT INTO [FERCO].[ERP_SALES_ORDER_SEQUENCE_CHANNEL_MODERN] ([StartDate], [EndDate])
    VALUES (@START_DATE  -- StartDate - datetime
    , @END_DATE  -- EndDate - datetime
    )
  SELECT
    @ID = SCOPE_IDENTITY()
   ,@SEQUENCE = SCOPE_IDENTITY()

  SELECT
    @SQL = '
		INSERT INTO [FERCO].[ERP_SALES_ORDER_DETAIL_CHANNEL_MODERN]
			(
			[Sequence]
			,[DocDate]
			,[DocNum]
			,[U_Serie]
			,[U_NoDocto]
			,[CardCode]
			,[CardName]
			,[SlpName]
			,[U_oper]
			,[ItemCode]
			,[U_MasterIdSKU]
			,[U_OwnerSKU]
			,[Dscription]
			,[Quantity]
			,[PRECIO_CON_IVA]
			,[TOTAL_LINEA_SIN_DESCUENTO]
			,[TOTAL_LINEA_CON_DESCUENTO_APLICADO]
			,[WhsCode]
			,[DESCUENTO_FACTURA]
			,[STATUS]
			,[NUMERO_LINEA]
			,[U_MasterIDCustomer]
			,[U_OwnerCustomer]
			,[Owner]
			,[OpenQty]
			,[LINE_DISCOUNT]
		)
		SELECT
			' + CAST(@ID AS VARCHAR) + '
		  ,*
		FROM OPENQUERY([SAPSERVER], ''
		SELECT DISTINCT
			[T0].[DocDate]
			,[T0].[DocNum]
			,'''''''' [U_Serie]
			,'''''''' [U_NoDocto]
			,[T0].[CardCode]
			,[T0].[CardName]
			,[T2].[SlpName]
			,'''''''' [U_oper]
			,[T1].[ItemCode]
			,[T1].[ItemCode] [U_MasterIdSKU]
			,''''ferco'''' [U_OwnerSKU]
			,[T1].[Dscription]
			,CASE	WHEN [T0].[CANCELED] = ''''N'''' THEN [T1].[Quantity]
					WHEN [T0].[CANCELED] = ''''Y'''' THEN 0
				END AS Quantity
			,CASE	WHEN [T0].[CANCELED] = ''''N'''' THEN [T1].[PriceAfVAT]
					WHEN [T0].[CANCELED] = ''''Y'''' THEN 0
				END AS PRECIO_CON_IVA
			,CASE	WHEN [T0].[CANCELED] = ''''N''''
					THEN ([T1].[Quantity] * [T1].[PriceAfVAT])
					WHEN [T0].[CANCELED] = ''''Y'''' THEN 0
				END AS TOTAL_LINEA_SIN_DESCUENTO
			,CASE	WHEN [T0].[CANCELED] = ''''N''''
					THEN ([T1].[Quantity] * [T1].[PriceAfVAT])
							- (([T1].[Quantity] * [T1].[PriceAfVAT])
								* ([T0].[DiscPrcnt] / 100))
					WHEN [T0].[CANCELED] = ''''Y'''' THEN 0
				END AS TOTAL_LINEA_CON_DESCUENTO_APLICADO
			,[T1].[WhsCode]
			,CAST([T0].[DiscPrcnt] AS DECIMAL) / 100 AS DESCUENTO_FACTURA
			,CASE	WHEN [T0].[CANCELED] = ''''N'''' THEN ''''FACTURA''''
					WHEN [T0].[CANCELED] = ''''Y'''' THEN ''''ANULADA''''
				END AS STATUS
			,[T1].[LineNum] + 1 AS NUMERO_LINEA
			,[T0].[CardCode] [U_MasterIDCustomer]
			,''''ferco'''' [U_OwnerCustomer]
			,''''ferco'''' [Owner]
			,[T1].[OpenQty]
			,T1.DiscPrcnt LineDiscPrcnt
		FROM SBOFERCO.dbo.ORDR T0 
			INNER JOIN SBOFERCO.dbo.RDR1 T1 ON T0.DocEntry = T1.DocEntry                                                                                                       
			INNER JOIN SBOFERCO.dbo.OSLP T2 ON [T0].[SlpCode] = [T2].[SlpCode]                                      
		WHERE
			[T0].[CANCELED] <> ''''C''''
			AND [T0].[CardCode] NOT LIKE ''''SO%''''
			AND T0.DocDueDate BETWEEN CAST(''''' + @START_DATE + ''''' AS VARCHAR) AND CAST(''''' + @END_DATE + ''''' AS VARCHAR)
			AND T0.DocType <> ''''S'''';			
	'')	'
  PRINT (@SQL)
  EXEC (@SQL)

  RETURN;
END

