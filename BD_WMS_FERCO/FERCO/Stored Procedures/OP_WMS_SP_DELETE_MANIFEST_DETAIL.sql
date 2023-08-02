
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	10-Nov-17 @ Nexus Team Sprint F-Zero 
-- Description:			SP que borra el detalle de un manifiesto

/*
-- Ejemplo de Ejecucion:
				DECLARE @MANIFEST_HEADER_ID INT = 1121
				--
				SELECT * FROM [FERCO].[OP_WMS_MANIFEST_DETAIL] WHERE MANIFEST_HEADER_ID = @MANIFEST_HEADER_ID
				--
				EXEC [FERCO].[OP_WMS_SP_DELETE_MANIFEST_DETAIL]
					@MANIFEST_HEADER_ID = @MANIFEST_HEADER_ID
				-- 
				SELECT * FROM [FERCO].[OP_WMS_MANIFEST_DETAIL] WHERE MANIFEST_HEADER_ID = @MANIFEST_HEADER_ID
*/
-- =============================================
CREATE PROCEDURE FERCO.OP_WMS_SP_DELETE_MANIFEST_DETAIL (@MANIFEST_HEADER_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY
    DELETE [P]
      FROM [FERCO].[OP_WMS_PICKING_LABEL_BY_MANIFEST] [P]
      INNER JOIN [FERCO].[OP_WMS_MANIFEST_DETAIL] [MD]
        ON [MD].[MANIFEST_DETAIL_ID] = [P].[MANIFEST_DETAIL_ID]
    WHERE [MD].[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID
    --
    DELETE FROM [FERCO].[OP_WMS_MANIFEST_DETAIL]
    WHERE [MANIFEST_DETAIL_ID] > 0
      AND [MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID
    --
    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,'' DbData
  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@ERROR Codigo
  END CATCH
END
