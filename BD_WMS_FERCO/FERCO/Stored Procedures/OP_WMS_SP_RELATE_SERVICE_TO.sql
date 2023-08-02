
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE FERCO.OP_WMS_SP_RELATE_SERVICE_TO @pCLIENT_ERP_CODE VARCHAR(25),
@pSERVICE_ID VARCHAR(50),
@pLOGIN_ID VARCHAR(25),
@pResult VARCHAR(250) OUTPUT
AS
  DECLARE @pCLIENT_ID VARCHAR(25);

  BEGIN
    BEGIN TRY
      BEGIN
        SELECT
          @pCLIENT_ID =
          ISNULL((SELECT TOP 1
              A.CLIENT_CODE
            FROM FERCO.OP_WMS_VIEW_CLIENTS A
            WHERE A.CLIENT_ERP_CODE = @pCLIENT_ERP_CODE
            ORDER BY CLIENT_CODE)
          , 'N/F')

        IF (@pCLIENT_ID = 'N/F')
        BEGIN
          SELECT
            @pResult = 'CLIENTE ' + @pCLIENT_ERP_CODE + ' NO EXISTE'
          RETURN -1
        END

        INSERT INTO [FERCO].[OP_WMS_SERVICES_TO_BILL] ([CLIENT_ERP_CODE]
        , [CLIENT_CODE]
        , [SERVICE_ID]
        , [SERVICE_DESCRIPTION]
        , [QTY]
        , SERVICE_UM
        , [CREATED_DATETIME]
        , [CREATED_BY]
        , [LAST_UPDATED]
        , [LAST_UPDATED_BY], PROCESS_UPTODATE)
          VALUES (@pCLIENT_ERP_CODE, @pCLIENT_ID, @pSERVICE_ID, (SELECT TOP 1 SERVICE_DESCRIPTION FROM FERCO.OP_WMS_VIEW_SERVICES_FROM_ERP WHERE SERVICE_SEQUENCE = @pSERVICE_ID), 1, (SELECT TOP 1 SERVICE_UM FROM FERCO.OP_WMS_VIEW_SERVICES_FROM_ERP WHERE SERVICE_SEQUENCE = @pSERVICE_ID), CURRENT_TIMESTAMP, @pLOGIN_ID, NULL, NULL, CONVERT(DATE, CURRENT_TIMESTAMP))


        INSERT INTO [FERCO].[OP_WMS_SERVICES_LOG] ([CLIENT_ERP_CODE]
        , [SERVICE_ID]
        , [ACTION_NAME]
        , [LAST_QTY]
        , [NEW_QTY]
        , [CREATED_DATETIME]
        , [CREATED_BY])
          VALUES (@pCLIENT_ERP_CODE, @pSERVICE_ID, 'CREATED', 0, 1, CURRENT_TIMESTAMP, @pLOGIN_ID)


        IF @@ERROR = 0
        BEGIN
          SELECT
            @pResult = 'OK'
        END
        ELSE
        BEGIN
          SELECT
            @pResult = ERROR_MESSAGE()
        END
      END

    END TRY
    BEGIN CATCH
      SELECT
        @pResult = ERROR_MESSAGE()
    END CATCH

  END
