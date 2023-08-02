﻿







-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [FERCO].[OP_WMS_FUNC_GET_AUDIT_DISPATCH_SERIAL]
(	
	@pSINCE_DATE	DATETIME,
	@pTO_DATE		DATETIME
)
RETURNS TABLE 
AS
RETURN 
(

SELECT 
	AUDIT_ID,
	MATERIAL_ID,
	SERIAL_NUMBER AS Serial 
FROM 
	FERCO.OP_WMS_AUDIT_DISPATCH_SERIES A
WHERE 
	A.MATERIAL_ID IN (
		 SELECT A.MATERIAL_ID
		 FROM FERCO.OP_WMS_AUDIT_DISPATCH_SKUS A
		 WHERE A.LAST_UPDATED >= @pSINCE_DATE AND A.LAST_UPDATED <= @pTO_DATE
	)
)






