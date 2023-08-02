﻿
CREATE PROCEDURE FERCO.OP_WMS_SP_CERTIFICATION_BY_SERIAL_NUMBER @CERTIFICATION_HEADER_ID INT
, @MATERIAL_ID VARCHAR(50)
, @SERIAL_NUMBER VARCHAR(50)
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY

    DELETE [FERCO].[OP_WMS_CERTIFICATION_BY_SERIAL_NUMBER]
    WHERE [CERTIFICATION_HEADER_ID] = @CERTIFICATION_HEADER_ID
      AND [MATERIAL_ID] = @MATERIAL_ID
      AND [SERIAL_NUMBER] = @SERIAL_NUMBER

    SELECT
      1 AS [Resultado]
     ,'Proceso Exitoso' [Mensaje]
     ,0 [Codigo]
     ,'0' [DbData];

  END TRY
  BEGIN CATCH
    SELECT
      -1 AS [Resultado]
     ,ERROR_MESSAGE() [Mensaje]
     ,@@error [Codigo];
  END CATCH;

END