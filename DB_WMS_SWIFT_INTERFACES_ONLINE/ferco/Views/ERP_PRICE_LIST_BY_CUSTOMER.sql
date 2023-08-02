
CREATE VIEW [ferco].[ERP_PRICE_LIST_BY_CUSTOMER]
AS 
select * from openquery (SAPSERVER,'
select
 CAST(ListNum AS varchar) as code_price_list
 , CardCode COLLATE database_default as CODE_CUSTOMER  
 ,CAST(''ferco'' AS VARCHAR(50)) [OWNER]
 from [SBOFERCO].dbo.OCRD  
 WHERE ListNum>0
 ')