





CREATE VIEW [ferco].[ERP_VIEW_INVOICE_DETAIL_FOR_INTERFACE]
AS
select 
	[DocEntry]
 ,[AgrNo]
 ,[ItemCode]
from OPENQUERY([SAPSERVER],'SELECT DocEntry, AgrNo, ItemCode FROM [SBOFERCO].dbo.INV1')
