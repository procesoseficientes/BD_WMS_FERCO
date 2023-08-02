
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	19-08-2016 @ Sprint θ
-- Description:			SP que obtiene las listas de precios por sku y escala

-- Modificacion 27-Feb-17 @ A-Team Sprint Donkor
-- alberto.ruiz
-- Ajuste por Alutech

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [ferco].[ERP_SP_GENERATE_PRICE_LIST_BY_SKU_SCALE]
*/
-- =============================================
CREATE PROCEDURE ferco.ERP_SP_GENERATE_PRICE_LIST_BY_SKU_SCALE
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @PRICE_TYPE INT = 1

  -- ------------------------------------------------------------------------------------
  -- Se cargan las nuevas bonificaciones
  -- ------------------------------------------------------------------------------------
  TRUNCATE TABLE ferco.ERP_TB_PRICE_LIST_BY_SKU_PACK_SCALE
  --
  INSERT INTO ferco.[ERP_TB_PRICE_LIST_BY_SKU_PACK_SCALE] ([CODE_ROUTE]
  , [CODE_CUSTOMER]
  , [CODE_SKU]
  , [CODE_PACK_UNIT]
  , [LIMIT]
  , [COST])
    SELECT
      [VKORG]
     ,[PLTYP]
     ,[MATNR]
     ,[VRKME]
     ,1
     ,MAX([KBETR])
    FROM [SAPR3].[dbo].[ZTT_SD001_DATOS_MAESTROS]
    WHERE [Z_TIPO_CLASE] = @PRICE_TYPE
    AND [KSTBM] = 0
    GROUP BY [VKORG]
            ,[PLTYP]
            ,[MATNR]
            ,[VRKME]
    ORDER BY [VKORG]
    , [PLTYP]
    , [MATNR]
    , [VRKME]

  -- ------------------------------------------------------------------------------------
  -- Muestra el resultado
  -- ------------------------------------------------------------------------------------
  SELECT
    [CODE_ROUTE]
   ,[CODE_CUSTOMER]
   ,[CODE_SKU]
   ,[CODE_PACK_UNIT]
   ,[LIMIT]
   ,[COST]
  FROM ferco.ERP_TB_PRICE_LIST_BY_SKU_PACK_SCALE
  ORDER BY CODE_ROUTE, CODE_CUSTOMER, CODE_SKU
END
