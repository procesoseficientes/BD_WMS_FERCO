-- =============================================
--  Autor:		joel.delcompare
-- Fecha de Creacion: 	2016-04-14 02:12:43
-- Description:		Obtiene las unidades de medida que maneja el ERP


/*
-- Ejemplo de Ejecucion:
USE SWIFT_INTERFACES_ONLINE
GO

SELECT
  CODE_PACK_UNIT
 ,DESCRIPTION_PACK_UNIT
 ,LAST_UPDATE
 ,LAST_UPDATE_BY
 ,UM_ENTRY
FROM ferco.ERP_PACK_UNIT;
GO
*/	
-- =============================================
CREATE VIEW ferco.ERP_PACK_UNIT
  AS 
SELECT
    CODE_PACK_UNIT
   ,DESCRIPTION_PACK_UNIT
   ,GETDATE() LAST_UPDATE
   ,'BULK_DATA' LAST_UPDATE_BY
   ,UM_ENTRY
  FROM OPENQUERY(SAPSERVER, 'SELECT  
     "UomCode" CODE_PACK_UNIT
    ,"UomName" DESCRIPTION_PACK_UNIT
    ,"UomEntry" UM_ENTRY   
   FROM SBOFERCO.DBO.OUOM ')