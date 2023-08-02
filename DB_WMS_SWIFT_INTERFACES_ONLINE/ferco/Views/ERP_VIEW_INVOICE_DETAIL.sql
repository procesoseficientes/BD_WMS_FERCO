-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		10/10/2017 @ NEXUS-Team Sprint eNave 
-- Description:			    Vista para ver el detalle de las facturas de ERP

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [ferco].[ERP_VIEW_INVOICE_DETAIL]
*/
-- =============================================
CREATE VIEW [ferco].[ERP_VIEW_INVOICE_DETAIL]
AS (
	SELECT * FROM OPENQUERY([SAPSERVER],'
		SELECT 
			DocEntry
			,LineNum
			,ItemCode
			,Dscription ItemName
			,Quantity
			,OpenQty
			,Price
			,DiscPrcnt DiscPercent
			,LineTotal
			,''ferco'' Owner
		FROM SBOFERCO.dbo.INV1
	')
)