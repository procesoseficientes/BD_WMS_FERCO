﻿
--USE [OP_WMS]
--GO

--/****** Object:  StoredProcedure [FERCO].[OP_WMS_SP_START_CAMPAIGN]    Script Date: 06/02/2011 11:02:24 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO



CREATE PROCEDURE  [FERCO].[OP_WMS_SP_REVERT_POLIZA_DETAIL_LINE] 
(
	@pNUMERO_ORDEN varchar(25),
	@pLINE_NUMBER NUMERIC(18,0)
)
AS
BEGIN

-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

BEGIN TRANSACTION

BEGIN TRY
	
	UPDATE [FERCO].OP_WMS_POLIZA_DETAIL SET PICKING_STATUS = 'PENDING'
	WHERE DOC_ID = (SELECT DOC_ID FROM OP_WMS_POLIZA_HEADER WHERE NUMERO_ORDEN  = @pNUMERO_ORDEN) 
	AND LINE_NUMBER = @pLINE_NUMBER
	
	COMMIT TRANSACTION;
	
END TRY
BEGIN CATCH

	ROLLBACK TRANSACTION
	
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT @ErrorMessage = ERROR_MESSAGE(),
           @ErrorSeverity = ERROR_SEVERITY(),
           @ErrorState = ERROR_STATE();

	RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
	
END CATCH;

END





--GO