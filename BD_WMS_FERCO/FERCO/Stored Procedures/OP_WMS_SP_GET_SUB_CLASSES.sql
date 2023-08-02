-- =============================================
-- Autor:				kevin.guerra
-- Fecha de Creacion: 	GForce@B
-- Description:			Obtiene todos los registros de la tabla OP_WMS_SUB_CLASS

/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[OP_WMS_SP_GET_SUB_CLASSES]
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_GET_SUB_CLASSES]
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		[SUB_CLASS_ID]
	   ,[SUB_CLASS_NAME]
	   ,[CREATED_BY]
	   ,[CREATED_DATETIME]
	   ,[LAST_UPDATED_BY]
	   ,[LAST_UPDATED]
	  FROM [FERCO].[OP_WMS_SUB_CLASS]
END