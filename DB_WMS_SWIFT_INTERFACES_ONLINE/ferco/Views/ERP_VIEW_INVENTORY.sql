



-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	16-12-2015
-- Description:			Vista que obtiene detalles de bodegas 

/*
-- Ejemplo de Ejecucion:
				DROP VIEW [ferco].[ERP_VIEW_INVENTORY]
*/
-- =============================================

CREATE VIEW [ferco].[ERP_VIEW_INVENTORY]
as 
select * from openquery (SAPSERVER,'SELECT   
          NULL             AS SERIAL_NUMBER
         ,OITWS.[WhsCode]  COLLATE database_default  AS WAREHOUSE
		 ,OITWS.[WhsCode]  COLLATE database_default  AS LOCATION
		 ,OITMS.[ItemCode]  COLLATE database_default AS SKU
		 ,OITMS.[ItemName] COLLATE database_default  AS SKU_DESCRIPTION
		 ,OITWS.[OnHand]     AS ON_HAND
         ,NULL             AS BATCH_ID
		 ,GETDATE()        AS LAST_UPDATE
		 ,''BULK_DATA''    AS LAST_UPDATE_BY
         ,9999             AS TXN_ID
		 ,0                AS IS_SCANNED
         ,NULL             AS RELOCATED_DATE
  FROM [SBOFERCO].[dbo].[OITW] AS OITWS INNER JOIN
       [SBOFERCO].[dbo].[OITM] AS OITMS ON OITMS.[ItemCode] = OITWS.[ItemCode] ')