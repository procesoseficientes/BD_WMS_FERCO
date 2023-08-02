-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		20-Jun-17 @ A-Team Sprint Khalid
-- Description:			    Vista para la consulta de invetario por zonas en linea

-- Modificacion 6/23/2017 @ A-Team Sprint Khalid
					-- rodrigo.gomez
					-- Se ajusto la vista para SAP BO

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [ferco].[ERP_VIEW_INVENTORY_ONLINE]
*/
-- =============================================
CREATE VIEW [ferco].[ERP_VIEW_INVENTORY_ONLINE]
AS (
	/*SELECT
		[I].[WERKS] [CENTER] --CAST AS VARCHAR 50
		,[I].[LGORT] [CODE_WAREHOUSE]
		,[I].[MATNR] [CODE_SKU]
		,[I].[LABST] [ON_HAND]
		,[I].[MEINS] [CODE_PACK_UNIT]
	FROM [SAPR3].[dbo].[T_INVENT_FIT] [I]*/

	SELECT *
	FROM OPENQUERY([SAPSERVER], '
		SELECT 
			CAST(NULL AS VARCHAR(50)) CENTER
			,OITW.WhsCode COLLATE DATABASE_DEFAULT CODE_WAREHOUSE
			,OITW.ItemCode COLLATE DATABASE_DEFAULT CODE_SKU
			,OITW.OnHand ON_HAND
			,OUOM.UomCode CODE_PACK_UNIT
		FROM [SBOFERCO].[dbo].[OITW] OITW
			INNER JOIN [SBOFERCO].[dbo].[OITM] OITM ON OITW.ItemCode = OITM.ItemCode
			INNER JOIN [SBOFERCO].[dbo].[UGP1] UGP1 ON UGP1.UgpEntry = OITM.UgpEntry
			INNER JOIN [SBOFERCO].[dbo].[OUOM] OUOM ON OUOM.UomEntry = UGP1.UomEntry

		
	
	')
)
