-- =============================================
-- Autor:				Gildardo.Alvarado
-- Fecha de Creacion: 	16/01/2021 @ProcesosEficientes
-- Description:			Inserta las ordenes de venta (Dilevery Order ) en ERP_DELIVERY_ORDER_HEADER y devuelve el ID de secuencia para el reporte de trazabilidad.
--						Se agrego la columna 'U_estado2'

-- Autor:				Gildardo.Alvarado
-- Fecha de Creacion: 	25/01/2021 @ProcesosEficientes
-- Description:			Se agrego la columna 'U_estado2'


-- Autor:				Thomas.Pamal
-- Fecha de Creacion:   16/06/2021 @Procesos eficientes 
-- Description:			Se corrigió la variable [U_estado2]

/*
-- Ejemplo de Ejecucion:
				DECLARE @START_DATE DATETIME = GETDATE()
					,@END_DATE DATETIME = DATEADD(d,-1,GETDATE())
					,@ID INT
				
				EXEC [ferco].[ERP_SP_INSERT_DELIVERY_ORDER_HEADER_FOR_REPORT] 
					@START_DATE = @START_DATE, -- varchar(100)
					@END_DATE = @END_DATE, -- varchar(100)
					@SEQUENCE = @ID OUTPUT	-- int

				SELECT @ID
*/
-- =============================================

CREATE PROCEDURE [ferco].[ERP_SP_INSERT_DELIVERY_ORDER_HEADER_FOR_REPORT] (@START_DATE VARCHAR(100)
, @END_DATE VARCHAR(100)
, @SEQUENCE INT OUTPUT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @SQL VARCHAR(4000) = ''
         ,@ID INT
  --
  INSERT INTO [ferco].[ERP_DELIVERY_ORDER_SEQUENCE] ([StartDate], [EndDate])
    VALUES (@START_DATE  -- StartDate - datetime
    , @END_DATE  -- EndDate - datetime
    )
  --
  SELECT
    @ID = SCOPE_IDENTITY()
   ,@SEQUENCE = SCOPE_IDENTITY()
  --
  SELECT
    @SQL = '
		INSERT INTO [ferco].[ERP_DELIVERY_ORDER_HEADER]
		(
			[Sequence]
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
			,[U_estado2]
			,[MIN_DAYS_EXPIRATION_DATE]
		)
		SELECT
			' + CAST(@ID AS VARCHAR) + '
		  ,*
		FROM OPENQUERY([SAPSERVER], ''
		SELECT DISTINCT 
			T0.DocDate,
			T0.DocNum as DocNum,
			'''''''' U_Serie, --T0.U_Serie,
			'''''''' U_NoDocto, --T0.U_NoDocto,
			T0.CardCode,
			T0.CardName,
			T0.CardCode U_MasterIDCustomer,
			''''ferco'''' U_OwnerCustomer,
			T2.SlpName,
			'''''''' U_oper, --T0.U_oper,
			CAST(T0.DiscPrcnt AS DECIMAL) / 100 AS DESCUENTO_FACTURA,--T0.DiscPrcnt,
			CASE
			WHEN T0.CANCELED = ''''N'''' THEN ''''NO''''
			WHEN T0.CANCELED = ''''Y'''' THEN ''''SI''''
			END AS STATUS,
			T0.Comments,
			T0.DiscPrcnt,
			T0.Address,
			T0.Address2,
			T3.AddrTypeS AS ShipToAddressType,
			T3.StreetS AS ShipToStreet,
			T3.StateS AS ShipToState,
			T3.CountryS AS ShipToCountry,
			T0.DocEntry,
			T2.SlpCode,
			T0.DocCur,
			T0.DocRate,
			T0.DocDueDate,
			''''ferco'''' Owner,
			''''ferco'''' OwnerSlp,
			T2.SlpCode MasterIdSlp
			,T1.WhsCode
			,T0.[DocStatus]
			,T0.[DocTotal]
			, T4.TrnspCode
			,T4.TrnspName
			,[T0].[U_Proyecto] [PROJECT]
			,[T0].[U_estado2]
			,0 [MIN_DAYS_EXPIRATION_DATE]
		FROM SBOFERCO.dbo.ODRF T0 
			INNER JOIN SBOFERCO.dbo.DRF1 T1 ON T0.DocEntry = T1.DocEntry
			INNER JOIN SBOFERCO.dbo.DRF12 T3 ON T0.DocEntry = T3.DocEntry
			INNER JOIN SBOFERCO.dbo.OSLP T2 ON T0.SlpCode = T2.SlpCode
			LEFT JOIN SBOFERCO.dbo.OSHP T4 ON T0.TrnspCode = T4.TrnspCode
			INNER JOIN SBOFERCO.[dbo].[OSHP] [OS] ON ([T0].[TrnspCode] = [OS].[TrnspCode]) 
		WHERE T0.DocDueDate BETWEEN CAST(''''' + @START_DATE + ''''' AS VARCHAR) AND CAST(''''' + @END_DATE + ''''' AS VARCHAR)
			
	'')	'
  --
  PRINT (@SQL)
  --
  EXEC (@SQL)
  --
  RETURN;
END
