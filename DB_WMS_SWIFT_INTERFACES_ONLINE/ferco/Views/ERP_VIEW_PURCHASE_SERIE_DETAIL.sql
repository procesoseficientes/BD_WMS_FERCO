

CREATE VIEW [ferco].[ERP_VIEW_PURCHASE_SERIE_DETAIL]
as 
select *from openquery (SAPSERVER,'SELECT      po.LineNum AS Line_Num 
,po.ItemCode ITEM_CODE
,po.DocEntry DOC_ENTRY
FROM          [SBOFERCO].dbo.POR1 AS po  ')