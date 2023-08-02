-- =============================================
-- Autor:				Gustavo.García
-- Fecha de Creacion: 	2020/06/23 @  Sprint Junio3
-- Description:			Inserta las ordenes de entrega en ERP_DELIVERY_ORDER_HEADER y devuelve el ID de secuencia.

/*
-- Ejemplo de Ejecucion:
				DECLARE @START_DATE DATETIME = GETDATE()-180
					,@END_DATE DATETIME = GETDATE()
					,@ID INT
				
				EXEC [FERCO].[ERP_SP_INSERT_DELIVERY_ORDER_HEADER] 
					@START_DATE = @START_DATE -- varchar(100)
					,@WAREHOUSE = '01',
					@END_DATE = @END_DATE, -- varchar(100)
					@SEQUENCE = @ID OUTPUT	-- int

				SELECT @ID
				select * from [ferco].[ERP_DELIVERY_ORDER_HEADER] where  [Sequence] = @ID
				delete [ferco].[ERP_DELIVERY_ORDER_HEADER] where  [Sequence] = @ID

*/
-- =============================================
CREATE PROCEDURE [ferco].[ERP_SP_INSERT_DELIVERY_ORDER_HEADER] (@START_DATE VARCHAR(100)
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

  INSERT INTO [ferco].[ERP_DELIVERY_ORDER_SEQUENCE] ([StartDate], [EndDate])
    VALUES (
				CAST(@START_DATE AS DATETIME)  -- StartDate - datetime
				,CAST(@END_DATE AS DATETIME)  -- EndDate - datetime
    )
  SELECT
    @ID = SCOPE_IDENTITY()
   ,@SEQUENCE = SCOPE_IDENTITY()

  SELECT
    @SQL = '
		INSERT INTO [ferco].[ERP_DELIVERY_ORDER_HEADER]
		 ([Sequence]
           ,[DocDate]
           ,[DocNum]
				, [BASE_REF]
				, [BASE_ENTRY]
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
		   ,[Descr])
		SELECT
			' + CAST(@ID AS VARCHAR) + '
		  ,*
		FROM OPENQUERY([SAPSERVER], ''
		SELECT DISTINCT 
			T0.DocDate,
			T0.DocEntry as DocNum,
			[T1].[BaseRef]
			,[T1].[BaseENtry],
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
					  ,T4.Descr '
    END
    ELSE BEGIN
      SELECT
      @SQL = @SQL + ' ,0 [TYPE_DEMAND_CODE]
                      ,'''''''' [TYPE_DEMAND_NAME]
					  ,'''''''' [PROJECT] 
					  ,0 MIN_DAYS_EXPIRATION_DATE
					  ,T4.Descr '
    END
      
    SELECT
      @SQL = @SQL +
		' FROM [SBOPruebas].dbo.ODRF T0 
				INNER JOIN [SBOPruebas].DBO.DRF1 T1 ON T0.DocEntry = T1.DocEntry --AND T0.U_Owner = T1.U_Owner
				INNER JOIN [SBOPruebas].DBO.DRF12 T3 ON T0.DocEntry = T3.DocEntry --AND T0.U_Owner = T3.U_Owner
				INNER JOIN [SBOPruebas].dbo.OSLP T2 ON [T0].[SlpCode] = [T2].[SlpCode]
				INNER JOIN [SBOPruebas].[DBO].[UFD1] T4 ON T0.U_SUCURSAL = T4.FldValue
				 LEFT JOIN [SBOPruebas].dbo.OCST [T5] ON [T3].[CountryS] = [T5].[Country] AND [T3].[StateS] = [T5].[Code]
				'

    IF @GET_TYPE_OF_DEMAND = '1' BEGIN
      SELECT
      @SQL = @SQL + ' INNER JOIN [SBOPruebas].[dbo].[OSHP] [OS] ON ([T0].[TrnspCode] = [OS].[TrnspCode]) '
    END

    SELECT
      @SQL = @SQL + 
		'WHERE T0.CANCELED <> ''''C''''
			AND T0.[DocStatus] <> ''''C''''
			AND T0.DocDueDate BETWEEN CAST(''''' + @START_DATE + ''''' AS VARCHAR) AND CAST(''''' + @END_DATE + ''''' AS VARCHAR)	
			and CASE WHEN ISNULL(u_bodega_wms, '''''''' ) = '''''''' THEN  T1.WhsCode  ELSE u_bodega_wms END = ''''' + @WAREHOUSE + '''''
			and t1.[BaseRef] is not null
			AND T4.tableID = ''''ADOC'''' 
			AND T4.FieldID = 12
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
  print @SQL;
  EXEC (@SQL)
  RETURN;
END