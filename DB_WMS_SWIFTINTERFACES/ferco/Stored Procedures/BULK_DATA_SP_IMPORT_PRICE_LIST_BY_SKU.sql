﻿-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	29-02-2016
-- Description:			SP que importa lista de precios por producto

-- Modificado 2016-05-10
              -- alberto.ruiz
              -- Se agregaron las columnas CODE_PRICE_LIST y CODE_SKU
/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [ferco].[BULK_DATA_SP_IMPORT_PRICE_LIST_BY_SKU]
				--
				SELECT * FROM [SWIFT_EXPRESS].[ferco].[SWIFT_PRICE_LIST_BY_SKU]
*/
-- =============================================
CREATE PROCEDURE [ferco].[BULK_DATA_SP_IMPORT_PRICE_LIST_BY_SKU]
AS
BEGIN
	SET NOCOUNT ON;
	--
	MERGE [SWIFT_EXPRESS].[ferco].[SWIFT_PRICE_LIST_BY_SKU]   [TGR] 
	USING (SELECT * FROM  [SWIFT_INTERFACES_ONLINE].[ferco].[ERP_PRICE_LIST_BY_SKU] WHERE [CODE_PRICE_LIST] IS NOT NULL) [SRC] 
	ON  
		[TGR].[CODE_PRICE_LIST]  = [SRC].[CODE_PRICE_LIST] 
		AND [TGR].[CODE_SKU] = [SRC].[CODE_SKU] COLLATE DATABASE_DEFAULT
	WHEN MATCHED THEN 
	UPDATE  
		SET 
			[TGR].[COST] = [SRC].[COST]
			,[TGR].[CODE_PACK_UNIT] = [SRC].[CODE_PACK_UNIT] COLLATE DATABASE_DEFAULT
			,[TGR].[UM_ENTRY] = [SRC].[UM_ENTRY]
			,[TGR].[OWNER] = [SRC].[OWNER]
	WHEN NOT MATCHED THEN 
	INSERT (
		[CODE_PRICE_LIST]
		,[CODE_SKU]
		,[COST]
		,[CODE_PACK_UNIT]
		,[UM_ENTRY]
		,[OWNER]
	)
	VALUES (
		[SRC].[CODE_PRICE_LIST] 
		,[SRC].[CODE_SKU] 
		,[SRC].[COST] 
		,[SRC].[CODE_PACK_UNIT] COLLATE DATABASE_DEFAULT
		,[SRC].[UM_ENTRY]
		,[SRC].[OWNER]
	);
END