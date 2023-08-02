﻿
-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		28-Oct-16 @ A-Team Sprint 4
-- Description:			    SP que actualiza el detalle del acuerdo comercial

/*
-- Ejemplo de Ejecucion:
        DECLARE @pResult VARCHAR(250) = ''
		--
		EXEC [FERCO].[OP_WMS_SP_UPDATE_TARIFICADOR_DETAIL]
			@ACUERDO_COMERCIAL = '12'
			,@SERIAL_ID = 11
			,@TYPE_CHARGE_ID = 1
			,@UNIT_PRICE = 10
			,@CURRENCY = 'CURRENCY'
			,@LAST_UPDATED_BY = 'LAST_UPDATED_BY'
			,@COMMENTS = 'COMMENTS'
			,@BILLING_FRECUENCY = 50
			,@LIMIT_TO = 50
			,@TYPE_MEASURE = 'TYPE_MEASURE'
			,@U_MEASURE = 'U_MEASURE'
			,@TX_SOURCE = 'TX_SOURCE'
			,@pResult = @pResult OUTPUT
		--
		SELECT @pResult [pResult]
		--
		SELECT * FROM  [FERCO].[OP_WMS_TARIFICADOR_DETAIL] WHERE [ACUERDO_COMERCIAL] = 12
*/
-- =============================================
CREATE PROCEDURE FERCO.OP_WMS_SP_UPDATE_TARIFICADOR_DETAIL (@ACUERDO_COMERCIAL INT
, @SERIAL_ID INT
, @TYPE_CHARGE_ID INT
, @UNIT_PRICE INT
, @CURRENCY VARCHAR(20)
, @LAST_UPDATED_BY VARCHAR(25)
, @COMMENTS VARCHAR(MAX)
, @BILLING_FRECUENCY INT
, @LIMIT_TO INT
, @TYPE_MEASURE VARCHAR(25)
, @U_MEASURE VARCHAR(15)
, @TX_SOURCE VARCHAR(25)
, @pResult VARCHAR(250) OUTPUT)
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRAN;
  BEGIN
    UPDATE [FERCO].[OP_WMS_TARIFICADOR_DETAIL]
    SET [TYPE_CHARGE_ID] = @TYPE_CHARGE_ID
       ,[UNIT_PRICE] = @UNIT_PRICE
       ,[CURRENCY] = @CURRENCY
       ,[LAST_UPDATED] = GETDATE()
       ,[LAST_UPDATED_BY] = @LAST_UPDATED_BY
       ,[COMMENTS] = @COMMENTS
       ,[BILLING_FRECUENCY] = @BILLING_FRECUENCY
       ,[LIMIT_TO] = @LIMIT_TO
       ,[U_MEASURE] = @U_MEASURE
       ,[TX_SOURCE] = @TX_SOURCE
       ,[TYPE_MEASURE] = @TYPE_MEASURE
    WHERE [ACUERDO_COMERCIAL] = @ACUERDO_COMERCIAL
    AND [SERIAL_ID] = @SERIAL_ID;

  END;
  IF @@ERROR = 0
  BEGIN
    SELECT
      @pResult = 'OK';
    COMMIT TRAN;
  END;
  ELSE
  BEGIN
    ROLLBACK TRAN;
    SELECT
      @pResult = ERROR_MESSAGE();
  END;

END;
