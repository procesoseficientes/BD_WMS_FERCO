﻿
CREATE PROCEDURE FERCO.OP_WMS_SP_CREATE_ACUERDOS_X_CLIENTE @ACUERDO_COMERCIAL INT,
@CLIENT_ID VARCHAR(50),
@pResult VARCHAR(250) OUTPUT

AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRAN
  BEGIN
    INSERT INTO FERCO.OP_WMS_ACUERDOS_X_CLIENTE (CLIENT_ID
    , ACUERDO_COMERCIAL)
      VALUES (@CLIENT_ID, @ACUERDO_COMERCIAL)
  END
  IF @@error = 0
  BEGIN
    SELECT
      @pResult = 'OK'
    COMMIT TRAN
  END
  ELSE
  BEGIN
    ROLLBACK TRAN
    SELECT
      @pResult = ERROR_MESSAGE()
  END

END
