﻿
CREATE FUNCTION [FERCO].[OP_WMS_FUNC_GET_USER_BASC]
(	
	@pLOGIN_ID		VARCHAR(25)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		A.ACCESS,
		A.CHECK_ID,
		A.DESCRIPTION,
		B.ROLE_ID
	FROM 
		FERCO.OP_BASC_VIEW_MENU				A,
		FERCO.OP_WMS_ROLES_JOIN_CHECKPOINTS	B
	WHERE 
		B.ROLE_ID	= (SELECT TOP 1 ROLE_ID FROM FERCO.OP_WMS_LOGINS WHERE LOGIN_ID = @pLOGIN_ID) AND
		B.CHECK_ID	= A.CHECK_ID
)



