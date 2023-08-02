﻿-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		30-Jan-17 @ Reborn Team Sprint Trotzdem
-- Description:			    Obtiene las clases de la licencia enviada

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [FERCO].[OP_WMS_FN_GET_CLASSES_BY_LICENSE](408468)
*/
-- =============================================
CREATE FUNCTION [FERCO].[OP_WMS_FN_GET_CLASSES_BY_LICENSE] (@LICENSE_ID INT)
RETURNS @CLASSES TABLE
    (
     [CLASS_ID] INT
    ,[CLASS_NAME] VARCHAR(50)
    ,[CLASS_DESCRIPTION] VARCHAR(250)
    ,[CLASS_TYPE] VARCHAR(50)
    ,[CREATED_BY] VARCHAR(50)
    ,[CREATED_DATETIME] DATETIME
    ,[LAST_UPDATED_BY] VARCHAR(50)
    ,[LAST_UPDATED] DATETIME
    ,[PRIORITY] INT
    )
AS
BEGIN
    DECLARE @CLASSES_ON_LICENSE TABLE ([CLASS_ID] INT);
	-- ------------------------------------------------------------------------------------
	-- Obtiene las clases de la licencia
	-- ------------------------------------------------------------------------------------
    INSERT  INTO @CLASSES_ON_LICENSE
    SELECT DISTINCT
        [C].[CLASS_ID]
    FROM
        [FERCO].[OP_WMS_INV_X_LICENSE] [IXL]
    INNER JOIN [FERCO].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [IXL].[MATERIAL_ID]
    INNER JOIN [FERCO].[OP_WMS_CLASS] [C] ON [M].[MATERIAL_CLASS] = [C].[CLASS_ID]
    WHERE
        [QTY] > 0
        AND [LICENSE_ID] = @LICENSE_ID;

	-- ------------------------------------------------------------------------------------
	-- Resultado Final
	-- ------------------------------------------------------------------------------------
	INSERT INTO @CLASSES
	SELECT [C].[CLASS_ID]
          ,[CLASS_NAME]
          ,[CLASS_DESCRIPTION]
          ,[CLASS_TYPE]
          ,[CREATED_BY]
          ,[CREATED_DATETIME]
          ,[LAST_UPDATED_BY]
          ,[LAST_UPDATED]
          ,[PRIORITY] 
	FROM [FERCO].[OP_WMS_CLASS] [C]
	INNER JOIN @CLASSES_ON_LICENSE [CL] ON [CL].[CLASS_ID] = [C].[CLASS_ID]
	
	RETURN;
END;
