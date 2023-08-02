
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE FERCO.OP_WMS_SP_AUDIT_DISPATCH_RESET @pAUDIT_ID NUMERIC(18, 0),
@pBARCODE_ID VARCHAR(50),
@pResult VARCHAR(250) OUTPUT
AS
  DECLARE @pMATERIAL_ID VARCHAR(50);

  BEGIN
    BEGIN TRY
      BEGIN
        SELECT
          @pMATERIAL_ID = (SELECT
              MATERIAL_ID
            FROM [FERCO].OP_WMS_MATERIALS
            WHERE (BARCODE_ID = @pBARCODE_ID
            OR ALTERNATE_BARCODE = @pBARCODE_ID))

        IF (@pBARCODE_ID = '*')
        BEGIN
          DELETE [FERCO].OP_WMS_IMAGENES_POLIZA
          WHERE AUDIT_ID = @pAUDIT_ID
            AND AUDIT_TYPE = 'DISPATCH'
          DELETE FROM [FERCO].OP_WMS_AUDIT_DISPATCH_SKUS
          WHERE AUDIT_ID = @pAUDIT_ID
        END
        ELSE
          DELETE FROM [FERCO].OP_WMS_AUDIT_DISPATCH_SKUS
          WHERE AUDIT_ID = @pAUDIT_ID
            AND MATERIAL_ID = @pMATERIAL_ID

        IF (@pBARCODE_ID = '*')
        BEGIN
          DELETE [FERCO].OP_WMS_IMAGENES_POLIZA
          WHERE AUDIT_ID = @pAUDIT_ID
            AND AUDIT_TYPE = 'DISPATCH'
          DELETE FROM [FERCO].OP_WMS_AUDIT_DISPATCH_SERIES
          WHERE AUDIT_ID = @pAUDIT_ID
        END
        ELSE
          DELETE FROM [FERCO].OP_WMS_AUDIT_DISPATCH_SERIES
          WHERE AUDIT_ID = @pAUDIT_ID
            AND MATERIAL_ID = @pMATERIAL_ID


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
