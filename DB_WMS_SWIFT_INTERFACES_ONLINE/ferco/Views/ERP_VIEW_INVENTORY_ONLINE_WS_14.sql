





-- =============================================
-- Autor:					michael.mazariegos
-- Fecha de Creacion: 		29/03/2021
-- Description:			    Vista para la consulta de invetario por zonas en linea



/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [ferco].[ERP_VIEW_INVENTORY_ONLINE_WS_14]  
*/
-- =============================================
CREATE VIEW [ferco].[ERP_VIEW_INVENTORY_ONLINE_WS_14]
AS (

	SELECT *
	FROM OPENQUERY([SAPSERVER], '
		SELECT 
			CAST(NULL AS VARCHAR(50)) CENTER
			, ''14'' CODE_WAREHOUSE
			,OITW.ItemCode COLLATE DATABASE_DEFAULT CODE_SKU
			,OITM.ItemName MATERIAL_NAME
			, SUM(OITW.OnHand) ON_HAND 
			, SUM(OITW.OnOrder) IS_COMMITED
			,SUM(case when whsCode = ''14'' then  OITW.OnHand else 0 end ) ON_HAND_14
			--,OUOM.UomCode CODE_PACK_UNIT
		FROM [SBOFERCO].[dbo].[OITW] OITW
			INNER JOIN [SBOFERCO].[dbo].[OITM] OITM ON OITW.ItemCode = OITM.ItemCode
			--INNER JOIN [SBOFERCO].[dbo].[UGP1] UGP1 ON UGP1.UgpEntry = OITM.UgpEntry
			--INNER JOIN [SBOFERCO].[dbo].[OUOM] OUOM ON OUOM.UomEntry = UGP1.UomEntry
				where whsCode IN ( ''14'') AND OITW.OnHand > 0
				GROUP BY 
			OITW.ItemCode COLLATE DATABASE_DEFAULT,
			OITM.ItemName
			--,OUOM.UomCode
			
		
	
	')
)

