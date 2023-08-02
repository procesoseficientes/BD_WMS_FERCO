-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		10/10/2017 @ NEXUS-Team Sprint eNave 
-- Description:			    Vista para ver el encabezado de las facturas de ERP

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [ferco].[ERP_VIEW_INVOICE_HEADER]
*/
-- =============================================
CREATE VIEW [ferco].[ERP_VIEW_INVOICE_HEADER]
AS (
	SELECT * FROM OPENQUERY([SAPSERVER],
	'
		SELECT 
			DocEntry
			,DocNum
			,CardCode
			,CardName
			,Comments
			,DocDate
			,DocDueDate
			,DocStatus
			,CANCELED
			,SlpCode 
			,DocTotal
			,''ferco'' Owner
		FROM SBOFERCO.dbo.OINV
		WHERE CANCELED = ''N''
			AND DocStatus = ''O''
			AND DocDate > current_timestamp - 400
	')
)