/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [ferco].[ERP_VIEW_INVENTORY_ONLINE_WS_01] WHERE CODE_WAREHOUSE = '01'
*/
-- =============================================
create VIEW [ferco].[ERP_VIEW_INVENTORY_ONLINE_WS_18]
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
			, ''18'' CODE_WAREHOUSE
			,OITW.ItemCode COLLATE DATABASE_DEFAULT CODE_SKU
			, SUM(OITW.OnHand) ON_HAND
			,SUM(case when whsCode = ''01'' then  OITW.OnHand else 0 end ) ON_HAND_01
			,SUM(case when whsCode = ''03'' then  OITW.OnHand else 0 end ) ON_HAND_03
			--,OUOM.UomCode CODE_PACK_UNIT
		FROM [SBOFERCO].[dbo].[OITW] OITW
			INNER JOIN [SBOFERCO].[dbo].[OITM] OITM ON OITW.ItemCode = OITM.ItemCode

				where OITW.whsCode = ''18''
				AND OITW.OnHand > 0
				GROUP BY
			OITW.ItemCode COLLATE DATABASE_DEFAULT
			--,OUOM.UomCode



	')
	--INNER JOIN [SBOFERCO].[dbo].[UGP1] UGP1 ON UGP1.UgpEntry = OITM.UgpEntry
			--INNER JOIN [SBOFERCO].[dbo].[OUOM] OUOM ON OUOM.UomEntry = UGP1.UomEntry
)