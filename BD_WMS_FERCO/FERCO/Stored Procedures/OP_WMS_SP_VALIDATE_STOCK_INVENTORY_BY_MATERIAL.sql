
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	01-Nov-16 @ A-TEAM Sprint 4 
-- Description:			SP que valida si hay inventario para un producto

/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[OP_WMS_SP_VALIDATE_STOCK_INVENTORY_BY_MATERIAL]
					@EXTERNAL_SOURCE_ID = 1
					,@MATERIAL_ID = '100002'
					,@QTY = 10
				--
				EXEC [FERCO].[OP_WMS_SP_VALIDATE_STOCK_INVENTORY_BY_MATERIAL]
					@EXTERNAL_SOURCE_ID = 2
					,@MATERIAL_ID = '000000000000000002'
					,@QTY = 10
*/
-- =============================================
CREATE PROCEDURE FERCO.OP_WMS_SP_VALIDATE_STOCK_INVENTORY_BY_MATERIAL (@EXTERNAL_SOURCE_ID INT
, @MATERIAL_ID VARCHAR(50)
, @QTY INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @RESULT INT = 0
         ,@SOURCE_NAME VARCHAR(50) = ''

  -- ------------------------------------------------------------------------------------
  -- Obtiene las fuentes externas
  -- ------------------------------------------------------------------------------------
  SELECT
    @SOURCE_NAME = [ES].[SOURCE_NAME]
  FROM [FERCO].[OP_SETUP_EXTERNAL_SOURCE] [ES]
  WHERE [ES].[EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID

  -- ------------------------------------------------------------------------------------
  -- Obtiene el inventario reservado
  -- ------------------------------------------------------------------------------------
  SELECT TOP 1
    @RESULT =
    CASE
      WHEN [IG].[AVAILABLE] >= @QTY THEN 1
      ELSE 0
    END
  FROM [FERCO].[OP_WMS_VIEW_INVENTORY_GENERAL] [IG]
  WHERE [IG].[CLIENT_OWNER] = @SOURCE_NAME
  AND [IG].[MATERIAL_ID] = (@SOURCE_NAME + '/' + @MATERIAL_ID)

  -- ------------------------------------------------------------------------------------
  -- Muestra el resultado
  -- ------------------------------------------------------------------------------------
  SELECT
    @RESULT AS RESULT
END
