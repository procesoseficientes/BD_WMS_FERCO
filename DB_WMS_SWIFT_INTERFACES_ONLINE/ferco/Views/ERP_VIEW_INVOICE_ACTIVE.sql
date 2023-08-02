
-- =============================================
-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	2016-08-16
-- Description:			    Vista que obtiene facturas vencidas

-- Modificacion 3/13/2017 @ A-Team Sprint Ebonne
-- diego.as
-- Se modifica para que apunte a la BD SBOFERCO

-- Modificacion 4/20/2017 @ A-Team Sprint Hondo
-- rodrigo.gomez
-- Se agrego la referencia a U_MasterID de Clientes

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [FERCO].[ERP_VIEW_INVOICE_ACTIVE]
*/
-- =============================================
CREATE VIEW ferco.ERP_VIEW_INVOICE_ACTIVE
AS
SELECT DISTINCT
  [DocTotal] AS [DOC_TOTAL]
 ,[PaidToDate] AS [PAID_TO_DATE]
 ,[DocDueDate] AS [DOC_DUE_DATE]
 ,[CardCode] AS [CARD_CODE]
 ,[DocDate] AS [DOC_DATE]
FROM SAPSERVER.[SBOFERCO].[DBO].[OINV]
WHERE DocStatus = 'O'
--AND [U_MasterIDCustomer] IS NOT NULL
