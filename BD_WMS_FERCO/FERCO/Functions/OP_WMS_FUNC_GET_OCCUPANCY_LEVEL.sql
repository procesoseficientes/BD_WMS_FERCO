﻿






-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [FERCO].[OP_WMS_FUNC_GET_OCCUPANCY_LEVEL]
(	
	@pSINCE_DATE	DATETIME,
	@pTO_DATE		DATETIME
)
RETURNS TABLE 
AS
RETURN 
(

SELECT 
	A.INPUT_DATE,			
	A.LOCATION_SPOT,				
	A.OCCUPANCY_LEVEL,		
	A.WAREHOUSE_OWNER,
	A.TRAMO, 
	A.MAX_MT2_OCCUPANCY,
	CONVERT(NUMERIC(18,2), A.OCCUPANCY_MT2) AS OCCUPANCY_MT2, 
	A.WAREHOUSE_PARENT,
	A.SPOT_TYPE,
	CONVERT(VARCHAR(25),A.LAST_UPDATED) AS LAST_UPDATED,
	A.LAST_UPDATED_BY
 FROM 
	FERCO.OP_WMS_VIEW_OCCUPANCY_LEVEL A
 WHERE 
	A.INPUT_DATE >= @pSINCE_DATE AND A.INPUT_DATE <= @pTO_DATE

)





