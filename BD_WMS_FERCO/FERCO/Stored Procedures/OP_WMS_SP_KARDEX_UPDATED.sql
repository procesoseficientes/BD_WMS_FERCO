
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE FERCO.OP_WMS_SP_KARDEX_UPDATED
-- Add the parameters for the stored procedure here
@KARDEX_ID INT,
@CURRENT_BALACE NUMERIC(18, 2)
AS
BEGIN
  -- SET NOCOUNT ON added to prevent extra result sets from
  -- interfering with SELECT statements.
  SET NOCOUNT ON;

  UPDATE [FERCO].OP_WMS_KARDEX
  SET CURRENT_BALACE = @CURRENT_BALACE
     ,LAST_UPDATED = GETDATE()
  WHERE KARDEX_ID = @KARDEX_ID

END
