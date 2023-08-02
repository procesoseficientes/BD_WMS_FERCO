-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	8/11/2017 @ NEXUS-Team Sprint Banjo-Kazooie 
-- Description:			Se inserta el detalle del pedido en ERP_SALES_ORDER_DETAIL_CHANNEL_MODERN y se devuelve la secuencia

-- Modificacion 9/21/2017 @ NEXUS-Team Sprint DuckHunt
-- rodrigo.gomez
-- Se cambia el filtro por DocDueDate en lugar de Docdate

-- Modificacion 03-Nov-17 @ Nexus Team Sprint F-Zero
-- alberto.ruiz
-- Se agrega descuento

/*
-- Ejemplo de Ejecucion:
				DECLARE @START_DATE DATETIME = GETDATE()-1
					,@END_DATE DATETIME = GETDATE()
					,@ID INT
				
				EXEC [ferco].[ERP_SP_INSERT_SALES_ORDER_DETAIL] 
					@START_DATE = @START_DATE, -- varchar(100)
					@END_DATE = @END_DATE, -- varchar(100)
					@SEQUENCE = @ID OUTPUT,	-- int
					@WAREHOUSE ='01'

				SELECT @ID
				SELECT * FROM [ferco].[ERP_SALES_ORDER_DETAIL_CHANNEL_MODERN]  WHERE SEQUENCE = @ID 
				DELETE [ferco].[ERP_SALES_ORDER_DETAIL_CHANNEL_MODERN] WHERE SEQUENCE = @ID 

*/
-- =============================================
CREATE PROCEDURE [ferco].[ERP_SP_INSERT_SALES_ORDER_DETAIL] (
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

	INSERT	INTO [ferco].[ERP_SALES_ORDER_SEQUENCE_CHANNEL_MODERN]
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
		INSERT INTO [ferco].[ERP_SALES_ORDER_DETAIL_CHANNEL_MODERN]

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
			,[T0].[DocNum]
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
			, '''''''' statusOfMaterial
		FROM SBOFERCO.dbo.ORDR T0--ENCABEZADO OV
			INNER JOIN SBOFERCO.dbo.RDR1 T1 ON T0.[DocEntry] = T1.[DocEntry]  -- DETALLE OV
			LEFT JOIN SBOFERCO.dbo.OSLP T2 ON T0.SlpCode = T2.SlpCode  --EMPLEADOS DE VENTAS
		WHERE
			[T0].[CANCELED] <> ''''C'''' 
			AND [T0].[CardCode] NOT LIKE ''''SO%'''' 
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
  --

  -- ------------------------------------------------------------------------------------
  -- Detalles
  -- ------------------------------------------------------------------------------------
  /*
  	SELECT
		@SQL = '
		INSERT INTO [ferco].[ERP_SALES_ORDER_DETAIL_CHANNEL_MODERN]

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
			,[T0].[DocNum]
			,'''''''' U_Serie--[T0].[U_Serie]
			,'''''''' U_NoDocto--[T0].[U_NoDocto]
			,[T0].[CardCode]
			,[T0].[CardName]
			,[T2].[SlpName]
			,'''''''' U_oper--[T0].[U_oper]
			,[T1].[ItemCode]
			,[T1].[ItemCode] [U_MasterIdSKU]
			,''''DETALLES'''' [U_OwnerSKU]
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
			,   T1.WhsCode  WhsCode
			,CAST([T0].[DiscPrcnt] AS DECIMAL) / 100 AS DESCUENTO_FACTURA
			,CASE	WHEN [T0].[CANCELED] = ''''N'''' THEN ''''FACTURA''''
					WHEN [T0].[CANCELED] = ''''Y'''' THEN ''''ANULADA''''
				END AS STATUS
			,[T1].[LineNum] + 1 AS NUMERO_LINEA
			,[T0].[CardCode] [U_MasterIDCustomer]
			,''''DETALLES'''' [U_OwnerCustomer]
			,''''DETALLES'''' [Owner]
			,T1.OpenQty
			,T1.DiscPrcnt LineDiscPrcnt
			,T1.unitMsr
			, '''''''' statusOfMaterial
		FROM DETALLES.dbo.ORDR T0--ENCABEZADO OV
			INNER JOIN DETALLES.dbo.RDR1 T1 ON T0.[DocEntry] = T1.[DocEntry]  -- DETALLE OV
			LEFT JOIN DETALLES.dbo.OSLP T2 ON T0.SlpCode = T2.SlpCode  --EMPLEADOS DE VENTAS
		WHERE
			[T0].[CANCELED] <> ''''C'''' 
			AND [T0].[CardCode] NOT LIKE ''''SO%'''' 
			AND T0.DocDueDate BETWEEN CAST('''''
		+ @START_DATE + ''''' AS VARCHAR)  AND CAST('''''
		+ @END_DATE
		+ ''''' AS VARCHAR)
				and   T1.WhsCode = '''''
		+ @WAREHOUSE + ''''';
	'')	';
  --
	PRINT (@SQL);
  --
	EXEC (@SQL);
  --
  */
  
 -- -- ------------------------------------------------------------------------------------
 -- -- Detalles
 -- -- ------------------------------------------------------------------------------------

 -- 	SELECT
	--	@SQL = '
	--	INSERT INTO [ferco].[ERP_SALES_ORDER_DETAIL_CHANNEL_MODERN]

	--		(
	--			[Sequence]
	--			,[DocDate]
	--			,[DocNum]
	--			,[U_Serie]
	--			,[U_NoDocto]
	--			,[CardCode]
	--			,[CardName]
	--			,[SlpName]
	--			,[U_oper]
	--			,[ItemCode]
	--			,[U_MasterIdSKU]
	--			,[U_OwnerSKU]
	--			,[Dscription]
	--			,[Quantity]
	--			,[PRECIO_CON_IVA]
	--			,[TOTAL_LINEA_SIN_DESCUENTO]
	--			,[TOTAL_LINEA_CON_DESCUENTO_APLICADO]
	--			,[WhsCode]
	--			,[DESCUENTO_FACTURA]
	--			,[STATUS]
	--			,[NUMERO_LINEA]
	--			,[U_MasterIDCustomer]
	--			,[U_OwnerCustomer]
	--			,[Owner]
	--			,[OpenQty]
	--			,[LINE_DISCOUNT]
	--			,[unitMsr]
	--			, statusOfMaterial
	--		)

	--	SELECT
	--		' + CAST(@ID AS VARCHAR)
	--	+ '
	--	  ,*
	--	FROM OPENQUERY([SAPSERVER], ''
	--	SELECT DISTINCT
	--		[T0].[DocDate]
	--		,[T0].[DocNum]
	--		,'''''''' U_Serie--[T0].[U_Serie]
	--		,'''''''' U_NoDocto--[T0].[U_NoDocto]
	--		,[T0].[CardCode]
	--		,[T0].[CardName]
	--		,[T2].[SlpName]
	--		,'''''''' U_oper--[T0].[U_oper]
	--		,[T1].[ItemCode]
	--		,[T1].[ItemCode] [U_MasterIdSKU]
	--		,''''VOI7'''' [U_OwnerSKU]
	--		,[T1].[Dscription]
	--		,CASE	WHEN [T0].[CANCELED] = ''''N'''' THEN [T1].[Quantity]
	--				WHEN [T0].[CANCELED] = ''''Y'''' THEN 0
	--			END AS Quantity
	--		,CASE	WHEN [T0].[CANCELED] = ''''N'''' THEN [T1].[PriceAfVAT]
	--				WHEN [T0].[CANCELED] = ''''Y'''' THEN 0
	--			END AS PRECIO_CON_IVA
	--		,CASE	WHEN [T0].[CANCELED] = ''''N''''
	--				THEN ([T1].[Quantity] * [T1].[PriceAfVAT])
	--				WHEN [T0].[CANCELED] = ''''Y'''' THEN 0
	--			END AS TOTAL_LINEA_SIN_DESCUENTO
	--		,CASE	WHEN [T0].[CANCELED] = ''''N''''
	--				THEN ([T1].[Quantity] * [T1].[PriceAfVAT])
	--						- (([T1].[Quantity] * [T1].[PriceAfVAT])
	--							* ([T0].[DiscPrcnt] / 100))
	--				WHEN [T0].[CANCELED] = ''''Y'''' THEN 0
	--			END AS TOTAL_LINEA_CON_DESCUENTO_APLICADO
	--		,   T1.WhsCode  WhsCode
	--		,CAST([T0].[DiscPrcnt] AS DECIMAL) / 100 AS DESCUENTO_FACTURA
	--		,CASE	WHEN [T0].[CANCELED] = ''''N'''' THEN ''''FACTURA''''
	--				WHEN [T0].[CANCELED] = ''''Y'''' THEN ''''ANULADA''''
	--			END AS STATUS
	--		,[T1].[LineNum] + 1 AS NUMERO_LINEA
	--		,[T0].[CardCode] [U_MasterIDCustomer]
	--		,''''VOI7'''' [U_OwnerCustomer]
	--		,''''VOI7'''' [Owner]
	--		,T1.OpenQty
	--		,T1.DiscPrcnt LineDiscPrcnt
	--		,T1.unitMsr
	--		, '''''''' statusOfMaterial
	--	FROM CASA_OAKLAND.dbo.ORDR T0--ENCABEZADO OV
	--		INNER JOIN CASA_OAKLAND.dbo.RDR1 T1 ON T0.[DocEntry] = T1.[DocEntry]  -- DETALLE OV
	--		LEFT JOIN CASA_OAKLAND.dbo.OSLP T2 ON T0.SlpCode = T2.SlpCode  --EMPLEADOS DE VENTAS
	--	WHERE
	--		[T0].[CANCELED] <> ''''C'''' 
	--		AND [T0].[CardCode] NOT LIKE ''''SO%'''' 
	--		AND T0.DocDueDate BETWEEN CAST('''''
	--	+ @START_DATE + ''''' AS VARCHAR)  AND CAST('''''
	--	+ @END_DATE
	--	+ ''''' AS VARCHAR)
	--			and   T1.WhsCode = '''''
	--	+ @WAREHOUSE + ''''';
	--'')	';
 -- --
	--PRINT (@SQL);
  --
	--EXEC (@SQL);
 -- --
 -- SELECT
	--	@SQL = '
	--	INSERT INTO [ferco].[ERP_SALES_ORDER_DETAIL_CHANNEL_MODERN]

	--		(
	--			[Sequence]
	--			,[DocDate]
	--			,[DocNum]
	--			,[U_Serie]
	--			,[U_NoDocto]
	--			,[CardCode]
	--			,[CardName]
	--			,[SlpName]
	--			,[U_oper]
	--			,[ItemCode]
	--			,[U_MasterIdSKU]
	--			,[U_OwnerSKU]
	--			,[Dscription]
	--			,[Quantity]
	--			,[PRECIO_CON_IVA]
	--			,[TOTAL_LINEA_SIN_DESCUENTO]
	--			,[TOTAL_LINEA_CON_DESCUENTO_APLICADO]
	--			,[WhsCode]
	--			,[DESCUENTO_FACTURA]
	--			,[STATUS]
	--			,[NUMERO_LINEA]
	--			,[U_MasterIDCustomer]
	--			,[U_OwnerCustomer]
	--			,[Owner]
	--			,[OpenQty]
	--			,[LINE_DISCOUNT]
	--			,[unitMsr]
	--			, statusOfMaterial
	--		)

	--	SELECT
	--		' + CAST(@ID AS VARCHAR)
	--	+ '
	--	  ,*
	--	FROM OPENQUERY([SAPSERVER], ''
	--	SELECT DISTINCT
	--		[T0].[DocDate]
	--		,[T0].[DocNum]
	--		,'''''''' U_Serie--[T0].[U_Serie]
	--		,'''''''' U_NoDocto--[T0].[U_NoDocto]
	--		,[T0].[CardCode]
	--		,[T0].[CardName]
	--		,[T2].[SlpName]
	--		,'''''''' U_oper--[T0].[U_oper]
	--		,[T1].[ItemCode]
	--		,[T1].[ItemCode] [U_MasterIdSKU]
	--		,''''ALMASA'''' [U_OwnerSKU]
	--		,[T1].[Dscription]
	--		,CASE	WHEN [T0].[CANCELED] = ''''N'''' THEN [T1].[Quantity]
	--				WHEN [T0].[CANCELED] = ''''Y'''' THEN 0
	--			END AS Quantity
	--		,CASE	WHEN [T0].[CANCELED] = ''''N'''' THEN [T1].[PriceAfVAT]
	--				WHEN [T0].[CANCELED] = ''''Y'''' THEN 0
	--			END AS PRECIO_CON_IVA
	--		,CASE	WHEN [T0].[CANCELED] = ''''N''''
	--				THEN ([T1].[Quantity] * [T1].[PriceAfVAT])
	--				WHEN [T0].[CANCELED] = ''''Y'''' THEN 0
	--			END AS TOTAL_LINEA_SIN_DESCUENTO
	--		,CASE	WHEN [T0].[CANCELED] = ''''N''''
	--				THEN ([T1].[Quantity] * [T1].[PriceAfVAT])
	--						- (([T1].[Quantity] * [T1].[PriceAfVAT])
	--							* ([T0].[DiscPrcnt] / 100))
	--				WHEN [T0].[CANCELED] = ''''Y'''' THEN 0
	--			END AS TOTAL_LINEA_CON_DESCUENTO_APLICADO
	--		, CASE WHEN ISNULL(u_bodega_wms, '''''''' ) = '''''''' THEN  T1.WhsCode  ELSE u_bodega_wms END WhsCode
	--		,CAST([T0].[DiscPrcnt] AS DECIMAL) / 100 AS DESCUENTO_FACTURA
	--		,CASE	WHEN [T0].[CANCELED] = ''''N'''' THEN ''''FACTURA''''
	--				WHEN [T0].[CANCELED] = ''''Y'''' THEN ''''ANULADA''''
	--			END AS STATUS
	--		,[T1].[LineNum] + 1 AS NUMERO_LINEA
	--		,[T0].[CardCode] [U_MasterIDCustomer]
	--		,''''ALMASA'''' [U_OwnerCustomer]
	--		,''''ALMASA'''' [Owner]
	--		,T1.OpenQty
	--		,T1.DiscPrcnt LineDiscPrcnt
	--		,T1.unitMsr
	--		, '''''''' statusOfMaterial
	--	FROM SBO_ALMASA.dbo.ORDR T0--ENCABEZADO OV
	--		INNER JOIN SBO_ALMASA.dbo.RDR1 T1 ON T0.[DocEntry] = T1.[DocEntry]  -- DETALLE OV
	--		LEFT JOIN SBO_ALMASA.dbo.OSLP T2 ON T0.SlpCode = T2.SlpCode  --EMPLEADOS DE VENTAS
	--	WHERE
	--		[T0].[CANCELED] <> ''''C'''' 
	--		AND [T0].[CardCode] NOT LIKE ''''SO%'''' 
	--		AND T0.DocDueDate BETWEEN CAST('''''
	--	+ @START_DATE + ''''' AS VARCHAR)  AND CAST('''''
	--	+ @END_DATE
	--	+ ''''' AS VARCHAR)
	--			and CASE WHEN ISNULL(u_bodega_wms, '''''''' ) = '''''''' THEN  T1.WhsCode  ELSE u_bodega_wms END = '''''
	--	+ @WAREHOUSE + ''''';
	--'')	';
 -- --
	--PRINT (@SQL);
  --
	--EXEC (@SQL);

	RETURN;
END;

