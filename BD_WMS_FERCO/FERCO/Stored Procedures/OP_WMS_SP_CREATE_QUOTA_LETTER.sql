﻿
CREATE PROC FERCO.OP_WMS_SP_CREATE_QUOTA_LETTER @POLIZAS VARCHAR(MAX)
, @CLAVE_ADUANA VARCHAR(20)
, @NOMBRE_ADUANA VARCHAR(100)
, @NO_FACTURA VARCHAR(20)
, @MERCHANDISE_DESCRIPTION VARCHAR(200)
, @MERCHANDISE_QTY NUMERIC(18, 0)
, @MERCHANDISE_VALUE NUMERIC(18, 2)
, @BL_NUMBER VARCHAR(20)
, @CONTAINER_NUMBER VARCHAR(20)
, @CLAVE_AGENTE_ADUANERO VARCHAR(20)
, @NOMBRE_AGENTE_ADUANERO VARCHAR(100)
, @NOMBRE_CONSIGNATARIO VARCHAR(100)
, @NIT_CONSIGNATARIO VARCHAR(100)
, @DOMICILIO_FISCAL_CONSIGNATARIO VARCHAR(100)
, @RELATED_CLIENT_CODE VARCHAR(20)
, @pResult VARCHAR(200) OUTPUT
, @pDocID VARCHAR(200) OUTPUT
AS
BEGIN TRY
  INSERT INTO [FERCO].[OP_WMS_QUOTA_LETTER] ([POLIZAS]
  , [CLAVE_ADUANA]
  , [NOMBRE_ADUANA]
  , [NO_FACTURA]
  , [MERCHANDISE_DESCRIPTION]
  , [MERCHANDISE_QTY]
  , [MERCHANDISE_VALUE]
  , [BL_NUMBER]
  , [CONTAINER_NUMBER]
  , [CLAVE_AGENTE_ADUANERO]
  , [NOMBRE_AGENTE_ADUANERO]
  , [NOMBRE_CONSIGNATARIO]
  , [NIT_CONSIGNATARIO]
  , [DOMICILIO_FISCAL_CONSIGNATARIO]
  , [STATUS]
  , [RELATED_CLIENT_CODE]
  , [LAST_UPDATED]
  , [LAST_UPDATED_BY])
    VALUES (@POLIZAS, @CLAVE_ADUANA, @NOMBRE_ADUANA, @NO_FACTURA, @MERCHANDISE_DESCRIPTION, @MERCHANDISE_QTY, @MERCHANDISE_VALUE, @BL_NUMBER, @CONTAINER_NUMBER, @CLAVE_AGENTE_ADUANERO, @NOMBRE_AGENTE_ADUANERO, @NOMBRE_CONSIGNATARIO, @NIT_CONSIGNATARIO, @DOMICILIO_FISCAL_CONSIGNATARIO, 'SOLICITADA', @RELATED_CLIENT_CODE, CURRENT_TIMESTAMP, @RELATED_CLIENT_CODE)
  SELECT
    @pDocID = SCOPE_IDENTITY()
  SELECT
    @pResult = 'OK'
END TRY

BEGIN CATCH
  ROLLBACK TRAN;
  SELECT
    @pResult = ERROR_MESSAGE()
END CATCH
