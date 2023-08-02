
-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		25-Aug-17 @ NEXUSTeam Sprint CommandAndConquer
-- Description:			    Vista para obtener los precios de los productos con MasterId por fuente.

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [FERCO].[ERP_VIEW_PRICE_LIST_SOURCE]
*/
-- =============================================
CREATE VIEW ferco.ERP_VIEW_PRICE_LIST_SOURCE
AS
(SELECT
    [ItemCode] [ITEM_CODE]
   ,[PriceList] [PRICE_LIST]
   ,[Price] [PRICE]
   ,'ferco' [SOURCE]
  FROM SAPSERVER.SBOFERCO.[dbo].[ITM1]
--WHERE [U_MasterIDSKU] IS NOT NULL
)
