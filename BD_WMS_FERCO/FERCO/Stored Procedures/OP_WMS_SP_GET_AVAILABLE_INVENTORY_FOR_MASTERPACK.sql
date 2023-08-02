-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	7/12/2017 @ NEXUS-Team Sprint AgeOfEmpires 
-- Description:			Obtiene el inventario actual del masterpack utilizando la funcion OP_WMS_FN_GET_AVAILABLE_INVENTORY_FOR_MASTERPACK

/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[OP_WMS_SP_GET_AVAILABLE_INVENTORY_FOR_MASTERPACK]
					@MASTER_PACK_CODE = 'FERCO/C00000261'
					, @WAREHOUSE_ID = 'BODEGA_01'
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_GET_AVAILABLE_INVENTORY_FOR_MASTERPACK](
	@MASTER_PACK_CODE VARCHAR(25)
	, @WAREHOUSE_ID VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT 
		[FERCO].[OP_WMS_FN_GET_AVAILABLE_INVENTORY_FOR_MASTERPACK](@MASTER_PACK_CODE, @WAREHOUSE_ID) [AVAILABLE]

	
END