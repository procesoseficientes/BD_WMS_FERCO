


-- =============================================
--  Autor:		joel.delcompare
-- Fecha de Creacion: 	2016-02-26 16:08:17
-- Description:		Obitene los grupos de los productos


/*
-- Ejemplo de Ejecucion:
    USE SWIFT_INTERFACES_ONLINE
    GO
    
     SELECT  * FROM  ferco.ERP_VIEW_SKU_FAMILY
GO
*/
-- =============================================
CREATE VIEW [ferco].[ERP_VIEW_SKU_FAMILY]
AS
  
  SELECT 
  *
FROM (SELECT * FROM OPENQUERY(SAPSERVER,'      
select 
ItmsGrpCod AS CODE_FAMILY_SKU ,
ItmsGrpNam AS DESCRIPTION_FAMILY_SKU,
ItmsGrpCod AS [ORDER],
GETDATE() as LAST_UPDATE ,
''BULK_DATA'' AS   LAST_UPDATE_BY
 from SBOFERCO.dbo.OITB
 Where "Locked" =''N''
  ')) as sr