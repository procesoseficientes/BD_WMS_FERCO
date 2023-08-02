CREATE VIEW ferco.ERP_PRICE_LIST_BY_SKU 
AS SELECT 
		[CODE_PRICE_LIST]
		,[CODE_SKU]
		,[COST]
		,[CODE_PACK_UNIT] COLLATE DATABASE_DEFAULT [CODE_PACK_UNIT]
		,[UM_ENTRY]
		,[MASTER_ID]
		,[OWNER]
	FROM OPENQUERY(SAPSERVER, '
		SELECT 
			CAST(p.PriceList AS varchar) AS CODE_PRICE_LIST 
			,p.ItemCode AS CODE_SKU  
			,p.Price AS COST
			,CASE 
				WHEN OI.UgpEntry != -1 THEN OI.InvntryUom
				ELSE ''Manual''
			END CODE_PACK_UNIT 
			,ISNULL(OU.UomEntry,''-1'') UM_ENTRY
			,CAST(NULL AS INT) [MASTER_ID]
			,CAST(NULL AS VARCHAR(50)) [OWNER]
		FROM SBOFERCO.dbo.ITM1 AS p
		INNER JOIN SBOFERCO.dbo.OITM OI ON (
			p.ItemCode = OI.ItemCode
		)
		LEFT JOIN SBOFERCO.dbo.OUOM OU ON (
			OU.UomCode = OI.InvntryUom
		)
		WHERE p.Price > 0
		AND OI.SellItem = ''Y''
		ORDER BY p.PriceList 
			,p.ItemCode
	  ')