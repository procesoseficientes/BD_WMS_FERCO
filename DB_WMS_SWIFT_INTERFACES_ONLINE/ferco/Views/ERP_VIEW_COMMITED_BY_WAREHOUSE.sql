


-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	15-12-2015
-- Description:			Vista que obtiene detalles de bodegas 

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [ferco].[ERP_VIEW_COMMITED_BY_WAREHOUSE]
*/
-- =============================================

CREATE VIEW [ferco].[ERP_VIEW_COMMITED_BY_WAREHOUSE]
as 
select * from openquery (SAPSERVER,'SELECT  
	[ItemCode] COLLATE database_default as CODE_SKU
   ,[WhsCode] COLLATE database_default as CODE_WAREHOUSE 
   ,[IsCommited] as IS_COMMITED 
FROM [SBOFERCO].[dbo].[OITW] ')