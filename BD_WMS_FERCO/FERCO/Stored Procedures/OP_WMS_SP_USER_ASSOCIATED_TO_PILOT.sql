
-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-10 @ Team REBORN - Sprint Drache
-- Description:	        SP que devuelve los usuarios asociados a los pilotos

/*
-- Ejemplo de Ejecucion:
			EXEC  [FERCO].OP_WMS_SP_USER_ASSOCIATED_TO_PILOT
*/
-- =============================================
CREATE PROCEDURE FERCO.OP_WMS_SP_USER_ASSOCIATED_TO_PILOT
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [UXP].[CODE]
   ,[UXP].[USER_CODE]
   ,[UXP].[PILOT_CODE]
   ,[UXP].[LAST_UPDATE]
   ,[UXP].[LAST_UPDATE_BY]
  FROM [FERCO].[OP_WMS_USER_X_PILOT] [UXP]
  WHERE [UXP].[CODE] > 0

END
