-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		08-Jun-17 @ A-Team Sprint Jibade 
-- Description:			    Vista para el codigo de cliente por cada base de datos de la multiempresa

-- Modificacion 6/23/2017 @ A-Team Sprint Khalid
					-- rodrigo.gomez
					-- Se comento la parte de intercompany para las que se obtengan los datos cuando este no es intercompany

-- Modificacion 8/21/2017 @ NEXUS-Team Sprint ComandAndConquer
					-- rodrigo.gomez
					-- Se agregaron las columnas LICTRADNUM y CARD_NAME

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [ferco].[ERP_VIEW_CUSTOMER_SOURCE]
*/
-- =============================================
CREATE VIEW [ferco].[ERP_VIEW_CUSTOMER_SOURCE]
AS (
	/*SELECT
		[U_MasterID] [MASTER_ID]
		,[CardCode] [CARD_CODE]
		,[SOURCE] [SOURCE]
	FROM [SAP_INTERCOMPANY].[dbo].[OCRD]
	WHERE [U_MasterID] IS NOT NULL*/

	SELECT
	  *
	FROM OPENQUERY(SAPSERVER, '
	  SELECT 
		c.CardCode COLLATE DATABASE_DEFAULT [MASTER_ID] 
		,c.CardCode COLLATE DATABASE_DEFAULT [CARD_CODE] 
		,c.CardName COLLATE DATABASE_DEFAULT [CARD_NAME]
		,''C/F'' [TAX_ID]
		,''ferco'' COLLATE DATABASE_DEFAULT AS [SOURCE]
	  FROM [SBOFERCO].dbo.OCRD AS c 
	  WHERE 
		(c.CardCode <> ''ANULADO'') 
		AND (c.CardType = ''C'')    
	')


)