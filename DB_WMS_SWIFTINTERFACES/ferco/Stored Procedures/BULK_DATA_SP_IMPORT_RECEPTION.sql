
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	29-02-2016
-- Description:			SP que importa recepciones

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [ferco].[BULK_DATA_SP_IMPORT_RECEPTION]
*/
-- =============================================
CREATE PROCEDURE ferco.BULK_DATA_SP_IMPORT_RECEPTION
AS
BEGIN
  SET NOCOUNT ON;
  --
  DELETE FROM [ferco].[SWIFT_ERP_RECEPTION]
  INSERT INTO [ferco].[SWIFT_ERP_RECEPTION]
    SELECT
      *
    FROM [SWIFT_INTERFACES_ONLINE].[ferco].[ERP_VIEW_RECEPTION]
END
