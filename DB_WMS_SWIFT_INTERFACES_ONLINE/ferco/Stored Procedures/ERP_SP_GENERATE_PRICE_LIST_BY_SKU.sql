
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	20-08-2016 @ Sprint θ
-- Description:			SP que obtiene las listas de precio base

-- Modificacion 27-Feb-17 @ A-Team Sprint Donkor
-- alberto.ruiz
-- Ajuste por Alutech

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [ferco].[ERP_SP_GENERATE_PRICE_LIST_BY_SKU]
*/
-- =============================================
CREATE PROCEDURE ferco.ERP_SP_GENERATE_PRICE_LIST_BY_SKU
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @PRICE_TYPE INT = 1
         ,@CODE_PACK_UNIT_SMALLER VARCHAR(50) = 'ST'

  -- ------------------------------------------------------------------------------------
  -- Se cargan las nuevas bonificaciones
  -- ------------------------------------------------------------------------------------
  TRUNCATE TABLE ferco.ERP_TB_PRICE_LIST_BY_SKU
  --
  INSERT INTO ferco.[ERP_TB_PRICE_LIST_BY_SKU] ([CODE_ROUTE]
  , [CODE_CUSTOMER]
  , [CODE_SKU]
  , [COST]
  , [CODE_PACK_UNIT]
  , [UM_ENTRY])
    SELECT
      [VKORG]
     ,[PLTYP]
     ,[MATNR]
     ,MAX([KBETR])
     ,[VRKME]
     ,-1
    FROM [SAPR3].[dbo].[ZTT_SD001_DATOS_MAESTROS]
    WHERE [Z_TIPO_CLASE] = @PRICE_TYPE
    AND [KSTBM] = 0
    AND [VRKME] = 'ST'--@CODE_PACK_UNIT_SMALLER
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
   ,[COST]
   ,[CODE_PACK_UNIT]
   ,[UM_ENTRY]
  FROM ferco.ERP_TB_PRICE_LIST_BY_SKU
  ORDER BY CODE_ROUTE, CODE_CUSTOMER, CODE_SKU, CODE_PACK_UNIT
END
