﻿






-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create FUNCTION [FERCO].[OP_WMS_FUNC_GET_CURRENCY]
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
		PARAM_GROUP = 'CURRENCY'
	
		
)






