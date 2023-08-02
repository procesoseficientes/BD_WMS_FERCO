-- =============================================
--  Autor:		joel.delcompare
-- Fecha de Creacion: 	2016-02-27 13:23:47
-- Description:		OBTIENE LAS UNIDADES DE CONVERSION 


/*
-- Ejemplo de Ejecucion:

USE SWIFT_INTERFACES_ONLINE
GO

SELECT
  CODE_SKU
 ,CODE_PACK_UNIT_FROM
 ,CODE_PACK_UNIT_TO
 ,CONVERSION_FACTOR
 ,LAST_UPDATE
 ,LAST_UPDATE_BY
 ,[ORDER]
FROM ferco.ERP_PACK_CONVERSION;
GO

*/
-- =============================================

CREATE VIEW ferco.ERP_PACK_CONVERSION
AS

SELECT
    CODE_SKU
   ,CODE_PACK_UNIT_FROM
   ,CODE_PACK_UNIT_TO
   ,CONVERSION_FACTOR
   ,GETDATE() LAST_UPDATE
   ,'BULK_DATA' LAST_UPDATE_BY
   ,ROW_NUMBER() OVER (PARTITION BY CODE_SKU ORDER BY CONVERSION_FACTOR DESC) [ORDER]
  FROM OPENQUERY(SAPSERVER, 'SELECT              
    itm.ItemCode CODE_SKU
    , uom.UomCode CODE_PACK_UNIT_FROM   
    , uom2.UomCode CODE_PACK_UNIT_TO 
    ,CAST( gp1.AltQty / gp1.BaseQty AS NUMERIC(18,6)) CONVERSION_FACTOR     
    FROM SBOFERCO.dbo.UGP1 gp1  inner join SBOFERCO.dbo.OUOM uom       
    on uom.UomEntry = gp1.UomEntry
    inner join SBOFERCO.dbo.OITM  itm
    on gp1.UgpEntry = itm.UgpEntry
    inner join (select  min(LineNum) LineNum , UgpEntry from SBOFERCO.dbo.UGP1 group by UgpEntry )  minuom
    on minuom.UgpEntry = gp1.UgpEntry
    inner join SBOFERCO.dbo.UGP1 gp2 
    on gp2.LineNum = minuom.LineNum and gp2.UgpEntry = minuom.UgpEntry
    inner join SBOFERCO.dbo.OUOM uom2
    on uom2.UomEntry = gp2.UomEntry  
    WHERE itm.SellItem = ''Y''    
    Order by  itm.ItemCode, gp1.UgpEntry , gp1.LineNum

    '
  )