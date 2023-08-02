


CREATE VIEW [ferco].[ERP_VIEW_PROVIDERS]
AS

select *from openquery (SAPSERVER,'SELECT     CardCode COLLATE SQL_Latin1_General_CP1_CI_AS AS PROVIDER, CardCode COLLATE SQL_Latin1_General_CP1_CI_AS AS CODE_PROVIDER, 
                      CardName COLLATE SQL_Latin1_General_CP1_CI_AS AS NAME_PROVIDER, cast(NULL as varchar) AS CLASSIFICATION_PROVIDER, CntctPrsn COLLATE SQL_Latin1_General_CP1_CI_AS AS CONTACT_PROVIDER, 
                      1 AS FROM_ERP,CAST(null as varchar)  NAME_CLASSIFICATION 
FROM         [SBOFERCO].dbo.OCRD AS c
WHERE     (CardType = ''S'')')