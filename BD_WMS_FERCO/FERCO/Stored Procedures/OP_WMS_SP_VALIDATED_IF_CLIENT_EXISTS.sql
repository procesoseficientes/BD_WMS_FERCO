-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	7/6/2017 @ NEXUS-Team Sprint AgeOfEmpires 
-- Description:			Valida si el cliente existe o no

/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[OP_WMS_SP_VALIDATED_IF_CLIENT_EXISTS]
					@CLIENT_CODE = 'FERCO'

				EXEC [FERCO].[OP_WMS_SP_VALIDATED_IF_CLIENT_EXISTS]
					@CLIENT_CODE = 'FERCO123'
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_VALIDATED_IF_CLIENT_EXISTS](
	@CLIENT_CODE NVARCHAR(15)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @RESULT INT = 0
	
	--
	SELECT TOP 1 @RESULT = 1
		FROM [FERCO].[OP_WMS_VIEW_CLIENTS] WITH (FORCESEEK)
		WHERE @CLIENT_CODE = [CLIENT_CODE]
	--
	SELECT @RESULT RESULT
END