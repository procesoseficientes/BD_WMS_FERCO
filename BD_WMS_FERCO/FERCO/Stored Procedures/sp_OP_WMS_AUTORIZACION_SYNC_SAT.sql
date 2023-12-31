﻿
CREATE PROCEDURE FERCO.sp_OP_WMS_AUTORIZACION_SYNC_SAT @POLIZA VARCHAR(50),
@DOC_ID NUMERIC(18, 0),
@CLIENT_CODE VARCHAR(25),
@CLIENT_NAME VARCHAR(200),
@STATUS NUMERIC(2, 0),
@SENT DATETIME,
@RECEIVED DATETIME,
@SAT_RESULT VARCHAR(200),
@LAST_UPDATED_BY VARCHAR(25)
AS
  DECLARE @retCode INT

  IF NOT EXISTS (SELECT
        *
      FROM FERCO.OP_WMS_AUTORIZATION_SYNC_SAT
      WHERE POLIZA = @POLIZA)
  BEGIN
    BEGIN TRANSACTION
    INSERT INTO [FERCO].[OP_WMS_AUTORIZATION_SYNC_SAT] ([POLIZA]
    , [DOC_ID]
    , [CLIENT_CODE]
    , [STATUS]
    , [SENT]
    , [RECEIVED]
    , [SAT_RESULT], [CREATED], [LAST_UPDATED], [LAST_UPDATED_BY])
      VALUES (@POLIZA, @DOC_ID, @CLIENT_CODE, @STATUS, @SENT, @RECEIVED, @SAT_RESULT, GETDATE(), GETDATE(), @LAST_UPDATED_BY);
    IF @@ERROR <> 0
    BEGIN
      ROLLBACK TRANSACTION
      SELECT
        @retCode = 0
      RETURN @retCode
    END
    ELSE
    BEGIN
      COMMIT TRANSACTION
      SELECT
        @retCode = 1
      RETURN @retCode
    END
  END
  ELSE
  BEGIN
    BEGIN TRANSACTION
    UPDATE [FERCO].[OP_WMS_AUTORIZATION_SYNC_SAT]
    SET [DOC_ID] = @DOC_ID
       ,[CLIENT_CODE] = @CLIENT_CODE
       ,[STATUS] = @STATUS
       ,[SENT] = @SENT
       ,[RECEIVED] = @RECEIVED
       ,[SAT_RESULT] = @SAT_RESULT
       ,[LAST_UPDATED] = GETDATE()
       ,[LAST_UPDATED_BY] = @LAST_UPDATED_BY
    WHERE POLIZA = @POLIZA;
    IF @@ERROR <> 0
    BEGIN
      ROLLBACK TRANSACTION
      SELECT
        @retCode = 0
      RETURN @retCode
    END
    ELSE
    BEGIN
      COMMIT TRANSACTION
      SELECT
        @retCode = 2
      RETURN @retCode
    END
  END
