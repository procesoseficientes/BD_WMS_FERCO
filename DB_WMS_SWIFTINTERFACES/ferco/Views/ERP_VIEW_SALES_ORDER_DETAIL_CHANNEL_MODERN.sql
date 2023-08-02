
-- =============================================
-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	2017-01-13 TeamErgon Sprint 1
-- Description:			    Vista que trae el detalle de las ordenes de venta del canal moderno de sap

-- Modificacion 8/8/2017 @ NEXUS-Team Sprint Banjo-Kazooie
-- rodrigo.gomez
-- Se agregaron las columnas de SAPSERVER.

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [ferco].[ERP_VIEW_SALES_ORDER_DETAIL_CHANNEL_MODERN]
					
*/
-- =============================================
CREATE VIEW ferco.ERP_VIEW_SALES_ORDER_DETAIL_CHANNEL_MODERN
AS

SELECT
  *
FROM OPENQUERY([SAPSERVER], '
SELECT DISTINCT
  T0.DocEntry,T0.[DocDate]
 ,T0.[DOCNUM] 
  --,T0.U_Serie
  , 0 U_Serie
  --,T0.U_NoDocto
  ,'''' U_NoDocto
 ,T0.[CardCode]
 ,T0.[CardName]
 ,A.SLPNAME
  --,T0.U_OPER
 ,'''' U_OPER
 ,T1.[ItemCode] 
 ,T1.[Dscription]
,[T1].ItemCode [U_MasterIdSKU]
,''ferco'' [U_OwnerSKU]
 ,CASE
    WHEN T0.CANCELED = ''N'' THEN T1.[Quantity]
    WHEN T0.CANCELED = ''Y'' THEN 0
  END AS ''Quantity''
 ,CASE
    WHEN T0.CANCELED = ''N'' THEN T1.[PriceAfVAT]
    WHEN T0.CANCELED = ''Y'' THEN 0
  END AS ''PRECIO_CON_IVA''
 ,CASE
    WHEN T0.CANCELED = ''N'' THEN (T1.quantity * T1.[PriceAfVAT])
    WHEN T0.CANCELED = ''Y'' THEN 0
  END AS ''TOTAL_LINEA_SIN_DESCUENTO''
 ,CASE
    WHEN T0.CANCELED = ''N'' THEN (T1.quantity * T1.[PriceAfVAT]) - ((T1.quantity * T1.[PriceAfVAT]) * (T0.[DiscPrcnt] / 100))
    WHEN T0.CANCELED = ''Y'' THEN 0
  END AS ''TOTAL_LINEA_CON_DESCUENTO_APLICADO''
 ,T1.WhsCode
 ,CAST(T0.[DiscPrcnt] AS DECIMAL) / 100 AS ''DESCUENTO_FACTURA''
 ,CASE
    WHEN T0.CANCELED = ''N'' THEN ''FACTURA''
    WHEN T0.CANCELED = ''Y'' THEN ''ANULADA''
  END AS ''STATUS''
 ,T1.LINENUM + 1 AS ''NUMERO_LINEA''
 ,T0.[CardCode] [U_MasterIDCustomer]
,''ferco'' [U_OwnerCustomer]
,''ferco'' [Owner]
FROM SBOFERCO.dbo.ORDR T0--ENCABEZADO OV
INNER JOIN SBOFERCO.dbo.RDR1 T1
  ON T0.[DocEntry] = T1.[DocEntry]-- DETALLE OV
LEFT JOIN SBOFERCO.dbo.OSLP A ON T0.SlpCode = A.SlpCode--EMPLEADOS DE VENTAS
WHERE T0.CANCELED <> ''C''
AND T0.CardCode NOT LIKE ''SO%''
  ')

