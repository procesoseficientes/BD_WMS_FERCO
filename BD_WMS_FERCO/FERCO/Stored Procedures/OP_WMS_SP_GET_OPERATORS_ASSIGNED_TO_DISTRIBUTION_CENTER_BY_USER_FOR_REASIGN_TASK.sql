﻿
-- =============================================
-- Autor:	        rudi.gaecia
-- Fecha de Creacion: 	2017-02-28 @ Team ERGON - Sprint IV ERGON 
-- Description:	        Sp que trae los operadores asociados al mismo centro de distribucion y bodegas del operador enviado

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-03-31 @ Team ERGON - Sprint Hyper 
-- Description:	        se quito el where = '%oper'

/*
-- Ejemplo de Ejecucion:  
	EXEC [FERCO].OP_WMS_SP_GET_OPERATORS_ASSIGNED_TO_DISTRIBUTION_CENTER_BY_USER_FOR_REASIGN_TASK @LOGIN = 'ADMIN'
*/
-- =============================================
CREATE PROCEDURE FERCO.OP_WMS_SP_GET_OPERATORS_ASSIGNED_TO_DISTRIBUTION_CENTER_BY_USER_FOR_REASIGN_TASK (@LOGIN VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT DISTINCT
    [LR].[LOGIN_ID]
   ,[LR].[LOGIN_NAME]
  FROM [FERCO].[OP_WMS_LOGINS] [LA]
  INNER JOIN [FERCO].[OP_WMS_LOGINS] [LR]
    ON (
      [LA].[DISTRIBUTION_CENTER_ID] = [LR].[DISTRIBUTION_CENTER_ID]
      )
  INNER JOIN [FERCO].[OP_WMS_WAREHOUSE_BY_USER] [WUA]
    ON (
      [WUA].[LOGIN_ID] = [LA].[LOGIN_ID]
      )
  INNER JOIN [FERCO].[OP_WMS_WAREHOUSE_BY_USER] [WUR]
    ON (
        [WUR].[LOGIN_ID] = [LR].[LOGIN_ID]
        AND [WUA].[WAREHOUSE_ID] = [WUR].[WAREHOUSE_ID]
      )
  WHERE [LA].[LOGIN_ID] = @LOGIN
  AND [LR].[LOGIN_STATUS] = 'ACTIVO'
  AND [LR].[ROLE_ID] LIKE 'OPER%'
  ORDER BY [LR].[LOGIN_NAME]

END
