-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	7/6/2017 @ NEXUS-Team Sprint AgeOfEmpires 
-- Description:			Valida si existe el material para el cliente y si es o no master pack

/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[OP_WMS_SP_VALIDATED_IF_MATERIAL_EXISTS]
					@CLIENT_CODE = 'FERCO'
					,@MATERIAL_ID = 'FERCO/01272016'

				EXEC [FERCO].[OP_WMS_SP_VALIDATED_IF_MATERIAL_EXISTS]
					@CLIENT_CODE = 'FERCO'
					,@MATERIAL_ID = 'FERCO/C00000010'

				EXEC [FERCO].[OP_WMS_SP_VALIDATED_IF_MATERIAL_EXISTS]
					@CLIENT_CODE = 'FERCO'
					,@MATERIAL_ID = '10288449'
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_VALIDATED_IF_MATERIAL_EXISTS](
	@CLIENT_CODE VARCHAR(25)
	,@MATERIAL_ID VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE 
		@EXISTS INT = 0
		,@IS_MASTER_PACK INT = 0
	--
	SELECT TOP 1
		@EXISTS = 1
		,@IS_MASTER_PACK = [M].[IS_MASTER_PACK]
	FROM [FERCO].[OP_WMS_MATERIALS] [M]
	WHERE [CLIENT_OWNER] = @CLIENT_CODE AND [MATERIAL_ID] = @MATERIAL_ID
	--
	SELECT 
		@EXISTS [EXISTS]
		,@IS_MASTER_PACK [IS_MASTER_PACK]
END