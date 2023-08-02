-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		09-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
-- Description:			    Ajuste por intercompany

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [ferco].[ERP_VIEW_RECEPTION]
*/
-- =============================================
CREATE VIEW [ferco].[ERP_VIEW_RECEPTION]
as 
SELECT 
	[SAP_RECEPTION_ID]
	 ,[ERP_DOC]
	 ,[PROVIDER_ID]
	 ,[PROVIDER_NAME]
	 ,[SKU]
	 ,[SKU_DESCRIPTION]
	 ,[QTY]
	 ,[MASTER_ID_PROVIDER]
	 ,[OWNER]
FROM OPENQUERY(SAPSERVER,'SELECT 
    CAST( poD.DocEntry as varchar) + CAST(poD.LineNum as varchar)			 AS SAP_RECEPTION_ID,
    poD.DocEntry				AS ERP_DOC,
	po.CardCode			AS PROVIDER_ID,
	po.CardName		AS PROVIDER_NAME,
 	pod.ItemCode 					AS SKU ,
	pod.dscription  		AS SKU_DESCRIPTION,
	pod.Quantity					AS QTY 
	,po.CardCode [MASTER_ID_PROVIDER]
	,''ferco'' [OWNER]
FROM
	[SBOFERCO].dbo.por1 POD inner join  
	[SBOFERCO].DBO.OPOR   PO ON 
	po.DocEntry = pod.DocEntry
	where 
--po.DocStatus=''O''  and 
  po.DocType=''I''	')