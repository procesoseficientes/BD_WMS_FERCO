﻿
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [FERCO].[OP_WMS_FUNC_GETCLIENT_NAME]
(	
	@pClientID varchar(25)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT CLIENT_NAME
	FROM FERCO.OP_WMS_VIEW_CLIENTS
	WHERE CLIENT_CODE  = @pClientID COLLATE DATABASE_DEFAULT
)


