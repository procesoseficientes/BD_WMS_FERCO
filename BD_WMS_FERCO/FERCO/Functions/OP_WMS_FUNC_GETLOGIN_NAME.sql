
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [FERCO].[OP_WMS_FUNC_GETLOGIN_NAME]
(	
	@pLoginID varchar(25)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT LOGIN_NAME
	FROM FERCO.OP_WMS_LOGINS
	WHERE LOGIN_ID = @pLoginID
)


