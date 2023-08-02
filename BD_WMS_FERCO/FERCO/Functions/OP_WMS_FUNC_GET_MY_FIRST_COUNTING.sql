


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [FERCO].[OP_WMS_FUNC_GET_MY_FIRST_COUNTING]
(	
	@pLOGIN_ID		VARCHAR(25),
	@pCOUNT_ID		NUMERIC(18,0)
)

RETURNS TABLE 
AS
	
RETURN 
(
			SELECT TOP 1
			*			
			FROM FERCO.OP_WMS_FUNC_GET_MY_PICKING_LIST_DETAIL(@pLOGIN_ID)
)





