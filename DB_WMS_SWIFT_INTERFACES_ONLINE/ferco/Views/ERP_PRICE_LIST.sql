
CREATE VIEW [ferco].[ERP_PRICE_LIST]
as 
select * from openquery (SAPSERVER,'SELECT
   cast(p.ListNum as varchar)  as CODE_PRICE_LIST 
   ,p.LIstName as NAME_PRICE_LIST 
   , ''--'' COMMENT 
   , P.UpdateDate LAST_UPDATE  
   , ''SboIterfaces'' LAST_UPDATE_BY  
   ,CAST(NULL AS VARCHAR) AS [OWNER]
	,CAST(NULL AS VARCHAR) COLLATE SQL_Latin1_General_CP1_CI_AS AS [OWNER_ID] 
FROM  [SBOFERCO].dbo.OPLN AS p ')