
-- =============================================
-- Autor:				joel.delcompare
-- Fecha de Creacion: 	11-09-2015
-- Description:			Vista que obtiene los clientes de sap

-- Modificacion 11-09-2015
-- joel.delcompare
-- se cambio el SELLER_DEFAULT_CODE por el codigo del vendedor  dado que estaba usando el nombre 
-- Modificacion 23-01-2016
-- alberto.ruiz
-- Se agregaron los campos de latitud, longitud, frecuancia y dias de visita
--,/*c.CreditLine*/99999 AS CREDIT_LIMIT     sustituir para regresar la vista a su estado normal
-- Modificacion 06-04-2016
-- hector.gonzalez
-- Se agrego el campo "Discount" de la tabla "OCRD" con el alias de "DISCOUNT".
-- Modificado 2016-05-02
-- joel.delcompare
-- Se agregaron los campos U_RTOfiVentas                                U_RTRutaVentas                               U_RTRutaEntrega                               U_RTSecuencia 
-- Modificacion 01-08-2016  
-- alberto.ruiz
-- Se agrego isnull al nombre del cliente

-- Modificacion 27-11-2016  
-- hector.gonzalez
-- Se agrego la columna itemCode

-- Modificacion 28-Feb-17 @ A-Team Sprint Donkor
-- alberto.ruiz
-- Se agregaron los campos de organizacion de ventas y payment_conditions

-- Modificacion 8/31/2017 @ Reborn-Team Sprint Collin
-- diego.as
-- Se agrega columna VatIdUnCmp con el alias CODE_CUSTOMER_ALTERNATE

/*
-- Ejemplo de Ejecucion:
		--
        SELECT * FROM [ferco].[ERP_VIEW_COSTUMER] WHERE CODE_CUSTOMER = '2324'
*/
--================U_RTRutaVentas ===============
CREATE VIEW ferco.ERP_VIEW_COSTUMER
AS
SELECT
  *
FROM OPENQUERY(SAPSERVER, '
  SELECT 
    c.CardCode COLLATE SQL_Latin1_General_CP1_CI_AS AS CUSTOMER
    ,c.CardCode COLLATE SQL_Latin1_General_CP1_CI_AS AS CODE_CUSTOMER
    ,ISNULL(c.CardName,''NA'') COLLATE SQL_Latin1_General_CP1_CI_AS AS NAME_CUSTOMER
    ,c.Phone1 COLLATE SQL_Latin1_General_CP1_CI_AS AS PHONE_CUSTOMER
    ,c.Address COLLATE SQL_Latin1_General_CP1_CI_AS AS ADRESS_CUSTOMER
    , ''7'' AS CLASSIFICATION_CUSTOMER
    ,c.CntctPrsn COLLATE SQL_Latin1_General_CP1_CI_AS AS CONTACT_CUSTOMER
    ,cast(NULL as varchar) AS CODE_ROUTE
    ,c.UpdateDate AS LAST_UPDATE
    ,CAST(c.UserSign AS VARCHAR) AS LAST_UPDATE_BY
    ,cast(vendedores.SlpCode as varchar) COLLATE SQL_Latin1_General_CP1_CI_AS AS SELLER_DEFAULT_CODE
    ,99999 AS CREDIT_LIMIT
	, 1 AS FROM_ERP 
    ,CAST(null as varchar) NAME_ROUTE
    ,CAST(null as varchar) NAME_CLASSIFICATION
    ,ISNULL(0,0) LATITUDE
    ,ISNULL(0,0) LONGITUDE
    ,ISNULL(0,0) FREQUENCY
    ,ISNULL(''0'','''') SUNDAY
    ,ISNULL(''0'','''') MONDAY
    ,ISNULL(''0'','''') TUESDAY
    ,ISNULL(''0'','''') WEDNESDAY
    ,ISNULL(''0'','''') THURSDAY
    ,ISNULL(''0'','''') FRIDAY
    ,ISNULL(''0'','''') SATURDAY
    ,ISNULL('''','''') SCOUTING_ROUTE
    ,cp.GroupNum AS GROUP_NUM
    ,0 AS EXTRA_DAYS
    ,0 AS EXTRA_MONT
	,c.Discount AS DISCOUNT
    ,CAST('''' AS VARCHAR(50)) AS OFICINA_VENTAS
    ,CAST('''' AS VARCHAR(50)) AS RUTA_VENTAS
    ,CAST('''' AS VARCHAR(50)) AS RUTA_ENTREGA
    ,CAST(''0'' AS VARCHAR(50)) AS SECUENCIA
    ,equipo.itemCode AS RGA_CODE 
	,CAST(NULL AS VARCHAR(250)) AS [PAYMENT_CONDITIONS]
	,CAST(NULL AS VARCHAR(250)) AS [ORGANIZACION_VENTAS]	
	,CAST(''ferco'' AS VARCHAR) AS OWNER
	,c.CardCode COLLATE SQL_Latin1_General_CP1_CI_AS AS OWNER_ID
	,c.Balance
	,c.AddId TAX_ID
	,c.[CardFName] INVOICE_NAME
	,c.VatIdUnCmp CODE_CUSTOMER_ALTERNATE
  FROM [SBOFERCO].dbo.OCRD AS c 
  LEFT OUTER JOIN [SBOFERCO].dbo.OSLP AS vendedores ON c.SlpCode = vendedores.SlpCode
  LEFT OUTER JOIN [SBOFERCO].dbo.OCTG AS cp ON c.GroupNum = cp.GroupNum
  LEFT OUTER JOIN [SBOFERCO].dbo.OINS AS equipo ON equipo.Customer = c.CardCode and equipo.status = ''A''
  WHERE 
    (vendedores.Active = ''Y'') 
    AND (c.CardCode <> ''ANULADO'') 
    AND (c.CardType = ''C'')    
')

