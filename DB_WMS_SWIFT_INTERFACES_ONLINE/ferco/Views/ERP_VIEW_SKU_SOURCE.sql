-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		14-Jun-17 @ A-Team Sprint Jibade 
-- Description:			    Vista para el codigo de sku por cada base de datos de la multiempresa

-- Modificacion 6/23/2017 @ A-Team Sprint Khalid
					-- rodrigo.gomez
					-- Se comento la parte de intercompany para las que se obtengan los datos cuando este no es intercompany

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [ferco].[ERP_VIEW_SKU_SOURCE]
*/
-- =============================================
CREATE VIEW [ferco].[ERP_VIEW_SKU_SOURCE]
AS (
	/*SELECT
		[U_MasterID] [MASTER_ID]
		,[ItemCode] [ITEM_CODE]
		,[SOURCE] [SOURCE]
	FROM [SAP_INTERCOMPANY].[dbo].[OITM]
	WHERE [U_MasterID] IS NOT NULL*/
	SELECT
		*
	FROM OPENQUERY(SAPSERVER, '
	  SELECT
		CONVERT(VARCHAR(50),ItemCode) COLLATE DATABASE_DEFAULT AS MASTER_ID
		,CONVERT(VARCHAR(50),ItemCode) COLLATE DATABASE_DEFAULT AS ITEM_CODE
		,CONVERT(VARCHAR(50),''ferco'') COLLATE DATABASE_DEFAULT AS SOURCE
	  FROM [SBOFERCO].dbo.OITM 
	  '
	)
)