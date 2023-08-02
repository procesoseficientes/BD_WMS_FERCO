-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	8/11/2017 @ NEXUS-Team Sprint Banjo-Kazooie 
-- Description:			Inserta las ordenes de venta en ERP_SALES_ORDER_HEADER_CHANNEL_MODERN y devuelve el ID de secuencia.

-- Modificacion 22-Sep-17 @ Nexus Team Sprint DuckHunt
-- alberto.ruiz
-- Se agrego condficion del docstatus y u_ruta

-- Modificacion 20-Nov-17 @ Reborn Team Sprint Nach
-- rudi.garcia
-- Se agrego join con la tabla [OSHP] par abtener el tipo de despacho


/*
-- Ejemplo de Ejecucion:
				DECLARE @START_DATE DATETIME = GETDATE()-30
					,@END_DATE DATETIME = GETDATE()
					,@ID INT
				
				EXEC [FERCO].[ERP_SP_INSERT_SALES_ORDER_HEADER] 
					@START_DATE = @START_DATE -- varchar(100)
					,@WAREHOUSE = '01',
					@END_DATE = @END_DATE, -- varchar(100)
					@SEQUENCE = @ID OUTPUT	-- int

				SELECT @ID
				select * from [ferco].[ERP_SALES_ORDER_HEADER_CHANNEL_MODERN] where  [Sequence] = @ID
				delete [ferco].[ERP_SALES_ORDER_HEADER_CHANNEL_MODERN] where  [Sequence] = @ID

*/
-- =============================================
CREATE PROCEDURE [ferco].[ERP_SP_INSERT_SALES_ORDER_HEADER] (@START_DATE VARCHAR(100)
, @END_DATE VARCHAR(100)
, @WAREHOUSE VARCHAR(100)
, @SEQUENCE INT OUTPUT)
AS
BEGIN
  SET NOCOUNT ON;
  --

  
  DECLARE @SQL VARCHAR(4000) = ''
         ,@ID INT
         ,@ONLY_SALES_ORDERS_WITH_SPECIFIC_STATUS_OF_PREPARATION VARCHAR(1) = '0'
          ,@GET_TYPE_OF_DEMAND VARCHAR(1) = '0'
  SELECT
    @ONLY_SALES_ORDERS_WITH_SPECIFIC_STATUS_OF_PREPARATION = ISNULL([P].[VALUE], '0')
  FROM [OP_WMS_FERCO].[FERCO].[OP_WMS_PARAMETER] [P]
  WHERE [P].[GROUP_ID] = 'CLIENT_CONFIGURATIONS'
  AND [P].[PARAMETER_ID] = 'ONLY_SALES_ORDERS_WITH_SPECIFIC_DATA_ON_COLUMN';

 SELECT
    @GET_TYPE_OF_DEMAND = ISNULL([P].[VALUE], '0')
  FROM [OP_WMS_FERCO].[FERCO].[OP_WMS_PARAMETER] [P]
  WHERE [P].[GROUP_ID] = 'PICKING_DEMAND'
  AND [P].[PARAMETER_ID] = 'GET_TYPE_OF_DEMAND'

  INSERT INTO [ferco].[ERP_SALES_ORDER_SEQUENCE_CHANNEL_MODERN] ([StartDate], [EndDate])
    VALUES (
				CAST(@START_DATE AS DATETIME)  -- StartDate - datetime
				,CAST(@END_DATE AS DATETIME)  -- EndDate - datetime
    )
  SELECT
    @ID = SCOPE_IDENTITY()
   ,@SEQUENCE = SCOPE_IDENTITY()

  SELECT
    @SQL = '
		INSERT INTO [ferco].[ERP_SALES_ORDER_HEADER_CHANNEL_MODERN]
		 ([Sequence]
           ,[DocDate]
           ,[DocNum]
           ,[U_Serie]
           ,[U_NoDocto]
           ,[CardCode]
           ,[CardName]
           ,[U_MasterIDCustomer]
           ,[U_OwnerCustomer]
           ,[SlpName]
           ,[U_oper]
           ,[DESCUENTO_FACTURA]
           ,[STATUS]
           ,[Comments]
           ,[DiscPrcnt]
           ,[Address]
           ,[Address2]
           ,[ShipToAddressType]
           ,[ShipToStreet]
           ,[ShipToState]
           ,[ShipToCountry]
           ,[DocEntry]
           ,[SlpCode]
           ,[DocCur]
           ,[DocRate]
           ,[DocDueDate]
           ,[Owner]
           ,[OwnerSlp]
           ,[MasterIdSlp]
           ,[WhsCode]
           ,[DocStatus]
           ,[DocTotal]
           ,[TYPE_DEMAND_CODE]
           ,[TYPE_DEMAND_NAME]
           ,[PROJECT]
           ,[MIN_DAYS_EXPIRATION_DATE]
		   ,[U_estado2]
		   ,[U_Sucursal]
		   ,[Descr]
		   )
		SELECT
			' + CAST(@ID AS VARCHAR) + '
		  ,*
		FROM OPENQUERY([SAPSERVER], ''
		SELECT DISTINCT 
			T0.DocDate,
			T0.DocNum as DocNum,
			'''''''' U_Serie,
			'''''''' U_NoDocto,
			T0.CardCode,
			T0.CardName,
			T0.CardCode U_MasterIDCustomer,
			''''ferco'''' U_OwnerCustomer,
			T2.SlpName,
			'''''''' U_oper,
			CAST(T0.DiscPrcnt AS DECIMAL) / 100 AS DESCUENTO_FACTURA,--T0.DiscPrcnt,
			CASE
			WHEN T0.CANCELED = ''''N'''' THEN ''''FACTURA''''
			WHEN T0.CANCELED = ''''Y'''' THEN ''''ANULADA''''
			END AS STATUS,
			T0.Comments,
			T0.DiscPrcnt,
			T0.Address,
			 CASE WHEN [T5].[Name] IS NOT NULL AND [T3].[CountyS] IS NOT NULL  THEN  [T5].[Name] + '''' '''' + ISNULL([T3].[CountyS] ,'''''''') +'''' '''' + [T0].[Address2]
	   WHEN [T3].[CountyS] IS NOT NULL  THEN  ISNULL([T3].[CountyS] ,'''''''') +'''' '''' + [T0].[Address2]
	   WHEN  [T5].[Name] IS NOT NULL  THEN  ISNULL([T5].[Name] ,'''''''') +'''' '''' + [T0].[Address2]
	   ELSE  [T0].[Address2] END ,
			T3.AddrTypeS AS ShipToAddressType,
			T3.StreetS AS ShipToStreet,
			T3.StateS AS ShipToState,
			T3.CountryS AS ShipToCountry,
			T0.DocEntry,
			T2.SlpCode,
			T0.DocCur,
			T0.DocRate,
			T0.DocDueDate
			, ''''ferco'''' Owner
			, ''''ferco'''' OwnerSlp
			, T2.SlpCode MasterIdSlp
			, CASE WHEN ISNULL(u_bodega_wms, '''''''' ) = '''''''' THEN  T1.WhsCode  ELSE u_bodega_wms END WhsCode
			, T0.DocStatus 
			, T0.[DocTotal] '

      IF @GET_TYPE_OF_DEMAND = '1' BEGIN
      SELECT
      @SQL = @SQL + ' ,[T0].[TrnspCode] [TYPE_DEMAND_CODE]
                      ,[OS].[TrnspName] [TYPE_DEMAND_NAME]
					  ,[T0].[U_Proyecto] [PROJECT]
					  ,0 MIN_DAYS_EXPIRATION_DATE
					  ,T0.U_Estado2
					  ,T0.U_Sucursal
					  ,T4.Descr
					   '
    END
    ELSE BEGIN
      SELECT
      @SQL = @SQL + ' ,0 [TYPE_DEMAND_CODE]
                      ,'''''''' [TYPE_DEMAND_NAME]
					  ,'''''''' [PROJECT] 
					  ,0 MIN_DAYS_EXPIRATION_DATE 
					  ,T0.U_Estado2
					  ,T0.U_Sucursal
					  ,T4.Descr
					   '
    END
      
    SELECT
      @SQL = @SQL +
		' FROM SBOFERCO.dbo.ORDR T0 
				INNER JOIN SBOFERCO.DBO.RDR1 T1 ON T0.DocEntry = T1.DocEntry --AND T0.U_Owner = T1.U_Owner
				INNER JOIN SBOFERCO.DBO.RDR12 T3 ON T0.DocEntry = T3.DocEntry --AND T0.U_Owner = T3.U_Owner
				INNER JOIN SBOFERCO.dbo.OSLP T2 ON [T0].[SlpCode] = [T2].[SlpCode]
				INNER JOIN SBOFERCO.DBO.UFD1 T4 ON T0.U_SUCURSAL = T4.FldValue
				 LEFT JOIN SBOFERCO.dbo.OCST [T5] ON [T3].[CountryS] = [T5].[Country] AND [T3].[StateS] = [T5].[Code]
				'

    IF @GET_TYPE_OF_DEMAND = '1' BEGIN
      SELECT
      @SQL = @SQL + ' INNER JOIN SBOFERCO.[dbo].[OSHP] [OS] ON ([T0].[TrnspCode] = [OS].[TrnspCode]) '
    END

    SELECT
      @SQL = @SQL + 
		'WHERE T0.CANCELED <> ''''C''''
			AND T0.[DocStatus] <> ''''C''''
			AND T0.CardCode  NOT LIKE ''''SO%''''
			--AND T0.[U_Ruta] = ''''Si''''
			--AND T0.[U_consignacion] = ''''No''''
			AND T0.DocDueDate BETWEEN CAST(''''' + @START_DATE + ''''' AS VARCHAR) AND CAST(''''' + @END_DATE + ''''' AS VARCHAR)	
			and CASE WHEN ISNULL(u_bodega_wms, '''''''' ) = '''''''' THEN  T1.WhsCode  ELSE u_bodega_wms END = ''''' + @WAREHOUSE + '''''
			and T4.tableID = ''''ADOC'''' AND T4.FieldID = 12
			'

	  IF @ONLY_SALES_ORDERS_WITH_SPECIFIC_STATUS_OF_PREPARATION = '1'
  BEGIN
    SELECT
      @SQL = @SQL + ' AND T0.U_Estado2 = ''''03'''' '')  '
  END
  ELSE
  BEGIN
    SELECT
      @SQL = @SQL + ' '') '
  END
  

  EXEC (@SQL)

    SELECT
    @SQL = '
		INSERT INTO [ferco].[ERP_SALES_ORDER_HEADER_CHANNEL_MODERN]
		 ([Sequence]
           ,[DocDate]
           ,[DocNum]
           ,[U_Serie]
           ,[U_NoDocto]
           ,[CardCode]
           ,[CardName]
           ,[U_MasterIDCustomer]
           ,[U_OwnerCustomer]
           ,[SlpName]
           ,[U_oper]
           ,[DESCUENTO_FACTURA]
           ,[STATUS]
           ,[Comments]
           ,[DiscPrcnt]
           ,[Address]
           ,[Address2]
           ,[ShipToAddressType]
           ,[ShipToStreet]
           ,[ShipToState]
           ,[ShipToCountry]
           ,[DocEntry]
           ,[SlpCode]
           ,[DocCur]
           ,[DocRate]
           ,[DocDueDate]
           ,[Owner]
           ,[OwnerSlp]
           ,[MasterIdSlp]
           ,[WhsCode]
           ,[DocStatus]
           ,[DocTotal]
           ,[TYPE_DEMAND_CODE]
           ,[TYPE_DEMAND_NAME]
           ,[PROJECT]
           ,[MIN_DAYS_EXPIRATION_DATE]
		   ,[U_estado2]
		   ,[U_Sucursal]
		   ,[Descr]
		   )
		SELECT distinct 
			' + CAST(@ID AS VARCHAR) + '
		  ,*
		FROM OPENQUERY([SAPSERVER], ''
		SELECT DISTINCT 
			T0.DocDate,
			T0.DocNum as DocNum,
			'''''''' U_Serie,
			'''''''' U_NoDocto,
			T0.CardCode,
			T0.CardName,
			T0.CardCode U_MasterIDCustomer,
			''''ALMASA'''' U_OwnerCustomer,
			T2.SlpName,
			'''''''' U_oper,
			CAST(T0.DiscPrcnt AS DECIMAL) / 100 AS DESCUENTO_FACTURA,--T0.DiscPrcnt,
			CASE
			WHEN T0.CANCELED = ''''N'''' THEN ''''FACTURA''''
			WHEN T0.CANCELED = ''''Y'''' THEN ''''ANULADA''''
			END AS STATUS,
			T0.Comments,
			T0.DiscPrcnt,
			T0.Address,
			 CASE WHEN [T5].[Name] IS NOT NULL AND [T3].[CountyS] IS NOT NULL  THEN  [T5].[Name] + '''' '''' + ISNULL([T3].[CountyS] ,'''''''') +'''' '''' + [T0].[Address2]
	   WHEN [T3].[CountyS] IS NOT NULL  THEN  ISNULL([T3].[CountyS] ,'''''''') +'''' '''' + [T0].[Address2]
	   WHEN  [T5].[Name] IS NOT NULL  THEN  ISNULL([T5].[Name] ,'''''''') +'''' '''' + [T0].[Address2]
	   ELSE  [T0].[Address2] END ,
			T3.AddrTypeS AS ShipToAddressType,
			T3.StreetS AS ShipToStreet,
			T3.StateS AS ShipToState,
			T3.CountryS AS ShipToCountry,
			T0.DocEntry,
			T2.SlpCode,
			T0.DocCur,
			T0.DocRate,
			T0.DocDueDate
			, ''''ALMASA'''' Owner
			, ''''ALMASA'''' OwnerSlp
			, T2.SlpCode MasterIdSlp
			,T1.WhsCode
			--, CASE WHEN ISNULL(u_bodega_wms, '''''''' ) = '''''''' THEN  T1.WhsCode  ELSE u_bodega_wms END WhsCode
			, T0.DocStatus 
			, T0.[DocTotal] '

      IF @GET_TYPE_OF_DEMAND = '1' BEGIN
      SELECT
      @SQL = @SQL + ' ,[T0].[TrnspCode] [TYPE_DEMAND_CODE]
						 ,'''''''' [TYPE_DEMAND_NAME]
                      --,[OS].[TrnspName] [TYPE_DEMAND_NAME]
					  ,[T0].[U_Proyecto] [PROJECT]
					  ,0 MIN_DAYS_EXPIRATION_DATE
					  ,T0.U_Estado2
					  ,T0.U_Sucursal
					  ,''''ALMASA'''' Descr
					   '
    END
    ELSE BEGIN
      SELECT
      @SQL = @SQL + ' ,0 [TYPE_DEMAND_CODE]
                      ,'''''''' [TYPE_DEMAND_NAME]
					  ,'''''''' [PROJECT] 
					  ,0 MIN_DAYS_EXPIRATION_DATE 
					  ,T0.U_Estado2
					  ,T0.U_Sucursal
					  ,''''ALMASA'''' Descr
					   '
    END
      
  --  SELECT
  --    @SQL = @SQL +
		--' FROM SBO_ALMASA.dbo.ORDR T0 
		--		INNER JOIN SBO_ALMASA.DBO.RDR1 T1 ON T0.DocEntry = T1.DocEntry --AND T0.U_Owner = T1.U_Owner
		--		INNER JOIN SBO_ALMASA.DBO.RDR12 T3 ON T0.DocEntry = T3.DocEntry --AND T0.U_Owner = T3.U_Owner
		--		INNER JOIN SBO_ALMASA.dbo.OSLP T2 ON [T0].[SlpCode] = [T2].[SlpCode]
		--		INNER JOIN SBO_ALMASA.DBO.UFD1 T4 ON T0.U_SUCURSAL = T4.FldValue
		--		 LEFT JOIN SBO_ALMASA.dbo.OCST [T5] ON [T3].[CountryS] = [T5].[Country] AND [T3].[StateS] = [T5].[Code]
		--		'

  --  IF @GET_TYPE_OF_DEMAND = '1' BEGIN
  --    SELECT
  --    @SQL = @SQL + ' LEFT JOIN SBO_ALMASA.[dbo].[OSHP] [OS] ON ([T0].[TrnspCode] = [OS].[TrnspCode]) '
  --  END

--    SELECT
--      @SQL = @SQL + 
--		'WHERE T0.CANCELED <> ''''C''''
--			AND T0.[DocStatus] <> ''''C''''
--			AND T0.CardCode  NOT LIKE ''''SO%''''
--			--AND T0.[U_Ruta] = ''''Si''''
--			--AND T0.[U_consignacion] = ''''No''''
--			AND T0.DocDueDate BETWEEN CAST(''''' + @START_DATE + ''''' AS VARCHAR) AND CAST(''''' + @END_DATE + ''''' AS VARCHAR)
--			and   T1.WhsCode  = ''''' + @WAREHOUSE + '''''	
			
--			'
--			--and CASE WHEN ISNULL(u_bodega_wms, '''''''' ) = '''''''' THEN  T1.WhsCode  ELSE u_bodega_wms END = ''''' + @WAREHOUSE + '''''

--	  IF @ONLY_SALES_ORDERS_WITH_SPECIFIC_STATUS_OF_PREPARATION = '1'
--  BEGIN
--    SELECT
--      @SQL = @SQL + ' AND T0.U_Estado2 = ''''03'''' '')  '
--  END
--  ELSE
--  BEGIN
--    SELECT
--      @SQL = @SQL + ' '') '
--  END
--EXEC (@SQL)
  
 -- SELECT
 --   @SQL = '
	--	INSERT INTO [ferco].[ERP_SALES_ORDER_HEADER_CHANNEL_MODERN]
	--	SELECT
	--		' + CAST(@ID AS VARCHAR) + '
	--	  ,*
	--	FROM OPENQUERY([SAPSERVER], ''
	--	SELECT DISTINCT 
	--		T0.DocDate,
	--		T0.DocNum as DocNum,
	--		'''''''' U_Serie,
	--		'''''''' U_NoDocto,
	--		T0.CardCode,
	--		T0.CardName,
	--		T0.CardCode U_MasterIDCustomer,
	--		''''DETALLES'''' U_OwnerCustomer,
	--		T2.SlpName,
	--		'''''''' U_oper,
	--		CAST(T0.DiscPrcnt AS DECIMAL) / 100 AS DESCUENTO_FACTURA,--T0.DiscPrcnt,
	--		CASE
	--		WHEN T0.CANCELED = ''''N'''' THEN ''''FACTURA''''
	--		WHEN T0.CANCELED = ''''Y'''' THEN ''''ANULADA''''
	--		END AS STATUS,
	--		T0.Comments,
	--		T0.DiscPrcnt,
	--		T0.Address,
	--		T0.Address2,
	--		T3.AddrTypeS AS ShipToAddressType,
	--		T3.StreetS AS ShipToStreet,
	--		T3.StateS AS ShipToState,
	--		T3.CountryS AS ShipToCountry,
	--		T0.DocEntry,
	--		T2.SlpCode,
	--		T0.DocCur,
	--		T0.DocRate,
	--		T0.DocDueDate
	--		, ''''DETALLES'''' Owner
	--		, ''''DETALLES'''' OwnerSlp
	--		, T2.SlpCode MasterIdSlp
	--		,T1.WhsCode  
	--		, T0.DocStatus 
	--		, T0.[DocTotal]
	--		,0 [TYPE_DEMAND_CODE]
 --           ,'''''''' [TYPE_DEMAND_NAME]
	--		,'''''''' [PROJECT]  
	--		,0 MIN_DAYS_EXPIRATION_DATE 
	--		 FROM SBOFERCO.dbo.ORDR T0 
	--			INNER JOIN SBOFERCO.DBO.RDR1 T1 ON T0.DocEntry = T1.DocEntry --AND T0.U_Owner = T1.U_Owner
	--			INNER JOIN SBOFERCO.DBO.RDR12 T3 ON T0.DocEntry = T3.DocEntry --AND T0.U_Owner = T3.U_Owner
	--			INNER JOIN SBOFERCO.dbo.OSLP T2 ON [T0].[SlpCode] = [T2].[SlpCode]
				
	--		WHERE T0.CANCELED <> ''''C''''
	--		AND T0.[DocStatus] <> ''''C''''
	--		AND T0.CardCode  NOT LIKE ''''SO%''''
	--		--AND T0.[U_Ruta] = ''''Si''''
	--		--AND T0.[U_consignacion] = ''''No''''
	--		AND T0.DocDueDate BETWEEN CAST(''''' + @START_DATE + ''''' AS VARCHAR) AND CAST(''''' + @END_DATE + ''''' AS VARCHAR)	
	--		and   T1.WhsCode  = ''''' + @WAREHOUSE + '''''
	--		'')
	--		'
	--PRINT('SQL: ' + @SQL)	
  
 -- EXEC (@SQL)

  
 -- SELECT
 --   @SQL = '
	--	INSERT INTO [ferco].[ERP_SALES_ORDER_HEADER_CHANNEL_MODERN]
	--	SELECT
	--		' + CAST(@ID AS VARCHAR) + '
	--	  ,*
	--	FROM OPENQUERY([SAPSERVER], ''
	--	SELECT DISTINCT 
	--		T0.DocDate,
	--		T0.DocNum as DocNum,
	--		'''''''' U_Serie,
	--		'''''''' U_NoDocto,
	--		T0.CardCode,
	--		T0.CardName,
	--		T0.CardCode U_MasterIDCustomer,
	--		''''VOI7'''' U_OwnerCustomer,
	--		T2.SlpName,
	--		'''''''' U_oper,
	--		CAST(T0.DiscPrcnt AS DECIMAL) / 100 AS DESCUENTO_FACTURA,--T0.DiscPrcnt,
	--		CASE
	--		WHEN T0.CANCELED = ''''N'''' THEN ''''FACTURA''''
	--		WHEN T0.CANCELED = ''''Y'''' THEN ''''ANULADA''''
	--		END AS STATUS,
	--		T0.Comments,
	--		T0.DiscPrcnt,
	--		T0.Address,
	--		T0.Address2,
	--		T3.AddrTypeS AS ShipToAddressType,
	--		T3.StreetS AS ShipToStreet,
	--		T3.StateS AS ShipToState,
	--		T3.CountryS AS ShipToCountry,
	--		T0.DocEntry,
	--		T2.SlpCode,
	--		T0.DocCur,
	--		T0.DocRate,
	--		T0.DocDueDate
	--		, ''''VOI7'''' Owner
	--		, ''''VOI7'''' OwnerSlp
	--		, T2.SlpCode MasterIdSlp
	--		,T1.WhsCode  
	--		, T0.DocStatus 
	--		, T0.[DocTotal]
	--		,0 [TYPE_DEMAND_CODE]
 --           ,'''''''' [TYPE_DEMAND_NAME]
	--		,'''''''' [PROJECT]  
	--		,0 MIN_DAYS_EXPIRATION_DATE 
	--		 FROM SBOFERCO.dbo.ORDR T0 
	--			INNER JOIN SBOFERCO.DBO.RDR1 T1 ON T0.DocEntry = T1.DocEntry --AND T0.U_Owner = T1.U_Owner
	--			INNER JOIN SBOFERCO.DBO.RDR12 T3 ON T0.DocEntry = T3.DocEntry --AND T0.U_Owner = T3.U_Owner
	--			INNER JOIN SBOFERCO.dbo.OSLP T2 ON [T0].[SlpCode] = [T2].[SlpCode]
				
	--		WHERE T0.CANCELED <> ''''C''''
	--		AND T0.[DocStatus] <> ''''C''''
	--		AND T0.CardCode  NOT LIKE ''''SO%''''
	--		--AND T0.[U_Ruta] = ''''Si''''
	--		--AND T0.[U_consignacion] = ''''No''''
	--		AND T0.DocDueDate BETWEEN CAST(''''' + @START_DATE + ''''' AS VARCHAR) AND CAST(''''' + @END_DATE + ''''' AS VARCHAR)	
	--		and   T1.WhsCode  = ''''' + @WAREHOUSE + '''''
	--		'')
	--		'
	--PRINT('SQL: ' + @SQL)	
  
 -- EXEC (@SQL)


  RETURN;
END