

CREATE VIEW [ferco].[ERP_VIEW_PURCHASE_ORDER_DETAIL]
as 
select *from openquery (SAPSERVER,'SELECT     
 po.ItemCode,
 po.DocEntry,
 po.ObjType, 
 po.LineNum  Line_Num, 
 ISNULL(po.WhsCode, ''01'') AS Warehouse_Code, 
                      ''ST'' AS Sales_Unit
                      FROM         
                      [SBOFERCO].dbo.POR1 AS po   ')