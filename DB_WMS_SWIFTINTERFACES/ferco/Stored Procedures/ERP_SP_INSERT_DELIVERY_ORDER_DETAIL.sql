
-- =============================================
-- Autor:				gustavo.garcia
-- Fecha de Creacion: 	8/11/2017 @ NEXUS-Team Sprint Banjo-Kazooie 
-- Description:			Se inserta el detalle del pedido en ERP_SALES_ORDER_DETAIL_CHANNEL_MODERN y se devuelve la secuencia


/*
-- Ejemplo de Ejecucion:
				DECLARE @START_DATE DATETIME = GETDATE()-1
					,@END_DATE DATETIME = GETDATE()
					,@ID INT
				
				EXEC [ferco].[ERP_SP_INSERT_DELIVERY_ORDER_DETAIL] 
					@START_DATE = @START_DATE, -- varchar(100)
					@END_DATE = @END_DATE, -- varchar(100)
					@SEQUENCE = @ID OUTPUT,	-- int
					@WAREHOUSE ='01'

				SELECT @ID
				SELECT * FROM [ferco].[ERP_DELIVERY_ORDER_DETAIL]  WHERE SEQUENCE = @ID 
				DELETE [ferco].[ERP_DELETE_ORDER_DETAIL] WHERE SEQUENCE = @ID 

*/
-- =============================================
CREATE PROCEDURE [ferco].[ERP_SP_INSERT_DELIVERY_ORDER_DETAIL] (
		@START_DATE VARCHAR(100)
		,@END_DATE VARCHAR(100)
		,@WAREHOUSE VARCHAR(100)
		,@SEQUENCE INT OUTPUT
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	DECLARE
		@SQL VARCHAR(4000) = ''
		,@ID INT;

	INSERT	INTO [ferco].[ERP_DELIVERY_ORDER_SEQUENCE]
			([StartDate], [EndDate])
	VALUES
			(@START_DATE  -- StartDate - datetime
				, @END_DATE  -- EndDate - datetime
				);
	SELECT
		@ID = SCOPE_IDENTITY()
		,@SEQUENCE = SCOPE_IDENTITY();

	SELECT
		@SQL = '
		INSERT INTO [ferco].[ERP_DELIVERY_ORDER_DETAIL]

			(
				[Sequence]
				,[DocDate]
				,[DocNum]
				, [BASE_REF]
				, [BASE_ENTRY]
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
				,[unitMsr]
				, statusOfMaterial
			)

		SELECT
			' + CAST(@ID AS VARCHAR)
		+ '
		  ,*
		FROM OPENQUERY([SAPSERVER], ''
		SELECT DISTINCT
			[T0].[DocDate]
			,[T0].[DocEntry]
			,[T1].[BaseRef]
			,[T1].[BaseENtry]
			,'''''''' U_Serie--[T0].[U_Serie]
			,'''''''' U_NoDocto--[T0].[U_NoDocto]
			,[T0].[CardCode]
			,[T0].[CardName]
			,[T2].[SlpName]
			,'''''''' U_oper--[T0].[U_oper]
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
			, CASE WHEN ISNULL(u_bodega_wms, '''''''' ) = '''''''' THEN  T1.WhsCode  ELSE u_bodega_wms END WhsCode
			,CAST([T0].[DiscPrcnt] AS DECIMAL) / 100 AS DESCUENTO_FACTURA
			,CASE	WHEN [T0].[CANCELED] = ''''N'''' THEN ''''FACTURA''''
					WHEN [T0].[CANCELED] = ''''Y'''' THEN ''''ANULADA''''
				END AS STATUS
			,[T1].[LineNum] + 1 AS NUMERO_LINEA
			,[T0].[CardCode] [U_MasterIDCustomer]
			,''''ferco'''' [U_OwnerCustomer]
			,''''ferco'''' [Owner]
			,T1.OpenQty
			,T1.DiscPrcnt LineDiscPrcnt
			,T1.unitMsr
			, [T1].[BaseRef] statusOfMaterial
		FROM [SBOFERCO].dbo.ODRF T0--ENCABEZADO OV
			INNER JOIN [SBOFERCO].dbo.DRF1 T1 ON T0.[DocEntry] = T1.[DocEntry]  -- DETALLE OV
			LEFT JOIN [SBOFERCO].dbo.OSLP T2 ON T0.SlpCode = T2.SlpCode  --EMPLEADOS DE VENTAS
		WHERE
			[T0].[CANCELED] <> ''''C'''' 
			AND [T0].[CardCode] NOT LIKE ''''SO%'''' 
			AND T1.BaseRef is not null
			AND T0.DocDueDate BETWEEN CAST('''''
		+ @START_DATE + ''''' AS VARCHAR)  AND CAST('''''
		+ @END_DATE
		+ ''''' AS VARCHAR)
				and CASE WHEN ISNULL(u_bodega_wms, '''''''' ) = '''''''' THEN  T1.WhsCode  ELSE u_bodega_wms END = '''''
		+ @WAREHOUSE + ''''';
	'')	';
  --
	PRINT (@SQL);
  --
	EXEC (@SQL);
 

	RETURN;
END;

