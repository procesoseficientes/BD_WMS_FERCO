-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		7/6/2017 @ NEXUS-Team Sprint AgeOfEmpires 
-- Description:			    Devuelve la cantidad de inventario posible a ensamblar de un masterpack

/*
-- Ejemplo de Ejecucion:
        SELECT [FERCO].[OP_WMS_FN_GET_AVAILABLE_INVENTORY_TO_ASSAMBLE_FOR_MASTERPACK_1]('ferco/KIT000699','CEDI_ZONA_5') 
*/
-- =============================================
CREATE FUNCTION [FERCO].[OP_WMS_FN_GET_AVAILABLE_INVENTORY_TO_ASSAMBLE_FOR_MASTERPACK_1]
(
	@MASTER_PACK_CODE VARCHAR(50)
	,@WAREHOUSE_ID VARCHAR(25)
)
RETURNS int
AS
BEGIN
	DECLARE @COMPONENT_INVENTORY TABLE(
		MATERIAL_ID VARCHAR(50)
		,QTY INT
		,QTY_NEEDED INT
		,REAL_QTY INT
	)
	DECLARE @QTYCOMPS INT = 0
	-- ------------------------------------------------------------------------------------
	-- Se insertan todos los componentes en una tabla temporal.
	-- ------------------------------------------------------------------------------------
	INSERT INTO @COMPONENT_INVENTORY
			(
				[MATERIAL_ID]
				,[QTY]
				,[QTY_NEEDED]
				,[REAL_QTY]
			)
	SELECT 
		[CXMP].[COMPONENT_MATERIAL]
		, SUM(ISNULL([IXW].[QTY],0))
		, [CXMP].[QTY] [QTY_NEEDED]
		, CAST(SUM(ISNULL([IXW].[QTY],0)) / [CXMP].[QTY] AS INT)  REAL_QTY
	FROM [FERCO].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [CXMP]
		LEFT JOIN [FERCO].[OP_WMS_VIEW_PICKING_AVAILABLE_GENERAL] [IXW] ON [IXW].[MATERIAL_ID] = [CXMP].[COMPONENT_MATERIAL] AND [IXW].[CURRENT_WAREHOUSE] = @WAREHOUSE_ID
	WHERE [CXMP].[MASTER_PACK_CODE] = @MASTER_PACK_CODE
	GROUP BY [CXMP].[COMPONENT_MATERIAL]
			,[CXMP].[QTY]
	-- ------------------------------------------------------------------------------------
	-- Obtenemos la cantidad minima de masterpacks a ensamblar
	-- ------------------------------------------------------------------------------------


	SELECT TOP 1 @QTYCOMPS = ISNULL([REAL_QTY],0) 
	FROM @COMPONENT_INVENTORY
	ORDER BY [REAL_QTY]  ASC

	--
	RETURN ISNULL(@QTYCOMPS, 0)
END
