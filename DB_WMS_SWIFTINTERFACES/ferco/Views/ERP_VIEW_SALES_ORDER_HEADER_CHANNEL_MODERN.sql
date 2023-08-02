
-- =============================================
-- Autor:                hector.gonzalez
-- Fecha de Creacion:   2017-01-13 TeamErgon Sprint 1
-- Description:          Vista que trae el encabezado de las ordenes de venta del canal moderno de sap

-- Modificacion 8/8/2017 @ NEXUS-Team Sprint Banjo-Kazooie
-- rodrigo.gomez
-- Se agregaron las columnas SAPSERVER

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM ferco.ERP_VIEW_SALES_ORDER_HEADER_CHANNEL_MODERN
          
*/
-- =============================================
CREATE VIEW ferco.ERP_VIEW_SALES_ORDER_HEADER_CHANNEL_MODERN
AS
SELECT
  *
FROM OPENQUERY([SAPSERVER], '
SELECT DISTINCT
T0.DocDate,
T0.DocNum as DocNum,

  --,T0.U_Serie
   0 U_Serie,
--T0.U_NoDocto,
  '''' U_NoDocto,
T0.CardCode,
T0.CardName,
T0.CardCode U_MasterIDCustomer,
''ferco'' U_OwnerCustomer,
T2.SlpName,
'''' U_oper,
  --T0.U_oper,
CAST(T0.DiscPrcnt AS DECIMAL) / 100 AS DESCUENTO_FACTURA,--T0.DiscPrcnt,
CASE
WHEN T0.CANCELED = ''N'' THEN ''FACTURA''
WHEN T0.CANCELED = ''Y'' THEN ''ANULADA''
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
''ferco'' Owner,
''ferco'' OwnerSlp,
T2.SlpCode MasterIdSlp
FROM SBOFERCO.dbo.ORDR T0 
INNER JOIN SBOFERCO.dbo.RDR1 T1 ON T0.DocEntry = T1.DocEntry
INNER JOIN SBOFERCO.dbo.RDR12 T3 ON T0.DocEntry = T3.DocEntry
INNER JOIN SBOFERCO.dbo.OSLP T2 ON T0.SlpCode = T2.SlpCode
WHERE T0.CANCELED <> ''C''
AND T0.CardCode  NOT LIKE ''SO%''
')
