﻿
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	11-05-2016
-- Description:			SP que importa los precios base de los paquetes que no es el configurado el la lista de precios base

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [ferco].[BULK_DATA_SP_IMPORT_SKU_BASE_PRICE_BY_PACK]
				--
				SELECT * FROM [SWIFT_EXPRESS].[ferco].[SWIFT_SKU_BASE_PRICE_BY_PACK]
*/
-- =============================================
CREATE PROCEDURE ferco.BULK_DATA_SP_IMPORT_SKU_BASE_PRICE_BY_PACK
AS
BEGIN
  SET NOCOUNT ON;
  --
  MERGE [SWIFT_EXPRESS].[ferco].[SWIFT_SKU_BASE_PRICE_BY_PACK] SB
  USING (SELECT
      *
    FROM [SWIFT_INTERFACES_ONLINE].[ferco].[ERP_SKU_BASE_PRICE_BY_PACK]) ESB
  ON SB.CODE_PRICE_LIST = ESB.CODE_PRICE_LIST
    AND SB.CODE_SKU = ESB.CODE_SKU COLLATE DATABASE_DEFAULT
    AND SB.CODE_PACK_UNIT = ESB.CODE_PACK_UNIT COLLATE DATABASE_DEFAULT
  WHEN MATCHED
    THEN UPDATE
      SET SB.PRICE = ESB.COST
  WHEN NOT MATCHED
    THEN INSERT (CODE_PRICE_LIST
      , CODE_SKU
      , CODE_PACK_UNIT
      , PRICE)
        VALUES (ESB.CODE_PRICE_LIST, ESB.CODE_SKU COLLATE DATABASE_DEFAULT, ESB.CODE_PACK_UNIT COLLATE DATABASE_DEFAULT, ESB.COST);
END
