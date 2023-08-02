

CREATE VIEW [ferco].[ERP_VIEW_PURCHASE_ORDER_HEADER]
as 
select *from openquery (SAPSERVER,'SELECT     po.DocEntry AS Doc_Entry, po.CardCode AS Card_Code, po.CardName AS Card_Name, ''N'' AS Hand_Written,  po.Comments, 
                      po.DocCur AS Doc_Cur, po.DocRate AS Doc_Rate, CAST(NULL AS varchar) AS U_FacSerie, CAST(NULL AS varchar) AS U_FacNit, CAST(NULL AS varchar) AS U_FacNom, CAST(NULL AS varchar) 
                      AS U_FacFecha, CAST(NULL AS varchar) AS U_Tienda, CAST(NULL AS varchar) AS U_STATUS_NC, CAST(NULL AS varchar) AS U_NO_EXENCION, CAST(NULL AS varchar) AS U_TIPO_DOCUMENTO, 
                      CAST(NULL AS varchar) AS U_usuario, CAST(NULL AS varchar) AS U_Facnum, CAST(NULL AS varchar) AS U_SUCURSAL, CAST(NULL AS varchar) AS U_Total_Flete, CAST(NULL AS varchar) 
                      AS U_Tipo_Pago, CAST(NULL AS varchar) AS U_Cuotas, CAST(NULL AS varchar) AS U_Total_Tarjeta, CAST(NULL AS varchar) AS U_FECHAP, CAST(NULL AS varchar) AS U_TrasladoOC                                            
FROM         [SBOFERCO].dbo.OPOR AS po 
WHERE     (po.DocStatus = ''O'') AND (po.DocType = ''I'')  ')