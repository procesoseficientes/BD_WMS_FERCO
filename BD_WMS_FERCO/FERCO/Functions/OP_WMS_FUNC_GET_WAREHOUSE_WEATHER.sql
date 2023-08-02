






-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [FERCO].[OP_WMS_FUNC_GET_WAREHOUSE_WEATHER]
(	
	
)
RETURNS TABLE 
AS
RETURN 
(
	
	SELECT *
	FROM FERCO.OP_WMS_CONFIGURATIONS  
	WHERE 
		PARAM_TYPE = 'SISTEMA' AND
		PARAM_GROUP = 'CLIMA_ALMACENAJE'
	
		
)






