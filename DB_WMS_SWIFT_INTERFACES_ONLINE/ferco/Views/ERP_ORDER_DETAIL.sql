

CREATE VIEW [ferco].[ERP_ORDER_DETAIL]
as 
select *from openquery (SAPSERVER,'SELECT
  so.DocEntry DOC_ENTRY,
  so.ItemCode ITEM_CODE,
  so.ObjType AS OBJ_TYPE,
  so.LineNum AS LINE_NUM
FROM  [SBOFERCO].dbo.RDR1 AS so ')